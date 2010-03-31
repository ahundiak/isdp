class implementation NMfeaturelp;

# include "msdef.h"         /* MSSUCC           */
# include "dpdef.h"         /* for dpmacros.h   */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dperr.h"         /* DPSTOPDRAW       */
# include "dpmacros.h"  /* dp$build_dis_buffer dp$dispelem dp$display */
# include "nmdef.h"  
#include "EMSlmdef.h"
#include "OMmacros.h"

from EMSedge import EMdisplay;
from EMSsubbs import EMget_ele_header;

extern OMuword OPP_NMptflp_class_id;

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
  IGRlong		sts = OM_S_SUCCESS;
  IGRshort		edge_flag;
  OM_S_CHANSELECT	to_edges;
  struct DPele_header   local_sf_ele_header;
  struct IGResqbs       bsqsurf;
  GRrange               range;
  struct GRsymbology    symb;
  struct GRmdenv_info	env;
  IGRboolean		reset_weight = FALSE;
  IGRint		wt_inc = 0;

  *EMmsg = EMS_S_Success;
  if( !( ME.EMSloop->lp_props & EMLP_ACTIVE )) goto wrapup;
  env.matrix_type = *mx_type;
  OM_BLOCK_MOVE(matrix, env.matrix, sizeof(IGRmatrix));

  if(!ele_header)
   {
    struct GRid         srf_id;
    union IGRele_attr   ele_spec_att;

    ele_spec_att.bsqsurf = &bsqsurf;

    /*
     * get the surface info, I am a part of
     */
    sts = om$send(msg = message EMSboundary.EMgetsurface_info
          (EMmsg, &srf_id.objid, NULL), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    srf_id.osnum = OM_Gw_current_OS;

    /*
     * Get the element header
     */
    sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
          &env, NULL, &local_sf_ele_header, range,
          &symb.display_attr, ele_spec_att, NULL),
         targetid = srf_id.objid);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    ele_header = &local_sf_ele_header;
   }

  if(ele_header)
   {
    wt_inc = (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
	     OPP_NMptflp_class_id, FALSE)) ?
             PtFlpDispWeightInc : FlpDispWeightInc;

    ele_header->dis_att->weight += wt_inc;
    reset_weight = TRUE;
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
  /*if( owner_origin )*/  edge_flag = EMS_NONSUBORDINATE_EDGE;
  /*else  edge_flag = EMS_NONNATURAL_EDGE;*/

  sts = om$send( msg = message EMSedge.EMdisplay( EMmsg, ele_header,
        mx_type, matrix, mode, sp_info, edge_flag, NULL ),
        p_chanselect = &to_edges );

wrapup:
  if(ele_header && reset_weight) 
   ele_header->dis_att->weight -= wt_inc;

  EMWRAPUP( *EMmsg, sts, "NMfeaturelp.EMdisplay" )
  *EMmsg = EMS_S_Success;
  return( OM_S_SUCCESS );
}

end implementation NMfeaturelp; 

