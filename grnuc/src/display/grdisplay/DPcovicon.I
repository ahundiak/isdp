/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEgragad
	METHOD NAME:	covicon

	Abstract:
		This method will handle window uncovered condition
-----
%SC%

	VALUE = covicon (*msg ; *range)

-----
%EN%

	ON ENTRY:
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
	
-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong         return condition code
				
-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	HT   04/29/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This method will send update message to window that is uncovered.
----*/
/*EH*/


class implementation IGEgragad;


#include "grimport.h"
#include "igewindow.h"

#if ( defined( SUNOS ) || defined( SUNOS5 ) ) && defined( X11 )
#include "igewindef.h"
#include "igewinmacros.h"
#endif

method covicon( IGRlong *msg; struct IGEdit_range *range)
{	
    IGRlong status = OM_S_SUCCESS;
    IGRboolean flag = FALSE;
    struct IGEdit_range new_range;
#if ( defined( SUNOS ) || defined( SUNOS5 ) ) && defined( X11 )
    IGRint var_list[2];
    struct win_var_list win_list[2];
    IGRlong ret_msg, error_val, ret_bytes;
#endif

    *msg = MSSUCC;

#if ( defined( SUNOS ) || defined( SUNOS5 ) ) && defined( X11 )
    /* olwm hack -> only get this if window uncollapsed */
    ME.IGEgragad->gragad.flags |= IS_ACTIVE;

    /* set flags to reflect changed values: 0x00000010 = WIN_IS_NOTMAPPED */
    var_list[0] = WIN_IS_ACTIVE | 0x00000010;
    var_list[1] = WIN_IS_ACTIVE | 0x00000010;

    /* set up the window parameters to change */
    win_list[0].var = WINDOW_FLAGS;
    win_list[0].var_ptr = (char *)var_list;
    win_list[0].num_bytes = 2 * sizeof(int);
    win_list[0].bytes_returned = &ret_bytes;
    win_list[1].var = END_PARAM;

    ige$inq_set_window(	msg = &ret_msg,
			inq0_set1 = 1,
			osnum = OM_Gw_current_OS,
			window_objid = sender_id,
			which_error = &error_val,
			var_list = win_list);
#endif

    if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
    {

/* get intersection of area to be updated   */

	if ((range->xlo > ME.IGEgadget->max_x_dep) ||
	    (range->ylo > ME.IGEgadget->max_y_dep) ||
	    (range->xhi < ME.IGEgadget->min_x_dep) ||
	    (range->yhi < ME.IGEgadget->min_y_dep))
	{
	   goto wrapup;
	}
	else
	{

/* find x low */

	   if (range->xlo > ME.IGEgadget->min_x_dep)
	   {
	      new_range.xlo = range->xlo;
	   }
	   else
	   {
	      new_range.xlo = ME.IGEgadget->min_x_dep;
	   }

/* find y low  */

	   if (range->ylo > ME.IGEgadget->min_y_dep)
	   {
	      new_range.ylo = range->ylo;
	   }
	   else
	   {
	      new_range.ylo = ME.IGEgadget->min_y_dep;
	   }

/* find x hi */

	   if (range->xhi < ME.IGEgadget->max_x_dep)
	   {
	      new_range.xhi = range->xhi;
	   }
	   else
	   {
	      new_range.xhi = ME.IGEgadget->max_x_dep;
	   }

/* find y hi */

	   if (range->yhi < ME.IGEgadget->max_y_dep)
	   {
	      new_range.yhi = range->yhi;
	   }
	   else
	   {
	      new_range.yhi = ME.IGEgadget->max_y_dep;
	   }
	}

        status = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgragad.DPupdate(msg,(struct DPdit_range *)&new_range,&flag),
                     senderid = my_id,
                     targetid = my_id);
        if ( ! ( 1 & status ) )
        {
#ifdef DEBUG
	   printf ( "IGEgragad.covicon> error sending to IGEgragad update.\n" );
	   om$report_error(sts = status );
#endif
	   *msg = MSFAIL;
        }
    }


wrapup:
    return ( status );
}

end implementation IGEgragad;
