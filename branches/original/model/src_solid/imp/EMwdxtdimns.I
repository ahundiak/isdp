/* ###################   APOGEE COMPILED   ################## */

class implementation EMSwedge;

#include "EMS.h"
# include "EMSerrordef.h"
# include "OMmacros.h"

#define NO_VERTICES 6

method EMextract_vtx_hwd (IGRlong *EMmsg; /* completion code */
                          struct GRmd_env *env; 
                                          /* module environment of the solid*/
                          IGRpoint vertex;
                                          /* vertex of the right angle
                                             wedge */
                          IGRvector height,
                                    width,
                                    depth) /* height, width and depth 
                                              vectors */

/* *********************************************************************

Description
            This method returns the vertex, height, width and depth
            vectors of the right angle wedge.
 
            Input
             env

            Output
             EMmsg
             height
             width
             depth
             vertex

Notes
            Upon exit the completion code will be one of the following
             EMS_S_Success : if successful
             EMS_E_Fail : if severe failure
             EMS_E_InvalidArg : if invalid arguments

Assumptions
            This method is closely tied in with the manner in which
            the right angle wedge is constructed.

Algorithm
            Get the vertices
            vertex[4] corresponds to the vertex
            width = vertex[0] - vertex[4]
            height = vertex[1] - vertex[4]
            depth = vertex[5] - vertex[4]

History
            PP      : 06/09/87       Changes to accomadate the new
                                     class structure and data structure
            PP      : 02/17/87       design date

*********************************************************************** */

{
 IGRshort               i;
 IGRint                 no_of_vertices;

 IGRlong                status; /* OM return status */

 IGRpoint               vertices[NO_VERTICES];
 
/* *************

   Initialisation

   ************* */

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$send (msg = message EMSpolyhdrn.EMget_vertices (EMmsg,
                         env, NO_VERTICES, &no_of_vertices, vertices),
                   targetid = my_id);
 if (! (1 & status & *EMmsg)) goto wrapup;

 OM_BLOCK_MOVE(vertices[4], vertex, sizeof (IGRpoint));

 for (i=0 ; i < 3; i++)
 {
  height[i] = vertices[1][i] - vertices[4][i];
  width [i] = vertices[0][i] - vertices[4][i];
  depth [i] = vertices[5][i] - vertices[4][i];
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSwedge :EMextract_vtx_hwd error");
 return (status);

}

end implementation EMSwedge;


