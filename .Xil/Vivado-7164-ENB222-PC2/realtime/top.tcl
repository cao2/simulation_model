# 
# Synthesis run script generated by Vivado
# 

namespace eval rt {
    variable rc
}
set rt::rc [catch {
  uplevel #0 {
    set ::env(BUILTIN_SYNTH) true
    source $::env(HRT_TCL_PATH)/rtSynthPrep.tcl
    rt::HARTNDb_resetJobStats
    rt::HARTNDb_resetSystemStats
    rt::HARTNDb_startSystemStats
    rt::HARTNDb_startJobStats
    set rt::cmdEcho 0
    rt::set_parameter writeXmsg true
    rt::set_parameter enableParallelHelperSpawn true
    set ::env(RT_TMP) "C:/Users/cao2/Desktop/soci/soci/soc_ic/.Xil/Vivado-7164-ENB222-PC2/realtime/tmp"
    if { [ info exists ::env(RT_TMP) ] } {
      file delete -force $::env(RT_TMP)
      file mkdir $::env(RT_TMP)
    }

    rt::delete_design

    set rt::partid xc7k325tffg900-2

    set rt::multiChipSynthesisFlow false
    source $::env(SYNTH_COMMON)/common_vhdl.tcl
    set rt::defaultWorkLibName xil_defaultlib

    set rt::useElabCache false
    if {$rt::useElabCache == false} {
      rt::read_vhdl -lib xil_defaultlib {
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/defs.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/arbiter2.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/arbiter2_ack.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/arbiter6.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/arbiter6_ack.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/arbiter7.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/b_arbiter2.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/b_arbiter6.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/b_fifo.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/bmsg_fifo_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/util.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/fifo.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/cache.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/test.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/cache_req_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/soci/soci/soc_rnd/soc_rnd.srcs/sources_1/imports/soc/rndgen.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/soci/soci/soc_rnd/soc_rnd.srcs/sources_1/imports/2017paper/cpu_test.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/uart/fifo.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/fifo_snp.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/toper_chan_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/per_upreq_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/msg_fifo_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/per_write_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/wb_m.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/oven/soc/ic.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/new/real_mem.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/mem.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Downloads/uart/uart/mod_m_counter.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/AppData/Roaming/Xilinx/Vivado/peripharals/peripharals.srcs/sources_1/imports/2017paper/peripheral.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/proc.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/pwr.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Downloads/uart/uart/uart_rx.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Downloads/uart/uart/uart_tx.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Downloads/uart/uart/uart.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Downloads/uart/uart/project_1/project_1.srcs/sources_1/new/uart_wrapper.vhd
      C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/sources_1/imports/cao2/Desktop/2017paper/top.vhd
    }
      rt::filesetChecksum
    }
    rt::set_parameter usePostFindUniquification false
    set rt::top top
    set rt::reportTiming false
    rt::set_parameter elaborateOnly true
    rt::set_parameter elaborateRtl true
    rt::set_parameter eliminateRedundantBitOperator false
    rt::set_parameter writeBlackboxInterface true
    rt::set_parameter merge_flipflops true
    rt::set_parameter srlDepthThreshold 3
    rt::set_parameter rstSrlDepthThreshold 4
# MODE: 
    rt::set_parameter webTalkPath {}
    rt::set_parameter enableSplitFlowPath "C:/Users/cao2/Desktop/soci/soci/soc_ic/.Xil/Vivado-7164-ENB222-PC2/"
    set ok_to_delete_rt_tmp true 
    if { [rt::get_parameter parallelDebug] } { 
       set ok_to_delete_rt_tmp false 
    } 
    if {$rt::useElabCache == false} {
        set oldMIITMVal [rt::get_parameter maxInputIncreaseToMerge]; rt::set_parameter maxInputIncreaseToMerge 1000
        set oldCDPCRL [rt::get_parameter createDfgPartConstrRecurLimit]; rt::set_parameter createDfgPartConstrRecurLimit 1
      rt::run_rtlelab -module $rt::top
        rt::set_parameter maxInputIncreaseToMerge $oldMIITMVal
        rt::set_parameter createDfgPartConstrRecurLimit $oldCDPCRL
    }

    set rt::flowresult [ source $::env(SYNTH_COMMON)/flow.tcl ]
    rt::HARTNDb_stopJobStats
    if { $rt::flowresult == 1 } { return -code error }

    if { [ info exists ::env(RT_TMP) ] } {
      if { [info exists ok_to_delete_rt_tmp] && $ok_to_delete_rt_tmp } { 
        file delete -force $::env(RT_TMP)
      }
    }


  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] && [info exists rt::doParallel] && $rt::doParallel} { 
     $rt::db killSynthHelper $hsKey
  } 
  rt::set_parameter helper_shm_key "" 
    source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  } ; #end uplevel
} rt::result]

if { $rt::rc } {
  $rt::db resetHdlParse
  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] && [info exists rt::doParallel] && $rt::doParallel} { 
     $rt::db killSynthHelper $hsKey
  } 
  source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  return -code "error" $rt::result
}
