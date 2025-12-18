Class constructor($port : Integer; $options : Object; $event : cs:C1710.event.event)
	
	var $tabby : cs:C1710.workers.worker
	$tabby:=cs:C1710.workers.worker.new(cs:C1710._server)
	
	If (Not:C34($tabby.isRunning($port)))
		
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
		
		This:C1470.main($port; $options; $event)
		
	End if 
	
Function onTCP($status : Object; $options : Object)
	
	If ($status.success)
		
		var $className : Text
		$className:=Split string:C1554(Current method name:C684; "."; sk trim spaces:K86:2).first()
		
		CALL WORKER:C1389($className; Formula:C1597(start); $options; Formula:C1597(onModel))
		
	Else 
		
		var $statuses : Text
		$statuses:="TCP port "+String:C10($status.port)+" is aready used by process "+$status.PID.join(",")
		var $error : cs:C1710.event.error
		$error:=cs:C1710.event.error.new(1; $statuses)
		
		If ($options.event#Null:C1517) && (OB Instance of:C1731($options.event; cs:C1710.event.event))
			$options.event.onError.call(This:C1470; $options; $error)
		End if 
		
	End if 
	
Function main($port : Integer; $options : Object; $event : cs:C1710.event.event)
	
	main({port: $port; options: $options; event: $event}; This:C1470.onTCP)
	
Function terminate()
	
	var $tabby : cs:C1710.workers.worker
	$tabby:=cs:C1710.workers.worker.new(cs:C1710._server)
	$tabby.terminate()