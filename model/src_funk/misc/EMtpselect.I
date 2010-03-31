/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

/*
Abstract

    This function determines if the edge or vertex (edge's 
    end point) is locatable or not. If locatable, it prompts
    the user to accpet the object. This process is continued 
    until an object is accpeted or there are no more objects
    left. This function is used by local modification command objects.

    The locate process is based upon single stack philosphy.

History

RC      04/2/87         Creation date

AIC     15 Jul 1987     Use edge display instead of boundary.

RC      11/05/87        Rewrote the function such that locate
                        processing is performed here and also
                        it behaves as single stack locate.

AIC     14 February 88  Arguments changed for EMSedge.EMlocate.
                        (I am also passing NULL for insude, outside,
                         and overlap since they are only interpreted
                         for a prism locate.)

jBk	22 May 1989 	Replaced invocations of GRgetevent with uses of
                	co$getevent.

BL	07/10/89	moved 'if(num_edges) ui_prompt()' statement before the 
			co$getevent to prevent if there is no valid edge/vertex.

AIC	06 Oct 91	Arguments to EMget_ele_header changed.
Sudha   07/09/93        Modified for BSprototypes anisfication

*/

# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
#include "OMerrordef.h" /* OM message codes */

#include "exdef.h"      /* GRm_RJT_MOVEON   */

#include "OMmacros.h"   /* OM_BLOCK_MOVE*/
#include "EMSlmdef.h"
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"         /* GRlc_stack   */
#include "dpdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "griomacros.h" /* co$getevent */
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "maptsxfor.h"
#include "mainvmx.h"
#include "bssfeval.h"
#include "bsdistptli.h"

from EMSedge     import   EMendpts, EMdisplay, EMlocate;
from EMSboundary import   EMgetobjinfo;
from EMSsubbs    import   EMget_ele_header;

IGRint  EMtpselect (
    EMmsg, 
    edge_GRids, 
    srf_GRid,
    num_edges, 
    object_type, 
    srf_geom, 
    locate_event,
    md_env,
    acc_prompt,
    mask, 
    size, 
    response, 
    response_data, 
    accept_event, 
    obj_hilited  )

  IGRlong                 *EMmsg; 
  struct GRid             *edge_GRids; 
  struct GRid             srf_GRid;
  IGRint                  num_edges; 
  IGRshort                object_type; 
  struct IGRbsp_surface   *srf_geom; 
  struct GRevent          locate_event;
  struct GRmd_env         *md_env;
  IGRchar                 *acc_prompt;
  IGRlong                 *mask; 
  IGRint                  *size; 
  IGRint                  *response; 
  IGRchar                 *response_data; 
  struct GRevent          *accept_event; 
  IGRboolean              *obj_hilited;

