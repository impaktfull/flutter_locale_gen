#!/bin/bash

ls -la

flutter packages get || exit -1;
flutter pub global activate dart_style || exit -1;

#echo "ANALYZE"
#flutter analyze || exit -1;

echo "DART FORMAT CHECK"
flutter pub global run dart_style:format -n --set-exit-if-changed . || exit -1;

echo "TEST"
flutter test || exit -1;