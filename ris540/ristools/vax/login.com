$ ! Do not alter this line: $Revision: 1.1.54.1 $
$ if F$MODE() .EQS. "INTERACTIVE" then goto INTERACTIVE
$ if F$MODE() .EQS. "BATCH"       then goto BATCH
$ if F$MODE() .EQS. "NETWORK"     then goto NETWORK
$ if F$MODE() .EQS. "OTHER"       then goto OTHER
$!
$INTERACTIVE:
$ set term/vt100
$ define TERM_INGRES "vt100f"
$!
$BATCH:
$!
$NETWORK:
$!
$OTHER:
$ !
$ ! SET UP RISTOOLS based as "current.tools"
$ !
$ junk1 := 'f$logical("sys$disk")''f$directory()'
$ junk2  = 'f$locate("]",junk1)
$ junk3 := 'f$extract(0,junk2,junk1)'.tools]
$ junk2  = 'f$locate(".",junk3)
$ assign  'f$extract(0,junk2,junk3)'.tools] ristools
$ !
$ ! SET UP ORACLEHOME from system logical ORACLES/ORA_RDBMSS
$ !     (requires that oracle be running)
$ !
$ junk1 := 'f$logical("oracles")'
$ if junk1 .eqs. "" then goto oracle6
$ junk2  = 'f$locate("]",junk1)'+1
$ assign  'f$extract(0,junk2,junk1)' oraclehome
$ ora_vsn == 51
$ @oraclehome:orauser
$ !
$ goto end_oracle
$ !
$ oracle6:
$ junk1 := 'f$logical("ora_rdbmss")'
$ junk2 = 'f$locate(".RDBMS",junk1)'
$ assign  'f$extract(0,junk2,junk1)'.] oraclehome
$ ora_vsn == 60
$ @'f$logical("oraclehome")'[util]orauser ! set up oracle logicals
$ assign/nolog test  ora_sid             ! set up oracle SID as a convenience
$ !
$ end_oracle:
$ !
$ define SYS$LIBRARY SYS$SYSROOT:[SYSLIB]
$ define C$INCLUDE [.-.internal],[.-.include],[.-.errmsg],[.-.dd],[.-.server],-
[.-.dbms],[.-.dd.prototype],[.-.dbms.prototype],[.-.server.prototype],-
[.-.common.prototype],[.-.network.prototype],[.-.arch.prototype], -
[.-.remote.prototype], ora_proc,pro_dd_inc,sys$library
$ define LNK$LIBRARY SYS$LIBRARY:VAXCRTL,SYS$LIBRARY:SQL$USER.OLB
$ ifxisql == "run INFORMIXBIN:isql"
$ ESQL == "$ZFA0:[IGR.INFORMIX.PRO.BIN]INFXBLD ESQL "
$ ls   == "dir"
$ cat  == "type"
$ striplist == "$ ristools:striplist.exe"
$ Assign	ZFC2:[ris]	RIS_HOME:
$ ed		:== ed/ed/command:RIS_HOME:edt.cmd
$ pwd  == "show default"
$ me   == "edit"
$ rm   == "delete"
$ mv   == "rename"
$ cp   == "copy"
$ cd   == "@ristools:chdir"
$ grep == "@ristools:grp"
$ rmdb == "@ristools:rmdb"
$ rmris == "@ristools:rmris"
$ rmdir == "@ristools:rmdir"
$ make == "@make.vax"
$ @ZFC0:[INGRES.UTILITY]IISYMBOLDEF.COM
$ riset == "@ristools:setris"
$ riset
$ hitesh == "set def [.hitesh]"
