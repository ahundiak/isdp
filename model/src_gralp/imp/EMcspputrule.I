/* ###################   APOGEE COMPILED   ################## */
class implementation EMScusp;

/*
History

    AIC  08 Oct 1990 Genesis
    AIC  08 Nov 1990 Added edge based rule lines
    Jack 30 Apr 1991 Modified for 2.0.1 Horizon Loops.
    Jack 15 Oct 1991 Added struct EMSpartolbasis parm.  

*/

from EMSlinedge import EMleinit;
from EMSsubbs   import EMpartolbasis;

#include "emsedgedef.h"
#include "msdef.h"
#include "dperr.h"
#include "OMmacros.h"


method EMput_rule_lines(struct IGResqbs        *rule_lines;
                         int                    is_cusp;
                         OM_S_OBJID             surface_id;
                         struct EMSpartolbasis *partolbasis)
{
  IGRint                ii, 
                        uv;
  IGRlong               EMmsg = EMS_S_Success, 
                        sts = OM_S_SUCCESS;
  OM_S_OBJID            edge_id;
  struct IGRpolyline    inpoly;
  IGRdouble             pts[4];
  OM_S_CHANSELECT       to_owner,
                        to_edges;

  /*
   * Set up the polyline structure
   */
  inpoly.num_points = 2;
  inpoly.points = pts;

  for(uv = U; uv <= V; uv ++)
  {
    int     num_rules;
    double  *rule_values;

    /*
     * Set up num_rules and rule_values
     */
    if(uv == U)
    {
      num_rules = rule_lines->u_rules;
      rule_values = rule_lines->u_rule_values;
    }
    else
    {
      num_rules = rule_lines->v_rules;
      rule_values = rule_lines->v_rule_values;
    }

    /*
     * Construct the edges
     */
    for(ii = 0; ii < num_rules; ii ++)
    {
      int   Ndex;

      /*
       * Set up the points
       */
      pts[0] = pts[1] = 0; pts[2] = pts[3] = 1;
      pts[uv] = pts[uv + 2] = rule_values[ii];

      /*
       * Construct and initialize the edge
       */
      sts = om$construct(classid = OPP_EMSlinedge_class_id,
                         p_objid = &edge_id);
      if(! (1 & sts)) goto wrapup;
	
      sts = om$send(msg = message EMSlinedge.EMleinit(
                                            &EMmsg, 
                                            (unsigned short)EMED_ISO,
                                            (unsigned char)EMlinesegment, 
                                            &inpoly, 
                                             partolbasis, 
                                             NULL,
                                             surface_id),
                    targetid = edge_id);
      if(! (1 & sts & EMmsg)) goto wrapup;
      
      /*
       * Add the edge to the feature.
       */
      Ndex = is_cusp ? 0 : MAXINT;

      sts = EMmake_chanselect( EMSedge_to_owner, &to_owner );
      EMerr_hndlr( !( 1 & sts ), EMmsg, EMS_E_OMerror, wrapup );

      sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
      if(! (1 & sts)) goto wrapup;
                
      /*
       * Add the edge to the feature.
       */
      sts = om$send(msg = message Root.connect(
                                       to_owner,         /* targ. chan */
                                       Ndex,             /* targ index */
                                       my_id,            /* send objid */
                                       OM_Gw_current_OS, /* send os    */
                                       to_edges,         /* send chan  */ 
                                       Ndex),            /* from index */
                          targetid = edge_id);
      if(! (1 & sts)) goto wrapup;

    } /* for each edge */

  } /* for u, v */


wrapup:
  EMWRAPUP(EMmsg, sts, "EMScusp.EMput_rule_lines")
  return sts;
}

end implementation EMScusp;
