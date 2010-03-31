/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# define CONSTANTU 1
# define CONSTANTV 2
# define MAX_POLES 60
# define MAX_KNOTS 80
# include "EMSerrordef.h"
# include "emsmacros.h"
# include "bserr.h"
# include "EMSconstruct.h"
# include "psdinc.h"

# include "gocmacros.h"     /* GRgetabsg macro  */
# include "madef.h"
# include "godef.h"
# include "ex.h"
# include "igrdp.h"
# include "dp.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"

from EMSplane import EMplane_of_curve;

extern OMuword OPP_EMSplane_class_id;

method EMcap_yourself (IGRlong *EMmsg;
                       IGRshort construct_option;
                       struct GRmd_env *env;
                       struct GRvg_construct *construct_list;
                       GRobjid *bottom_cap;
                       GRobjid *top_cap;
                       GRobjid *bottom_edgeids;
                       GRobjid *top_edgeids)


/* *************************************************************************

Description 
            This method caps a surface closed in one direction by the planes
            if the end curves are planar. In the current implementation, the
            end curves should not be boundaries.

            Input
             env      -         module environment of the surface
             construct_option - The following are construct options:

                                EMS_CONSTRUCT_BOTTOM_CAP: Construct cap
                                  lying on u=0 or v=0 isoparametric curve
                                
                                EMS_CONSTRUCT_TOP_CAP : Construct cap lying
                                  on u=1 or v=1 isoparametric curve

                                EMS_CONSTRUCT_BOTH_CAPS : Construct both
                                  caps
                                NULL : Should the option be null then
                                  the method will try to determine 
                                  which end is open and will cap the
                                  same. This option is not advised as
                                  the method goes through additional
                                  processing in determining degenerate
                                  edges.

                                The constants are defined in construct.h

             construct_list -   construction_information
             bottom_cap     -   GRid of the bottom cap of the plane which
                                is the plane corresponding to v=0 iso curve
                                if the surface is closed in u or the plane
                                corresponding to u=0 iso curve is the surface
                                is closed in v.
             top_cap        -   GRid of the cap at the other end. 
                                
             bottom_edgeids -   Edgeids of the bottom cap. Memory is 
                                expected to be allocated for the same.
                                Should the edgeids be not wanted, the field
                                may be set to null. The edgeids are returned
                                in a depth first left to right mode.
                                
             top_edgeids    -   Edgeids of the top cap. Memory is also
                                expected to be allocated for the same.
                                Should the edgeids be not wanted, the field
                                may be set to null. The edgeids are returned
                                in a depth first left to right mode.

Notes
             Upon exit the completion code will be one of the following:
              EMS_S_Success : if all goes well
              EMS_E_InvalidArg : if the arguments are invalid.
                                 which might happen if the surface is
                                 closed in both directions or if the open
                                 ends are non planar.
              EMS_I_TopCapDegenerate : if the top cap is degenerate
              EMS_I_BottomCapDegenerate : if the bottom cap is degenerate
              EMS_I_BothCapsDegenerate : if both the caps are degenerate
              EMS_E_Fail       : A catch all error
    
            If there is an error, the two caps are deleted and NULL_OBJIDS
            are returned in the fields for bottom_cap and top_cap.
            Bottom edgeids and top edgeids will then contain garbage. The
            caller need not bother about cleaning up of edgeids as this
            method takes the responsibility of cleaning up topology should
            there be an error.

History
     PP  : 05/03/88     Fixed a bug wherein I was setting module environment
                        to NULL while calling EMget_nat_edgeinfo
             PP      : 01/26/88         Argument changes to EMplane_of_curve
             PP      : 12/01/87         Made modifications to support
                                        setting of edge types
             PP      : 09/21/87         Changed the method to support
                                        construction of caps when there is
                                        no option specified. The method then
                                        would even process degenerate edges
             PP      : 08/26/87         Included options to construct
                                        bottom cap, top cap or both bottom
                                        and top cap
             PP      : 07/28/87         Design date

********************************************************************** */

