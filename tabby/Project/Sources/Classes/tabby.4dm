Class constructor($port : Integer; $options : Object; $formula : 4D:C1709.Function)
	
	var $llama : cs:C1710._worker
	$llama:=cs:C1710._worker.new()
	
	If (Not:C34($llama.isRunning($port)))
		
		If ($options=Null:C1517)
			$options:={}
		End if 
		
		If ($options.model=Null:C1517)
			$options.model:="StarCoder-1B"
		End if 
		
		If ($options.chat_model=Null:C1517)
			$options.chat_model:="Qwen2.5-Coder-0.5B-Instruct"
		End if 
		
		If ($port=0) || ($port<0) || ($port>65535)
			$port:=8080
		End if 
		
		CALL WORKER:C1389(OB Class:C1730(This:C1470).name; This:C1470._Start; $port; $options; $formula)
		
	End if 
	
Function _Start($port : Integer; $options : Object; $formula : 4D:C1709.Function)
	
	var $model : cs:C1710.Model
	$model:=cs:C1710.Model.new($port; $options; $formula)
	
Function terminate()
	
	var $llama : cs:C1710._worker
	$llama:=cs:C1710._worker.new()
	$llama.terminate()