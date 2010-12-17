#ifndef NET_PROTO_H
#define NET_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NET(s) s
#else
# define __NET(s) ()
#endif


/* NETc_tools.c */
extern int NETclose_c __NET((int *NETid));
extern int NETbuffer_send_c __NET((int *NETid, char *buffer, int *len));
extern int NETbuffer_receive_c __NET((int *NETid, char *buffer, int *len));

/* NETfmu.c */
extern int NETfmu_con_send __NET((char *node_name, char *user_name, char *passwd, char *src_file, char *dst_file, char *attribute, int *file_size));
extern int NETfmu_con_receive __NET((char *node_name, char *user_name, char *passwd, char *src_file, char *dst_file, char *attribute, int *file_size));
extern int NETfmu_connect __NET((char *node_name, char *user_name, char *passwd));
extern int NETfmu_disconnect __NET((void));
extern int NETfmu_rcmd __NET((char *command));
extern int NETfmu_send __NET((char *src_file, char *dst_file, char *attribute, int *file_size));
extern int NETfmu_receive __NET((char *src_file, char *dst_file, char *attribute, int *file_size));
extern int NETfmu_set __NET((char *attribute));
extern int NETfmu_unset __NET((char *attribute));

/* NETs_tools.c */
extern int NETclose_s __NET((int *inpipe, int *outpipe));
extern int NETbuffer_send_s __NET((int *NETid, char *buffer, int *len));
extern int NETbuffer_receive_s __NET((int *NETid, char *buffer, int *len));

/* NETshm.c */
extern int NETattach_shm __NET((void));
extern int NETinsert_shm __NET((long pid, int fd));
extern int NETget_fd_from_shm __NET((long pid, int *fd));
extern int NETinit_shm __NET((void));

/* NETtools.c */
extern int _NETconnect __NET((char *nodename, int server_number, int port_number, int *NETid, int protocol));
extern int NETclose __NET((int *NETid));
extern int NETbuffer_send __NET((int *NETid, char *buffer, int *len));
extern int NETbuffer_receive __NET((int *NETid, char *buffer, int *len));
extern int _NETaccept __NET((int *fd));

#undef __NET

#endif
