//%attributes = {"invisible":true}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

var $folder : 4D:C1709.Folder
$folder:=Folder:C1567(fk data folder:K87:12).folder("examples/database")
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
		While ($folder.file($fileName+".jsonl").exists)
			$i+=1
			$fileName:=String:C10($i; "000000")
		End while 
		$folder.file($fileName+".jsonl").setText(JSON Stringify:C1217($result; *))
		var $message : Object
		$message:=$result.messages.query("role == :1"; "assistant").first()
		If ($message#Null:C1517)
			$folder.file($fileName+".4DCatalog").setText($message.content)
		End if 
		$message:=$result.messages.query("role == :1"; "user").first()
		If ($message#Null:C1517)
			$folder.file($fileName+".txt").setText($message.content)
		End if 
		
	End for each 
End if 

/*
This request would exceed your organization's rate limit of 10,000 input tokens per minute 
*/

DELAY PROCESS:C323(Current process:C322; 60*60*1)

data_database_1