/* ------------------------------------------------------------------------- */
/*                                                                           */ 
/*-------------------------------------------------------------------------- */ 
/*
API Definition

  ABSTRACT

  This API creates and attaches a reference file during an EMS session. The
  filename is supplied by the user along with the reference plane along which
  the reference file has to be created. The origin of the new reference file
  w.r.t. the reference plane has to be provided too. 

  NOTES

  The created reference file will be oriented parallel to the inputted 
  reference plane and will be in the same plane. 

  ARGUMENTS

  char filename[] (IN)    - Name of the reference file.
  int type (IN)           - Type of surface - datum (1)  or surface (2)
  PWobjid refplnid (IN)   - Objid of the reference plane.
  PWpoint origin (IN)     - Origin of the reference file w.r.t the origin
                            of the reference plane.
  PWobjid rfheader (OUT)  - GRreffile objid created for the reference file.
  PWosnum osn (OUT)       - The OS number of the created reference file.

  KEYWORDS

  Creation, Reference File

  CAVEATS

  Self Attachment ???

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
#include "go.h"
#include "dp.h"
#include "refmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "madef.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "exudata.h"

#define DATUM 1
#define SURFACE 2

from EMSdatpln import EMget_pln_info;
from GRvg import GRgetsize,GRgetgeom;

PWresult pwCreateReferenceFile
(
   char *filename ,
   PWobjid *rfheader ,
   PWosnum *osn
)
{
   IGRint status;
   IGRlong loc_msg;
   char curr_file[2048];
   char cur_file_name[2048];
   struct GRid ref_grid;
   GRspacenum ref_osnum;
   IGRmatrix rot_matrix;
   PWresult PWsts;
   char *tmpptr;

   if ((filename == NULL) || (filename[0] == '\0'))
   {
      return(PW_K_InvalidArg);
   }
   else
     if (access(filename, 0) == 0)
     {
         return(PW_K_InvalidArg);
     }

   if (rfheader == NULL || osn == NULL)
   {
      return(PW_K_InvalidArg);
   }

   om$os_number_to_name ( osnum = EX_active_OS_num,
                         osname = cur_file_name);

   tmpptr = strrchr(cur_file_name,'/');
   if(tmpptr != NULL)
   {
     tmpptr++;
     strcpy(curr_file, tmpptr);
   }
   else
   {
      return(PW_K_InvalidArg);
   } 

   /** Get the current file name and check against the input filename**/
   if (!strcmp(filename , curr_file))
   {
       return(PW_K_InvalidArg);

      /**** Self attachment code when it is decided to put it
      status = GetRotMatrixFromPlane(type,
                                     ref_plnid,
                                     origin,
                                     rot_matrix);

      status = rfAttachRefFile(&loc_msg,
                               filename,
                               rot_matrix,
                               origin,
                               &ref_grid,
                               &ref_osnum );  
      *****/
   }
   else
   {
      status = rfCreateRefFile(&loc_msg, filename);

      status = rfAttachRefFile(&loc_msg,
                               filename,
                               &ref_grid,
                               &ref_osnum );
   }

   /** On the creation of the reference file, activate it **/
   
   PWsts = pwActivateReferenceFile(filename, osn);

   *rfheader = ref_grid.objid;
   *osn = ref_osnum;

   return(PW_K_Success);

}

end implementation Root;
