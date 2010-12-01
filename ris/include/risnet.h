/* Do not alter this SPC information: $Revision: 1.4.21.1 $ */
/*
**      NAME:                                                   net.h
**      AUTHORS:                                                Dave Buehmann
**      CREATION DATE:                                  12/89
**      ABSTRACT:
**              Describes global stuff for network directory.
**      
**      REVISION HISTORY:
*/

#ifndef RIS_NET_H
#define RIS_NET_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>

#include "risnet_err.h"

#define UMS_SUPPORTED

#ifdef NET_DEFINE
#define NET_EXTERN
#define NET_INIT(x)    = x
#else
#define NET_EXTERN             extern
#define NET_INIT(x)
#endif
#ifndef STRING
#define STRING(s)       ((s)?(s):"NULL")
#endif

/*
**      network protocol function array offsets, protocols
*/
#define NO_PROTOCOL   0
#define XNS           1
#define TCP           2
#define DNP           3
#define LU62          4
#define ISO           5
#define SHMEM         6
#define LAST_PROTOCOL 7

/*
**      network protocol function array offsets, functions
*/
#define NET_CONNECT         0
#define NET_ACCEPT          1
#define NET_WRITE           2
#define NET_READ            3
#define NET_CLOSE           4
#define NET_ADDRESS         5
#define NET_NODE            6
#define NET_GET_FILE        7
#define NET_PUT_FILE        8
#define NET_GET_LOCK_FILE   9
#define NET_PUT_LOCK_FILE  10
#define NET_REMOVE_FILE    11
#define NET_LAST_FUNC      12

/*
**      Maximum buffer sizes
*/
#define NET_MAX_CONNECTIONS					40
#define MAX_XNS_BUFFER_SIZE					16384

#if defined (unix) || defined(WIN32) || defined(vms)
#define MAX_TCP_BUFFER_SIZE					16384
#endif

#if defined(DOS)
#define MAX_TCP_BUFFER_SIZE					1024
#endif
#define MAX_DNP_BUFFER_SIZE					512
#define MAX_LU62_BUFFER_SIZE	                                32768
#define MAX_ISO_BUFFER_SIZE					0
#define MAX_LOCAL_BUFFER_SIZE          		                0

#define MAX_ADDRESS_SIZE					29
#define MAX_USER_NAME_SIZE					19
#define MAX_PASSWORD_SIZE					24
#define MAX_PATH_SIZE						257
#define MAX_LU_NAME_SIZE					18
#define MAX_TRANS_PROG_NAME_SIZE			        65
#define MAX_MODE_NAME_SIZE					9
#define MAX_ARG_SIZE						80

#define REMOTE_TIME_OUT						300000  /* 300000 milliseconds = 5 min */
#define TCP_TIME_OUT						50      /* 50 secs */

/*
**      The next two defines should always add up to a multiple of 8
*/
#define NET_SIZE_FIELD_SIZE             	sizeof(int)
#define NET_LEN_FIELD_SIZE					4
#define NET_BUFFER_OFFSET               	(NET_SIZE_FIELD_SIZE + NET_LEN_FIELD_SIZE)

#define NET_DATA_SIZE                   	1008
#define NET_HEADER_SIZE                 	sizeof(net_block_info_s)
#define NET_BLOCK_SIZE                  	(NET_DATA_SIZE + NET_HEADER_SIZE)

#define NET_MAX_PATH_SIZE         			257

/*
**   Flags
*/
#define NON_BLOCKING           -1
#define BLOCKING                0

#define CLIENT_FLAG             1
#define SERVER_FLAG             2

#define READ_BUFFER             1
#define WRITE_BUFFER            2

/*
**      init memory modes
*/
#define ALLOCATE                1
#define ATTACH                  2
#define REALLOCATE              3

/*
**      finish memory modes
*/
#define DEALLOCATE              1
#define DETACH                  2

