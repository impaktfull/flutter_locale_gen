#!/bin/bash

ls -la

./flutter/bin/flutter packages get || exit -1;
./flutter/bin/flutter pub global activate dart_style || exit -1;

#echo "ANALYZE"
#flutter analyze || exit -1;

echo "DART FORMAT CHECK"
./flutter/bin/flutter pub global run dart_style:format -n --set-exit-if-changed . || exit -1;

echo "TEST"
./flutter/bin/flutter test || exit -1;