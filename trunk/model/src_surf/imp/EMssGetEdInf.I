/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "EMSbnddef.h"
# include "EMSprop.h"
# include "emsmacros.h"
# include "EMSopt.h"
# include "emsedgedef.h"
# include "gocmacros.h"     /*  GRgetabsg macro */
# include "bsparameters.h"
# include "bserr.h"
 
#define EDGEU0 0
#define EDGEV1 1
#define EDGEU1 2
#define EDGEV0 3

#define CONSTANT_V 2
#define CONSTANT_U 1

method EMget_natedge_info (
    IGRlong                     *EMmsg;
    struct GRmdenv_info         *md_env;
    IGRuchar            *curve_type;
    IGRushort           *edge_props) 

/*
Description
        The method evaluates and returns the curve type
        of its natural edges.

        It also evaluates and returns the following edge properties 
        for its natural edges.

        EMED_DEGENERATE
        EMED_XYZ_CLOSED
        EMED_SEAM
        EMED_REVERSE_CONNECT.

Arguments
        EMmsg   -- output

        md-env  -- input
                module environment info of the surface.

        curve_type -- output
                An array of natural edges' curve type.

        edge_props -- output
                An array of natural edges' properties.
        
    
History
	SM     06-Sep-89: The method used to always return free form curve
			  as the edge type. Modified so that when appropriate
			  it will return a linear edge type. Also, set edge 
			  type to point if a natural side is degenerate.
        PP     12/01/87 : Made modifications so that the caller can null out
                          edge properties or edge type field if he is not
                          interested
        RC     11/10/87 : Creation Date
*/

