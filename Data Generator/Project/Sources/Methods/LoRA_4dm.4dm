//%attributes = {"invisible":true}
var $i : Integer
$i:=20
var $out : 4D:C1709.Folder
var $root : 4D:C1709.Folder
$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
$out:=$root.folder("4dm_jsonl")
$out.create()
var $folders : Collection
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
$folder:=$root.folder("projects")

For each ($file; $folder.files(fk ignore invisible:K87:22 | fk recursive:K87:7).query("extension == :1"; ".4dm"))
	
	var $code : Text
	$code:=$file.getText()
	
	//remove suffix
	METHOD SET CODE:C1194("DETOKEN"; $code)
	METHOD GET CODE:C1190("DETOKEN"; $code)
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	//remove attribute
	If (Match regex:C1019("(^\\/\\/%attributes\\s=\\s.*)"; $code; 1; $pos; $len))
		$code:=Substring:C12($code; $pos{1}+$len{1})
	End if 
	
	Case of 
		: ($file.parent.name="Methods")
			$code:="// Methods/"+$file.fullName+"\n"+$code
		: ($file.parent.name="Classes")
			$code:="// Classes/"+$file.fullName+"\n"+$code
		: ($file.parent.name="DatabaseMethods")
			$code:="// DatabaseMethods/"+$file.fullName+"\n"+$code
		: ($file.parent.name="ObjectMethods")
			$code:="// Forms/"+$file.parent.name+"/ObjectMethods/"+$file.fullName+"\n"+$code
		: ($file.parent.name="Triggers")
			$code:="// Triggers/"+$file.fullName+"\n"+$code
		Else 
			$code:="// Forms/"+$file.parent.name+"/"+$file.fullName+"\n"+$code
	End case 
	var $task : Object
	
	$file:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file("temp.txt")
	$file.setText($code)
	
	$task:={file: $file; \
		text_as_tokens: False:C215; \
		tokens_length: 1500; \
		overlap_ratio: 0.09; \
		unique_values_only: True:C214; \
		pooling_mode: Extract Pooling Mode Mean}
	var $extracted : Object
	$extracted:=Extract(Extract Document TXT; Extract Output Collection; $task)
	If ($extracted.success)
		var $input : Text
		var $data : Collection
		$data:=[]
		For each ($input; $extracted.input)
			$data.push({text: $input})
		End for each 
		$i+=1
		$out.file(String:C10($i; "000000")+".jsonl").setText(JSON Stringify:C1217($data; *))
	End if 
	
End for each 