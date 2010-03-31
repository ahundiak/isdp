/* ------------------------------------------------------------------------- */
/*                                                                           */ 
/*-------------------------------------------------------------------------- */ 
/*
API Definition

  ABSTRACT

  This API deactivates the given reference file. 

  NOTES

  ARGUMENTS

  char filename[] (IN)   - The reference file name
  PWosnum *osn (OUT)     - The deactivated reference file's osnum

  KEYWORDS

  Deactivation, Reference File

  CAVEATS

  None so far

  HISTORY

  Satish - Creation - 

*/

class implementation Root;

#include "OMminimum.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "refmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "madef.h"

#include "exudata.h"

from GRreffile import GRgetosnum;
from GRgraphics import GRdisplay;

PWresult pwDeactivateReferenceFile
(
   char *filename ,
   PWosnum *osn
)
{
   IGRlong msg;
   IGRint status;
   int entry_num;

   exUDataActref rfact;

   struct GRid *ref_ids;
   int num_ref,ii;
   IGRchar **ref_names;
   struct GRid rfhead;
   IGRboolean found;

   if (filename == NULL || *filename == '\0')
   {
      return(PW_K_Error);
   }

   gr$review_ref_files(msg = &msg,
                       output_file = NULL,
                       ref_grids = &ref_ids,
                       ref_names = &ref_names,
                       num_found = &num_ref);
   found = FALSE;
   for (ii=0;ii<num_ref;ii++)
   {
      if (!strcmp(ref_names[ii], filename))
      {
         GRspacenum tmpos;
         {
             om$send(msg = message GRreffile.GRgetosnum(&msg, &tmpos),
                     senderid = NULL_OBJID,
                     targetid = ref_ids[ii].objid,
                     targetos = ref_ids[ii].osnum);

             status = ex$is_invis(mod_osnum = tmpos,index = &entry_num);

             if (status)
             {
                found = TRUE;
                rfhead = ref_ids[ii];
                if (osn) *osn = tmpos;
                if (ref_names) free(ref_names);
                if (ref_ids) free(ref_ids);
                break;
             }
         }
      }
   }
               
   if (found)
   {
      /** Update the global variables **/
      rfact.aflag = FALSE;
      rfact.osn   = 0;
      rfact.refid.objid = NULL_OBJID;

      status = exPostUData(EX_UDATA_ACTREF, (char *)&rfact);
   }
   else
   {
      char curr_file[2048];
      char cur_file_name[2048];
      char *tmpptr;

      om$os_number_to_name ( osnum = EX_active_OS_num,
                             osname = cur_file_name);

      tmpptr = strrchr(cur_file_name,'/');
      if(tmpptr != NULL)
      {
         tmpptr++;
         strcpy(curr_file, tmpptr);
      }
      if (!strcmp(curr_file,filename))
      {
         /* The current file being activated */
         /* Update the global variables */
         rfact.aflag = FALSE;
         rfact.osn   = 0;
         rfact.refid.objid = NULL_OBJID;

         status = exPostUData(EX_UDATA_ACTREF, (char *)&rfact);
         if (osn) *osn = EX_active_OS_num;
      }
      else
      {
         return(PW_K_InvalidArg);
      }
   }
   return(PW_K_Success);
}

end implementation Root;
