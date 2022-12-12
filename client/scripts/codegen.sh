#!/bin/bash

set -euxo pipefail

flutter pub run build_runner build --delete-conflicting-outputs
# This errors with:
#Unhandled exception:
#FileSystemException: Directory listing failed, path = '/Users/zen/repos/banananator/client/.dart_tool/pub/bin/assets/' (OS Error: No such file or directory, errno = 2)
#Instance of '_StringStackTrace'pub finished with exit code 255
# Fixing this will bundle the emojis from `twemoji.includes` in `pubspec.yaml` instead
# of downloading them
#flutter pub run twemoji:include_emojis