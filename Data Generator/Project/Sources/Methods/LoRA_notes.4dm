//%attributes = {"invisible":true}
var $i : Integer
$i:=0
var $out : 4D:C1709.Folder
var $root : 4D:C1709.Folder
$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
$out:=$root.folder("notes_jsonl")
$out.create()
var $folders : Collection
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
$folder:=$root.folder("notes")
var $version : Text
For each ($file; $folder.files(fk ignore invisible:K87:22 | fk recursive:K87:7).query("extension == :1"; ".pdf"))
	var $task : Object
	$task:={file: $file; \
		text_as_tokens: False:C215; \
		tokens_length: 1500; \
		overlap_ratio: 0.09; \
		unique_values_only: True:C214; \
		pooling_mode: Extract Pooling Mode Mean}
	var $extracted : Object
	$extracted:=Extract(Extract Document PDF; Extract Output Collection; $task)
	If ($extracted.success)
		var $input : Text
		var $data : Collection
		$data:=[]
		For each ($input; $extracted.input)
			$data.push({text: $version+$input})
		End for each 
		$i+=1
		$out.file(String:C10($i; "000000")+".jsonl").setText(JSON Stringify:C1217($data; *))
	End if 
End for each 
