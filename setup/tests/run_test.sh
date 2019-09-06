#!/bin/bash
for test_file in `find . -name '*.py'`; do
    echo $test_file tests is running.
    python $test_file
done