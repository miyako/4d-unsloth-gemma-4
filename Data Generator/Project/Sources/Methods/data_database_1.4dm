//%attributes = {"invisible":true}
#DECLARE($params : Object)

/*
this method uses AI to generate good and bad chatml messages about commands
*/

var $id:="database"

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684; Current method name:C684; {})
	
Else 
	
	var $agent : cs:C1710._AgentRemote
	//$agent:=cs._AgentRemote.new("xAI"; "grok-4-1-fast-reasoning")
	//$agent:=cs._AgentRemote.new("Claude"; "claude-opus-4-7")
	$agent:=cs:C1710._AgentRemote.new("Azure_xAI"; "grok-4-20-reasoning")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/"+$id+"/")
	
	var $systemPrompt; $userPrompt : Text
	$systemPrompt:=$folder.file("system.txt").getText()
	$userPrompt:=$folder.file("user.txt").getText()
	
	$folder:=Folder:C1567(fk data folder:K87:12).folder("examples/"+$id)
	var $files : Collection
	$files:=$folder.files(fk recursive:K87:7).query("extension == :1"; ".jsonl")
	var $file : 4D:C1709.File
	var $examples : Text
	For each ($file; $files)
		var $json : Object
		$json:=JSON Parse:C1218($file.getText(); Is object:K8:27)
		var $message : Object
		For each ($message; $json.messages.query("role == :1"; "user"))
			If ($examples#"")
				$userPrompt+="\n"
			End if 
			$examples+="- "+$message.content
		End for each 
	End for each 
	
	If ($examples#"")
		$userPrompt+="\nDo not include any of the following or similar cases.\n"
		$userPrompt+=$examples
	End if 
	
	var $messages:=[]
	
	$messages.push({role: "system"; content: $systemPrompt})
	$messages.push({role: "user"; content: $userPrompt})
	
	$agent.startConversation($messages; Formula:C1597(data_database_2))
	
End if 