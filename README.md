# BlueZ MIDI COPR Builds

Script that checks for BlueZ updates in recent Fedora versions and builds them with MIDI support via COPR.

## What it does

Checks the latest BlueZ versions in Fedora 41, 42, and rawhide. When there's an update, tells COPR to build it with `--enable-midi --enable-experimental`.

## Setup

1. Get COPR API credentials from https://copr.fedorainfracloud.org/api/
2. Set environment variables:
   - `COPR_LOGIN`: Your COPR username  
   - `COPR_TOKEN`: Your COPR API token

## Running

Uses Docker to run the update script in a Fedora container:

```bash
docker build -t bluez-midi-copr .
docker run --env COPR_LOGIN --env COPR_TOKEN bluez-midi-copr
```