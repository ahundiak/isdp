
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

/*#include "hsurf_import.h"*/
#include "stdlib.h"

#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igetypedef.h"

#include "OMminimum.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"

method DPcollect_win(	IGRlong		*msg;
			IGRint		*num_windows;
			IGRint		max_ids;
			struct GRid	*win_ids; 
			IGRint		flag )

	{
	IGRlong		status;
	IGRboolean	set_flag;

	status = OM_S_SUCCESS;
	set_flag = FALSE;
	
	if( ALL_TYPES & flag )
		{
		set_flag = TRUE;	
		}
	else
		{
		if( HIDDENLN_GG & flag )
			{
			set_flag = TRUE;
			
			/*
			 *  if neither ACTIVE_GG nor INACTIVE_GG is set than it is 
			 *  assumed that you want the id
			 */
			 
			if( (flag & ACTIVE_GG) || (flag & INACTIVE_GG) )
				{
				if( ME.IGEgragad->gragad.flags & IS_ACTIVE )
					{
						
					/*
					 *  the ! active is used rather than and inactive
					 *  so that if both flags are set the set_flag will
					 *  remain true
					 */
					 
					if( !(flag & ACTIVE_GG) )
						{
						set_flag = FALSE;
						}
					}
				else
					{
					if( !(flag & INACTIVE_GG) )
						{
						set_flag = FALSE;
						}
					}
				}

			if( (flag & GG_WIN_ON) || (flag & GG_WIN_OFF) )
				{
				if( ME.IGEgragad->gragad.flags & IS_WIN_ON )	
					{
					if( !(flag & GG_WIN_ON) )
						{
						set_flag = FALSE;
						}
					}
				else
					{
					if( !(flag & GG_WIN_OFF) )
						{
						set_flag = FALSE;
						}
					}
				}
				
			if( (flag & DELAY_GG) || (flag & NO_DELAY_GG) )
				{
				if( ME.IGEgragad->gragad.flags & DP_DELAY )
					{
					if( !(flag & DELAY_GG) )
						{
						set_flag = FALSE;
						}
					}
				else
					{
					if( !(flag & NO_DELAY_GG) )
						{
						set_flag = FALSE;
						}
					}
				}
			}  /* close for if HIDDENLN_GG */
		} /* close for else */

	if( set_flag )
		{
		if( *num_windows < max_ids )
			{
			win_ids[*num_windows].osnum = OM_Gw_current_OS;
			win_ids[*num_windows].objid = my_id;	
			(*num_windows)++;	
			}
			
		if( *num_windows >= max_ids )
			{
			status = OM_I_STOP_SENDING;
			}
		}

	*msg = MSSUCC;

	return (status);
	}
	
end implementation HSgragad;
