/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRwn
	METHOD NAME:	GRwn_construct

	Abstract:
-----
%SC%

	VALUE =

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

-----
%RL%

	RELATIONS REFERENCED:
				GRwswn
				GRwnvw

-----
%NB%


	
-----
%CH%

	CHANGE HISTORY

	MS    09/12/85	: Design date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEgragad;

#define DEBUG 1
#ifdef ENABLE_MATH_H
%safe
#include <math.h>
%endsafe
#else
#include <math.h>
#endif
#include <string.h>

#include "grimport.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "ex.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

/* prototype files */
%safe
#include "DPcons.h"
#include "DPaddvwname.h"
#include "COexpreval.h"

#include "maidmx.h"
%endsafe

                                                    
/*--- The following function is a fix requested by Mapping to enable windows
      to be created without Near and Far Z clipping enabled.
---*/

%safe
static IGRboolean front_clip_enabled = TRUE, back_clip_enabled = TRUE;
%endsafe


#if defined(__STDC__) || defined(__cplusplus)
void DPset_default_zclip_flags(	IGRboolean front, 
                                IGRboolean back )
#else
void DPset_default_zclip_flags( front, back )

	IGRboolean front, back;
#endif

	{
	front_clip_enabled = front;
	back_clip_enabled = back;
	}


method gragad_cons (IGRlong *msg; IGRchar *name; IGRdouble min_x;
		    IGRdouble min_y; IGRdouble max_x; IGRdouble max_y)
	{
	IGRlong stat;
	IGRint i;
	IGRint length;
	IGRdouble stand_vvol[3];


	stat = OM_S_SUCCESS;

	*msg = MSSUCC;

	stat = DPadd_vw_name_dir(msg,DP_PROTECTION,OM_Gw_current_OS, my_id, GRDP_REGVIEWS, GRDP_GRVIEWS,name);
	if (stat == DPDUPLICNM)
	{
	    goto fini;
	}
	else if(!(1&stat))
	{
	    #ifdef DEBUG
    	    om$report_error(sts = stat);
            #endif
            goto fini;
	}
	length = strlen(name);

	if (length > 31)
	{
	   length = 31;
	}

        /* This macro will return the distance in unit of measure data base units.
           i.e. 1000 inches will return 1000.0 when db is english and 25400.0 when 
           db is metric (mm) */
        stat = co$expreval( msg = msg,
                              expression = "1000 inch",
                              unit_type  = GRIO_DISTANCE,
                              result     = &(stand_vvol[2]) );

        /* assign the x and y view volume similarly.  x was 1400 and y was 1000. If 
           the distance for stand_vvol[2] (z) changes these 2 lines below will need to
           change also to keep the same value. */
	stand_vvol[0] = 1.4 * stand_vvol[2];
	stand_vvol[1] = stand_vvol[2];

	ME.IGEgadget->min_x_indep = min_x;
	ME.IGEgadget->min_y_indep = min_y;
	ME.IGEgadget->max_x_indep = max_x;
	ME.IGEgadget->max_y_indep = max_y;

	ME.IGEgragad->gragad.flags = 0;

	ME.IGEgragad->gragad.flags |= AXIS_WLD_ALIGN;
	ME.IGEgragad->gragad.flags |= CLIP;

/*    This has been masked in response to CR           .... Mohan   */

/*	ME.IGEgragad->gragad.flags |= GRID_ON; */
/* ---------------------------------------------------------------- */

 	ME.IGEgragad->gragad.flags |= IS_WIN_ON;
	if ( front_clip_enabled )
 	   ME.IGEgragad->gragad.flags |= FRONT_CLIP;
	if ( back_clip_enabled )
 	   ME.IGEgragad->gragad.flags |= BACK_CLIP;

	/* grid parameters */
	ME.IGEgragad->gragad.uor_per_ref_x = DEF_UOR_PER_REF;
	ME.IGEgragad->gragad.uor_per_ref_y = DEF_UOR_PER_REF;
	ME.IGEgragad->gragad.grid_per_ref_x = DEF_GRID_PER_REF;
	ME.IGEgragad->gragad.grid_per_ref_y = DEF_GRID_PER_REF;

	ME.IGEgragad->gragad.origin[0] = 0.0;
	ME.IGEgragad->gragad.origin[1] = 0.0;
	ME.IGEgragad->gragad.origin[2] = 0.0;
/*	ME.IGEgragad->gragad.origin[3] = 1.0; */

	if (!MAidmx(msg, (IGRdouble *)ME.IGEgragad->gragad.rotation))
 	 {
	    stat = OM_E_ABORT;
	    goto fini;
	 }

	ME.IGEgragad->gragad.act_z = 0;

	ME.IGEgragad->gragad.vw_volume[0] = -stand_vvol[0];
	ME.IGEgragad->gragad.vw_volume[1] = -stand_vvol[1];
	ME.IGEgragad->gragad.vw_volume[2] = -stand_vvol[2];
	ME.IGEgragad->gragad.vw_volume[3] = stand_vvol[0];
	ME.IGEgragad->gragad.vw_volume[4] = stand_vvol[1];
	ME.IGEgragad->gragad.vw_volume[5] = stand_vvol[2];

	for (i=0; i<32; i++)
	{
	   ME.IGEgragad->gragad.levels[i] = 0xffffffff;
	}

	ME.IGEgragad->gragad.gpipe_id =-1;
fini:
	return (stat);
	}
	end implementation IGEgragad;
                               
