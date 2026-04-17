//%attributes = {"invisible":true}
var $i : Integer
$i:=0
var $out : 4D:C1709.Folder
var $root : 4D:C1709.Folder
$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
$out:=$root.folder("snippets_jsonl")
$out.create()
var $folders : Collection
var $folder; $snippet : 4D:C1709.Folder
var $file : 4D:C1709.File
$folder:=Folder:C1567(fk data folder:K87:12).folder("examples/snippets")
var $version : Text
For each ($snippet; $folder.files().query("extension == :1"; ".txt"))
	
	var $code_4d; $code_py; $code_js; $code_in : Text
	$code_4d:=$folder.file($snippet.name+".4dm").getText()
	$code_py:=$folder.file($snippet.name+".py").getText()
	$code_js:=$folder.file($snippet.name+".js").getText()
	$code_in:=$folder.file($snippet.name+".txt").getText()
	
	var $jsonl : Object
	$jsonl:={}
	$jsonl.instruction:=$code_in
	$jsonl.input:=""
	$jsonl.output:=$code_4d
	
	$i+=1
	$out.file(String:C10($i; "000000")+".jsonl").setText(JSON Stringify:C1217($jsonl; *))
	
	$jsonl:={}
	$jsonl.instruction:="Convert this python code to 4D"
	$jsonl.input:=$code_py
	$jsonl.output:=$code_4d
	
	$i+=1
	$out.file(String:C10($i; "000000")+".jsonl").setText(JSON Stringify:C1217($jsonl; *))
	
	$jsonl:={}
	$jsonl.instruction:="Convert this javascript code to 4D"
	$jsonl.input:=$code_js
	$jsonl.output:=$code_4d
	
End for each 
