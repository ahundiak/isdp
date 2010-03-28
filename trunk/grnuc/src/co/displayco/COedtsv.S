class specification COedtsv (1:0) of CEO;



#include "limits.h"
#include "dpfile.h"
#include "DPedtsv.h"


instance COedtsv
{
  IGRint                   num_list;
  IGRint                   delete_flag;
  GRspacenum               osnum;
  variable struct sv_info  save_vw[];
};


message form_init ( long * sts );

override form_notification;

end specification COedtsv;
