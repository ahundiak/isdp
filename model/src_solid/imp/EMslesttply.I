/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
# include "EMSerrordef.h"
# include "emsmacros.h"
# include "EMSbnddef.h" 
# include "EMSprop.h"
# include "EMSopt.h"                      
# include "psdinc.h"  

# define PROPS 4

from EMSloopset import EMmake_natural_loopset;
from EMSedge import EMconnect_edges;
from EMSedge import EMset_props;

method EMesttplgy( IGRlong *EMmsg;
                   IGRshort no_of_edges,
                            no_of_faces;
                   IGRushort natural_edprops[][4];
                   IGRuchar  natural_curve_type[][4];     
                   IGRushort connectivity[][5];
                   struct GRid *surf_GRids;
                   struct GRvg_construct *construct_list)

/* ****************************************************************

Description

                    This method constructs the topological objects
                    and appropriately connects them up based on
                    the input which is described below.

                    Input
                    no_of_edges    -  total number of xyz edges
                    no_of_faces    -  total number of faces. Should correspond
                                      with the size of the surf_GRids coming in
                    natural_edprops-  array containing the special edge
                                      properties of the natural edges belonging
                                      to each surface. The properties
                                      EMED_NATURAL and EMED_OPEN  are set
                                      by default.
                    natural_curve_type - array containing the edge types
                                      of the natural edges. natural_edprops
                                      and natural_curve_type go hand in hand.
                                      If both these are set to NULL, then
                                      it is assumed that the caller does not
                                      know the edge properties and the curve
                                      type. The system tries then to determine
                                      the same.
                    connectivity   -  array specifying the manner in
                                      which the uv edges connect to
                                      form xyz edges across 
                                      different surfaces. If this is set to
                                      NULL, then no establishment of 
                                      connectivity is attempted across
                                      surfaces. If connectivity is being set
                                      to NULL, then the argument no_of_edges
                                      may be set to NULL too.
                    surf_GRids     -  Array of GRids of the faces whose
                                      topology is being established
                    construct_list -  Pointer to construction information
                                      of the solid. It is assumed that
                                      the solid exists in the same module as
                                      the surfaces.

                    Output
                     EMmsg         -  Pointer to completion code

Notes

                    Upon exit the completion code will be one of the
                    following
    
                    EMS_S_Success        -  if successful
                    EMS_E_Fail           -  if there is failure
                    EMS_E_InvalidArg     -  Invalid arguments. If no surface ids
                                            are coming in, or if the no of
                                            faces is 0.
                                   

Algorithm

History
           PP       :     06/16/91        Additon of horizon edges logic
                                          broke what I was doing.
           PP       :     10/10/87        Made argument changes to accept
                                          a curve type and curve properties
                                          to be used in constructing a natural
                                          loopset
           PP       :     09/28/87        Calling EMmk_nat_bdry instead
                                          of EMmake_natural_loopset to
                                          construct a natural loopset
           PP       :     05/17/87        Made the change so that an edge 
                                          closed in xyz is appropriately flagged
           PP       :     02/25/87        Made changes so that vertex
                                          objects are not constructed and
                                          the connectable edges are 
                                          appropriately flagged to 
                                          indicate whether they are
                                          reversed or not
           PP       :     01/01/87        Genesis
         
*************************************************************** */
 
{

  IGRlong               i;  /* indices used in for loops */
  IGRshort              j;

  IGRlong               status;
  IGRlong               cln_sts,
                        cleanup_msg;


  GRobjid               surface_edge_objids[MAX_NO_OF_FACES]
                                          [NO_OF_EDGES_PER_FACE];

  struct GRid		my_GRid;

  OM_S_OBJID		loopset_id;

  GRobjid               edge1_objid,
                        edge2_objid;

/* ************************************

   Initialisation

   ************************************ */

   status = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   edge1_objid = NULL_OBJID;
   edge2_objid = NULL_OBJID;
   loopset_id = NULL_OBJID;

   if (!surf_GRids || (no_of_faces == 0))
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
   for (i=0 ; i < no_of_faces; i++)
   {
    for (j=0; j < NO_OF_EDGES_PER_FACE; j++)
     {
       surface_edge_objids[i][j] = NULL_OBJID;
     } 
   }

/*
 * Commented the following section of code because of the introduction of
 * horizon edges which broke this logic.
 * pp 06/16/91
 */

/*
 if (natural_curve_type && natural_edprops)
 {
   status = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
   if (!(1&status)) goto wrapup;

   status = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
   if (!(1&status)) goto wrapup;

   for (i=0 ; i < no_of_faces; i++)
    {
      status = om$construct (classid = OPP_EMSloopset_class_id,
                             p_objid = &loopset_id,
                             msg = message EMSloopset.EMmake_natural_loopset(
                                   EMmsg,
                                   &natural_curve_type[i][0],
                                   &natural_edprops[i][0],
                                   &surface_edge_objids[i][0]));
      if (!(1&status&*EMmsg)) goto wrapup;
      
      status = om$send (msg = message Root.connect (to_surface, NULL,
                              surf_GRids[i].objid, surf_GRids[i].osnum,
                              to_loopset, NULL),
                        targetid = loopset_id); 
      if (!(1&status)) goto wrapup;
     }
  }
  else
*/
  {
   for (i=0; i < no_of_faces; i++)
    {
      status = om$send (msg = message EMSsurface.EMmk_nat_bdry (EMmsg,
                              &construct_list->env_info->md_env, 
                              &surface_edge_objids[i][0]),
                        targetid = surf_GRids[i].objid,
                        targetos = surf_GRids[i].osnum);
      if (!(1&status&*EMmsg)) goto wrapup;
    }
  }
 
  
/* ******************************************

   Connect the appropriate uv edges across the same or different
   surfaces based on the information contained in connectivity array
   and appropriately flag the edges to indicate whether they are
   connected in a reversed manner or not.

   ****************************************** */

  if (connectivity)
  {
    for (i = 0 ; i < no_of_edges; i++)
    {

     edge1_objid = surface_edge_objids[connectivity[i][0] - 1]
                                    [connectivity[i][2] ];
     edge2_objid = surface_edge_objids[connectivity[i][1] - 1]
                                    [connectivity[i][3] ];

     status = om$send(msg = message EMSedge.EMconnect_edges
                      (EMmsg, connectivity[i][PROPS], FALSE,
                      edge1_objid, NULL_OBJID, NULL_OBJID, NULL),
                      targetid = edge2_objid);
     if (! (1 & status)) goto wrapup;
    }
  }

/* *****************************************

   Connect the surfaces to the solid

   ***************************************** */

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  for (i = 0; i < no_of_faces; i++)
  {
    status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
                            &my_GRid, &i),
                      targetid = surf_GRids[i].objid);
    EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
    if (!(1 & status)) goto wrapup;
  }

  status = om$send (msg = message GRgraphics.GRconstruct(construct_list),
                    targetid = my_id);
  if (! (1 & status)) goto wrapup;

wrapup:

  if (! (1 & status & *EMmsg))
  {
   for (i=0 ; i < no_of_faces; i++)
   {
    for (j=0; j < NO_OF_EDGES_PER_FACE; j++)
     {
      cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                               construct_list->env_info),
                         targetid = surface_edge_objids[i][j]);
     } 
    }

      cln_sts = om$send (msg = message Root.delete (1),
                         targetid = loopset_id);
   }
  else
   *EMmsg = EMS_S_Success;

  EMWRAPUP(*EMmsg, status, "In EMSsolid:EMesttplgy error");
  return (status);

}

end implementation EMSsolid;

