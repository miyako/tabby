var $tabby : cs:C1710.tabby

If (False:C215)
	$tabby:=cs:C1710.tabby.new()  //default
Else 
	
	var $port : Integer
	$port:=8080
	
	Case of 
		: (Is macOS:C1572) && (Get system info:C1571.processor="@apple@")
			$device:="metal"
		: (Is Windows:C1573)
			$device:="vulcan"
		Else 
			$device:="cpu"
	End case 
	
	$tabby:=cs:C1710.tabby.new($port; {\
		model: "StarCoder-1B"; \
		chat_model: "Qwen2.5-Coder-0.5B-Instruct"; \
		device: $device; \
		parallelism: 1}; Formula:C1597(ALERT:C41(This:C1470.options.models.extract("file.fullName").join(",")+($1.success ? " started!" : " did not start..."))))
	
End if 