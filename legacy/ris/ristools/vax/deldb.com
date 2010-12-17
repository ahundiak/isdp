$ ! Do not alter this line: $Revision: 1.1.54.1 $
$
$ if P1 .EQS. "" then goto error
$
$ write SYS$OUTPUT "Removing database ''P1'"
$
$ del [.'P1'_dbs]*.*;*
$ set prot 'P1'_dbs.dir
$ del 'P1'_dbs.dir;*
$ exit
$
$ error:
$
$ write SYS$OUTPUT "Usage: deldb <db_name>"
$
