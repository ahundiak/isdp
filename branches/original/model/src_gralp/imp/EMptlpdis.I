/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSptgralp;

# include "EMSlmdef.h"      /* EMS_WHL_EDGE    */
# include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY */
# include "OMmacros.h"      /* OM_BLOCK_MOVE   */

from EMSsubbs import EMget_ele_header;

method EMdisplay( IGRlong                *EMmsg;
                  IGRboolean              owner_origin;
                  enum GRdpmode          *mode;
                  struct DP_information  *sp_info;
                  struct IGResbs         *bs_attr;
                  struct DPele_header    *ele_header;
                  IGRshort               *mx_type;
                  IGRmatrix               matrix;
                  IGRchar                *buffer;
                  IGRint                  buffer_size;
                  struct EMSpartolbasis  *partol;
                  IGRboolean             *display_done;
                  struct GRid            *window_id )
/*
History

        SM        Few Moons Ago     Creation.
        SCW       29-JUL-91         Added check for no_display flag
        AIC       06 Oct 91         Changed arguments to EMget_ele_header.
*/
{
  IGRlong              sts;
  struct DPele_header  local_ele_header;
  GRrange              range;
  struct GRsymbology   symb;
  struct IGResqbs      bsqsurf;
  IGRuchar     save_weight;
  struct GRmdenv_info  mdenv_info;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if( !( ME.EMSloop->lp_props & EMLP_ACTIVE )) goto wrapup;

  /*
   * Make shure we have the surface element header
   */
  if( !ele_header )
  {
     struct GRid         srf_id;
     union IGRele_attr   ele_spec_att;

     ele_header = &local_ele_header;
     ele_spec_att.bsqsurf = &bsqsurf;

     sts = om$send( msg = message EMSboundary.EMgetsurface_info( EMmsg, 
                                                                &srf_id.objid,
                                                                 NULL ), 
                    targetid = my_id );
     if( !( 1 & *EMmsg & sts )) goto wrapup;
     srf_id.osnum = OM_Gw_current_OS;

     /*
      * Get the element header
      */
     mdenv_info.matrix_type = *mx_type;
     OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

     sts = om$send( msg = message EMSsubbs.EMget_ele_header( EMmsg,  
                                                             NULL,
                                                             &mdenv_info,
                                                             NULL, 
                                                             ele_header, 
                                                             range,
                                                            &symb.display_attr,
                                                             ele_spec_att, 
                                                             NULL ),
                    targetid = srf_id.objid );
     if( !( 1 & *EMmsg & sts )) goto wrapup;
  }

  save_weight = ele_header->dis_att->weight;
  ele_header->dis_att->weight = PointLoopDisplayWeight;

  sts = om$send( mode = OM_e_wrt_message, 
                 msg = message EMSgraloop.EMdisplay( EMmsg, 
                                                     owner_origin, 
                                                     mode, 
                                                     sp_info, 
                                                     bs_attr, 
                                                     ele_header, 
                                                     mx_type, 
                                                     matrix, 
                                                     buffer, 
                                                     buffer_size, 
                                                     partol, 
                                                     display_done, 
                                                     window_id ), 
                 targetid = my_id );
  ele_header->dis_att->weight = save_weight;

wrapup:
  EMWRAPUP( *EMmsg, sts, "EMSptloop.EMdisplay" )
  *EMmsg = EMS_S_Success;
  return( OM_S_SUCCESS );
}

end implementation EMSptgralp; 
