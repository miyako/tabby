---
layout: default
---

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/tabby)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/tabby/total)

# Use TabbyML from 4D

#### Abstract

[**TabbyML**](https://github.com/TabbyML/tabby) is a local inference server for "Fill-In-The-Middle" (FIM) code completion. It has a specialised RAG logic for coding to generate tokens are the most relevant to the current workspace.

You typically use pair of models, one for conversation and another for coding. The AI generated code can be augmented by indexing the codebase (RAG). The conversation model is trained understand semantic queries and the coding model is to trained to generate better code.

For instance, one may use the following combination:

* StarCoder-1B for coding (`675.7 MB`)
* Qwen2.5-Coder-0.5B-Instruct for chat (`1.32 GB`)

The idea is to run the AI locally instead of using online such as Copilot, Claude Sonnet or ChatGPT.

#### Usage

Instantiate `cs.tabby.tabby` in your *On Startup* database method:

```4d
var $tabby : cs.tabby.tabby

If (False)
    $tabby:=cs.tabby.tabby.new()  //default
Else 
    
    var $port : Integer
    $port:=8080
    
    Case of 
        : (Is macOS) && (System info.processor="@apple@")
            $device:="metal"
        : (Is Windows)
            $device:="vulcan"
        Else 
            $device:="cpu"
    End case 
    
    var $TABBY_ROOT : 4D.Folder
    $TABBY_ROOT:=Folder(fk home folder).folder(".tabby")
    
    var $folder : 4D.Folder
    $folder:=Folder(Structure file; fk platform path).parent.parent.parent
    
    //can be file, github or gitlab
    var $repositories : Collection
    $repositories:=[]
    var $URL : Text
    var $name : Text
    $URL:="file://"+Convert path system to POSIX($folder.platformPath; *)
    $name:="local"
    $repositories.push({name: $name; URL: $URL})
    
    $URL:="https://github.com/miyako/tabby"
    $name:="github"
    $repositories.push({name: $name; URL: $URL})
    
    //paths exclude from RAG index
    var $ignore : Collection
    $ignore:=["Libraries/"; "Data/"; "userPreferences.*"]
    
    var $event : cs.tabby.tabbyEvent
    $event:=cs.tabby.tabbyEvent.new()
    /*
        Function onError($params : Object; $error : cs._error)
        Function onSuccess($params : Object)
    */
    $event.onError:=Formula(ALERT($2.message))
    $event.onSuccess:=Formula(ALERT([$1.model; $1.chat_model].join(",")+" loaded!"))
    
    $tabby:=cs.tabby.tabby.new($port; {\
    model: "StarCoder-1B"; \
    chat_model: "Qwen2.5-Coder-0.5B-Instruct"; \
    device: $device; \
    parallelism: 1; \
    root: $TABBY_ROOT; \
    repositories: $repositories; \
    ignore: $ignore}; $event)
    
End if 
```

Unless the server is already running (in which case the costructor does nothing), the following procedure runs in the background:

1. The specified models are downloaded via HTTP
2. The `tabby` program is started

Visit [http://localhost:8080/](http://localhost:8080/]) and follow the instructions to create your account. After creating your account, you can find your token for connecting to the server.

Now you can test the server:

```
curl http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer auth_..." \
  -d '{
    "language": "python",
    "segments": {
      "prefix": "def fibonacci(n):\n    \"\"\"Return the nth fibonacci number.\"\"\""
    },
    "max_tokens": 64,
    "temperature": 0.1
  }'
```

```json
{"id":"cmpl-f6f89dca-549a-4a7c-a129-8b976083dd9c","choices":[{"index":0,"text":"\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)\n"}],"mode":"standard"}
```

The newer chat endpoint:

```
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer auth_" \
  -d '{
    "model": "tabby",
    "messages": [
      {
        "role": "user",
        "content": "Write a Python function for fibonacci."
      }
    ],
    "max_tokens": 64,
    "temperature": 0.1
  }'
```

```
data: {"id":"chatcmpl-3ewdYlS51ra4RQ3LJATBPDOf1Qu5Hpqa","choices":[{"index":0,"delta":{"content":null,"function_call":null,"tool_calls":null,"role":"assistant","refusal":null},"finish_reason":null,"logprobs":null}],"created":1765334008,"model":"tabby","service_tier":null,"system_fingerprint":"b1-952a47f","object":"chat.completion.chunk","usage":null}

data: {"id":"chatcmpl-3ewdYlS51ra4RQ3LJATBPDOf1Qu5Hpqa","choices":[{"index":0,"delta":{"content":"Here","function_call":null,"tool_calls":null,"role":null,"refusal":null},"finish_reason":null,"logprobs":null}],"created":1765334008,"model":"tabby","service_tier":null,"system_fingerprint":"b1-952a47f","object":"chat.completion.chunk","usage":null}

data: {"id":"chatcmpl-3ewdYlS51ra4RQ3LJATBPDOf1Qu5Hpqa","choices":[{"index":0,"delta":{"content":"'s","function_call":null,"tool_calls":null,"role":null,"refusal":null},"finish_reason":null,"logprobs":null}],"created":1765334008,"model":"tabby","service_tier":null,"system_fingerprint":"b1-952a47f","object":"chat.completion.chunk","usage":null}
...
```

#### Use the Web UI

Visit [http://localhost:8080/](http://localhost:8080/]), select a repository and ask a specific technical question about the project.

e.g. 

> Explain the function escape

#### Install IDE Extension

* [Tabby VSCode Extension](https://marketplace.visualstudio.com/items?itemName=TabbyML.vscode-tabby)

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
|Embeddings|`/v1/embeddings`||
|Files|`/v1/files`||
