#!/bin/bash

./flutter/bin/flutter packages get || EXIT_CODE=$?
./flutter/bin/flutter pub global activate dart_style || EXIT_CODE=$?

#echo "ANALYZE"
#./flutter/bin/flutter analyze || EXIT_CODE=$?

echo "DART FORMAT CHECK"
.pub-cache/bin/dartfmt -n --set-exit-if-changed . || EXIT_CODE=$?

echo "TEST"
./flutter/bin/flutter test || EXIT_CODE=$?