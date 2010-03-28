/*	Copyright (c) 1984 AT&T	*/
/*	Copyright (c) 1988,1989,1990 Intergraph Corporation	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	AND INTERGRAPH CORPORATION	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

#ident  "$Id: stdarg.h,v 1.1.1.1 2001/12/17 22:40:15 hans Exp $ Copyright (c) 1986,1987,1988,1989,1990 by Intergraph Corp."

#ifndef _STDARG_H
#define _STDARG_H
#include <sys/stdarg.h>

#if defined(__cplusplus)
extern "C" {
#if defined(__APGE__)
extern void __va_funcx(...);
extern int __va_dummy_formal;
#elif defined(__GNUC__)
extern int __builtin_saveregs(...);
extern int __alignof__(...);
#elif defined(__GHILL__)
#if defined(__STDC__)
extern int va_arg0, va_arg1, va_arg2;
extern int __va_ansiarg, __va_intreg0,__va_intreg1;
extern double __va_dblreg0, __va_dblreg1;
extern int __va_regtyp(...);
extern int __va_align(...);
extern int __va_stkarg(...);
extern int __va_argnum(...);
#else
extern int va_arg0, va_arg1, va_arg2;
extern int va_intreg0,va_intreg1;
extern double va_dblreg0,va_dblreg1;
extern int va_regtyp(...);
extern int va_align(...);
extern int va_stkarg(...);
extern int va_argnum(...);
#endif /* __STDC__ */
#endif /* __APGE__ */
}

// This is a kludge to get the Green Hills varargs constructs past
// cfront. va_regtype and va_align take a 'type' as an argument, but
// that is not legal c++, so we put sizeof there and then remove it 
// on output from cfront. (It was either that or modify the c++ 
// grammar, which is a real bear). 

#if defined(__GHILL__)
#undef va_arg
#if defined(__STDC__)
#define va_arg(ap,type) 							\
((ap).arg++ < _VA_REGS && __va_regtyp(sizeof(type)) ? 				\
  ((type *)((ap).adr[2*(ap).arg+__va_align(sizeof(type))/4-2]))[0]: 		\
  ((type *)((ap).adr[0]=(char *)(((int)(ap).adr[0]+__va_align(sizeof(type))-1 	\
				  &-__va_align(sizeof(type)))+sizeof(type))))[-1] \
)
#else  /* !__STDC__ */
#define va_arg(ap,type) 							\
((ap).arg++ < _VA_REGS && va_regtyp(sizeof(type)) ? 				\
  ((type *)((ap).adr[2*(ap).arg+va_align(sizeof(type))/4-2]))[0]: 		\
  ((type *)((ap).adr[0]=(char *)(((int)(ap).adr[0]+va_align(sizeof(type))-1 	\
				  &-va_align(sizeof(type)))+sizeof(type))))[-1] \
)
#undef va_start
#define va_start(list,parmN)                                               \
(       (list).adr[0] = (char *) va_stkarg(va_arg0, va_arg1, va_arg2),\
        (list).adr[1] = (char *) &va_intreg0,         /* &input r0 */\
        (list).adr[2] = (char *) &va_dblreg0,         /* &input f0 */\
        (list).adr[3] = (char *) &va_intreg1,         /* &input r1 */\
        (list).adr[4] = (char *) &va_dblreg1,         /* &input f1 */\
        (list).arg    =  va_argnum (parmN)+1          /*  position */\
)

#endif /* __STDC__ */
#elif defined (__APGE__)
#undef va_start
#define va_start(ap, parmN)  (void)(__va_funcx(0,(ap),0))
#elif defined (__GNUC__)
#undef va_arg
#define va_arg(ap,type) \
    ((ap).arg++ < _VA_REGS && __va_regtyp(type) ? \
     ((type *)((ap).adr[2*(ap).arg+__alignof__(sizeof(type))/4-2]))[0] : \
     ((type *)((ap).adr[0] = \
  (char *)(((int)((ap).adr[0]+(__alignof__(sizeof(type))-1)) & (-__alignof__(sizeof(type)))) + sizeof(type))))[-1])
#endif 
#endif /* __cplusplus */

#endif /* _STDARG_H */

