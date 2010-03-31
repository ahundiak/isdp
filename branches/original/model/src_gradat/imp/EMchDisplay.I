/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

/*
History

    02 Oct 92       msm     ANSI-C conversion.   
    30 Nov 89       RC      Removed the display of the edges as it will 
                            done by the surface.
    11 Jan 89       RC      Modified to allow material cross hatch
                            patterns
    02 Jan 1989     AIC     Modified to support alternate display
                            attributes.
    28 Apr 88       AIC     Changed EMFRT_UPTODATE to EMGD_UPTODATE
    12/07/87        RC      Modified as u-scale and v-scale are
                            taken out from instance data.
    15 July 1987    AIC     Creation Date
*/

# ifndef OMmacros_include
# include "OMmacros.h"      /* OM_BLOCK_MOVE                    */
# endif

# ifndef dpdef_include
# include "dpdef.h"         /* dp$dispelem                      */
# endif

# ifndef dpmacros_include
# include "dpmacros.h"      /* dp$dispelem                      */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport                     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport                     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport                     */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMSmessage codes                 */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE, RLT_BUFFER_SIZE   */
# endif

# ifndef EMSlmdef_include
# include "EMSlmdef.h"      /* EMS_WHL_EDGE                     */
# endif

# ifndef EMSfrtmacros_include
# include "EMSfrtmacros.h"  /* frt$update                       */
# endif

# ifndef msdef_include
# include "msdef.h"         /* MSSUCC                           */
# endif

# ifndef dperr_include
# include "dperr.h"         /* DPSTOPDRAW                       */
# endif

# include "emsdef.h"

from EMSloop import EMtree_traverse;
from EMSedge import EMdisplay;

IGRdouble  EMScrossHatchPlaneBuffer[DBL_CROSS_HATCH_PLANE_BUFFER_SIZE];

