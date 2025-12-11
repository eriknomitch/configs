#!/bin/bash
"$(dirname "$0")/util/play-sound.sh" needs-permission
"$(dirname "$0")/util/notify.sh" -m "Permission required"
