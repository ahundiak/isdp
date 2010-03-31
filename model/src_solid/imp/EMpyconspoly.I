/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpolyhdrn;   

#include "EMS.h"
# include "bserr.h"
# include "OMmacros.h"
# include "EMSerrordef.h"
# include "emsmacros.h"

# define MAX_NO_OF_VERTICES_ON_FACE 4
# define NOT_FOUND -1 
# define MAX_SURFS 6

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSsubbs import EM3o4pts;

method EMcnsplyhdrn (IGRlong *EMmsg;
                     IGRshort no_of_faces;
                     IGRshort no_of_edges;
                     IGRshort no_of_vertices;
                     IGRpoint *vertices;
                     IGRint *option; 
                     IGRshort faces[][5];
                     IGRushort natural_edprops[][4];
                     IGRuchar natural_curve_type[][4];
                     IGRushort connectivity[][5];
                     struct GRvg_construct *construct_list)

/* *******************************************************************

Description

            This method constructs a general polyhedron constituting
            of faces having three or four vertices.

            Input

              no_of_faces  -  Number of faces that comprise the
                              polyhedron
              no_of_edges  -  Number of edges that comprise the 
                              polyhedron.  An edge, in the context
                              of a polyhedron, occurs when two
                              different faces meet.
              no_of_vertices - Number of vertices that comprise the
                              polyhedron. A vertex, in the context
                              of a polyhedron, occurs at the intersection
                              point of three edges.
              vertices     -  array of xyz coordinates of all vertices
              faces        -  array specifying the vertex indices that 
                              comprise each face. 
              connectivity -  array specifying the manner in which faces
                              connect to each other resulting in edges
              option       -  specifies whether each face is a 
                              rectangular plane, triangle or an order 2
                              nonplanar face.
              construct_list - construction information. The same
                              construct_list is used for constructing
                              all the surfaces of the solid.

              Output
 
               EMmsg       -  Pointer to completion code

Notes

             Upon exit the completion code will be one of the following

               EMS_S_Success   -   if successful
               EMS_E_Fail      -   if severe failure which could be due
                                   not being able to establish topology
                                   could not construct the surfaces
               EMS_E_InvalidArg   -   if there is invalid input
                                e.g if the method is asked to
                                construct a solid with faces containing
                                more than four edges.   

Algorithm

1. For (i=0 to total number of faces)
   {
     Determine the vertices comprising the face.
     Determine a point lying on the solid side of the face.
     Construct the face
   }

2. Send a message to myself to establish topology.

3. Set the properties bit appropriately to make myself active.

History

  PP          :    11/08/87          Conversion to EMS 1.1
  PP          :    12/20/86          Genesis


***************************************************************** */



{
 IGRshort               i;    /* indices in the for loop */
 IGRshort               j;
 IGRshort               k;

 IGRint                 size; /* for memory allocation purposes */
 IGRint                 indx; /* used to determine the index into the 
                                 vertices array which corresponds to 
                                 a point in the solid for a face */

 IGRboolean             found;/* flag for indicating that the vertex
                                 index has been found */
                                

 IGRlong                status;/* OM return status */

 IGRlong                cln_sts,
                        cleanup_msg; 
 
 IGRpoint               vertices_on_face[MAX_NO_OF_VERTICES_ON_FACE];
                               /* array for storing the vertices belonging
                                  to a face */
 IGRpoint               point_in_solid;
                               /* point inside the solid for a face */

 struct GRid            surface_GRid_buff[MAX_SURFS];

 struct GRid            *surface_GRid;
                               /* pointer to the array of surface GRids
                                  forming the polyhedron */
 IGRboolean convert_into_plane = TRUE;

/* **********************

   Initialisation

   ********************** */

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surface_GRid = NULL;
 indx = NOT_FOUND;


 if (no_of_faces > MAX_SURFS)
 {
  surface_GRid = (struct GRid *) om$malloc (size = no_of_faces * 
                                            sizeof (struct GRid));
  EMerr_hndlr (!surface_GRid, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
  surface_GRid = &surface_GRid_buff[0];
 
 for (i=0 ; i < no_of_faces; i++)
   surface_GRid[i].objid = NULL_OBJID;
 
 for (i=0 ; i< no_of_faces; i++) 
  {
/* *****************************

    Move the vertices belonging to face i into vertices_on_face array

   ***************************** */

   for (j=0 ;j < MAX_NO_OF_VERTICES_ON_FACE;j++)
    {
      size = sizeof (IGRpoint);

      OM_BLOCK_MOVE((IGRint)vertices[abs(faces[i][j]) - 1],
                    (IGRint)vertices_on_face[j], size);
    }

/* *****************************

   Determine the index into the vertices array which 
   corresponds to a point in solid for face i

   ***************************** */


     for (k=0 ; k < no_of_vertices; k++)
     {
       found = FALSE;
        for (j = 0; j < MAX_NO_OF_VERTICES_ON_FACE; j++)
        {
         if (k != (abs(faces[i][j]) - 1))
          found = TRUE;
         else
          {
           found = FALSE;
           break;
          }
         }
        if (found)
        {
         indx = k;
         break;
        }
      }

   if (indx != NOT_FOUND)
   {
   OM_BLOCK_MOVE ((IGRint) vertices[indx], (IGRint) point_in_solid,
                  size);

   surface_GRid[i].osnum = construct_list->env_info->md_id.osnum;

/* *********************************

   Construct the surface objects. 

   ********************************* */

     if (option[i] == RECTANGULAR_PLANE)
     {
     status = om$construct(classid = OPP_EMSplane_class_id,
                           osnum = surface_GRid[i].osnum,
                           p_objid = &surface_GRid[i].objid,
                           msg = message EMSsubbs.EM3o4pts(
                           EMmsg, 
                           vertices_on_face[0],
                           vertices_on_face[3],
                           vertices_on_face[2],
                           vertices_on_face[1],
                           point_in_solid,
                           construct_list));
     EMerr_hndlr ( !(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
    else if (option[i] == ORDER_2_SURF || option[i] == TRIANGLE)
     {
       status = om$construct(classid = OPP_EMSgenbs_class_id,
                           osnum = surface_GRid[i].osnum,
                           p_objid = &surface_GRid[i].objid,
                           msg = message EMSsubbs.EM3o4pts(
                           EMmsg, 
                           vertices_on_face[0],
                           vertices_on_face[3],
                           vertices_on_face[2],
                           vertices_on_face[1],
                           point_in_solid,
                           construct_list));
     EMerr_hndlr ( !(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
    else
     {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
     }
   }
  else /* if index is not found something is messed up */
   {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
   }
  }
                            
/* ***************************************

   Establish the topology connections

   *************************************** */

 status = om$send (msg = message EMSsolid.EMesttplgy (EMmsg,
                         no_of_edges,
                         no_of_faces,
                         natural_edprops,
                         natural_curve_type,
                         connectivity,
                         surface_GRid,
                         construct_list),
                   targetid = my_id);
 EMerr_hndlr ( !(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if(convert_into_plane && construct_list->env_info)
  status = EMconvert_into_plane(EMmsg, NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, construct_list->env_info, my_id, OM_Gw_current_OS);


wrapup:

 if (1 & status & *EMmsg) *EMmsg = EMS_S_Success;

 if (surface_GRid && (!(1 & *EMmsg & status))) 
 {
  for (i=0 ; i < no_of_faces; i++) 
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg,
                            construct_list->env_info),
                      targetid = surface_GRid[i].objid,
                      targetos = surface_GRid[i].osnum);
  }
 }

 if (no_of_faces > MAX_SURFS)
 {
  if (surface_GRid) om$dealloc (ptr = (IGRchar *) surface_GRid);
 }

 EMWRAPUP(*EMmsg, status, "In EMSpolyhdrn:EMcnsplyhdrn error")
 return (status);
}

end implementation EMSpolyhdrn;
