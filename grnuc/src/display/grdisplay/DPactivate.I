/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRwn
        METHOD NAME:    activate

        Abstract:
                This is the window activate method for the window object.
             it will reset CS_OS_number[hard_w_no] CS_window_id[hard_w_no]
             and use tools' routine to delete window.
-----
%SC%

        VALUE = activate( &msg )

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

        
-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

                                
-----
%RL%

        RELATIONS REFERENCED:


-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        HT   04/28/86  : Creation date.
	AET  07/30/88  : Add change process method 
	AET  08/01/88  : Added change to keep which screen it is on

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "grimport.h"
#include "exdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msmacros.h"
#include "grmessage.h"

#include "wl.h"
#include "dl.h"
#include "DPdlist.h"

/* prototype files */
%safe
/** #include "DPactivate.h" **/
PROTO_DPdlist_setup_feedback_gragad
%endsafe

#define DISABLE 0
#define ENABLE  1

from GRmodule import GRmdinfntptr;
from IGEwindow import DPinquire, display_name;

%safe
static int activate_update=TRUE;
%endsafe

void DPactivate_update(update)
IGRint update;
{
	activate_update=update;
}

method activate( IGRlong *msg; IGRint win_no;)

{

IGRlong status;
IGRboolean flag = FALSE;
IGRint win_min_x;
IGRint win_min_y;
IGRint win_max_x;
IGRint win_max_y;
IGRint win_extents[2];
IGRint mode;
IGRint num_of_screens;
IGRlong bytes_returned;
IGRint window_flags;
int    screen_no;
OM_S_CHANSELECT chandef;
GRobjid mod_id;
GRspacenum osnum;
IGRlong which_error;
struct win_var_list	var_list[3];
IGRchar full_name[DI_PATH_MAX];
IGRchar name[DI_PATH_MAX];

chandef.type = OM_e_name;
chandef.u_sel.name = "to_parent";

    status = OM_S_SUCCESS;

	if (ex$is_batch())
	{
	    goto wrapup;
	}

        DPdlist_setup_feedback_gragad();

	status = di$untranslate (objname = full_name,
			path = GRDP_REGVWS,
			objid = my_id,
			osnum = OM_Gw_current_OS);
    	if(!(1&status))
    	{
#ifdef DEBUG
	di$report_error(sts=status, comment = "untranslate failed \n");
#endif
        ex$message( msgnumb = GR_I_WrongName, buff = name );
   	}
	else
	{
		status = di$split(pathname=full_name,
			  name = name);
		if (!(status &1))
		{
#ifdef DEBUG
		printf("split failed in DPaddname\n");
#endif
		}
	}
	om$send( msg = message IGEwindow.display_name(name),
                 p_chanselect = &chandef );

        /* Calculate the dependent graphics gadget min & max */
    	ex$get_cur_mod ( id = &mod_id, osnum = &osnum);

        om$send( msg = message IGEgadget.dep_extents( msg, &win_min_x,
                 &win_min_y, &win_max_x, &win_max_y), 
                 p_chanselect = &chandef );

        if ( ! ( status & 1) )
        {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            *msg = MSFAIL;
            goto wrapup;
        }

        win_extents[0] = win_max_x - win_min_x;
        win_extents[1] = win_max_y - win_min_y;

        ME.IGEgadget->min_x_dep = win_extents[0] * ME.IGEgadget->min_x_indep;
        ME.IGEgadget->min_y_dep = win_extents[1] * ME.IGEgadget->min_y_indep;
        ME.IGEgadget->max_x_dep = win_extents[0] * ME.IGEgadget->max_x_indep;
        ME.IGEgadget->max_y_dep = win_extents[1] * ME.IGEgadget->max_y_indep;

        /*
         *    Calculate the extents of the gragad in dits
         */

        ME.IGEgadget->win_no = win_no;


	ME.IGEgragad->gragad.flags |= IS_ACTIVE;
	ME.IGEgragad->gragad.flags |= IS_WIN_ON;

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRmodule.GRmdinfntptr(msg, 
                         &ME.IGEgragad->gragad.fnt_os_ptr),
                         senderid = my_id,
			 targetos = osnum,
                         targetid = mod_id);
        if ( ! ( status & 1) )
        {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            *msg = MSFAIL;
            goto wrapup;
        }

	mode = (ME.IGEgragad->gragad.flags & IS_PERSP) ? DL_PERSP_PIPE : DL_ORTHO_PIPE;

	if ( DLcreate_drawing_pipeline( mode, win_no, &ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
	{
	   status = FALSE;
	   *msg = MSFAIL;
            goto wrapup;
	}

        DLset_curve_max_points( ME.IGEgragad->gragad.gpipe_id, 100 );

	ige$get_num_screens( num_of_screens = &num_of_screens);

	var_list[0].var = SCREEN_NO;
	var_list[0].var_ptr = (void *)&screen_no;
	var_list[0].num_bytes = sizeof(int);
	var_list[0].bytes_returned = &bytes_returned;

	var_list[1].var = WINDOW_FLAGS;
	var_list[1].var_ptr = (void *)&window_flags;
	var_list[1].num_bytes = sizeof(IGRint);
	var_list[1].bytes_returned = &bytes_returned;

	var_list[2].var = END_PARAM;

        status = om$send( msg = message IGEwindow.DPinquire( msg, &which_error,
              var_list),
              p_chanselect = &chandef );

        if ( ! ( status & 1) )
           {
#ifdef DEBUG
              om$report_error(sts = status);
#endif
              *msg = MSFAIL;
              goto wrapup;
           }


	if (num_of_screens == 1)
	{
	   ME.IGEgragad->gragad.flags  &= ~DPLEFT_SCREEN;
	}
	else
	{
	   if (screen_no == RIGHT_SCREEN)
	   {
	      ME.IGEgragad->gragad.flags  &= ~DPLEFT_SCREEN;
	   }
	   else
	   {
	      ME.IGEgragad->gragad.flags  |= DPLEFT_SCREEN;
	   }

	}
	
	/* took out an if (activate_update) put in by create window
	   command.  A DPcal is done with reference planes for all
	   2.0 files, but 1.4 files do not have this call and windows
	   using top, iso, front etc would have junk data JDU */	
	status = om$send( msg = message IGEgragad.DPcal (msg),
             targetid = my_id );
        if ( ! ( status & 1) )
        {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            *msg = MSFAIL;
            goto wrapup;
        }

	if (window_flags & WIN_IS_COLLAPSED)
	{
	   ME.IGEgragad->gragad.flags &= ~IS_ACTIVE;
	}

	if (activate_update)
	{
                status = om$send(mode = OM_e_wrt_object,
                         msg = message IGEgragad.DPupdate(msg,NULL,&flag),
                         senderid = my_id,
                         targetid = my_id);
        }
        
        if ( ! ( status & 1) )
        {
#ifdef DEBUG
            om$report_error(sts = status);
#endif
            *msg = MSFAIL;
        }
wrapup:
    return ( status );
}

#ifndef IDRAW
method change_process_from( IGRlong *msg; IGRint pid; IGRint time_out)

{

IGRlong status;
IGRint win_no;
IGRint mode;


	status = OM_S_SUCCESS;
	win_no = ME.IGEgadget->win_no;

	if (ME.IGEgragad->gragad.flags & IS_ACTIVE)
	{
    	   mode = (ME.IGEgragad->gragad.flags & IS_PERSP) ? DL_PERSP_PIPE : DL_ORTHO_PIPE;
	   if ( DLcreate_drawing_pipeline( mode, win_no, &ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
	   {
	      status = FALSE;
	      *msg = MSFAIL;
               goto wrapup;
	   }


           DLset_curve_max_points( ME.IGEgragad->gragad.gpipe_id, 100 );


           status = om$send( msg = message IGEgragad.DPcal (msg),
              		targetid = my_id );
           if ( ! ( status & 1) )
           {
#ifdef DEBUG
              om$report_error(sts = status);
#endif
              *msg = MSFAIL;
              goto wrapup;
           }
	}

wrapup:
    return ( status );
}

method change_process_to( IGRlong *msg; IGRint pid; IGRint time_out)

{

	if (ME.IGEgragad->gragad.flags & IS_ACTIVE)
	{
	   DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id );
	}

    return ( OM_S_SUCCESS );
}

#endif
end implementation IGEgragad;
