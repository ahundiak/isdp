	.section	.init
	.globl	libxc_init
	.globl	XC_init

	call	XC_init
	nop
	libxc_init = 0
