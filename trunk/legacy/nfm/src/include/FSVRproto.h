#ifndef FSVR_PROTO_H
#define FSVR_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __FSVR(s) s
#else
# define __FSVR(s) ()
#endif


/* NFMfs.c */
extern int main __FSVR((int argc, char *argv[]));

/* NFMl_comm.c */
extern long NFMswitch_command __FSVR((long *in_pipe, long *out_pipe, long in_command, MEMptr in_list, MEMptr *out_list));

#undef __FSVR

#endif
