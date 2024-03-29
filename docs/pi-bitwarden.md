# Running bitwarden_rs on a Raspberry Pi 4

## Summary

We will be setting up bitwarden_rs without Docker, by compiling it manually and then running as a service. In this example we are using SQLite, but you can change this to MySQL or PostgreSQL if you prefer.

## Install dependencies

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh      # Answer Y when prompted
apt install -y build-essential git pkg-config libssl-dev libsqlite3-dev
```

## Clone the repo

```
git clone https://github.com/dani-garcia/bitwarden_rs.git
cd bitwarden_rs
```

## Compile

```
cargo build --features sqlite --release
```

## Admin
After compilation, the built binary will be `./target/release/bitwarden_rs`. This should be moved to `/usr/bin` with `mv ./target/release/bitwarden_rs /usr/bin/bitwarden_rs`

The data directory needs to be created with `mkdir -p /var/lib/bitwarden_rs/data`. This is where the bitwarden keys and database are stored.

Create a user account with `adduser bitwarden_rs`. Make sure the ownership of everything in `/var/lib/bitwarden_rs` is set to the `bitwarden_rs` user.

## Frontend

Download the already built assets: 

```
cd /var/lib/bitwarden_rs
# Amend the version as appropriate
wget https://github.com/dani-garcia/bw_web_builds/releases/download/v2.17.1/bw_web_v2.17.1.tar.gz
```

Extract them

```
tar -xvf bw_web_v2.17.1.tar.gz
```

## Run

Create the systemd service file. Copy the file from [the wiki](https://github.com/dani-garcia/bitwarden_rs/wiki/Setup-as-a-systemd-service). 

