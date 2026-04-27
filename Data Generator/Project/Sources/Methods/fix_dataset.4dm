//%attributes = {"invisible":true}
var $folder : 4D:C1709.Folder
$folder:=Folder:C1567("/DATA/examples/critique")
var $files : Collection
$files:=$folder.files(fk ignore invisible:K87:22).query("extension == :1"; ".jsonl")
var $target : 4D:C1709.Folder
$target:=Folder:C1567("/DATA/examples/jsonl")
$target.create()
var $file : 4D:C1709.File
For each ($file; $files)
	var $json : Text
	$json:=$file.getText()
	var $result : Object
	$result:=Try(JSON Parse:C1218($json; Is object:K8:27))
	var $results : Collection
	If ($result=Null:C1517)
		$results:=Try(JSON Parse:C1218($json; Is collection:K8:32))
	Else 
		$results:=[$result]
	End if 
	If ($results#Null:C1517)
		var $i:=1
		For each ($result; $results)
			If ($result.messages.length=4)
				$result.messages[0].role:="system"
				$result.messages[1].role:="user"
				$result.messages[2].role:="thought"
				$result.messages[3].role:="assistant"
				var $fileName : Text
				$fileName:=String:C10($i; "000000")+".jsonl"
				While ($target.file($fileName).exists)
					$i+=1
					$fileName:=String:C10($i; "000000")+".jsonl"
				End while 
			Else 
				continue
			End if 
			$target.file($fileName).setText(JSON Stringify:C1217($result))
		End for each 
	End if 
End for each 