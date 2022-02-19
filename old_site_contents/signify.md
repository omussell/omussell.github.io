+++
title = "Signify"
date = 2020-01-09

[taxonomies]
tags = ["crypto", "homelab"]
+++

## Signify

Sign and verify files

Generate keys without password (remove -n flag to ask for a password)

```
signify-openbsd -G -p keyname.pub -s keyname.sec -n
```

Sign a file

```
signify-openbsd -S -s keyname.sec -m $file_to_sign -x $signature_file

```

Verify a file

```
signify-openbsd -V -p keyname.pub -m $file_to_verify -x $signature_file
```
