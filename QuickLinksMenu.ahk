; This code creates a menu based on a directory, so it is easy to change and manage without changing any code.

; Acknowledgments
; This code is an adaptation of QuickLinks.ahk, by Jack Dunning.
; http://www.computoredge.com/AutoHotkey/AutoHotkey_Quicklinks_Menu_App.html
; and of subsequent adaptation - QuickLinksMenu_V2, by AHK_user (aka dmtr99)
; https://github.com/dmtr99/QuickLinksMenu_V2
; Subsequently, it has been extended by functions from Easy Access to Favorite Folders (based on the v1 script by Savage).
; https://www.autohotkey.com/docs/v2/scripts/#FavoriteFolders

; Changelog
; Updated 2021-11-24:
;- Added name of menu as variable
;- Changed functions to V2 compatible
;- Submenu's with the same name are allowed now
;- Special thanks to Swagfag and Just me to fix the getExtIcon function to version V2
; Updates 2023-11-22:
; - Moved to a class

; Objev - Menu je navigovatelné klávesnicí

#Requires AutoHotkey v2.0
#SingleInstance Force

; MARK: Depencencies
;{-----------------------------------------------
#Include .\dependency\ini_v2.ahk ; Class for parsing .ini's from TopHatCat


;{-----------------------------------------------
; MARK: Set HOTKEYS
;{-----------------------------------------------

; Set YOUR HOTKEY for Quick Links Menu
; Hotkey for Showing menu:
SimpleHotkey := ["^RButton"] ; <-- SET ME ; Eg. ( Ctrl + Right Mouse Button)
; Hotkey for Showing Extended menu:
ExtendedModifierKey := ["+"] ; <-- SET ME ; Eg. ( Shift ) == Eg. (Ctrl + Shift + Right Mouse Button)

;{-----------------------------------------------


; Assigning all hotkeys to functions
for htky in SimpleHotkey
{
	Hotkey(htky, DisplaySimpleMenu.Bind())
	for mkey in ExtendedModifierKey
		htky := mkey htky
	Hotkey(htky, DisplayExtendedMenu.Bind())
}

; Hotkeys functions:
;^RButton::
DisplaySimpleMenu(*)
{
	OutputDebug '`nThe menu was requested.`n'
	DisplayMenu(false)
	return
}

;^+RButton::
DisplayExtendedMenu(*)
{
	OutputDebug '`nThe extended menu was requested.`n'
	DisplayMenu(true)
	return
}


; MARK: Settings from .ini
;{-----------------------------------------------

; Parsing settings.ini
ini := IniConf.parse(A_ScriptDir . "\settings.ini")
; Ini object is structured: ini.section.property
OutputDebug "`nRetrived settings from .ini:`n"
For property, value in ini.settings.OwnProps()
	OutputDebug property "=" value "`n"

; Example for Setting values to ini:
;IniWrite "value_example", A_ScriptDir . "\settings.ini", "settings", "enable_item_example"


; MARK: Translation
;{-----------------------------------------------
; If translation language is set in settings, it will look for lang_XX.ini
; If lang_en.ini wanted in settings, it will be created.

; Default lang_en translation:
lang_en := "
(
	;https://en.wikipedia.org/wiki/INI_file
	;Save With UTF-8 with BOM
	[basics]
	tray_tip = "Press [] to show the menu"
	[commands]
	edit_links = "Edit QuickLinks Menu"
	reload_links = "Reload QuickLinks Menu"
	[features]
	current_windows = "Current Windows"
	recent_files = "Recent Files"
	recent_folders = "Recent Folders"
)"

; Parse lang_en translation:
Filename := A_ScriptDir "\lang_en.ini"
if (!FileExist(Filename)) {
	; If wanted, create lang_en.ini file and parse it.
	if (ini.translating.write_lang_en_ini)
	{
		FileAppend(lang_en, FileName, "`n UTF-8")
		lang := IniConf.parse(Filename)
	}
}
if (!HasProp(ini.translating, "translation_lang") AND FileExist(Filename))
{
	; If lang_en.ini exist parse it.
	lang := IniConf.parse(Filename)
}
; Else parse lang_en directly from script
else {
	lang := IniConf.parse(lang_en)
}

; Parse optional translation:
if (HasProp(ini.translating, "translation_lang"))
{
	Filename := A_ScriptDir "\lang_" ini.translating.translation_lang ".ini"
	if (FileExist(Filename))
	{
		translation := IniConf.parse(Filename)
		; Use translated lines:
		For section in translation.OwnProps()
			For property, value in translation.%section%.OwnProps()
				lang.%section%.%property% := value
	}
	else {
		MsgBox("Your set translation file was not found!")
	}
}


; Global Variables
g_window_id := 0
g_class := ""
g_title := ""
g_process := ""

; Startup
oMenu := QuickLinksMenu(QL_Menu := "Links")
;oMenu := QuickLinksMenu(QL_Menu := ".\tests\basic") ; Path to test files.

TrayTip(StrReplace(lang.basics.tray_tip, "[]", SimpleHotkey[1]))


; TODO: #13 Make QuickLinksMenu more independent
; Class with Menu
Class QuickLinksMenu { ; Just run it one time at the start.

	__New(QL_Menu) {
		this.oMenu := {}
		this.CreateMenu(QL_Menu)
	}

	; CREATE MENU - prepare base of menus
	CreateMenu(QL_Menu) {

		; If it's not path, place it relative to the script.
		If !InStr(QL_Menu, "\") {
			this.QL_Link_Dir := A_ScriptDir "\" QL_Menu
		}
		else {
			this.QL_Link_Dir := ConvertToAbsolutePath(QL_Menu, A_ScriptDir)
		}

		SplitPath(this.QL_Link_Dir, &QL_MenuName)

		this.QL_MenuName := QL_MenuName

		If !FileExist(this.QL_Link_Dir) {
			DirCreate(this.QL_Link_Dir)
		}

		; ROOT MENU
		this.oMenu.%this.QL_MenuName% := Menu()

		; OPTIONAL FEATURES
		; Current Windows
		if (ini.settings.enable_current_windows)
		{
			this.oMenu.CurrentWindows := Menu()
			this.oMenu.%this.QL_MenuName%.Add(lang.features.current_windows, this.oMenu.CurrentWindows) ; Add submenu
			this.oMenu.%this.QL_MenuName%.SetIcon(lang.features.current_windows, A_Windir "\System32\SHELL32.dll", -46) ; optional icon for Edit Links ;
		}

		; Recent Folders
		if (ini.settings.enable_recent_folders)
		{
			this.oMenu.RecentFolders := Menu()
			this.oMenu.%this.QL_MenuName%.Add(lang.features.recent_folders, this.oMenu.RecentFolders) ; Add submenu
			this.oMenu.%this.QL_MenuName%.SetIcon(lang.features.recent_folders, A_Windir "\System32\SHELL32.dll", -37219) ; optional icon for Edit Links ;
		}

		; Recent Files
		if (ini.settings.enable_recent_files)
		{
			this.oMenu.RecentFiles := Menu()
			this.oMenu.%this.QL_MenuName%.Add(lang.features.recent_files, this.oMenu.RecentFiles) ; Add submenu
			this.oMenu.%this.QL_MenuName%.SetIcon(lang.features.recent_files, A_Windir "\System32\SHELL32.dll", -327) ; optional icon for Edit Links ;
		}

		if (ini.settings.enable_current_windows) ; OR ANOTHER FEATURE
		{
			this.oMenu.%this.QL_MenuName%.Add() ; Divider
		}

		; Loop through Folders & CREATE MENUS
		OutputDebug "`nCreating Menus:`n"
		Loop Files, this.QL_Link_Dir "\*", "DR" ; Get Folders & Recurse
		{
			;Skip any file that is H, or S (System).
			if InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S")
				continue

			OutputDebug "Adding Folder: " A_LoopFileName "`n"

			; PARSE FOLDER PATH INTO VARIABLES
			; E.g. "C:\QL\Links\directory0_example\directory1_example

			; Path to Folder from A_Loopfilefullpath
			; E.g. "C:\QL\Links\directory0_example\directory1_example"
			FolderPath := A_Loopfilefullpath

			; Path to Parent Folder from A_Loopfilefullpath
			; E.g. "C:\QL\Links\directory0_example"
			SplitPath(A_LoopFileFullPath, , &ParentFolderPath)

			; Folder Name from A_Loopfilefullpath
			; E.g. "directory1_example"
			SplitPath(A_Loopfilefullpath, &FolderName)

			; Path to Folder -> To (Child) Menu Name
			; E.g. "Links$directory0_example$directory1_example"
			Folder1Menu := QL_MenuName StrReplace(StrReplace(FolderPath, this.QL_Link_Dir), "\", "$")

			; Path to Parent Folder -> To Parent Menu Name
			; E.g. "Links$directory0_example"
			Folder0Menu := QL_MenuName StrReplace(StrReplace(ParentFolderPath, this.QL_Link_Dir), "\", "$")

			; CHILD MENU
			if !this.oMenu.HasOwnProp(Folder1Menu) {
				this.oMenu.%Folder1Menu% := Menu()
			}

			; PARENT MENU
			if !this.oMenu.HasOwnProp(Folder0Menu) {
				this.oMenu.%Folder0Menu% := Menu()
			}

			; Add Child Menu to Parent
			this.oMenu.%Folder0Menu%.Add(FolderName, this.oMenu.%Folder1Menu%) ; Create submenu

			; Set Icon to Child Menu
			if (ini.settings.enable_menu_folder_icon)
			{
				; set folder icon from Desktop.ini
				this.Icon_Folder_Add(this.oMenu.%Folder0Menu%, FolderName, FolderPath)
			}
			else
			{
				; set default folder icon
				this.oMenu.%Folder0Menu%.SetIcon(FolderName, A_Windir "\System32\SHELL32.dll", "5")
			}
		}

		; Loop through Files & ADD MENU ITEMS
		OutputDebug "`nAdding menu items:`n"
		Loop Files, this.QL_Link_Dir "\*.*", "FR" ; Get Files & Recurse
		{
			;Skip any file that is H, R, or S (System).
			if InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "R") or InStr(A_LoopFileAttrib, "S")
				continue

			; Skip any file that matches:
			if (A_LoopFileName = "Desktop.ini" or A_LoopFileExt = "ico")
				continue

			; PARSE FILE PATH INTO VARIABLES
			; E.g. "C:\QL\Links\directory0_example\directory1_example\link_example.lnk"

			; Path to folder -> To Child Menu Name
			; E.g. "Links$directory0_example$directory1_example"
			Folder1Menu := QL_MenuName StrReplace(StrReplace(RegExReplace(A_Loopfilefullpath, "(.*\\[^\\]*\\[^\\]*)\\([^\\]*)", "$1"), this.QL_Link_Dir), "\", "$")

			Linkname := StrReplace(A_LoopFileName, ".lnk")

			this.Command_Set(this.oMenu.%Folder1Menu%, Linkname, A_LoopFilePath)
			this.Icon_Add(this.oMenu.%Folder1Menu%, Linkname, A_LoopFilePath) ; icon

		}

		; End of menu preparation
		return this.oMenu
	}

	; Show Menu
	Show(extended) {

		;Refresh DarkMode state when menu Called.
		LightTheme := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
		if !LightTheme {
			this.SetDarkMode()
		}

		; Recreate Current Windows Submenu
		if (ini.settings.enable_current_windows)
		{
			this.oMenu.CurrentWindows.Delete
			this.CurrentWindows()
		}

		; Recreate Recent File Submenu
		if (ini.settings.enable_recent_files OR ini.settings.enable_recent_folders)
		{
			if (ini.settings.enable_recent_folders)
			{
				this.oMenu.RecentFolders.Delete
			}
			if (ini.settings.enable_recent_files)
			{
				this.oMenu.RecentFiles.Delete
			}
			this.RecentFiles()
		}

		; Show Extended Menu
		if (extended) {
			; EXTENDED COMMANDS SECTION OF THE MENU

			; Add separator
			this.oMenu.%this.QL_MenuName%.Add() ; Adding a line separating items from Commands.

			; Add Extended commands:
			; Edit Links - comand for opening folder with Ink's.
			this.Command_Set(this.oMenu.%this.QL_MenuName%, lang.commands.edit_links, this.QL_Link_Dir)
			; this.oMenu.%this.QL_MenuName%.SetIcon(lang.commands.edit_links, A_Windir "\System32\SHELL32.dll", "5") ; optional icon for Edit Links ;

			; Reload Links - command for recreating menu. Rescan Ink's, icons and folders.
			if (ini.settings.enable_command_reload_QL)
			{
				this.oMenu.%this.QL_MenuName%.Add(lang.commands.reload_links, this.Recreate.Bind(this))
			}

			; Show
			this.oMenu.%this.QL_MenuName%.Show()

			; & Cleanup:
			; Delete Extended Items
			this.oMenu.%this.QL_MenuName%.Delete(lang.commands.edit_links)
			this.oMenu.%this.QL_MenuName%.Delete(lang.commands.reload_links)

			; Retrieve the number of items in a menu. And delete last extended item - separator.
			item_count := DllCall("GetMenuItemCount", "ptr", this.oMenu.%this.QL_MenuName%.Handle)
			this.oMenu.%this.QL_MenuName%.Delete(item_count "&")
		}

		; Show Simple Menu
		else {
			this.oMenu.%this.QL_MenuName%.Show()
		}

	}

	CurrentWindows() {
		ExplArray := Explorer_Array()
		if (ExplArray = 0)
		{
			return
		}
		; Potřebuji ten seznam seřadit od nejaktivnějšího po nejstarší. Tohle je ještě otázkou.
		; Potřebuji vypsat x položek.
		; Potřebuji aby položky měli omezený počet znaku.

		ExplArray := ReverseArray(ExplArray)
		for index, window in ExplArray
		{
			;ID := window[1]
			path := window[2]
			this.Command_Set(this.oMenu.CurrentWindows, path, path)
		}
	}

	; MARK: Recent Files/Folders
	RecentFiles()
	{
		RecentFolderLimit := ini.settings.recent_folders_limit
		RecentFileLimit := ini.settings.recent_files_limit

		RecentLimit := RecentFolderLimit + RecentFileLimit

		RecentFilesFolder := "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Recent"

		FileList := ""
		Loop Files, RecentFilesFolder "\*.*", "F" ; Include Files
			FileList .= A_LoopFileTimeModified "`t" A_LoopFilePath "`n"
		FileList := Sort(FileList, "R")  ; Sort by date - reverse.

		iterationCount := 0
		iterationFolderCount := 0
		iterationFileCount := 0

		Loop Parse, FileList, "`n"
		{
			if (iterationCount >= RecentLimit)
			{
				break
			}

			if A_LoopField = "" ; Omit the last linefeed (blank item) at the end of the list.
				continue

			FileItem := StrSplit(A_LoopField, A_Tab) ; Split into parts at the tab char

			FileGetShortcut(FileItem[2], &LinkTargetPath)
			if (LinkTargetPath = "") ; For Internet targets
			{
				continue
			}
			if (RegExMatch(LinkTargetPath, "^(.*[\\/])[^.\\/.]*$"))
			{
				; Recent folders
				if (iterationFolderCount >= RecentFolderLimit)
				{
					continue
				}
				if (ini.settings.enable_recent_folders) {
					iterationFolderCount++
					SplitPath(LinkTargetPath, &OutFileName)
					this.Command_Set(this.oMenu.RecentFolders, OutFileName, LinkTargetPath)
					if (ini.settings.enable_recent_folder_icons)
					{
						this.Icon_Add(this.oMenu.RecentFolders, OutFileName, LinkTargetPath) ; icon for extension
					}
					else {
						this.oMenu.RecentFolders.SetIcon(OutFileName, A_Windir "\System32\SHELL32.dll", 5) ; default icon for Folders
					}

				}
				else {
					iterationFolderCount := RecentFolderLimit
					continue
				}
			}
			else {
				; Recent files
				if (iterationFileCount >= RecentFileLimit)
				{
					continue
				}
				if (ini.settings.enable_recent_files) {
					iterationFileCount++
					SplitPath(LinkTargetPath, &OutFileName)
					this.Command_Set(this.oMenu.RecentFiles, OutFileName, LinkTargetPath)
					if (ini.settings.enable_recent_file_icons)
					{
						this.Icon_Add(this.oMenu.RecentFiles, OutFileName, LinkTargetPath) ; icon for extension
					}
					else {
						this.oMenu.RecentFiles.SetIcon(OutFileName, A_Windir "\System32\SHELL32.dll", 0) ; default icon for Files
					}
				}
				else {
					iterationFileCount := RecentFileLimit
					continue
				}
			}
			iterationCount := iterationFolderCount + iterationFileCount
		}
	}

	; Re-create the menu and display it
	Recreate(*) {
		OutputDebug '`nRecreate called for menu: "' QL_Menu '".`n'
		this.oMenu := {}
		this.CreateMenu(QL_Menu)
		this.oMenu.%this.QL_MenuName%.Show()
		return
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

		/* IconNumber (IconIndex)
		Type: Integer
		If omitted, it defaults to 1 (the first icon group). Otherwise, specify the number of the icon group to be used in the file. For example, MyMenu.SetIcon(MenuItemName, "Shell32.dll", 2) would use the default icon from the second icon group. If negative, its absolute value is assumed to be the resource ID of an icon within an executable file.
		*/

		;if Defined in .Ink
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

		;if Target Unavailable - Important for temporarily Unavalilable link targets.
		CheckTargetExist := FileExist(File)
		if not CheckTargetExist {
			; If Is Path to Folder
			if (RegExMatch(File, "^(.*[\\/])[^.\\/.]*$"))
			{
				menuitem.SetIcon(submenu, A_Windir "\system32\shell32.dll", -146)
				return
			}
			else
			{
				menuitem.SetIcon(submenu, A_Windir "\system32\shell32.dll", -145)
				return
			}
		}

		;if Folder
		if InStr(CheckTargetExist, "D") {
			; Add icon for folders
			this.Icon_Folder_Add(menuitem, submenu, File)
			return
		}

		;else -> By Extension
		SplitPath File, , , &Extension

		; Extension Exe
		If (Extension = "exe") {
			try {
				menuitem.SetIcon(submenu, file, "1")
			}
			return
		}

		; Other Extensions
		switch (Extension) {
			; Manualy Set Icons for Selected Extensions
			case "url":
				menuitem.SetIcon(submenu, A_Windir "\system32\Imageres.dll", -1010)
			case "jpg", "png", "gif", "bmp":
				menuitem.SetIcon(submenu, A_Windir "\system32\shell32.dll", -236)
			case "txt":
				menuitem.SetIcon(submenu, A_Windir "\System32\shell32.dll", -235)
			default:
				this.GetExtIcon(Extension, &IconFile, &IconIndex)
				menuitem.SetIcon(submenu, IconFile, IconIndex)
				return
		}
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
			menuitem.SetIcon(submenu, A_Windir "\System32\SHELL32.dll", "5")
		}
	}

	; Function to get icons from registry
	GetExtIcon(Ext, &IconFile, &IconIndex) {
		; Try pulling the ico from the registry. I'm in over my head. Is there no official dll library?
		; https://superuser.com/questions/436939/where-is-the-default-program-associations-stored-in-the-registry
		try {
			try { ; Associations from Windows Explorer
				ProgId1 := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\." Ext "\UserChoice", "ProgId")
			}
			try { ; Base Associations From Root
				ProgId2 := RegRead("HKEY_CLASSES_ROOT\." Ext)
			}

			; Icons from ProgID
			try {
				DefaultIcon := RegRead("HKEY_CLASSES_ROOT\" ProgId1 "\DefaultIcon")
				If (RegExMatch(DefaultIcon, "^@")) ; REVIEW: If you now how to handle URI (Uniform Resource Identifier) and png images sets feel free to fill in.
				{
					throw
				}
			}
			catch {
				try {
					DefaultIcon := RegRead("HKEY_CLASSES_ROOT\" ProgId2 "\DefaultIcon")
					If (RegExMatch(DefaultIcon, "^@")) ; REVIEW: If you now how to handle URI (Uniform Resource Identifier) and png images sets feel free to fill in.
					{
						throw
					}
				}
				catch
				{
					throw ; Throw to FallBackIcon
				}
			}
			DefaultIcon := StrReplace(DefaultIcon, '"')

			; Skip any file that matches:
			if (DefaultIcon = "%1") {
				throw
			}
			I := StrSplit(DefaultIcon, ",")
			IconFile := I[1]
			IconIndex := this.IndexOfIconResource(ExpandEnvironmentStrings(&IconFile), RegExReplace(I[2], "[^\d]+"))
			return
		}

		; FallBackIcon
		; If you can't find it in all the mess and complexity. Then use:
		catch {
			; Set Fallback Icon TODO: A taky Catch když Defauilt Icon selže.
			IconFile := A_Windir "\System32\SHELL32.dll"
			IconIndex := -16769
			OutputDebug "Error. The path for the '" Ext "' icon was not retrieved from the registry. It will by used default.`n"
			return
		}
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
DisplayMenu(extended, *)
{
	; These first few variables are set here and used by OpenFavorite:
	try global g_window_id := WinGetID("A")
	try global g_class := WinGetClass(g_window_id)
	try global g_title := WinGetTitle(g_window_id)
	try global g_process := WinGetProcessName(g_window_id)

	; Set exceptions or set exclusivity
	if ini.settings.always_show_menu = "false" ; The menu should be shown only if application
	{
		;; Exceptions
		;; If Application Is
		/*
				switch
				{
					case (g_class ~= "example_unset_value1|example_unset_value2"):
						OutputDebug 'The menu will not be displayed because the window class matches the set exception `n'
						return
					case (g_process ~= "Code.exe"): return
						OutputDebug "The menu will not be displayed because the window process matches the set exception `n"
						return
					case (g_title ~= "example_unset_value1|example_unset_value2"):
						OutputDebug "The menu will not be displayed because the window title matches the set exception `n"
						return
				}
		*/
		; Since it's of this window type, don't display menu.


		;; Or Exclusivity
		;; If Application Is Not
		/*
				if !(g_class ~= "#32770|ExploreWClass|CabinetWClass|ConsoleWindowClass|CASCADIA_HOSTING_WINDOW_CLASS")
					return ; Since it's some other window type, don't display menu.
		*/
		; Since it's some other window type, don't display menu.

	}
	; Otherwise, the menu should be presented for this type of window:
	oMenu.Show(extended)
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
			ExpandEnvironmentStrings(&path)
			try GetActiveExplorerTab().Navigate(path)
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

	; Open File/Folder/Link
	if (ini.settings.enable_find_explorer)
	{
		; Try to find an existing Windows Explorer window with the same path before opening a new one.
		Run_explorer(path)
	}
	else
	{
		; Open .Ink file. Sometimes opens existing window.
		Run LinkPath
		;Run "explorer " path  ; Might work on more systems without double quotes.
	}
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
		catch {
			IconFile := A_Windir "\System32\SHELL32.dll"
			IconIndex := "5"
		}
	}
}

ConvertToAbsolutePath(relativePath, basePath) {

	ExpandEnvironmentStrings(&relativePath)

	; Check if the path starts with a drive letter and a colon or backslash, which indicates an absolute path
	if (RegExMatch(relativePath, "^\w:\\") || SubStr(relativePath, 1, 2) == "\\")
		return relativePath ; Path is already absolute
	else
		return PathCombine(basePath, relativePath)
}


Run_explorer(path) {
	OutputDebug "Called Function Run_Explorer with path: " path "`n"
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
				OutputDebug "Unique ID of Window/Control From Explorer List: '" ID "'`n"
				if IsInteger(ID)
					ID := Integer(ID)
				else {
					throw Error("ID is not Integer")
				}
				WinActivate "ahk_id" ID


				; Try to find and Activate Tab
				if (ini.settings.enable_find_explorer_tab)
				{
					; If Windows 11 and later
					if VerCompare(A_OSVersion, "10.0.22000") >= 0
						;https://www.autohotkey.com/boards/viewtopic.php?t=109907
					{
						loop 25 { ; Set Hard Limit 25 times switch tab. For Safety. If someone requests it, we can add it to the settings.
							explorer_tab_path := GetActiveExplorerTab(ID).Document.Folder.Self.Path
							OutputDebug "Active Tab Path: " explorer_tab_path "`n"
							If (explorer_tab_path = path)
							{
								OutputDebug "Successfully Found Tab: " explorer_tab_path "`n"
								break
							}

							If not (WinActive(ID)) {
								; Fallback
								OutputDebug "Window is no longer active! Or something's gone bad. Fallback to Open As New.`n"
								Run(path)
							}

							; Switch to Next Tab
							Send "^{Tab}"
							Sleep (500)
						}
					}
				}

				; If Not Windows 11 and later
				break
			}
		}
	}
	else
		Run(path)
}

Explorer_Array() { ; TODO: Replace Explorer_List with this.
	; Get ID + fullpath of all opened explorer windows:
	If WinExist("ahk_class CabinetWClass") ; explorer
	{
		ExplArray := Array()
		for window in ComObject("Shell.Application").Windows
		{
			try explorer_path := window.Document.Folder.Self.Path
			;OutputDebug explorer_path '`n'
			If (explorer_path = "")
				continue
			ID := window.HWND
			ExplArray.Push([ID, explorer_path])
		}
		return ExplArray
	}
	else {
		return 0
	}
}

explorer_list() {
	; Get ID + fullpath of all opened explorer windows:
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
}
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


PathCombine(abs, rel)
; http://stackoverflow.com/questions/29783202/combine-absolute-path-with-a-relative-path-with-ahk/
; The PathCombine function returns combination of absolute path with a relative path.
{
	dest := Buffer(2 * 260) ; MAX_PATH
	DllCall("Shlwapi.dll\PathCombine", "Ptr", dest, "str", abs, "str", rel)
	Return StrGet(dest)
}


GetFullPathName(path) {
	;The GetFullPathName function returns the full path to the file based on the specified relative path. The root against which the relative path is interpreted depends on the current working directory in which the script or program is running.
	cc := DllCall("GetFullPathNameW", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
	buf := Buffer(cc * 2)
	DllCall("GetFullPathNameW", "str", path, "uint", cc, "ptr", buf, "ptr", 0, "uint")
	return StrGet(buf)
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


ReverseArray(arr) {
	;https://www.autohotkey.com/boards/viewtopic.php?p=297353#p297353
	o := []
	brr := arr.clone()
	for i, k in arr.clone() {
		o.InsertAt(i, brr.pop())
	}
	return o
}