method EMdisplay(IGRlong *EMmsg; IGRboolean owner_origin;
                 enum GRdpmode *mode; struct DP_information *sp_info;
                 struct IGResbs *bs_attr; struct DPele_header *ele_header;
                 IGRshort *mx_type; IGRmatrix matrix; IGRchar *buffer;
                 IGRint buffer_size; struct EMSpartolbasis *partol;
                 IGRboolean *display_done; struct GRid *window_id)
{
  IGRboolean                dis_att_saved = FALSE;
  IGRlong                   sts;
  IGRchar                   local_buffer[RLT_BUFFER_SIZE];
  struct IGResqbs           nat_edge_rlt;
  struct IGResqbs           *surface_rlt;
  struct IGRbsp_surface     *new_surface;
  struct IGRaltdisplay      alt_display;
  IGRuint           rgb_value;
  short unsigned            color;
  IGRuchar          weight;
  IGRuchar          style;
  struct IGRdisplay         save_dis_att;
  IGRint                    total_bytes;
  struct IGRbsp_surface     *old_surface;

  extern void               EFget_xh_sf_geom();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  new_surface = (struct IGRbsp_surface *)EMScrossHatchPlaneBuffer;
  surface_rlt = ele_header->ele_spec_att.bsqsurf;
  if(! buffer) buffer_size = 0;

  if(! (me^^EMShelper.props & EMGD_UPTODATE))
  {
    /*
     * Update myself
     */
    sts = frt$update(rc = EMmsg,
                     mx_type =      mx_type,
                     mx =           matrix,
                     rlt =          &surface_rlt,
                     bs_attr =      bs_attr,
                     surface =      ele_header->geometry.bspsurf,
                     buffer =       buffer,
                     buffer_size =  buffer_size,
                     partol_basis = partol,
                     objid =        my_id);
  }

  /*
   * Get my rule line table
   */
  {
    IGRint            local_buffer_size;

    local_buffer_size = RLT_BUFFER_SIZE;
    ele_header->ele_spec_att.bsqsurf = NULL;
    sts = om$send(msg = message EMSgradata.EMgetRLT(
                    EMmsg,
                    local_buffer,
                    local_buffer_size,
                    &ele_header->ele_spec_att.bsqsurf),
                  targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

  /*
   * Get the element specific attributes to be used.
   */
  if(bs_attr)
  {
    ele_header->ele_spec_att.bsqsurf->is_polydis = bs_attr->is_polydis;
    ele_header->ele_spec_att.bsqsurf->is_surfdis = bs_attr->is_surfdis;
    ele_header->ele_spec_att.bsqsurf->is_slowdis = bs_attr->is_slowdis;
    ele_header->ele_spec_att.bsqsurf->type = bs_attr->type;
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
/*  alt_display.rgb_value = NULL; */
    alt_display.color = NULL;
    alt_display.weight = NULL;
    alt_display.style = NULL;
    sts = om$send(msg = message EMSgradata.EMgetAlternateDisplay(
                    EMmsg,
                    &rgb_value,
                    &color,
                    &weight,
                    &style,
                    &alt_display),
                  targetid = my_id);
    if(! (1 & sts & *EMmsg)) goto wrapup;

    /*
     * Store the new display attributes in the element header
     */
/*  if(alt_display.rgb_value)
      ele_header->dis_att->rgb_value = alt_display.rgb_value[0]; */
    if(alt_display.color)
      ele_header->dis_att->color = alt_display.color[0];
    if(alt_display.weight)
      ele_header->dis_att->weight = alt_display.weight[0];
    if(alt_display.style)
      ele_header->dis_att->style = alt_display.style[0];
  }

  if(ele_header->ele_spec_att.bsqsurf->is_polydis)
  {
    IGRint    u_rules, v_rules;

    /*
     * Display the polygon
     */
    u_rules = ele_header->ele_spec_att.bsqsurf->u_rules;
    v_rules = ele_header->ele_spec_att.bsqsurf->v_rules;
    ele_header->ele_spec_att.bsqsurf->u_rules = 0;
    ele_header->ele_spec_att.bsqsurf->v_rules = 0;

    dp$dispelem(msg =       EMmsg,
                buffer =    ele_header,
                mode =      *mode,
                dp_info =   sp_info);

    ele_header->ele_spec_att.bsqsurf->u_rules = u_rules;
    ele_header->ele_spec_att.bsqsurf->v_rules = v_rules;
    ele_header->ele_spec_att.bsqsurf->is_polydis = FALSE;
  }

  /*
   * If there are no rule lines and the polygon is off,
   * don't display me.
   */
  if((ele_header->ele_spec_att.bsqsurf->u_rules) ||
     (ele_header->ele_spec_att.bsqsurf->v_rules))
  {
    IGRint  l, i;

    /*
     * Display the rule lines
     */
    old_surface = ele_header->geometry.bspsurf;
    EMSbs_size(old_surface->u_order,
               old_surface->v_order,
               old_surface->u_num_poles,
               old_surface->v_num_poles,
               old_surface->rational,
               0,
               (IGRlong *)NULL,
               total_bytes)

    if(total_bytes > CROSS_HATCH_PLANE_BUFFER_SIZE)
    {
      new_surface = (struct IGRbsp_surface *)om$malloc(size=total_bytes);
      if(! (new_surface)) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }

    EMSbs_partition(old_surface->u_order,
                    old_surface->v_order,
                    old_surface->u_num_poles,
                    old_surface->v_num_poles,
                    old_surface->rational,
                    0,
                    (IGRlong *) NULL,
                    new_surface)

    EFget_xh_sf_geom(EMmsg,
                     me->angle,
                     NULL,
                     NULL,
                     old_surface,
                     new_surface);
    if(! (1 & *EMmsg)) goto wrapup;

    ele_header->geometry.bspsurf = new_surface;

    for(l = 0; l < 2; l ++)
    {
      IGRdouble                 **rule_values, ***clips;
      IGRint                    num_sgrps, *num_rules, **num_clips;
      struct EMSxh_sgrp_info    *sgrps;

      if(l IS U)
      {
        ele_header->ele_spec_att.bsqsurf->v_rules = 0;
        rule_values = &ele_header->ele_spec_att.bsqsurf->u_rule_values;
		num_rules = (IGRint *)&ele_header->ele_spec_att.bsqsurf->u_rules;
		num_clips = &ele_header->ele_spec_att.bsqsurf->u_num_bound;
		clips = &ele_header->ele_spec_att.bsqsurf->u_bdrys;
        num_sgrps = me->num_u_sgrps;
        sgrps = me->sgrp_info;
      }
      else
      {
        ele_header->ele_spec_att.bsqsurf->u_rules = 0;
        rule_values = &ele_header->ele_spec_att.bsqsurf->v_rule_values;
		num_rules = (IGRint *)&ele_header->ele_spec_att.bsqsurf->v_rules;
		num_clips = &ele_header->ele_spec_att.bsqsurf->v_num_bound;
		clips = &ele_header->ele_spec_att.bsqsurf->v_bdrys;
        num_sgrps = me->num_v_sgrps;
        sgrps = &me->sgrp_info[me->num_u_sgrps];
      }

      for(i = 0; i < num_sgrps; i ++)
      {
        ele_header->dis_att->style = sgrps[i].style;
		num_rules[0] = sgrps[i].num_rls_this_style;

        dp$dispelem(msg =       EMmsg,
                    buffer =    ele_header,
                    mode =      *mode,
                    dp_info =   sp_info);

        if(*EMmsg IS DPSTOPDRAW) goto wrapup;
        (*rule_values) += sgrps[i].num_rls_this_style;
		(*clips) += sgrps[i].num_rls_this_style;
		(*num_clips) += sgrps[i].num_rls_this_style;
      }
    }

    ele_header->geometry.bspsurf = old_surface;
  }


  /*
   * Resposibility for display has been accepted
   */
  *display_done = TRUE;

  /*
   * Display the edges
   */
/*
  {
    IGRuchar    save_style;
    OM_S_CHANSELECT     to_requesters;

    EMmake_chanselect (EMShelper_to_requesters, &to_requesters);

    save_style = ele_header->dis_att->style;
    ele_header->dis_att->style = 0;
    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message EMSloop.EMtree_traverse(
                    EMmsg,
                    message EMSedge.EMdisplay(
                        EMmsg,
                        ele_header,
                        mx_type,
                        matrix,
                        mode,
                        sp_info,
                        EMS_WHL_EDGE,
                        NULL),
                    2,
                    1,
                    &OPP_EMSedge_class_id,
                    TRUE,
                    NULL,
                    NULL,
                    NULL),
                  p_chanselect = &to_requesters,
                  from = 1, to = 1);
    ele_header->dis_att->style = save_style;
    if (sts = OM_E_NOSUCHOBJ) sts = OM_S_SUCCESS;
    if(! (1 & *EMmsg & sts)) goto wrapup;
}
*/

   {
    IGRuchar    save_style;
    OM_S_CHANSELECT     to_requesters;
    unsigned int        num_requesters;

    EMmake_chanselect (EMShelper_to_requesters, &to_requesters);

    sts = om$get_channel_count (object = me, 
             p_chanselect = &to_requesters, count = &num_requesters);
    if (!(1&sts)) goto wrapup;

    if(num_requesters == 1)
    {
      IGRint            num_bound[2];
      IGRdouble         rule_values[2];
      /*
       * Set up a rule line table to display natural edges
       */
      num_bound[0] = num_bound[1] = 0;
      rule_values[0] = 0;
      rule_values[1] = 1;
      nat_edge_rlt.u_rules = 2;
      nat_edge_rlt.v_rules = 2;
      nat_edge_rlt.is_polydis = FALSE;
      nat_edge_rlt.is_surfdis = TRUE;
      nat_edge_rlt.is_slowdis = FALSE;
      nat_edge_rlt.type = NULL;
      nat_edge_rlt.rules_specified = TRUE;
      nat_edge_rlt.u_rule_values = rule_values;
      nat_edge_rlt.v_rule_values = rule_values;
      nat_edge_rlt.u_num_bound = num_bound;
      nat_edge_rlt.v_num_bound = num_bound;
      nat_edge_rlt.u_bdrys = NULL;
      nat_edge_rlt.v_bdrys = NULL;

      /*
       * Display the natural edges
       */

      ele_header->ele_spec_att.bsqsurf = &nat_edge_rlt;
      save_style = ele_header->dis_att->style;
      ele_header->dis_att->style = 0;

      dp$dispelem(msg =     EMmsg,
                  buffer =  ele_header,
                  mode =    *mode,
                  dp_info = sp_info);

      ele_header->dis_att->style = save_style;

    } /* if(num_requesters == 1) */
  }

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
     (ele_header->ele_spec_att.bsqsurf ISNT &nat_edge_rlt) &&
     (ele_header->ele_spec_att.bsqsurf ISNT surface_rlt))
    om$dealloc (ptr = ele_header->ele_spec_att.bsqsurf);
  ele_header->ele_spec_att.bsqsurf = surface_rlt;
  if(new_surface && ((IGRdouble *)new_surface ISNT EMScrossHatchPlaneBuffer))
    om$dealloc (ptr = new_surface);

  EMSmsgReport(sts, "EMSchatch.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSchatch.EMdisplay", FALSE);

  if(*EMmsg IS DPSTOPDRAW) sts = OM_I_STOP_SENDING;
  else { *EMmsg = MSSUCC; sts = OM_S_SUCCESS; }

  return(sts);
}

end implementation EMSchatch; 
