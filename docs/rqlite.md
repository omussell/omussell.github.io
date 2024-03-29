# RQLite

SQLite, distributed over many nodes with consensus achieved with the Raft protocol.

```
go get github.com/rqlite/rqlite
cd ~/go/src/github.com/rqlite/rqlite/cmd/rqlite
go get -t -d -v ./...
go build
# You now have the rqlite binary
cd ~/go/src/github.com/rqlite/rqlite/cmd/rqlited
go build
# You now have the rqlited binary
```

Set up the first cluster node:

```
./rqlited ~/node.1
```

Then subsequent cluster nodes:

```
rqlited -http-addr localhost:4003 -raft-addr localhost:4004 -join http://localhost:4001 ~/node.2
```

Presumably you'd have the HTTP address and Raft address to be the same port on different servers, and you'd join to the same master node.

