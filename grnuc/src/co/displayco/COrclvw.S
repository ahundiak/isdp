class specification COrclvw (1:0) of COwindow;



#include "limits.h"
#include "dpfile.h"
#include "DPedtsv.h"


instance COrclvw
{
   IGRint                   num_list;
   GRspacenum               osnum;
   variable struct sv_info  save_vw[];
   struct GRid              sv_grid;
   IGRint                   switch1;
};


message form_init ( long * sts );

override form_notification;

message idn_wnd ( long * sts );

message erase_form ( long * sts );

message get_state ( long * sts );

end specification COrclvw;
