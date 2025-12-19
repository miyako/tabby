Class extends _tabby

Class constructor($controller : 4D:C1709.Class)
	
	Super:C1705($controller)
	
Function _config($repositories : Collection) : Text
	
	var $lines : Collection
	$lines:=[]
	
	var $repository : Object
	For each ($repository; $repositories)
		
		If (Value type:C1509($repository.name)=Is text:K8:3) && ($repository.name#"")
			If (Value type:C1509($repository.URL)=Is text:K8:3) && ($repository.URL#"")
				$lines.push("[[repositories]]")
				$lines.push("name = \""+$repository.name+"\"")
				$lines.push("git_url = \""+$repository.URL+"\"")
			End if 
		End if 
	End for each 
	
	return $lines.join("\n")
	
Function start($option : Object) : 4D:C1709.SystemWorker
	
	This:C1470.bind($option; ["onTerminate"])
	
	var $command : Text
	$command:=This:C1470.escape(This:C1470.executablePath)
	
	$command+=" serve "
	
	var $root : 4D:C1709.Folder
	$root:=Folder:C1567(fk home folder:K87:24).folder(".tabby")
	
	If ($option.root#Null:C1517)
		If (OB Instance of:C1731($option.root; 4D:C1709.Folder))
			$option.root.create()
			$root:=$option.root
		End if 
	End if 
	
	This:C1470.controller.variables.TABBY_ROOT:=This:C1470.expand($root).path
	
	If (Value type:C1509($option.repositories)=Is collection:K8:32)
		$root.file("config.toml").setText(This:C1470._config($option.repositories))
	End if 
	
	If (Value type:C1509($option.ignore)=Is text:K8:3)
		If ($option.ignore#"")
			$root.file(".tabbyignore").setText($option.ignore.join("\n"))
		End if 
	End if 
	
	If (False:C215)
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
	End if 
	
	var $arg : Object
	var $valueType : Integer
	var $key : Text
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["root"; "ignore"; "repositories"; "help"; "version"].includes($arg.key))
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
	
	//SET TEXT TO PASTEBOARD($command)
	
	return This:C1470.controller.execute($command; Null:C1517; $option.data).worker
	