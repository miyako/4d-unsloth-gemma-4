//%attributes = {"invisible":true}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

var $folder : 4D:C1709.Folder
$folder:=Folder:C1567(fk data folder:K87:12).folder("examples")
$folder.create()

var $i:=1
var $folderName; $fileName : Text
$folderName:=String:C10($i; "000000")

While ($folder.folder($folderName).exists)
	$i+=1
	$folderName:=String:C10($i; "000000")
End while 

$folder:=$folder.folder($folderName)
$folder.create()

var $results : Collection
$results:=Try(JSON Parse:C1218(This:C1470.ChatResult; Is collection:K8:32))

If ($results=Null:C1517)
	return 
End if 

var $result : Object
$i:=1
For each ($result; $results)
	$fileName:=String:C10($i; "000000")
	$i+=1
	var $instruction; $output_python; $output_4d : Text
	$instruction:=$result.instruction
	$output_python:=$result.output_python
	$output_4d:=$result.output_4d
	$folder.file($fileName+".py").setText($output_python)
	$folder.file($fileName+".4dm").setText($output_4d)
	$folder.file($fileName+".txt").setText($instruction)
End for each 