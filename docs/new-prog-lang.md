# Finding a New Programming Language

In my journey at work of learning how to program in Python, I've become increasingly annoyed by some of its behaviours.

Initially creating a new project is difficult. Build a virtualenv, activate it, pip install the requirements. Each of these has their own problems. It also ends up making it hard to deploy projects because you need to do these steps wherever you want to use your project.

The performance is poor because its interpreted. If you want to make things faster, you can link to C code, but then you have to write C code.

The package ecosystem is a mess. Packages frequently break or change their dependencies.

New updates happen frequently and bring backwards incompatible changes with them. So you end up with some packages that won't work on newer Python versions, and some packages that only work on new Python versions. You end up stuck in limbo.

Popular libraries like requests and flask are mature but the way you use the libraries are similar to Python 2 era code. Newer libraries like FastAPI are nicer to use, but they arent stable and for some reason use async. So now every project has to decide between mature and old code, or immature and async code.

Types hints are a pain. They arent evaluated unless you use a static checker like mypy or a validator like pydantic. You might put loads of effort into maintaining types but ultimately Python is dynamically typed and mypy will miss things so the types are wrong.

Python seems to work fine for small or short lived projects. But if you want a project to last at least a couple of years, it ends up being painful.

My requirements for a new language are:

- Compiled - Interpreted is inherently slower
- Statically typed - Dynamic typing is great but makes it harder in the long run
- Easy to install packages and pin their version
- Easy to deploy
- Good ecosystem - Web servers, ORM, Database connectors

So far I have tried Go, Rust and even Ada. 

Somehow, I came across Nim, and it fits everything that I want. The syntax is similar enough to Python that it doesnt feel like a chore to learn like the other languages. It also compiles down to a single binary making deployment easy. It uses a C compiler so the resulting binary can be small and compile anywhere that supports C.

The problem is, the ecosystem isnt there yet. Even basic things like, how to write tests, isnt documented clearly. I think it just needs some more popularity which would sort out the low hanging fruit.

For now, I've decided to try Go. I dont like that its got policitical messages on the websites. I also dont like that they enforce CoC to permaban people.

But I dont have much choice. Otherwise I'd have to use something like C# or Java, backed by Microsoft and Oracle, which are just as bad. At least Go compiles quickly.

Go has a lot of stuff baked into the stdlib like DNS, HTTP, crypto, file operations etc. which I think should be a standard nowadays. You can get very far without ever having to import other packages. I tried Go while it was still young and endured the problems with importing dependencies.

I set up Bazel with Gazelle before it was well documented. I used Hugo before it was popular and had lots of themes.

So I think if I were starting a project now I would:
- Use Go
- Have Bazel set up on a remote server and use remote caching to perform quick builds during the develop/debug phase
- Build the final app in Docker
- Deploy to Kubernetes
