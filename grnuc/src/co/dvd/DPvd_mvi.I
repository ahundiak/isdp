class implementation DPvd_mv;
/*
** DPvd_mv - Mark [temporary|original] view
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

#include "grcmd.h"
#include "grmsg.h"




method execute (int *response;
		char *response_data;
		int pos )
/*
NAME
        execute(method)
       
DESCRIPTION
        Mark the "current" or all views for later restore during
        the View dynamics command or by execute the "restore view"
        commmand.
        There are three used bits in the command_type variable:
        me->command_type = 0x0  -  store as "marked" view.
        me->command_type = 0x1  -  store as "original" view.

        me->command_type = 0x0  - store the "current" view.
        me->command_type = 0x2  - store the all available views.

        me->command_type = 0x0  - ask user for the window to store view info
        me->command_type = 0x4  - use the "active" window.

        In the last case, the "active" window is determined in the same way as
        with the "display view dynamics" command.
       
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
        07/07/93    G. Werner
*/

{
   struct DPvd_actwin active_window;
   IGRlong    msg;

   *response = TERMINATE;

   if(me->command_type & 0x2)
   {
        IGRint     num_wins;
        struct     GRid windows[EX_MAX_WINDOW];
        IGRint     status;
        IGRint     i;


	/* get all window id's */
	
	status = dp$get_gragad_id( 
		msg = &msg,
		name = "*",
		type_gragad =ALL_GG_CLASSES|GG_WIN_ON|ACTIVE_GG|NO_DELAY_GG ,
		array_size = EX_MAX_WINDOW,
		numberofids = &num_wins,
		found_GRids = windows);
	
        /*
        printf("store all %d windows....\n",num_wins);
        */

	for(i=0;i<num_wins;i++)
	{

	    DPvd_mark_view( me->command_type & 0x1, &windows[i], NULL);
	    
        }
   }
   else if(me->command_type & 0x4)
   {
           /* printf("Mark the active view\n"); */
	   /* get the "active" window */
           if(DPvd_get_active_window(&active_window) == 0)
	   {
#ifdef DEBUG
		printf("cannot get active window\n");
#endif
	        return OM_S_SUCCESS;
	   }
	   DPvd_mark_view( me->command_type & 0x1, &active_window.grid, NULL);
   }
   else
   {
     while(TRUE)
     {
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

	DPvd_mark_view( me->command_type & 0x1, &grid, NULL);

	if(me->command_type&0x1)
	{
	    /* MrkOriVie command has been taken out
	    ex$message (field = ERROR_FIELD, msgnumb =  GR_I_MrkOriVie);
	    */
	}
	else
	{
	    ex$message (field = ERROR_FIELD, msgnumb =  GR_I_MrkTmpVie);
	}
     }
   }


   return OM_S_SUCCESS;
}/* end execute method */


/*--- init -----------------------------------------------------*/

method init ( int type;char *str_ptr)
/*
NAME
	init(method)

DESCRIPTION
	selects different types of mark view command.

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
    if(me->command_type&0x1)
    {
	/* MrkOriVie command has been taken out
	   ex$message (field = ERROR_FIELD, msgnumb =  GR_I_MrkOriVie);
	*/
    }
    else
    {
	ex$message (field = ERROR_FIELD, msgnumb =  GR_I_MrkTmpVie);
    }

   return(OM_S_SUCCESS);
}

end implementation DPvd_mv;
