#include "machine.h"
#include "NFMsysinc.h"

 extern MSGptr NFMmsg_ptr;
 extern MSGptr MEMmsg_ptr;

 void  NFMreset_message_struct (user_id)
   {
      NFMmsg_ptr.error_no = NFM_S_SUCCESS;
      MEMmsg_ptr.error_no = NFM_S_SUCCESS;
      NFMmsg_ptr.error_msg [0]  = 0;
      MEMmsg_ptr.error_msg [0]  = 0;
   }
