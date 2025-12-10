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
	
	var $TABBY_ROOT : 4D:C1709.Folder
	$TABBY_ROOT:=Folder:C1567(fk home folder:K87:24).folder(".tabby")
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(Structure file:C489; fk platform path:K87:2).parent.parent.parent
	
	//can be file, github or gitlab
	var $repositories : Collection
	$repositories:=[]
	var $URL : Text
	var $name : Text
	$URL:="file://"+Convert path system to POSIX:C1106($folder.platformPath; *)
	$name:="local"
	$repositories.push({name: $name; URL: $URL})
	
	$URL:="https://github.com/miyako/tabby"
	$name:="github"
	$repositories.push({name: $name; URL: $URL})
	
	//paths exclude from RAG index
	var $ignore : Collection
	$ignore:=["Libraries/"; "Data/"; "userPreferences.*"]
	
	$tabby:=cs:C1710.tabby.new($port; {\
		model: "StarCoder-1B"; \
		chat_model: "Qwen2.5-Coder-0.5B-Instruct"; \
		device: $device; \
		parallelism: 1; \
		root: $TABBY_ROOT; \
		repositories: $repositories; \
		ignore: $ignore}; Formula:C1597(ALERT:C41(This:C1470.options.models.extract("file.fullName").join(",")+($1.success ? " started!" : " did not start..."))))
	
End if 