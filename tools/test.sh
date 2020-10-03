#!/bin/bash

flutter test --coverage || exit -1;

echo "LS BASE"
ls

echo "CD .."
cd ..

echo "LS ROOT PROJECT"

ls
echo "CD COVERAGE"

cd coverage

echo "LS COVERAGE"
ls

coveralls-lcov coverage/lcov.info