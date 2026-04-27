//%attributes = {"invisible":true}
/*

for LoRA fine tuning, we need a system prompt that sets the framework for writing valid code.
commands.json is a 489 KB document that describes all classic commands.

*/

var $object : cs:C1710.Row
$object:=cs:C1710.Row.new(21)

var $syntax; $command : Object
$syntax:=JSON Parse:C1218(File:C1566("/RESOURCES/syntaxEN.json").getText())._command_

var $i; $info : Integer
var $theme; $name : Text

var $descriptions : Object
$descriptions:={themes: {}; commands: []}

For ($i; 1; 2000)
	var $description : Object
	$description:={description: []}
	$name:=Command name:C538($i; $info; $theme)
	$command:=$syntax[$name]
	$description.description.push($name)
	If ($command=Null:C1517)
		Case of 
			: ($name="")
				continue
			: ($name="_o_@")
				$description.description.push("**"+$name+"** is an obsolete command that not longer exists in 4D.")
			: ($name="_@")
				continue
			Else 
				$description.description.push("**"+$name+"** is a command that should no longer be used in 4D.")
		End case 
	Else 
		$description.description.push($command.Summary)
		$description.description.push("The command has the following syntax;")
		$description.description.push($command.Syntax)
	End if 
	
	//$description.name:=$name
	//$description.id:=Lowercase(Replace string($name; " "; "-"))
	
	If ($info ?? 0)
		//$description.push("The command is thread safe.")
	Else 
		$description.description.push("The command not thread safe.")
	End if 
	
	If ($info ?? 1)
		$description.description.push("The command is deprecated.")
	Else 
		//$description.push("The command is not deprecated.")
	End if 
	$description.description:=$description.description.join("\n")
	$descriptions.commands.push($description)
	If ($descriptions.themes[$theme]=Null:C1517)
		$descriptions.themes[$theme]:=[]
	End if 
	$descriptions.themes[$theme].push($description)
End for 

File:C1566("/RESOURCES/commands_by_theme.json").setText(JSON Stringify:C1217($descriptions; *))
