var $event : Object
$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		If (Not:C34(OB Instance of:C1731(Form:C1466; cs:C1710._Agent)))
			OBJECT SET VISIBLE:C603(*; "@"; False:C215)
			return 
		End if 
		
		var $systemPrompt; $inferenceIdentity : Text
		$inferenceIdentity:=Folder:C1567(fk data folder:K87:12).folder("prompts/coding").file("identity-for-inference.txt").getText()
		
		var $persona; $personaRuntime : Text
		$persona:=File:C1566("/RESOURCES/prompts/le pecq.txt").getText()
		$personaRuntime:=File:C1566("/RESOURCES/prompts/le pecq code.txt").getText()
		
		Form:C1466.systemPrompt:=$persona+"\n"+$personaRuntime
		Form:C1466.prompt:={values: []; contents: []}
		
		var $files : Collection
		$files:=Folder:C1567(fk resources folder:K87:11).files(fk ignore invisible:K87:22).query("extension == :1 order by name asc"; ".txt")
		
		var $file : 4D:C1709.File
		For each ($file; $files)
			Form:C1466.prompt.values.push($file.name)
			Form:C1466.prompt.contents.push($file.getText())
		End for each 
		
		If (Form:C1466.prompt.values.length#0)
			Form:C1466.prompt.index:=0
			Form:C1466.userPrompt:=Form:C1466.prompt.contents[Form:C1466.prompt.index]
		Else 
			Form:C1466.userPrompt:=""
		End if 
		
		Form:C1466.focusUserPrompt().clearConversation()
		
	: ($event.code=On After Edit:K2:43)
		
		Form:C1466.onAfterEdit()
		
	: ($event.code=On Unload:K2:2)
		
End case 