	.file	"Rload.s"
	.text
	.align	2

	.globl	Rload
Rload:
	pushw	r0,sp
	pushw	r1,sp
	subi	$16,sp
	stord	f0,8(sp)
	stord	f1,0(sp)
	movw	r2,r0
	movw	r3,r1
	call	sp,_EX_reactive_load
	loadd	0(sp),f1
	loadd	8(sp),f0
	addi	$16,sp
	popw	sp,r1
	popw	sp,r0
	ret	sp
