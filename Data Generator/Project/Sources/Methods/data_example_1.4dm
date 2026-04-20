//%attributes = {"invisible":true}
#DECLARE($params : Object)

var $id:="snippets"

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684; Current method name:C684; {})
	
Else 
	
	var $agent : cs:C1710._AgentRemotev2
	//$agent:=cs._AgentRemote.new("OpenAI"; "gpt-5-mini")
	//$agent:=cs._AgentRemote.new("Claude"; "claude-haiku-4-5")
	//$agent:=cs._AgentRemotev2.new("xAI"; "grok-4.20-0309-reasoning")
	$agent:=cs:C1710._AgentRemotev2.new("Azure_xAI"; "grok-4-20-reasoning")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/"+$id+"/")
	
	var $systemPrompt; $userPrompt : Text
	$systemPrompt:=$folder.file("system.txt").getText()
	$userPrompt:=$folder.file("user.txt").getText()
	
	$folder:=Folder:C1567(fk data folder:K87:12).folder("examples/"+$id)
	var $files : Collection
	$files:=$folder.files(fk recursive:K87:7).query("extension == :1"; ".txt")
	var $file : 4D:C1709.File
	var $examples : Text
	For each ($file; $files)
		If ($examples#"")
			$userPrompt+="\n"
		End if 
		$examples+="- "+$file.getText()
	End for each 
	
	If ($examples#"")
		$userPrompt+="\nDo not include any of the following or similar cases.\n"
		$userPrompt+=$examples
	End if 
	
	var $messages:=[]
	
	$messages.push({role: "system"; content: $systemPrompt})
	$messages.push({role: "user"; content: $userPrompt})
	
	$agent.startConversation($messages; Formula:C1597(data_example_2))
	
End if 