	.file	"slock.s"
	.text
	.align	2
	.globl	_slock
	.globl	_slockw

_slock:
	tsts	0(r0),r0	# test and set lock
	ret	sp		# return lock

_slockw:
	pushw	fp,sp		# save fp for scratch
	movw	r0,fp		# move lock addr to fp
.L1:	tsts	0(fp),r0	# test and set lock
	cmpq	$0,r0		# did we get it?
	bnn	.L2		# branch if yes
	loadq	$1,r0		# wait 1 sec and try again
	call	sp,_sleep
	b	.L1
.L2:	popw	sp,fp		# restore fp
	ret	sp		# return lock
