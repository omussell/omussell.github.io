+++
title = "Building Go with Bazel"
date = 2020-01-07

[taxonomies]
tags = ["programming", "homelab"]
+++

## Handling Go Dependencies

During development, you will often use `go get` to download libraries for import into the program which is useful for development but not so useful when building the finished product. Managing these dependencies over time is a hassle as they change frequently and can sometimes disappear entirely.

The `dep` tool provides a way of automatically scanning your import statements and evaluating all of the dependencies. It create some files `Gopkg.toml` and `Gopkg.lock` which contain the location and latest Git SHA of your dependencies.

`dep` is installed via:

```
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

Run `dep init` to create the initial files, then as your develop run `dep ensure` to update dependencies to the latest version.

The `dep` tool also downloads a copy of all dependencies into a `vendor` folder at the root of your project. This provides a backup in case a dependency disappears and provides the facility for reproducible builds.


### Bazel / Gazelle

With our dependencies being updated, we would also need to update the WORKSPACE file so that Bazel/Gazelle knows about them as well. Gazelle requires the location and git commit hash in order to pull down the correct dependencies, but this is laborious to update manually.

Thankfully, we can run a command to have gazelle pull in all of the dependencies from the `Gopkg.lock` file and update the WORKSPACE file automatically. Bazel will then pull in all of the dependencies correctly without any manual intervention.

`gazelle update-repos -from_file Gopkg.lock`

As part of ongoing development, you would periodically run

`dep ensure` 

followed by

`gazelle update-repos -from_file Gopkg.lock`

to keep all of the dependencies up to date and generate the new WORKSPACE file.

## Packaging Go Applications

Now that we've built the go application and its dependencies we now need to package it up to distribute across the infrastructure.


### Packaging with fpm

The below command is an example of what we would want to run:


`fpm -s dir -t freebsd -n ~/go_test --version 1.0.0 --prefix /usr/local/bin go_tests`

But this has a few issues. Rather than putting the finished package into `~/go_test`, it would be better in a dedicated directory like `/var/packages` or similar. The version number is hard coded which obviously isn't always going to be correct. You would want to instead have your CI tool set to only run the packaging command when a new tag/release is created, and then have the version number derived from the tag/release number. It also includes the `--prefix` flag to specify the path to prepend to any files in the package. This is required as when the package is installed/extracted, the files will be extracted to the full path as specified in the package. So in this instance the `/usr/local/bin/go_tests` file is extracted.


For now, I'm getting by with the following command which will overwrite the finished package if it already exists.

`fpm -f -s dir -t freebsd -n ~/go_test --prefix /usr/local/bin go_tests`


## Building Go programs using Bazel

Bazel is a build tool created by Google which operates similarly to their internal build tool, Blaze. It is primarily concerned with generating artifacts from compiled languages like C, C++, Go etc. 

`pkg install -y bazel`

Bazel requires some files so that it knows what and where to build. As an example, we are going to compile a simple go program with no dependencies (literally print a single string to stdout).

```
// ~/go/src/github.com/omussell/go_tests/main.go

package main

import "fmt"

func main() {
	fmt.Println("test")
}
```

A file called WORKSPACE should be created at the root of the directory. This is used by bazel to determine source code locations relative to the WORKSPACE file and differentiate other packages in the same directory. Then a BUILD.bazel file should also be created at the root of the directory. 




### Gazelle

Instead of creating BUILD files by hand, we can use the Gazelle tool to iterate over a go source tree and dynamically generate BUILD files. We can also let bazel itself run gazelle.

Note that gazelle doesn't work without bash, and the gazelle.bash file has a hardcoded path to `/bin/bash` which of course is not available on FreeBSD by default.

```
pkg install -y bash
ln -s /usr/local/bin/bash /bin/bash
```

In the WORKSPACE file:

```
http_archive(
    name = "io_bazel_rules_go",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.9.0/rules_go-0.9.0.tar.gz",
    sha256 = "4d8d6244320dd751590f9100cf39fd7a4b75cd901e1f3ffdfd6f048328883695",
)
http_archive(
    name = "bazel_gazelle",
    url = "https://github.com/bazelbuild/bazel-gazelle/releases/download/0.9/bazel-gazelle-0.9.tar.gz",
    sha256 = "0103991d994db55b3b5d7b06336f8ae355739635e0c2379dea16b8213ea5a223",
)
load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")
go_rules_dependencies()
go_register_toolchains(go_version="host")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()
```

In the BUILD.bazel file:

```
load("@bazel_gazelle//:def.bzl", "gazelle")

