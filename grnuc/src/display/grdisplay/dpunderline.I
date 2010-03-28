
class implementation IGEgragad;

#include "grimport.h"
#include "exmacros.h"

/* prototype files */
%safe
#include "dpunderline.h"
#include "dptxunder.h"
%endsafe


from GRmodule import GRmdinfntptr;

#if defined(__STDC__) || defined(__cplusplus)
DPunderine(	IGRlong		*msg,
		struct IGRlbsys	*lbsys,
		struct IGResintx *txt_ele,
		GRspacenum	osnum,
		GRobjid		mod_objid,
		IGRint		which_char,
		IGRint		which_point,
		IGRint		horizontal,
		IGRdouble	*point1,
		IGRdouble	*point2 )
#else
DPunderine(msg, lbsys, txt_ele, osnum, mod_objid, which_char, which_point,
	   horizontal, point1, point2)
	

	IGRlong		*msg;
	struct IGRlbsys	*lbsys;
	struct IGResintx *txt_ele;
	GRspacenum	osnum;
	GRobjid		mod_objid;
	IGRint		which_char;
	IGRint		which_point;
	IGRint		horizontal;
	IGRdouble	*point1;
	IGRdouble	*point2;
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
	
	status = DPtxunder(msg,lbsys,txt_ele,os_fnt_ptr,which_char,
			   which_point,horizontal,point1, point2);
wrapup:

        return(status);
      }


end implementation IGEgragad;
