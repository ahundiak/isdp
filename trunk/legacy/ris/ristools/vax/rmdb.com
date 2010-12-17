$ ! Do not alter this line: $Revision: 1.1.54.1 $
$
$ if P1 .EQS. "" then goto error
$
$ write SYS$OUTPUT "Removing database in [ris.dbs.''P1'_dbs]"
$
$ del [ris.dbs.'P1'_dbs]*.*;*
$ set prot [ris.dbs]'P1'_dbs.dir
$ del [ris.dbs]'P1'_dbs.dir;*
$ exit
$
$ error:
$
$ write SYS$OUTPUT "Usage: rmdb <db_name>"
$
