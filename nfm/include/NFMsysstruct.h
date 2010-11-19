
typedef struct NFMbuffer_info
{
  long request;
  long size;
  char username [NFM_USERNAME+1];
} NFMbuffer_info;

typedef struct NFMfile_info
{
  char name     [NFM_FILENAME+1];
  char attr     [NFM_USERNAME+2];
  char platter  [NFM_PLATTERNAME+1];
  char partition[NFM_PARTITION+1];
  long size;
  long mode;
  long atime;
  long mtime;
} NFMfile_info;

typedef struct NFMuser_info_struct
{
  char name[NFM_USERNAME+2];
  char dir [NFM_FILENAME*2];
  long uid;
  long gid;
} NFMuser_info_struct;

typedef	struct	NFMsys_buf_status
{
  long status1;
  long status2;
  long status3;
} NFMsys_buf_status ;

typedef struct NFMcp_buffer
{
  char src_name [NFM_FILENAME+1];
  char dst_name [NFM_FILENAME+1];
  char attr [NFM_USERNAME+2];
  long delete_src_flag;
} NFMcp_buffer;

typedef struct NFMstatus_buf
{
  long status;
} NFMstatus_buf;

typedef struct NFMfto_status
{
  long status;
  long status2;
  long status3;
  long status4;
  long status5;
  long status6;
} NFMfto_status ;

