class implementation DPvd_rv;
/*
** DPvd_rv  - restore [temporary|original] view
*/

#include <stdio.h>
#include <math.h>
#include <FI.h>


#include "go.h"
#include "dpdef.h" 
#include "dp.h" 
#include "dpmacros.h" 
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grmsg.h"

#include "grmsg.h"
#include "grcmd.h"


method execute (int *response;
		char *response_data;
		int pos )
/*
NAME
        execute(method)
       
DESCRIPTION
        Restore an old view for the  indicated window.

        me->command_type = 0x0  -  restore the "temporary" view.
                                   If there is no temporary view, or if the
				   identified view is already the same as 
				   the temporary view, restore original view.

        me->command_type = 0x1  -  restore the "original" view.

        me->command_type = 0x0  - ask user for the window to restore view info
        me->command_type = 0x4  - use the "active" window.


        In the last case, the "active" window is determined in the same way as
        with the "view dynamics" command.
       
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
        07/07/93    G. Werner      execute method
*/

{
   struct DPvd_actwin active_window;
   IGRint view_restored = 0;

   *response = TERMINATE;

   if(me->command_type & 0x4)
   {
	   /* get the "current" view */
           if(DPvd_get_active_window(&active_window) == 0)
	   {
#ifdef DEBUG
		printf("cannot get active window\n");
#endif
	        return OM_S_SUCCESS;
	   }
	   view_restored = DPvd_restore_view2( me->command_type & 0x1  , &active_window.grid);
   }
   else
   {
     while(TRUE)
     {
        IGRlong    msg;
	struct GRevent event1;
	struct GRid grid;

	co$getevent( msg = &msg ,
                     event_mask = GRm_DATA | GRm_RESTART | GRm_STRING,
		     msgnum = GR_P_IdWin,
                     response = response,
                     response_data = response_data,
                     event = &event1);

	if ( event1.response == EX_DATA )
	{
            grid.osnum = event1.event.button.osnum;
            grid.objid = event1.event.button.objid;

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

           /* Display appr. error messages  & continue */

           if ( num_id == 0)
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
        }
	else
		break    ;

	view_restored = DPvd_restore_view2( me->command_type & 0x1 , &grid);
     }
   }

   if(view_restored == 1)
   {
   	ex$message (field = ERROR_FIELD, msgnumb = GR_I_TmpVieRes);
   } 
   else if(view_restored == 2)
   {
        ex$message (field = ERROR_FIELD, msgnumb = GR_I_OriVieRes);
   }
   else
   {
	ex$message (field = ERROR_FIELD, msgnumb = GR_I_NoVieRes);
   }

   return OM_S_SUCCESS;

}/* end execute method */

/*--- init -----------------------------------------------------*/

method init ( int type;char *str_ptr)
/*
NAME
	init(method)

DESCRIPTION
	selects different types of restore view command.

SYNOPSIS
	method init ( int type;char *str_ptr)

PARAMETERS

GLOBALS USED

RETURN VALUES

NOTES

HISTORY
	07/07/93    G. Werner   
	   Creation Date
*/
{
    me->command_type = type;
    return OM_S_SUCCESS;

}


method super_cmd.sleep(int pos)
{
   long sts = OM_S_SUCCESS;

   /*
    * clear message field when command is put to sleep
    */
   ex$message (field = MESSAGE_FIELD,
               in_buff = "" );

   return(sts);
}
method wakeup (int pos)
{
   /* put name of command in message field */
   ex$message (field = MESSAGE_FIELD,
               in_buff = me->cmd_name);

   return(OM_S_SUCCESS);
}

end implementation DPvd_rv;
