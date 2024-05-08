param (
    [Parameter(Mandatory = $true, ParameterSetName = 'Path', Position = 0)]
    [string]$Path
)

function ConvertTraceIDToConnectionPeerID {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TraceID
    )

    # Convert the GUID string into a byte array
    $A = $TraceID -split '(..)' | Where-Object { $_ }
    $GUID = $A[3] + $A[2] + $A[1] + $A[0] + $A[5] + $A[4] + $A[7] + $A[6] + $A[8] + $A[9] + $A[10] + $A[11] + $A[12] + $A[13] + $A[14] + $A[15]

    # Convert the reversed GUID string back to a GUID format
    $reversedGuid = [guid]::ParseExact($GUID, "N")

    return $reversedGuid
}

function ParseTraceIDFromNetworkPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NPPath,
        [Parameter(Mandatory = $false)]
        [string]$TsharkPath = "C:\Program Files\Wireshark"
    )

    if (Test-Path -Path $TsharkPath) {
        if ($env:PATH -notcontains $TsharkPath) { $env:PATH += ";" + $TsharkPath }
        # "C:\Program Files\Wireshark\tshark.exe" -Y "tds.type == 18 && !tls && tds.status==1 && tcp.dstport==1433" -T ek -r port56358.pcap
        $result = Invoke-Expression "tshark.exe -r $NPPath -Y `"tds.type == 18 && !tls && tds.status==1 && tcp.dstport==1433`" -T fields -e frame.time_utc -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport -e tcp.stream  -e tds.prelogin.option.traceid -E separator=, -E quote=d -E occurrence=f"
        return $result
    }
    else {
        Write-Error "Please make sure we have installed Wireshark and the $TsharkPath is right."
    }
}
$Headers = 'UtcTime', 'SrcIP', 'SrcPort', 'DstIP', 'DstPort', 'StreamId', 'TraceId'
ParseTraceIDFromNetworkPackage -NPPath $Path | convertfrom-csv -Header $Headers |
Select-Object @{Name = 'UtcTime'; Expression = { $_.UtcTime } }, @{Name = 'SrcIP'; Expression = { $_.SrcIP } }, @{Name = 'SrcPort'; Expression = { $_.SrcPort } }, @{Name = 'DstIP'; Expression = { $_.DstIP } }, @{Name = 'DstPort'; Expression = { $_.DstPort } }, @{Name = 'StreamId'; Expression = { $_.StreamId } }, @{Name = 'connection_peer_id'; Expression = { ConvertTraceIDToConnectionPeerID -TraceID $_.TraceId.Substring(0, 32) } }, @{Name = 'peer_activity_id'; Expression = { ConvertTraceIDToConnectionPeerID -TraceID $_.TraceId.Substring(32, 32) } }
| Format-Table
