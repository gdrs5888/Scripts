$menu = @"
1.顯示當前MTU
2.自動配置MTU
3.手動配置MTU
4.恢復預設值(1500)
5.說明
=================
*執行此腳本需提權*
"@
do
{
cls
Write-Host $menu
$userchoose = Read-Host "請輸入選項(數字)"
switch($userchoose)
{
1
{
netsh interface ipv4 show subinterfaces
timeout /t -1
}
3
{
$menu0 = @"
1.乙太網路
2.Wi-Fi
3.自定義
4.返回上一層
==================
參考值
1492>PPPoE
1472>使用ping的最大值
1468>DHCP
1430>VPN&PPTP
576>撥接到ISP

"@
do
{
cls
Write-Host $menu0
$userchoose0 = Read-Host "請輸入選項(數字)"
switch($userchoose0)
{
1
{
$MTU0 = Read-Host "請輸入MTU值(68~1500)"
netsh interface ipv4 set subinterface 乙太網路 mtu= $MTU0 store=persistent
timeout /t -1
}
2
{
$MTU0 = Read-Host "請輸入MTU值(68~1500)"
netsh interface ipv4 set subinterface Wi-Fi mtu= $MTU0 store=persistent
timeout /t -1
}
3
{
$NIC_Name = Read-Host "請輸入網卡名稱"
$MTU = Read-Host "請輸入MTU值(68~1500)"
netsh interface ipv4 set subinterface $NIC_Name mtu= $MTU store=persistent
timeout /t -1
}
4
{
break
}
default
{
Write-Host "無效的選項"
Start-Sleep -Seconds 1
}
}
}
while($userchoose0 -ne '4')
}
4
{
$adapters = Get-NetAdapter | Where-Object { $_.Status -in @("Up","Disconnected") -and $_.Name -notlike "*區域*" }
foreach($adapter in $adapters)
{
Write-Host "設定介面[$($adapter.Name)]的MTU為1500"
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=1500 store=persistent
}
timeout /t -1
}
2
{
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -notlike "*區域*" }
foreach($adapter in $adapters)
{
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=1500 store=persistent
}
$TargetIP = Read-Host "請輸入目標IP(例如8.8.8.8)"
$payload = 1472
Write-Host "正在配置，請稍後..."
$found = $false
while ($payload -ge 40)
{
$result = ping $TargetIP -f -l $payload -n 1
if($result -match "ms")
{
$bestPayload = $payload +28
Write-Host 偵測最佳MTU為 $bestPayload
foreach($adapter in $adapters)
{
Write-Host "已將介面[$($adapter.Name)]的MTU設為 $bestPayload "
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu= $bestPayload store=persistent
}
$found = $true
break
}
$payload--
}
if(-not $found)
{
Write-Host "此IP無法配置!"
}
timeout /t -1
}
5
{
@"

1.何時該更改MTU?

明顯延遲飄高但本地網路正常
遊戲頻繁「斷線重連」但ping穩定
使用VPN/Proxy加速器遊戲
遊戲流量為UDP為主（如FPS/MMORPG）
使用手機熱點或ISP穩定性差

-----------------------

2.如何找出最佳MTU?

下列以連線至Google_DNS為指標，由於全球皆有節點且穩定，它能體現「從出發，穿過ISP和國際骨幹」的連線狀況。
若要找出特定應用程式的最佳MTU需將8.8.8.8換成與之對應的IP。
過大或過小的MTU皆會降低傳輸效率，由於網路使用環境因人而異，故需透過測試流程得出最佳值。
Step1.開啟cmd
Step2.輸入 "ping -f -l 1472 8.8.8.8"
Step3.從1472開始測試，若顯示封包需切割則繼續往下調整，直到可順利ping通為止
Step4.假設"ping -f -l 1450 8.8.8.8"成功，則最佳MTU為1450+28=1478
-l參數設定的是Payload大小，並不包含IP Header(20 Bytes)與ICMP Header(8 Bytes)。所以實際MTU需要額外加上28，作為補正。

"@
timeout /t -1
}
default
{
Write-Host "無效的選項"
Start-Sleep -Seconds 1
}
}
}
while($userchoose -ne '3.1415926')