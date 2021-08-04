#RequireAdmin
#AutoIt3Wrapper_Res_Fileversion=3.0.0.0
#include <file.au3>
#include <WinAPI.au3>
#include <GuiToolBar.au3>
#include <Date.au3>
#include <Array.au3>
#include <GuiListView.au3>
#include <Constants.au3>
#include <_XMLDomWrapper.au3>
#include <String.au3>
#include <Process.au3>
#include "_Base64.au3"

Opt("WinTitleMatchMode", 2)
Global $win = "[CLASS:#32770]"
Global $ServerPackage, $posPassword, $monPassword, $port,$password, $ServerIP, $regedit, $FilePath, $FileName
Global $portresult, $installMode
Global $IniPath
Global $NowTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC

$IniPath=@ScriptDir & "\ServerInstall.ini"
If FileExists($IniPath) = 0 Then
	MsgBox(4096, "File Error", $IniPath & " doesnot exit!", 10)
	Exit 1
Else
	$FilePath = IniRead($IniPath, "Server", "filepath", "")
	$filelist = _FileListToArray($FilePath, "DeviceOn_Server_Setup_"& "*.exe", 1)
	IniWrite($IniPath, "Server", "ServerPackage", $filelist[$filelist[0]])
	$ServerPackage = IniRead($IniPath, "Server", "serverpackage", "")
	$posPassword = IniRead($IniPath, "Server", "postgrepsw", "")
	$monPassword = IniRead($IniPath, "Server", "mongopsw", "")

	$ServerIP = IniRead($IniPath, "Server", "serverip", "")
	$port = IniRead($IniPath, "Server", "serverport", "")
	$grafanaport = IniRead($IniPath, "Server", "grafanaport", "")
	$ftpport = IniRead($IniPath, "Server", "ftpport", "")
	
	$password = IniRead($IniPath, "Server", "loginpsw", "")
	
	$regedit = "HKLM64\SOFTWARE\Advantech\DeviceOn Server"
EndIf

$FileName = @ScriptDir & "\Serverinstall.txt"
$version = RegRead($regedit, "Version")
;MsgBox(4096, "Program files are in:", RegRead($regedit, "Version"))
If RegRead($regedit, "Version") == "" Then
	;$portresult = _RunDOS('netstat -ano|findstr ":' & $port & '"')
	;While ($portresult = 0)
		;Sleep(10000)
		;$portresult = _RunDOS('netstat -ano|findstr ":' & $port & '"')
	;WEnd
	;$grafanaportresult = _RunDOS('netstat -ano|findstr ":' & $grafanaport & '"')
	;While ($grafanaportresult = 0)
		;Sleep(10000)
		;$grafanaportresult = _RunDOS('netstat -ano|findstr ":' & $grafanaport & '"')
	;WEnd
	Install()
Else
	Upgrade()
EndIf




