class implementation DPvw;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "wl.h"

#include "FI.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "DPview.h"

/* prototype include files */
#include "DPvw_pyrmd.h"
#include "DPvwi.h"
#include "DPvw_var.h"

/*----------------------------------------------------------------*/
/* This method works like a complete command:    init, wakeup,  */
/* work ( display pyramids) and sleep. It is better used as a one */
/* time call. ( If want to display pyramids repeatedly, use other */
/* functions and methods.)					      */
/*----------------------------------------------------------------*/

IGRint DPshow_pyramid(msg,win_objid)
IGRlong *msg; 
GRobjid win_objid;
{
    IGRint i;
    struct DPbase_gg_t *base_p;
    struct DPview_wrk_t *wrk_p;
    struct DPpyramid_t   *pyrmd_p;

   /* assign working variables */

    DPassign_var(&base_p,&wrk_p,&pyrmd_p);

    /* initialize the pyramid structure and get all windows' info */

    wrk_p->cmd_type = NOT_CMD;

    DPvw_start(msg,wrk_p);

    /* 
     * following is a copy of portion of DPvw.I's get_curr_win() method
     */

       /*
    	* get current working window and other window's info
    	*/

    	DPpick_curr_window(msg,win_objid,wrk_p);

    	/* init base_p and wrk_p from the current window */

    	DPget_base_wrk(msg,base_p,wrk_p);

	/* calc and display pyramids */

        DPdp_pyramid(msg,pyrmd_p,wrk_p,wrk_p->view_to_wld,TRUE);
	
     	/* erase the pyramid left on the curr window */
    	i = wrk_p->curr_win;
        WLset_drawing_mode( wrk_p->win_no[i], (WL_BASE_NOOP | WL_HILITE_ERASE) );
    	DPco_erase_win(msg,wrk_p->win_no[i],
	      (IGRint)wrk_p->win_dit_rng[i][0],(IGRint)wrk_p->win_dit_rng[i][1],
	      (IGRint)wrk_p->win_dit_rng[i][3],(IGRint)wrk_p->win_dit_rng[i][4]);


   /* clear things */

    DPvw_end(msg,wrk_p,0);  /* not erase all windows hi-plane */

    return(TRUE);
}


end implementation DPvw;
