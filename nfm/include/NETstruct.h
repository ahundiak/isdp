#ifndef NETstruct_H_
#define NETstruct_H_

#define XNS_MAX_SIZE        1024 * 16
#define TCP_MAX_SIZE        1024 * 4

#define NET_PATH_SIZE       256
#define NET_BUF_SIZE        512 

#define NET_I_NO_CONNECTION  -1
#define	NET_XNS              1
#define NET_TCP              2

#define FIXED_ENCRYPT_LENGTH 25
#define MAX_PASSWD_LENGTH    14

#define C1	23
#define C2	43

struct   NETbuffer_info
  {
     long    size;
     long    request;
     char    username [16];
  };

struct     NETfile_info
  {
     char       name [80];
     char       attr [16];
     long       size;
     long       mode;
     long       atime;
     long       mtime;
  };

struct utimebuf
 {
   long   actime;
   long   modtime;
 };

struct NETuser_struct
 {
    char    name [16];
    char    dir [256];
    long    uid;
    long    gid;
 };

typedef struct DRPheader 
 {
    char    request_id [40];
    int     request_type;
    char    catalog_name [40];
    char    item_name [60];
    char    item_rev [40];
    int     size_of_buffer;
    int     immediate_int;
    char    immediate_char [40];
 } *DRPptr;
#endif
