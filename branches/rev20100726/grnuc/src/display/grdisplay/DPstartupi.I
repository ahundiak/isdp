class implementation DPstartup;

/*
DESCRIPTION
	Implementation file for the DPstartup

HISTORY
	S.P. Rogers  11/27/87  Creation Date
*/

#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"

#include "gr.h"

#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"

#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"

/* prototype files */
%safe
#include "DPsetinq.h"
#include "DPgetggid.h"
%endsafe

/*--------------------------------------------------------------*/

static void DPvalidate_windows_and_gragads()

/*
NAME
	DPvalidate_windows_and_gragads (static)

DESCRIPTION
	This function makes sure the shared flags between an
	IGEwindow and IGEgragad object are consistent and that
	IGEgragads are connected to an IGEwindow.

PARAMETERS
	none

GLOBALS USED
	none

NOTES
	This function was added in response to TR92n4790.
	We found out that the IGES translator was creating
	window/gragad pairs where the window was marked as
	off and the gragad was marked as on.  This caused
	the Zoom command to blow up because it tried to 
	draw a gragad that it thought was on.  The IGES
	folks will fix this problem, but this function is
	necessary to cope with all the files that have
	been translated prior to the fix.

	It was also added to fix problems introduced by
	the translation of IGDS saved views into EMS.
	The translation process was leaving IGEgragad
	objects in the file that weren't connected to
	an IGEwindow.  This was also causing the
	Zoom command to crash

HISTORY
	05/26/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             msg;
	IGRint              total_found;
	IGRint              num_ids;
	IGRint              ii;
	OMuint              number_on_channel;
	struct GRid         gragad_ids[40];
	IGRlong             ret_bytes;
	IGRlong             which_error;
	IGRint              gg_flags[2], win_flags[2], new_gg_flags[2];
	struct var_list     gg_var_list[2];
	struct win_var_list win_var_list[2];
	OM_S_OBJECT_LINKAGE parent_list[1];
	OM_S_CHANSELECT     parent_chandef;


	win_var_list[0].var = WINDOW_FLAGS;
	win_var_list[0].var_ptr = (IGRchar *) win_flags;
	win_var_list[0].num_bytes = sizeof( IGRint ) * 2;
	win_var_list[0].bytes_returned = &ret_bytes;
	win_var_list[1].var = END_PARAM;

	gg_var_list[0].var = GRAGAD_FLAGS;
	gg_var_list[0].var_ptr = (IGRchar *) gg_flags;
	gg_var_list[0].num_bytes = sizeof( IGRint ) * 2;
	gg_var_list[0].bytes_returned = &ret_bytes;
	gg_var_list[1].var = END_PARAM;

	om$make_chanselect( channame = "IGEgadget.to_parent",
	                    p_chanselect = &parent_chandef );

	/* get all the gragads in the file */
	num_ids = 0;
	dp$get_gragad_id( msg         = &msg,
	                  name        = "*",
                          array_size  = 40,
                          total_num   = &total_found,
	                  numberofids = &num_ids,
	                  found_GRids = gragad_ids );

	/* check all gragads for consistency with their parent windows */
	for ( ii = 0; ii < num_ids; ii++ )
	   {
	   om$get_channel_objects( objid = gragad_ids[ii].objid,
	                           osnum = gragad_ids[ii].osnum,
	                           p_chanselect = &parent_chandef,
	                           list = parent_list,
	                           size = 1,
	                           count = &number_on_channel );

	   if ( number_on_channel == 0 )
	      {
	      /* no window object connected to the gragad */
	      /* => delete the gragad from the file       */
	      om$send( msg      = message Root.delete(0),
	               targetid = gragad_ids[ii].objid,
	               targetos = gragad_ids[ii].osnum,
	               senderid = NULL_OBJID );
	      }
	   else
	      {
	      ige$inq_set_window( msg = &msg,
	                          inq0_set1 = 0,
	                          osnum = gragad_ids[ii].osnum,
	                          window_objid = parent_list[0].S_objid,
	                          which_error = &which_error,
	                          var_list = win_var_list );

	      dp$inq_set_gragad( msg = &msg,
	                         inq0_set1 = 0,
	                         osnum = gragad_ids[ii].osnum,
	                         gragad_objid = gragad_ids[ii].objid,
	                         which_error = &which_error,
	                         var_list = gg_var_list );

	      new_gg_flags[0] = new_gg_flags[1] = 0;

	      if ( (win_flags[0] & WIN_IS_ON) && (!(gg_flags[0] & IS_WIN_ON)) )
	         {
	         /* window on and gragad off => turn gragad on */
	         new_gg_flags[0] |= IS_WIN_ON;
	         new_gg_flags[1] |= IS_WIN_ON;
	         }

	      if ( (!(win_flags[0] & WIN_IS_ON)) && (gg_flags[0] & IS_WIN_ON) )
	         {
	         /* window off and gragad on => turn gragad off */
	         new_gg_flags[0] |= IS_WIN_ON;
	         }

	      if ( new_gg_flags[0] != 0 )
	         {
	         /* need to update flags in the gragad */
	         gg_flags[0] = new_gg_flags[0];
	         gg_flags[1] = new_gg_flags[1];

	         dp$inq_set_gragad( msg = &msg,
	                            inq0_set1 = 1,
	                            osnum = gragad_ids[ii].osnum,
	                            gragad_objid = gragad_ids[ii].objid,
	                            which_error = &which_error,
	                            var_list = gg_var_list );

	         }

	      }  /* end: else */

	   }  /* end: for */

	}  /* DPvalidate_windows_and_gragads */


