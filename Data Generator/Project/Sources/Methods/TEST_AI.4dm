//%attributes = {"invisible":true}
#DECLARE($params : Object)

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	var $agent : cs:C1710._AgentRemote
	$agent:=cs:C1710._AgentRemote.new("OpenAI"; "gpt-5-mini")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/generate code/")
	
	var $systemPrompt; $userPrompt : Text
	$systemPrompt:=$folder.file("system.txt").getText()
	
	var $n : Integer
	$n:=3
	$userPrompt:="Generate "+String:C10($n)+" cases."
	
	var $files : Collection
	$files:=Folder:C1567(fk data folder:K87:12).folder("examples").files(fk recursive:K87:7).query("extension == :1"; ".txt")
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
	
	$agent.startConversation($messages; Formula:C1597(onAI))
	
End if 