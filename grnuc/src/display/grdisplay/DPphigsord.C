/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   DPphigsord
 
     Abstract: 	This function takes our "phigs persp" parameters and returns
		our ordinary view representation.
-----
%SC%

     VALUE = DPphigsord (msg,in_flag,vrp,vpn,vup,eye_pt,coi,ang_dis,pnear,pfar,
			vw_vol,act_z,rotate,origin)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 MSSUCC -- successful completion

     VALUE (IGRint) = OM_S_SUCCESS or OM_E_ABORT
			
		      
-----
%MD%

     MODULES INVOKED:	MAdotvc();
			MAptsxform();
			MAsincos();
			DPalignper();
----- 
%NB%

     NOTES: 
-----
%CH%
     CHANGE HISTORY:
	
	MSP  88  : Creation date.
	MSP  05/19/89 
		fixed (in a Kludgy way) the active z prob.
		No longer produces zoom out effect
			
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N

		This function takes our "phigs persp" parameters and returns
		our ordinary view representation.

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
#include "OMerrordef.h"

/* prototype files */
#include "DPphigsord.h"
#include "dpalignper.h"

#include "madotvc.h"
#include "masincos.h"
#include "maptsxfor.h"


#define FROM_PERSP 1

IGRint DPphigsord (msg,in_flag,vrp,vpn,vup,eye_pt,coi,ang_dis,pnear,pfar,
vw_vol,act_z,rotate,origin)

IGRlong *msg;
IGRint in_flag;
IGRdouble *vrp;
IGRdouble *vpn;
IGRdouble *vup;
IGRdouble *eye_pt;
IGRdouble *coi;
IGRdouble *ang_dis;
IGRdouble *pnear;
IGRdouble *pfar;
IGRdouble *vw_vol;
IGRdouble *act_z;
IGRdouble *rotate;
IGRdouble *origin;

{
IGRlong status;
IGRdouble temp_mx[4][4];
IGRlong num_pts = 1;
IGRdouble sine;
IGRdouble m_cos;
IGRdouble angle;
IGRdouble vw_vec[3];
IGRdouble new_coi[3];
IGRdouble dot_prod;
IGRdouble save_pnear;
IGRdouble save_pfar;


	/*  REASSIGNED TO SUCCESS AT THE END */

	status = OM_E_ABORT;

    save_pnear = *pnear;
    save_pfar = *pfar;
    origin[0] = eye_pt[0];
    origin[1] = eye_pt[1];
    origin[2] = eye_pt[2];
    /* be sure that the view vector and the vpn are going in approximately 
	the same direction */
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
    DPalignper(msg, 0, vpn, vup, eye_pt, rotate, (IGRdouble *)temp_mx);

	if (!MAptsxform (msg, &num_pts, (IGRdouble *)temp_mx, coi, new_coi))
	{
	    goto fini;
	}
	*act_z = new_coi[2];	

	if (in_flag & FROM_PERSP)
	{
	    angle = *ang_dis / 2.0;
 	    MAsincos(msg,&angle,&sine,&m_cos);
            /* Active z is the correct place to interpolate x and y */
            *ang_dis = (sine/m_cos) * *act_z;
	}
	    vw_vol[0] = - *ang_dis;
	    vw_vol[1] = - *ang_dis;
	    vw_vol[2] = - save_pfar;
	    vw_vol[3] = *ang_dis;
	    vw_vol[4] = *ang_dis;
	    vw_vol[5] = - save_pnear;

	status = OM_S_SUCCESS;
fini:
    return(status);
}
