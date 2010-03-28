/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEgragad	graphic gadget
	METHOD NAME:	DPdisbyoid	display element(s) by object id

	Abstract:
-----
%SC%

	value = DPdisbyoid (msg,mode,buffer,no_oids,type,matrix)

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

       *buffer		struct GRid	        buffer containing graphic 
						object ids and corresponding
						object space numbers

       *no_oids		IGRlong			number of object ids


       *type		IGRshort		type of the matrix

       *matrix[]		IGRmatrix		matrix associated with
						object id

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

	OM_send foreign 	to GRdisplay

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	AET  01/09/86	: Design date.
	AET  07/30/88	: Added alternate symbology

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to display element(s) (graphic object)
	which has not been formatted for display.  The method
	will push the clip information and matrix information
	on the stack so the strokers can access the information.  Then
	the message is sent to the graphic object to display itself.
----*/
/*EH*/

   

class implementation IGEgragad;

#include "grimport.h"
#include <stdlib.h>
#include "referr.h"
#include "exdef.h"
#include "exmacros.h"
#include "igewinmacros.h"
#include "OMindex.h"
#include "wl.h"

struct DPdismsg
{
	IGRlong *msg;
	IGRshort *mx_type;
	IGRdouble *matrix;
	enum GRdpmode *mode;
	struct IGRaltdisplay *alt_symb;
	struct DP_information *dp_info;
	OM_p_KEY_DESC range_key;
};

/* prototype files */
%safe
#include "GRdisthruref.h"
#include "GRcheckref.h"

#include "dpclpstack.h"
#include "dpmtxstack.h"
#include "dpdiselem.h"
%endsafe

from GRgraphics import GRdisyourself; 
from IGEwinsup import pre_single_display, post_single_display;

extern IGRboolean	dynamics_in_progress;

 method DPdisbyoid (IGRlong *msg; enum GRdpmode *mode;
		       struct GRid *buffer; IGRlong *no_oids;
		       IGRshort *type; IGRmatrix *matrix[];
		       struct IGRaltdisplay *alt_symb)



  {

	      
       IGRint sts, i;
       struct GRid	gragad_id, graphic_id;
       struct DP_information sp_info;
       struct DPdismsg	dismsg;
       OM_S_CHANSELECT  chandef;
       OM_S_MESSAGE	display_msg;
       OMuint		count;
       IGRint		quiet_flag;

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


	sts = om$make_chanselect (channame = "IGEgragad.winsup", 
			    p_chanselect = &chandef);
			
        if (!(sts & 1))
        {
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }
			
       sts = om$get_channel_count(objid = my_id, 
                                 p_chanselect = &chandef, 
                                 count = &count);

	
        if (!(sts & 1))
        {
#ifdef DEBUG            
	   om$report_error(sts = sts);
#endif
           goto wrapup;
        }

	gragad_id.objid = my_id;
	gragad_id.osnum = OM_Gw_current_OS;

	/* set solid blend pattern */
   	WLset_blendarea( ME.IGEgadget->win_no, NULL, TRUE );

        sts = WLset_active_symbology( ME.IGEgadget->win_no, 0, DP_SOLID_LINE_STYLE,
                                      0xffff, 0, WL_SYMB_CHANGE_STYLE );
        
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
	   WLhide_cursor( ME.IGEgadget->win_no, FALSE );
	}
	
	for (i=0; i < (*no_oids); i++,buffer++,type++,matrix++)
	{
		
	   if (count)
	   {
		
	      graphic_id = *buffer;

	      sts = om$send(msg = message IGEwinsup.pre_single_display(msg, 
								&gragad_id, 
								&graphic_id), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
              /* protect against unknown objects */
              if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

	      if (!(sts & 1))
	      {
#ifdef DEBUG
	        printf("Error in Window's DPdisbyoid, Error: ");
	        om$report_error(sts = sts);
#endif
	        *msg = MSFAIL;
	        goto wrapup;
	      }
				
	   }

	   sts = GRcheckref(msg, type, *matrix[0], &OM_Gw_current_OS,
			&buffer->osnum);
	   
	   if ((*msg != GRNOTREFFILE) && ( 1 & *msg & sts))
	   {

 		dismsg.msg = msg;
		dismsg.mx_type = type;
		dismsg.matrix = (IGRdouble *) *matrix;
		dismsg.mode = mode;
		dismsg.alt_symb = alt_symb;
		dismsg.dp_info = &sp_info;
		dismsg.range_key = NULL;

		om$make_message( classname = "GRgraphics",
				 methodname = "GRdisyourself",
				 size = sizeof (struct DPdismsg),
				 p_arglist = &dismsg,
				 p_msg = &display_msg);



		sts = GRdisthruref(msg,&display_msg,buffer);

	   }
	   else
	   {
	        sts = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdisyourself(msg,type,
			  (IGRdouble *) *matrix,mode,alt_symb,&sp_info, 0),
                        senderid = my_id,
                        targetid = buffer->objid,
                        targetos = buffer->osnum);
	  }

	   if (!(sts & 1))
	   {
#ifdef DEBUG
	     printf("Error in Window's DPdisbyoid, Error: ");
	     om$report_error(sts = sts);
#endif
	     *msg = MSFAIL;
	     goto wrapup;
	   }
	   else
	   {
		if (!( *msg & 1))
		{
		   goto wrapup;
		}
	   }
	
	   if (count)
	   {
		

	      sts = om$send(msg = message IGEwinsup.post_single_display(msg, 
								&gragad_id, 
								&graphic_id), 
			    senderid = my_id, 
			    p_chanselect = &chandef);
	    
              /* protect against unknown objects */
              if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

	      if (!(sts & 1))
	      {
#ifdef DEBUG
	        printf("Error in Window's DPdisbyoid, Error: ");
	        om$report_error(sts = sts);
#endif
	        *msg = MSFAIL;
	        goto wrapup;
	      }
				
	   }
	
	}

wrapup:
	
	if (!dynamics_in_progress)
	{
	   WLshow_cursor( ME.IGEgadget->win_no );
	   WLflush( ME.IGEgadget->win_no );
	}

wrapup0:

	return(sts);


}
end implementation IGEgragad;