{
  IGRdouble           locate_pt[3], vx_xyz[3], vx_uv[2];
  IGRdouble           line_pt[6], dist;
  IGRlong             OM_stat, mthd_stat /*, new_mask */;
  IGRint              status, cur_entry ;
  IGRshort            display_flag;
  
  IGRboolean          object_accepted = FALSE, was_located;
  IGRboolean          sts;
  enum GRdpmode       display_mode;

  GRrange             range;
  struct GRsymbology  symb;
  struct DPele_header srf_ele_header;
  union  IGRele_attr  ele_spec_att;
  struct IGResqbs     bsqsurf;
  struct GRobj_info   object_info;
  struct GRlc_parms   lc_parms;
  struct GRlc_cvl     cvl;
  BSrc                rc;
  
*EMmsg = EMS_S_Success;
OM_stat = OM_S_SUCCESS;
*obj_hilited = FALSE;

accept_event->response = EX_RJT_MOVEON;
cur_entry = 0;

/*
 * get the element header to be used in display
 */

ele_spec_att.bsqsurf = &bsqsurf;
OM_stat = om$send (msg = message EMSsubbs.EMget_ele_header (&mthd_stat,
                    srf_geom, &md_env->md_env, NULL, &srf_ele_header, range,
                    &symb.display_attr, ele_spec_att, NULL),
                   senderid = NULL_OBJID,
                   targetid = srf_GRid.objid, targetos = srf_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_OMerror,wrapup);

/*
 * Build lc_parms and cvl structures
 */

{
   struct var_list  list_var[4];
   IGRlong   num_bytes, ret_bytes, which_error, num_points;
   IGRdouble scale, wvmat[16], vvol[6];
   IGRshort  dim;

   cvl.attributes.type = LC_BL_LOCATE;

   OM_BLOCK_MOVE(&locate_event.event.button, cvl.attributes.acc_point,
                 sizeof(IGRpoint));
 
   cvl.attributes.acc_line.point1 = &line_pt[0];
   cvl.attributes.acc_line.point2 = &line_pt[3];
   
   /*
    * get the dit tolerance
    */
    num_bytes = sizeof (IGRdouble);

    gr$get_dit_tolerance (msg = &mthd_stat, sizbuf = &num_bytes, 
                    buffer = &cvl.attributes.acc_tolerance, 
                    nret = &ret_bytes);

   /* 
    *    Calculate  boreline. 
    */

    list_var[0].var            = VVOL_VIEWPORT_SCALE;
    list_var[0].var_ptr        = (IGRchar *) &scale;
    list_var[0].num_bytes      = sizeof(IGRdouble);
    list_var[0].bytes_returned = &ret_bytes;

    list_var[1].var            = WLD_TO_VIEW;
    list_var[1].var_ptr        = (IGRchar *) wvmat;
    list_var[1].num_bytes      = sizeof(IGRdouble)*16;
    list_var[1].bytes_returned = &ret_bytes;

    list_var[2].var            = VW_VOLUME;
    list_var[2].var_ptr        = (IGRchar *) vvol;
    list_var[2].num_bytes      = sizeof(IGRdouble)*6;
    list_var[2].bytes_returned = &ret_bytes;

    list_var[3].var            = END_PARAM;
    list_var[3].var_ptr        = NULL;
    list_var[3].num_bytes      = 0;
    list_var[3].bytes_returned = NULL;

    status = dp$inq_set_gragad (msg = &mthd_stat,
               osnum = locate_event.event.button.osnum,
               gragad_objid = locate_event.event.button.objid,
               which_error = &which_error,
               var_list = list_var);
    EMerr_hndlr (!(1&status&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    cvl.attributes.acc_tolerance /= scale;

    OM_BLOCK_MOVE (cvl.attributes.acc_point, line_pt, sizeof(IGRpoint));

    num_points = 1;
    MAptsxform (&mthd_stat, &num_points, wvmat, line_pt, line_pt);

    line_pt[3] = line_pt[0];
    line_pt[4] = line_pt[1];
    line_pt[2] = vvol[2];
    line_pt[5] = vvol[5];

    dim = 4;
    MAinvmx (&mthd_stat, &dim, wvmat, wvmat);

    num_points = 2;

    MAptsxform (&mthd_stat, &num_points, wvmat, line_pt, line_pt);
    lc_parms = cvl.attributes;
}

/*
BL : 07/10/89	moved this statement before the co$getevent to prevent if 
 		there is no valid edge/vertex.

if (num_edges) ui_prompt (acc_prompt);
*/
   
while ( cur_entry < num_edges &&  
        accept_event->response == EX_RJT_MOVEON)
{
    /*
     * find out if the object (edge or vertex) is locatable.
     */

    was_located = FALSE;

    if (object_type == EMS_GET_MOD_EDGE)
    {
      OM_stat = om$send (msg = message EMSedge.EMlocate (&mthd_stat,
                          srf_geom, &md_env->md_env, &srf_GRid,
                          (struct GRlc_info *) &lc_parms,
                          &cvl,NULL,NULL,NULL,NULL,TRUE,&was_located),
                         senderid = NULL_OBJID,
                         targetid = edge_GRids[cur_entry].objid,
                         targetos = edge_GRids[cur_entry].osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      if (was_located) display_flag = EMS_WHL_EDGE;

    } /* if (object_type == EMS_GET_MOD_EDGE) */
    else
    {
       OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                           vx_uv, NULL, NULL, NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = edge_GRids[cur_entry].objid,
                          targetos = edge_GRids[cur_entry].osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
       
       BSsfeval (srf_geom, vx_uv[0], vx_uv[1], 0, (IGRpoint *)vx_xyz, &rc);
       EMerr_hndlr (rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
 
       sts = BSdistptli (&rc, vx_xyz, line_pt, &line_pt[3], &dist);
       EMerr_hndlr (!sts || rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

       if (dist <= cvl.attributes.acc_tolerance)
       {
         was_located = TRUE;
         display_flag = EMS_EDGE_BEG_PT;
       }

    } /* else for if (object_type == EMS_GET_MOD_EDGE) */

    if (was_located)
    {
      display_mode = GRhd;
      OM_stat = om$send (msg = message EMSboundary.EMgetobjinfo(
                          &mthd_stat, &object_info, display_flag),
                         senderid = NULL_OBJID,
                        targetid = edge_GRids[cur_entry].objid,
                        targetos = edge_GRids[cur_entry].osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      /*
       *   Highlight the element
       */
      OM_stat = om$send (msg = message EMSedge.EMdisplay (&mthd_stat, 
                          &srf_ele_header, &md_env->md_env.matrix_type, 
                          md_env->md_env.matrix, &display_mode, NULL,
                          display_flag, NULL),
                         senderid = NULL_OBJID,
                         targetid = edge_GRids[cur_entry].objid,
                         targetos = edge_GRids[cur_entry].osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

      *obj_hilited = TRUE;
/*
      new_mask = *mask | GRm_RJT_MOVEON;
*/
      ex$message(in_buff = object_info.type)

      if (num_edges) ex$message(in_buff = acc_prompt, field = PROMPT_FIELD)
/*
      status = GRgetevent (&mthd_stat, &new_mask, size, accept_event, 
                           response, response_data);
*/
        status = co$getevent (
            msg = &mthd_stat,
            event_mask = *mask | GRm_RJT_MOVEON,
            response = response,
            response_data = response_data,
            event = accept_event
        );

      EMerr_hndlr(!(1&mthd_stat&status),*EMmsg,EMS_E_Fail,wrapup);

      switch (accept_event->response)
      {
       case EX_RJT_MOVEON:
       case EX_BACK_UP:
         /* 
          *  The case of the rejected object
          *  unhilight and increment stack if possible
          */

          display_mode = GRhe;
          OM_stat = om$send (msg = message EMSedge.EMdisplay (&mthd_stat, 
                            &srf_ele_header, &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &display_mode, NULL,
                            display_flag, NULL),
                           senderid = NULL_OBJID,
                           targetid = edge_GRids[cur_entry].objid,
                           targetos = edge_GRids[cur_entry].osnum);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          *obj_hilited = FALSE;
          cur_entry++;
          break;


        case GR_UNKNOWN_TYPE:
          break;
    
        default:

          /*
           * if the response is neither EX_RJT_MOVEON, EX_BACK_UP 
           * or GR_UNKNOWN_TYPE, 
           * it is an indication of accepted object.
           */

          accept_event->located_object[0].located_obj = 
                                                 edge_GRids[cur_entry];

          accept_event->located_object[0].module_info = *md_env;
          object_accepted = TRUE;
          break;

      } /* switch (accept_event->response) */

    } /* if (was_located) */

    else  ++cur_entry;

} /* while ( cur_entry < num_edges &&  
             accept_event->response == EX_RJT_MOVEON) */

if(cur_entry == num_edges && !was_located) 
 ex$message(msgnumb = EMS_S_InvInp)

wrapup:
    if ( *obj_hilited && ( !(1 & OM_stat) || !(1 & mthd_stat) ||
                    !object_accepted) )
    {
      display_mode = GRhe;
      OM_stat = om$send (msg = message EMSedge.EMdisplay ( &mthd_stat, 
                          &srf_ele_header, &md_env->md_env.matrix_type, 
                          md_env->md_env.matrix, &display_mode, NULL,
                          display_flag, NULL),
                         senderid = NULL_OBJID,
                         targetid = edge_GRids[cur_entry].objid,
                         targetos = edge_GRids[cur_entry].osnum);

       *obj_hilited = FALSE;
   
    }
    
   if (accept_event->response == EX_RJT_MOVEON)
           accept_event->response = response[0] = EX_BACK_UP;

    EMWRAPUP (*EMmsg, OM_stat, "In EMtpselect");

    return( OM_stat );
}
end implementation Root;

