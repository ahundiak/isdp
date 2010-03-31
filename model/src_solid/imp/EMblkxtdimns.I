/* ###################   APOGEE COMPILED   ################## */

class implementation EMSblock;

#include "EMS.h"
# include "EMSerrordef.h"
# include "OMmacros.h"

#define NO_VERTICES 8
method EMextract_vtx_hwd (IGRlong *EMmsg; /* completion code */
                          struct GRmd_env *env; 
                                          /* module environment of the solid*/
                          IGRpoint vertex;
                                          /* vertex of the solid box */
                          IGRvector height,
                                    width,
                                    depth) /* height, width and depth 
                                              vectors */

/* *********************************************************************

Description
            This method returns the vertex, height, width and depth
            vectors of the solid box.
 
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
            the solid box is constructed.

Algorithm
            Get the vertices
            vertex[0] corresponds to the vertex
            width = vertex[1] - vertex[0]
            height = vertex[3] - vertex[0]
            depth = vertex[4] - vertex[0]

History
            PP      : 06/09/87       Major revisions due to changes in class
                                     structure and data structure
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

 OM_BLOCK_MOVE(vertices[0], vertex, sizeof (IGRpoint));

 for (i=0 ; i < 3; i++)
 {
  height[i] = vertices[3][i] - vertices[0][i];
  width [i] = vertices[1][i] - vertices[0][i];
  depth [i] = vertices[4][i] - vertices[0][i];
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSblock:EMextract_vtx_hwd error");
 return (status);

}

end implementation EMSblock;


