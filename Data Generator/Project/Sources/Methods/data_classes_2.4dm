//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

var $id:=This:C1470.task
var $folder : 4D:C1709.Folder
$folder:=Folder:C1567(fk data folder:K87:12).folder("examples").folder($id)
$folder.create()

var $result : Object
$result:=Try(JSON Parse:C1218(This:C1470.ChatResult; Is object:K8:27))

var $name:=This:C1470.name

If ($result#Null:C1517)
	$folder.file($name+".jsonl").setText(JSON Stringify:C1217($result; *))
End if 

/*
This request would exceed your organization's rate limit of 10,000 input tokens per minute 
*/

//DELAY PROCESS(Current process; 60*30)
//EXECUTE METHOD(This.api)
data_classes_1