/*
**      LU6.2 LU macros
*/
#define LOCALLY_KNOWN           0
#define FULLY_QUALIFIED         1
#define START_CONNECTION        1
#define STOP_CONNECTION         1
#define START_CONVERSATION      0
#define STOP_CONVERSATION       0

/*
**      Timestamp macros
*/
#define NET_DATA        0
#define NET_TIMESTAMP   1

/*
**      network success
*/
#define NET_SUCCESS		0

#ifndef MIN
#define MIN(x,y)        ( ( (x) < (y) ) ? (x) : (y) )
#endif

#ifndef MAX
#define MAX(x,y)        ( ( (x) > (y) ) ? (x) : (y) )
#endif

#ifdef NO_NET_DBG
# define NET_DBG(s)
#else
# define NET_DBG(s)     if (NET_debug && NET_debug_handler) {NET_debug_handler s;}
#endif

#define NET_ERRCHK(net) if (net->error_code != NET_SUCCESS) return

#define NET_TIMEOUT_CHECK(net) (net->error_code == NET_E_TIMEOUT)

typedef struct net_shmem_info_s
{
 int shm_seg_size;
 int shm_key;
 int shm_access;
 int sem_cnt;
 int sem_key;
 int sem_access;
} net_shmem_info_s;

typedef union net_connect_s
{
  struct
  {
    char            address    [MAX_ADDRESS_SIZE];
    char            username   [MAX_USER_NAME_SIZE];
    char            password   [MAX_PASSWORD_SIZE];
    char            server_name[MAX_PATH_SIZE];
    unsigned short  server_num;
  } xns;

  struct
  {
    char            address [MAX_ADDRESS_SIZE];
    char            username[MAX_USER_NAME_SIZE]; /* file transfer only */
    char            password[MAX_PASSWORD_SIZE];  /* file transfer only */
    unsigned short  port;
  } tcp;

  struct
  {
    char            node_name[MAX_ADDRESS_SIZE];
    char            userid   [MAX_USER_NAME_SIZE];
    char            password [MAX_PASSWORD_SIZE];
    char            task_name[MAX_PATH_SIZE];
    short           object_nbr;
  } dnp;

  struct
  {
    char    lluname [MAX_LU_NAME_SIZE];     /* local LU name */
    char    rluname [MAX_LU_NAME_SIZE];     /* remote LU name */
    short   llutype;        /* local LU type (0 = local;1 = fully-qualified) */
    short   rlutype;        /* remote LU type (0 = local;1 = fully-qualified) */
    char    ltpn [MAX_TRANS_PROG_NAME_SIZE]; /* local trans program name */
    char    rtpn [MAX_TRANS_PROG_NAME_SIZE]; /* remote trans program name */
    char    mode_name [MAX_MODE_NAME_SIZE]; /* mode name */
    char    userid [MAX_USER_NAME_SIZE];
    char    password [MAX_PASSWORD_SIZE];
    char    debug;
    char    dbtype;
    char    os;
  } lu62;

  struct
  {
    struct net_shmem_info_s shmem_info;
    char   path[MAX_PATH_SIZE];
    char   arg1[MAX_ARG_SIZE];
    char   arg2[MAX_ARG_SIZE];
    char   arg3[MAX_ARG_SIZE];
  } shmem;
} net_connect_s;

typedef struct net_finish_s
{
  int memory_mode;
} net_finish_s;

typedef struct net_buffer_s
{
  int           size;
  unsigned char len[NET_LEN_FIELD_SIZE];
  char          data[1]; /* variable length */
} net_buffer_s;

/*
**      NOTE:   net_block_info must be 8 byte aligned.
**                      next is a self-relative pointer
**                      See below for further discussion
*/
typedef struct net_block_info_s
{
  struct net_block_info_s *next;
  unsigned int  count;
  unsigned int  size;   /* size of the buffer */
  unsigned int  len;    /* len of the data in the buffer */
} net_block_info_s;

/*
**      Note: net_mem_info must be 8 byte aligned.
*/

