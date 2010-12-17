$ ! Do not alter this line: $Revision: 1.1.54.1 $
$ if P1 .EQS. "" then goto home
$ if P1 .EQS. "BIN" then goto first
$ if P1 .EQS. "BUILD" then goto first
$ if P1 .EQS. "COMMON" then goto first
$ if P1 .EQS. "DBS" then goto first
$ if P1 .EQS. "DDIFX" then goto first
$ if P1 .EQS. "ERRMSG" then goto first
$ if P1 .EQS. "FUNC" then goto first
$ if P1 .EQS. "INCLUDE" then goto first
$ if P1 .EQS. "INFORMIX" then goto first
$ if P1 .EQS. "LIB" then goto first
$ if P1 .EQS. "PREP" then goto first
$ if P1 .EQS. "PROG" then goto first
$ if P1 .EQS. "REMOTE" then goto first
$ if P1 .EQS. "SERVER" then goto first
$ if P1 .EQS. "TOOLS" then goto first
$ if P1 .EQS. ".." then goto back
$
$ set default [.'P1']
$ exit
$
$ first:
$ set default [.'P1']
$ exit
$
$ home:
$ set default zfc2:[ris]
$ exit
$
$ back:
$ set default [.-]
$ exit
$
