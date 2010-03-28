
class implementation IGEgragad;

#include "grimport.h"
#include "wl.h"

#include "exmacros.h"
#include "igewinmacros.h"

extern IGRboolean dynamics_in_progress;

method DPerase_hilite(IGRlong *msg)

	{

	*msg = MSSUCC;

	if (ex$is_batch() || ige$SR_active())
	{
	   goto wrapup0;
	}


	if ((!(ME.IGEgragad->gragad.flags & IS_ACTIVE)) ||
	    (ME.IGEgragad->gragad.flags & DP_DELAY))
	{
	    goto wrapup0;
	}


	/* set the blend pattern to solid */
	WLset_blendarea( ME.IGEgadget->win_no, NULL, TRUE );

	if (!dynamics_in_progress)
	{
	   WLhide_cursor( ME.IGEgadget->win_no, TRUE );
	}

	if ( WLclear_hilite( ME.IGEgadget->win_no ) != WL_SUCCESS )
	{
#if DEBUG
	   printf("\nError in dperase window\n");
#endif
	   *msg = MSFAIL;
	   goto wrapup;
	}

wrapup:

	if (!dynamics_in_progress)
	{
	   WLshow_cursor( ME.IGEgadget->win_no );
	   WLflush( ME.IGEgadget->win_no );
	}

wrapup0:
	return( (*msg == MSFAIL) ? OM_E_ERROR : OM_S_SUCCESS );

	}

end implementation IGEgragad;
