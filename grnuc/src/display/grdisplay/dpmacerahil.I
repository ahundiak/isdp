
class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "exmacros.h"
#include "msdef.h"

/* prototype files */
%safe
#include "dpmacerahil.h"
%endsafe

extern void DIclear_hilited ( void );

int DPerase_hilite ( long *msg, GRobjid	objid, GRspacenum osnum )
{
  int        status;
  GRobjid    mod_id;
  GRspacenum mod_osnum;

  /*
   * HGB - 5/11/93: clear the hilited lines in the directory command form
   */
  DIclear_hilited ();
  
  if (objid == NULL_OBJID)
  {

    ex$get_cur_mod (id = &mod_id,
        osnum = &mod_osnum);

  }
  else
  {
    mod_id = objid;
    mod_osnum = osnum;
  }



  status = om$send(msg = message IGEdisplay.DPerase_hilite(msg),
      senderid = NULL_OBJID,
      targetid = mod_id,
      targetos = mod_osnum);

  if (!(1 & status))
  {
#ifdef DEBUG
    printf("Error in DPerase_hilite's send to DPerase_hilite\n");
    om$report_error(sts = status);
#endif
    *msg = MSFAIL;
  }

  return(status);
}

end implementation IGEgragad;
