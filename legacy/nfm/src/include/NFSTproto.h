#ifndef NFST_PROTO_H
#define NFST_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFST(s) s
#else
# define __NFST(s) ()
#endif


/* NFMnfs.c */
extern int NFMnfs_file_transfer __NFST((char *local_nodename, char *nodename, char *resource, char *cifilename, char *cofilename, char *cofilepath, char *mountpoint));
extern int NFMnfs_file_remove __NFST((char *local_nodename, char *nodename, char *resource, char *cifilename, char *cofilename, char *cofilepath, char *mountpoint));
extern int NFMnfs_mount __NFST((char *mountpoint, char *nodename, char *resource, char *options));
extern int NFMnfs_umount __NFST((char *mountpoint));
extern int NFMget_mount_point __NFST((char *nodename, char *resource, char *mountpoint));

/* NFMnfsstart.c */

/* NFMnfsstop.c */

#undef __NFST

#endif
