	.file	"stackalloc.s"
	.text
	.align	2
	.globl	_stackalloc
	.globl	_stackfree
_stackalloc:
	addq	$0xf,r0			# add space needed for saved SP
	andi	$0xfffffff8,r0		# align result to 8-byte multiple
	loadw	0(sp),r1		# get return address off stack
	movw	sp,r2			# remember current SP
	subw	r0,sp			# adjust the stack pointer
	storw	r1,0(sp)		# replace the return address on stack
	storw	r2,4(sp)		# save old SP for stackfree
	loada	12(sp),r0		# get pointer to allocated memory
	ret	sp			# return to caller
_stackfree:
	loadw	0(sp),r1		# get return address off stack
	loadw	-8(r0),sp		# restore the stack pointer
	storw	r1,0(sp)		# replace the return address on stack
	ret	sp			# return to caller
