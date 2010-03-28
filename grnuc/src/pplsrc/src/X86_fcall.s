	CI_CHAR = 1
	CI_SHORT = 2
	CI_INT = 3
	CI_DOUBLE = 4
	CI_STRUCT = 5

	.globl	ret_val		/ defined in ciextern.C

/ Build a calling sequence using argument types array, argument
/ sizes, (only used for structs), and args. Call routine specified
/ in fn_addr, return %eax and %st(0) in the ret_val struct.
/---------------------------------------------------------------------------
/  8(%ebp) = fn_addr     20(%ebp) = arg_sizes   -8(%ebp) = cnt     %ecx = SP
/ 12(%ebp) = num_args    24(%ebp) = args       -12(%ebp) = ptr1
/ 16(%ebp) = arg_types   -4(%ebp) = ndx        -16(%ebp) = ptr2
/---------------------------------------------------------------------------
/
/ int _ci_call (fn_addr, num_args, arg_types, arg_sizes, args)
/ 
/ int  (*fn_addr)();
/ int    num_args;
/ char  *arg_types;
/ short *arg_sizes;
/ char **args;
/ {
/   int   ndx, *ptr1;
/   char *SP, *ptr2;
/   short FTOS;
/
	.text
	.globl	_ci_call
_ci_call:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	movl	%esp,%ecx		/ SP = <stack pointer>;
	movl	12(%ebp),%edx		/ ndx = num_args;

	movl	%edx,%eax		/ while (ndx--) {
	movl	%eax,%esi		/
	decl	%eax			/
	andl	%esi,%esi		/
	je	.L2			/
	movl	16(%ebp),%esi
	movl	20(%ebp),%edi
.L3:
	movb	(%esi,%eax),%bl		/   if (arg_types[ndx] == CI_DOUBLE) {
	cmpb	$CI_DOUBLE,%bl		/
	jne	.L4			/
	addl	$-8,%ecx		/     SP -= 8;
	jmp	.L5			/   }
	.align	4
.L4:
	cmpb	$CI_STRUCT,%bl		/   else if (arg_types[ndx] == CI_STRUCT) {
	jne	.L6			/
	movswl	(%edi,%eax,2),%ebx	/     SP -= arg_sizes[ndx];
	subl	%ebx,%ecx		/
	jmp	.L5			/   }
	.align	4
.L6:
	addl	$-4,%ecx		/   else SP -= 4;
.L5:
	movl	%eax,%ebx
	decl	%eax
	andl	%ebx,%ebx
	jne	.L3			/ }
.L2:
	movl	%ecx,%esp		/ <stack pointer> = SP;
	movl	%ecx,%eax		/ ptr1 = (int *)SP;
	andl	%edx,%edx		/ while (num_args) {
	je	.L7			/
	movl	20(%ebp),%esi
	movl	24(%ebp),%edx
.L8:
	movl	16(%ebp),%ecx
	movsbl	(%ecx),%ecx		/   switch (*arg_types) {
	cmpl	$CI_CHAR,%ecx		/     case CI_CHAR:
	jne	.L9			/
	movl	(%edx),%ecx		/       *ptr1 = ((char *)*args)[0];
	movsbl	(%ecx),%ecx		/
	movl	%ecx,(%eax)		/
	jmp	.L10			/       break;
	.align	4
.L11:					/     case CI_SHORT:
	movl	(%edx),%ecx		/       *ptr1 = ((short *)*args)[0];
	movswl	(%ecx),%ecx		/
	movl	%ecx,(%eax)		/
	jmp	.L10			/       break;
	.align	4
.L12:					/     case CI_INT:
	movl	(%edx),%ecx		/       *ptr1 = ((int *)*args)[0];
	movl	(%ecx),%ecx		/
	movl	%ecx,(%eax)		/
	jmp	.L10			/       break;
	.align	4
.L13:					/     case CI_DOUBLE:
	movl	(%edx),%ecx		/       *ptr1 = ((double *)*args)[0];
	movl	(%ecx),%edi		/
	movl	4(%ecx),%ecx		/
	movl	%edi,(%eax)		/
	movl	%ecx,4(%eax)		/
	addl	$4,%eax			/       ptr1++;
	jmp	.L10			/       break;
	.align	4
.L14:					/     case CI_STRUCT: {
	movl	(%edx),%edi		/       char *temp = *args;
	movswl	(%esi),%ecx		/       int   cnt  = *arg_sizes;

	movl	%ecx,%ebx		/       ptr2 = (char *)ptr1;
	decl	%ecx			/       while (cnt--) {
	andl	%ebx,%ebx		/
	je	.L15			/
	movl	%eax,%ebx		/
.L16:
	movb	(%edi),%al		/         *ptr2 = *temp;
	movb	%al,(%ebx)		/
	incl	%edi			/         temp++;
	incl	%ebx			/         ptr2++;
	movl	%ecx,%eax		
	decl	%ecx
	andl	%eax,%eax
	jne	.L16			/       }
	movl	%ebx,%eax
.L15:
	addl	$-4,%eax		/       ptr1 = (int *)(ptr2 - 4);
					/       break;

					/     default:
					/       return 0;
					/   }
.L10:
	decl	12(%ebp)		/   num_args--;
	incl	16(%ebp)		/   arg_types++;
	addl	$2,%esi			/   arg_sizes++;
	addl	$4,%edx			/   args++;
	addl	$4,%eax			/   ptr1++;
	cmpl	$0,12(%ebp)		/
	jne	.L8			/ }
.L7:
	fnstsw	%ax			/ FTOS = <top of float reg stack>
	sarw	$10,%ax			/
	andw	$7,%ax			/
	movswl	%ax,%esi		/
	call	*8(%ebp)		/ fn_addr ();
	movl	%eax,ret_val+8		/ ret_val.Ival = <int function return>
	fnstsw	%ax			/ if (FTOS != <top of float reg stack>)
	sarw	$10,%ax			/
	andw	$7,%ax			/
	movswl	%ax,%eax		/
	cmpl	%eax,%esi		/
	je	.L17			/
	fstpl	ret_val			/   ret_val.Dval = <pop float reg stack>;
.L17:
	subl	%eax,%eax		/ return 0;
	movl	-24(%ebp),%ebx
	movl	-20(%ebp),%esi
	movl	-16(%ebp),%edi
	leave	
	ret	
	.align	4
.L9:
	cmpl	$CI_SHORT,%ecx
	je	.L11
	cmpl	$CI_INT,%ecx
	je	.L12
	cmpl	$CI_DOUBLE,%ecx
	je	.L13
	cmpl	$CI_STRUCT,%ecx
	je	.L14
	jmp	.L17
	.align	4
