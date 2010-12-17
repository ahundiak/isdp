#ifndef NFMD_PROTO_H
#define NFMD_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMD(s) s
#else
# define __NFMD(s) ()
#endif


/* NFMd.c */
extern int main __NFMD((int argc, char **argv));
extern int process_com __NFMD((int fd, char *address));
extern int NFMget_params __NFMD((long type, char **path, char ***ARGV, char **username));
extern char *Next_entry __NFMD((char *line, long max_num, FILE *fp));

#undef __NFMD

#endif
