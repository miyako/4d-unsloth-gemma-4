//%attributes = {"invisible":true}
/*

for LoRA fine tuning, we need a system prompt that sets the framework for writing valid code.
commands.json is a 324 KB document that describes all oop commands.

*/

var $object : cs:C1710.Row
$object:=cs:C1710.Row.new(21)

var $syntax : Object
$syntax:=JSON Parse:C1218(File:C1566("/RESOURCES/syntaxEN.json").getText())
OB REMOVE:C1226($syntax; "_command_")

var $descriptions : Collection
$descriptions:=[]

var $name : Text
var $class : Object
For each ($name; $syntax)
	$class:=$syntax[$name]
	If (OB Is defined:C1231($class; "_inheritedFrom_"))
		$classes:=[$class; $syntax[$class._inheritedFrom_]]
	Else 
		$classes:=[$class]
	End if 
	var $description : Object
	
	Case of 
		: ($name="4D")
			For each ($className; OB Keys:C1719($class))
				$description:={description: []}
				$description.name:=$className
				$functions:=$class[$className]  //constructiors
				If ($functions.length#0)
					$description.description:=[]
					For each ($function; $functions)
						$description.description.push($name+"."+$className+"."+$function)
						$info:=$class[$className][$function]
						If ($info.Summary#Null:C1517)
							$description.description.push($info.Summary)
						End if 
						If ($info.Syntax#Null:C1517)
							//$description.description.push("The "+$function+" function has the following syntax:")
							$description.description.push($info.Syntax)
						End if 
						If ($info.Params#Null:C1517)
							$description.description.push($info.Params.join(" "))
						End if 
					End for each 
					$descriptions.push($description)
				End if 
			End for each 
			continue
		Else 
			$description:={description: []}
			$description.name:=$name
			$description.description:=[]
			$description.description.push($name)
			For each ($class; $classes)
				$keys:=OB Keys:C1719($class)
				$functions:=$keys.filter(Formula:C1597($1.value="@()")).orderBy(ck ascending:K85:9)
				$properties:=$keys.filter(Formula:C1597($1.value#"@()")).orderBy(ck ascending:K85:9)
				If ($functions.length#0)
					//$description.description.push("The class has the following functions:")
					For each ($function; $functions)
						$description.description.push($name+"."+$function)
						$info:=$class[$function]
						If ($info.Summary#Null:C1517)
							$description.description.push($info.Summary)
						End if 
						If ($info.Syntax#Null:C1517)
							//$description.description.push("The "+$function+" function has the following syntax:")
							$description.description.push($info.Syntax)
						End if 
						If ($info.Params#Null:C1517)
							$description.description.push($info.Params.join(" "))
						End if 
					End for each 
				End if 
				If ($properties.length#0)
					//$description.description.push("The class has the following properties:")
					For each ($property; $properties)
						If ($property="_inheritedFrom_")
							continue
						End if 
						$description.description.push($name+"."+$property)
						$info:=$class[$property]
						If (Value type:C1509($info)=Is object:K8:27)
							$description.description.push($info.Summary)
						End if 
					End for each 
				End if 
			End for each 
	End case 
	$descriptions.push($description)
End for each 

File:C1566("/RESOURCES/commands_orda.json").setText(JSON Stringify:C1217($descriptions; *))