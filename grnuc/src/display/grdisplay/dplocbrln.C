#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igr.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpdef.h"

/* prototype files */
#include "DPsetinq.h"
#include "dplocbrln.h"

#include "mainvmx.h"
#include "malnplise.h"
#include "maptsxfor.h"


#if defined(__STDC__) || defined(__cplusplus)
 IGRint DPlocbrln(IGRlong		*msg,
		  IGRdouble		*point,
		  GRobjid		id,
		  GRspacenum		osnum,
		  struct IGRline	*boreline )
#else
 IGRint DPlocbrln(msg,point,id,osnum,boreline)

  IGRlong	*msg;
  IGRdouble	*point;
  GRobjid	id;
  GRspacenum	osnum;
  struct IGRline	*boreline;
#endif

  {
	
	struct var_list	   list[4];
	IGRdouble	   wld_to_view[4][4];
	IGRdouble	   view_to_wld[4][4];
	IGRdouble	   temp[6];
	IGRshort	   four=4;
	IGRshort	   i;
	IGRlong		   bytes_returned;
	IGRlong 	   which_error;
	IGRlong 	   num_pts;
	IGRint		   gragad_flag;
	IGRdouble 	   vw_volume[6];
	IGRdouble 	   tol;
	IGRdouble 	   t;
	IGRdouble	   eye[3];
	IGRdouble	  pl_pt[3];
	IGRdouble	  norm[3];
	struct IGRplane	   z_plane;
	struct IGRline     line1;

	IGRlong status = OM_S_SUCCESS;

	list[0].var = WLD_TO_VIEW;
	list[0].var_ptr = (char *)wld_to_view;
	list[0].num_bytes = sizeof(IGRdouble)*16;
	list[0].bytes_returned= &bytes_returned;
	list[1].var = GRAGAD_FLAGS;
	list[1].var_ptr = (char *)&gragad_flag;
	list[1].num_bytes = sizeof(IGRint);
	list[1].bytes_returned= &bytes_returned;
	list[2].var = VW_VOLUME;
	list[2].var_ptr = (char *)vw_volume;
	list[2].num_bytes = sizeof(IGRdouble)*6;
	list[2].bytes_returned= &bytes_returned;

	list[3].var = END_PARAM;

	status = dp$inq_set_gragad( msg = msg,
			   osnum = osnum,
			   gragad_objid = id,
			   which_error = &which_error,
			   var_list = list);
	if (!(status & 1))
	{
		om$report_error(sts = status);
		goto fini;
	}
	num_pts = 1;
	if (!MAptsxform(msg, &num_pts, (IGRdouble *)wld_to_view, point, temp))
	{
	    status = OM_E_ABORT;
	    goto fini;
	}		

	if (gragad_flag & IS_PERSP)
	{
		/* find in viewing coordinates the intersection of the 
		z planes with the vector from the eye point to the input pt */

		line1.point1 = eye;
		line1.point2 = temp;
		z_plane.point = pl_pt;
		z_plane.normal = norm;
		tol = 0;
	        for ( i = 0; i < 3; ++i )
	        {
		    eye[i] = 0;
		    pl_pt[i] = 0;
		    norm[i] = 0;
	        }
		pl_pt[2] = vw_volume[2];
		norm[2] = 1;
	    	if(! MAlnplisect (msg,&line1,&z_plane,&tol,temp,&t))
		{
			status = OM_E_ABORT;
			goto fini;
		}
		pl_pt[2] = vw_volume[5];
	    	status = MAlnplisect (msg,&line1,&z_plane,&tol,&temp[3],&t);
		if (!(status & 1))
		{
			goto fini;
		}
	}
	else
	{
	        if (gragad_flag & FRONT_CLIP)
		{
		    temp[2] = vw_volume[2];
		}
		else
		{
		    temp[2] = IGE_DESIGN_LIMITS_MIN;
		}
		temp[3] = temp[0];
		temp[4] = temp[1];
	        if (gragad_flag & BACK_CLIP)
		{
		    temp[5] = vw_volume[5];
		}
		else
		{
		    temp[5] = IGE_DESIGN_LIMITS_MAX;
		}
	} /* end of if not persp */

	if (!MAinvmx(msg, &four, (IGRdouble *)wld_to_view, 
			(IGRdouble *)view_to_wld))
	{
	    status = OM_E_ABORT;
	    goto fini;
	}
	num_pts = 2;
	if (!MAptsxform(msg, &num_pts, (IGRdouble *)view_to_wld, temp, temp))
	{
	    status = OM_E_ABORT;	
	    goto fini;
	}		
    	OM_BLOCK_MOVE (temp, boreline->point1,sizeof(IGRdouble)*3);
    	OM_BLOCK_MOVE (&temp[3], boreline->point2,sizeof(IGRdouble)*3);
	fini:
	;
	return (status);
}

