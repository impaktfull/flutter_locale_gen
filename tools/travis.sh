#!/bin/bash

./flutter/bin/flutter packages get || { echo 'my_command failed' ; exit -1; }
./flutter/bin/flutter pub global activate dart_style || { echo 'my_command failed' ; exit -1; }

#echo "ANALYZE"
#./flutter/bin/flutter analyze || { echo 'my_command failed' ; exit -1; }

echo "DART FORMAT CHECK"
./.pub-cache/bin/dartfmt -n --set-exit-if-changed .  || { echo 'my_command failed' ; exit -1; }

echo "TEST"
./flutter/bin/flutter test || { echo 'my_command failed' ; exit -1; }