gazelle(
    name = "gazelle",
    prefix = "github.com/omussell/go_tests",
)
```

Then to run:

```
bazel run //:gazelle
bazel build //:go_tests
```

A built binary should be output to the ~/.cache directory. Once a binary has been built once, Bazel will only build again if the source code changes. Otherwise, any subsequent runs just complete successfully extremely quickly.

When attempting to use bazel in any capacity like `bazel run ...` or `bazel build ...` it would give the following error:

```
ERROR: /root/.cache/bazel/_bazel_root/...285a1776/external/io_bazel_rules_go/
BUILD.bazel:7:1: every rule of type go_context_data implicitly depends upon the target '@go_sdk//
:packages.txt', but this target could not be found because of: no such package '@go_sdk//': 
Unsupported operating system: freebsd
ERROR: /root/.cache/bazel/_bazel_root/...1776/external/io_bazel_rules_go/
BUILD.bazel:7:1: every rule of type go_context_data implicitly depends upon the target '@go_sdk//
:files', but this target could not be found because of: no such package '@go_sdk//': 
Unsupported operating system: freebsd
ERROR: /root/.cache/bazel/_bazel_root/...5a1776/external/io_bazel_rules_go/
BUILD.bazel:7:1: every rule of type go_context_data implicitly depends upon the target '@go_sdk//
:tools', but this target could not be found because of: no such package '@go_sdk//': 
Unsupported operating system: freebsd
ERROR: Analysis of target '//:gazelle' failed; build aborted: no such package '@go_sdk//': 
Unsupported operating system: freebsd
```

I think this is caused by bazel attempting to download and build go which isn't necessary as we've already installed via the package anyway. In the WORKSPACE file, change the `go_register_toolchains()` line to 

```
go_register_toolchains(go_version="host")
``` 

as documented at:

```
https://github.com/bazelbuild/rules_go/blob/master/go/toolchains.rst#using-the-installed-go-sdk.
```

This will force bazel to use the already installed go tools.

## CI with Buildbot


Example buildbot config:

```
factory.addStep(steps.Git(repourl='git://github.com/omussell/go_tests.git', mode='incremental'))
factory.addStep(steps.ShellCommand(command=["go", "fix"],))
factory.addStep(steps.ShellCommand(command=["go", "vet"],))
factory.addStep(steps.ShellCommand(command=["go", "fmt"],))
factory.addStep(steps.ShellCommand(command=["bazel", "run", "//:gazelle"],))
factory.addStep(steps.ShellCommand(command=["bazel", "build", "//:go_tests"],))
```

I needed to rebuild the buildbot jail because it was borked, and after rebuilding it I was surprised that bazel worked without any more configuration. I just needed to install the git, go and bazel packages and run the buildbot config as described above and it ran through and rebuilt everything from scratch. This is one of the major advantages of keeping the build files (WORKSPACE and BUILD.bazel) alongside the source code. I am sure that if desired, anyone with a bazel setup would be able to build this code as well and the outputs would be identical.


### Adding dependencies

In order to have Bazel automatically build dependencies we need to make a some changes to the WORKSPACE file. I've extended the example program to pull in a library that generates fake data and prints a random name when invoked.


```
package main

import "github.com/brianvoe/gofakeit"
import "fmt"

func main() {
        gofakeit.Seed(0)
        fmt.Println(gofakeit.Name())
        //      fmt.Println("test")
}
```

The following needs to be appended to the WORKSPACE file:

```
load("@io_bazel_rules_go//go:def.bzl", "go_repository")

go_repository(
    name = "com_github_brianvoe_gofakeit",
    importpath = "github.com/brianvoe/gofakeit",
    commit = "b0b2ecfdf447299dd6bcdef91001692fc349ce4c",
)
```

The go_repository rule is used when a dependency is required that does not have a BUILD.bzl file in their repo.

## Bazel Remote Cache

When building with Bazel, by default you are connecting to a local Bazel server which runs the build. If multiple people are running the same builds, you are all independently having to build the whole thing from scratch every time. 

With a Remote Cache, some other storage service can cache parts of the build and artifacts which can then be reused by multiple people. 
This can be a plain HTTP server like NGINX or Google Cloud Storage.

```
mkdir -p /var/cache/nginx
chmod 777 /var/cache/nginx

# nginx config:
location / {
    root /var/cache/nginx;
    dav_methods PUT;
    create_full_put_path on;
    client_max_body_size 1G;
    allow all;
}
```

Then when running the Bazel build, add the `--remote_cache=http://$ip:$port` flag to the build parameter like `bazel build --remote_cache=http://192.168.1.10:80 //...`

