
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

class		HSgetzmem
super_class	HSwindow
command_object	HSM_M_GetZbufMemory,0,HSGtZMm
product_name	"$MODEL"
start_state	start


state_table
#include "dpdef.h"

implementation

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "igrtypedef.h"

#include "igetypedef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "hsurf.h"
#include "hsmsg.h"
#include "HStl_window.h"
#include "hswinmacros.h"

/*------------------------
 *  for functions
 *     HMdispose
 *     HSactivate_window
 */
 
#include "OMminimum.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_global.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--------------------------*/

state start
	on CMD_TYPE = 0	
	   do get_windows( sts, (HIDDENLN_GG | GG_WIN_ON), 0, 0 )
	      on ELSE
	         do get_zbuffer_memory
	         state terminate
	   state terminate


/*--- get_zbuffer_memory -----------------------------------------*/

action get_zbuffer_memory

/*
DESCRIPTION
	Convert all the shading windows to wireframe and free the big
	buffer used for the Z/Image buffers.
*/

	{
	IGRlong	        msg;
	IGRint          gpipe_id;
	IGRint          ii;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRint          total_freed;
	struct var_list var_list1[2];

	*sts = OM_S_SUCCESS;

	for ( ii = 0; ii < me->num_win_ids; ii++ )
	   {
	   /* get the needed instance data */
	   var_list1[0].var            = GPIPE_ID;
	   var_list1[0].var_ptr        = (IGRchar *) &gpipe_id;
	   var_list1[0].num_bytes      = sizeof( IGRint );
	   var_list1[0].bytes_returned = &ret_bytes;

	   var_list1[1].var            = END_PARAM;

	   dp$inq_set_gragad( msg = &msg, inq0_set1 = 0,
	                      osnum = me->win_ids[ii].osnum,
	                      gragad_objid = me->win_ids[ii].objid,
	                      which_error = &which_error, var_list = var_list1 );

	   /* Only change the window to wireframe if it has a zbuffer allocated */
	   HSactivate_window( gpipe_id );
	   if ( active_window->zbuf )
	      {
	      hs$convert_shading_window_to_wireframe( msg = &msg,
	                                              win_id = me->win_ids[ii].objid,
	                                              win_os = me->win_ids[ii].osnum );
	      }

	   }  /* end: for */
		
	total_freed = HMdispose();
	ex$message( msgnumb = HS_I_ZbufferBytes, var = `total_freed`, type = "%d" );

	}  /* get_zbuffer_memory */
