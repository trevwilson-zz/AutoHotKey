;
; AutoHotkey Version: 1.x
; Language:	   English
; Platform:	   Win9x/NT
; Author:		 sj4c <samuelj123@gmail.com>
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;--------------------------------------
;Start Processing
;--------------------------------------

^+r:: ; press control+r to reload
Reload
return

^+e::

Config:
global type = ""
global Tags = Object()
global ParentProj = ""
global Name = ""
WinActivate, ahk_class ENMainFrame
WinWaitActive, ahk_class ENMainFrame
ControlGetText, Name, ENAutoCompleteEditCtrl2, ahk_class ENMainFrame
goto Rename
return

GuiEscape:
GuiClose:
ButtonCancel:
Gui, Destroy
return 

Rename:
Gui, Destroy
Gui, Add, Text,,Do you want to rename this note?
Gui, Add, Edit, -WantReturn vName, %Name%
Gui, Add, Button, gDelete, &Delete
Gui, Add, Button, gSnooze, &Snooze
Gui, Add, Button, Default gSaveName, &Next
Gui, Show
return

Delete:
global type
type = delete
goto FinishProcessing

SaveName:
Gui, Submit
Gui, Destroy
goto ChooseType

;TODO: Decouple these into separate keyboard shortcuts?
ChooseType:
Gui, Add, Text,, What is this?
Gui, Add, Button,gActionSetup,&1 - Action
Gui, Add, Button,gReference,&2 - Reference Material
Gui, Add, Button,gEvent,&3 - Event
Gui, Add, Button,gProject,&4 - Project
Gui, Show
return

Project:
global ParentProject
ParentProject := Name
Gui, Destroy
Gui, Add, Text,, What's the next action for this project?
Gui, Add, Edit, vProjectAction
Gui, Add, Button, Default gActionSetup, Next
Gui, Show
return

Reference:
global type
type = reference
goto AddTagsSetup

ActionSetup:
global type
type = action
Gui, Submit
if(ParentProject){
	Name = %ProjectAction%
}

Action:
Gui, Destroy
Gui, +AlwaysOnTop -SysMenu +Owner
Gui, Add, Text,, When?*
Gui, Add, DropDownList, vWhen, 1 - Now||2 - Next|3 - Later|4 - Waiting|5 - Someday/Maybe|Recurring
Gui, Add, Text,, Where?*
Gui, Add, DropDownList, vWhere, Computer|Errands|Home|Phone|Work
Gui, Add, Text,, Parent Project
Gui, Add, ComboBox, vParentProject, %ParentProject%||
Gui, Add, Text,, Energy Required
Gui, Add, DropDownList, vEnergy, 1 - Mindless|2 - Easy|3 - Medium|4 - Difficult|5 - Deep Focus
Gui, Add, Text,, Time Required
Gui, Add, DropDownList, vTime, 1 - 5m|2 - 5-30m|3 - 30m-1h|4 - 1-2h|5 - 2+h
Gui, Add, Button, Default gProcessAction,Done
Gui, Show
return

ProcessAction:
Gui, Submit
if(When = "Recurring"){
	Gui, Destroy
	Gui, Add, Text,,Repeat
	Gui, Add, Edit
	Gui, Add, UpDown, vRecurNumber Range1-10, 1
	Gui, Add, Text,, times per
	Gui, Add, DropdownList, vRecurTimeframe, Day||Week|Month|Year
	Gui, Add, Button, gAddTagsSetup, Next}
	Gui, Show
	return
}
goto AddTagsSetup

Event:
global type
type = event
Gui, Destroy
Gui, Add, Text,, When is the event?
Gui, Add, Edit, vEventQuickAdd
Gui, Add, Button, gProcessEvent, Done
Gui, Show
return

ProcessEvent:
global name
name += %EventQuickAdd%
goto FinishProcessing

AddTagsSetup:
global Tags := Object()
goto AddTags

AddTags:
global Tags
Gui, Submit
Gui, Destroy
Gui, Add, Text,, Other Tags
For index,value in Tags
{
  Gui, Add, Text,, %value%
}
Gui, Add, Edit, -WantReturn vNewTag
Gui, Add, Button, Default Hidden gAddTag, addtag
Gui, Add, Button, gFinishProcessing, Done
Gui, Show
return

AddTag:
Gui, Submit
global Tags
Tags.Push(NewTag)
goto AddTags

Snooze:
global type
type = snooze
Gui, Submit
Gui, Destroy
Gui, Add, Text,, When do you want to be reminded?
Gui, Add, DateTime, vSnoozeDate
Gui, Add, Button,Default gSnoozeSave,Done
Gui, Show
return

SnoozeSave:
Gui, Submit
Gui, Destroy
goto FinishProcessing

FinishProcessing:
global type
global Tags
Gui, Submit
Gui, Destroy
WinActivate, ahk_class ENMainFrame

if(type = "delete"){
	SendInput, {Alt}nd
	return
}

WinWaitActive, ahk_class ENMainFrame
ControlFocus, ENAutoCompleteEditCtrl2, ahk_class ENMainFrame
ControlSetText, ENAutoCompleteEditCtrl2, %Name%, ahk_class ENMainFrame
ControlSend, ENAutoCompleteEditCtrl2, {Enter}, ahk_class ENMainFrame

if(type = "event"){
	SendInput, {Ctrl Down}/{Ctrl Up}
	SendInput, {Alt}nd
	return
}

SendInput, {Alt}nt
WinWaitActive, Assign Tags
SendInput, !n

for index,key in Tags{
	SendInput, %key%
	SendInput, {Enter}
}
if(Where){
	SendInput, @%Where%{Enter}
}
if(Energy){
	SendInput, %Energy%{Enter}
}
if(Time){
	SendInput, %Time%{Enter}
}
if(When){
	if(When = "Recurring"){
		SendInput, !Recurring{Enter}
		SendInput, %RecurNumber%x{Enter}
		SendInput, %RecurTimeframe%{Enter}
	}else{
		SendInput, %When%{Enter}
	}
}
if(SnoozeDate){
	SendInput, %SnoozeDate%{Enter}
}if(ParentProject){
	SendInput, %ParentProject%{Enter}
}

SendInput, {Tab}{Tab}{Enter}
WinWaitActive, ahk_class ENMainFrame

moveto = none

if(type = "action"){
	moveto = Pending Actions
}else if (type = "reference"){
	moveto = Reference
}else if(type = "snooze"){
	moveto = Snoozed
}

if(moveto <> "none"){
	SendInput, {Alt}nv
	WinWaitActive, Move Note to Notebook
	SendInput, %moveto%
	Sleep, 100
	SendInput, {Enter}
}

Sleep, 200
goto Config

DestroyGui:
Gui, Destroy
return