{
struct IGRbsp_surface   *srf_geom;
IGRdouble               distsq_tol, distsq, uv, *begin_pt, *end_pt;
  extern IGRdouble               BSdistptpts();
IGRlong                 OM_stat;
IGRlong   mthd_stat, num_poles, num_malloced_poles;
IGRlong                 u0v0_pole, u0v1_pole, u1v1_pole, u1v0_pole;
BSrc                    rc;
IGRint                  i, nat_edge;
IGRshort                option, order, num_boundaries;
IGRboolean              status, rational, tst_plan, is_degen, xyz_closed,
                        seam_ed;
IGRchar                 *cache_ptr;
struct IGRbsp_curve     *curve;
  extern void                    BSalloccv();
  extern void   BStstcvdegn();

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

srf_geom = NULL;
cache_ptr = NULL;
curve= NULL;

/*
 * put curve type
 */

if (curve_type)
{
for (i = 0; i < 4; i++)
  curve_type[i] = EMfreeform_curve;
}

GRgetabsg (&mthd_stat, &md_env->matrix_type, md_env->matrix,
           &cache_ptr, i);
EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

srf_geom = (struct IGRbsp_surface *) cache_ptr;

status = BSEXTRACTPAR (&mthd_stat, BSTOLSQLENVEC, distsq_tol);

u0v0_pole = 0;
u0v1_pole = (srf_geom->u_num_poles * srf_geom->v_num_poles * 3)- 
                             (srf_geom->u_num_poles * 3);
u1v1_pole = (srf_geom->u_num_poles * srf_geom->v_num_poles * 3) - 3;
u1v0_pole = (srf_geom->u_num_poles * 3) - 3;

if (srf_geom->u_num_poles > srf_geom->v_num_poles)
  num_malloced_poles = srf_geom->u_num_poles;
else 
  num_malloced_poles = srf_geom->v_num_poles;

if (srf_geom->u_order > srf_geom->v_order)
 order = srf_geom->u_order;
else
 order = srf_geom->v_order;

rational = srf_geom->rational;
num_boundaries  = 0;

(void) BSalloccv (order,  num_malloced_poles, rational, num_boundaries, 
                  &curve, &rc);
 EMerr_hndlr( (rc != BSSUCC), *EMmsg,EMS_E_BSerror, wrapup);

 if(edge_props)
  for (nat_edge = 0; nat_edge < 4; nat_edge++) edge_props[nat_edge] = 0;

for ( nat_edge = 0; nat_edge < 4; nat_edge++)
{
   /*
    * check if the natural edge is a degenerate edge
    */

   switch (nat_edge)
   {
 
      case EDGEU0:
      case EDGEU1:

        option = CONSTANT_U;
        uv = (nat_edge == 2) ?  1.0 : 0;
        num_poles = srf_geom->v_num_poles;
        order = srf_geom->v_order;
        break;

      case EDGEV1:
      case EDGEV0:

        option = CONSTANT_V;
        uv =  (nat_edge == 1) ? 1.0 : 0.;
        num_poles = srf_geom->u_num_poles;
        order = srf_geom->u_order;
        break;
 
   } /* switch (nat_edge) */

   num_boundaries  = 0;

   tst_plan = FALSE;
   status = BSconstprcv (&rc, srf_geom, &option, &uv, &tst_plan, curve);
   EMerr_hndlr( (rc != BSSUCC || !status), *EMmsg,EMS_E_BSerror, wrapup);

   (void) BStstcvdegn (curve, &is_degen, &rc);

   EMerr_hndlr( (rc != BSSUCC), *EMmsg,EMS_E_BSerror, wrapup);

   if (is_degen && edge_props) edge_props[nat_edge] |= EMED_DEGENERATE;

   /* Following 'if' statement added SM 06-Sep-89.
   */
   if(curve_type)
    {
     if(is_degen) curve_type[nat_edge] = EMpoint;
/*
 * Added the check for non-uniform for Hidden line processing.
 * We need to do this so that HLP can make the assumption that
 * the edges have the same parametrization as the surface.
 * pp 08/26/91
 */ 
     else if((curve->order == 2) && !(curve->non_uniform))
      curve_type[nat_edge] = curve->num_poles == 2 ? EMlinesegment 
						   : EMlinestring; 
    }

   /*
    * check if the edge is closed in model space. If
    * the edge is a degenerate edge, it can not be closed
    * in model space.
    */

   if (edge_props && !(edge_props[nat_edge] & EMED_DEGENERATE))
   {
     xyz_closed = FALSE;

     switch (nat_edge)
     {

        case EDGEU0:
        case EDGEU1:
          if (srf_geom->v_phy_closed)
          xyz_closed = TRUE;
          break;

        case EDGEV1:
        case EDGEV0:
          if (srf_geom->u_phy_closed)
          xyz_closed = TRUE;
          break;

     } /* switch (nat_edge) */

     /*
      * couldn't determine if my natural edge is
      * closed. So next step is to compare natural 
      * edge end points in the (xyz) space. Since,
      * it is a natural edge, the surface poles at the corners
      * can be directly used for comparision. This way,
      * unnecessary surface evaluations can be avoided.
      */

     if (!xyz_closed)
     {
      switch(nat_edge)
      {
         case EDGEU0:
            begin_pt = &srf_geom->poles[u0v0_pole];
            end_pt = &srf_geom->poles[u0v1_pole];
            break;

         case EDGEV1:
            begin_pt = &srf_geom->poles[u0v1_pole];
            end_pt = &srf_geom->poles[u1v1_pole];
            break;

         case EDGEU1:
            begin_pt = &srf_geom->poles[u1v1_pole];
            end_pt = &srf_geom->poles[u1v0_pole];
            break;

         case EDGEV0:
            begin_pt = &srf_geom->poles[u1v0_pole];
            end_pt = &srf_geom->poles[u0v0_pole];
            break;
        
      } /* switch(nat_edge) */

      /*
       * compare the distance squared between the begin and end pt
       * with tolerance. If they are within the tolerance, the
       * edge is closed in (x,y,z) space. 
       */

      distsq = BSdistptpts (&rc, begin_pt, end_pt);
      if (distsq <= distsq_tol) xyz_closed = TRUE;

     } /* if (!(xyz_closed)) */

     if (xyz_closed && edge_props) edge_props[nat_edge] |= EMED_XYZ_CLOSED;

   } /* if (edge_props && !(edge_props[nat_edge] & EMED_DEGENERATE)) */

} /* for ( nat_edge = 0; nat_edge < 4; nat_edge++) */

/*
 * check if the natural edge is a seam edge. It is assumed
 * only EDGEU0 and EDGEU1 can be seam edges or EDGEV0 and
 * EDGEV1 can be seam edges. Also if any of the pairs are
 * seam edges, they are reverse connected too.
 */

for ( nat_edge = 0; (nat_edge < 2) && edge_props; nat_edge++)
{
  seam_ed = FALSE;

  switch (nat_edge)
  {
     case EDGEU0:
       if (srf_geom->u_phy_closed) seam_ed = TRUE;
       break;

     case EDGEV1:
       if (srf_geom->v_phy_closed) seam_ed = TRUE;
       break;

   } /* switch (nat_edge) */

  if (seam_ed)
  {
   edge_props[nat_edge] |= EMED_SEAM | EMED_REVERSE_CONNECT | EMED_SUBORDINATE;
   edge_props[nat_edge+2] |= EMED_SEAM | EMED_REVERSE_CONNECT;

  } /* if (seam_ed) */

} /* for ( nat_edge = 0; (nat_edge < 2) && edge_props; nat_edge++) */

wrapup:

EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMget_natedge_info");
if (curve) status = BSfreecv (&rc, curve); 
if (cache_ptr) GRabsg_del(cache_ptr);

  return (OM_stat);
}

end implementation EMSsubbs;
