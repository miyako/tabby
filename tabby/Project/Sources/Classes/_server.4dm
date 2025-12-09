Class extends _tabby

Class constructor($controller : 4D:C1709.Class)
	
	Super:C1705($controller)
	
Function start($option : Object) : 4D:C1709.SystemWorker
	
	var $command : Text
	$command:=This:C1470.escape(This:C1470.executablePath)
	
	$command+=" serve "
	
	var $models : Collection
	$models:=[]
	If ($option.models#Null:C1517)
		For each ($model; $option.models)
			If (OB Instance of:C1731($model.file; 4D:C1709.File))
				If (Value type:C1509($model.file)=Is object:K8:27) && (OB Instance of:C1731($model.file; 4D:C1709.File)) && ($model.file.exists)
					$models.push(This:C1470.escape(This:C1470.expand($model.file).path))
				End if 
			End if 
		End for each 
	End if 
	
	var $arg : Object
	var $valueType : Integer
	var $key : Text
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["model"; "chat_model"; \
				"help"].includes($arg.key))
				continue
		End case 
		$valueType:=Value type:C1509($arg.value)
		$key:=Replace string:C233($arg.key; "_"; "-"; *)
		Case of 
			: ($valueType=Is real:K8:4)
				$command+=(" --"+$key+" "+String:C10($arg.value)+" ")
			: ($valueType=Is text:K8:3)
				$command+=(" --"+$key+" "+This:C1470.escape($arg.value)+" ")
			: ($valueType=Is boolean:K8:9) && ($arg.value)
				$command+=(" --"+$key+" ")
			: ($valueType=Is object:K8:27) && (OB Instance of:C1731($arg.value; 4D:C1709.File))
				$command+=(" --"+$key+" "+This:C1470.escape(This:C1470.expand($option.model).path))
			Else 
				//
		End case 
	End for each 
	
	return This:C1470.controller.execute($command; Null:C1517; $option.data).worker
	