#ifndef VER_PROTO_H
#define VER_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __VER(s) s
#else
# define __VER(s) ()
#endif


/* NFMversion.c */
extern void _NFMprint_copyright __VER((char *label));

#undef __VER

#endif
