class specification COvwchar (1:0) of COedtly, COwindow;



#include "gr.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "DIdef.h"
#include "dpdef.h"



instance COvwchar
{
  IGRchar name[DI_PATH_MAX];
  IGRint flags;
  IGRlong num_grid_x;
  IGRlong num_grid_y;
  IGRdouble dis_grid[2];
  IGRdouble vw_vol[6];
  IGRdouble wld_to_view[4][4];
  IGRdouble wld_act_z;
  IGRdouble wld_dis_dep[2];
  IGRdouble const_org[3];
  IGRint win_response;
  IGRint win_nbytes;
  char *win_resp_data;
  IGRint toggle_proj;

};


override form_notification;

message gather_gg_data ();

message proc_chgs ();

override sleep;

override wakeup;

end specification COvwchar;
