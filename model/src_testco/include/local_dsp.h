/*
 * This macro displays a line string w/o creating an object.
 * Arguments are as follows:
 *
 *	int		sts;			OM return status
 *	int		*msg;			Message code
 * 	int		num_pnts;		How many points?
 * 	IGRpoint	*pnts;			The points
 * 	int		draw_background;	Draw in background?
 *
 * Also used:
 *
 *	struct IGRdisplay	ME.CObuild->ActiveDisplay
 *	struct GRmd_env		ME.CObuild->ModuleInfo
 *
 */
#define LOCAL_DISPLAY(sts, msg, num_pnts, pnts, draw_background)\
{\
 int	ECdisplayPointSetByBuffer(); \
 sts = ECdisplayPointSetByBuffer(msg, ME.CObuild->ActiveDisplay, \
        ME.CObuild->ModuleInfo, my_id, num_pnts, pnts, draw_background); \
}

