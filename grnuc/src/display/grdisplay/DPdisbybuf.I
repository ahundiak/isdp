/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEgragad	graphic gadget
	METHOD NAME:	DPdisbybuf	display element(s) in buf

	Abstract:
-----
%SC%

	value = DPdisbybuf (msg,mode,buffer,no_elem)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE	     DESCRIPTION
       ------  		-----------    	     ----------------------------
       *mode		GRdpmode		The mode of the object
					     EX:
						GRbd    GRbe
						GRhd    GRhe
						GRbdhd  GRbehe
						GRbdhe  GRbehd

       *buffer        struct DPele_header  buffer containing graphic 
					     elements

       *no_elem		IGRlong		     number of object ids

-----
%EX%

	ON EXIT:

	NAME	DATA TYPE	DESCRIPTION
       ------  -----------    ----------------------------
	msg	IGRlong		return status
				  MSSUCC - successfully completed
				  MSFAIL - unsuccessfully completed
-----
%MD%

	MODULES AND METHODS INVOKED:

-----
%RL%

	RELATIONS REFERENCED:
-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	HT  05/19/86	: Design date.

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to display element(s) (graphic object)
	which has been formatted for display.  The method
	will push the clip information and matrix information
	on the stack so the strokers can access the information.  Then
	DPdiselem is called.
----*/
/*EH*/

   

class implementation IGEgragad;

extern IGRboolean dynamics_in_progress;

#include "grimport.h"
#include <stdlib.h>
#include "exdef.h"
#include "exmacros.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "wl.h"
#include "dpstruct.h"

/* prototype files */
%safe
#include "dpviewind.h"
#include "dpclpstack.h"
#include "dpmtxstack.h"
#include "dpdiselem.h"
%endsafe

method DPdisbybuf (IGRlong *msg; enum GRdpmode *mode;
		       struct DPele_header  *buffer; IGRlong *no_elem;
		       IGRint view_ind; IGRint view_ind_type;
		       IGRdouble *view_ind_point)
    {

	      
       IGRint 		sts, sts1, i;
       IGRint		quiet_flag;
       struct DPviewinfo	old_view_info;
       struct DP_information sp_info;

	*msg = MSSUCC;
	sts = OM_S_SUCCESS;

	if (ex$is_batch() || ige$SR_active())
	{
	   goto wrapup0;
	}

       if ((!(ME.IGEgragad->gragad.flags & IS_ACTIVE)) || 
	   (ME.IGEgragad->gragad.flags & DP_DELAY))
       {
            goto wrapup0;
       }

	ex$disp_flag(flag = &quiet_flag);

	if (quiet_flag)
	{
	   goto wrapup0;
	}

 	WLset_active_symbology( ME.IGEgadget->win_no, 0, DP_SOLID_LINE_STYLE, 0xffff,
                                0, WL_SYMB_CHANGE_STYLE );

   	WLset_blendarea( ME.IGEgadget->win_no, NULL, TRUE );

	sp_info.gragad = &ME.IGEgragad->gragad;
	sp_info.win_no = ME.IGEgadget->win_no;
	sp_info.is_update = FALSE;
	sp_info.is_fit = FALSE;	
	sp_info.is_hidden_line = FALSE;
	sp_info.hline_info = NULL;
	sp_info.hl_tiler = NULL;
	sp_info.view_objid = my_id;
	sp_info.view_osnum = OM_Gw_current_OS;

	if (!dynamics_in_progress)
	{
	   WLhide_cursor( ME.IGEgadget->win_no, TRUE );
	}

	if (view_ind)
	{
	   dp$set_view_ind(	type = view_ind_type,
				point = view_ind_point,
				dp_info = &sp_info,
				old = &old_view_info);
	}

	for (i=0; i < (*no_elem); i++,buffer++)
	{
	   if ( ! DPdiselem(&sts1,buffer,mode,&sp_info ) )
	   {
#ifdef DEBUG
	     printf("Error in Window's DPdiselem, Error: ");
#endif
	     *msg = MSFAIL;
	     goto wrapup;
	   }
	   else
	   {
		if (!(*msg & 1))
		{
		   goto wrapup;
		}
	   }

	}
wrapup:
	if (view_ind)
	{
	   dp$reset_view_ind(	dp_info = &sp_info,
				old = &old_view_info);
	}

	if (!dynamics_in_progress)
	{
	   WLshow_cursor( ME.IGEgadget->win_no );
	   WLflush( ME.IGEgadget->win_no );
	}

wrapup0:
	return(sts);


	}
end implementation IGEgragad;
