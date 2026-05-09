#!/bin/bash

CURRENT=`pwd`
DIR_NAME=`basename "$CURRENT"`
if [ $DIR_NAME == 'tool' ]
then
  cd ..
fi

cd example_dart
dart run locale_gen
cd ..

cd example_flutter
dart run locale_gen
cd ..
