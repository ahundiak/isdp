/* ###################   APOGEE COMPILED   ################## */

class implementation EMSwedge;

#include "EMS.h"
#define NO_OF_FACES 5
#define TOTAL_NO_OF_VERTICES 6
#define NO_OF_EDGES 9

#include "EMSprop.h"
#include "bserr.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsedgedef.h"
#include "EMSerrordef.h"
#include "EMSconstruct.h"

method EMrtwedge (IGRlong *EMmsg;
                  struct GRvg_construct *construct_list;
                  IGRpoint vertex;
                  IGRvector height;
                  IGRvector width;
                  IGRvector depth)

/* ******************************************************************

Description
   
           This method constructs a right angle wedge when specified the 
           vertex point, the height vector, depth vector and the width
           vector.

           Input
             vertex  - vertex point of the right angle wedge. 
             height,  
             width ,
             depth   - height, width and depth vector of the
                       right angle wedge 

             construct_list - pointer to construction information
             
            Output
             EMmsg - completion code

Notes

           Upon exit the completion code will be one of the following
             EMS_S_Success - if successful
             EMS_E_Fail - if failure
Algorithm

           1. Determine the vertices comprising the solid box.
           2. Send a EMcnsplyhdrn message to myself with appropriate
              input.

See also

           The solid construction notes. It explains the data 
           structure necessary for defining topology.

History
          
           PP      :    10/10/87           Changed code to handle setting up
                                           of edge types and natural edge
                                           properties
           PP      :    01/01/87           Genesis

**********************************************************************/
{
 IGRint                 sts; 
 BSrc                   rc;
 IGRlong                status; /* OM return status */
 IGRlong                cln_sts,
                        cleanup_msg;
                                 /* OM return status and completion 
                                    message during cleanup */

 IGRpoint               vertices[ TOTAL_NO_OF_VERTICES];
                                  /* array storing the vertices
                                     comprising the right angle wedge */

 static                 IGRshort faces[NO_OF_FACES] [5] =
                         {
                          {1,2,3,4,1},
                          {2,5,6,3,2},
                          {1,4,6,5,1},
                          {-4,-4,3,6,4},
                          {-1,-1,5,2,1}
                         };
                                    /* array specifying the indices into
                                       the vertices array comprising a 
                                       face */

 static IGRuchar natural_curve_type [NO_OF_FACES][4] = 
                         {
     {EMlinesegment,EMlinesegment,EMlinesegment, EMlinesegment},
     {EMlinesegment,EMlinesegment,EMlinesegment, EMlinesegment},
     {EMlinesegment,EMlinesegment,EMlinesegment, EMlinesegment},
     {EMpoint,EMlinesegment,EMlinesegment, EMlinesegment},
     {EMpoint,EMlinesegment,EMlinesegment, EMlinesegment},
                          };        /* array specifying the edge types
                                       of the model space natural edges */
  
 static IGRushort natural_edprops [NO_OF_FACES][4] = 
                         {
                          {0,0,0,0},
                          {0,0,0,0},
                          {0,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                         };
                                    /* array specifying the natural
                                       edge properties */
 static                 IGRushort connectivity [NO_OF_EDGES] [5] =
                         {
                          {1,5,0,3,REVERSED},
                          {1,3,3,0,REVERSED},
                          {1,4,2,1,REVERSED},
                          {1,2,1,3,REVERSED},
                          {2,5,0,2,REVERSED},
                          {3,5,3,1,REVERSED},
                          {3,4,1,3,REVERSED},
                          {2,4,2,2,REVERSED},
                          {2,3,1,2,REVERSED}
                         };
                                    /* array specifying the connectivity
                                       relationships between uv edges
                                       across different faces */

 static                 IGRint option[NO_OF_FACES] = 
                         {0, 0, 0, 1, 1 };
                                    /* array specifying the polygon type */

 IGRboolean             EMvctendpt (); /* Function declarations */

/* **************************************

   Initialisation

   ************************************** */


 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

/* **************************************

   Determine the vertices

   ************************************** */



 OM_BLOCK_MOVE ( (IGRint)vertex, (IGRint)vertices[5-1], sizeof (IGRpoint));

 sts = EMvctendpt (&rc, vertices[5-1], width, vertices[1-1]);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 sts = EMvctendpt (&rc, vertices[5-1], height, vertices[2-1]);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 sts = EMvctendpt (&rc, vertices[5-1], depth, vertices[6-1]);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 sts = EMvctendpt (&rc, vertices[6-1], width, vertices[4-1]);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 sts = EMvctendpt (&rc, vertices[6-1], height, vertices[3-1]);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);


 status = om$send (msg = message EMSpolyhdrn.EMcnsplyhdrn
                          (EMmsg, NO_OF_FACES,
                           NO_OF_EDGES,
                           TOTAL_NO_OF_VERTICES, vertices,
                           option,
                           faces, 
                           natural_edprops, natural_curve_type,
                           connectivity,construct_list),
                    targetid=my_id);
 if (! (1 & status & *EMmsg)) goto wrapup;


wrapup:

/* ***********************

   If there is any error then all objects constructed during solid
   construction process are deleted
  
   *********************** */

  if (! (1 & status & *EMmsg))
  {
    cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg, 
                             construct_list->env_info),
                       targetid = my_id);
    *EMmsg = EMS_E_Fail;

  }
  else
    *EMmsg = EMS_S_Success;

  EMWRAPUP (*EMmsg, status, " In EMSwedge.S: EMrtwedge error");
  return (status);

}

end implementation EMSwedge;
