class specification COviewmnpl (1:0) of COwindow;



#include "dpsavevw.h"
#include "dpstruct.h"


instance COviewmnpl
{
    
    struct GRevent event11;
    struct GRevent event22;
    IGRchar name[32];
    IGRlong return_bytes;
    IGRdouble zoom_factor;
    GRspacenum sv_osnum;
    struct GRid sv_grid;
    IGRint	action;

    struct  GRid  vwid1[32];
    struct  GRid  vwid2[32];
   
    IGRdouble  rotation[4][4];

    IGRdouble wld_volume[6];

    struct IGRpolyline	  line;
    struct DPele_header       element;
    struct IGRespy            LineSpecific;
    struct GRevent events[2];
    struct IGRdisplay display_info;	
    IGRdouble angle1;
    IGRdouble   temp_pts1[6];
    IGRdouble	angles[3];
    IGRint	bufr_def;

    /*  for the retrieve saved view command */

    IGRint           row_selected;
    struct sv_info   *save_vw;
};


message my_delete ( long * sts );

message init_act ( long * sts );

message nme_savvw ( long * sts );

message descr ( long * sts );

message origin ( long * sts );

message cnstr ( long * sts );

message del_view ( long * sts );

message ky_vw ( long * sts );

message idn_wnd ( long * sts );

message id_vw ( long * sts );

message rnm_vw ( long * sts );

override get_type_view;

override get_wndid;

message wld_view ( long * sts );

message vw_view ( long * sts );

message zoom_factor ( long * sts );

message zoom_inout ( long * sts );

message dspl_bufrs ( long * sts );

message erase_bufrs ( long * sts );

message reset_flag ( long * sts );

message get_ax_pt1 ( long * sts );

override dynamics;

message get_ax_pt2 ( long * sts );

message get_angle ( long * sts );

message get_id_view ( long * sts );

message get_angles (IGRint  index);

message get_view ( long * sts );

message get_id_view1 ( long * sts );

override status_disp;

override form_notification;

end specification COviewmnpl;
