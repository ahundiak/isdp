/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   DPordphigs
 
     Abstract: This function takes our ordinary view parameters and returns
		our "phigs persp" representation.
		For standard defaults, it assumes an angle of 
		approx. 60 degrees is desired. (This should be changed to
		be and input value.) To produce this the eye point is 
		backed up enough to see everything in the view volume
		with that viewing angle.

-----
%SC%

     VALUE = DPordphigs (msg,in_flag,vw_vol,act_z,wld_to_view,vrp,vpn
			vup,eye_pt,coi,ang_dis,pnear,pfar,new_act_z)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	in_flag	   IGRint	 the #defines for this are in dpdef.h
				 the     "    are also used by dp$setpersp.
				 possible flags are 	DP_FIT_VOL
							DP_NOFIT_Z
							DP_NOFIT_X
							DP_NOFIT_Y
							DP_STD_DEFAULTS
							DP_STD_DEF_PSP
				For this routine, DP_STD_DEFAULTS AND 
				DP_STD_DEF_PSP work the same.  They
				both cause parameters to be calculated as if
				you are assuming the view will be perspective.
				If neither of theses flags is set a distance
				will be returned rather than an angle.
				For DP_FIT_VOL, the view volume will be fitted
				before calculations are made from the volume.
				To selectively not fit one of the axes
				(Note the axes determination is at the view
				 coordinate level)  you	need to as well as 
				the DP_FIT_VOL flag flag(s) for NOFIT.
				

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 MSSUCC -- successful completion

     VALUE (IGRint) = OM_S_SUCCESS  or  OM_E_ABORT
			
		      
-----
%MD%

     MODULES INVOKED:	MAinvmx()	
			MAdotvc();
			MAptsxform();
			MA2ptdis();
			MAatan2();

----- 
%NB%

     NOTES: 
-----
%CH%
     CHANGE HISTORY:
	
	MSP  88  : Creation date.
	MSP  05/19/89 
		fixed (in a Kludgy way) the active z prob.
		added special flags for fitting capability
			
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N

		This function takes our ordinary view parameters and returns
		our "phigs persp" representation.

----*/
/*EH*/


#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dperr.h"
#include "dpdef.h"
#include "godef.h"
#include "msdef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "OMDB.h"
#include "OMerrordef.h"

/* prototype files */
#include "DPordphigs.h"
#include "DPfitrng.h"

#include "madotvc.h"
#include "maatan2.h"
#include "mainvmx.h"
#include "masincos.h"
#include "maptsxfor.h"
#include "ma2ptdis.h"


IGRint DPordphigs(msg,in_flag,vw_vol,act_z,wld_to_view,vrp,
					vpn,vup,
					eye_pt,coi,ang_dis,pnear,pfar,new_act_z)
