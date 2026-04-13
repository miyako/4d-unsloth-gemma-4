var $llama : cs:C1710.llama.llama

var $homeFolder : 4D:C1709.Folder
$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".GGUF")
var $file : 4D:C1709.File
var $URL : Text
var $port : Integer
var $huggingface : cs:C1710.event.huggingface

var $event : cs:C1710.event.event
$event:=cs:C1710.event.event.new()

$event.onError:=Formula:C1597(OnModelDownloaded)
$event.onSuccess:=Formula:C1597(OnModelDownloaded)
$event.onData:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; This:C1470.file.fullName+":"+String:C10((This:C1470.range.end/This:C1470.range.length)*100; "###.00%")))
$event.onResponse:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; This:C1470.file.fullName+":download complete"))
$event.onTerminate:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; (["process"; $1.pid; "terminated!"].join(" "))))

$port:=8080

var $folder : 4D:C1709.Folder
var $path; $mmproj; $URL; $cache_type_k; $cache_type_v : Text
var $n_gpu_layers; $threads; $batches; $ubatch_size; $batch_size; $max_position_embeddings : Integer

$folder:=$homeFolder.folder("gemma-4-E2B")
$path:="gemma-4-E2B-it-Q4_K_M.gguf"
$mmproj:="mmproj-F16.gguf"
$URL:="unsloth/gemma-4-E2B-it-GGUF"
$cache_type_k:="q4_0"
$cache_type_v:="q4_0"
$n_gpu_layers:=99
$threads:=6
$batches:=1
$ubatch_size:=512
$batch_size:=2048
$max_position_embeddings:=8192

var $logFile : 4D:C1709.File
$logFile:=$folder.file("llama.log")
$folder.create()
If (Not:C34($logFile.exists))
	$logFile.setContent(4D:C1709.Blob.new())
End if 

var $options : Object

$options:={\
ctx_size: $max_position_embeddings*$batches; \
batch_size: $batch_size; \
ubatch_size: $ubatch_size; \
parallel: $batches; \
threads: $threads; \
threads_batch: $threads; \
threads_http: 2; \
temp: 1; \
min_p: 0; \
top_k: 20; \
top_p: 0.95; \
repeat_penalty: 1; \
presence_penalty: 0; \
mmproj: $folder.file($mmproj); \
n_gpu_layers: $n_gpu_layers; \
log_disable: False:C215; \
log_file: $logFile; \
jinja: True:C214}

var $huggingfaces : cs:C1710.event.huggingfaces

$huggingface:=cs:C1710.event.huggingface.new($folder; $URL; [$path; $mmproj])
$huggingfaces:=cs:C1710.event.huggingfaces.new([$huggingface])

$llama:=cs:C1710.llama.llama.new($port; $huggingfaces; $homeFolder; $options; $event)