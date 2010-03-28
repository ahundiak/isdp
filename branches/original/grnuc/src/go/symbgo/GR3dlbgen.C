/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GR3dlbvigenabsg

Description
   This routine will generate a local bounded system.

   *msg              IGRlong           completion code
   *matrix_type      IGRshort          type of matrix
   matrix            IGRmatrix         matrix local to world
   view_independent  IGRint            If 1 view independent
                                       if 0 not view independent
   rot_matrix[]      IGRdouble         local to world of lbs
   origin[]          IGRdouble         origin of lbs
   diag_pt1[]        IGRdouble         diagonal point one          
   diag_pt2[]        IGRdouble         diagonal point two
   objid             GRobjid           object id
   osnum             GRspacenum        object space number 
   **absgptr         IGRchar           pointer to abstract geometry.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   11/09/87    Creation date
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"

extern IGRboolean  MAmulmx();
extern IGRdouble   MAdabs();

IGRint GR3dlbvigenabsg (msg, matrix_type, matrix, view_independent, 
                        rot_matrix, origin, diag_pt1, diag_pt2, objid, 
                        osnum, absgptr)
IGRlong           *msg;
IGRshort          *matrix_type;
IGRmatrix         matrix;
IGRint            view_independent;
IGRdouble         rot_matrix[];
IGRdouble         origin[];
IGRdouble         diag_pt1[];
IGRdouble         diag_pt2[];
GRobjid           objid;
GRspacenum        osnum;
IGRchar           **absgptr;
{
IGRlong           om_msg;
IGRint            i,j,k;
IGRshort          four = 4;
IGRdouble         temp_pt1;
IGRdouble         temp_pt2;
IGRdouble         longest_extent;
IGRmatrix         trans_matrix;
struct GRabsg_hdr absg_hdr;
struct IGRlbsys   *lbs;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   /*
    * initialize values of abstract geometry header
    */

   absg_hdr.geometry_size = sizeof (struct IGRlbsys);
   absg_hdr.id.objid = objid;
   absg_hdr.id.osnum = osnum;
   absg_hdr.matrix_type = *matrix_type;

   for (i = 0; i < 16; ++i)
   {
      absg_hdr.matrix[i] = matrix[i];
   }

   /* 
    *  Allocate the abstract geometry buffer
    */

   lbs = (struct IGRlbsys *)GRabsg_alloc(msg, &absg_hdr);

   if (*msg & 1)
   {
      if (*matrix_type != MAIDMX)
      {
         for (i = 0, k = 0; i < 9; i += 4)
         {
            for (j = i; j < i+3; ++j, ++k)
            {
               trans_matrix[j] = rot_matrix[k];
            }
         }

         trans_matrix[3]  = origin[0];
         trans_matrix[7]  = origin[1];
         trans_matrix[11] = origin[2];
         trans_matrix[12] = 0;
         trans_matrix[13] = 0;
         trans_matrix[14] = 0;
         trans_matrix[15] = 1;

         if (!MAmulmx(msg, &four, &four, &four, matrix, trans_matrix,
                      lbs->matrix))
         {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
         }
      }else
      {
         for (i = 0, k = 0; i < 9; i += 4)
         {
            for (j = i; j < i+3; ++j, ++k)
            {
               lbs->matrix[j] = rot_matrix[k];
            }
         }

         lbs->matrix[3]  = origin[0];
         lbs->matrix[7]  = origin[1];
         lbs->matrix[11] = origin[2];
         lbs->matrix[12] = 0;
         lbs->matrix[13] = 0;
         lbs->matrix[14] = 0;
         lbs->matrix[15] = 1;
      }

      if (om_msg & *msg & 1)
      {
         /*
          *  initialize range block diagonal points
          */
         
         if (view_independent)
         {
            /*
             *  View independent local bounded system.
             */

            longest_extent = 0;
            for (i=0; i < 3; ++i)
            {
               temp_pt1 = MAdabs(msg, &diag_pt1[i]);
               temp_pt2 = MAdabs(msg, &diag_pt2[i]);
               if (temp_pt1 > longest_extent)
               {
                  longest_extent = temp_pt1;
               }

               if (temp_pt2 > longest_extent)
               {
                  longest_extent = temp_pt2;
               }
            }

            lbs->diag_pt1[0] = -longest_extent;
            lbs->diag_pt1[1] = -longest_extent;
            lbs->diag_pt1[2] =  longest_extent;
            lbs->diag_pt2[0] =  longest_extent;
            lbs->diag_pt2[1] =  longest_extent;
            lbs->diag_pt2[2] = -longest_extent;
         }else
         {
            for (i=0; i < 3; ++i)
            {
               lbs->diag_pt1[i] = diag_pt1[i];
               lbs->diag_pt2[i] = diag_pt2[i];   
            }
         }
         *absgptr = (IGRchar *)lbs;
      }
   }
   return (om_msg);
}

/*\
Name
   GR3dlbgenabsg

Description
   This routine will generate a local bounded system.

   *msg              IGRlong           completion code
   *matrix_type      IGRshort          type of matrix
   matrix            IGRmatrix         matrix local to world
   rot_matrix[]      IGRdouble         local to world of lbs
   origin[]          IGRdouble         origin of lbs
   diag_pt1[]        IGRdouble         diagonal point one          
   diag_pt2[]        IGRdouble         diagonal point two
   objid             GRobjid           object id
   osnum             GRspacenum        object space number 
   **absgptr         IGRchar           pointer to abstract geometry.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   11/09/87    Creation date
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"

extern IGRboolean  MAmulmx();

IGRint GR3dlbgenabsg (msg, matrix_type, matrix, rot_matrix, origin, 
                      diag_pt1, diag_pt2, objid, osnum, absgptr)
IGRlong           *msg;
IGRshort          *matrix_type;
IGRmatrix         matrix;
IGRdouble         rot_matrix[];
IGRdouble         origin[];
IGRdouble         diag_pt1[];
IGRdouble         diag_pt2[];
GRobjid           objid;
GRspacenum        osnum;
IGRchar           **absgptr;
{
   return (GR3dlbvigenabsg (msg, matrix_type, matrix, NULL, rot_matrix,
                            origin, diag_pt1, diag_pt2, objid, osnum, 
                            absgptr));
}
