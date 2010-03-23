	.seg	"text"
	.global	_trapreturn

_trapreturn:
	set	SP,%o2		! check for stack overflow
	ld	[%o2],%o2
	set	stack+12,%o3
	cmp	%o2,%o3
	bgu	L1		! continue if OK
	nop
	retl			! return zero if not
	mov	0,%i0
L1:
	sub	%o2,12,%o2	! adjust our stack pointer
	set	SP,%o3
	st	%o2,[%o3]
	st	%i7,[%o2+8]	! save caller's return address
	st	%o0,[%o2+4]	! save routine to call
	st	%o1,[%o2]	! save argument to this routine
	set	catch-8,%i7	! arrange for a return to "catch"
	retl			! all done!
	nop

catch:
	save	%sp,-104,%sp
	st	%f0,[%fp-8]	! save potential float return value
	set	SP,%l0
	ld	[%l0],%l1
	ld	[%l1],%o0	! retrieve saved argument
	ld	[%l1+4],%l2	! retrieve routine to call
	ld	[%l1+8],%i7	! restore return address
	add	%l1,12,%l1	! adjust our stack pointer
	st	%l1,[%l0]
	call	%l2,1		! call the catching routine
	nop
	ld	[%fp-8],%f0	! restore potential float return value
	ret
	restore

	.seg	"data"
	.align	4

SP:	.word	Lend
stack:	.skip	400
Lend:
