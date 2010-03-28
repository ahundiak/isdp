class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpdef.h"

/* prototype files */
%safe
#include "DPfddefvw.h"
%endsafe

#define DEBUG 1

#if defined(__STDC__) || defined(__cplusplus)
int DPfind_defaultvw ( IGRlong     *msg,
                       IGRlong     flag,
                       GRspacenum  osnum,
                       GRobjid     *objid )
#else
int DPfind_defaultvw (msg,flag,osnum,objid)

IGRlong *msg;
IGRlong flag;
GRspacenum osnum;
GRobjid *objid;
#endif

{
    DIint num_ids;
    DIchar pathname[DI_PATH_MAX];  
    DIgrid default_id;
    IGRint status;

	status = 1;
	*msg = 1;

	status = DIstmocpy (pathname,GRDP_VIEWS,GRDP_REGVIEWS,GRDP_GRVIEWS,".GRdefaultview",0,osnum);

	if (!(1 & status))
	{
	    status = 0;
	    *msg = 0;
	    goto fini;
	}
	status = di$start_dump ( regexp = pathname,
		   	ptr = &num_ids,
		   	options = OPT_ALL);
  	if(!(1&status) && ( status != DIR_W_NAME_NOT_FOUND )) 
  	{
	#ifdef DEBUG
	di$report_error(sts = status, comment = "didump failed in GRmodule");
	#endif
	goto fini;
  	}
	if (num_ids == 1)
	{
    		status = di$fetch_dump (p_grid = &default_id,
			index = 0);
    		if(!(1&status)) 
    		{
    		#ifdef DEBUG
    		di$report_error(sts = status, comment = "didump failed in GRmodule");
    		#endif
  		goto fini;
    		}
	    *objid = default_id.objid;
	    status = 1;
	    *msg = 1;
	}
	else
	{
	    if (flag & DPCONST_VW)
	    {
	    	status = om$construct(osnum = osnum,
                        classname = "IGEgragad",
                        p_objid = objid,
                        msg = message IGEgragad.gragad_cons(msg,
                                       ".GRdefaultview",0.0,0.0,1.0,1.0),
                        neighbor = OM_GS_NULL_NEIGHBOR);
	    	if(!(1&status)) 
    		{
    			#ifdef DEBUG
    			om$report_error(sts = status);
    			printf("error constructing default view \n");
    			#endif
    			goto fini;
    		}
	    status = 1;
	    *msg = 1;
	   }
	   else
	   {
	    	status = 0;
	    	*msg = 0;
	   }
	}
fini:
	return (status);
}

end implementation IGEgragad;
