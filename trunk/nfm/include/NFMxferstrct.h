#ifndef NFMxferstrct_H_
#define NFMxferstrct_H_

#ifndef   NFMfto_buf_H_
#include "NFMfto_buf.h"
#endif

typedef	struct	NFMxfer_buf_status
{
  long status1;
  long status2;
  long status3;
} NFMxfer_buf_status ;

typedef struct NFMfilexfer_local_sa
{
  int  local_sa_flag;
  char LOCAL_SA[FTO_MAX_BUF][FTO_MAX_LEN+1];
} NFMfilexfer_local_sa;

typedef	struct NFMxfer_ftp
{
  long no_of_retries;
  long sleep_time;
  long verify;
} NFMxfer_ftp ;

#endif
