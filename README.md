# SQLDebuggingTools

## ParseTraceIDfromNetworkPackage.ps1
How to:
- Run Powershell and navigate to the folder
- .\ParseTraceIDfromNetworkPackage.ps1
- Input the full path of your network package
- The script will output below informations:
```
UtcTime                             SrcIP        SrcPort DstIP       DstPort StreamId connection_peer_id                   peer_activity_id
-------                             -----        ------- -----       ------- -------- ------------------                   ----------------
May  3, 2024 09:00:14.185558000 UTC 10.16.97.155 46740   10.16.96.47 1433    237      aee22233-2f83-4d03-9756-f60cd723e25f 0740c1d0-464f-48c0-aff8-4cb537bbc92f
May  3, 2024 09:00:14.307411000 UTC 10.16.97.155 46744   10.16.96.47 1433    242      41d238d7-191d-45b8-8cbc-9e3deb76b046 0740c1d0-464f-48c0-aff8-4cb537bbc92f
```