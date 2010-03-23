	.file	"trapreturn.s"
	.text
	.align	2
	.globl	_trapreturn

_trapreturn:
	loadw	SP,r2			#check for stack overflow
	loada	stack+12,r3
	cmpw	r2,r3
	bcgt	.L1			#continue if OK
	loadi	$0,r0			#return zero if not
	ret	sp
.L1:
	loadw	4(fp),r3		#get routine's current return address
	pushw	r3,r2			#push this onto our stack
	pushw	r0,r2			#push on the routine to call
	pushw	r1,r2			#push on argument to this routine
	storw	r2,SP
	loada	catch,r1		#arrange for a return to "catch"
	storw	r1,4(fp)
	ret	sp			#all done!

catch:
	subq	$12,sp			#save return value from caught routine
	stord	f0,4(sp)
	pushw	r0,sp
	loadw	SP,r2
	popw	r2,r0			#pop saved argument into r0
	popw	r2,r1			#pop routine to call into r1
	storw	r2,SP
	call	sp,0(r1)		#call the catching routine
	popw	sp,r0			#restore the return values saved before
	loadd	4(sp),f0
	addq	$12,sp
	loadw	SP,r2			#get original return address
	popw	r2,r1
	storw	r2,SP
	b	0(r1)			#now go there!

	.data
	.align	8
SP:	.long	.end
stack:	.space	400
.end:
