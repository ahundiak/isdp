/* ###################   APOGEE COMPILED   ################## */
/*
HISTORY

23-Oct-1987 jBk EMED_NONMODIFIABLE removed.  Bit never used.
*/

class implementation EMSloop;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsedgedef.h"

#define MAX_EDGES 5
#define MAX_POINTS 15

from EMSbsedge import EMbsinit;
from EMSlinedge import EMleinit;

extern OMuword OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSbsedge_class_id;

method EMmake_lb_loop (IGRlong *EMmsg;
                       IGRushort loop_props;
                       IGRint no_of_edges;
                       struct IGRbsp_curve **edgegeom;
                       IGRuchar *curve_type;
                       struct EMSpartolbasis *partolbasis;
                       GRobjid *edgeids)
/* ********************************************************************

Description
             This method accepts a series of edge geometries. If the incoming
             edge geometry is a polyline then a linear edge is constructed or
             if it is a bpline a bsedge is constructed.

             If edgeids are wanted back ( a typical case when this might be
             necessary are during solid constructions for establishing
             topology), memory should be allocated for the same. Otherwise
             a null pointer may be sent, in which case no edge ids are
             returned. 


Assumptions
             The edges following each other need to be well connected and
             should form a close loop.  By well connected I mean the tail of
             one edge should match the end of the successive edge.


************************************************************************ */

{
 IGRshort   i;
 IGRshort   j;
 IGRushort props;
 OM_S_CHANSELECT to_edges,
                 to_owner;

 IGRlong     cln_sts;
 IGRint      ord2_buff_size = 0;
 struct      IGRpolyline inpoly;
 IGRboolean  memory_allocated = FALSE;
 GRobjid     edgeid_buff[MAX_EDGES];
 IGRdouble   ord2_ptsbuff[MAX_POINTS][2];
 IGRboolean      ord2_pts_alloc = FALSE;
 IGRlong    status;
 IGRuchar default_curve_type;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 for (i=0; i < MAX_EDGES; i++)
    edgeid_buff[i] = NULL_OBJID;

 props = 0;
 ME.EMSloop->lp_props = 0;
 ME.EMSloop->lp_props |= loop_props;

 
 if(!partolbasis->is_valid)
  {
    status = om$send(msg=message EMSboundary.EMgetsurface_info
                    (EMmsg,NULL,partolbasis),targetid=my_id);
    EMerr_hndlr(!(1&*EMmsg&status),*EMmsg,EMS_E_EdgeError,wrapup);
  }

 if (!edgeids)
 {
   if (no_of_edges <= MAX_EDGES)
     edgeids = edgeid_buff;
   else
   {
   edgeids = (GRobjid *) om$malloc (size = sizeof (GRobjid) *
                                           no_of_edges);
   EMerr_hndlr (!edgeids, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

   for (i=0 ; i < no_of_edges; i++)
    edgeids[i] = NULL_OBJID;

   memory_allocated = TRUE;
   }
 }

  status = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

  status = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);

   if(edgegeom == NULL)
      {
      for( i=0; i<no_of_edges;i++)
         {
         status = om$send (msg = message Root.connect (to_owner, 0,
                             my_id, OM_Gw_current_OS, to_edges,
                             0),
                       senderid = my_id,
                       targetid = edgeids[i]);
           EMerr_hndlr (!status, *EMmsg, EMS_E_Fail, wrapup);
         }
      goto wrapup;
      }


  for (i=0; i < no_of_edges; i++)
  {
   props = NULL;

   if (curve_type)
    default_curve_type = curve_type[0];
   else
    default_curve_type = EMfreeform_curve;

   if (edgegeom[i]->phy_closed)
      props |= EMED_XYZ_CLOSED;

   if (edgegeom[i]->order == 2 && (!edgegeom[i]->rational))
   {
       inpoly.num_points = edgegeom[i]->num_poles;

       if (inpoly.num_points >= MAX_POINTS)
       {
         if (inpoly.num_points >= ord2_buff_size)
         {
         inpoly.points = (IGRdouble *) om$malloc (size = 
                          inpoly.num_points * 2 * sizeof (IGRdouble));
         ord2_buff_size = inpoly.num_points;
         }
       }
       else
         inpoly.points = &ord2_ptsbuff[0][0];

       for (j=0 ; j < edgegeom[i]->num_poles; j++)
       {
         inpoly.points[2*j] = edgegeom[i]->poles[3*j];
         inpoly.points[2*j + 1] = edgegeom[i]->poles[3*j + 1];
       }

       status = om$construct (classid = OPP_EMSlinedge_class_id,
                              p_objid = &edgeids[i],
                              msg = message EMSlinedge.EMleinit (EMmsg,
                                    props, default_curve_type, 
                                    &inpoly,partolbasis,NULL, NULL_OBJID)); 
       EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
   }
   else
   {
     status = om$construct (classid = OPP_EMSbsedge_class_id,
                              p_objid = &edgeids[i],
                              msg = message EMSbsedge.EMbsinit(EMmsg,
                                    props, default_curve_type, 
                                    edgegeom[i],partolbasis));
     EMerr_hndlr (!(1 & status), *EMmsg, EMS_E_Fail, wrapup);
    }


     status = om$send (msg = message Root.connect (to_owner, 0,
                             my_id, OM_Gw_current_OS, to_edges,
                             0),
                       senderid = my_id,
                       targetid = edgeids[i]);
     EMerr_hndlr (!status, *EMmsg, EMS_E_Fail, wrapup);

   }

 props = NULL | EMLP_ACTIVE | EMLP_EXTERNAL;


 status = om$send (msg = message EMSloop.EMlpinit (EMmsg,
                         props, partolbasis, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 
wrapup:
 if (memory_allocated)
  {
   if (edgeids) om$dealloc (ptr = edgeids);
  }

 if (!(1&status&*EMmsg))
 {
   for (i=0; i < no_of_edges; i++)
   {
    cln_sts = om$send (msg = message Root.delete (1),
                       targetid = edgeids[i]);
   }
 }
 if (ord2_pts_alloc) om$dealloc (ptr = (char *)ord2_pts_alloc);
 EMWRAPUP (*EMmsg, status, "In EMSloop :EMmake_lb_loop error");
 return (status);

}

end implementation EMSloop;
 
