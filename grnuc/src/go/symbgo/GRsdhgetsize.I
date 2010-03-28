/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgetsize

Description
   This method will return the size of the abstract geometry for
   a symbol definition header.

   *msg         IGRlong        completion code
   *matrix_type IGRshort       The type of matrix
   matrix       IGRmatrix      The matrix to generate absg
   *size        IGRlong        The size of the abstract geometry.

History
   HGW/DEM  07/24/86 : Design Date and Creation Date
   HGW      08/07/86 : Changed terminology
   HGW      11/02/87 : Changed for version 1.1
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"

method GRgetsize (IGRlong *msg; IGRshort *matrix_type;
                  IGRmatrix matrix; IGRlong *size)
{
   *msg = MSSUCC;
   *size = sizeof(struct IGRsymboldef);
   return(OM_S_SUCCESS);
}
end implementation GRsmdfhdr;
