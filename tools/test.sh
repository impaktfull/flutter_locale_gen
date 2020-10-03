#!/bin/bash

flutter test --coverage || exit -1;

cd coverage

ls

coveralls-lcov lcov.info