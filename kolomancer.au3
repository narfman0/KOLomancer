;Bot for kingdom of loathing, focused on pastamancer (summon noodles)
;After summoning noodles and cooking, will adventure until adventures expended
;@TODO add food/booze consuming
;@TODO add materials purchasing

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ie.au3>

_IEErrorHandlerRegister("IE3ErrorHandler")
$rootURL="http://www.kingdomofloathing.com/"
HotKeySet("{ESC}", "Terminate")
HotKeySet("{PAUSE}", "TogglePause")
Dim $oIE
Dim $mainpane
Dim $StartButton
Dim $usernameCtrl
Dim $passwordCtrl
Dim $AreaList
Dim $areaID
Dim $running = 0
Dim $pauseTime = 150
Dim $eat = 1
Dim $drink = 1
Dim $max_alcohol = 19
Dim $craft_quantity = 5
Dim $craft_id = 3006 ;noodles

GUIInit()

Func GUIInit()
   $Form1 = GUICreate("KOLomancer", 257, 146, 192, 124)
   $StartButton = GUICtrlCreateButton("Start", 136, 72, 75, 25)
   $AreaList = GUICtrlCreateList("", 8, 72, 121, 45)
   GUICtrlSetData(-1, "Icy Peak|Knob Goblin Treasury")
   $usernameLabel = GUICtrlCreateLabel("Username:", 8, 16, 55, 17)
   $passwordLabel = GUICtrlCreateLabel("Password:", 8, 48, 53, 17)
   $usernameCtrl = GUICtrlCreateEdit("", 64, 8, 185, 25, $ES_WANTRETURN)
   $passwordCtrl = GUICtrlCreateEdit("", 64, 40, 185, 25, $ES_WANTRETURN)
   GUISetState(@SW_SHOW)

   While True
	  GUITick()
	  If StringInStr(_IEBodyReadText($mainpane), "You're out of adventures") Then
		 $running = 0
	  EndIf
	  If $running Then
		 Adventure()
	  EndIf
   WEnd
EndFunc

Func GUITick()
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 $running = 0
		 Exit
	  Case $StartButton
		 $area = GUICtrlRead($AreaList)
		 If $area = "Icy Peak" Then
			$areaID = 110
		 ElseIf $area = "Knob Goblin Treasury" Then
			$areaID = 260
		 EndIf
		 Attach()
		 Summon()
		 Cook()
		 Consume()
		 $running = 1
   EndSwitch
 EndFunc

Func Attach()
   $oIE = _IEAttach("The Kingdom of Loathing")
   If @error <> 0 Then
	  $oIE = _IECreate ($rootURL) 
	  $oForm = _IEFormGetObjByName ($oIE, "Login")  
	  $oQuery1 = _IEFormElementGetObjByName ($oForm, "loginname")  
	  $oQuery2 = _IEFormElementGetObjByName ($oForm, "password")   
	  _IEFormElementSetValue ($oQuery1,GUICtrlRead($usernameCtrl))  
	  _IEFormElementSetValue ($oQuery2,GUICtrlRead($passwordCtrl))  
	  _IEFormSubmit($oForm)
	  _IELoadWait($oIE)
   EndIf
   $mainpane = _IEFrameGetObjByName($oIE, "mainpane")
EndFunc

Func Adventure()
   If Not StringInStr(_IEBodyReadText($mainpane), "You're fighting a") Or StringInStr(_IEBodyReadText($mainpane), "Go back to ") Then
	  _IENavigate($mainpane, $rootURL & "adventure.php?snarfblat=" & $areaID)
   Else
	  If StringInStr(_IEBodyReadText($mainpane), "Snow Queen") Then
		 $skillForm = _IEFormGetObjByName ($mainpane, "skill")
		 $sQuery = _IEFormElementGetObjByName ($skillForm, "whichskill")
		 _IEFormElementSetValue ($sQuery,3005);cannelloni cannon id
		 _IEFormSubmit($skillForm)
	  Else
		 ;attack button
		 $oButton=_IEGetObjById($mainpane,"tack")  
		 _IEAction ($oButton, "click")  
	  EndIf
   EndIf
   _IELoadWait($mainpane)
   Sleep($pauseTime)
