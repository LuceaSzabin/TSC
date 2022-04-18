::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
call run_test.bat 12332 4 
call run_test.bat 54348 7
call run_test.bat 77777 12
call run_test.bat 99489 19
call run_test.bat 22222 5
call run_test.bat 33333 4
call run_test.bat 44444 9
call run_test.bat 55555 3
call run_test.bat 66666 11
call run_test.bat 88888 20
