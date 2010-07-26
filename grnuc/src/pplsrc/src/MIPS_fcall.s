.globl	ret_val			# defined in ciextern.C

 # Build a calling sequence using argument types array, argument
 # sizes, (only used for structs), and args. Call routine specified
 # in fn_addr, return $2 and $f0 in the ret_val struct.
 #---------------------------------------------------------------------------
 # $4 = fn_addr         $7 = arg_sizes         $10 = argsize
 # $5 = num_args        $8 = args              $11 = ndx
 # $6 = arg_types       $9 = framesize         $12 = ptr1
 #---------------------------------------------------------------------------
 #
 # int _ci_call (fn_addr, num_args, arg_types, arg_sizes, args)
 #
 # int  (*fn_addr)();
 # int    num_args;
 # char  *arg_types;
 # short *arg_sizes;
 # char **args;
 # {
 #   int   framesize;
 #   int   argsize;
 #   int   ndx;
 #   int  *ptr1;
 #

.globl	_ci_call
.ent	_ci_call
_ci_call:
	.text
	.align	2
	.frame	$sp,32,$31

	lw	$8,16($sp)
	li	$9,32		# framesize = 32;
	move	$10,$0		# argsize   = 0;
	move	$11,$5		# ndx       = num_args;

	b	$35		# while (ndx--) {
$32:	addu	$3,$6,$11	#   if (arg_types[ndx] == CI_DOUBLE)
	lbu	$2,0($3)
	bne	$2,4,$33
	addu	$10,7		#     argsize = ((argsize + 7) & ~0x7) + 8;
	and	$10,-8
	addu	$10,8
	b	$35
$33:	bne	$2,5,$34	#   else if (arg_types[ndx] == CI_STRUCT) {
	mul     $3,$11,2	#     if (arg_sizes[ndx] > 4)
	addu    $13,$3,$7
	lh      $14,0($13)
	ble	$14,4,$60
	addu	$10,7		#       argsize = ((argsize + 7) & ~0x7);
	and	$10,-8
$60:	addu	$10,$14		#     argsize += arg_sizes[ndx];
	b	$35		#   }
$34:	addu	$10,4		#   else argsize += 4;
$35:	move	$2,$11		# }
	subu	$11,1
	bne	$2,$0,$32

$36:	ble	$10,16,$37	# if (argsize > 16)
	addu	$15,$10,7	#   framesize += ((argsize + 7) & ~0x7);
	and	$15,-8
	addu	$9,$15

$37:	move	$2,$sp		# /* adjust stack pointer */
	subu	$sp,$9
	sw	$31,-4($2)	# /* save return address */
	sw	$gp,-8($2)	# /* save global pointer */
	sw	$16,-12($2)
	move	$16,$2		# /* remember old SP in $16 */

	move	$12,$sp		# ptr1 = <stack pointer>;
	beq	$5,$0,$50	# while (num_args) {
$38:	lbu	$3,0($6)	#   switch (*arg_types) {
	subu	$3,1
	bgeu	$3,5,$48
	sll	$3,2
	lw	$3,$39($3)
	j	$3
	.rdata
$39:	.word	$41
	.word	$42
	.word	$43
	.word	$44
	.word	$45
	.text
$41:	lw	$2,0($8)	#     case CI_CHAR:
	lbu	$3,0($2)	#       *ptr1 = ((char *)*args)[0];
	sw	$3,0($12)
	addu	$12,4		#       ptr1++;
	b	$49		#       break;

$42:    lw      $2,0($8)	#     case CI_SHORT:
        lh      $3,0($2)	#       *ptr1 = ((short *)*args)[0];
        sw      $3,0($12)
        addu    $12,4		#       ptr1++;
        b       $49		#       break;

$43:    lw      $2,0($8)	#     case CI_INT:
        lw	$3,0($2)	#       *ptr1 = ((int *)*args)[0];
        sw      $3,0($12)
        addu    $12,4		#       ptr1++;
        b       $49		#       break;

$44:	addu	$12,7		#     case CI_DOUBLE:
	and	$12,-8		#       ptr1 = (int *)(((int)ptr1 + 7) & ~0x7);
	lw	$2,0($8)	#       *(double *)ptr1 = ((double *)*args)[0];
	l.d	$f4,0($2)
	s.d	$f4,0($12)
	addu	$12,8		#       ptr1 += 2;
	b	$49		#       break;

				#     case CI_STRUCT: {
$45:	lh	$13,0($7)	#       int   cnt = *arg_sizes;
	lw	$14,0($8)	#       char *to, *from = *args;
	ble	$13,4,$61	#       if (cnt > 4)
	addu	$12,7		#         ptr1 = (int *)(((int)ptr1 + 7) & ~0x7);
	and	$12,-8
$61:	move	$15,$12		#       for (to = (char *)ptr1; cnt--; to++, from++)
$46:	move	$2,$13
	subu	$13,1
	beq	$2,$0,$47
	lbu	$3,0($14)	#         *to = *from;
	sb	$3,0($15)
	addu	$14,1
	addu	$15,1
	b	$46
$47:	move	$12,$15		#       ptr1 = (int *)to;
	b	$49		#       break;
				#     }
$48:	move	$2,$0		#     default:
	b	$51		#       return 0;
				#   }

$49:	subu	$5,1		#   num_args--;
	addu	$6,1		#   arg_types++;
	addu	$7,2		#   arg_sizes++;
	addu	$8,4		#   args++;
	bne	$5,$0,$38	# }

$50:	move	$25,$4		# /* load args into registers and call fcn */
	lw	$4,0($sp)
	lw	$5,4($sp)
	lw	$6,8($sp)
	lw	$7,12($sp)
	l.d	$f12,0($sp)
	l.d	$f14,8($sp)
	jal	$25
	lw	$gp,-8($16)	# /* restore global pointer */
	la	$14,ret_val	# /* save return value in ret_val */
	s.d	$f0,0($14)
	sw	$2,8($14)

	li	$2,1		# return 1;
$51:	move	$15,$16		# /* recover stack pointer  */
	lw	$31,-4($15)	# /* restore return address */
	lw	$16,-12($15)	# /* restore register $16   */
	move	$sp,$15		# /* restore stack pointer  */
	j	$31

.end	_ci_call
