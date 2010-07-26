	.file	"CLIP_fcall.s"

	.set	CI_CHAR, 1	# these must match ci_defs.h definitions
	.set	CI_SHORT, 2
	.set	CI_INT, 3
	.set	CI_DOUBLE, 4
	.set	CI_STRUCT, 5

	.globl	_ret_val	# these defined in ci_call.c
	.globl	_align_vals

	.text
	.align	2

# __ci_call(fn_addr, num_args, arg_types, arg_sizes, args)
#
#	Build a calling sequence using argument types array, argument
#	sizes, (only used for structs), and args. Call routine specified
#	in fn_addr, return r0 and f0 in the ret_val struct.

	.globl	__ci_call
__ci_call:
	pushw	fp,sp
	movw	sp,fp
	pushw	r0,sp		# save f_addr for call
	pushw	r11,sp
	pushw	r12,sp		# free some regs for local use
	pushw	r13,sp
	movw	sp,r0
	pushw	r0,sp		# save for popping built-up stack

	subw	$4,sp		# set up stack to be 8-byte aligned

	loada	-1(r1),r13	# nargs - 1
	loadw	16(fp),r12	# args
	b	.FOR_LOOP_TEST
.FOR_LOOP:
	movw	r13,r11
	addw	r11,r11		# create "pointer" index
	addw	r11,r11
	addw	r12,r11
	loadw	(r11),r11	# r11 now has addr of current arg
	loadw	8(fp),r0	# arg_types
	addw	r13,r0
	loadb	(r0),r0		# r0 has current arg type
	loada	_align_vals,r1	# pickup stack alignment for this arg
	loadw	(r1),r1		# the "align_vals" array set in "ci_call"
	addw	r13,r1
	loadb	(r1),r1
	subw	r1,sp
.ARGTYP_SWITCH:
	cmpi	$CI_CHAR,r0
	bcgt	.BAD_CASE
	cmpi	$CI_STRUCT,r0
	bclt	.BAD_CASE
	subw	$1,r0
	addw	r0,r0
	loadh	.BR_TAB(r0),r5
.BR_ADDR:
	b	[r5](pc)
.BR_TAB:
	.word	.CHAR_CASE-.BR_ADDR
	.word	.SHORT_CASE-.BR_ADDR
	.word	.INT_CASE-.BR_ADDR
	.word	.DOUBLE_CASE-.BR_ADDR
	.word	.STRUCT_CASE-.BR_ADDR
.CHAR_CASE:
	loadb	(r11),r0
	b	.GEN_REG_CMN
.UCHAR_CASE:
	loadbu	(r11),r0
	b	.GEN_REG_CMN
.SHORT_CASE:
	loadh	(r11),r0
	b	.GEN_REG_CMN
.USHORT_CASE:
	loadhu	(r11),r0
	b	.GEN_REG_CMN
.INT_CASE:
.LONG_CASE:
.UINT_CASE:
.ULONG_CASE:
.PTR_CASE:
	loadw	(r11),r0
	b	.GEN_REG_CMN
.FLOAT_CASE:
	loads	(r11),f0
	cnvsd	f0,f0
	b	.FLT_REG_CMN
.DOUBLE_CASE:
	loadd	(r11),f0
	b	.FLT_REG_CMN
.STRUCT_CASE:
	loadw	12(fp),r0		# get arg_sizes
	movw	r13,r1
	addw	r1,r1			# create short index
	addw	r1,r0
	loadh	(r0),r0			# r0 contains struct size
	movw	r11,r1
	subw	r0,sp
	movw	sp,r2
	movc				# transfer struct onto stack
	b	.DECR_COUNTER
.BAD_CASE:
	movw	$0,r0
	b	.EXIT

.GEN_REG_CMN:
	cmpi	$1,r13			# should this be a register parameter?
	bcge	.IS_GEN_REG_PARM
	pushw	r0,sp			# parameter number >1, push on stack
	b	.DECR_COUNTER
.IS_GEN_REG_PARM:
	cmpi	$1,r13
	bcgt	.DECR_COUNTER
	storw	r0,sav_r1
	b	.DECR_COUNTER
.FLT_REG_CMN:
	cmpi	$1,r13			# should this be a register parameter?
	bcge	.IS_FLT_REG_PARM
	subi	$8,sp
	stord	f0,(sp)			# parameter number >1, push on stack
	b	.DECR_COUNTER
.IS_FLT_REG_PARM:
	cmpi	$1,r13
	bcgt	.DECR_COUNTER
	movd	f0,f1
#	b	.DECR_COUNTER

.DECR_COUNTER:
	subw	$1,r13
.FOR_LOOP_TEST:
	cmpi	$0,r13
	bcle	.FOR_LOOP

.MAKE_CALL:
	loadw	-4(fp),r11		# retrieve saved function addr
	loadw	sav_r1,r1		# get saved argument 1
	call	sp,(r11)
	loada	_ret_val,r11		# set up return value struct
	stord	f0,(r11)
	storw	r0,8(r11)
	loada	_ret_val,r0
.EXIT:
	loadw	-20(fp),sp		# get value of sp before call buildup
	popw	sp,r13
	popw	sp,r12
	popw	sp,r11
	popw	sp,r1			# don't bother r0, we've already set it
	popw	sp,fp
	ret	sp
	.data

	.data

	.align	4
sav_r1:	.long 0				# temporary storage for r1 parameter

			
#_i	r13	local
#_f_addr	r0	local
#_nargs	r1	local
#_arg_types	8(fp)	local
#_arg_sizes	12(fp)	local
#_args		16(fp)	local
	.text
	.data

