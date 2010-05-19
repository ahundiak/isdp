DATABASE training12

MAIN
CALL VDSdummy ()
CALL stopctrlz()

OPTIONS MESSAGE LINE 4
message "--------------------------------------------------Press CTRL-W FOR Help-------------------"
DEFER INTERRUPT
CALL show_menu()

END  MAIN


FUNCTION show_menu()
OPTIONS HELP file "menuhelp.ex",
        HELP key control-w

MENU "VDS REPORTS"

       COMMAND "Bill_Of_Material" "Bill of material reports" HELP 1
          CALL bom_menu()

       COMMAND "Weight_Management" "Weight control worksheets" HELP 2
          CALL wgt_menu()

       COMMAND "Compartment" "Compartment reports" HELP 1
          CALL comp_menu()

       COMMAND "Reference_data" "Extract Reference Data" HELP 33
	  CALL refdata_menu()

       COMMAND "Verify_Data" "Design error component reports" HELP 3
          CALL error_menu()

       COMMAND "Design_Data" "Design data reports" HELP 4
          CALL data_menu()

       COMMAND "Specifications" "Application specification reports" HELP 5
          CALL spec_menu()

       COMMAND "Nsts" "Nsts reports" HELP 29
          CALL nsts_menu()

       COMMAND "Type  " "Type a report" HELP 27
          CALL type_func()

       COMMAND "List " "List the reports" HELP 28
          CALL list_func()

       COMMAND "Print " "Print a report" HELP 28
          CALL print_func()

#       COMMAND "FMU " "FMU a report" HELP 28
#          CALL fmu_func()
  END MENU

END FUNCTION

FUNCTION bom_menu()
  OPTIONS MESSAGE LINE 22
  MENU "BOM"
     COMMAND "Beam" "Structural beam bill of material report" HELP 6
       CALL set_rpt_key ("BMB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into BeamBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Struct_Plate" "Structural plate bill of material report" HELP 7
       CALL set_rpt_key ("PLB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PlateBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Piping" "Piping bill of material report" HELP 8
       CALL set_rpt_key ("PPB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Valve_List" "Piping valve list report" HELP 9
       CALL set_rpt_key ("PPV")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeVal.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Hvac" "Hvac bill of material report" HELP 10
       CALL set_rpt_key ("HVB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into HvacBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Rway" "Rway bill of material report" HELP 11
       CALL set_rpt_key ("RWB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into RwayBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Nozzle_Summary" "Nozzle summary report" HELP 12
       CALL set_rpt_key ("NZB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeNoz.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Accessories_Equip" "Equipment bill of material report" HELP 13
       CALL set_rpt_key ("EQB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into EqupBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 15
       EXIT MENU

  END MENU
END FUNCTION

FUNCTION wgt_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Weight"
     COMMAND "Beam" "Structural beam weight control worksheet" HELP 15
       CALL set_rpt_key ("BMW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into BeamWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Struct_Plate" "Structural plate weight control worksheet" HELP 16
       CALL set_rpt_key ("PLW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PlateWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Piping" "Piping weight control worksheet" HELP 17
       CALL set_rpt_key ("PPW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Hvac" "Hvac weight control worksheet" HELP 18
       CALL set_rpt_key ("HVW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into HvacWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Rway" "Raceway weight control worksheet" HELP 19
       CALL set_rpt_key ("RWW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into RwayWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Accessories_Equip" "Equipment weight control worksheet" HELP 20
       CALL set_rpt_key ("EQW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into EqupWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Overall" "Integrated overall weight control worksheet" HELP 21
       CALL set_rpt_key ("OVW")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into OverWgt.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION


FUNCTION error_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Verify_Data"
     COMMAND "Piping" "Piping error component report" HELP 22
       CALL set_rpt_key ("PPE")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeErr.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Hvac" "Hvac error component report" HELP 23
       CALL set_rpt_key ("HVE")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into HvacErr.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Rway" "Raceway error component report" HELP 24
       CALL set_rpt_key ("RWE")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into RwayErr.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION

FUNCTION data_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Design_Data"
     COMMAND "Piping" "Piping design data report" HELP 25
       CALL set_rpt_key ("PPD")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeDat.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION



FUNCTION spec_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Spec"
     COMMAND "Piping" "Piping specification report" HELP 26
#       RUN "isql -rr pipespec.arc"
	RUN "pipespec.sh"
       MESSAGE "Report written into pipespec.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION


FUNCTION nsts_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Nsts"
     COMMAND "Struct_Plate" "Struct_Plate Nsts report" HELP 30
       CALL set_rpt_key ("PLN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PlateNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Beam" "Beam Nsts report" HELP 31
       CALL set_rpt_key ("BMN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into BeamNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Piping" "Piping Nsts report" HELP 32
       CALL set_rpt_key ("PPN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Hvac" "Hvac Nsts report" HELP 35
       CALL set_rpt_key ("HVN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into HvacNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Raceway" "Raceway Nsts report" HELP 36
       CALL set_rpt_key ("RWN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into RwayNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Acc_Equip" "Equipment Nsts report" HELP 37
       CALL set_rpt_key ("EQN")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into EqupNsts.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION

FUNCTION type_func()

  DEFINE rep_name  CHAR(15)
  DEFINE msg       CHAR(50)

  PROMPT  "Give Report File >> " FOR rep_name
  MESSAGE "Listing the report ", rep_name CLIPPED,"   ....Please Wait"
  LET msg = "/usr/bin/pg ", rep_name CLIPPED
  RUN msg
  MESSAGE ""

END FUNCTION

FUNCTION list_func()

  DEFINE rep_name  CHAR(15)
  DEFINE msg       CHAR(50)

  PROMPT  "Give Report File >> " FOR rep_name
  LET msg = "ls -ls ", rep_name CLIPPED
  RUN msg
  SLEEP 4
END FUNCTION

FUNCTION print_func()

  DEFINE rep_name  CHAR(15)
  DEFINE msg       CHAR(50)

  PROMPT  "Give Report File >> " FOR rep_name
  LET msg = "print_file.sh  ", rep_name CLIPPED
  RUN msg
  SLEEP 4
END FUNCTION

FUNCTION fmu_func()

  DEFINE rep_name  CHAR(15)
  DEFINE login     CHAR(80)
  DEFINE msg       CHAR(80)

  PROMPT  "Report File Name >> " FOR rep_name
  PROMPT  "Node.user.passwd >> " FOR login
  LET msg = "fmu  ", login CLIPPED, " send ", rep_name CLIPPED
  RUN msg
  SLEEP 4
END FUNCTION

FUNCTION refdata_menu()
  OPTIONS MESSAGE LINE 22
  MENU "reference Data"
     COMMAND "Refer_Data" "Reference data report" HELP 34
       CALL set_rpt_key ("PPR")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into PipeRef.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION

FUNCTION comp_menu()
  OPTIONS MESSAGE LINE 22
  MENU "Compartment Reports"
     COMMAND "Comp_descr" "Compartment Description report" HELP 14
       CALL set_rpt_key ("CMB")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into CompBom.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Comp_track" "Compartment Tracking report" HELP 14
       CALL set_rpt_key ("CMT")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into CompTrk.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Comp_spaceclass" "Compartment Space class report" HELP 14
       CALL set_rpt_key ("CMC")
       RUN "RPTexec.4ge"
       MESSAGE "Report written into CompSpc.rpt"
       SLEEP 4
       MESSAGE ""
     COMMAND "Exit" "Return to VDS REPORTS menu" HELP 14
       EXIT MENU
  END MENU
END FUNCTION
