/*
Name
        GRcheckref - This function checks to see if the requested object space
        represents a reference file object space.

Synopsis
        IGRlong GRcheckref(msg, type, matrix, master_osnum, object_osnum)

        IGRlong    *msg;
        IGRshort   *type;
        IGRmatrix  matrix;
        OMuword    *master_osnum;
        OMuword    *object_osnum;
  
Description

        This function determines if a particular object space represents a
        reference file object space.
  
Diagnostics
        The return codes:
                MSSUCC
                GRNOTREFFILE
                MSFAIL

Notes
        GRlslmgr.wake_up and GRlslmgr.sleep are dependent on the matrix type,
        the matrix, and the master_osnum arguments being ignored.

History
        MAS     09/23/87    Design Date
        mrm     06/12/92    added comments about GRlslmgr dependencies
*/

class implementation Root;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "referr.h"
#include "refpriv.h"

from GRcontext import GRgetinstance;

	#argsused
IGRlong GRcheckref (msg, type, matrix, master_osnum, object_osnum )
IGRlong    *msg;
IGRshort   *type;
IGRmatrix  matrix;
OMuword    *master_osnum;
OMuword    *object_osnum;
{
  short refflag;
  int   index;

  *msg = GRNOTREFFILE;

  Get_invisible_index ( *object_osnum, index );
  if (index >= 0)
  {
    /* object_osnum is in invisible table. */
    Get_ref_flag ( index,refflag );
    if (refflag == EX_ref)
      *msg = MSSUCC;
  }

  return OM_S_SUCCESS;
}

end implementation Root;
