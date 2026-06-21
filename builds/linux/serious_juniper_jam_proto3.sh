#!/bin/sh
printf '\033c\033]0;%s\a' SeriousJuniperJam
base_path="$(dirname "$(realpath "$0")")"
"$base_path/serious_juniper_jam_proto3.x86_64" "$@"
