/*

Name
  smoption.t

Description
  State table for Usage: mess [-p <platform>] [-n <n>|-k <key>|-l <literal>|-i <literal>] -l <literal> Searches for message info by literal string -i <literal> Same as -l except not case sensitive command

Notes


 */
command_string  GRC_M_SSOptions,0,GRSmSk
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "smopt.cmd"

state_table

state start
   execute SSOptions(sts)
   on ELSE                                             state terminate