{

 IGRshort               i;
 IGRlong                status;
 IGRlong                cln_sts,
                        cleanup_msg;

 struct IGRbsp_curve    gen_curve;
 struct IGRbsp_surface  *surf;   /* abstract geometry of myself */
 IGRboolean             memory_allocated = FALSE;
 IGRboolean             tst_plan = FALSE;
 IGRboolean             bssts;
 BSrc                   rc; 
 IGRshort               option;
 IGRshort               curve_order;
 IGRlong                curve_num_poles;
 IGRlong                num_bytes;
 
 IGRdouble              uv;
 IGRpoint               poles_buff[MAX_POLES];
 IGRdouble              weights_buff[MAX_POLES],
                        knots_buff[MAX_KNOTS];

 IGRboolean             test_degeneracy,
                        bottom_cap_degenerate = FALSE,
                        top_cap_degenerate = FALSE;

 IGRuchar       curve_type[4];
 IGRushort      bottom_cap_index, top_cap_index;
  extern  IGRboolean             BSconstprcv ();


 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 surf = NULL;

/*
 * I am not using GRgenabsg because the method EMplane_of_curve which I am
 * calling also uses the same.
 */


 status = om$send (msg = message GRvg.GRgetsize (EMmsg,
                         &env->md_env.matrix_type,
                         env->md_env.matrix,
                         &num_bytes),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_InvalidArg, wrapup);

 surf = (struct IGRbsp_surface *) om$malloc (size = num_bytes);

 status = om$send (msg = message GRvg.GRgetgeom (EMmsg,
                         &env->md_env.matrix_type, 
                         env->md_env.matrix,
                         (IGRchar *) surf),
                         targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_DynamicMemoryAllocated,
                  wrapup);

 status = om$send (msg = message EMSsubbs.EMget_natedge_info (EMmsg,
             &env->md_env,
                         &curve_type[0],
                         NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);

 if ((surf->u_phy_closed) && !(surf->v_phy_closed))
 {
   option = CONSTANTV;
   bottom_cap_index = 3;
   top_cap_index = 1;
   if (surf->u_num_poles >= MAX_POLES)
   {
     curve_num_poles = surf->u_num_poles;
     curve_order     = surf->u_order;
     memory_allocated = TRUE;
   }
 }
 else if ((surf->v_phy_closed) && !(surf->u_phy_closed))
 {
   option = CONSTANTU;
   bottom_cap_index = 0;
   top_cap_index = 2;
   if (surf->v_num_poles >= MAX_POLES)
   {
     curve_num_poles = surf->v_num_poles;
     curve_order =  surf->v_order;
     memory_allocated = TRUE;
   }
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if (memory_allocated)
 {
  gen_curve.poles = (IGRdouble *) om$malloc (size = sizeof (IGRpoint) *
                                             curve_num_poles);
  EMerr_hndlr (!gen_curve.poles, *EMmsg, EMS_E_DynamicMemoryAllocated,
                                 wrapup);

  gen_curve.knots = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                                             (curve_num_poles + curve_order));
  EMerr_hndlr (!gen_curve.knots, *EMmsg, EMS_E_DynamicMemoryAllocated,
                                 wrapup);
  if (surf->rational)
   {
    gen_curve.weights = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                                             (curve_num_poles));
    EMerr_hndlr (!gen_curve.weights, *EMmsg, EMS_E_DynamicMemoryAllocated,
                                   wrapup);
   }
  else 
    gen_curve.weights = NULL;
  }
  else
  {
    gen_curve.poles = (IGRdouble *) poles_buff;
    gen_curve.knots = knots_buff;
    if (surf->rational)
     gen_curve.weights = weights_buff;
    else
     gen_curve.weights = NULL;
  }
                                             
/*
 * Construct the bottom cap
 */

 if (construct_option == NULL)
   test_degeneracy = TRUE;
 else
   test_degeneracy = FALSE;

 if ((construct_option == EMS_CONSTRUCT_BOTTOM_CAP) || 
     (construct_option == EMS_CONSTRUCT_BOTH_CAPS) ||
     (construct_option == NULL))
 {
   uv = 0.0;
   bssts = BSconstprcv (&rc, surf, &option, &uv, &tst_plan, &gen_curve);
   EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

   status = om$construct (classid = OPP_EMSplane_class_id,
                          p_objid = bottom_cap, 
                          msg = message EMSplane.EMplane_of_curve (EMmsg,
                                construct_list, NULL, &gen_curve,
                                &curve_type[bottom_cap_index],
                                test_degeneracy,
                                TRUE, NULL,bottom_edgeids));
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
   if (!(1&status&*EMmsg))
   {
    *bottom_cap = NULL_OBJID;
    goto wrapup;
   }

   if (*EMmsg == EMS_I_Degenerate)
   {
     bottom_cap_degenerate = TRUE;
     *bottom_cap = NULL_OBJID;
   }
 }

  if ((construct_option == EMS_CONSTRUCT_TOP_CAP) ||
          (construct_option == EMS_CONSTRUCT_BOTH_CAPS) ||
          (construct_option == NULL))
 {

/*
 * Construct the top cap
 */

 uv = 1.0;
 bssts = BSconstprcv (&rc, surf, &option, &uv, &tst_plan, &gen_curve);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

 status = om$construct (classid = OPP_EMSplane_class_id,
                        p_objid = top_cap,
                        msg = message EMSplane.EMplane_of_curve (EMmsg,
                              construct_list,NULL, &gen_curve,
                              &curve_type[top_cap_index],
                              test_degeneracy,
                              TRUE,NULL,top_edgeids));
 if (!(1&status&*EMmsg))
 {
  *top_cap = NULL_OBJID;
  goto wrapup;
 }

 if (*EMmsg == EMS_I_Degenerate)
 {
   top_cap_degenerate = TRUE;
   *top_cap = NULL_OBJID;
 }
}

 if (bottom_cap_degenerate && top_cap_degenerate)
  *EMmsg = EMS_I_BothCapsDegenerate;
 else if (bottom_cap_degenerate)
  *EMmsg = EMS_I_BottomCapDegenerate;
 else if (top_cap_degenerate)
  *EMmsg = EMS_I_TopCapDegenerate;
 else
  *EMmsg = EMS_S_Success;

wrapup:
             
 if (memory_allocated)
 {
  if (gen_curve.poles) om$dealloc(ptr = (IGRchar *) gen_curve.poles);
  if (gen_curve.knots) om$dealloc(ptr = (IGRchar *) gen_curve.knots);
  if (gen_curve.weights) om$dealloc (ptr = (IGRchar *) gen_curve.weights);
 }

 if (!(1&status&*EMmsg))
 {
  cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                           construct_list->env_info),
                     targetid = *bottom_cap);
  *bottom_cap = NULL_OBJID;

  cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                           construct_list->env_info),
                     targetid = *top_cap);
  *top_cap = NULL_OBJID;

  }

 if (surf) om$dealloc(ptr = (IGRchar *) surf);

 return (status);

}

end implementation EMSsubbs;
                            
                                
             
   
            
