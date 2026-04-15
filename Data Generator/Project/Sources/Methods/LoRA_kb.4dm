//%attributes = {"invisible":true}
var $i : Integer
$i:=0
var $out : 4D:C1709.Folder
var $root : 4D:C1709.Folder
$root:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent
$out:=$root.folder("kb_assets_jsonl")
$out.create()
var $folders : Collection
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
$folder:=$root.folder("kb_assets")
var $version; $body; $title : Text
For each ($file; $folder.files(fk ignore invisible:K87:22 | fk recursive:K87:7).query("extension == :1"; ".json"))
	var $json : Object
	$json:=JSON Parse:C1218($file.getText(); Is object:K8:27)
	var $content : Text
	$content:=$json.content
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	If (Match regex:C1019("(KNOWLEDGE BASE\\nLog In\\n\\|\\nKnowledge Base\\n\\|\\n4D Home\\n)"; $content; 1; $pos; $len))
		$body:=Substring:C12($content; $pos{1}+$len{1})
		If (Match regex:C1019("(?:[^:]+:)\\s*(.+)"; $body; 1; $pos; $len))
			$title:=Substring:C12($body; $pos{1}; $len{1})
			$content:=Substring:C12($body; $pos{1}+$len{1}+1)
			//PRODUCT: 4D | VERSION: 21 | PLATFORM: Mac & Win\nPublished On: March 26, 2026\nWhen unauthenticated HTTP requests hit the 4D built-in REST server, the Administration window can quickly become overwhelmed by hundreds of "REST Direct Access" entries with no associated users\nRestart the 4D Server to clear all existing REST Direct Access sessions immediately.\nTo stop new sessions from being created, set $0 := False in the On REST Authentication database method or add a proper authentication :\n#DECLARE\n(\n$url\n:\nText\n;\n$header\n:\nText\n;\n$ipB\n:\nText\n;\n$ipS\n:\nText\n; \\\n$user\n:\nText\n;\n$pw\n:\nText\n)->\n$accept\n:\nBoolean\nIf\n(your logic : check header, token, IP, etc ...)\n$accept\n:=\nTrue\nElse\n$accept\n:=\nFalse\nEnd if\nEnsure client applications reuse the WASID4D cookie, details are in\nhttps://blog.4d.com/a-better-understanding-of-4d-rest-sessions/\n. If REST is not required, disable global exposure in Database Settings > Web > Web Features and uncheck “Expose as REST resource” on every table in the Structure Editor.\nTo enhance overall firewall security, permit HTTP traffic only from trusted IPs instead of leaving it open to the world.
			If (Match regex:C1019("PRODUCT: (.+) \\| VERSION: (\\S+) \\| .+"; $content; 1; $pos; $len))
				var $product : Text
				$product:=Substring:C12($content; $pos{1}; $len{1})
				If ($product#"4D@")
					continue
				End if 
				$version:=$product+" version "+Substring:C12($content; $pos{2}; $len{2})
				$body:=Substring:C12($content; $pos{0}+$len{0}+1)
				If (Match regex:C1019("(?:[^:]+:)(.+)"; $body; 1; $pos; $len))
					$content:=Substring:C12($body; $pos{0}+$len{0}+1)
					$content:=Replace string:C233($content; "\n"; ""; *)
					var $tempFile : 4D:C1709.File
					$tempFile:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file("temp.txt")
					$tempFile.setText($content)
					var $task : Object
					$task:={file: $tempFile; \
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
							$data.push({text: $version+"\n"+$input})
						End for each 
						$i+=1
						$out.file(String:C10($i; "000000")+".jsonl").setText(JSON Stringify:C1217($data; *))
					End if 
				End if 
			End if 
		End if 
	End if 
End for each 
