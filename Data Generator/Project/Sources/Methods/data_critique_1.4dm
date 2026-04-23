//%attributes = {"invisible":true}
#DECLARE($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)

/*
this method uses AI to generate chatml
*/

var $id:="critique"

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684; Current method name:C684; [])
	
Else 
	
	If (This:C1470=Null:C1517)
		
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
		
		var $messages:=[]
		$messages.push({role: "system"; content: $trainingIdentity+"\n"+$systemPrompt})
		$messages.push({role: "user"; content: $userPrompt})
		
		$agent.systemPrompt:=$systemPrompt
		$agent.assistingIdentity:=$assistingIdentity
		$agent.trainingIdentity:=$trainingIdentity
		$agent.count:=1000
		$agent.task:=$id
		$agent.startConversation($messages; Formula:C1597(data_critique_1))
		
	Else 
		
		$id:=This:C1470.task
		var $folder : 4D:C1709.Folder
		$folder:=Folder:C1567(fk data folder:K87:12).folder("examples").folder($id)
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
				$fileName:=String:C10($i; "000000")+".jsonl"
				While ($folder.file($fileName).exists)
					$i+=1
					$fileName:=String:C10($i; "000000")+".jsonl"
				End while 
				var $system : Object
				//inject persona
				$result.messages.unshift({role: "system"; content: This:C1470.assistingIdentity})
				If (False:C215)
					//❓syntax check
					var $content : Text
					$content:=$result.messages.query("role == :1"; "assistant").first().content
					var $l1 : Text
					var $lines : Collection
					var $offset : Integer
					$lines:=Split string:C1554($content; "\n")
					$l1:=$lines.first()
					Case of 
						: ($l1="var $@")
						: ($l1="Try@")
						: ($l1="Use@")
						Else 
							$content:=$lines.slice(1).join("\n")
							$offset:=1
					End case 
					METHOD SET CODE:C1194("DETOKEN"; $content)
					var $status : Object
					var $options:={}
					$options.targets:=[]  //Empty collection for syntax checking
					$status:=Compile project:C1760($options)
					var $errors : Collection
					$errors:=$status.errors
					var $errorsForMethod : Collection
					$errorsForMethod:=$errors.query("isError == true and code.type == :1 and code.methodName == :2"; "projectMethod"; "DETOKEN")
					If ($errorsForMethod.length#0)
						var $messages : Collection
						$messages:=[]
						var $error : Object
						For each ($error; $errorsForMethod)
							If ($error.line=Null:C1517)
								continue
							End if 
							If ($error.line=$offset)
								continue
							End if 
							$messages.push("line "+String:C10($error.line-$offset)+": "+$error.message)
						End for each 
						If ($messages.length>0)
							//❌error
							var $errorMessages : Text
							$errorMessages:=$messages.join("\n")
							var $userPrompt : Text
							$userPrompt:="Explain what is wrong and how to fix the error.\n"
							$userPrompt+=$content
							$userPrompt+="\nerrors:\n"
							$userPrompt+=$messages.join("\n")
							$messages:=[]
							$messages.push({role: "user"; content: $userPrompt})
							$folder.file("error-"+$fileName).setText(JSON Stringify:C1217($messages; *))
						End if 
					End if 
				End if 
				//✅save it
				$folder.file($fileName).setText(JSON Stringify:C1217($result; *))
			End for each 
		End if 
		
		If ($i>=This:C1470.count)
			TRACE:C157
			return 
		End if 
		
		//DELAY PROCESS(Current process; 60*30)
		
		data_critique_1
		
	End if 
	
End if 