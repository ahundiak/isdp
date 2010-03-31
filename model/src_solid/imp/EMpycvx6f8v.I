/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpolyhdrn;

#include "EMS.h"
# include "bserr.h"
# include "emsmacros.h"
# include "EMSerrordef.h"
# include "emsedgedef.h"
# include "EMSconstruct.h"
# include "EMSprop.h"

# define NO_OF_FACES 6
# define TOTAL_NO_OF_VERTICES 8 
# define NO_OF_EDGES 12

method EMcvx6f8v (IGRlong *EMmsg;
                  struct GRvg_construct *construct_list;
                  IGRpoint *vertices)

/* *******************************************************************

 Description

             This method constructs a six faced eight vertex polyhedron.

             Input
               vertices - array of xyz points representing the vertices
               construct_list - pointer to the construction information

             Output
               EMmsg - Completion code

Notes
             Upon exit the completion code will be one of the 
             following
               EMS_S_Success -  if successful
               EME_E_Fail    -  if there is failure

Algorithm
             Send a EMcnsplyhdrn message to myself with 
             appropriate input.
See also
             Solid construction notes. It explains the data
             structure necessary for defining the topology
             between faces.

History
             PP       : 10/10/87      Made changes to the code to handle
                                      setting up of edge types and natural
                                      edge properties
             PP       : 01/01/87      Genesis

********************************************************************* */


{
 IGRlong                status;   /* OM return status */
 IGRlong                cleanup_msg,
                        cln_sts;
                                  /* Completion status and OM return
                                     status during cleanup */

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
                              };

  static                IGRushort natural_edprops [NO_OF_FACES][4] = 
                              {
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                               {0,0,0,0},
                              };

  static                IGRint option [NO_OF_FACES] = 
                             {2,2,2,2,2,2};
                                    /* array specifying the polygon type */

  static                IGRushort  connectivity [NO_OF_EDGES][5] =
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
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;


 status = om$send (msg = message EMSpolyhdrn.EMcnsplyhdrn
                          (EMmsg, NO_OF_FACES,
                           NO_OF_EDGES,
                           TOTAL_NO_OF_VERTICES, vertices,
                           option,
                           faces, 
                           natural_edprops, natural_curve_type,
                           connectivity,construct_list),
                    targetid=my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail,wrapup);



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
  }
  else
    *EMmsg = EMS_S_Success;

  EMWRAPUP(*EMmsg,status,"In EMSpolyhdrn:EMcvx6f8v error")
  return (status);

 }

end implementation EMSpolyhdrn;
