# This routine is used to convert a double value to a float. 
# The rounding factor is also supplied.  A zero will imply rounding down 
# and a one will imply rounding up.  Any other value will cause default 
# rounding.
#
#       Arguments:
#
#		f0 - double to convert
#		r1 - rounding mode
#
#               Returns converted float in f0
#
	.file	"OMfloatcvt.s"
	.data
	.globl	_OMfloatcvt
	.data
	.text
_OMfloatcvt:
	movpw	psw,r2			# save psw state
	cmpq	$0,r1
	bceq	.rounddown
	cmpq	$1,r1
	bceq	.roundup
	b	.doit
.rounddown:
	movpw	psw,r0
	ori	$0x00010000,r0
	movwp	r0,psw	
	b	.doit
.roundup:
	movpw	psw,r0
	ori	$0x00008000,r0
	movwp	r0,psw	
	b	.doit
.doit:
	cnvds	f0,f0
	cnvsd	f0,f0
	movwp	r2,psw			# restore psw state
	ret	sp
