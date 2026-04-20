//%attributes = {"invisible":true}
#DECLARE($prompt : Collection)

/*
this method uses AI to generate good and bad chatml messages about commands
*/

var $id:="critique"

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684; Current method name:C684; [])
	
Else 
	
	var $agent : cs:C1710._AgentRemoteCollection
	//$agent:=cs._AgentRemote.new("Claude"; "claude-haiku-4-5")
	//$agent:=cs._AgentRemote.new("xAI"; "grok-4.20-0309-reasoning")
	$agent:=cs:C1710._AgentRemoteCollection.new("Azure_xAI"; "grok-4-20-reasoning")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/"+$id+"/")
	
	var $systemPrompt; $userPrompt; $trainingIdentity; $assistingIdentity : Text
	$systemPrompt:=Folder:C1567(fk data folder:K87:12).folder("prompts/coding").file("system.txt").getText()
	$trainingIdentity:=Folder:C1567(fk data folder:K87:12).folder("prompts/coding").file("identity-for-training.txt").getText()
	$assistingIdentity:=Folder:C1567(fk data folder:K87:12).folder("prompts/coding").file("identity-for-assisting.txt").getText()
	
	If ($prompt.length=0)
		$userPrompt:=$folder.file("user.txt").getText()
		//$folder:=Folder(fk data folder).folder("examples/"+$id)
		//var $files : Collection
		//$files:=$folder.files(fk recursive).query("extension == :1 and name != :2"; ".jsonl"; "error-@")
		//var $file : 4D.File
		//var $examples : Text
		//For each ($file; $files)
		//var $json : Object
		//$json:=JSON Parse($file.getText(); Is object)
		//var $message : Object
		//For each ($message; $json.messages.query("role == :1"; "user"))
		//If ($examples#"")
		//$userPrompt+="\n"
		//End if 
		//$examples+="- "+$message.content
		//End for each 
		//End for each 
		//If ($examples#"")
		//$userPrompt+="\nDo not include any of the following or similar cases.\n"
		//$userPrompt+=$examples
		//End if 
		var $messages:=[]
		$messages.push({role: "system"; content: $trainingIdentity+"\n"+$systemPrompt})
		$messages.push({role: "user"; content: $userPrompt})
	Else 
		$messages:=$prompt
	End if 
	
	$agent.systemPrompt:=$systemPrompt
	$agent.assistingIdentity:=$assistingIdentity
	$agent.trainingIdentity:=$trainingIdentity
	$agent.count:=1000
	$agent.task:=$id
	$agent.startConversation($messages; Formula:C1597(data_critique_6))
	
End if 