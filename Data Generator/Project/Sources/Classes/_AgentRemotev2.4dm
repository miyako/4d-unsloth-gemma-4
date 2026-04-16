Class extends _AgentRemote

Class constructor($provider : Text; $model : Text)
	
	Super:C1705($provider; $model)
	
Function continueConversation($messages : Collection) : cs:C1710.AIKit.OpenAIChatCompletionsResult
	
	This:C1470.messages.combine($messages)
	
	This:C1470.reasoning_content:=""
	
	If (This:C1470.ChatResult#"")
		This:C1470.ChatResult+="\r\r"
	End if 
	
	var $ChatCompletionsParameters : cs:C1710.AIKit.OpenAIChatCompletionsParameters
	$ChatCompletionsParameters:=cs:C1710.AIKit.OpenAIChatCompletionsParameters.new(This:C1470)
	$ChatCompletionsParameters.model:=This:C1470.model
	$ChatCompletionsParameters.stream:=This:C1470.stream
	$ChatCompletionsParameters.formula:=This:C1470.onEventStream
	
	var $response_format:={type: "json_schema"; json_schema: {}}
	$response_format.json_schema:={}
	$response_format.json_schema.name:="CustomObject"
	$response_format.json_schema.strict:=True:C214
	$response_format.json_schema.schema:={}
	$response_format.json_schema.schema.type:="object"
	$response_format.json_schema.schema.properties:={}
	$response_format.json_schema.schema.required:=["instruction"; "input"; "output_py"; "output_js"; "output_4d"; "output"]
	$response_format.json_schema.schema.additionalProperties:=False:C215
	$response_format.json_schema.schema.properties.instruction:={}
	$response_format.json_schema.schema.properties.instruction.type:="string"
	$response_format.json_schema.schema.properties.input:={}
	$response_format.json_schema.schema.properties.input.type:="string"
	$response_format.json_schema.schema.properties.output_py:={}
	$response_format.json_schema.schema.properties.output_py.type:="string"
	$response_format.json_schema.schema.properties.output_js:={}
	$response_format.json_schema.schema.properties.output_js.type:="string"
	$response_format.json_schema.schema.properties.output_4d:={}
	$response_format.json_schema.schema.properties.output_4d.type:="string"
	$response_format.json_schema.schema.properties.output:={}
	$response_format.json_schema.schema.properties.output.type:="string"
	$ChatCompletionsParameters.response_format:=$response_format
	
	If (This:C1470.provider="Cohere")
		OB REMOVE:C1226($ChatCompletionsParameters; "n")
	End if 
	
	var $ChatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult
	$ChatCompletionsResult:=This:C1470.OpenAI.chat.completions.create(This:C1470.messages; $ChatCompletionsParameters)
	
	return $ChatCompletionsResult