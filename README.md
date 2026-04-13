## How to use LoRA to fine-tune an LLM

### What does an LLM know?

It costs millions of dollars to train an LLM base model that understands language. "Understand" in this context means that its weights are parameterised to meaningfully predict the next probable token when multiplied using **Transformer** or other kind of vector maths. "Token" in this context are small chunks of digital data, like puzzle pieces the may or may not fit together. "Language" in this context means a collection of tokens that follow an interesting pattern we call meaning. It is not limit to text; sound is audio-language, vision is video-language. 

Every LLM has a knowledge cutoff date. Any information made public after that date was not included in its training data. That means the information is not accounted for in the weights of its parameters.

|Model|Cutoff|
|:-|-:|
|GPT 5.4 |[August 2025](https://developers.openai.com/api/docs/guides/latest-model)|
|Gemini 3.1 |[January 2025](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-pro-preview)
|Claude Opus 4.6|[August 2025](https://platform.claude.com/docs/en/about-claude/models/overview)

### How does an LLM learn new information?

Modern LLMs are trained to search the internet for new information if necessary. Whether a prompt triggers a web search depends on how the prompt is engineered and how the model was trained to design a plan before generating its output. 

While tool calling allows the LLM to include new information its output, an impromptu web search can only go so far. Simply putting things up on the internet doesn't replace actual training. If a model does not have access to the internet, it must generate a response solely based on its trained parameters and sampling hyper-parameters such as `top-k` `top-p` `min-p` and `temperature`.

### How does an adapter refine an LLM's output?

A base model already has good grasp of how language works. There is no need to retrain the model from scratch just to teanch some additional knowledge. Instead, you can create a **LoRA adapter**. An adapter is like a lens that adjusts the the built-in weights of a base model so that tokens become more or less likely to react with each other.

### Unsloth

**Unsloth** is an open-source framework that makes fine-tuning large language models (LLMs) dramatically faster and cheaper. You can fine-tune popular models like Llama, Gemma, Phi, Qwen, Mistral, or DeepSeek. 

### Prepare Training Data

Suppose you want to teach an LLM about 4D. You need to design a training course that covers multiple domains:

- Completion: finish partial code snippets
- Instruction: "write a method that does..."
- Explanation:  "explain what this code does"
- Translation: "convert this python code to 4D"
- Analysis: "what's wrong with this code"
- Documentation: insert comments and generate .md files

Before we start, let's establish the baseline. Using Gemma 4, I prompt:

> How do I make HTTP requests in 4D?

The result was a terrible hallucination:

> As a 4D-LLM based on the v21 feature set, I can guide you on making HTTP requests within the 4D development environment.
>
> The standard and most reliable method for handling external HTTP communication in 4D is through the **`NetworkModule`** or the dedicated **`HttpRequest`** component.
> 
> Here is a step-by-step guide on how to implement an HTTP request in 4D:
>
> ### 1. Initialize the Request Object
>
> You must first instantiate an `HttpRequest` object. This object will manage all parameters for your request.
> ```
> // Initialize the HTTP Request component
> DECLARE http_request AS HttpRequest;
> ```
>
> ### 2. Configure the Request Details
>
> Use the properties of the `HttpRequest` object to define *what* you are requesting.
>
> **A. Define the Method (Verb):**
> Specify the HTTP method you wish to use (e.g., `GET`, `POST`, `PUT`, `DELETE`).
>
> ```
> SET http_request.Method = "GET";  // Or "POST", "PUT", etc.
> ```
>
> **B. Define the Endpoint (URL):**
>
> Set the full URL or endpoint you are targeting.
>
> ```
> SET http_request.URL = "https://api.example.com/data/resourceID";
> ```
> 
> **C. Define Headers (Optional but Common):**
>
> If your request requires specific authentication (like API keys or content types), set the headers.
>
> ```
> // Add an Authorization header for token-based authentication
> SET http_request.Headers.Add("Authorization", "Bearer your_secure_token_12345");
> 
> // Set the content type for POST/PUT requests
> SET http_request.Headers.Add("Content-Type", "application/json");
> ```
>
> **D. Define the Body (For POST/PUT Requests):**
>
> If you are sending data to the server (e.g., creating a new record), you must populate the request body. This is typically done by structuring a data payload (like a JSON object) and setting it as the request body.
>
> ```
> // Create the JSON payload data structure
> DECLARE payload AS JSONObject;
> SET payload.username = "user_4D";
> SET payload.action = "update_status";
> 
> // Set the payload as the request body
> SET http_request.Body = Serialize(payload);
> ```
>
> ### 3. Execute the Request
>
> Once configured, execute the request using the system's network execution function.
>
> ```
> // Execute the request and store the result in a response variable
> DECLARE response AS HttpResponse;
> response = NetworkModule.Execute(http_request);
> ```
>
> ### 4. Handle the Response
>
> The `response` variable will contain the result from the server. You must check the status code and retrieve the data.
>
> **A. Check Status Code:**
>
> Verify that the request was successful (typically 200-299 range).
>
> ```
> IF response.StatusCode >= 200 AND response.StatusCode < 300 THEN
>     // Success path
>     PRINT "Request successful!";
>     
>     // Extract the data payload from the response body
>     DECLARE data_result AS JSONObject;
>     data_result = ParseJSON(response.Body);
>     PRINT "Received Data: " + data_result.message;
> 
> ELSE
>     // Error path
>     PRINT "Error: Request failed with status code " + response.StatusCode;
>     PRINT "Error details: " + response.ErrorMessage;
> END IF;
> ```
>
> ### Summary Flowchart
>
> 1.  **DECLARE** `HttpRequest`
> 2.  **SET** `Method`, `URL`, and optional `Headers`.
> 3.  **(IF POST/PUT)** **DECLARE** payload, **SET** payload, **SET** `Body`.
> 4.  **RESPONSE** = `NetworkModule.Execute(HttpRequest)`
> 5.  **IF** `RESPONSE.StatusCode` is successful:
    *   **PARSE** `RESPONSE.Body` into a usable format.
> 6.  **ELSE** (Error Handling):
    *   Log the error details.
> 
> By following this structure, you ensure that your HTTP interactions within 4D are robust, secure, and fully managed by the `NetworkModule`.

What is noteworthy that the 4D coding language has been around for decades, yet, it has clearly not made a meaningful impact on the model's weights related to coding capability. Simply having more resources on the internet is unlikely to sway how the model thinks. It is essential to develop a cutom LoRA adapter in order to improves the quality of 4D code generation by AI. 

## Training

I created Alpaca datasets using public resources and a **LoRA** [Notebook](https://colab.research.google.com/drive/1YkFF2n3hbxi5Sk4tLL7nV9fOURhA6kV5?usp=sharing) to train a model with **Unsloth**.

|Dataset|GPU (Google Colab)|Epochs|Duration
|-|-|-:|-
|[Documentation](https://huggingface.co/datasets/keisuke-miyako/developer-4d-com-21r2) |`NVIDIA A100-SXM4-40GB`|`1`
|[Blog](https://huggingface.co/datasets/keisuke-miyako/blog-4d-com-2026-0414)| `NVIDIA A100-SXM4-40GB`|`1`
|[Knowledge Base]() |`NVIDIA A100-SXM4-40GB`|`1`

> [!NOTE]
> Feeding documentation is only the first step. To actually train a model in coding, **you need carefully edited request and response examples written by an expert** such as:
> - Write a unit test for this
> - Refactor this in ORDA
> - Remove inter-process variables from this
> - What are the edge cases here?
> - Add documentation to this
> - Why does this code not work?
> 
> An LLM can be used to generate paraphrased variants, but by defintion you can't use an LLM to teach itself something it doesn't know already.