#if defined(WIN32) || defined(__Sol2__) || defined(Soli) || defined(__i386)
/*
**  FOR NT only:
**              Make pointers self-relative offsets so virtual memory can be
**              mapped differently for each process (client/server).
**              The fields in net_mem_info struct affected are pos, free, and
**              buffers[]; which are all the pointers in the struct.
**
**  Macros to support setting and retrieving self-relative pointers.
**              A self-relative pointer is the offset between location (address 
**              pointing to) and self (address of pointer)
**      Inputs are addresses: 
**              x: pointer to be stored
**              y: address of self-relative pointer
**              z: pointer-to-pointer to data type the result is cast to
*/
#define NET_SET_PTR(x,y,z) (*(z **)(y) = (z *)((char *)(x) - (int)(y)))
/*
**      Inputs:
**              x: address of self-relative pointer
**              y: pointer data type to cast to
*/
#define NET_GET_PTR(x,y) ((y *)((char *)(x) + (int)(*x)))

/*
**	This is the WINNT structure that keeps track of each server 
**	using shared memory (currently max of 25)
*/
#if defined(WIN32)
struct event_info
{
	HANDLE	Server;
	HANDLE	EventC;
	HANDLE	EventS;
	int		server_died;
	BOOL	client_locked;
};
#endif
#endif

typedef struct net_mem_info_s
{
#if defined(unix)
	int                     shmid;                  /* shared memory id */
#endif
	unsigned int            avail;                  /* amount of available shared memory */
	char                    *pos;                   /* pointer to available shared memory */

#if defined(unix)
	int                     semid;                  /* semaphore set id */
	unsigned int            sem_alloc;              /* semaphore set mask */
	unsigned int            sem_cnt;                /* semaphore set count */
#endif
	int                     attach_count;   		/* process attach count */
	net_block_info_s        *free;      			/* pointer of free block list */

#if defined(unix)
	int                     semnum;     /* current semaphore number */
#endif
#if defined(WIN32) || defined(__Sol2__) ||  defined(Soli)
	int                     dummy;      /* not used in NT */
#endif
	/*
	** cur_index is used only during startup
	** connection phase of communication between client/server processes
	*/
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	int                     cur_index;  /* index to current buffer and
								       	   break_connection flag arrays */
#endif
#if defined(unix)
	net_block_info_s        **bufferp;  /* pointer to current buffer */
	char                    *break_connectionp;     
									/* pointer to current break_connection flag */
	char                    pad[4];
#endif
	net_block_info_s        *buffers[NET_MAX_CONNECTIONS]; /* current buffer */
	char					break_connections[NET_MAX_CONNECTIONS]; 
									/* current break_connection flag */
} net_mem_info_s;

typedef struct net_s
{
  void            (*error_handler)();     /* user-defined error handler */
  unsigned short  protocol;               /* user-defined protocol code */
  unsigned char   cs_flag;                /* client/server flag */

  unsigned int    error_code;             /* generic error code */
  char            error_string[160];      /* generic error string */
  unsigned int    net_error_code;         /* protocol-specific error code */
  char            net_error_string[160];  /* protocol-specific error string */

  unsigned char   misc_flag;              /* internal flag */

  union
  {
    unsigned int  id;                   /* generic field for network id */
    union
    {
      struct
      {
        int socket;                 /* unix client tcp socket id */
      } user;
      struct
      {
        /* TCPware/vms has int type */
        unsigned int    infildes;       /* unix server tcp input fd */
        unsigned int    outfildes;      /* unix server tcp output fd */
      } server;
    } tcp;
    struct
    {
      long            sni_d;          /* unix/vax xns sni id */
    } xns;
    struct
    {
      int                     logical_link;
    } dnp;
    struct
    {
      char            *lcbp;          /* unix lu62 id; really lu62lcb* */
    } lu62;
    struct
    {
      unsigned int      pid;
      unsigned int      semnum;
      net_block_info_s  **bufferp;    /* pointer to buffer for this
											connection */
      char              *break_connectionp; /* pointer to
													break_connection flag */
    } shmem;
  } id;
  char   connection_open;
  char   pad[3];
  struct net_s *next;
} net_s;

