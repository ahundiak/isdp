#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "maerr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"
#include "ma2lnpro.h"

static IGRchar error;

struct pt3d
{
   struct DPele_header elem[2];
   IGRchar first_pnt;
   struct IGRline *line1;
};

/* prototype files */

#include "dp3Ddatapt.h"
#include "dpdynamics.h"
#include "dpbrlnconst.h"

#include "mabrlncon.h"


IGRint DPdyn3dpt(add_info,button,mtx,objects,num_objects,buffers,num_buffers,
		in_flags,in_dum2,in_dum3,out_flags,out_dum2,out_dum3)

	struct pt3d		*add_info;
	struct EX_button	*button;
	IGRdouble		*mtx;
	struct GRid		**objects;
	IGRint			*num_objects;
	struct DPele_header	**buffers;
	IGRint			*num_buffers;
	IGRint			*in_flags;
	IGRchar			*in_dum2;
	IGRchar			*in_dum3;
	IGRint			*out_flags;
	IGRchar			**out_dum2;
	IGRchar			**out_dum3;

	
{

	IGRint status = MSSUCC;
	IGRlong msg;
	IGRpoint pt;	
	struct IGRline boreline;
	IGRpoint brlnpt1;
	IGRpoint brlnpt2;
	IGRpoint proj_pnt1;
	IGRpoint proj_pnt2;
	IGRdouble t1;
	IGRdouble t2;
	
	boreline.point1 = brlnpt1;
	boreline.point2 = brlnpt2;

	pt[0] = button->x;
	pt[1] = button->y;

	pt[2] = button->z;

	if (add_info->first_pnt == 1)
	{
	    if (! DPbrlnconstr(&msg,pt,button->objid,button->osnum,&boreline))
	    {
#ifdef DEBUG
	    	printf("Error in DPbrlnconstr");
#endif
	    	status = MSFAIL;
	    	goto fini;
	    }
	    add_info->elem[0].geometry.polyline->points[0] = brlnpt1[0];
	    add_info->elem[0].geometry.polyline->points[1] = brlnpt1[1];
	    add_info->elem[0].geometry.polyline->points[2] = brlnpt1[2];
	    add_info->elem[0].geometry.polyline->points[3] = brlnpt2[0];
	    add_info->elem[0].geometry.polyline->points[4] = brlnpt2[1];
	    add_info->elem[0].geometry.polyline->points[5] = brlnpt2[2];

	    *num_buffers = 1;
	}
	else
	{
	    *num_buffers = 2;

	    if (! MAbrlnconstr(&msg,pt,mtx,&boreline))
	    {
#ifdef DEBUG
	    	printf("Error in MAbrlnconstr");
#endif
	    	status = MSFAIL;
	    	goto fini;
	    }	
	    if (!MA2lnproj(&msg,add_info->line1,&boreline,proj_pnt1,proj_pnt2,&t1,&t2))
	    {
#ifdef DEBUG
	    	printf("Error in MA2lnproj");
#endif
	    	status = MSFAIL;
		goto fini;
	    }
	    if(msg == MAINFSOLUTION)
	    {
	    	if (!error)
		{
		    error = 1;
		    ex$message ( msgnumb = GR_E_EntPtVwDifRot);
		}
		*num_buffers = 1;
	    }
	    else
	    {
		
    	       if (error)
	       {
	    	  error = 0;
		  ex$message ( msgnumb = EX_S_Clear);
	       }

	       button->x = proj_pnt1[0];
	       button->y = proj_pnt1[1];
	       button->z = proj_pnt1[2];		

	       *out_flags |= DP_NEW_POINT;

	       if (! DPbrlnconstr(&msg,proj_pnt1,button->objid,
						button->osnum,&boreline))
		{
#ifdef DEBUG
		    printf("Error in DPbrlnconstr");
#endif
		    status = MSFAIL;
		    goto fini;
		}
	    	add_info->elem[1].geometry.polyline->points[0] = brlnpt1[0];
	    	add_info->elem[1].geometry.polyline->points[1] = brlnpt1[1];
	    	add_info->elem[1].geometry.polyline->points[2] = brlnpt1[2];
	    	add_info->elem[1].geometry.polyline->points[3] = brlnpt2[0];
	    	add_info->elem[1].geometry.polyline->points[4] = brlnpt2[1];
	    	add_info->elem[1].geometry.polyline->points[5] = brlnpt2[2];
	
	   } /* end of else part of if (msg == MAINFSOULUTION)  */
	
	} /* close for second point */

	*buffers = add_info->elem;

	fini:
		;

	return (status);
}

IGRint DP3Ddatapt(IGRdouble       *pnts,
		  IGRchar         first_pnt,
		  struct IGRline  *brline1 )

{
	struct IGRpolyline line1;      /* the bore line */
	struct IGRpolyline line2;      /* the bore line */
	struct IGRdisplay dis_att;
	struct pt3d info;
	IGRint status = 1;
	IGRint dyn_flags = DP_AUTO_DYN | DP_USE_WIN_FLAG | DP_ALL_WINDOWS;
	error = 0;

	line1.num_points = 2;
	line1.points = pnts;

	dis_att.color = 2;
	dis_att.weight = 0;
	dis_att.style = 5;

	dp$build_dis_buffer( 	buffer = info.elem,
				type = IGRPY,
				display_att = &dis_att,
				geometry = &line1);

	if (first_pnt)
	{
	    info.first_pnt = 1;
	}
	else
	{
	    info.first_pnt = 0;

	    line2.num_points = 2;
	    line2.points = &pnts[6];

	    info.line1 = brline1;
	
 	    dp$build_dis_buffer(buffer = &info.elem[1],
				type = IGRPY,
				display_att = &dis_att,
				geometry = &line2);

	}


	dp$dynamics(	dyn_fun = DPdyn3dpt,
			information = (IGRchar *)&info,
			flags = &dyn_flags);
	if (error)
	{
	    ex$message ( msgnumb = EX_S_Clear);
	}

	return (status);
}

