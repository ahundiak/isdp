	.seg	".init"
	.global libxc_init
	.global	XC_init

	call	XC_init
	nop
	libxc_init = 0
