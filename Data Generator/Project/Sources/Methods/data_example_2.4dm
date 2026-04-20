//%attributes = {"invisible":true}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

var $folder : 4D:C1709.Folder
$folder:=Folder:C1567(fk data folder:K87:12).folder("examples/snippets")
$folder.create()

var $result : Object
$result:=Try(JSON Parse:C1218(This:C1470.ChatResult; Is object:K8:27))

var $results : Collection
If ($result=Null:C1517)
	$results:=Try(JSON Parse:C1218(This:C1470.ChatResult; Is collection:K8:32))
Else 
	$results:=[$result]
End if 

If ($results#Null:C1517)
	var $i:=1
	For each ($result; $results)
		var $fileName : Text
		$fileName:=String:C10($i; "000000")
		While ($folder.file($fileName+".txt").exists)
			$i+=1
			$fileName:=String:C10($i; "000000")
		End while 
		var $instruction; $output_py; $output_js; $output_4d : Text
		$instruction:=$result.instruction
		$output_py:=$result.output_py
		$output_js:=$result.output_js
		$output_4d:=$result.output_4d
		$folder.file($fileName+".py").setText($output_py)
		$folder.file($fileName+".js").setText($output_js)
		$folder.file($fileName+".4dm").setText($output_4d)
		$folder.file($fileName+".txt").setText($instruction)
	End for each 
End if 

/*
This request would exceed your organization's rate limit of 10,000 input tokens per minute 
This request would exceed your organization's rate limit of 4,000 output tokens per minute
*/

DELAY PROCESS:C323(Current process:C322; 60*60*1)

data_example_1