#!/bin/bash

./flutter/bin/flutter packages get
./flutter/bin/flutter pub global activate dart_style

#echo "ANALYZE"
#./flutter/bin/flutter analyze

echo "DART FORMAT CHECK"
.pub-cache/bin/dartfmt -n --set-exit-if-changed .

echo "TEST"
./flutter/bin/flutter test