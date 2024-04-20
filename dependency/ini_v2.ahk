#Requires Autohotkey v2.0
; https://www.autohotkey.com/boards/viewtopic.php?p=458421#p458421

/*
	name ------ : ini.ahk
	description : Parse INI configuration text or dump an object as INI configuration text.
	author ---- : TopHatCat
    convert v2  : vysmaty (not fully tested at time)
	version --- : v2.0.0
	date ------ : 18-04-2024  [DD-MM-YYYY]
*/

; Example: ini := IniConf.parse(A_ScriptDir . "\ini_text.ini")

class IniConf
{
	static allow_read_file := true            ; PARSE()                Whether to allow reading a given file path or to only accept strings.
	static allow_multi_line_values := false   ; PARSE()                Whether to allow multi-line parsed values.
	static allow_bool_translation := true     ; PARSE()                Whether to allow boolean translation ("true" to true, "no" to false, etc).
	static allow_null_translation := true     ; PARSE()                Whether to allow translating "null" to null character.
	static allow_empty_translation := true    ; PARSE()                Whether to allow empty values to exist.
	static allow_escape_translation := false  ; PARSE()                Whether to allow translating backslash escapes. Saves on performance to have off.
	static allow_trailing_whitespace := true  ; PARSE()                Whether to allow trailing whitespace.
	static remove_quotation_marks := true     ; PARSE()                Whether to remove quotation marks.
	static comment_flag := "`;"               ; PARSE() & STRINGIFY()  Comment flag. By default, the comment character is a semi-colon (;).
	static null_character := Chr(0)           ; PARSE()                The NULL character to use. By default it's ASCII 0.
	static allow_dunder_comments := true      ; STRINGIFY()            Whether to allow comments when parsing in the form of "__comment__".
	static escape_values :=                   ; PARSE()                The custom escape values to translate. To add your own, push a new 2 value array.
		(Ltrim Join Comments
			[
				["\n", "`n"],                     ; Newline
				["\r", "`r"],                     ; Carriage return
				["\t", "`t"],                     ; (Horizonal) Tab
				["\a", "`a"],                     ; Alert (bell)
				["\v", "`v"],                     ; Vetical tab
				["\f", "`f"],                     ; Formfeed
				["\b", "`b"],                     ; Backspace
				["\0", IniConf.null_character],   ; Null character
				["\\", "\"],                      ; Normal backslash
				['\"', '"'],                      ; Quote
				["\`;", "`;"],                    ; Semi-colon
				["\#", "#"],                      ; Pound
				["\:", ":"],                      ; Colon
				["\=", "="]                       ; Equals
			]
		)

	/*
		@name parse
		@brief Parse an INI configuation string into a object.
		@param {string} str - The text to parse. If ALLOW_READ_FILE is true, this can be a file path.
		@return {object} The parsed object.
	*/
	static parse(str) {
		if (IniConf.allow_read_file)
		{
			if (FileExist(str))
			{
				str := Fileread(str)
			}
		}

		result := {}
		split_lines := StrSplit(str, "`n", "`r")
		last_section := ""
		skip_line := false

		for index, line in split_lines
		{
			if (skip_line)
			{
				skip_line := false
				continue
			}

			; Replace comments.
			line := RegExReplace(line, "im)((?:[\t ]+|)\Q" . IniConf.comment_flag . "\E.*)$")

			; Ignore blanks
			if (line == "")
			{
				continue
			}

			split_keyval := StrSplit(line, "=")

			; If it's a valid section, create a sub object to the result.
			if (RegExMatch(line, "i)\[([a-z_0-9]+)\]", &match_obj))
			{
				result.%match_obj[1]% := {}
				last_section := match_obj[1]
				continue
			}
			else if (split_keyval.Length > 0)
			{
				; If we've split more than needed, just combine the rest of the array.
				if (split_keyval.Length > 2)
				{
					Loop split_keyval.Length
					{
						split_keyval[2] .= split_keyval[A_Index + 2]
					}
				}

				; If it's not a valid key-value pair, throw a syntax error.
				if (split_keyval[1] == "")
				{
					throw ValueError(Format("[line {1}] SynatxError: Invalid key-value pair. " . "Maybe you used a colon instead of an equals sign?", index), -1, line)
				}

				; If the settings of the class allows for multi-line values and
				; if the current line has the "continuation" character, add the next line to this.
				if ((IniConf.allow_multi_line_values) && (line ~= "\s+?\\$"))
				{
					split_keyval[2] .= split_lines[index + 1]
					skip_line := true
				}
				else
				{
					; Remove whitespace from beggining of string
					split_keyval[2] := LTrim(split_keyval[2])

					; Optional remove trailing whitespace
					if (!IniConf.allow_trailing_whitespace) {
						split_keyval[2] := RTrim(split_keyval[2])
					}

					; Optional remove quotation marks
					if (IniConf.remove_quotation_marks)
					{
						; Remove quotation marks if begins with mark
						if (SubStr(split_keyval[2], 1, 1) == "`"")
						{
							split_keyval[2] := RTrim(split_keyval[2])
							split_keyval[2] := Trim(split_keyval[2], "`"")
						}
					}

					switch (split_keyval[2])
					{
						case "true", "yes":
							if (IniConf.allow_bool_translation)
							{
								split_keyval[2] := true
							}
						case "false", "no":
							if (IniConf.allow_bool_translation)
							{
								split_keyval[2] := false
							}
						case "null", "undefined":
							if (IniConf.allow_null_translation)
							{
								split_keyval[2] := IniConf.null_character
							}
						case "":
							{
								if (!IniConf.allow_empty_translation)
								{
									throw ValueError(Format("[line {1}] ValueError: Empty value. " . "Did you accidently delete the value?", index), -1, line)
								}
								split_keyval[2] := ""
							}
						default:
							{
								if (IniConf.allow_escape_translation)
								{
									for i, val in IniConf.escape_values
									{
										split_keyval[2] := StrReplace(split_keyval[2], val[1], val[2])
									}
								}
							}
					}

					result.%last_section%.%Trim(split_keyval[1])% := split_keyval[2]
				}
			}
		}
		return result
	}

	/*
		@name stringify
		@brief Dump an object into a standard
		@param {string} str - The text to parse.
		@return {object} The parsed object.
	*/
	stringify(obj, replacer := false, spacer := "`n")
	{
		; Since this function parses an object into a string,
		; and the object is already a string, we just return the value.
		if (!IsObject(obj))
		{
			return obj
		}

		result := ""

		for section_name, entry in obj
		{
			result .= Format("[{1}]`n", section_name)

			for key, value in entry
			{
				; Don't allow objects as results in the config file.
				if (IsObject(value))
				{
					throw ValueError("TypeError: Expected string, integer, boolean, or null value. " . "Make sure to only use a single nested object.", -1, value)
				}

				if (HasMethod(replacer))
				{
					value := replacer.Call(key, value)
				}

				if (IniConf.allow_dunder_comments)
				{
					if (key = "__comment__")
					{
						if (IsObject(value))
						{
							for index, comment in value
							{
								result .= Format("{1} {2}`n", IniConf.comment_flag, comment)
							}
						}
						else
						{
							result .= "# " . value . "`n"
						}
						continue
					}
				}

				if (IniConf.allow_escape_translation)
				{
					for i, val in IniConf.escape_values
					{
						value := StrReplace(value, val[2], val[1])
					}
				}

				result .= Format("{1} = {2}`n", key, value)
			}

			; When we move to a new object, we can add a "spacer" between sections.
			result .= spacer
		}
		return RTrim(result, "`n")
	}
}