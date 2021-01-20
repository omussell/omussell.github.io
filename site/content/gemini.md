+++
title = "Gemini Protocol"
date = 2021-01-20

[taxonomies]
tags = ["homelab"]
+++

[Project Gemini](https://gemini.circumlunar.space/)

```
Gemini is a new, collaboratively designed internet protocol, which explores the space inbetween gopher and the web, striving to address (perceived) limitations of one while avoiding the (undeniable) pitfalls of the other.
```

For the server I'm using [satellite](https://git.sr.ht/~gsthnz/satellite).

```
git clone https://git.sr.ht/~gsthnz/satellite
cd satellite
go build
mkdir -p /var/lib/satellite/certs
```

Create satellite.toml

```
# Address to listen to requests (default: 0.0.0.0:1965)
#listen = "0.0.0.0"

[tls]
# Directory to save certificates
directory = "/var/lib/satellite/certs"

# Multiple domains can be set with the [[domain]] section
[[domain]]
name = "gemini.matrix"
root = "/srv/gemini/gemini.matrix"
```

For the client I'm using [bombadillo](https://bombadillo.colorfield.space/)

```
git clone https://tildegit.org/sloum/bombadillo
cd bombadillo
sudo make install
bombadillo
```

You will need to create a directory with some static files inside. These files should have a file extension of `.gmi` or `.gemini`. The content is structured like a subset of markdown:

```
# Normal text
Hello World!

# Link
=> gemini://example.org/ An Example Link

# Preformatted text
# ```
preformatted text surrounded by 3 backticks
# ```

# Headers using #
# Title
## Sub Title
### Sub Sub Title

# Unordered list
* No
* Particular
* Order

# Quote lines
> This is a good quote

```


