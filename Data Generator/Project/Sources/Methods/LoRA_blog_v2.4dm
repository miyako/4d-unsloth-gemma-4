//%attributes = {"invisible":true}
var $i : Integer
$i:=0
var $out : 4D:C1709.Folder
var $root : 4D:C1709.Folder
$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
$out:=$root.folder("chatml_blog_jsonl")
$out.create()
var $folders : Collection
var $folder; $snippet : 4D:C1709.Folder
var $file : 4D:C1709.File

var $files1; $files2 : Collection
$files1:=Folder:C1567(fk data folder:K87:12).folder("examples/blog").files(fk ignore invisible:K87:22 | fk recursive:K87:7).query("extension == :1"; ".jsonl")
$files2:=Folder:C1567(fk data folder:K87:12).folder("examples/blog_2").files(fk ignore invisible:K87:22 | fk recursive:K87:7).query("extension == :1"; ".jsonl")

var $files : Collection
$files:=$files1.combine($files2)

For each ($file; $files)
	var $fileName : Text
	$fileName:=String:C10($i; "000000")+".jsonl"
	While ($out.file($fileName).exists)
		$i+=1
		$fileName:=String:C10($i; "000000")+".jsonl"
	End while 
	
	$file.moveTo($out; $fileName)
End for each 