/*--- execute -------------------------------------------------*/

method execute( int  *response;
                char *response_data;
                int  pos )

/*
NAME
	DPstartup.execute

DESCRIPTION
	Startup command for the display subsystem:

	   Create (new file) or Retrieve (old file) DPusrlnstl object which
	   holds 248 (potentially) user-defined line styles.

	   Make sure that the flags shared between the IGEwindow and IGEgragad
	   objects are consistent

PARAMETERS
	response (IN/OUT) - response type
	response_data (IN/OUT) - data for the response
	pos (IN) - position of command

GLOBALS USED
	none

HISTORY
	04/12/91    Trevor Mink
	   Created.
	05/26/92    S.P. Rogers
	   Added IGEwindow/IGEgragad consistency checks
*/

	{
	IGRlong        sts;
	OM_S_OBJID     mod_id;
	OMuword        mod_osnum;
	OM_S_OBJID     super_id;
	OMuword        super_osnum;

	sts = ex$get_cur_mod( osnum = &mod_osnum, id = &mod_id );

	/* Make sure that the DPstartup super object initiates the execute command */
	/* for the GRusrlnstl object. If this is a new file, the super_construct   */
	/* action is initiated by ex$get_super. Otherwise, the wakeup method is    */
	/* called. If the file already existed, ex$get_super returns the object id */
	/* and osnum of the super object and it won't be re-created		   */
	sts = ex$get_super( mod_id      = mod_id,
	                    mod_osnum   = mod_osnum,
	                    super_name  = "DPusrlnstl",
	                    create      = 1,
	                    super_class = "DPusrlnstl",
	                    super_id    = &super_id,
	                    super_osnum = &super_osnum );

	sts = ex$get_super( mod_id      = mod_id,
	                    mod_osnum   = mod_osnum,
	                    super_name  = "DPcodpb",
	                    create      = 1,
	                    super_class = "DPcodpb",
	                    super_id    = &super_id,
	                    super_osnum = &super_osnum );


	DPvalidate_windows_and_gragads();

	*response = TERMINATE;
	return( OM_S_SUCCESS );

	} /* execute */


end implementation DPstartup;
