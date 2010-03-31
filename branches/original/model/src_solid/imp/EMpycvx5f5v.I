/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpolyhdrn;

#include "EMS.h"
# include "bserr.h"
# include "emsmacros.h"
# include "EMSerrordef.h"
# include "emsedgedef.h"
# include "EMSconstruct.h"
# include "emsedgedef.h" /* for edge type definitions */
# include "EMSprop.h"

# define NO_OF_FACES 5
# define NO_OF_VERTICES 5
# define NO_OF_EDGES 8

method EMcvx5f5v (IGRlong *EMmsg;
                  struct GRvg_construct *construct_list;
                  IGRpoint *vertices)

/* **************************************************************

Description
              This method constructs a five faced five vertex
              polyhedron

              Input
               construct_list - pointer to construction information
               vertices       - array containing the xyz points
                                of the polyhedron

              Output
               EMmsg - completion code

Notes
              Upon exit the completion code will be one of the
              following
      
              EMS_S_Success    - if successful
              EMS_E_Fail       - if there is failure

Algorithm
              Send a EMcnsplyhdrn message to myself with appropriate
              input

See also 
              See solid construction notes. This explains the data
              structure necessary for defining the topology between
              the faces

History
              PP         :   10/10/87      Changes to handle setting
                                           edge types and natural
                                           edge props.
              PP         :   01/01/87      Genesis


**************************************************************** */


{
 IGRshort               i;          /* index used in for loop */
 IGRlong                status;     /* OM return status */

 IGRlong                cln_sts, cleanup_msg;
                                    /* OM return status and completion
                                       status during cleanup */

 static IGRshort        faces [NO_OF_FACES][5] = 
                         {
                          {1,4,3,2,1},
                          {3,3,4,5,3},
                          {1,1,5,4,1},
                          {1,1,2,5,1},
                          {2,2,3,5,2}
                         };
                                    /* array specifying the indices into
                                       the vertices array comprising a 
                                       face */

 static IGRuchar natural_curve_type [NO_OF_FACES][4] = 
                         {
              {EMlinesegment, EMlinesegment, EMlinesegment,EMlinesegment},
              {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
              {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
              {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
              {EMpoint, EMlinesegment, EMlinesegment, EMlinesegment},
                         };         /* array specifying the model space
                                       types of the natural edges */
        
 static IGRushort natural_edprops [NO_OF_FACES][4] = 
                         {
                          {0,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                          {EMED_DEGENERATE,0,0,0},
                         };        /* array specifying the edge properties
                                      of the natural edges */

           
 static IGRint          option [NO_OF_FACES] = 
                         { 2, 1, 1, 1, 1 };
                                    /* array specifying the polygon type */

 
 static IGRushort    connectivity[NO_OF_EDGES][5] =
                         {
                          {1,5,2,1,REVERSED},
                          {1,2,1,1,REVERSED},
                          {1,3,0,3,REVERSED},
                          {1,4,3,1,REVERSED},
                          {2,3,2,2,REVERSED},
                          {3,4,1,3,REVERSED},
                          {2,5,3,2,REVERSED},
                          {4,5,2,3,REVERSED}
                         };
                                    /* array specifying the connectivity
                                       relationships between uv edges
                                       across different faces */
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

/* **************************************************

   Should there be any error; all objects constructed are
   deleted

   ************************************************** */



  if (! (1 & status & *EMmsg))
  {
    cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg, 
                             construct_list->env_info),
                       targetid = my_id);
  }
  else
    *EMmsg = EMS_S_Success;

  EMWRAPUP(*EMmsg,status,"In EMSpolyhdrn:EMcvx5f5v error")
  return (status);

 }

end implementation EMSpolyhdrn;
