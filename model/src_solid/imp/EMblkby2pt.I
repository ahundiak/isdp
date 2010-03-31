/* ###################   APOGEE COMPILED   ################## */
class implementation EMSblock;  

#include "EMS.h"
# include "EMSerrordef.h"
# include "emsmacros.h"
# include "EMSconstruct.h"
# include "emsedgedef.h"
# include "EMSprop.h"

# define NO_OF_FACES 6
# define TOTAL_NO_OF_VERTICES 8
# define NO_OF_EDGES 12
# define X 0
# define Y 1
# define Z 2

method EMboxby2pt(IGRlong *EMmsg;
                struct GRvg_construct *construct_list;
                IGRpoint  min, max )

/* ************************************************************

Description

            This method constructs a box by two points. The sides
          of the box are parallel to the coordinate system of the
          model space.

          Input
           construct_list - Pointer to the construction information
           min, max -  diagonal points of the box

          Output
           EMmsg - Pointer to the completion code 


Notes
      
           Upon exit the completion code will be one of the following
 
           EMS_S_Success - if successful
           EMS_E_Fail    - if failure


Algorithm

           1. Determine the vertices comprising the box.
           2. Send a EMcnsplyhdrn message to myself with the
              appropriate input.

See also 
 
          Solid construction notes. This explains the data structures
          necessary for defining the topology.

History
          PP : 10/10/87         Added the code for setting curve type
                                and edge props.
          PP : 01/01/87         design date


*****************************************************************/

{
  IGRlong               status;     /* OM return code */
  IGRlong               cln_sts,   
                        cleanup_msg;/* cleanup OM return code and 
                                       completion code */


  IGRpoint              vertices[TOTAL_NO_OF_VERTICES];
                                    /* array for storing the xyz 
                                       coordinates of the vertices */

  
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
  
  static                IGRint option [NO_OF_FACES] = 
                             {0,0,0,0,0,0};
                                         /* array specifying the polygon type */

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

/* *************************************

   Initialisation

   ************************************* */


  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


/* ***************************

   Determine the xyz coordinates of the vertices

   *************************** */


  vertices[0][X] = max[X];
  vertices[0][Y] = min[Y];
  vertices[0][Z] = min[Z];

  vertices[1][X] = max[X];
  vertices[1][Y] = max[Y];
  vertices[1][Z] = min[Z];

  vertices[2][X] = max[X];
  vertices[2][Y] = max[Y];
  vertices[2][Z] = max[Z];

  vertices[3][X] = max[X];
  vertices[3][Y] = min[Y];
  vertices[3][Z] = max[Z];

  vertices[4][X] = min[X];
  vertices[4][Y] = min[Y];
  vertices[4][Z] = min[Z];

  vertices[5][X] = min[X];
  vertices[5][Y] = max[Y];
  vertices[5][Z] = min[Z];

  vertices[6][X] = min[X];
  vertices[6][Y] = max[Y];
  vertices[6][Z] = max[Z];

  vertices[7][X] = min[X];
  vertices[7][Y] = min[Y];
  vertices[7][Z] = max[Z];
  
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
  if (! (1 & status & *EMmsg)) goto wrapup;

 wrapup:


/* ************************

   Cleanup operations

   ************************ */



  if (! (1 & status & *EMmsg))
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete (&cleanup_msg, 
                            construct_list->env_info),
                      targetid = my_id);
  }

  EMWRAPUP(*EMmsg, status, "In EMSblock:EMboxby2pt error")
  return(status);
}

end implementation EMSblock;   
