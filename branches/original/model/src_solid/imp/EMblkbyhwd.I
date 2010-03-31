/* ###################   APOGEE COMPILED   ################## */
class implementation EMSblock;

#include "EMS.h"
# include "bserr.h"
# include "EMSerrordef.h"
# include "emsmacros.h"
# include "emsedgedef.h" /* for edge type definitions */
# include "EMSconstruct.h"
# include "EMSprop.h"

# define NO_OF_FACES 6
# define TOTAL_NO_OF_VERTICES 8
# define NO_OF_EDGES 12

method EMboxbyhwd (IGRlong *EMmsg;
                   struct GRvg_construct *construct_list;
                   IGRpoint vertex;
                   IGRvector height;
                   IGRvector width;
                   IGRvector depth)

/* ******************************************************************

Description
   
           This method constructs a solid box when specified, the
           vertex point, the height vector, depth vector and the width
           vector.

           Input
             vertex  - vertex point of the box
             height,  
             width ,
             depth   - height, width and depth vector for the solid
                       box

             construct_list - pointer to construction information
             
            Output
             EMmsg - completion code

Notes

           Upon exit the completion code will be one of the following
             EMS_S_Success - if successful
             EMS_S_Fail  - if failure

Algorithm

           1. Determine the vertices comprising the solid box.
           2. Send a EMcnsplyhdrn message to myself with appropriate
              input.

See also

           The solid construction notes. It explains the data 
           structure necessary for defining topology.

History
 
           PP      :    01/01/87           Genesis

**********************************************************************/

  

{
  IGRlong               status;   /* OM return status */
  IGRint                sts, rc;

  IGRlong               cln_sts, 
                        cleanup_msg; /* OM return status and completion
                                        message */


  IGRpoint              vertices[TOTAL_NO_OF_VERTICES];
                                     /* array containing the vertices
                                        of the cube */

  
  static                IGRshort faces[NO_OF_FACES][5] = 
                             {
                              {1,2,3,4,1},
                              {2,6,7,3,2},
                              {1,5,6,2,1},
                              {1,4,8,5,1},
                              {4,3,7,8,4},
                              {6,5,8,7,6} 
                             };
                                    /* array specifying the indices into
                                       the vertices array comprising a 
                                       face */
  
  static                IGRuchar natural_curve_type[NO_OF_FACES][4] =
                              {
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                 {EMlinesegment,EMlinesegment,EMlinesegment,EMlinesegment},
                              };    /* array specifying the edge types of
                                       the natural edges in model space */

  static                IGRushort natural_edprops [NO_OF_FACES][4] = 
                              {
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                              };    /* array specifying the special
                                       edge properties that need to be
                                       set for natural edges */
                                       

  static                IGRint option [NO_OF_FACES] = 
                             {0,0,0,0,0,0};
                                    /* array specifying the type of face */

  static                IGRushort connectivity [NO_OF_EDGES][5] =
                              {
                               {1,2,1,3,REVERSED},
                               {1,3,0,3,REVERSED},
                               {1,4,3,0,REVERSED},
                               {1,5,2,0,REVERSED},
                               {2,3,0,2,REVERSED},
                               {2,6,1,3,REVERSED},
                               {2,5,2,1,REVERSED},
                               {3,4,0,3,REVERSED},
                               {4,6,2,1,REVERSED},
                               {4,5,1,3,REVERSED},
                               {5,6,2,2,REVERSED},
                               {3,6,1,0,REVERSED}
                              };
                                    /* array specifying the connectivity
                                       relationships between uv edges
                                       across different faces */

  IGRboolean            EMvctendpt ();
                                    /* Function declarations */


  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  vertices [1 - 1][0] = vertex[0];
  vertices [1 - 1][1] = vertex[1];
  vertices [1 - 1][2] = vertex[2];

  sts = EMvctendpt (&rc, vertices [1 - 1], width, vertices [2 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);
  
  sts = EMvctendpt (&rc, vertices [1 - 1], depth, vertices [5 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  sts = EMvctendpt (&rc, vertices [1 - 1], height, vertices [4 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  sts = EMvctendpt (&rc, vertices [4 - 1], width, vertices [3 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  sts = EMvctendpt (&rc, vertices [5 - 1], width, vertices [6 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  sts = EMvctendpt (&rc, vertices [6 - 1], height, vertices [7 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  sts = EMvctendpt (&rc, vertices [5 - 1], height, vertices [8 - 1]);
  EMerr_hndlr ( !sts, *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message EMSpolyhdrn.EMcnsplyhdrn
                          (EMmsg, NO_OF_FACES,
                           NO_OF_EDGES,
                           TOTAL_NO_OF_VERTICES, vertices,
                           option,
                           faces, 
                           natural_edprops, natural_curve_type,
                           connectivity,construct_list),
                    senderid=my_id,
                    targetid=my_id);
  EMerr_hndlr ( !(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);


 wrapup:

/* ************************

   If there is any error, whatever has been constructed is
   deleted

   ************************ */


  if (! (1 & status & *EMmsg))
  {
    cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg, 
                             construct_list->env_info),
                      targetid = my_id);
  }
  else
   *EMmsg = EMS_S_Success;

  EMWRAPUP(*EMmsg, status, "In EMSblock:EMboxbyhwd error")
  return(status);
}

end implementation EMSblock;    
