;Bot for kingdom of loathing, focused on pastamancer (summon noodles)
;After summoning noodles and cooking, will adventure in gnoll treasury
;until adventures expended
;@TODO add food/booze consuming
;@TODO add materials purchasing

#include <ie.au3>  

$uname="your username"
$pwd="your password"
$rootURL="http://www.kingdomofloathing.com/"
HotKeySet("{ESC}", "Terminate")
HotKeySet("{PAUSE}", "TogglePause")
Dim $oIE
Dim $mainpane

Func Start()
   $oIE = _IEAttach("The Kingdom of Loathing")
   If @error <> 0 Then
	  $oIE = _IECreate ($rootURL) 
	  $oForm = _IEFormGetObjByName ($oIE, "Login")  
	  $oQuery1 = _IEFormElementGetObjByName ($oForm, "loginname")  
	  $oQuery2 = _IEFormElementGetObjByName ($oForm, "password")   
	  _IEFormElementSetValue ($oQuery1,$uname)  
	  _IEFormElementSetValue ($oQuery2,$pwd)  
	  _IEFormSubmit($oForm)
	  _IELoadWait($oIE)
   EndIf
   $mainpane = _IEFrameGetObjByName($oIE, "mainpane")
EndFunc

Func Treasury()
   ;go to treasury
   _IENavigate($mainpane, $rootURL & "adventure.php?snarfblat=260")
   Sleep(100)
   ;attack button
   $oButton=_IEGetObjById($mainpane,"tack")  
   _IEAction ($oButton, "click")  
   _IELoadWait($mainpane)
   Sleep(1000)
EndFunc

Func Summon()
   _IENavigate($mainpane, $rootURL & "skills.php")
   Sleep(100)
   $skillForm = _IEFormGetObjByName ($mainpane, "skillform")
   $sQuery = _IEFormElementGetObjByName ($skillForm, "whichskill")
   $qQuery = _IEFormElementGetObjByName ($skillForm, "quantity")
   _IEFormElementSetValue ($sQuery,3006);noodles id
   _IEFormElementSetValue ($qQuery,3)
   _IEFormSubmit($skillForm)
   _IELoadWait($mainpane)
   Sleep(1000)
EndFunc

Func Cook()
   ;cook knoll lo mein http://www.kingdomofloathing.com/craft.php?mode=cook&steps%5B%5D=205,723&steps%5B%5D=304,804
   _IENavigate($mainpane, $rootURL & "craft.php?mode=cook&steps%5B%5D=205,723&steps%5B%5D=304,804")
   Sleep(100)
   $cookForm = _IEFormGetObjByName ($mainpane, "master")
   $qQuery = _IEFormElementGetObjByName ($cookForm, "qty")
   _IEFormElementSetValue ($qQuery,3)
   _IEFormSubmit($cookForm)
   Sleep(1000)
EndFunc

Func Consume()
   _IENavigate($mainpane, $rootURL & "inventory.php?which=1")
   Sleep(100)
   ;gnoll lo mein specifically <a href="inv_eat.php?pwd=c7ddd0ab0a08aa42a643e222f26bae10&amp;which=1&amp;whichitem=1589">[eat]</a>
EndFunc

Start()
Summon()
Cook()
;Consume()
While Not StringInStr(_IEBodyReadText($mainpane), "You're out of adventures")
   Treasury()
WEnd

