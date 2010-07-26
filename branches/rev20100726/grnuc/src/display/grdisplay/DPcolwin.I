/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPcollect_win
 
     	Abstract: This method will collect the windows if the 
		  hl_flag is FALSE.
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     *num_windows IGRlong	  the number of windows collected 
				  so far

     *win_ids	  struct GRid	  the ids of the windows collected
				  so far

     *hl_flag     IGRboolean	  if FALSE, we need to add this
				  window to the list.  If it is
				  true, we don't do anything
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     *num_windows IGRlong	  the number of windows collected 
				  so far

     *win_ids	  struct GRid	  the ids of the windows collected
				  so far

     msg           IGRlong	 MSSUCC -- successful completion

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	AET 07/09/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------


	   This method will check the hl_flag to see if it is FALSE.
	If it is FALSE, we will increment the num_windows and add
	our id to the list.

----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"

method DPcollect_win (IGRlong *msg; IGRint *num_windows;
		      IGRint max_ids; struct GRid *win_ids; 
		      IGRint flag)

{

IGRlong status = OM_S_SUCCESS;
IGRboolean set_flag = FALSE;

    if (ALL_TYPES & flag)
    {
    	set_flag = TRUE;	
    }
    else
    {
	if (IGE_GG & flag)
	{
	    set_flag = TRUE;
	    /* if neither ACTIVE_GG nor INACTIVE_GG is set than it is 
		assumed that you want the id */
	    if ((flag & ACTIVE_GG) || (flag & INACTIVE_GG))
	    {
	    	if (ME.IGEgragad->gragad.flags & IS_ACTIVE)
	    	{
		    /* the ! active is used rather than and inactive
			so that if both flags are set the set_flag will
			remain true					*/
		    if (!(flag & ACTIVE_GG))
		    {
		    	set_flag = FALSE;
		    }
	    	}
	    	else
	    	{
		    if (!(flag & INACTIVE_GG))
		    {
		    	set_flag = FALSE;
		    }
	        }
	    }
	    
	    if((flag & GG_WIN_ON) || (flag & GG_WIN_OFF))
	    {
	    	if (ME.IGEgragad->gragad.flags & IS_WIN_ON)	
	    	{
		    if(!(flag & GG_WIN_ON))
		    {
		    	set_flag = FALSE;
		    }
		}
		else
		{
		    if (!(flag & GG_WIN_OFF))
		    {
		    	set_flag = FALSE;
		    }
	    	}
	    }
	    if ((flag & DELAY_GG) || (flag & NO_DELAY_GG))
	    {
	    	if (ME.IGEgragad->gragad.flags & DP_DELAY)
	    	{
		    if (!(flag & DELAY_GG))
		    {
		    	set_flag = FALSE;
		    }
	    	}
	    	else
	    	{
		    if (!(flag & NO_DELAY_GG))
		    {
		    	set_flag = FALSE;
		    }
	        }
	    }

	}  /* close for if IGE_GG */
    } /* close for else */

	if(set_flag)
	{
	    if (*num_windows < max_ids )
	    {
	   	win_ids[*num_windows].osnum = OM_Gw_current_OS;
	   	win_ids[*num_windows].objid = my_id;	
		(*num_windows)++;	
	    }
	    if (*num_windows >= max_ids )
	    {
		status = OM_I_STOP_SENDING;		
	    }
	}

	*msg = MSSUCC;

	return (status);

}
end implementation IGEgragad;
