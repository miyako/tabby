---
layout: default
---

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/tabby)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/tabby/total)

# Use TabbyML from 4D

#### Abstract

[**TabbyML**](https://github.com/TabbyML/tabby) is a specialised local inference server for "Fill-In-The-Middle" (FIM) code completion. It has specialised logic for RAG to make the model smarter about the current project structure.

#### Usage

Instantiate `cs.tabby.tabby` in your *On Startup* database method:

```4d
var $tabby : cs.tabby

If (False)
    $tabby:=cs.tabby.tabby.new()  //default
Else 
    
    var $port : Integer
    $port:=8080
    
    Case of 
        : (Is macOS) && (Get system info.processor="@apple@")
            $device:="metal"
        : (Is Windows)
            $device:="vulcan"
        Else 
            $device:="cpu"
    End case 
    
    $tabby:=cs.tabby.tabby.new($port; {\
    model: "StarCoder-1B"; \
    chat_model: "Qwen2.5-Coder-0.5B-Instruct"; \
    device: $device; \
    parallelism: 1}; Formula(ALERT(This.options.models.extract("file.fullName").join(",")+($1.success ? " started!" : " did not start..."))))
    
End if 
```

Unless the server is already running (in which case the costructor does nothing), the following procedure runs in the background:

1. The specified models are downloaded via HTTP
2. The `tabby` program is started

#### Install IDE Extension

* [Tabby VSCode Extension](https://marketplace.visualstudio.com/items?itemName=TabbyML.vscode-tabby)

Visit http://localhost:8080/ (or your server address) and follow the instructions to create your account. After creating your account, you can find your token for connecting to the server.

In VSCode, connect to server.



Finally to terminate the server:

```4d
var $tabby : cs.tabby.tabby
$tabby:=cs.tabby.tabby.new()
$tabby.terminate()
```

#### AI Kit compatibility

The API is compatibile with [Open AI](https://platform.openai.com/docs/api-reference/embeddings). 

|Class|API|Availability|
|-|-|:-:|
|Models|`/v1/models`||
|Chat|`/v1/chat/completions`|✅|
|Completion|`/v1/completions`|✅|
|Images|`/v1/images/generations`||
|Moderations|`/v1/moderations`||
|Embeddings|`/v1/embeddings`|✅|
|Files|`/v1/files`||
