; This code creates a menu based on a directory, so it is easy to change and manage without changing any code.
; This code is an adaptation of QuickLinks.ahk, by Jack Dunning.
; http://www.computoredge.com/AutoHotkey/AutoHotkey_Quicklinks_Menu_App.html
; Updated 2021-11-24:
;- Added name of menu as variable
;- Changed functions to V2 compatible
;- Submenu's with the same name are allowed now
;- Special thanks to Swagfag and Just me to fix the getExtIcon function to version V2
; Updates 2023-11-22:
; - Moved to a class


#Requires AutoHotkey v2
#SingleInstance Force


; DEBUG: Dále je kód z Easy Access to Favorite Folders
;----
oMenu := {}
g_AlwaysShowMenu := true
g_Paths := []
g_window_id := 0
g_class := ""

; DEBUG:

oMenu := QuickLinksMenu(QL_Link_Dir := "Links")
TrayTip("Press the [Capslock] key to show the menu")
;return

^RButton::
#y::
CapsLock:: {
	OutputDebug 'The menu was requested.`n'
	DisplayMenu
	return
}

; TODO: START OF THINGS

Class QuickLinksMenu { ; Just run it one time at the start.

	__New(QL_Link_Dir) {
		this.oMenu := {}
		this.InitMenu(QL_Link_Dir)
	}
	; TODO: FIXME: Možná nebude vůbec potřeba to rozdělovat. Záleží na tom, jak to budeme znovuvytvářet.
	InitMenu(QL_Link_Dir) {
		this.QL_Link_Dir := QL_Link_Dir
		If !InStr(QL_Link_Dir, "\") {
			QL_Link_Dir := A_ScriptDir "\" QL_Link_Dir
		}

		SplitPath(QL_Link_Dir, &QL_Menu)

		If !FileExist(QL_Link_Dir) {
			DirCreate(QL_Link_Dir)
		}
		FileCreateShortcut(QL_Link_Dir, QL_Link_Dir "\" QL_Menu ".lnk")

		Loop Files, QL_Link_Dir "\*.*", "FR"
		{
			if InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "R") or InStr(A_LoopFileAttrib, "S") ;Skip any file that is H, R, or S (System).
				continue

			Folder1 := RegExReplace(A_Loopfilefullpath, "(.*\\[^\\]*)\\([^\\]*)\\([^\\]*)", "$2")
			FolderPath := RegExReplace(A_Loopfilefullpath, "(.*\\[^\\]*)\\([^\\]*)\\([^\\]*)", "$1\$2")
			Folder1Menu := QL_Menu StrReplace(StrReplace(RegExReplace(A_Loopfilefullpath, "(.*\\[^\\]*\\[^\\]*)\\([^\\]*)", "$1"), QL_Link_Dir), "\")
			Folder2Menu := QL_Menu StrReplace(StrReplace(RegExReplace(A_Loopfilefullpath, "(.*\\[^\\]*)\\([^\\]*)\\([^\\]*)", "$1"), QL_Link_Dir), "\")

			Linkname := StrReplace(A_LoopFileName, ".lnk")

			if !this.oMenu.HasOwnProp(Folder1Menu) {
				this.oMenu.%Folder1Menu% := Menu()
			}

			this.Command_Set(this.oMenu.%Folder1Menu%, Linkname, A_LoopFilePath)
			;this.oMenu.%Folder1Menu%.Add(Linkname, OpenFavorite.Bind(Linkname, LinkTarget))
			;this.oMenu.%Folder1Menu%.Add(Linkname, ((Functon1, Parameter, *) => (%Functon1%(Parameter))).Bind("Run", A_Loopfilefullpath))

			this.Icon_Add(this.oMenu.%Folder1Menu%, Linkname, A_LoopFilePath) ; icon


			if !this.oMenu.HasOwnProp(Folder2Menu) {
				this.oMenu.%Folder2Menu% := Menu()
			}

			this.oMenu.%Folder2Menu%.Add(Folder1, this.oMenu.%Folder1Menu%) ; Create submenu
			; TODO: FIXME: This loops to many times. Icon could be set only for first time. Same for submenu? To many requests for ini & checks for tmp non available folders.
			;-> rewrite oMenu? parse separately folders and separately .ink files? Possibly it would be possible to make links from submenus
			;this.Icon_Folder_Add(this.oMenu.%Folder2Menu%, Folder1, FolderPath) ; icon for folder
			this.oMenu.%Folder2Menu%.SetIcon(Folder1, A_Windir "\syswow64\SHELL32.dll", "5") ; icon for folder

		}
		;this.oMenu.%this.QL_Link_Dir%.Add("Reload QuickLinks", this.Recreate.Bind(this, this.QL_Link_Dir)) ; FIXME: Add command to Recreate Menu
		return this.oMenu
	}

	Recreate(QL_Link_Dir) { ;FIXME:
		OutputDebug 'Recreate called.'
		;this.oMenu := {}
		;this.InitMenu(QL_Link_Dir)
		;return this.oMenu
	}

	Show() {
		;Refresh DarkMode state when menu Called.
		LightTheme := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
		if !LightTheme {
			this.SetDarkMode()
		}
		this.oMenu.%this.QL_Link_Dir%.Show()
	}

	Command_Set(menuitem, linkname, LoopFileFullPath) { ; set command based on extention or name
		; Find direct links to folders for instant switching.
		If InStr(LoopFileFullPath, ".lnk") {
			FileGetShortcut(LoopFileFullPath, &LinkTargetPath)
		}
		Else {
			LinkTargetPath := LoopFileFullPath
		}
		menuitem.Add(linkname, OpenFavorite.Bind(linkname, LinkTargetPath, LoopFileFullPath))
	}

	Icon_Add(menuitem, submenu, LoopFileFullPath) { ; add icon based on extention or name
		IconFile := ""
		IconIndex := ""

		If InStr(LoopFileFullPath, ".lnk") {
			FileGetShortcut(LoopFileFullPath, &File, , , , &OutIcon, &OutIconNum)
			if (OutIcon != "") {
				menuitem.SetIcon(submenu, OutIcon, OutIconNum)
				return
			}
		}
		Else {
			File := LoopFileFullPath
		}

		;if Target Unavailable - Important for temporaly Unavalilable link targets.
		if not FileExist(File) {
			menuitem.SetIcon(submenu, A_Windir "\syswow64\SHELL32.dll", "67")
			return
		}

		;if Folder
		if InStr(FileExist(File), "D") {
			;region Icon from .ini REVIEW: Enhancement: Add icon for folders. FolderPainter.
			;encapsulate TODO:
			this.Icon_Folder_Add(menuitem, submenu, File)
			return
		}

		;else File
		Extension := RegExReplace(File, "([^\.]*)(\.[^\.]*).*", "$2")
		;Extension2 := RegExReplace(File, "([^\.]*)(\..*)", "$2") ;Unused part of code.
		Icon_nr := 0

		If (Extension = ".exe") {
			try {
				menuitem.SetIcon(submenu, file, "1")
			}
			return
		}

		IconFile := this.getExtIcon(StrReplace(Extension, "."))

		If InStr(Extension, "\")
			menuitem.SetIcon(submenu, A_Windir "\syswow64\SHELL32.dll", "5")
		Else If (Extension = ".ahk")
			menuitem.SetIcon(submenu, "autohotkey.exe", "2")
		Else If (Extension ~= "i)\.(jpg|png)")
			menuitem.SetIcon(submenu, A_Windir "\system32\Imageres.dll", "68")
		Else If (Extension = ".txt")
			menuitem.SetIcon(submenu, A_Windir "\syswow64\Notepad.exe", "0")
		Else If InStr(IconFile, " - ") {
			try {
				RegExMatch(IconFile, "(.*) - (\d*)", &IconFile)
				menuitem.SetIcon(submenu, IconFile[1], IconFile[2])
			}
			Catch {
				MsgBox(IconFile[1] "`n" IconFile[2] "`next:" Extension)
			}
			return
		}
		Return
	}

	Icon_Folder_Add(menuitem, submenu, FolderPath) { ; add icon for folders
		IniFile := FolderPath "\desktop.ini"
		if FileExist(IniFile) {
			ReadDesktopIni(IniFile, &IconFile, &IconIndex)
			AbsoluteIconPath := ConvertToAbsolutePath(IconFile, FolderPath)
			OutputDebug 'IconToSet:' AbsoluteIconPath ',' IconIndex '`n'
			menuitem.SetIcon(submenu, AbsoluteIconPath, IconIndex)
		}
		else {
			menuitem.SetIcon(submenu, A_Windir "\syswow64\SHELL32.dll", "5")
		}
	}

	getExtIcon(Ext) {
		from := RegRead("HKEY_CLASSES_ROOT\." Ext)
		DefaultIcon := RegRead("HKEY_CLASSES_ROOT\" from "\DefaultIcon")
		; TODO: Use ExpandEnvironmentStrings or ConvertToAbsolutePath
		DefaultIcon := StrReplace(DefaultIcon, '"')
		DefaultIcon := StrReplace(DefaultIcon, "%SystemRoot%", A_WinDir)
		DefaultIcon := StrReplace(DefaultIcon, "%ProgramFiles%", A_ProgramFiles)
		DefaultIcon := StrReplace(DefaultIcon, "%windir%", A_WinDir)

		I := StrSplit(DefaultIcon, ",")

		Return I[1] " - " this.IndexOfIconResource(I[1], RegExReplace(I[2], "[^\d]+"))
	}

	IndexOfIconResource(Filename, ID) {
		; If the DLL isn't already loaded, load it as a data file.
		If !DllCall("GetModuleHandle", "Str", Filename, "UPtr")
			HMOD := DllCall("LoadLibraryEx", "Str", Filename, "Ptr", 0, "UInt", 0x02, "UPtr")
		EnumProc := CallbackCreate(IndexOfIconResource_EnumIconResources, "F")
		Param := Buffer(12, 0)
		NumPut("UInt", ID, Param)
		; Enumerate the icon group resources. (RT_GROUP_ICON=14)
		DllCall("EnumResourceNames", "Ptr", HMOD, "UInt", 14, "Ptr", EnumProc, "Ptr", Param)
		CallbackFree(EnumProc)
		; If we loaded the DLL, free it now.
		If (HMOD)
			DllCall("FreeLibrary", "Ptr", HMOD)
		Return (NumGet(Param, 8, "UInt")) ? NumGet(Param, 4, "UInt") : 0
	}

	SetDarkMode() {
		uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
		SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
		FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
		DllCall(SetPreferredAppMode, "int", 1) ; Dark
		DllCall(FlushMenuThemes)
	}
}

IndexOfIconResource_EnumIconResources(hModule, lpszType, lpszName, lParam) {
	NumPut("UInt", NumGet(lParam + 4, "UInt") + 1, lParam + 4)
	If (lpszName = NumGet(lParam, "UInt")) {
		NumPut("UInt", 1, lParam + 8)
		Return False	; break
	}
	Return True
}


; BASED ON: Easy Access to Favorite Folders (based on the v1 script by Savage)

;----Display the menu
DisplayMenu(*)
{
	; These first few variables are set here and used by OpenFavorite:
	try global g_window_id := WinGetID("A")
	try global g_class := WinGetClass(g_window_id)
	if g_AlwaysShowMenu = false  ; The menu should be shown only selectively.
	{
		if !(g_class ~= "#32770|ExploreWClass|CabinetWClass|ConsoleWindowClass|CASCADIA_HOSTING_WINDOW_CLASS")
			return ; Since it's some other window type, don't display menu.
	}
	; Otherwise, the menu should be presented for this type of window:
	oMenu.Show()
}

;----Open the selected favorite
OpenFavorite(ItemName, LinkTargetPath, LinkPath, *)
{
	control_id := 0
	; Fetch the array element that corresponds to the selected menu item:
	path := LinkTargetPath
	if path = ""
		return
	if g_class = "#32770"    ; It's a dialog.
	{
		; Activate the window so that if the user is middle-clicking
		; outside the dialog, subsequent clicks will also work:
		WinActivate g_window_id
		; Retrieve the unique ID number of the Edit1 control:
		control_id := ControlGetHwnd("Edit1", g_window_id)
		; Retrieve any filename that might already be in the field so
		; that it can be restored after the switch to the new folder:
		text := ControlGetText(control_id)
		ControlSetText path, control_id
		ControlFocus control_id
		ControlSend "{Enter}", control_id
		Sleep 100  ; It needs extra time on some dialogs or in some cases.
		ControlSetText text, control_id
		return
	}
	else if g_class = "CabinetWClass"  ; In Explorer, switch folders.
	{
		if VerCompare(A_OSVersion, "10.0.22000") >= 0 ; Windows 11 and later
		{
			try GetActiveExplorerTab().Navigate(ExpandEnvVars(path))
		}
		else
		{
			ControlClick "ToolbarWindow323", g_window_id, , , , "NA x1 y1"
			; Wait until the Edit1 control exists:
			while not control_id
				try control_id := ControlGetHwnd("Edit1", g_window_id)
			ControlFocus control_id
			ControlSetText path, control_id
			; Tekl reported the following: "If I want to change to Folder L:\folder
			; then the addressbar shows http://www.L:\folder.com. To solve this,
			; I added a {right} before {Enter}":
			ControlSend "{Right}{Enter}", control_id
		}
		return
	}
	else if g_class ~= "ConsoleWindowClass|CASCADIA_HOSTING_WINDOW_CLASS" ; In a console window, CD to that directory
	{
		WinActivate g_window_id ; Because sometimes the mclick deactivates it.
		SetKeyDelay 0  ; This will be in effect only for the duration of this thread.
		if InStr(path, ":")  ; It contains a drive letter
		{
			path_drive := SubStr(path, 1, 1)
			Send path_drive ":{enter}"
		}
		Send "cd " path "{Enter}"
		return
	}
	; Since the above didn't return, one of the following is true:
	; 1) It's an unsupported window type but g_AlwaysShowMenu is true.
	; Yes. It is. ;)

	;Run "explorer " path  ; Might work on more systems without double quotes.

	;Run LinkPath ; .Ink file call variant. Open existent window. But non consistent.
	Run_explorer(path) ; TODO: Testing.
}

;----Read Desktop.ini for information about Folder icon
ReadDesktopIni(IniFile, &IconFile, &IconIndex) {
	try {
		IconFile := IniRead(IniFile, ".ShellClassInfo", "IconFile")
		IconIndex := IniRead(IniFile, ".ShellClassInfo", "IconIndex")
	}
	catch {
		try {
			IconResource := StrSplit(IniRead(IniFile, ".ShellClassInfo", "IconResource"), ",")
			IconFile := IconResource[1]
			IconIndex := IconResource[2]
		}
	}
}

ConvertToAbsolutePath(relativePath, basePath) {

	ExpandEnvironmentStrings(&relativePath)

	; Check if the path starts with a drive letter and a colon or backslash, which indicates an absolute path
	if (RegExMatch(relativePath, "^\w:\\") || SubStr(relativePath, 1, 2) == "\\")
		return relativePath ; Path is already absolute
	else
		return basePath . "\" . relativePath ; ; Convert to absolute
}

ExpandEnvironmentStrings(&vInputString)
{
	; get the required size for the expanded string
	vSizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Int", 0, "Int", 0)
	If (vSizeNeeded == "" || vSizeNeeded <= 0)
		return False ; unable to get the size for the expanded string for some reason

	vByteSize := vSizeNeeded + 1
	VarSetStrCapacity(&vTempValue, vByteSize)

	; attempt to expand the environment string
	If (!DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Str", vTempValue, "Int", vSizeNeeded))
		return False ; unable to expand the environment string
	vInputString := vTempValue

	; return success
	Return True
}

; Unused part of Code
/*
IsFolderPath(path) {
	return (SubStr(path, -1) = "\" || SubStr(path, -1) = "/")
}
*/

; TODO: Untested.
Run_explorer(path) {
	EnPath := '"' path '"'

	list := explorer_list()
	If InStr(list, EnPath)
	{
		ID := ""
		Loop Parse, list, "`n"
		{
			If InStr(A_LoopField, EnPath)
			{
				ID := StrSplit(A_LoopField, "_")[1]
				WinActivate("ahk_id " ID)
				; TODO: Activate and Find Tab!

				/* 				if VerCompare(A_OSVersion, "10.0.22000") >= 0 ; Windows 11 and later
									;https://www.autohotkey.com/boards/viewtopic.php?t=109907
									;{
									;}
									break
				*/
			}
		}
	}
	else
		Run(path)
}

explorer_list() {
	; Get ID + fullpath of all opened explorer windows:
	DetectHiddenWindows "On" ;TODO: Is it necesary?
	If WinExist("ahk_class CabinetWClass") ; explorer
	{
		list := ""
		for window in ComObject("Shell.Application").Windows
		{
			try explorer_path := window.Document.Folder.Self.Path
			;OutputDebug explorer_path '`n'
			If (explorer_path = "")
				continue
			ID := window.HWND
			;Enclosed path.
			EnEx_path := '"' explorer_path '"'
			list .= ID "_" EnEx_path ? ID "_" EnEx_path "`n" : ""
		}
		list := trim(list, "`n")
		return list
	}
	DetectHiddenWindows "Off" ;TODO: Is it necesary?
}

; TODO: Kód k aplikování a vyzkoušení:
;a viz "Window.HWND and Window.Document.Folder.ahk"
; DetectHiddenWindows
F1:: {
	MsgBox(GetExplorerPath())
}
GetExplorerPath(hwnd := WinExist("A")) {
	activeTab := 0
	try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd)
	for w in ComObject("Shell.Application").Windows {
		if (w.hwnd != hwnd)
			continue
		if activeTab {
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(3, shellBrowser, "uint*", &thisTab := 0)
			if (thisTab != activeTab)
				continue
		}
		return w.Document.Folder.Self.Path
	}
	return false
}
; TODO:

; Get the WebBrowser object of the active Explorer tab for the given window,
; or the window itself if it doesn't have tabs.  Supports IE and File Explorer.
; https://www.autohotkey.com/boards/viewtopic.php?t=109907
GetActiveExplorerTab(hwnd := WinExist("A")) {
	activeTab := 0
	try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	catch
		try activeTab := ControlGetHwnd("TabWindowClass1", hwnd) ; IE
	for w in ComObject("Shell.Application").Windows {
		if w.hwnd != hwnd
			continue
		if activeTab { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(3, shellBrowser, "uint*", &thisTab := 0)
			if thisTab != activeTab
				continue
		}
		return w
	}
}

ExpandEnvVars(str)
{
	if sz := DllCall("ExpandEnvironmentStrings", "Str", str, "Ptr", 0, "UInt", 0)
	{
		buf := Buffer(sz * 2)
		if DllCall("ExpandEnvironmentStrings", "Str", str, "Ptr", buf, "UInt", sz)
			return StrGet(buf)
	}
	return str
}