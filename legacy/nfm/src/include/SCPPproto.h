#ifndef SCPP_PROTO_H
#define SCPP_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __SCPP(s) s
#else
# define __SCPP(s) ()
#endif


/* SCatofn.c */

/* SCcppmain.c */
extern int main __SCPP((int argc, char *argv[]));

#undef __SCPP

#endif
