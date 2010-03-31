/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsolid;

#include "EMS.h"
# include "psdinc.h"        /* for REVERSED, NOT_REVERSED decl etc  */
# include "EMSerrordef.h"
# include "EMSbnddef.h"
# include "emsmacros.h"
# include "OMmacros.h"      /* for OM_BLOCK_MOVE                    */
# include "EMSconstruct.h"  /* for EMS_CONSTRUCT_BOTH_CAPS          */
# include "EMSopt.h"
# include "EMSprop.h"

# define CONSTANTU 1
# define CONSTANTV 2
# define NO_SURFS 3
# define CAP1 1
# define CAP2 2
# define SURF 0
# define MAX_POLES 60
# define MAX_KNOTS 70
# define MAXINT 1000
# define SPHERE 100
# define TORUS 200

from EMSedge import EMconnect_edges;
from EMSedge import EMget_props;
from EMSedge import EMset_props;

extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSproject_class_id;



method EMconstruct_solid_by_capping_surface (IGRlong *EMmsg;
                                             struct EMSdataselect *data;
                                             struct GRmd_env *env;
                                             IGRboolean use_surfid;
                                             IGRboolean *solid_oriented;
                                             OMuword *surf_classid;
                                             struct GRvg_construct
                                                    *construct_list)

/* **************************************************************


Description
            This method constructs a solid by capping a surface by planes
            on the sides at which it is open.  It can either accept the
            surface objectid or the surface geometry as input. Also the
            surface has to be closed in one direction and open in the other.

Assumptions
            The cases when some of the edges are degenerate is not being
            handled in this version.

Notes
            Upon exit the completion code will be one of the following
                EMS_S_Success : if successful
                EMS_E_Fail : if there is failure
            
Bugs
            The alignment of normals deal has not been thoroughly tested
            for all surfaces which can be capped. I know for sure there
            are cases when it will fail. It definitely works for all
            solid of revolution and solid of projection cases.
History
           AMD : 11/24/92            Modified for 'place solid by capping'
            PP : 02/24/89            Fixed an orientation problem occuring
                                     for single surfaces of revolution
                                     in some cases.
            PP : 01/25/89            Initialised solid_topology_type to 0
            PP : 11/03/88            Fixed a problem wherein normals were
                                     being oriented wrong for a cone with
                                     bottom cap degenerate.
            PP : 09/21/87            Modified the method to construct
                                     solids of surfaces which have
                                     degenerate caps          
            PP : 08/26/87            Supported modification of cap
                                     yourself method
            PP : 05/23/87            Prenatal

***************************************************************** */

{
 IGRlong                status;
 struct IGRbsp_surface  *surf;
 struct IGRbsp_surface  *gen_surf;
 IGRboolean             bottom_cap_degenerate = FALSE,
                        top_cap_degenerate = FALSE;
 IGRshort               bottom_index, top_index;
 IGRlong                cleanup_msg, cln_sts;
 IGRushort              orient_option = 0;
 IGRushort              solid_topology_type = 0;
 struct GRid            *surf_GRid;
 struct GRid		my_GRid;
 IGRshort               i;
 IGRshort               j;
 IGRshort        pos_orient;
                         
 IGRlong                num_bytes;
 IGRpoint               point_in_solid;
 IGRshort               construct_option = NULL;
 IGRlong                ind;

 GRobjid                surfids[NO_SURFS];
 GRobjid                edgeids[NO_SURFS][4];

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 surf = NULL;
 gen_surf = NULL;

 EMerr_hndlr(!surf_classid, *EMmsg, EMS_E_InvalidArg, wrapup);
 EMerr_hndlr(!solid_oriented, *EMmsg,EMS_E_InvalidArg, wrapup);
 *solid_oriented = FALSE;

   for (i=0 ; i < NO_SURFS; i++)
      surfids[i] = NULL_OBJID;

   for (i=0 ; i < NO_SURFS; i++)
   {
     for (j=0 ; j < 4; j++)
     {
      edgeids[i][j] = NULL_OBJID;
     }
   }


 /*
  * Get the geometry of the surface if one is not coming in
  */

  if (data->datatype == EMSdata_object)
  {
   surf_GRid = data->data.object;

   status = om$send (msg = message GRvg.GRgetsize (EMmsg,
                           &env->md_env.matrix_type,
                           env->md_env.matrix,
                           &num_bytes),
                     targetid = surf_GRid->objid);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   surf = (struct IGRbsp_surface *) om$malloc (size = num_bytes);

   status = om$send (msg = message GRvg.GRgetgeom (EMmsg,
                           &env->md_env.matrix_type, 
                           env->md_env.matrix,
                           (IGRchar *) surf),
                           targetid = surf_GRid->objid);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail,
                  wrapup);
   gen_surf = surf;
  }
  else
  {
    *EMmsg = EMS_E_InvalidCase;
    goto wrapup;
  }

