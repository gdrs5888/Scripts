$menu = @"
1.��ܷ�eMTU
2.�۰ʰt�mMTU
3.��ʰt�mMTU
4.��_�w�]��(1500)
5.����
=================
*���榹�}���ݴ��v*
"@
do
{
cls
Write-Host $menu
$userchoose = Read-Host "�п�J�ﶵ(�Ʀr)"
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
1.�A�Ӻ���
2.Wi-Fi
3.�۩w�q
4.��^�W�@�h
==================
�Ѧҭ�
1492>PPPoE
1472>�ϥ�ping���̤j��
1468>DHCP
1430>VPN&PPTP
576>������ISP

"@
do
{
cls
Write-Host $menu0
$userchoose0 = Read-Host "�п�J�ﶵ(�Ʀr)"
switch($userchoose0)
{
1
{
$MTU0 = Read-Host "�п�JMTU��(68~1500)"
netsh interface ipv4 set subinterface �A�Ӻ��� mtu= $MTU0 store=persistent
timeout /t -1
}
2
{
$MTU0 = Read-Host "�п�JMTU��(68~1500)"
netsh interface ipv4 set subinterface Wi-Fi mtu= $MTU0 store=persistent
timeout /t -1
}
3
{
$NIC_Name = Read-Host "�п�J���d�W��"
$MTU = Read-Host "�п�JMTU��(68~1500)"
netsh interface ipv4 set subinterface $NIC_Name mtu= $MTU store=persistent
timeout /t -1
}
4
{
break
}
default
{
Write-Host "�L�Ī��ﶵ"
Start-Sleep -Seconds 1
}
}
}
while($userchoose0 -ne '4')
}
4
{
$adapters = Get-NetAdapter | Where-Object { $_.Status -in @("Up","Disconnected") -and $_.Name -notlike "*�ϰ�*" }
foreach($adapter in $adapters)
{
Write-Host "�]�w����[$($adapter.Name)]��MTU��1500"
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=1500 store=persistent
}
timeout /t -1
}
2
{
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -notlike "*�ϰ�*" }
foreach($adapter in $adapters)
{
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=1500 store=persistent
}
$TargetIP = Read-Host "�п�J�ؼ�IP(�Ҧp8.8.8.8)"
$payload = 1472
Write-Host "���b�t�m�A�еy��..."
$found = $false
while ($payload -ge 40)
{
$result = ping $TargetIP -f -l $payload -n 1
if($result -match "ms")
{
$bestPayload = $payload +28
Write-Host �����̨�MTU�� $bestPayload
foreach($adapter in $adapters)
{
Write-Host "�w�N����[$($adapter.Name)]��MTU�]�� $bestPayload "
netsh interface ipv4 set subinterface "$($adapter.Name)" mtu= $bestPayload store=persistent
}
$found = $true
break
}
$payload--
}
if(-not $found)
{
Write-Host "��IP�L�k�t�m!"
}
timeout /t -1
}
5
{
@"

1.��ɸӧ��MTU?

���㩵���ư������a�������`
�C���W�c�u�_�u���s�v��pingí�w
�ϥ�VPN/Proxy�[�t���C��
�C���y�q��UDP���D�]�pFPS/MMORPG�^
�ϥΤ�����I��ISPí�w�ʮt

-----------------------

2.�p���X�̨�MTU?

�U�C�H�s�u��Google_DNS�����СA�ѩ���y�Ҧ��`�I�Bí�w�A������{�u�q�X�o�A��LISP�M��ڰ��F�v���s�u���p�C
�Y�n��X�S�w���ε{�����̨�MTU�ݱN8.8.8.8�����P��������IP�C
�L�j�ιL�p��MTU�ҷ|���C�ǿ�Ĳv�A�ѩ�����ϥ����Ҧ]�H�Ӳ��A�G�ݳz�L���լy�{�o�X�̨έȡC
Step1.�}��cmd
Step2.��J "ping -f -l 1472 8.8.8.8"
Step3.�q1472�}�l���աA�Y��ܫʥ]�ݤ��Ϋh�~�򩹤U�վ�A����i���Qping�q����
Step4.���]"ping -f -l 1450 8.8.8.8"���\�A�h�̨�MTU��1450+28=1478
-l�ѼƳ]�w���OPayload�j�p�A�ä��]�tIP Header(20 Bytes)�PICMP Header(8 Bytes)�C�ҥH���MTU�ݭn�B�~�[�W28�A�@���ɥ��C

"@
timeout /t -1
}
default
{
Write-Host "�L�Ī��ﶵ"
Start-Sleep -Seconds 1
}
}
}
while($userchoose -ne '3.1415926')