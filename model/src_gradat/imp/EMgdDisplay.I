/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "OMmacros.h"      /* OM_BLOCK_MOVE                    */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dpdef.h"         /* dp$dispelem                      */
# include "dpmacros.h"      /* dp$dispelem                      */
# include "EMSlogic.h"      /* EMSmsgReport                     */
# include "EMStypedef.h"    /* EMSmsgReport                     */
# include "EMScmacros.h"    /* EMSmsgReport                     */
# include "EMSmsgdef.h"     /* EMSmessage codes                 */
# include "EMSfrtdef.h"     /* EMFRT_UPTODATE, RLT_BUFFER_SIZE  */
# include "EMSlmdef.h"      /* EMS_WHL_EDGE                     */
# include "EMSfrtmacros.h"  /* frt$update                       */
# include "msdef.h"         /* MSSUCC                           */
# include "dperr.h"         /* DPSTOPDRAW                       */
# include "emserr.h"        /* EMWRAPUP                         */
# include "emsdef.h"

from EMSboundary import EMgetsurface_info;
from EMSsubbs import EMget_ele_header;

method EMdisplay(IGRlong *EMmsg; IGRboolean owner_origin;
                 enum GRdpmode *mode; struct DP_information *sp_info;
                 struct IGResbs *bs_attr; struct DPele_header *ele_header;
                 IGRshort *mx_type; IGRmatrix matrix; IGRchar *buffer;
                 IGRint buffer_size; struct EMSpartolbasis *partol;
                 IGRboolean *display_done; struct GRid *window_id)