Func Install()
	If FileExists($FilePath&"\"&$ServerPackage) = 0 Then
		FileWriteLine($FileName, "ServerInstall,Fail,Server Package not exsit!")
		Exit 1
	EndIf
	ShellExecute($FilePath&"\"&$ServerPackage)
	Sleep(60000)
	ControlClick("DeviceOn", "", "Button1");Next
	Sleep(30000)
	ControlClick("DeviceOn", "", "Button3"); accept
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1"); next
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button2");next  ��װ·��Ĭ��
	Sleep(10000)
	ControlSetText("DeviceOn", "", "Edit1", $ServerIP)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1"); Next
	Sleep(10000)
	ControlSetText("DeviceOn", "", "Edit1", $port)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1"); Next
	Sleep(10000)
	ControlSetText("DeviceOn", "", "Edit1", $posPassword)
	ControlSetText("DeviceOn", "", "Edit2", $posPassword)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1");
	Sleep(10000)
	WinActivate("DeviceOn", "")
	ControlSetText("DeviceOn", "", "Edit1", $monPassword)
	ControlSetText("DeviceOn", "", "Edit2", $monPassword)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1");
	Sleep(10000)
	WinActivate("DeviceOn", "")
	ControlClick("DeviceOn", "", "Button2");
	Sleep(10000)
	WinActivate("DeviceOn", "")
	ControlClick("DeviceOn", "", "Button1");   MongoDB Capped Setting
	Sleep(10000)
	WinActivate("DeviceOn", "")
	ControlSetText("DeviceOn", "", "Edit1", $password)
	ControlSetText("DeviceOn", "", "Edit2", $password)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1");
	Sleep(10000)
	WinActivate("DeviceOn", "")
	ControlSetText("DeviceOn", "", "Edit1", $grafanaport)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1");grafana
	Sleep(10000)
	
	WinActivate("DeviceOn", "")
	ControlSetText("DeviceOn", "", "Edit1", $ftpport)
	Sleep(10000)
	ControlClick("DeviceOn", "", "Button1");grafana
	Sleep(10000)
	
	
	WinActivate("DeviceOn", "")
	ControlClick("DeviceOn", "", "Button1");install
	Sleep(100000)
	;wait install finish
	$j=1
	While $j<200
		$var = ControlCommand("DeviceOn", "Finish", "Button1", "IsVisible", "")
		If $var = 1 Then
			Sleep(1000)
			ControlClick("DeviceOn", "", "Button1");
			ExitLoop
		EndIf
		Sleep(10000)
		$j=$j+1
	WEnd

	Sleep(300000)

	If RegRead($regedit, "Version") Then
		FileWriteLine($FileName, "ServerInstall,Pass,Server regedit exsit!")
		Return 1
	Else
		FileWriteLine($FileName, "ServerInstall,Fail,Server regedit not exsit!")
		Exit 1
	EndIf
EndFunc   ;==>Install

Func Upgrade()
	$currentversion = RegRead($regedit, "Version")
	$result = StringInStr($ServerPackage, $currentversion)

	If $result<>0 Then
		FileWriteLine($FileName, "ServerInstall,Fail,Already Exist!")
		Exit 1
	EndIf
	If FileExists($FilePath&"\"&$ServerPackage) = 0 Then
		FileWriteLine($FileName, "ServerInstall,Fail,Server Package not exsit!")
		Exit 1
	EndIf
	ShellExecute($FilePath&"\"&$ServerPackage)
	Sleep(600000)
	ControlClick("DeviceOn", "", "Button1");Next
	Sleep(20000)
	ControlClick("DeviceOn", "", "Button5");Upgrade
	Sleep(20000)
	ControlClick("DeviceOn", "", "Button1");Install
	Sleep(60000)
	;wait install finish
	$i=1
	While $i<50
		$var = ControlCommand("DeviceOn", "OK", "Button1", "IsVisible", "")
		If $var = 1 Then
			Sleep(1000)
			ControlClick("DeviceOn", "", "Button1");
		EndIf
		Sleep(5000)
		$i=$i+1
	WEnd
	$j=1
	While $j<100
		$var = ControlCommand("DeviceOn", "Finish", "Button1", "IsVisible", "")
		If $var = 1 Then
			Sleep(1000)
			ControlClick("DeviceOn", "", "Button1");
			ExitLoop
		EndIf
		Sleep(10000)
		$j=$j+1
	WEnd

	Sleep(300000)
	
	
	If RegRead($regedit, "Version") Then
		$currentversion = RegRead($regedit, "Version")
		$result = StringInStr($ServerPackage, $currentversion)
		If $result<>0 Then
			FileWriteLine($FileName, "ServerInstall,Pass,Server upgrade success!")
			Return 1
		Else
			FileWriteLine($FileName, "ServerInstall,Fail,Server upgrade fail!")
		EndIf
	Else
		FileWriteLine($FileName, "ServerInstall,Fail,Server regedit not exsit!")
		Exit 1
	EndIf
	
EndFunc




