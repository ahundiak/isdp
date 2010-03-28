#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"

/* prototype files */
#include "DPunitvwvec.h"

#include "madabs.h"
#include "mainvmx.h"
#include "madotvc.h"
#include "maptsxfor.h"
#include "maunitvc.h"


IGRboolean  DPunit_vwvec (msg,rotation,unit_vw_vec)

IGRlong *msg;
IGRdouble *rotation;
IGRdouble *unit_vw_vec;
{
IGRdouble view_vec[3];
IGRdouble pos_vec[3];
IGRdouble dot_prod;
IGRlong status = FALSE;


	    view_vec[0] = rotation[8];
	    view_vec[1] = rotation[9];
	    view_vec[2] = rotation[10];
	    pos_vec[0] = 1;
	    pos_vec[1] = 1;
	    pos_vec[2] = 1;
	    if (!MAdotvc(msg,view_vec,pos_vec,&dot_prod))
	    {
		goto fini;
	    }
	    if (dot_prod < 0 )
	    {
		view_vec[0] = - view_vec[0];
		view_vec[1] = - view_vec[1];
		view_vec[2] = - view_vec[2];
	    }		
	    MAunitvc(msg,view_vec,unit_vw_vec);

	    status = TRUE;
	    *msg = MSSUCC;
fini:

	return(status);	
}

IGRboolean DPwld_z (msg,view_z,wld_to_view,unit_vw_vec,wld_z)

IGRlong *msg;
IGRdouble view_z;
IGRdouble *wld_to_view;
IGRdouble *unit_vw_vec;
IGRdouble *wld_z;

{
IGRlong num_pts =1;
IGRshort four = 4;
IGRdouble view_to_wld[4][4];
IGRdouble ex_zpt[3];
IGRdouble abs_zpt[3];
IGRshort zid;
IGRlong status = FALSE;

	    ex_zpt[0] = wld_to_view[3];    
	    ex_zpt[1] = wld_to_view[7];
	    ex_zpt[2] = view_z;    
	    num_pts = 1;
    	if(!MAinvmx(msg, &four, wld_to_view, (IGRdouble *)view_to_wld))
    	{
    		goto fini;
    	}
    	    if(!MAptsxform(msg, &num_pts, (IGRdouble *)view_to_wld, ex_zpt,
				ex_zpt))
    	    {
	    	goto fini;
	    }
	    if (unit_vw_vec[0] == 0)
	    {
		ex_zpt[0] = 0;
	    }
	    else
	    {
	    	ex_zpt[0] = ex_zpt[0] / unit_vw_vec[0];
	    }
	    if (unit_vw_vec[1] == 0)
	    {
		ex_zpt[1] = 0;
	    }
	    else
	    {
	    	ex_zpt[1] = ex_zpt[1] / unit_vw_vec[1];
	    }
	    if (unit_vw_vec[2] == 0)
	    {
		ex_zpt[2] = 0;
	    }
	    else
	    {
	    	ex_zpt[2] = ex_zpt[2] / unit_vw_vec[2];
	    }
	    abs_zpt[0] = MAdabs(msg,&ex_zpt[0]);
	    abs_zpt[1] = MAdabs(msg,&ex_zpt[1]);
	    abs_zpt[2] = MAdabs(msg,&ex_zpt[2]);
	    if (abs_zpt[0] > abs_zpt[1])
	    {
		    zid = 0;
	    }
	    else
	    {
		    zid = 1;
	    }
	    if (abs_zpt[2] > abs_zpt[zid])
	    {
		zid = 2;
	    }
	    *wld_z = ex_zpt[zid];

	status = TRUE;
fini:
return (status);
}
