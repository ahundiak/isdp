/*Copyright (C) 1989,1990 Apogee Software, Inc. -- All rights reserved.
  This is unpublished proprietary source code of Apogee Software, Inc.*/
/* @(#)_int_sarg.h	1.1 7/20/90 11:16:21 */
/*
_int_stdarg.h -- Private include file for variable argument lists (see 4.8).
              -- Also used by stdio.h, for vprintf() and friends.
*/
#ifndef _SYS_INT_STDARG_H
#define _SYS_INT_STDARG_H
#if defined(__APGE__)
#if !defined(__APVA__)
typedef struct  {
  char         *arg_ptr;  /* positioned at the end of last memory arg fetched */
  int	       *i0;
  double       *d0;
  int	       *i1;
  double       *d1;
  int          arg_num;   /* next arg to be fetched, leftmost arg is 0 */
} __va_list;
#else
typedef struct  {
  int	    i0, i1;
  double    d0, d1;
  int       arg_num;
  char     *arg_ptr;
} __va_list;
#endif
#else /* must be Green Hills */
typedef struct {
	char *adr[5];  /* potential addresses of input args*/
        int      arg;  /* position index in parameter-list */
} __va_list;
#endif /* __APGE__ */

#endif /* _SYS_INT_STDARG_H */

