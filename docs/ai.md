
## Notes from 2026-05-30

Until recently my main engagement with AI was by running Ollama with a small model like gemma3n on a mac mini. It was very basic usage, and trying to use it for code was by copy/pasting a snippet and asking it for input.

Then recently I discovered Opencode which is a way of running AI with Agents. I'm too cheap to pay for "real" models like ChatGPT/Claude so I wanted to run it locally.

Running either on a Mac laptop or Mac mini was only possible by using very small and slow models.

I do have a gaming computer though, with an NVIDIA 3070 GPU. You can also set Ollama to allow network access. 

So the current method has been to run Opencode from the mac mini and configure it to connect to Ollama running on the gaming computer. The model I've been using has mainly been Gemma 4 with the `e4b` variant which can reasonably fit within the 3070's VRAM. 

This is still a little slow, but its much faster than the laptop or mac mini. 

This is also as far as I can reasonably go with local hardware. Dedicated AI hardware like DGX spark are expensive (£4,300) and highly sought after. Likewise getting gaming GPUs and connecting them together would be expensive. I'd have to build a whole computer because I dont have any motherboards with 2 PCIe slots, the GPUs are expensive and you need two of them. Even then, if you had two 3090s linked with NVLINK then you'd get 48GB VRAM which is only enough to run ~70B parameter models. That still limits you to small models, but they will run faster.

I've mainly been using it with the [Nexus project](https://github.com/omussell/nexus) since that is purely programming.

Some things I've found since working with Opencode:

- You have to be careful in write mode, because it has `bash` access. It can read, write and delete files, use  git, in addition to running any other shell commands. I havent yet tried sandboxing using a tool or containers. I'll try [sbx](https://www.docker.com/products/docker-sandboxes/) next.
- If it says its going to delete some files, it may delete the whole folder with `rm -rf` instead. Found that out the hard way. If its read the file contents while doing some other work, you can ask it to retrieve the file from its memory and it will print the contents to the screen so you can copy and recover it.
- Everything you're doing is saved in a session, and when you exit it will print the session ID. So you can reattach to an old session with `opencode -s sessionid`. This means you dont have to start over again.
- AGENTS.md are read on startup and kept in its memory while you converse. Its very important to have a lot of detail in that document because it directly influences the AI's behaviour.
- Writing plans to files is very helpful. I was getting some mixed results while trying to prompt it to create a plan which seemed correct. It was creating a high level plan where each task would involve multiple steps. So it was helpful to take the high level plan and iterate over it into discrete actionable tasks. 
- Bootstrapping from a blank repo doesnt go well. It needs context and existing content to push it in the right direction. I had been starting from a blank folder with only a README.md with rough notes. It was trying to run a lot of other commands to bootstrap. For example I said I wanted to use `sqlc` for handling the SQL and database connection. It was trying to run the wrong commands and creating files with the incorrect content. Instead I should have done this manually and got the ball rolling and then it could continue. This might be a side effect from using a relatively weak model.

Next things to try are:

- Be more rigorous with planning and executing the plans
- Sandboxing
- A real model like Codex, Claude code, or GLM 5.1 for coding



## Notes from 2026-06-13

I've been doing further research on how to run models locally and also keeping up with the changes happening in the AI world. A lot has been happening recently. 

Anthropic released Fable with major guardrails, and then subsequently prevented access due to those guardrails being broken. This has triggered more talk about the importance of open source models, and how the popular ones like DeepSeek-v4-pro, GLM 5.1, Qwen3.6, are all Chinese made and hosted. The only other major open source option being Gemma by Google. The worry is that not only will they restrict the frontier models to US, they will also restrict access to the Chinese models.

I'm planning on downloading the models from HuggingFace as a backup just in case this happens.

Gemma has had more variants released, most notably a 12b parameter model and also quantization for the models. Apparently the original tweet announcing the Gemma 4 models also said about a 124b MoE model and was then rewritten to remove the reference.

I tried running the quantized 12b model and it worked albeit slowly. I think the best way to use it would be to work interactively with gemma4:e4b to come up with a plan, write that to a file and then let the 12b-qat model execute the plan with an agent.

I did also have a quick go at using llama.cpp for serving a model, which was annoying to set up on a Windows machine because of having to use Powershell.

For work I did some research on how to properly sandbox an agent. The `sbx` tool by Docker was binned immediately after finding that it requires you to have a Docker account and to be logged in. The next option to be tested was OpenShell by Nvidia which works pretty well. It starts a VM and blocks all filesystem and network access unless you explicitly allow it using config in a policy file. This can be as fine grained as allowing GET requests with curl but disallowing POST. The only caveat with using it is that you have to run a command to copy the codebase into the sandbox and then run the agent. I havent yet looked deeper if you're supposed to give it read/write access to the code folder on the host. The alternative was to give it permission to write to Github/Gitlab which would mean the changes are isolated into the sandbox and then git pushed onto a branch and reviewed with a pull request.

While testing OpenShell there were references to Nemoclaw so I was reading about that too. I remember when OpenClaw was first released and it was going crazy. NemoClaw seems like a sandbox version of OpenClaw. I wasnt really sure if you were supposed to use that as an agent harness for coding or if it was specifically only for Claws.

I did install Claude and created an account since I've only used local models thus far. It seems fine, I only used the free version. I would want to use Claude + Opus for work since that seems like the best for reasoning/coding right now.

I would also like to try doing some basic training/inference to see how that proccess works. I was reading for example taking the gemma3:270m model which is really basic/dumb and training that on our company documentation so you can ask it questions and it will know the answers.

Next things to try:

- MoE model on 3070 hardware, like qwen3.6:35b-a3b
- Test quantized versions of Gemma4 models to see if they run faster
- Pay for Claude and use that
- Training/inference test
- How to properly use sandbox with agents without manually copying code
