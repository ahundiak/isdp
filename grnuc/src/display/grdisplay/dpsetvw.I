/*----
GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEgragad
        METHOD NAME:  ( if file contains the function DPset_view_rot)

        Abstract: returns the rotation matrix necessary for the specified
		  rotation.  However, first the saved views are searched for
		  an exact match on the name, and if found the saved view's
		  rotation is used.  If an active coordinate system
		  is exists, and the prefix acs is used with a standard set
		  name. Example, acstop, acsiso.

-----
%SC%

        VALUE = IGRint	DPset_view_rot  (msg,osnum,p_rotation,vw_name)
		returns OM codes
-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	osnum	   GRspacenum 
	vw_name	   IGRchar *	view type you wish

-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	msg	   IGRlong *
     p_rotation	   IGRdouble *	the rotation matrix 4x4 last column 0,0,0,1

-----
%RL%

        RELATIONS REFERENCED:

-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

       MSP    09/23/89  : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

above

----*/
/*EH*/



class implementation IGEgragad;

#include <string.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "dperr.h"
#include "dpmacros.h"
#include "grmessage.h"
#include "msdef.h"
#include "msmacros.h"
#include "csmacros.h"

/* prototype files */
%safe
#include "dpsetvw.h"
#include "DPsvinquire.h"
#include "GRcsfunc.h"

#include "maidmx.h"
#include "mamulmx.h"
#include "matrnmx.h"
#include "exproto.h"
%endsafe

#define NOSPACE 1
#define ONESPACE 0
#define LOWERCASE  1
#define SAMECASE 0
#define TOP_VW 0
#define FRONT_VW 1
#define LEFT_VW 2
#define RIGHT_VW 3
#define BOTTOM_VW 4
#define REAR_VW   5
#define BACK_VW 6
#define ISO_VW 7

from GRgencs import GRgetmatrix;

#if defined(__STDC__) || defined(__cplusplus)
IGRint	DPset_view_rot( IGRlong     *msg,
                        GRspacenum  osnum,
                        IGRdouble   *p_rotation,
                        IGRchar     *vw_name )
#else
IGRint	DPset_view_rot  (msg,osnum,p_rotation,vw_name)

IGRlong *msg;
GRspacenum osnum;
IGRdouble *p_rotation;
IGRchar *vw_name;
#endif

