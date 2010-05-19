/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRudsave
Synopsis
        method GRudsave (long *msg; struct GRid *add_id; 
                        struct GRmd_env *add_mod)

        msg             - return status
        add_id          - GRid of object being manipulated
        add_mod         - module of object being manipulated

        This is the latest version as of 1/1/98
Description
        This method saves the object being manipulated on a 
        channel off of the undo object, after deleting any objects
        previously placed on that channel.  If the object is a graphic
        set, it is placed on the GRundo.to_grset channel; otherwise
        it is placed on the GRcmpowner.to_components channel.
        The locatable and displayable bits of the object being
        manipulated are turned off.  If undo is turned off, the object
        is deleted immediately.

Notes
        Initially undo supports only "undelete"

History
        mrm     09/05/86    Creation
                10/14/86    OM 4.0 conversion
                09/23/87    Channel changes
                06/23/89    don't count on me->can_undo; check channel count
                07/24/89    ignore empty channel
        jhw     01/10/90    special check for reference file objects
      anand     09/10/97    Enhancements to delete command defining rules for
                            EMS objects with dependencies. 


	HF	04/01/98	VDS TR # 179800890
				Override of function delete_warn_notify() ONLY !!!
				

Bugs
        Fence delete of reference file objects will result in an undisplayable
        /unlocatable reference file attachment but the clipping polygon will be
        unchanged.
        
*/
class implementation GRundo;

#include <OMerrordef.h>
#include "grimport.h"
#include "grgsmacros.h"
#include "godef.h"
#include "madef.h"
#include "DImacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "alloca.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include "grmacros.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include <stdlib.h>
#include "nddef.h"

/*
*/

#define  FI_YES     100
#define  FI_NO      200 

IGRint delete_warn_notify(form_label, gadget_label, value, form_ptr )
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{

  switch(gadget_label)
  {
  case FI_YES:
    {
      long stat;
      int  rsp = EX_FORM_FINISHED;
      ex$putque(msg = &stat, response = &rsp);
//    FIf_erase(form_ptr);
      FIf_delete(form_ptr); form_ptr = NULL;		// HF: 04/01/98 TR # 179800890
      
      break;
    }
  case FI_NO:
    {
      long stat;
      int  rsp = EX_RJT_MOVEON;
      ex$putque(msg = &stat, response = &rsp);
//    FIf_erase(form_ptr);
      FIf_delete(form_ptr); form_ptr = NULL;		// HF: 04/01/98 TR # 179800890

      break;
    }
  }
  return(1);
}

end implementation GRundo;