IGRlong *msg;
IGRint in_flag;
IGRdouble *vw_vol;
IGRdouble *act_z;
IGRdouble *wld_to_view;
IGRdouble *vrp;
IGRdouble *vpn;
IGRdouble *vup;
IGRdouble *eye_pt;
IGRdouble *coi;
IGRdouble *ang_dis;
IGRdouble *pnear;
IGRdouble *pfar;
IGRdouble *new_act_z;
{
IGRint status;
IGRshort four = 4;
IGRdouble view_to_wld[4][4];
IGRlong num_pts = 1;
IGRdouble temp_lr;
IGRdouble temp_sm;
IGRdouble delta;
IGRdouble fudge_fac;
IGRdouble vw_vec[3];
IGRdouble range[6];
IGRdouble ex_vol[6];
IGRdouble dot_prod;
IGRdouble angle;
IGRdouble sine;
IGRdouble cosine;
GRspacenum mod_os;
GRobjid mod_id;


	/****** NOTE status is set to OM_S_SUCCESS AT THE END *******/

	status = OM_E_ABORT;

    	if(!MAinvmx(msg, &four, wld_to_view, (IGRdouble *)view_to_wld))
    	{
    		goto fini;
    	}

	coi[0] = (vw_vol[3] + vw_vol[0]) / 2.0;
	coi[1] = (vw_vol[4] + vw_vol[1]) / 2.0;
	coi[2] = *act_z;

	eye_pt[0] = coi[0];
	eye_pt[1] = coi[1];

	if (!MAptsxform (msg, &num_pts, (IGRdouble *)view_to_wld, coi, coi))
	{
	    goto fini;
	}
	vrp[0] = coi[0];
	vrp[1] = coi[1];
	vrp[2] = coi[2];

	vpn[0] = - wld_to_view[8];
	vpn[1] = - wld_to_view[9];
 	vpn[2] = - wld_to_view[10];

        vup[0] = wld_to_view[4];
        vup[1] = wld_to_view[5];
        vup[2] = wld_to_view[6];

	if ((vw_vol[3] - vw_vol[0]) > (vw_vol[4] - vw_vol[1]))
	{
    	     temp_lr = (vw_vol[3] - vw_vol[0])/2.0;
    	     temp_sm = (vw_vol[4] - vw_vol[1])/2.0;
	}
	else
	{
    	     temp_lr = (vw_vol[4] - vw_vol[1])/2.0;
    	     temp_sm = (vw_vol[3] - vw_vol[0])/2.0;
	}
	if (in_flag & DP_FIT_VOL)
	{
	/* later I will need to add arguements to pass this in */
		ex$get_cur_mod(id=&mod_id,osnum=&mod_os);
		status = DPfit_range (msg,VIEW_COOR,mod_id,mod_os ,wld_to_view,range);
		/* If the rtree is empty then the x and y values will be same as
			their previous values */
		if((range[0] == 0) && (range[3] == 0))
		{
		   if ((range[1] == 0) && (range[4] == 0))
		   {
			if((range[2] == 0) && (range[5] == 0))
			{
			    status = DB_I_EMPTYTREE;
			}
		    }
		}
		if (status == DB_I_EMPTYTREE)
		{
			vw_vol[2] = *act_z - 1;
			vw_vol[5] = *act_z + 1;
			OM_BLOCK_MOVE(vw_vol,ex_vol,(sizeof(IGRdouble)*6));
		}
		else 
		{
		    if(((range[0] - range[3]) == 0) && ((range[1] - range[4]) == 0))
		    {
		    	range[3] = range[0] + 1;
		    	range[4] = range[1] + 1;
		    }
		    if((range[2] - range[5])==0)
		    {
			range[5] = range[2] +1;
		    }
		    OM_BLOCK_MOVE(range,ex_vol,(sizeof(IGRdouble)*6));
		}
		if(in_flag & DP_NOFIT_Z)
	    	{
			ex_vol[2] = vw_vol[2];
			ex_vol[5] = vw_vol[5];
	    	}
		if (in_flag & DP_NOFIT_X)
	    	{ 
			ex_vol[0] = vw_vol[0];
			ex_vol[3] = vw_vol[3];
	    	}
		if (in_flag & DP_NOFIT_Y)
	    	{
			ex_vol[1] = vw_vol[1];
			ex_vol[4] = vw_vol[4];
	    	}
	}
	else
	{
		OM_BLOCK_MOVE(vw_vol,ex_vol,(sizeof(IGRdouble)*6));
	}
	if ((in_flag & DP_STD_DEFAULTS) || (in_flag & DP_STD_DEF_PSP))
	{
	    angle = 0.5236;
	    MAsincos(msg,&angle,&sine,&cosine);
	    /* temp_sm is used rather than temp_lr since DPcalpersp will 
		enlarge the volume to be proportional to the window.
		If temp_lr were used the volume size would still be enlarged 
		to match the window by app. the same amount and a much larger 
		area than what is wanted would be viewed. */
	    delta = temp_sm/(sine/cosine);
	    eye_pt[2] = ex_vol[5] + delta;
	    if (!MAptsxform (msg, &num_pts, (IGRdouble *)view_to_wld, eye_pt,
				eye_pt))
	    {
	    	goto fini;
	    }
	    fudge_fac = delta / 100.0;	
	    *pnear = delta;
	    *pfar = ex_vol[5] - ex_vol[2] + delta;
 	    *ang_dis = MAatan2(msg,&temp_sm,pnear) * 2.0;

	    vw_vec[0] = coi[0] - eye_pt[0];	
	    vw_vec[1] = coi[1] - eye_pt[1];	
	    vw_vec[2] = coi[2] - eye_pt[2];	
	    if (!MAdotvc(msg,vw_vec,vpn,&dot_prod))
	    {
		goto fini;
	    }
	    if (dot_prod < 0 )
	    {
	    	vpn[0] = -vpn[0];
	    	vpn[1] = -vpn[1];
	    	vpn[2] = -vpn[2];
	    }
	    if (!MA2ptdis(msg,eye_pt,coi,new_act_z))
	    {
	    	goto fini;
	    }
	}
	else
	{
/* I may want to put this back to the previous way */
	    eye_pt[2] = ex_vol[5] + (0.01 * (ex_vol[5] - ex_vol[2]));
	    if (!MAptsxform (msg, &num_pts, (IGRdouble *)view_to_wld, eye_pt,
				eye_pt))
	    {
	    	goto fini;
	    }
	    *pnear = 0.01 * (ex_vol[5] - ex_vol[2]);
	    *pfar = ex_vol[5] - ex_vol[2];
	    *ang_dis = temp_sm;
	}

	status = OM_S_SUCCESS;
fini:
    return(status);
}
