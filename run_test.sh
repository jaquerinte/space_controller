#!/bin/bash
rm -rf ./test.log
make clean
echo "Start Test"
echo "Start LA test 1" 
echo "###############################################" >  test.log
echo "Start LA test 1" >>  test.log
make verify-la_test1 >>  test.log
echo "Start LA test 2"
echo "###############################################" >>  test.log
echo "Start LA test 2" >>  test.log
make verify-la_test2 >>  ./test.log
echo "Start LA test 3"
echo "###############################################" >>  test.log
echo "Start LA test 3" >>  test.log
make verify-la_test3 >>  ./test.log
echo "Start LA test 4"
echo "###############################################" >>  test.log
echo "Start LA test 4" >>  test.log
make verify-la_test4 >>  ./test.log
echo "Start LA test 5"
echo "###############################################" >>  test.log
echo "Start LA test 5" >>  test.log
make verify-la_test5 >>  ./test.log
echo "Start LA test 6"
echo "###############################################" >>  test.log
echo "Start LA test 6" >>  test.log
make verify-la_test6 >>  ./test.log
echo "Start LA test 7"
echo "###############################################" >>  test.log
echo "Start LA test 7" >>  test.log
make verify-la_test7 >>  ./test.log
echo "Start LA test 8"
echo "###############################################" >>  test.log
echo "Start LA test 8" >>  test.log
make verify-la_test8 >>  ./test.log
echo "Start LA test 9"
echo "###############################################" >>  test.log
echo "Start LA test 9" >>  test.log
make verify-la_test9 >>  ./test.log
echo "Start LA test 10"
echo "###############################################" >>  test.log
echo "Start LA test 10" >>  test.log
make verify-la_test10 >>  ./test.log
echo "Start LA test 11"
echo "###############################################" >>  test.log
echo "Start LA test 11" >>  test.log
make verify-la_test11 >>  ./test.log
echo "Start WB test 1"
echo "###############################################" >>  test.log
echo "Start WB test 1" >>  test.log
make verify-wb_test1 >>  ./test.log
echo "Start WB test 2"
echo "###############################################" >>  test.log
echo "Start WB test 2" >>  test.log
make verify-wb_test2 >>  ./test.log
echo "Start WB test 3"
echo "###############################################" >>  test.log
echo "Start WB test 3" >>  test.log
make verify-wb_test3 >>  ./test.log
echo "Start WB test 4"
echo "###############################################" >>  test.log
echo "Start WB test 4" >>  test.log
make verify-wb_test4 >>  ./test.log
echo "Start WB test 5"
echo "###############################################" >>  test.log
echo "Start WB test 5" >>  test.log
make verify-wb_test5 >>  ./test.log
echo "Start WB test 6"
echo "###############################################" >>  test.log
echo "Start WB test 6" >>  test.log
make verify-wb_test6 >>  ./test.log
echo "Start WB test 7"
echo "###############################################" >>  test.log
echo "Start WB test 7" >>  test.log
make verify-wb_test7 >>  ./test.log
echo "End Test"