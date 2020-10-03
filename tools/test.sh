#!/bin/bash

flutter test --coverage || exit -1;

coveralls-lcov ../coverage/lcov.info