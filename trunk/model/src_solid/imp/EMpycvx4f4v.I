/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpolyhdrn;

#include "EMS.h"
# include "bserr.h"
# include "emsmacros.h"
# include "EMSerrordef.h"
# include "EMSconstruct.h"
# include "emsedgedef.h" /* for edge type declarations */
# include "EMSprop.h"

# define NO_OF_FACES 4
# define NO_OF_VERTICES 4
# define NO_OF_EDGES 6

method EMcvx4f4v (IGRlong *EMmsg;
                  struct GRvg_construct *construct_list;
                  IGRpoint *vertices)

/* *******************************************************************

 Description

             This method constructs a four faced four vertex polyhedron.

             Input
               vertices - array of xyz points representing the vertices
               construct_list - pointer to the construction information

             Output
               EMmsg - Completion code

Notes
             Upon exit the completion code will be one of the 
             following
               EMS_S_Success -  if successful
               EMS_S_Fail    -  if there is failure

Algorithm
             Send a EMcnsplyhdrn message to myself with 
             appropriate input.
See also
             Solid construction notes. It explains the data
             structure necessary for defining the topology
             between faces.

History
             PP       : 02/06/88      Fixed a bug, wherin I had define
                                      edge properties to be of type
                                      IGRuchar when it should
                                      have been IGRshort.
             PP       : 10/10/87      Changes to handle setting edge
                                      types and special edge properties.
             PP       : 01/01/87      Genesis

********************************************************************* */



{
 IGRlong                status; /* OM return status */
 IGRlong                cln_sts,
                        cleanup_msg;
                              /* OM return status and completion message
                                 during cleanup */


 static IGRshort        faces [NO_OF_FACES][5] = 
                         {
                          {1,1,3,2,1},
                          {2,2,3,4,2},
                          {1,1,2,4,1},
                          {3,3,1,4,3}
                         };
                                    /* array specifying the indices into
                                       the vertices array comprising a 
                                       face */

 static IGRint          option [NO_OF_FACES] = 
                         { 1, 1, 1, 1 };
                                    /* array specifying the polygon type */

 static IGRuchar natural_curve_type [NO_OF_FACES][4] = 
                         {
            {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
            {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
            {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
            {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
                         }; /* array specifying the curve types of the
                               model space counterparts */

 static IGRushort natural_edprops [NO_OF_FACES][4] = 
                         {
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                         }; /* array specifying the special edge properties of
                               the natural edges */
                            

 static IGRushort  connectivity [NO_OF_EDGES][5] =
                         {
                          {1,2,2,1,REVERSED},
                          {1,3,3,1,REVERSED},
                          {1,4,1,1,REVERSED},
                          {2,4,2,3,REVERSED},
                          {2,3,3,2,REVERSED},
                          {3,4,3,2,REVERSED}
                         };
                                    /* array specifying the connectivity
                                       relationships between uv edges
                                       across different faces */
 
/* ************************************

   Initialisation

   ************************************ */


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = om$send (msg = message EMSpolyhdrn.EMcnsplyhdrn
                          (EMmsg, NO_OF_FACES,
                           NO_OF_EDGES,
                           NO_OF_VERTICES, vertices,
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

  EMWRAPUP(*EMmsg,status,"In EMSplyhdrn:EMcvx4f4v error")
  return (status);

 }

end implementation EMSpolyhdrn;