{
    IGRdouble rotation[4][4];
    IGRdouble extra_mtx[4][4];
    IGRdouble acs_mtx[4][4];
    IGRshort n = 4;
    IGRshort vwname_fd =-1;
    IGRshort i=0;
    IGRint msgnb[8];
    IGRint acs_len;
    IGRlong status;
    struct var_list var_list[2];
    IGRlong which_error;
    IGRlong return_bytes;
    IGRchar shortnm[256];
    IGRchar cp_vwnm[256];
    IGRchar temp[30];
    IGRchar msgbuffer[256];
    IGRshort acs_flag;
    GRobjid acs_id;


    status = OM_S_SUCCESS;
    *msg = OM_S_SUCCESS;
		    
/* How can I make this case insensitive or should I ? can directory 
	structure do this or do I need to check to see if 
	first do a search on it as is then
	if fail
	if name = top 
	 search on TOP
*/

if (osnum != 0)
{
	var_list[0].var = VW_ROT_NO_CON;
	var_list[0].var_ptr = (char *)rotation;
	var_list[0].num_bytes = sizeof(IGRdouble) *16;
	var_list[0].bytes_returned = &return_bytes;
	var_list[1].var = END_PARAM;

	status = dp$inq_set_saved_view ( msg = msg,
			   osnum=osnum,
			   vw_name=vw_name,
			   which_error = &which_error,
			   var_list = var_list);
}
else
{
	status = OM_E_ABORT;
}
	if ( !(status & 1))
	{
	    status = OM_S_SUCCESS;

	    MAidmx (msg, (IGRdouble *)rotation);

	   acs_flag=0;

	   strcpy(cp_vwnm,vw_name);

	   EX_clean_str(cp_vwnm,NOSPACE,LOWERCASE);
	   ex$message(msgnumb = GR_I_ACS,buff= msgbuffer);
	   EX_clean_str(msgbuffer,NOSPACE,LOWERCASE);
	   acs_len=strlen (msgbuffer);
	   strncpy (shortnm,cp_vwnm,acs_len);
           shortnm[acs_len]='\0';
	   if ((strcmp(shortnm,msgbuffer) == 0))
	   {
		acs_flag = 1;
		strcpy(temp,&cp_vwnm[acs_len]);
		strcpy(cp_vwnm,temp);
	    }

	    msgnb[0] = GR_I_Top;
	    msgnb[1] = GR_I_Front;
	    msgnb[2] = GR_I_Left;
	    msgnb[3] = GR_I_Right;
	    msgnb[4] = GR_I_Bottom;
	    msgnb[5] = GR_I_Back;
	    msgnb[6] = GR_I_True_Back;
	    msgnb[7] = GR_I_Iso;

	   /* var initialized at declaration time */
	   while (vwname_fd == -1 && i < 8)
	   {
	   	ex$message(msgnumb = msgnb[i],buff= msgbuffer);
	   	EX_clean_str(msgbuffer,NOSPACE,LOWERCASE); 
		if ((strcmp(cp_vwnm,msgbuffer) == 0))
		{
		    vwname_fd = i;
		}
		i++;
	   }
	   switch (vwname_fd)
	   {
		case TOP_VW:
               	     ; /* TOP is the identity matrix which is already in rotation */
		break;

		case FRONT_VW:

			/* rotate -90 degrees about the x axis */

		    	rotation[1][1] = 0;
		    	rotation[1][2] = 1.0;	
		    	rotation[2][1] = -1.0;	
		    	rotation[2][2] = 0;		
		break;

		case LEFT_VW:

			/* rotate -90 degrees about the x axis */
			/* rotate 90 degrees about the y axis */

		    	rotation[0][0] = 0;
 		    	rotation[0][1] = -1.0;
		    	rotation[1][1] = 0;
		    	rotation[1][2] = 1.0;	
		    	rotation[2][0] = -1.0;
		    	rotation[2][2] = 0;		

		break;

		case RIGHT_VW:

			/* rotate -90 degrees about the x axis */
			/* rotate -90 degrees about the y axis */

		    	rotation[0][0] = 0;
		    	rotation[0][1] = 1.0;
		    	rotation[1][1] = 0;
		    	rotation[1][2] = 1.0;	
		    	rotation[2][0] = 1.0;
		    	rotation[2][2] = 0;		

		break;

		case BOTTOM_VW:

			/* rotate -180 degrees about the x axis */
		    	rotation[1][1] = -1.0;
		    	rotation[2][2] = -1.0;
		break;

		case BACK_VW:
		case REAR_VW:

			/* rotate -90 degrees about the x axis */
			/* rotate -180 about the y axis */

		    	rotation[0][0] = -1.0;
		    	rotation[1][1] = 0;
		    	rotation[1][2] = 1.0;	
		    	rotation[2][1] = 1.0;		
		    	rotation[2][2] = 0;		

		break;

		case ISO_VW:					

			rotation[0][0]=  0.707106781186548;
			rotation[0][1]=  0.707106781186548;
			rotation[1][0]= -0.408248290463863;
			rotation[1][1]=  0.408248290463863;
			rotation[1][2]=  0.816496580927726;
			rotation[2][0]=  0.577350269189626;
			rotation[2][1]= -0.577350269189626;
			rotation[2][2]=  0.577350269189626;
		break;

	    default:
                    *msg = DPINVINP;
		   status = OM_E_ABORT;
	    break;

	    } /* close for switch */

	    if (acs_flag)
	    {
		
		status = cs$get_active_info(msg =msg,osnum= osnum,objid= &acs_id);
		if (!(status & 1))
		{
		    goto quit;
		}
          	status = om$send(mode = OM_e_wrt_object,
                               msg = message GRgencs.GRgetmatrix ( msg,
					(IGRdouble *)acs_mtx),
                               senderid = NULL_OBJID,
                               targetid = acs_id,
                               targetos = osnum);
		if (!(status & 1))
		{
		    goto quit;
		}
		acs_mtx[0][3] = 0;
		acs_mtx[1][3] = 0;
		acs_mtx[2][3] = 0;
		if(! MAtrnmx(msg, &n, (IGRdouble *)acs_mtx, (IGRdouble *)acs_mtx))
		{
			status = OM_E_ABORT;
			    goto quit;
		}
		if (! MAmulmx(msg, &n, &n, &n, (IGRdouble *)rotation,
				(IGRdouble *)acs_mtx, (IGRdouble *)extra_mtx))
		{
			status = OM_E_ABORT;
			goto quit;
		}
		OM_BLOCK_MOVE(extra_mtx,rotation,sizeof(IGRdouble) *16);
	    } /* close for acs_flag */
	} /* close for if saved view not found */

	if ( status == OM_S_SUCCESS )
	{
		OM_BLOCK_MOVE(rotation,p_rotation,sizeof(IGRdouble) *16);
	}
quit:
	return(status);
}	/* end of get_type_view    */

end implementation IGEgragad;
