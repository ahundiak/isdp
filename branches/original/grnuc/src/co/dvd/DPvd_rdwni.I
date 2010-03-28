class implementation DPvd_rdwn;
/*
** DPvd_rdwn - redraw windows: recompute the display list
*/

#include <stdio.h>
#include <math.h>
#include <FI.h>

#include "exmacros.h"

#include "go.h"
#include "dpdef.h" 
#include "dp.h" 
#include "dpmacros.h" 
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grcmd.h"
#include "grmsg.h"

#include "DPdlist.h" 

/* New Prototypes */
PROTO_DPdlist_set_tolerance_gragad

from IGEgragad import DPupdate;





method execute (int *response;
		char *response_data;
		int pos )
/*
NAME
        execute(method)
       
DESCRIPTION
        After identifying a window, update the display list
        with a tolarance useful for the identified window.
        When finished, the command exits immediatly
       
SYNOPSIS
        method execute (int *response;
                        char *response_data;
	                int pos )
       
PARAMETERS
GLOBALS USED
RETURN VALUES
        Always OM_S_SUCCESS     
NOTES
HISTORY
        07/14/93    G. Werner
*/

{
   IGRlong    msg;
   int        status = OM_S_SUCCESS;
   struct GRid grid;


   ex$message (field = MESSAGE_FIELD,
               msgnumb =  GRC_M_RedWins);

   while(TRUE)
   {
	struct GRevent event1;

        /* first get the window, which is used for tolerancing
        ** the display list
        */
	co$getevent( msg = &msg ,
                     event_mask = GRm_DATA | GRm_RESTART | GRm_STRING,
		     msgnum = GR_P_IdeWinTol,
                     response = response,
                     response_data = response_data,
                     event = &event1);

	if ( event1.response == EX_DATA )
	{
            grid.osnum = event1.event.button.osnum;
            grid.objid = event1.event.button.objid;
            break;
        }
        else if( event1.response == EX_STRING )
        {
           IGRint num_id, dummy;

           /* check for string length and quit if neccessary   */

           if(!strlen(event1.event.keyin))
  	   {
	           	ex$message ( msgnumb = GR_E_AmbNme);
			continue ;
           }

           /* check if name exists */

           num_id = 0;
	   dp$get_gragad_id(msg = &msg,
			name        = event1.event.keyin,
			array_size  = 1,
			total_num   = &num_id, 
			numberofids = &dummy,
			found_GRids = &grid);

           /* Display appr. error messages  & set the "action return code"*/

           if ( num_id <= 0)
           {
	        	ex$message ( msgnumb = GR_E_WinNotFnd);
			continue ;
           }
           else if(num_id > 1)
           {
                           /* Error only if searching for one window.
                              Command can't proceed if more then one window
                                      is returned    */
	           	ex$message ( msgnumb = GR_E_AmbNme);
			continue ;
           }
	   else
	   {
              break;
           }
        }
        else
	    return status;

   }

   {
	OMuword    mod_osnum;
	OM_S_OBJID mod_objid;

	/* set the display list tolerance according to this window */
        DPdlist_set_tolerance_gragad( &grid );

	/* update all the windows */
	ex$get_cur_mod(
		id = &mod_objid,
		osnum = &mod_osnum );

	dp$gen_update(
		msg = &msg,
		osnum = mod_osnum,
		mod_objid = mod_objid );

   }

   *response = TERMINATE;
   return OM_S_SUCCESS;
}/* end execute method */


end implementation DPvd_rdwn;