EndFunc

Func Summon()
   _IENavigate($mainpane, $rootURL & "skills.php")
   Sleep($pauseTime)
   $skillForm = _IEFormGetObjByName ($mainpane, "skillform")
   $sQuery = _IEFormElementGetObjByName ($skillForm, "whichskill")
   $qQuery = _IEFormElementGetObjByName ($skillForm, "quantity")
   _IEFormElementSetValue ($sQuery,$craft_id)
   _IEFormElementSetValue ($qQuery,$craft_quantity)
   _IEFormSubmit($skillForm)
   _IELoadWait($mainpane)
   Sleep($pauseTime)
EndFunc

Func Cook()
   ;cook knoll lo mein http://www.kingdomofloathing.com/craft.php?mode=cook&steps%5B%5D=205,723&steps%5B%5D=304,804
   _IENavigate($mainpane, $rootURL & "craft.php?mode=cook&steps%5B%5D=205,723&steps%5B%5D=304,804")
   Sleep($pauseTime)
   $cookForm = _IEFormGetObjByName ($mainpane, "master")
   $qQuery = _IEFormElementGetObjByName ($cookForm, "qty")
   _IEFormElementSetValue ($qQuery, $craft_quantity)
   _IEFormSubmit($cookForm)
   Sleep($pauseTime)
EndFunc

Func Consume()
   _IENavigate($mainpane, $rootURL & "inventory.php?which=1")
   For $i = 0 To $max_alcohol - 1
	  _IELinkClickByText($mainpane, "[drink]", $drink)
	  Sleep($pauseTime)
	  _IELinkClickByText($mainpane, "[eat]", $eat)
	  Sleep($pauseTime)
   Next
EndFunc

Func IE3ErrorHandler()
	; Important: the error object variable MUST be named $oIEErrorHandler
	Local $ErrorScriptline = $oIEErrorHandler.scriptline
	Local $ErrorNumber = $oIEErrorHandler.number
	Local $ErrorNumberHex = Hex($oIEErrorHandler.number, 8)
	Local $ErrorDescription = StringStripWS($oIEErrorHandler.description, 2)
	Local $ErrorWinDescription = StringStripWS($oIEErrorHandler.WinDescription, 2)
	Local $ErrorSource = $oIEErrorHandler.Source
	Local $ErrorHelpFile = $oIEErrorHandler.HelpFile
	Local $ErrorHelpContext = $oIEErrorHandler.HelpContext
	Local $ErrorLastDllError = $oIEErrorHandler.LastDllError
	Local $ErrorOutput = ""
	$ErrorOutput &= "--> COM Error Encountered in " & @ScriptName & @CR
	$ErrorOutput &= "----> $ErrorScriptline = " & $ErrorScriptline & @CR
	$ErrorOutput &= "----> $ErrorNumberHex = " & $ErrorNumberHex & @CR
	$ErrorOutput &= "----> $ErrorNumber = " & $ErrorNumber & @CR
	$ErrorOutput &= "----> $ErrorWinDescription = " & $ErrorWinDescription & @CR
	$ErrorOutput &= "----> $ErrorDescription = " & $ErrorDescription & @CR
	$ErrorOutput &= "----> $ErrorSource = " & $ErrorSource & @CR
	$ErrorOutput &= "----> $ErrorHelpFile = " & $ErrorHelpFile & @CR
	$ErrorOutput &= "----> $ErrorHelpContext = " & $ErrorHelpContext & @CR
	$ErrorOutput &= "----> $ErrorLastDllError = " & $ErrorLastDllError
	;MsgBox(0, "COM Error", $ErrorOutput)
	SetError(1)
	Return
EndFunc