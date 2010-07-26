#include "igrtypedef.h"
#include "exms.h"
#include "msdef.h"
#include "mspriv.h"
#include "msmacros.h"
#include "stdio.h"
#include <UMS.h>

int MS_retrieve_msg (MS_msg)
struct MS_sd_msg *MS_msg;
{
int status;

    /*
     *	find correct header
     */

    if (MS_msg->no_msg == MS_NO_MSG) 
     {
      status = _UMSReturnByKey(MS_msg->in_msg,MS_msg->msgname);
     }
    else
     {
       status = _UMSReturnByNum(MS_msg->in_msg,MS_msg->no_msg);
     }
 return(status);

}
