//%attributes = {"invisible":true}
#DECLARE($params : Object)

/*
this method uses AI to generate good and bad chatml messages about commands
*/

var $id:="blog"

var $target_folder : 4D:C1709.Folder
$target_folder:=Folder:C1567(fk data folder:K87:12).folder("examples/blog")
$target_folder.create()

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(Current method name:C684+"first"; Current method name:C684; {})
	
Else 
	
	var $agent : cs:C1710._AgentRemote
	//$agent:=cs._AgentRemote.new("OpenAI"; "gpt-5")
	$agent:=cs:C1710._AgentRemote.new("Cohere"; "command-a-03-2025")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("prompts/"+$id+"/")
	
	var $systemPrompt; $userPrompt : Text
	$systemPrompt:=$folder.file("system.txt").getText()
	$userPrompt:=$folder.file("user.txt").getText()
	
	//loop on blogs
	
	var $root : 4D:C1709.Folder
	$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
	$folder:=$root.folder("blog_posts_jsonl")
	
	var $file : 4D:C1709.File
	$file:=$folder.files(fk ignore invisible:K87:22).first()
	
	If ($file=Null:C1517)
		return 
	End if 
	
	var $count : Integer
	$count:=3
	If ($target_folder.file(String:C10($count; "000000")+".jsonl").exists)
		var $done : 4D:C1709.Folder
		$done:=$folder.folder("done")
		$done.create()
		$file.moveTo($done)
		$done:=$target_folder.folder($file.name)
		$done.create()
		For each ($file; $target_folder.files())
			$file.moveTo($done)
		End for each 
		$file:=$folder.files(fk ignore invisible:K87:22).first()
		If ($file=Null:C1517)
			return 
		End if 
	End if 
	
	$userPrompt+="\n\n"
	$userPrompt+=JSON Parse:C1218($file.getText()).extract("text").join("\n")
	
	var $messages:=[]
	
	$messages.push({role: "system"; content: $systemPrompt})
	$messages.push({role: "user"; content: $userPrompt})
	
	$agent.startConversation($messages; Formula:C1597(data_blog_2))
	
End if 