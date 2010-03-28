/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgenabsg

Description
   This routine generates the abstract data representation for a 3-D
   double precision symbol definition header object and places
   the data in the abstract geometry cache.

    *msg         IGRlong        completion message 
    *matrix_type IGRshort       type of transformation matrix
    matrix       IGRmatrix      transformation matrix
    **absgptr    IGRchar        pointer to abstract geometry buffer

Note
   The matrix should be an Identity matrix.  If the matrx is not 
   identity then MSFAIL will be returned.

History
   DEM/HGW  07/16/86 : Design date.
   DEM/HGW  07/16/86 : Creation date.
   HGW      08/14/86 : Changed terminology
   HGW      09/29/86 : Convert to 4.0
   HGW      11/02/87 : Change for version 1.1
   SCW      07/23/92 : Ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"

extern IGRchar              *GRabsg_alloc(); /* buffer allocation       */

method GRgenabsg (IGRlong *msg; IGRshort *matrix_type;
                  IGRmatrix matrix; IGRchar **absgptr)
{
IGRlong              om_msg;          /* OM return status        */
IGRint               i;               /* loop counter            */
IGRlong              absg_size;
struct IGRsymboldef  *sdh;
struct IGRlbsys      lbs;
struct IGRlbsys      t_lbs;
struct GRabsg_hdr    absg_hdr;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   /*
    *  Get the size of my abstract geometry.
    */

   om_msg = om$send(msg = message GRvg.GRgetsize (msg, matrix_type, 
            matrix, &absg_size), targetid = my_id);

   /*
    * initialize values of abstract geometry header
    */

   absg_hdr.geometry_size = absg_size;
   absg_hdr.id.objid = my_id;
   absg_hdr.id.osnum = OM_Gw_current_OS;
   absg_hdr.matrix_type = *matrix_type;

   for (i = 0; i < 16; ++i)
   {
      absg_hdr.matrix[i] = matrix[i];
   }

   /* 
    *  Allocate the abstract geometry buffer
    */

   sdh = (struct IGRsymboldef *)GRabsg_alloc(msg,&absg_hdr);

   if (*msg & 1)                  /* error allocating    */
   {
      if (*matrix_type == MAIDMX)
      {
         /*
          * initialize range block diagonal points
          */

         for (i = 0; i < 3; ++i)
         {
            sdh->diag_pt1[i] = me->diag_pt1[i];
            sdh->diag_pt2[i] = me->diag_pt2[i];
         }
      }else
      {
         /*
          *  Form a local bounded system and find the range of it.
          */

         MAidmx(msg, lbs.matrix);
         for (i = 0; i < 3; ++i)
         {
            lbs.diag_pt1[i] = me->diag_pt1[i];
            lbs.diag_pt2[i] = me->diag_pt2[i];
         }
         MAlbxform (msg, &lbs, matrix, &t_lbs);
         MAlbextents(msg, &t_lbs, sdh->diag_pt1, sdh->diag_pt2);
      }
   }

   *absgptr = (IGRchar *)sdh;
   return(om_msg);
}
end implementation GRsmdfhdr;
