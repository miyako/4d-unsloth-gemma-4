property OpenAI : cs:C1710.AIKit.OpenAI
property ChatResult : Text
property model : Text
property preemptive : Boolean
property messages : Collection
property _onResponse : 4D:C1709.Function
property stream : Boolean
property reasoning_content : Text
property apiKey : Text

Class constructor($provider : Text; $model : Text)
	
	var $OpenAI : cs:C1710.RemoteLLM
	$OpenAI:=cs:C1710.RemoteLLM.new($provider)
	var $baseURL; $apiKey : Text
	$baseURL:=$OpenAI.endpoint
	$apiKey:=$OpenAI.getAccessToken($provider)
	This:C1470.stream:=True:C214
	This:C1470.model:=$model
	This:C1470.OpenAI:=cs:C1710.AIKit.OpenAI.new({baseURL: $baseURL; apiKey: $apiKey})
	This:C1470.preemptive:=Process info:C1843(Current process:C322).preemptive
	
Function clearConversation() : cs:C1710._AgentRemote
	
	This:C1470.ChatResult:=""
	This:C1470.reasoning_content:=""
	This:C1470.messages:=[]
	
	return This:C1470
	
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
	
Function onCompletion($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)
	
	If (OB Instance of:C1731(This:C1470._onResponse; 4D:C1709.Function))
		This:C1470._onResponse.call(This:C1470; $chatCompletionsResult)
	End if 
	
Function onEventStream($chatCompletionsResult : cs:C1710.AIKit.OpenAIChatCompletionsResult)
	
	If ($chatCompletionsResult.success)
		If ($chatCompletionsResult.terminated)
			//complete result
			If ($chatCompletionsResult.choice#Null:C1517)
				If ($chatCompletionsResult.choice.message=Null:C1517)  //streaming
					$chatCompletionsResult:=JSON Parse:C1218(JSON Stringify:C1217($chatCompletionsResult))
					$chatCompletionsResult.choice.message:={role: "assistant"; content: This:C1470.ChatResult}
				Else   //not streaming
					This:C1470.ChatResult+=$chatCompletionsResult.choice.message.content
				End if 
				This:C1470.messages.push($chatCompletionsResult.choice.message)
			Else 
				
			End if 
			This:C1470.onCompletion($chatCompletionsResult)
		Else 
			//partial result
			If ($chatCompletionsResult.choice#Null:C1517)
				If ($chatCompletionsResult.choice.delta.text#"")
					
					If (This:C1470.reasoning_content#"")
						This:C1470.reasoning_content:=""
						This:C1470.ChatResult:=This:C1470.reasoning_content
					End if 
					This:C1470.ChatResult+=$chatCompletionsResult.choice.delta.text
				Else 
					If ($chatCompletionsResult.choice.delta["reasoning_content"]#Null:C1517)
						This:C1470.reasoning_content+=$chatCompletionsResult.choice.delta["reasoning_content"]
						This:C1470.ChatResult:=This:C1470.reasoning_content
					End if 
				End if 
			Else 
			End if 
		End if 
	Else 
		If ($chatCompletionsResult.terminated)
			This:C1470.ChatResult+=$chatCompletionsResult.errors.extract("message").join("\r")
		End if 
	End if 
	
Function _isFreshConversation() : Boolean
	
	return This:C1470.messages.length=0
	