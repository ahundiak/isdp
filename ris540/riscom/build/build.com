$ ! Do not alter this SPC information: $Revision: 1.1.55.1 $
$! file:	build.com
$!
$	set noverify
$	set proc/name="RIScommon"
$!
$! running in a spawned process from a batch process is slow - priority 3
$! lets boost it to an interactive level (pri=5) to get the stuff done 
$! within a reasonable time. If you don't care how long it takes, then
$! comment out the following 2 lines
$!	set proc/privileges=(altpri)	! alter priority of process 0=lo 16=hi
$!	set proc/priority=5
$!
$	build_dir = f$directory()
$	error_count =  0
$!	@[.--]login
$	if error_count .gt. 0 then goto builderror_exit
$	wr sys$output " "
$	wr sys$output " "
$	on error then goto builderror_exit
$	set def [.-.build]
$	wr sys$output " "
$	wr sys$output "**************** BUILDING RIS *******************"
$	show time
$	wr sys$output " "
$
$	on error then goto build_error
$	wr sys$output " "
$	show time
$	wr sys$output " "
$	set def 'build_dir'
$	@make.vax "ORACLE"
$	goto no_build
$
$build_error:
$	error_count = error_count + 1
$
$no_build:
$
$	if error_count .gt. 0 then goto builderror_exit
$
$	wr sys$output " "
$	wr sys$output "**************** RIS BUILD COMPLETE *******************"
$	set def [.-.build]
$	show time
$	wr sys$output " "
$	exit
$
$builderror_exit:
$	set def 'build_dir'
$	wr sys$output " "
$	wr sys$output "**************** RIS BUILD - ERROR *******************"
$	show time
$	wr sys$output " "
$	exit
$
