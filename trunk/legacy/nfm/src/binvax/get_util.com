$ !
$ !	INTERGRAPH/VAX Delivery Procedures
$ !
$	PRODUCT_ID := I_NFM 3.0.0/VAX
$ !
$ ! The  information  in this document  is subject to change without
$ ! notice and should not be construed as a commitment by INTERGRAPH
$ ! corporation.
$ !
$ ! Date:		    15-JAN-1992
$ ! Calling Seq:	@GET_UTIL
$ ! Change History:
$ !
$ ! PARSE PRODUCT FILENAME AND PRODUCT NAME
$ !
$	POS = 'F$LOCATE(" ",PRODUCT_ID)'
$	PRODNAME := 'F$EXTRACT(0,POS,PRODUCT_ID)'
$ !
$ ! DIRECTORIES FOR PRO_ AND WRK_
$ !
$	PRODIR := ""
$	WRKDIR := ""
$	SYDISK := 'F$LOGICAL("SYS$DISK")'
$	DEFDIR := 'F$DIRECTORY()'
$	LEN = 'F$LENGTH(DEFDIR)'
$	POS = 'F$LOCATE(".",DEFDIR)'
$	IF POS .LT. LEN THEN GOTO DIRS
$	IF POS .GT. 4 THEN POS=4
$	POS1 = POS+1
$	    PRODIR := 'SYDISK''F$EXTRACT(0,POS,DEFDIR)','F$EXTRACT(POS1,4,DEFDIR)'
$	    WRKDIR := 'SYDISK''F$EXTRACT(0,POS,DEFDIR)','F$EXTRACT(POS1,4,DEFDIR)'
$	    GOTO DDIRX
$DIRS:
$	    TEMP := 'F$EXTRACT(0,POS,DEFDIR)'
$	    POS = POS + 1
$	    JUNK := 'F$EXTRACT(POS,LEN,DEFDIR)'
$	    POS = 'F$LOCATE(".",JUNK)'
$	    JUNK := 'F$EXTRACT(0,POS,JUNK)'
$	    IF JUNK .NES. "''PRODNAME'" THEN GOTO DDIRX
$		PRODIR := 'SYDISK''DEFDIR'
$		WRKDIR := 'SYDISK''DEFDIR'
$ddirx:
$ !
$ !
$ !
$ on control_y then goto exit
$ !
$ ! Make sure that we are in the NFM product directory
$ !
$ NFM_DIR := [IGR.I_NFM.PRO]
$ cur_dir := 'f$directory()'
$ if cur_dir .eqs. NFM_DIR then goto dir_ok
$ write sys$output "Must Execute From ", NFM_DIR
$ goto exit
$ !
$dir_ok:
$ !
$ ! Find node_name of I/NFM server node
$ ! If Set Verify is on, turn it off
$ !
$ vfy := 'f$verify()'
$ set noverify
$ read sys$command/prompt="Enter I/NFM Server name : " server
$ nfmserver = "nfms_"'server'
$ assign igr$scratch:nfm.tmp sys$output
$ clh -p nodename -l nfmserver
$ u_status = $status
$ deassign sys$output
$ open/read node_file igr$scratch:nfm.tmp
$ read/end_of_file=no_node node_file node_name
$ close node_file
$ !
$ ! Find operating system of I/NFM server
$ !
$ assign igr$scratch:nfm.tmp sys$output
$ clh -p NETMAP_info -l 'node_name'
$ deassign sys$output
$ nvfy := 'f$verify(vfy)'
$ open/read node_file igr$scratch:nfm.tmp
$ read/end_of_file=no_node node_file map_info
$ op_sys := 'f$extract(1, 1, map_info)'
$ close node_file
$ !
$ ! Get the password for the I/NFM server node
$ !
$ set term/noecho
$ read sys$command/prompt="Enter password for the nfmadmin account on I/NFM server : " passwd
$ set term/echo
$ if passwd .nes. "" then password = "."'passwd'
$ !
$ ! Assign the appropriate utility file name
$ !
$unix:
$ file_name := "/usr/ip32/nfm/bin/VAXutil"
$ goto get_file
$get_file:
$ !
$ ! Receive the NFMutil file
$ !
$ fmu -v 'nfmserver'.nfmadmin'password' rec "''file_name'" []Nfmutil.exe
$ fmu_stat = $status
$ if .not. (fmu_stat) then goto connect
$ !
$ ! Create ASSIGNS.COM and startup file
$ !
$ open/write assigns_file assigns.com
$ write assigns_file "$ !"
$ write assigns_file "$ !  ASSIGNS.COM -- ", PRODUCT_ID
$ write assigns_file "$ !   CREATED ''f$time()'"
$ write assigns_file "$ !"
$ write assigns_file "$ ASSIGN/SYSTEM ''PRODIR' PRO_DD_NFM"
$ write assigns_file "$ ASSIGN/SYSTEM ''WRKDIR' WRK_DD_NFM"
$ write assigns_file "$ !"
$ close assigns_file
$ !
$	STU := "N"
$	OPEN/READ/ERR=NOSTU  STUFIL  'PRODNAME'.STU
$	CLOSE  STUFIL
$	STU := "Y"
$NOSTU:
$	OPEN/WRITE STRFIL 'PRODNAME'.STU
$	WRITE STRFIL "$ !"
$	WRITE STRFIL "$ !  ''PRODNAME'  STARTUP FILE"
$	WRITE STRFIL "$ !"
$	WRITE STRFIL "$ HDEF := 'F$ENVIRONMENT (""DEFAULT"")'"
$	WRITE STRFIL "$ SET DEF ''PRODIR'"
$	WRITE STRFIL "$ @ASSIGNS"
$	WRITE STRFIL "$ SET DEF 'HDEF'"
$	WRITE STRFIL "$ !"
$	CLOSE STRFIL
$ !
$ ! Copy .STU file to pro_dd_startup
$ !
$       COPY 'PRODNAME'.STU PRO_DD_STARTUP
$ @assigns
$ !
$ write sys$output ""
$ write sys$output "Successful Installation of NFMUTIL.EXE !"
$ goto done
$no_node:
$ write sys$output "Cannot Get I/NFM server Node"
$ goto done
$connect:
$ write sys$output "Cannot Connect To or Receive From I/NFM server"
$ goto done
$done:
$ del igr$scratch:nfm.tmp;*
$ nvfy := 'f$verify(vfy)'
$exit:
$ exit
