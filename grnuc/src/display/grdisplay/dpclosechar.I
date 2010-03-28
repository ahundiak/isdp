class implementation IGEgragad;

#include "grimport.h"
#include "exmacros.h"

/* prototype files */
%safe
#include "dpclosechar.h"
#include "dpprojchar.h"
%endsafe

from GRmodule import GRmdinfntptr;

#if defined(__STDC__) || defined(__cplusplus)
DPclosestchar(	IGRlong		*msg,
		struct IGRlbsys	*lbsys,
		struct IGResintx *txt_ele,
		GRspacenum	osnum,
		GRobjid		mod_objid,
		IGRdouble	*point,
		IGRint		*which_char )
#else
DPclosestchar(msg, lbsys, txt_ele, osnum, mod_objid, point, which_char)
	
	IGRlong		*msg;
	struct IGRlbsys	*lbsys;
	struct IGResintx *txt_ele;
	GRspacenum	osnum;
	GRobjid		mod_objid;
	IGRdouble	*point;
	IGRint		*which_char;
#endif	
	
      {
	
       IGRint status;
       struct DPfnt_os_tbl	*os_fnt_ptr;


	if (mod_objid == NULL_OBJID	)
	{
	  ex$get_cur_mod( id= &mod_objid);
	}

	status = om$send (msg = message GRmodule.GRmdinfntptr(msg, &os_fnt_ptr), 
			  senderid = NULL_OBJID, 
			  targetid = mod_objid, 
			  targetos = osnum);
			
	if (!(status & 1))
	{
	   om$report_error(sts = status);
	   goto wrapup;
	}
	
	status = DPprojchar(msg,lbsys,txt_ele,os_fnt_ptr,point,which_char);

wrapup:

        return(status);
      }


end implementation IGEgragad;
