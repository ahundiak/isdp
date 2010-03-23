	.globl	Rload
	.ent	Rload
Rload:
	subu	$sp,40
	.frame	$sp, 40, $31
	.mask	0x800001f0, -4
	sw	$31, 36($sp)
	sw	$8, 32($sp)
	sw	$7, 28($sp)
	sw	$6, 24($sp)
	sw	$5, 20($sp)
	sw	$4, 16($sp)
	.fmask	0x0000f000, -28
	s.d	$f14, 8($sp)
	s.d	$f12, 0($sp)
	move	$4, $9
	move	$5, $10
	jal	dload_reactive
	l.d	$f12, 0($sp)
	l.d	$f14, 8($sp)
	lw	$4, 16($sp)
	lw	$5, 20($sp)
	lw	$6, 24($sp)
	lw	$7, 28($sp)
	lw	$8, 36($sp)
	lw	$31, 34($sp)
	addu	$sp, 40
	j	$8
	.end
