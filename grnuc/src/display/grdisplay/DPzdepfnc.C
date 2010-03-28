
#include "grimport.h"
#include "igrtypedef.h"

/* prototype files */
#include "DPzdepfnc.h"

#include "madabs.h"
#include "mainvmx.h"
#include "maptsxfor.h"
#include "maunitvc.h"


#if defined(__STDC__) || defined(__cplsuplus)
IGRboolean DPset_zdep(	IGRlong    *msg,
			IGRint     in_flags,
			IGRdouble  *rotate,
			IGRdouble  *wld_to_view,
			IGRdouble  *keyedin_depths,
			IGRshort   num12,
			IGRdouble  *vw_zs )
#else
IGRboolean DPset_zdep(msg,in_flags,rotate,wld_to_view,keyedin_depths,num12,vw_zs)

IGRlong *msg;
IGRint in_flags;
IGRdouble *rotate;
IGRdouble *wld_to_view;
IGRdouble *keyedin_depths;
IGRshort  num12;
IGRdouble *vw_zs;
#endif

{

IGRdouble view_vec[3];
IGRdouble unit_vw_vec[3];
IGRlong num_pts;
IGRshort ic,kc;
IGRdouble zpts[6];
IGRdouble *p_vw_zs;
IGRboolean sts = 0;

/* can't I extract the view vec from the world to view 
	If world to view contains only the translation and rot but not 
	swapping z only problem may be that the z can't
*/

p_vw_zs = vw_zs;

view_vec[0] = rotate[8];
view_vec[1] = rotate[9];
view_vec[2] = rotate[10];

if (!MAunitvc(msg,view_vec,unit_vw_vec))
{
	goto fini;
}
for(ic = 0,kc=0;ic < num12 * 3;ic =ic + 3,kc++)
{
    zpts[ic] = unit_vw_vec[0] * keyedin_depths[kc];
    zpts[ic+1] = unit_vw_vec[1] * keyedin_depths[kc];
    zpts[ic+2] = unit_vw_vec[2] * keyedin_depths[kc];
}
num_pts = (IGRlong)num12;
if(!MAptsxform(msg, &num_pts, wld_to_view,zpts,zpts))
{
  	goto fini;
}
for(ic=0;ic < num12 * 3;ic = ic + 3)
{
	    *p_vw_zs++ = zpts[ic+2];	
}
sts = 1;
fini:

    return(sts);
}

/*  Converting to World Coordinates */

#if defined(__STDC__) || defined(__cplusplus)
IGRboolean DPgetvwz_in_wld(	IGRlong    *msg,
				IGRint     in_flags,
				IGRdouble  *rotate,
				IGRdouble  *wld_to_view,
				IGRdouble  *vw_zs,
				IGRshort   num12,
				IGRdouble  *wld_zs )
#else
IGRboolean DPgetvwz_in_wld(msg,in_flags,rotate,wld_to_view,vw_zs,num12,wld_zs)

IGRlong *msg;
IGRint in_flags;
IGRdouble *rotate;
IGRdouble *wld_to_view;
IGRdouble *vw_zs;
IGRshort num12;
IGRdouble *wld_zs;
#endif

{
/* same concern for view vec */
IGRshort ic;
IGRdouble view_vec[3];
IGRdouble unit_vw_vec[3];
IGRlong num_pts;
IGRdouble view_to_wld[4][4];
IGRshort four = 4;
IGRdouble zpts[6];
IGRdouble *p_vw_zs;
IGRdouble *p_wld_zs;
IGRdouble abs_vw_vec[3];
IGRshort zid;
IGRboolean sts = 0;

p_vw_zs = vw_zs;
p_wld_zs = wld_zs;

view_vec[0] = rotate[8];
view_vec[1] = rotate[9];
view_vec[2] = rotate[10];

MAunitvc(msg,view_vec,unit_vw_vec);

MAinvmx(msg, &four, wld_to_view, (IGRdouble *)view_to_wld);
for(ic = 0;ic < num12 * 3;ic = ic + 3)
{
       	zpts[ic] = wld_to_view[3];    
       	zpts[ic+1] = wld_to_view[7];
       	zpts[ic+2] = *p_vw_zs++;    
}
num_pts = (IGRlong)num12;
if (!MAptsxform(msg, &num_pts, (IGRdouble *)view_to_wld, zpts, zpts))
{
	goto fini;
}

/* insert */
for(ic=0;ic< num12 * 3;ic=ic+3)
{
     	if (unit_vw_vec[0] == 0)
      	{
	    zpts[ic] = 0;
       	}
       	else
       	{
	    zpts[ic] = zpts[ic] / unit_vw_vec[0];
       	}
       	if (unit_vw_vec[1] == 0)
       	{
	    zpts[ic+1] = 0;
       	}
       	else
       	{
  	    zpts[ic+1] = zpts[ic+1] / unit_vw_vec[1];
       	}
       	if (unit_vw_vec[2] == 0)
       	{
	    zpts[ic+2] = 0;
       	}
       	else
       	{
  	    zpts[ic+2] = zpts[ic+2] / unit_vw_vec[2];
       	}
       	abs_vw_vec[0] = MAdabs(msg,&zpts[ic]);
       	abs_vw_vec[1] = MAdabs(msg,&zpts[ic+1]);
       	abs_vw_vec[2] = MAdabs(msg,&zpts[ic+2]);
     	if (abs_vw_vec[0] > abs_vw_vec[1])
       	{
	    zid = 0;
       	}
       	else
       	{
	    zid = 1;
       	}
       	if (abs_vw_vec[2] > abs_vw_vec[zid])
       	{
	    zid = 2;
       	}
	*p_wld_zs++ = zpts[ic+zid];

} /* close for for */
sts = 1;
fini:
	return (sts);
}
/*      This section of code was used to keep 
	the z values the same for top and bottom (example:  If 10 were
	keyed in the value would be at a world value of +10 no matter
	which view (but the axes would vary according to the view ))


	        	temp_pt[0] = 1;
	        	temp_pt[1] = 1;
	        	temp_pt[2] = 1;
	        	MAdotvc(msg,view_vec,temp_pt,&dot_prod);
	        	if (dot_prod < 0 )
	        	{
			    view_vec[0] = - view_vec[0];
			    view_vec[1] = - view_vec[1];
			    view_vec[2] = - view_vec[2];
	        	}		
*/