/*
 * Construct the surface if need be 
 */

  if (use_surfid && (data->datatype == EMSdata_object))
  {
   surfids[SURF] = surf_GRid->objid;
  } 

/*
 * Send a message to the surface to cap itself and return the caps
 */

 if ((gen_surf->u_phy_closed) && (gen_surf->v_phy_closed))
   solid_topology_type = TORUS;
 else if (!(gen_surf->u_phy_closed || gen_surf->v_phy_closed))
 {
   *EMmsg = EMS_E_InvalidCase;
   goto wrapup;
 }

 status = om$send (msg = message EMSsurface.EMmk_nat_bdry (EMmsg,
                         &construct_list->env_info->md_env,
                         &edgeids[SURF][0]),
                   targetid = surfids[SURF]);
 if (! (1 & status & *EMmsg))goto wrapup;

  if (!(solid_topology_type == TORUS))
  {
  status = om$send (msg = message EMSsurface.EMcap_yourself (EMmsg, 
                          construct_option, env,
                          construct_list, &surfids[CAP1], &surfids[CAP2],
                          &edgeids[CAP1][0], &edgeids[CAP2][0]),
                    targetid = surfids[SURF]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
                         
  if (*EMmsg == EMS_I_BothCapsDegenerate)
  {
   solid_topology_type = SPHERE;
  }
  else if (*EMmsg == EMS_I_BottomCapDegenerate)
   bottom_cap_degenerate = TRUE;
  else if (*EMmsg == EMS_I_TopCapDegenerate)
   top_cap_degenerate = TRUE;
 }


/*
 * Establish the topology, align the normals and connect the surfaces to
 * myself
 */
if (!((solid_topology_type == SPHERE) ||
      (solid_topology_type == TORUS)))
{
  IGRushort cap1_edge_props = 0,
                    cap2_edge_props = 0;


/*
 * Flag the degenerate edges and set the appropriate properties
 */

 if (gen_surf->u_phy_closed)
 {
   bottom_index = 3;
   top_index = 1;
 }
 else if (gen_surf->v_phy_closed)
 {
   bottom_index = 0;
   top_index = 2;
 }
 
if (!bottom_cap_degenerate)
{
 status = om$send (msg = message EMSedge.EMget_props (EMmsg, &cap1_edge_props),
                         targetid = edgeids[CAP1][0]);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 cap1_edge_props |= EMED_XYZ_CLOSED;
 */
}

if (!top_cap_degenerate)
{
 status = om$send (msg = message EMSedge.EMget_props (EMmsg, &cap2_edge_props),
                         targetid = edgeids[CAP2][0]);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 cap2_edge_props |= EMED_XYZ_CLOSED;
*/
}


 if (gen_surf->u_phy_closed)
 {
  if (!bottom_cap_degenerate)
  {
   if (cap1_edge_props & EMED_REVERSED)
    cap1_edge_props |= NOT_REVERSED;
   else
    cap1_edge_props |= REVERSED;
  }

  if (!top_cap_degenerate)
  {
   if (cap2_edge_props & EMED_REVERSED)
    cap2_edge_props |= REVERSED;
   else
    cap2_edge_props |= NOT_REVERSED;
  }

/*
 * Connect the edge of cap1 to the third edge of surf and
 * the edge of cap2 to the first edge of surf.
 */

   if (!bottom_cap_degenerate)
   {
   status = om$send (msg = message EMSedge.EMconnect_edges (EMmsg,
                           cap1_edge_props, FALSE, edgeids[CAP1][0],
                           NULL_OBJID, NULL_OBJID, NULL),
                     targetid = edgeids[SURF][3]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

   if (!top_cap_degenerate)
   {
   status = om$send (msg = message EMSedge.EMconnect_edges (EMmsg,
                           cap2_edge_props, FALSE, edgeids[CAP2][0],
                           NULL_OBJID, NULL_OBJID, NULL),
                     targetid = edgeids[SURF][1]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

 }
 else
 {
   if (!bottom_cap_degenerate)
   {
   if (cap1_edge_props & EMED_REVERSED)
    cap1_edge_props |= REVERSED ;
   else
    cap1_edge_props |= NOT_REVERSED;
   }

   if (!top_cap_degenerate)
   {
   if (cap2_edge_props & EMED_REVERSED)
    cap2_edge_props |= NOT_REVERSED;
   else
    cap2_edge_props |= REVERSED;
   }

   if (!bottom_cap_degenerate)
   {
   status = om$send (msg = message EMSedge.EMconnect_edges (EMmsg,
                           cap1_edge_props, FALSE, edgeids[CAP1][0],
                           NULL_OBJID, NULL_OBJID, NULL),
                     targetid = edgeids[SURF][0]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

   if (!top_cap_degenerate)
   {
   status = om$send (msg = message EMSedge.EMconnect_edges (EMmsg,
                           cap2_edge_props, FALSE, edgeids[CAP2][0],
                           NULL_OBJID, NULL_OBJID, NULL),
                     targetid = edgeids[SURF][2]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
 }

/*
 * Align the normals
 */

  if (!bottom_cap_degenerate)
  {
  if ((gen_surf->u_phy_closed) && !(gen_surf->v_phy_closed))
  {
   OM_BLOCK_MOVE(&gen_surf->poles[3*(gen_surf->u_num_poles)], 
                 point_in_solid,
                 sizeof (IGRpoint));
   if (gen_surf->rational)
   {
     for (i=0; i < 3; i++)
     point_in_solid[i] /= gen_surf->weights[gen_surf->u_num_poles];
   }
  }
  else if ((gen_surf->v_phy_closed) && !(gen_surf->u_phy_closed))
   {
    OM_BLOCK_MOVE(&gen_surf->poles[3*(gen_surf->u_num_poles - 1)],
                   point_in_solid, sizeof (IGRpoint));

   if (gen_surf->rational)
   {
     for (i=0; i < 3; i++)
     point_in_solid[i] /= gen_surf->weights[gen_surf->u_num_poles - 1];
   }
  }
  else
  {
    *EMmsg = EMS_E_InvalidCase;
    goto wrapup;
  }

  orient_option = 0;
  orient_option |= EMS_SET_POS_ORIENT | EMS_GET_POS_ORIENT ;

  status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg, orient_option,
                          &pos_orient, point_in_solid, 
                          construct_list->env_info),
                    targetid = surfids[CAP1]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);


  pos_orient = ((cap1_edge_props & EMED_REVERSE_CONNECT ) ? pos_orient : 
                 !pos_orient);

  orient_option = 0;
  orient_option |=  EMS_SET_POS_ORIENT;

  status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg,
                          orient_option, &pos_orient,
                          NULL,NULL),
                    targetid = surfids[SURF]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (!top_cap_degenerate)
  {
   pos_orient = ((cap2_edge_props & EMED_REVERSE_CONNECT) ? pos_orient :
                !pos_orient);

   orient_option = 0;
   orient_option |=  EMS_SET_POS_ORIENT;

   status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg,
                           orient_option, &pos_orient,
                           NULL, NULL),
                     targetid = surfids[CAP2]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 else if (!top_cap_degenerate)
  {
  if ((gen_surf->u_phy_closed) && !(gen_surf->v_phy_closed))
  {
   ind = gen_surf->u_num_poles * (gen_surf->v_num_poles - 2 );
   OM_BLOCK_MOVE(&gen_surf->poles[3*ind],
                 point_in_solid,
                 sizeof (IGRpoint));
   if (gen_surf->rational)
   {
     for (i=0; i < 3; i++)
     point_in_solid[i] /= gen_surf->weights[ind];
   }
  }
  else if ((gen_surf->v_phy_closed) && !(gen_surf->u_phy_closed))
   {
    ind = gen_surf->u_num_poles * gen_surf->v_num_poles - 2;
    OM_BLOCK_MOVE(&gen_surf->poles[3*ind],
                   point_in_solid, sizeof (IGRpoint));

   if (gen_surf->rational)
   {
     for (i=0; i < 3; i++)
     point_in_solid[i] /= gen_surf->weights[ind];
   }
  }
  else
  {
    *EMmsg = EMS_E_InvalidCase;
    goto wrapup;
  }

  orient_option = 0;
  orient_option |= EMS_SET_POS_ORIENT | EMS_GET_POS_ORIENT ;

  status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg, orient_option,
                          &pos_orient, point_in_solid, 
                          construct_list->env_info),
                    targetid = surfids[CAP2]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);


  pos_orient = ((cap2_edge_props & EMED_REVERSE_CONNECT ) ? pos_orient : 
                 !pos_orient);

  orient_option = 0;
  orient_option |=  EMS_SET_POS_ORIENT;

  status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg,
                          orient_option, &pos_orient,
                          NULL,NULL),
                    targetid = surfids[SURF]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (!bottom_cap_degenerate)
  {
   pos_orient = ((cap1_edge_props & EMED_REVERSE_CONNECT) ? pos_orient :
                !pos_orient);

   orient_option = 0;
   orient_option |=  EMS_SET_POS_ORIENT;

   status = om$send (msg = message EMSsurface.EMalgnnrml (EMmsg,
                           orient_option, &pos_orient,
                           NULL, NULL),
                     targetid = surfids[CAP1]);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
  }
  
/*
 * If the surface class is a subclass of EMSproject then and only then
 * can we successfully orient the surface solid using the above mechanism. 
 * Else we say that the solid is not oriented.
 */
 
  status = om$is_ancestry_valid(subclassid = *surf_classid,
                                superclassid = OPP_EMSproject_class_id);
  if (status == OM_S_SUCCESS)
    *solid_oriented = TRUE;
  else if (status == OM_I_INVANCESTRY)
  {
   status = OM_S_SUCCESS;
   *solid_oriented = FALSE;
  }
  else
   goto wrapup;
 }
 else /* Solid topology type is torus or sphere */
 {
 /*
  * Also if the solid topology type is sphere/torus we can orient the
  * same using the below mechanism. 
  */

  GRrange range;
  IGRboolean in_world;

  in_world = TRUE;
  status = om$send (msg = message GRgraphics.GRgetrang(EMmsg,
                     &env->md_env.matrix_type,
                      env->md_env.matrix,
                      &in_world, range),
                    targetid = surfids[SURF]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);

  orient_option = 0;
  orient_option |= EMS_SET_POS_ORIENT | EMS_POINT_OUT_OF_SOLID;

  status = om$send (msg = message EMSsurface.EMalgnnrml(EMmsg,
                          orient_option, &pos_orient, range,
                          env),
                    targetid = surfids[SURF]);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
 
  *solid_oriented = TRUE;
 }


  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  /* Modified for 'place solid by capping'  AMD  11/24/92 */
  for (ind=1 ; ind < 3; ind++)
  {
    if (surfids[ind] != NULL_OBJID)
    {
    status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
                            &my_GRid, &ind),
                      targetid = surfids[ind]);
    EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
    if (!(1 & status)) goto wrapup;
    }
  }

  status = om$send (msg = message GRgraphics.GRconstruct(construct_list),
                    targetid = my_id);
  if (! (1 & status)) goto wrapup;


wrapup :

/*
 * If there is any error after the construction of two caps, the
 * same are deleted.
 */

 if (!(1&status&*EMmsg))
 {
   cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                          construct_list->env_info),
                      targetid = surfids [CAP1]);

   cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                            construct_list->env_info),
                      targetid = surfids [CAP2]);
 }

 if (surf) om$dealloc (ptr = (IGRchar *) surf);

/*
 * Delete the objects constructed in this method if there is an error
 */

 return (status);
}

end implementation EMSsfsolid;
  
