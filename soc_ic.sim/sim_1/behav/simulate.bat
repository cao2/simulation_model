@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xsim top_behav -key {Behavioral:sim_1:Functional:top} -tclbatch top.tcl -view C:/Users/cao2/Desktop/soci/soci/soc_ic/top_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
