## How to use LoRA to fine-tune an LLM

### What does an LLM know?

It costs millions of dollars to train an LLM base model that understands language. "Understand" in this context means that its weights are parameterised to meaningfully predict the next probable token when matrix multiplied using **Transformer** or other kinds of vector maths. "Token" in this context are small chunks of digital data, like puzzle pieces the may or may not fit together. "Language" in this context means a collection of tokens that follow an interesting pattern we call meaning. It is not limit to text; sound is audio-language, vision is video-language. 

Every LLM has a knowledge cutoff date. Any information made public after that date was not included in its training data. That means the information is not accounted for in the weights of its parameters.

|Model|Cutoff|
|:-|-:|
|GPT 5.4 |[August 2025](https://developers.openai.com/api/docs/guides/latest-model)|
|Gemini 3.1 |[January 2025](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-pro-preview)
|Claude Opus 4.6|[August 2025](https://platform.claude.com/docs/en/about-claude/models/overview)

### How does an LLM acquire new information?

Modern LLMs are trained to search the internet for new information if necessary (**tool calling**). Whether a prompt triggers a web search depends on how the prompt is engineered and how the model was trained to design a multi-step plan before generating output tokens (**reasoning model**). 

While tool calling allows the LLM to include new information its output, an impromptu web search can only go so far. Simply putting things up on the internet doesn't mean they get caught by an AI. **LLMs are not web crawlers.** Moreover, if a model does not have access to the internet, or decides not to search, it will generate a response based on its trained parameters and sampling hyper-parameters such as `top-k` `top-p` `min-p` and `temperature`. You must **fine-tune** a model by exposing it to additinal minformation.

### How can a model be fine-tuned with additional training material?

You can fine-tune a model by creating a **LoRA adapter**. An adapter is like a lens that adjusts the model's built-in weights so that some weights become more or less reactive to each other. Since a base model already has good grasp of how language works and retraining is expensive, it is more efficient to invest in a domain specific adapter than to generate online content in the hopes that the next generation of LLMs might have more exposure to the information during its initial training. In fact, frontier labs have hinted that they will shift their focus from training to inference and fine-tuning.

### Unsloth

**Unsloth** is an open-source framework that makes fine-tuning large language models (LLMs) dramatically faster and cheaper. You can fine-tune popular models like Llama, Gemma, Phi, Qwen, Mistral, or DeepSeek. 

### Prepare Training Data

Suppose you want to teach an LLM about 4D. You need to design a comprehensive training course that covers multiple domains of the coding experience:

- Completion: finish partial code snippets
- Instruction: "write a method that does..."
- Explanation:  "explain what this code does"
- Translation: "convert this python code to 4D"
- Analysis: "what's wrong with this code"
- Documentation: insert comments and generate .md files

Before we start training, let's establish the baseline. Using Gemma 4, I prompt: _"How do I make HTTP requests in 4D?"_. The [result](https://github.com/miyako/4d-unsloth-gemma-4/blob/main/level-1.md) was a terrible hallucination.

What is noteworthy that the 4D coding language has been around for decades, yet, it has clearly not made a meaningful impact on the model's weights that are related to coding. Simply adding more resources on the internet is unlikely to sway how the model thinks. It is essential to develop a cutom LoRA adapter in order to improves the quality of 4D code generation by AI. 

## Training

> [!WARNING]
> If you want to teach an LLM to answer questions and carry out tasks, you should fine-tune an **instruction model**, not a base model. A base model is trained to mimic a pattern and complete text by predicting what comes next. It it not trained to engaged in a conversation. If you fine-tine a base model with a dataset full of tables and lists, the base model will likely output a lot of tables and lists. 

I have created Alpaca datasets using public resources and a **LoRA** [Notebook](https://colab.research.google.com/drive/1YkFF2n3hbxi5Sk4tLL7nV9fOURhA6kV5?usp=sharing) to train [google/gemma-4-E2B-it](https://huggingface.co/google/gemma-4-E2B-it) with **Unsloth**.

|Dataset|GPU (Google Colab)|Epochs|Duration
|-|-|-:|-
|[Documentation](https://huggingface.co/datasets/keisuke-miyako/developer-4d-com-21r2) |`NVIDIA A100-SXM4-40GB`|`1`|`2` hours
|[Blog](https://huggingface.co/datasets/keisuke-miyako/blog-4d-com-2026-0414)| `NVIDIA A100-SXM4-40GB`|`1`
|[Knowledge Base]() |`NVIDIA A100-SXM4-40GB`|`1`

> [!NOTE]
> Feeding 4D documentation to the model is only the first step. To actually train a model in coding, **you need carefully edited request and response examples written by an expert** such as:
> - Write a unit test for this
> - Refactor this in ORDA
> - Remove inter-process variables from this
> - What are the edge cases here?
> - Add documentation to this
> - Why does this code not work?
> 
> An LLM can be used to generate paraphrased variants, but by defintion you can't use an LLM to teach itself something it doesn't know already.

> [!WARNING]
> Additional training by itself does not guarantee improvement. It is possible to poison a model's weights by feeding it bad data. The media often portrays AI like a magical tool that can do just about anything. That is absolutely **not** how an LLM works. Machine learning is mathematical pattern recognition. Frontier labs have done the hard work of training base models using a colossal amount of cultural content created and classified by actual people. Fine-tuning is less costly, but still requires careful guidance and attention by a qualified supervisor.
 
```
==((====))==  Unsloth - 2x faster free finetuning | Num GPUs used = 1
   \\   /|    Num examples = 29,249 | Num Epochs = 1 | Total steps = 3,657
O^O/ \_/ \    Batch size per device = 2 | Gradient accumulation steps = 4
\        /    Data Parallel GPUs = 1 | Total batch size (2 x 4 x 1) = 8
 "-____-"     Trainable parameters = 31,039,488 of 5,154,217,504 (0.60% trained)
```

> [!TIP]
> You can merge a LoRA adapter with a GGUF model. To track progess, you might want to verify fine-tuned models each step of the way and publish them as transitional checkpoints.



