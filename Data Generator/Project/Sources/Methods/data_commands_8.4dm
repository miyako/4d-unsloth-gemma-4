//%attributes = {"invisible":true}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

/*
this method uses AI to generate text
*/

var $id:="commands_grok_e"
//$id:="themes"

var $target_folder : 4D:C1709.Folder
$target_folder:=Folder:C1567(fk data folder:K87:12).folder("examples").folder($id)
$target_folder.create()

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684; Current method name:C684; {})
	
Else 
	
	If (This:C1470=Null:C1517)
		
		var $agent : cs:C1710._AgentRemoteText
		//$agent:=cs._AgentRemoteText.new("Cohere"; "command-a-03-2025")
		//$agent:=cs._AgentRemoteText.new("Azure"; "Mistral-Large-3")
		//$agent:=cs._AgentRemoteText.new("Azure_xAI"; "grok-4-1-fast-reasoning")
		//$agent:=cs._AgentRemoteText.new("Azure_xAI"; "Kimi-K2.6-1")
		$agent:=cs:C1710._AgentRemoteText.new("Azure_xAI"; "grok-4-20-reasoning")
		
		var $folder : 4D:C1709.Folder
		$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/"+$id+"/")
		
		var $systemPrompt; $userPrompt : Text
		$systemPrompt:=$folder.file("system.txt").getText()
		
		var $raw : 4D:C1709.Folder
		$raw:=$folder.folder("raw")
		
		var $file : 4D:C1709.File
		$file:=$raw.files(fk ignore invisible:K87:22).query("extension == :1"; ".txt").first()
		
		If ($file=Null:C1517)
			return 
		End if 
		
		If ($target_folder.file($file.name+".jsonl").exists)
			var $done : 4D:C1709.Folder
			$done:=$folder.folder("done")
			$done.create()
			$file.moveTo($done)
			$file:=$raw.files(fk ignore invisible:K87:22).query("extension == :1"; ".txt").first()
			If ($file=Null:C1517)
				return 
			End if 
		End if 
		
		$userPrompt:=$file.getText()
		
		var $messages:=[]
		
		$messages.push({role: "system"; content: $systemPrompt})
		$messages.push({role: "user"; content: $userPrompt})
		
		$agent.task:=$id
		$agent.name:=$file.name
		$agent.api:=Current method name:C684
		$agent.startConversation($messages; Formula from string:C1601(Current method name:C684))
		
	Else 
		
		$id:=This:C1470.task
		$folder:=Folder:C1567(fk data folder:K87:12).folder("examples").folder($id)
		$folder.create()
		
		var $result : Object
		$result:=Try(JSON Parse:C1218(This:C1470.ChatResult; Is object:K8:27))
		
		var $name : Text
		$name:=This:C1470.name
		
		If ($result#Null:C1517)
			$folder.file($name+".jsonl").setText(JSON Stringify:C1217($result; *))
		End if 
		
		//DELAY PROCESS(Current process; 60*30)
		
		EXECUTE METHOD:C1007(Current method name:C684)
		
	End if 
	
End if 