NET_EXTERN  int  NET_debug                               NET_INIT(0);
NET_EXTERN  int  (*NET_debug_handler)(const char *, ...) NET_INIT((int (*)(const char *, ...))NULL);

NET_EXTERN  net_mem_info_s       *NET_mem        NET_INIT(0);

NET_EXTERN  char NET_ums_file[NET_MAX_PATH_SIZE]      NET_INIT("");

NET_EXTERN  char NET_peer_name[MAX_ADDRESS_SIZE]      NET_INIT("");

/* ==============================================================================
 * Prototype eveything
 */
#ifdef __cplusplus
extern "C" {
#endif

/* netgnerc.c */
extern int NET_connect(net_s *net, net_connect_s *connect_info);
extern int NET_accept (net_s *net);
extern int NET_close  (net_s *net);
extern int NET_finish (net_s *net, net_finish_s *finish_info);

extern int NET_invalidate_connection(net_s *net);

extern int NET_write       (net_s *net, char *buffer, int *len, int blocking);
extern int NET_write_no_len(net_s *net, char *buffer, int *len, int blocking);
extern int NET_read        (net_s *net, char *buffer, int *len, int blocking);
extern int NET_read_no_len (net_s *net, char *buffer, int *len, int blocking);

extern int NET_address (net_s *net, char *nodename, char *netaddr, int *len);
extern int NET_nodename(net_s *net, char *nodename,                int *len);

extern int NET_get_file(net_s *net, net_connect_s *connect_info, char *remote_file, char *local_file);
extern int NET_put_file(net_s *net, net_connect_s *connect_info, char *local_file,  char *remote_file);

extern int NET_remove_file(net_s *net, net_connect_s *connect_info, char *remote_file);

extern int NET_get_lock_file(net_s *net, net_connect_s *connect_info, char *remote_file);
extern int NET_put_lock_file(net_s *net, net_connect_s *connect_info, char *remote_file);

extern int   NET_init_lang(net_s *net, char *ums_file);
extern char *NET_error_code(int code);

extern char *NET_alloc  (int size);
extern char *NET_realloc(char *user_buffer, int size);
extern void  NET_free   (char *user_buffer);

extern void NET_set_debug_handler(int (*debug_handler)(const char *, ...));

extern int Net_Error_Return_Function (net_s *net);

/* netmem.c */
extern void NET_alloc_shmem(net_s *net, net_shmem_info_s *shmem_info);
extern void NET_dealloc_shmem(net_s *net);
extern void NET_detach_shmem (net_s *net);
extern void NET_attach_shmem (net_s *net);

extern void NET_free_blocks(net_s *net, net_block_info_s * block);

extern net_block_info_s * NET_get_block(net_s *net, int size);

/* netumsg.c */
extern int   NET_init_error_msg();
extern char *NET_error_msg(int code);
extern void  NET_clear_ums_msg(void);

/* netlen.c */
extern void NET_put_len(unsigned char len_field[NET_LEN_FIELD_SIZE], int  len);
extern void NET_get_len(unsigned char len_field[NET_LEN_FIELD_SIZE], int *lenp);

/* netshare.c */
extern void NET_execute_command(
  net_s   *net,
  char    *command,
  int     error_code,
  void    (*error_function)(),
  char    *alt_string,
  int     alt_error_code);

extern void NET_error(net_s *net, int code);
extern time_t NET_get_remaining_time(time_t *start_time, time_t timeout);
extern int NET_strcmp_ic(char *s1, char *s2);

/* netpopen.c */
extern FILE * NET_popen(char *cmd, char *mode);
extern int    NET_pclose(FILE *ptr);

/* nettcp.c */
extern void NET_connect_tcp(net_s *net, net_connect_s *connect_info);
extern void NET_accept_tcp (net_s *net);

extern void NET_write_tcp(
	net_s   *net,
	char    *user_buffer,
	int     *user_lenp,
	int      blocking,
	int      send_length_flag);

extern void NET_read_tcp(
	net_s   *net,
	char    *user_buffer,
	int     *user_lenp,
	int      blocking,
	int      receive_length_flag);

extern void NET_close_tcp(net_s *net);
extern void NET_addr_tcp (net_s *net, char *nodename, char *netaddr, int *len);
extern void NET_node_tcp (net_s *net, char *nodename, int *len);

extern void NET_get_file_tcp(net_s *net, net_connect_s *connect_info, char *remote_file, char *local_file);
extern void NET_put_file_tcp(net_s *net, net_connect_s *connect_info, char *local_file, char *remote_file);

extern void NET_get_lock_file_tcp(net_s *net, net_connect_s *connect_info, char *remote_file);
extern void NET_put_lock_file_tcp(net_s *net, net_connect_s *connect_info, char *remote_file);
extern void NET_remove_file_tcp  (net_s *net, net_connect_s *connect_info, char *remote_file);

extern int  NET_tcp_getpeer(int sock);
extern void NET_error_tcp(net_s *net, int code, char *string);

/* netwrap.c */
extern int NET_chmod(char *path, int mode);
extern int NET_sys_close(int fd);
extern int NET_dup      (int fd);
extern int NET_execl(char *path, char *argv0, char *argv1, char *argv2, char *argv3, char *argv4);
extern int NET_fclose(FILE *stream);
extern int NET_fcntl(int fd, int cmd, int arg);
extern char *NET_fgets(char *st, int n, FILE *fd);
extern FILE *NET_fopen(char *fname, char *type);
extern int NET_getc(FILE *stream);
extern int NET_ioctl(int fd, int req, ...);
extern int NET_open(char *path, int oflag, ...);
extern int NET_remove(char *path);
extern int NET_sighold(int sig);
extern int NET_sigrelse(int sig);
extern void (*NET_sigset(int sig,void (*func)(int)))(int);
extern int NET_stat(char *path, struct stat *buffer);
extern char *NET_tmpnam(char *st);

/* netwrapt.c */
extern int             NET_socket(int domain,int type,int protocol);
extern struct hostent *NET_gethostbyname(char *name);
extern int             NET_gethostname   (char *name,int len);

/* netlocal.c */
extern void NET_connect_local(net_s *net, net_connect_s *connect_info);
extern void NET_accept_local (net_s *net);

extern void NET_write_local(
	net_s   *net,
	char    *user_buffer,
	int     *user_lenp,
	int      blocking,
	int      send_length_flag);

extern void NET_read_local(
	net_s   *net,
	char    *user_buffer,
	int     *user_lenp,
	int      blocking,
	int      receive_length_flag);

extern void NET_close_local(net_s *net);
extern void NET_addr_local (net_s *net, char *nodename, char *netaddr, int *len);
extern void NET_node_local (net_s *net, char *nodename, int *len);

extern void NET_get_file_local(net_s *net, net_connect_s *connect_info, char *remote_file, char *local_file);
extern void NET_put_file_local(net_s *net, net_connect_s *connect_info, char *local_file, char *remote_file);

extern void NET_get_lock_file_local(net_s *net, net_connect_s *connect_info, char *remote_file);
extern void NET_put_lock_file_local(net_s *net, net_connect_s *connect_info, char *remote_file);
extern void NET_remove_file_local  (net_s *net, net_connect_s *connect_info, char *remote_file);

extern void NET_error_local(net_s *net, int code, char *string);
extern void NET_lock_sem   (net_s *net, int blocking);
extern void NET_unlock_sem (net_s *net, int blocking);

// Close up
#ifdef __cplusplus
}
#endif

#endif /* NET_H */
