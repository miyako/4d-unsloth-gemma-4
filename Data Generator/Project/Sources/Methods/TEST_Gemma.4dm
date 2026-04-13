//%attributes = {"preemptive":"capable"}
#DECLARE($params : Object)

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	var $Gemma : cs:C1710.Gemma
	$Gemma:=cs:C1710.Gemma.new(\
		"Chat Result (LOCAL)"; \
		"Start Conversation"; \
		"Continue Conversation"; \
		"User Prompt")
	
	//%T-
	var $window : Integer
	$window:=Open form window:C675("TEST_LOCAL")
	DIALOG:C40("TEST_LOCAL"; $Gemma; *)
	//%T+
	
End if 