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
