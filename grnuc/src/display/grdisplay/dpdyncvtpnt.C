/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  GRwn

     METHOD NAME  GRdyn_conv_pnt
 
     Abstract:	This method converts a data point from screen dit to
		world coordinate system.
-----
%SC%

	GRdyn_conv_pnt (msg,pnt,dit_pnt,uor_pnt)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*pnt	  IGRdouble	point to be converted to the WCS.
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

	*dit_pnt  IGRint	actual dit point

	*uor_pnt  IGRdouble	actual uor point
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        mrm  10/02/91    Took out the $*!# beep and sleep



-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"

/* prototype files */
#include "dpdyncvtpnt.h"
#include "dpcvrtpnt.h"

#include "maptsxfor.h"


static IGRint message_disp = FALSE;

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPdyn_conv_pnt (	IGRlong			*msg,
			struct DPgra_gad 	*wn,
			IGRdouble 		*point,
			IGRint			*dit_pnt,
			struct EX_button	*uor_pnt,
			GRspacenum		osnum )
#else
IGRint DPdyn_conv_pnt (msg, wn, point, dit_pnt, uor_pnt, osnum)

IGRlong			*msg;
struct DPgra_gad 	*wn;
IGRdouble 		*point;
IGRint			*dit_pnt;
struct EX_button	*uor_pnt;
GRspacenum		osnum;
#endif 

{
    IGRlong 	num_points;
    IGRboolean  valid_point = TRUE;
    IGRlong	status;

    status = OM_E_ABORT;

    point[2] = wn->act_z_screen;

    status = DPconv_pnt(msg,wn,point,dit_pnt,&valid_point,osnum);

    if (!status)
    {
        goto finish;
    }

    if (valid_point)
    {
        uor_pnt->x = point[0];
        uor_pnt->y = point[1];
        uor_pnt->z = point[2];

        if (message_disp)
        {
            ex$message (msgnumb = EX_S_Clear);
            message_disp = FALSE;
        }	   
    }
    else
    {
        if (!message_disp)
        {
#ifdef BEEP
            EX_bell();
#endif
            ex$message (msgnumb = GR_E_PtOutVwVol);
            message_disp = TRUE;
        }
    }

    if ((wn->flags & VALID_ALT_INV) && valid_point)
    {
        num_points = 1;
        status = MAptsxform (msg, &num_points, (IGRdouble *)wn->wld_to_viewport, 
                             point, point);

        dit_pnt[0] = dpround(point[0]);
        dit_pnt[1] = dpround(point[1]);
    }

    if (valid_point)
    {
        status = TRUE;
    }
    else
    {
        status = FALSE;
    }	
finish:
    return (status);
}

IGRint DPis_message_disp()
{
    return(message_disp);
}

IGRint DPset_message_disp(mes_disp)
IGRint mes_disp;
{
    message_disp = mes_disp;
    return(1);
}
