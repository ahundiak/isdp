/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GR3dlbvipost

Description
   This routine will post a local bounded system into a 3-d format.

   *msg              IGRlong           completion code
   *mod_env          struct GRmd_env   module environment
   view_independent  IGRint            if 1 view independent
                                       if 0 not view independent
   *lbs              struct IGRlbsys   local bounded system
   *local_lbs        struct IGRlbsys   local bounded system in local cord
   range             GRrange           the range of the new lbs

Notes
   If range is NULL then the range will not be computed.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   09/09/88    Creation date
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

extern IGRboolean     MAinvmx();
extern IGRboolean     MAmulmx();
extern IGRboolean     MAlbextents();
extern IGRdouble      MAdabs();

IGRint GR3dlbvipost (msg, mod_env, view_independent, lbs, local_lbs, range)
IGRlong           *msg;
struct GRmd_env   *mod_env;
IGRint            view_independent;
struct IGRlbsys   *lbs;
struct IGRlbsys   *local_lbs;
GRrange           range;
{
IGRlong           om_msg;
IGRshort          four = 4;            /* matrix size              */
IGRint            i;
IGRdouble         temp_pt1;
IGRdouble         temp_pt2;
IGRdouble         longest_extent;
IGRmatrix         invmx;
struct IGRlbsys   tlb;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   if (mod_env->md_env.matrix_type != MAIDMX)
   {
      /* 
       *  Determine inverse transformation matrix
       */

      if (MAinvmx(msg, &four, mod_env->md_env.matrix, invmx))
      {
         /* 
          *  Multiply local bounded system matrix by inverse matrix
          */

         if (!MAmulmx(msg, &four, &four, &four, invmx, lbs->matrix, 
                      local_lbs->matrix))
         {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
         }
      }else
      {
         *msg = GRSNOINVTRAN;
         om_msg = OM_E_ABORT;
      }
   }else                              /* identity matrix        */
   {
      for (i = 0; i < 16; ++i)
      {
          local_lbs->matrix[i] = lbs->matrix[i];
      }
   }

   if (om_msg & *msg & 1)
   {
      if (view_independent)
      {
         /*
          *  View independent local bounded system.
          */

         longest_extent = 0;
         for (i=0; i < 3; ++i)
         {
            temp_pt1 = MAdabs(msg, &lbs->diag_pt1[i]);
            temp_pt2 = MAdabs(msg, &lbs->diag_pt2[i]);
            if (temp_pt1 > longest_extent)
            {
               longest_extent = temp_pt1;
            }

            if (temp_pt2 > longest_extent)
            {
               longest_extent = temp_pt2;
            }
         }

         local_lbs->diag_pt1[0] = -longest_extent;
         local_lbs->diag_pt1[1] = -longest_extent;
         local_lbs->diag_pt1[2] =  longest_extent;
         local_lbs->diag_pt2[0] =  longest_extent;
         local_lbs->diag_pt2[1] =  longest_extent;
         local_lbs->diag_pt2[2] = -longest_extent;
      }else
      {
         for (i = 0; i < 3; ++i)
         {
            local_lbs->diag_pt1[i] = lbs->diag_pt1[i];
            local_lbs->diag_pt2[i] = lbs->diag_pt2[i];
         }
      }

      if (range)
      {
         /*
          *  Determine range of the lbs
          */

         for (i=0; i < 3; ++i)
         {
            tlb.diag_pt1[i] = local_lbs->diag_pt1[i];
            tlb.diag_pt2[i] = local_lbs->diag_pt2[i];
         }

         for (i=0; i < 16; ++i)
         {
            tlb.matrix[i] = lbs->matrix[i];
         }

         MAlbextents(msg, &tlb, range, &range[3]);

         /*
          *  Check range of object against design limits
          */

         for (i = 0; i < 3; ++i)
         {
            if ((range[i] < GRDGNLIMITS_MIN_D) ||
                (range[i+3] > GRDGNLIMITS_MAX_D))
            {
               *msg = GRSDGNEXCEED;
               om_msg = OM_E_ABORT;
            }
         }
      }
   }
   return (om_msg);
}

/*\
Name
   GR3dlbpost

Description
   This routine will post a local bounded system into a 3-d format.

   *msg              IGRlong           completion code
   *mod_env          struct GRmd_env   module environment
   *lbs              struct IGRlbsys   local bounded system
   *local_lbs        struct IGRlbsys   local bounded system in local cord
   range             GRrange           the range of the new lbs

Notes
   If range is NULL then the range will not be computed.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   11/09/87    Creation date
\*/
IGRint GR3dlbpost (msg, mod_env, lbs, local_lbs, range)
IGRlong           *msg;
struct GRmd_env   *mod_env;
struct IGRlbsys   *lbs;
struct IGRlbsys   *local_lbs;
GRrange           range;
{
   return (GR3dlbvipost (msg, mod_env, NULL, lbs, local_lbs, range));
}
