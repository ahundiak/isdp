#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igr.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpdef.h"

/* prototype files */
#include "DPsetinq.h"
#include "dpbrlnconst.h"
#include "mainvmx.h"
#include "maptsxfor.h"


 IGRint DPbrlnconstr(	IGRlong		*msg,
			IGRdouble	*point,
			GRobjid		id,
			GRspacenum	osnum,
			struct IGRline	*boreline )

  {
	
	struct var_list	   list[2];
	IGRdouble	   wld_to_view[16];
	IGRdouble	   view_to_wld[16];
	IGRdouble	   temp[6];
	IGRshort	   four=4;
	IGRlong		   bytes_returned;
	IGRlong 	   which_error;
	IGRlong 	   num_pts;
	
	IGRlong status = OM_S_SUCCESS;
	
	list[0].var = WLD_TO_VIEW;
	list[0].var_ptr = (char *)wld_to_view;
	list[0].num_bytes = sizeof(IGRdouble)*16;
	list[0].bytes_returned= &bytes_returned;
	list[1].var = END_PARAM;

	status = dp$inq_set_gragad( msg = msg,
			   osnum = osnum,
			   gragad_objid = id,
			   which_error = &which_error,
			   var_list = list);
	if (!(status & 1))
	{
#ifdef DEBUG
		printf("error in brlnconst inq ");
		om$report_error(sts = status);
#endif
	}
	num_pts = 1;
	if (!MAptsxform(msg,&num_pts,wld_to_view,point,temp))
	{
#ifdef DEBUG
	    printf("error in dpbrlnconst at ptsxform");
#endif
	    status = OM_E_ABORT;
	    goto fini;
	}		
	temp[2] = IGE_DESIGN_LIMITS_MIN;
	
	temp[3] = temp[0];
	temp[4] = temp[1];
	temp[5] = IGE_DESIGN_LIMITS_MAX;
	
	if (!MAinvmx(msg,&four,wld_to_view,view_to_wld))
	{
#ifdef DEBUG
	    printf("error in dpbrlnconst at invmx");
#endif
	    status = OM_E_ABORT;
	    goto fini;
	}
	
	num_pts = 2;
	if (!MAptsxform(msg,&num_pts,view_to_wld,temp,temp))
	{
#ifdef DEBUG
	    printf("error in dpbrlnconst at ptsxform");
#endif
	    status = OM_E_ABORT;	
	    goto fini;
	}		
	
	boreline->point1[0] = temp[0];
	boreline->point1[1] = temp[1];
	boreline->point1[2] = temp[2];
	boreline->point2[0] = temp[3];
	boreline->point2[1] = temp[4];
	boreline->point2[2] = temp[5];	
	fini:
	;
	return (status);
}
