	CI_CHAR = 1
	CI_SHORT = 2
	CI_INT = 3
	CI_DOUBLE = 4
	CI_STRUCT = 5

	.global	ret_val		! defined in ciextern.C

! Build a calling sequence using argument types array, argument
! sizes, (only used for structs), and args. Call routine specified
! in fn_addr, return %o0 and %f0 in the ret_val struct.
!---------------------------------------------------------------------------
! %i0 = fn_addr         %i3 = arg_sizes         %l7 = cnt        %l0 = SP
! %i1 = num_args        %i4 = args              %l6 = ptr1
! %i2 = arg_types       %i5 = ndx               %l5 = ptr2
!---------------------------------------------------------------------------
!
! int _ci_call (fn_addr, num_args, arg_types, arg_sizes, args)
! 
! int  (*fn_addr)();
! int    num_args;
! char  *arg_types;
! short *arg_sizes;
! char **args;
! {
!   int   ndx, cnt, *ptr1;
!   char *ptr2;
!   char *SP;
!
	.seg	"text"
	.global	_ci_call
_ci_call:
	save	%sp,-0x40,%sp	!
	sub	%sp,0x4,%l0	! SP  = <stack pointer> - 4;
	mov	%i1,%l7		! cnt = num_args;
	mov	%i1,%i5		! ndx = num_args;
L16:
	mov	%i5,%o0		! while (ndx--) {
	dec	%i5		!
	tst	%o0		!
	be	L17		!
	nop			!

	ldsb	[%i2+%i5],%o0	!   if (arg_types[ndx] == CI_DOUBLE) {
	cmp	%o0,CI_DOUBLE	!
	bne	L18		!
	nop			!

	inc	%l7		!     cnt++;
	sub	%l0,0x4,%l0	!     SP -= 4;
	b	L19		!   }
	nop			!

L18:
	ldsb	[%i2+%i5],%o1	!   else if (arg_types[ndx] == CI_STRUCT) {
	cmp	%o1,CI_STRUCT	!
	bne	L20		!
	nop			!

	sll	%i5,0x1,%o2	!     SP -= (arg_sizes[ndx] + 7) & ~0x7;
	ldsh	[%i3+%o2],%o3	!   }
	add	%o3,0x7,%o4	!
	and	%o4,-0x8,%o5	!
	sub	%l0,%o5,%l0	!
L20:
L19:
	sub	%l0,0x4,%l0	!   SP -= 4;
	b	L16		! }
	nop			!
L17:
	and	%l0,-0x8,%l0	! SP = (char *)((int)SP & ~0x7);
	mov	%l0,%sp		! <stack pointer> = SP;
	add	%l0,0x44,%l6	! ptr1 = (int *)(SP + 68);
	sll	%l7,0x2,%l1	! ptr2 = (char *)(ptr1 + cnt);
	add	%l6,%l1,%l5	!
L23:
	tst	%i1		! while (num_args) {
	be	L22		!
	nop			!
        ldsb    [%i2],%o0	!   switch (*arg_types) {
        dec     %o0		!
        cmp     %o0,CI_DOUBLE	!
        bgu     L33		!
        sll     %o0,2,%o0	!
        set     L2000000,%o1	!
        ld      [%o0+%o1],%o0	!
        jmp     %o0		!
        nop			!
        L2000000:		!
        .word   L26		!
        .word   L27		!
        .word   L28		!
        .word   L29		!
        .word   L30		!

L26:				!     case CI_CHAR:
	ld	[%i4],%o0	!       *ptr1 = ((char *)*args)[0];
	ldsb	[%o0],%o1	!
	st	%o1,[%l6]	!
	b	L24		!       break;
	nop
L27:				!     case CI_SHORT:
	ld	[%i4],%o2	!	*ptr1 = ((short *)*args)[0];
	ldsh	[%o2],%o3	!
	st	%o3,[%l6]	!
	b	L24		!       break;
	nop
L28:				!     case CI_INT:
	ld	[%i4],%o4	!       *ptr1 = ((int *)*args)[0];
	ld	[%o4],%o5	!
	st	%o5,[%l6]	!
	b	L24		!       break;
	nop
L29:				!     case CI_DOUBLE:
	ld	[%i4],%o7	!	*ptr1 = ((int *)*args)[0];
	ld	[%o7],%l2	!
	st	%l2,[%l6]	!
	add	%l6,0x4,%l6	!       ptr1++;
	ld	[%o7+0x4],%l3	!       *ptr1 = ((int *)*args)[1];
	st	%l3,[%l6]	!
	b	L24		!       break;
	nop
L30:				!     case CI_STRUCT:
	add	%l5,0x7,%o0	!       ptr2 = (char *)((int)(ptr2 + 7) & ~0x7);
	and	%o0,-0x8,%l5	!
	st	%l5,[%l6]	!       *ptr1 = (int)ptr2;
	ld	[%i4],%l4	!       { char *temp = *args;
	ldsh	[%i3],%l7	!         cnt = *arg_sizes;
L31:				!
	mov	%l7,%o1		!         while (cnt--) {
	dec	%l7		!
	tst	%o1		!
	be	L32		!
	nop			!
	ldsb	[%l4],%o3	!           *ptr2 = *temp;
	stb	%o3,[%l5]	!
	inc	%l4		!           temp++;
	inc	%l5		!           ptr2++;
	b	L31		!         }
	nop			!       }
L32:				!
	b	L24		!       break;
	nop
L33:				!     default:
	mov	0,%o0		!       return 0;
	b	LE14		!   }
	nop
L24:
	dec	1,%i1		!   num_args--;
	inc	1,%i2		!   arg_types++;
	inc	2,%i3		!   arg_sizes++;
	inc	4,%i4		!   args++;
	inc	4,%l6		!   ptr1++;
L21:
	b	L23		! }
	nop			!
L22:
	ld	[%sp+0x44],%o0
	ld	[%sp+0x48],%o1
	ld	[%sp+0x4c],%o2
	ld	[%sp+0x50],%o3
	ld	[%sp+0x54],%o4
	ld	[%sp+0x58],%o5
	call	%i0,6
	nop
	set	ret_val,%i0
	std	%f0,[%i0]
	st	%o0,[%i0+0x8]
LE14:
	ret
	restore
