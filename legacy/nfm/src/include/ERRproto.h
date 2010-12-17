/* 12/18/92 - KT - SUN Port */
/* MSSP - 29 Dec 93. modified to work on sco, solaris as well */
/* 3/18/94 - MaC - SGI Port */

/* HP PORT - IGI - 10 Jun 94 */

#if (defined (__sgi) || defined OS_SUNOS || defined OS_SOLARIS || defined OS_SCO_UNIX || defined (OS_HPUX) )
#include <varargs.h>
#endif

#ifndef ERR_PROTO_H
#define ERR_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __ERR(s) s
#else
# define __ERR(s) ()
#endif

/* DEBUG.c */
extern void _NFMdebug_function __ERR((char *fname, char *format, ...));

/* ERR.c */
extern long ERRload_struct __ERR((int type, long status, char *format, ...));
extern long _ERRload_arguments __ERR((char *format, char ***arg_array, va_list vars));
extern long ERRget_message __ERR((char *message));
extern long ERRget_specific_message __ERR((int type, char *message));
extern void ERRget_number __ERR((long *error_no, int *subsystem));
extern long ERRget_specific_number __ERR((int subsystem, long *error_no));
extern void ERRreset_struct __ERR((void));
extern long ERRinit_messages __ERR((char *path, int optflag));
extern long ERRget_context_data __ERR((int subsystem, int *argc, char ***argv));
extern char *_ERRfgets __ERR((char *s, int n, FILE *stream));

#undef __ERR

#endif
