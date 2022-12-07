#!/bin/bash

set -euxo pipefail

flutter pub run build_runner build --delete-conflicting-outputs
