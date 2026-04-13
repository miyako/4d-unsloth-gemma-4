## How to use LoRA to fine-tune an LLM

### What does an LLM know?

It costs millions of dollars to train an LLM base model that understands language. "Understand" in this context means that its weights are parameterised to meaningfully predict the next probable token when multiplied using **Transformer** or other kind of vector maths. "Token" in this context are small chunks of digital data, like puzzle pieces the may or may not fit together. "Language" in this context means a collection of tokens that follow an interesting pattern we call meaning. It is not limit to text; sound is audio-language, vision is video-language. 

Every LLM has a knowledge cutoff date. Any information made public after that date was not included in its training data. That means the information is not accounted for in the weights of its parameters.

|Model||
|:-|-:|
|GPT 5.4 |[August 2025](https://developers.openai.com/api/docs/guides/latest-model)|
|Gemini 3.1 |[January 2025](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-pro-preview)
|Claude Opus 4.6|[August 2025](https://platform.claude.com/docs/en/about-claude/models/overview)

### How does an LLM learn new information?

Modern LLMs are trained to search the internet for new information if necessary. Whether a prompt triggers a web search depends on how the prompt is engineered and how the model was trained to design a plan before generating its output. 

While tool calling allows the LLM to include new information its output, an impromptu web search can only go so far. Simply putting things up on the internet doesn't replace actual training. 

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

Before we start, let's establish the baseline. Using Gemma 4, I prompt

> How do I make HTTP requests in 4D?

The result is a terrible hallucination:

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
> ...
 
