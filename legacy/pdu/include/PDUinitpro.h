#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./init/PDUpart.c */
extern void PDUpart_init __PDU((void));

/* ./init/PDUpdm_exec.c */
extern void PDUpdm_exec_init __PDU((void));

/* ./init/PDUrefresh.c */
extern void refresh_init __PDU((void));

/* ./init/PDUstorage.c */
extern void PDUstorage_init __PDU((void));

/* ./init/PDUuser.c */
extern void PDUuser_init __PDU((void));

#undef __PDU
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#endif