/*
History

    10/03/92    msm ANSI-C conversion.
    12/26/91    pp  Added support if sp_info coming in is NULL. This 
                    happens in the case of "Removing and displaying
                    disjoint regions". 
    20-July-91  AIC Make rule lines on/off window-specific.
    20-June-91  AIC Moved initialization of surface_rlt to top of file.
    04-June-91 Jack Exit if rule line display is off.  2.0.1 Horizon Loops.
    30 Nov 1989 RC  Removed the display of the edges as it will 
                    done by the surface.
    02 Jan 1989 AIC Allow for alternate display attributes.

    11 Nov 1988 jBk Enhanced so if input pointer to struct
                    DPele_header is NULL, the struct DPele_header is
                    derived here.
                    Changed type of local variable, surface_rlt, from
                    pointer to nonexistent struct IGResqs to point to
                    struct IGResqbs.
                    Added else clause to "if (bs_attr)" so one can
                    have a valid ele_header->ele_spec_att.bsqsurf->*
                    even if there is no bs_attr.
                    Enhanced to use dp$display with ex$get_cur_mod,
                    instead of dp$dispelem, when there is sp_info is
                    input as NULL.

    15 Jul 1987 AIC Creation Date

*/
{
  IGRchar               local_buffer[RLT_BUFFER_SIZE];
  IGRboolean            dis_att_saved = FALSE;
  IGRlong               sts;
  struct IGResqbs       *surface_rlt;
  struct IGRaltdisplay  alt_display;
  IGRuint       rgb_value;
  short unsigned        color;
  IGRuchar      weight;
  IGRuchar      style;
  struct IGRdisplay     save_dis_att;
  struct DPele_header   localDPele_header;
  GRrange               dummyGRrange;
  struct IGRdisplay     dummyIGRdisplay;
  union IGRele_attr     dummyIGRele_attr;
  struct IGResqbs       dummyIGResqbs;
  struct GRmdenv_info   mdenv_info;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  if (ele_header)
   surface_rlt = ele_header->ele_spec_att.bsqsurf;

  if(!sp_info || (sp_info && ! (sp_info->gragad->flags & DP_NO_RULE_LINES)))
  {  /* only want to come in here if rule line display is on */

    if(!ele_header)
    {
      OM_S_CHANSELECT toRequesters;
      OM_S_OBJID sfoid;

      sts = EMmake_chanselect (EMShelper_to_requesters, &toRequesters);
      if (EMSerror (sts)) goto wrapup; /* !UGH! */

      sts = om$send(msg = message EMSboundary.EMgetsurface_info(
                      EMmsg,
                      &sfoid,
                      NULL),
                    p_chanselect = &toRequesters);

      if (NOT (EMSokay (sts) AND EMSokay (*EMmsg))) goto wrapup;

      dummyIGRele_attr.bsqsurf = &dummyIGResqbs;

      mdenv_info.matrix_type = *mx_type;
      OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

      sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
                      &mdenv_info, NULL, &localDPele_header, dummyGRrange,
                      &dummyIGRdisplay, dummyIGRele_attr, NULL),
                    targetid = sfoid);
      if(NOT (EMSokay (sts) AND EMSokay (*EMmsg))) goto wrapup;

      ele_header = &localDPele_header;
      surface_rlt = ele_header->ele_spec_att.bsqsurf;
    } /* end else (NOT ele_header) */

    if(! buffer) buffer_size = 0;

    if(! ((me^^EMShelper.props & EMGD_UPTODATE) &&
          (me^^EMShelper.props & EMGD_TRIMMED)))
    {
      /*
       * Update myself
       */
      sts = frt$update(rc = EMmsg, mx_type = mx_type, mx = matrix,
                       rlt = &surface_rlt, bs_attr = bs_attr,
                       buffer = buffer, buffer_size = buffer_size,
                       partol_basis = partol, objid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }

    /*
     * Get my rule line table
     */
    {
      IGRint            local_buffer_size;

      local_buffer_size = RLT_BUFFER_SIZE;
      ele_header->ele_spec_att.bsqsurf = NULL;
      sts = om$send(msg = message EMSgradata.EMgetRLT(EMmsg, local_buffer,
                    local_buffer_size, &ele_header->ele_spec_att.bsqsurf),
                    targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }

    /*
     * Get the element specific attributes to be used.
     */
    if (bs_attr) /* use overrides -- jBk */
    {
      ele_header->ele_spec_att.bsqsurf->is_polydis = bs_attr->is_polydis;
      ele_header->ele_spec_att.bsqsurf->is_surfdis = bs_attr->is_surfdis;
      ele_header->ele_spec_att.bsqsurf->is_slowdis = bs_attr->is_slowdis;
      ele_header->ele_spec_att.bsqsurf->type = bs_attr->type;
    }
    else /* use the defaults -- jBk */
    {
      ele_header->ele_spec_att.bsqsurf->is_polydis =
          surface_rlt->is_polydis;
      ele_header->ele_spec_att.bsqsurf->is_surfdis =
          surface_rlt->is_surfdis;
      ele_header->ele_spec_att.bsqsurf->is_slowdis =
          surface_rlt->is_slowdis;
      ele_header->ele_spec_att.bsqsurf->type =
          surface_rlt->type;
    }

    ele_header->ele_spec_att.bsqsurf->rules_specified = TRUE;

    /*
     * If the polygon has been displayed, don't do it again.
     */
    if(*display_done) ele_header->ele_spec_att.bsqsurf->is_polydis = FALSE;

    if(me->props & EMGD_ALTDISPLAY)
    {
      /*
       * Save the current display attributes
       */
      save_dis_att = *(ele_header->dis_att);
      dis_att_saved = TRUE;

      /*
       * Get the alternate display attributes
       */
/*    alt_display.rgb_value = NULL; */
      alt_display.color = NULL;
      alt_display.weight = NULL;
      alt_display.style = NULL;
      sts = om$send(msg = message EMSgradata.EMgetAlternateDisplay(EMmsg,
                      &rgb_value, &color, &weight, &style, &alt_display),
                    targetid = my_id);
      if(! (1 & sts & *EMmsg)) goto wrapup;

      /*
       * Store the new display attributes in the element header
       */
/*    if(alt_display.rgb_value)
        ele_header->dis_att->rgb_value = alt_display.rgb_value[0]; */
      if(alt_display.color)
        ele_header->dis_att->color = alt_display.color[0];
      if(alt_display.weight)
        ele_header->dis_att->weight = alt_display.weight[0];
      if(alt_display.style)
        ele_header->dis_att->style = alt_display.style[0];
    }

    /*
     * If there are no rule lines and the polygon is off,
     * don't display me.
     */
    if((ele_header->ele_spec_att.bsqsurf->u_rules) ||
       (ele_header->ele_spec_att.bsqsurf->v_rules) ||
       (ele_header->ele_spec_att.bsqsurf->is_polydis))
    {
      /*
       * Display the rule lines and/or polygon
       */
      if (sp_info)
      {
        /*
         * Perform the display
         */
        dp$dispelem(msg = EMmsg,
                    buffer = ele_header,
                    mode = *mode,
                    dp_info = sp_info);
      }
      else
      {
        struct GRid moduleGRid;

        ex$get_cur_mod(id = &moduleGRid.objid,
                       osnum = &moduleGRid.osnum);

        dp$display(msg = EMmsg,
                   osnum = moduleGRid.osnum,
                   objid = moduleGRid.objid,
                   mode = *mode,
                   buffer = ele_header);
      }

      if(*EMmsg IS DPSTOPDRAW) goto wrapup;
    }

    /*
     * Resposibility for display has been accepted
     */
    *display_done = TRUE;

  } /* end if( rule_lines_on ) */

wrapup:
  /*
   * Restore the display attributes
   */
  if(dis_att_saved) ele_header->dis_att[0] = save_dis_att;

  /*
   * Restore the input rule line table. (If the surface's rule line
   * table wasn't provided but was used, then that rule line table will
   * be placed in the element header.)
   */
  if((ele_header->ele_spec_att.bsqsurf) &&
     (ele_header->ele_spec_att.bsqsurf ISNT (struct IGResqbs *)local_buffer) &&
     (ele_header->ele_spec_att.bsqsurf ISNT surface_rlt))
    om$dealloc (ptr = ele_header->ele_spec_att.bsqsurf);
  ele_header->ele_spec_att.bsqsurf = surface_rlt;

  EMSmsgReport(sts, "EMSgradata.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSgradata.EMdisplay", FALSE);
  if(*EMmsg IS DPSTOPDRAW)
  {
    sts = OM_I_STOP_SENDING;
  }
  else
  {
    *EMmsg = MSSUCC;
    sts = OM_S_SUCCESS;
  }
  return(sts);
}

end implementation EMSgradata; 
