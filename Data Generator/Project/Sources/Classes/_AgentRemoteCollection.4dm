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
	$response_format.json_schema.name:="ChatML"
	$response_format.json_schema.strict:=True:C214
	$response_format.json_schema.schema:={}
	$response_format.json_schema.schema.type:="array"
	$response_format.json_schema.schema.items:={}
	$response_format.json_schema.schema.items.type:="object"
	$response_format.json_schema.schema.items.properties:={}
	$response_format.json_schema.schema.items.required:=["messages"]
	$response_format.json_schema.schema.items.additionalProperties:=False:C215
	$response_format.json_schema.schema.items.properties.messages:={}
	$response_format.json_schema.schema.items.properties.messages.type:="array"
	$response_format.json_schema.schema.items.properties.messages.minItems:=3
	$response_format.json_schema.schema.items.properties.messages.maxItems:=3
	$response_format.json_schema.schema.items.properties.messages.items:={}
	$response_format.json_schema.schema.items.properties.messages.items.type:="object"
	$response_format.json_schema.schema.items.properties.messages.items.properties:={}
	$response_format.json_schema.schema.items.properties.messages.items.required:=["role"; "content"]
	$response_format.json_schema.schema.items.properties.messages.items.additionalProperties:=False:C215
	$response_format.json_schema.schema.items.properties.messages.items.properties.role:={type: "string"; enum: ["user"; "thought"; "assistant"]}
	$response_format.json_schema.schema.items.properties.messages.items.properties.content:={type: "string"}
	$ChatCompletionsParameters.response_format:=$response_format
	
	If (This:C1470.provider="Cohere")
		OB REMOVE:C1226($ChatCompletionsParameters; "n")
	End if 
	
	var $ChatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult
	$ChatCompletionsResult:=This:C1470.OpenAI.chat.completions.create(This:C1470.messages; $ChatCompletionsParameters)
	
	return $ChatCompletionsResult
	
Function startConversation($messages : Collection; $onResponse : 4D:C1709.Function) : cs:C1710.AIKit.OpenAIChatCompletionsResult
	
	If (OB Instance of:C1731($onResponse; 4D:C1709.Function))
		This:C1470._onResponse:=$onResponse
	Else 
		This:C1470._onResponse:=Null:C1517
	End if 
	
	return This:C1470.clearConversation().continueConversation($messages)