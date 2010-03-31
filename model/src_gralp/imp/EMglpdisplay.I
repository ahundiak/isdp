/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
History

    27-MAR-91    SCW    Genesis
    29-JUL-91    SCW    Added check for no_display flag

*/


class implementation EMSgraloop;

# include "EMS.h"
# include "EMSlmdef.h"      /* EMS_WHL_EDGE */
# include "EMSfrtdef.h"  

from EMSedge import EMdisplay;

method EMdisplay( long                   *EMmsg;
                  IGRboolean              owner_origin;
                  enum GRdpmode          *mode;
                  struct DP_information  *sp_info;
                  struct IGResbs         *bs_attr;
                  struct DPele_header    *ele_header;
                  short                  *mx_type;
                  IGRmatrix               matrix;
                  char                   *buffer;
                  int                     buffer_size;
                  struct EMSpartolbasis  *partol;
                  IGRboolean             *display_done;
                  struct GRid            *window_id )
{
  long  sts;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if( !( ME.EMSloop->lp_props & EMLP_ACTIVE )) goto wrapup;

  if(!( me->props & EMGL_HOLD_UPDATE) )
  {
     short               edge_flag;
     OM_S_CHANSELECT     to_edges;

     if( !( me->props & EMGL_UPTODATE ))
     {
        sts = om$send( msg = message EMSgraloop.EMupdate_feature( EMmsg,
                                                                  mx_type,
                                                                  matrix ),
                       targetid = my_id );

     }

     /*
      * Display the edges
      */
     sts = EMmake_chanselect( EMSbd_owner_to_comps, &to_edges );
     if( !( 1 & sts )) goto wrapup;

     /*
      * If the display originated from the owner, then supress
      * the display of dominant edges. Always supress the display
      * natural edges, since they are included in the rule line table.
      */
     if( owner_origin )  edge_flag = EMS_NONSUBORDINATE_EDGE;
     else  edge_flag = EMS_NONNATURAL_EDGE;

     sts = om$send( msg = message EMSedge.EMdisplay( EMmsg,
                                                     ele_header,
                                                     mx_type,
                                                     matrix,
                                                     mode,
                                                     sp_info,
                                                     edge_flag,
                                                     NULL ),
                    p_chanselect = &to_edges );
  }

wrapup:
  EMWRAPUP( *EMmsg, sts, "EMSgraloop.EMdisplay" )
  *EMmsg = EMS_S_Success;
  return( OM_S_SUCCESS );
}

end implementation EMSgraloop; 

