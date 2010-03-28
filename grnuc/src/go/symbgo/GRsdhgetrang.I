/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgetrang

Description
   This method will calculate the range of a symbol definition header.
   If the world flag is set the range is in world coordinates.  Otherwise
   use identity to find the range.

   *msg         IGRlong       Completion code
   *matrix_type IGRshort      The type of matrix
   matrix       IGRmatrix     The matrix to use if world is set.
   world        IGRboolean    Use the world cordinate system to find 
                              the range
   range        GRrange       The range of symbol definition.

Notes
   If one wishes to retreive the extents of the symbol definition
   then call this method and set world to zero.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   11/03/87 : Creation date
   scw         07/23/92 : ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "madef.h"

method GRgetrang(IGRlong *msg;IGRshort *matrix_type; IGRmatrix matrix; 
                 IGRboolean *world; GRrange range)
{
IGRint               i;
IGRshort             local_matrix_type;
IGRmatrix            local_matrix;
struct  IGRsymboldef *absgptr;

   *msg = MSSUCC;
   if (*world)
   {   
      local_matrix_type = *matrix_type;
      for (i=0; i < 16; ++i)
      {
         local_matrix[i] = matrix[i];
      }
   }else
   {
      local_matrix_type = MAIDMX;
      MAidmx (msg, local_matrix);
   }

   /*
    *  Get the geometry.
    */

   GRgetabsg ( msg, &local_matrix_type, local_matrix, (IGRchar **)&absgptr, i);
        
   if (*msg & 1)
   {
      for (i = 0; i < 3; ++i)
      {
         range[i] = absgptr->diag_pt1[i];
         range[i+3] = absgptr->diag_pt2[i];
      }
   }
   return (OM_S_SUCCESS);
}
end implementation GRsmdfhdr;
