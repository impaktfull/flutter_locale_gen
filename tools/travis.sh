#!/bin/bash

./flutter/bin/flutter packages get

cd example
./flutter/bin/flutter packages get

cd ..

echo "ANALYZE"
./flutter/bin/flutter analyze

echo "DART FORMAT CHECK"
dartfmt -n --set-exit-if-changed .

echo "TEST"
./flutter/bin/flutter test