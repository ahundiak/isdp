class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "gr.h"
#include "igr.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dperr.h"
#include "dpdef.h"
#include "godef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMmacros.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"

#define BORDER_PERC .03

struct get_rng
{
   OM_p_RTREESTAT  rt_stat;
   IGRint	   *ret;
};

/* prototype files */
%safe
#include "DPfitrng.h"
#include "dpaxisalign.h"
#include "dpgetrng.h"
#include "dpsetrng.h"

#include "madabs.h"
%endsafe


from module import GRmod_passon;

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPfit_range (	IGRlong 	*msg,
			IGRint 		in_flags,
			GRobjid 	module_id,
			GRspacenum	module_os,
			IGRdouble	*wld_to_view,
			IGRdouble	*range )
#else
IGRint DPfit_range (msg,in_flags,module_id, module_os, wld_to_view, range) 

IGRlong *msg;
IGRint in_flags;
GRobjid module_id;
GRspacenum module_os;
IGRdouble *wld_to_view;
IGRdouble *range;
#endif

{

   IGRint       sts;            /* OM return status         */
   IGRdouble    rng[6];         /* window range               */
   IGRdouble    x_rng_delta;
   IGRdouble    y_rng_delta;
   IGRdouble    z_rng_delta;
   IGRdouble    rng_delta;
   struct DPrange_check range_chk;
   IGRdouble		new_range[6];
   struct  get_rng      rng_arg;
   OM_S_RTREESTAT	rtree_info;
   OM_S_MESSAGE		rng_msg;
   IGRint		ret;
   IGRshort		axis_aligned;
   IGRint		beg = 0;
   IGRint		fin = 0;


   rtree_info.request_type = RTREE_PAGE_STATUS;
   rtree_info.rtree_status.page.level_no = 0;

   rng_arg.rt_stat = &rtree_info;
   rng_arg.ret     = &ret;
   sts = OM_S_SUCCESS; 

/*  get range of rtree  */

    sts = om$make_message (classname = "GRrtree",
			   methodname = "get_stat",
			   size = sizeof(struct get_rng),
			   p_arglist = &rng_arg,
			   p_msg = &rng_msg);

    if (!(sts & 1))
    {
#ifdef DEBUG
       printf("Error in DPfit's make message\n");
       om$report_error(sts = sts);
#endif
       goto wrapup;
    }
    sts = om$send ( msg = message module.GRmod_passon(msg,&rng_msg,
					"module.primary",&beg,&fin),
		    senderid = NULL_OBJID,
		    targetid = module_id,
		    targetos = module_os);
		
    if (!(sts & 1))
    {
#ifdef DEBUG
       printf("Error in DPfit's send to module\n");
       om$report_error(sts = sts);
#endif
       goto wrapup;
    }

    if (ret == DB_I_EMPTYTREE)
    {
	sts = DB_I_EMPTYTREE;
	goto wrapup;
    }
    else 
    {
       if (ret != DB_SUCCESS)
       {
#ifdef DEBUG
	  printf("Error in DPfit's send to the Rtree\n");
#endif
	  *msg = MSFAIL;
	  goto wrapup ;
       }
    }

      rng[0] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmin;

      rng[1] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymin;

      rng[2] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmin;

      rng[3] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmax;

      rng[4] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymax;

      rng[5] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmax;

    if (rng[0] != IGE_DESIGN_LIMITS_MAX)
    {
	if (in_flags & VIEW_COOR)
	{
       	    DPsetrng (msg,wld_to_view,&range_chk);
	    
            if (!DPgetrng (msg,wld_to_view,
			  &range_chk,rng,new_range))
            {
#ifdef DEBUG
	  	printf("error in DPfit's DPgetrng call\n");
#endif
	  	goto wrapup;
            }
	    DPaxisalign (msg,wld_to_view,&axis_aligned);
	}
	else
	{
	    OM_BLOCK_MOVE(rng,new_range,(sizeof (IGRdouble) *6));
	    axis_aligned = 1;
	}

	x_rng_delta = (new_range[3] - new_range[0]);
    	y_rng_delta = (new_range[4] - new_range[1]);
    	z_rng_delta = (new_range[5] - new_range[2]);

	x_rng_delta = MAdabs(msg,&x_rng_delta);
	y_rng_delta = MAdabs(msg,&y_rng_delta);
	z_rng_delta = MAdabs(msg,&z_rng_delta);

	if (axis_aligned)
	{
	    if (x_rng_delta > y_rng_delta)
    	    {
	    	rng_delta = x_rng_delta;
	    }
	    else
	    {
	    	rng_delta = y_rng_delta;
	    }
    	}	
	else
	{
	    if (x_rng_delta > y_rng_delta)
    	    {
	    	if (x_rng_delta > z_rng_delta)
	    	{
	    	    rng_delta = x_rng_delta;
	    	}
	    	else
	    	{
	    	    rng_delta = z_rng_delta;
	    	}
    	    }
    	    else /* y is greater */
    	    {
	    	if (y_rng_delta > z_rng_delta)
	    	{
	    	    rng_delta = y_rng_delta;
	    	}
	    	else
	    	{
	    	    rng_delta = z_rng_delta;
	    	}
    	    }	
	}

        rng_delta = rng_delta * BORDER_PERC;

	  new_range[0] -= rng_delta;
    	  new_range[3] += rng_delta;

	  range[0] = new_range[0];
	  range[3] = new_range[3];

	  new_range[1] -= rng_delta;
	  new_range[4] += rng_delta;
	
	  range[1] = new_range[1];
	  range[4] = new_range[4];

    	  new_range[2] -= rng_delta;
    	  new_range[5] += rng_delta;
	
	  range[2] = new_range[2];
	  range[5] = new_range[5];

}
else
{
	sts = DPDGNLIMIT;
}

wrapup:

return(sts);

}

end implementation IGEgragad;
