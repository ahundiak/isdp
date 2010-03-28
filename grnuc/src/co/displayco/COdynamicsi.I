/* #######################    APOGEE COMPILED   ######################## */





/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: COdynamics
     METHOD NAME: 

        Abstract: zoom in/out
-----
%SC%    

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     NA     

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
             
     Methods:

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%UI% 

     USER INTERFACE DESCRIPTION:
-----
%CH%

     CHANGE HISTORY:

     HT 6/23/86 : design date

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------


        zoom in / out     

----*/
/*EH*/


class implementation COdynamics;


#include "dpdef.h"
#include "madef.h"

from IGEgragad import dynamics;

%safe
/* prototype files */
#include "maptsxfor.h"
%endsafe

/*--------------------------------------------------------------*/
/*	method: wakeup						*/
/*--------------------------------------------------------------*/

method wakeup ( int pos )

{

	ex$message(msgnumb = GRC_M_ViewDyn);
    
    return ( OM_S_SUCCESS );
}


method delete( int f_defer_flag )

{
    IGRlong  status;

    clear_vsd;

    /*
     *  send to my parent class
     */
    status = om$send(
                mode = OM_e_wrt_message,
                msg = message Root.delete( f_defer_flag ),
                targetid = my_id );

    return( status );
}


/*--------------------------------------------------------------*/
/*	method: execute						*/
/*--------------------------------------------------------------*/

method execute ( int *response;
		 char *response_data;
		 int pos )

{
    IGRchar not_exit;
    IGRint status;
    IGRlong msg;
    IGRint num_id;
    struct GRid wnid[MAX_WINDOW];
    IGRdouble zoom_factor;
    IGRdouble pan_factor;
    IGRdouble max_rotate_factor;
    IGRdouble stroke_scale_factor;

    not_exit = TRUE;
    status = OM_S_SUCCESS;

    while ( not_exit )
    {

	ME.COdynamics->mask = GRm_DATA | GRm_RESTART;
	co$getevent( msg = &msg ,
                     event_mask =ME.COdynamics->mask,
		     msgnum = GR_P_IdWin,
                     response = response,
                     response_data = response_data,
                     event = &ME.COdynamics->event1);

	if ( ME.COdynamics->event1.response == EX_DATA )
	{
            num_id = 1;

            wnid[0].osnum = ME.COdynamics->event1.event.button.osnum;
            wnid[0].objid = ME.COdynamics->event1.event.button.objid;
        }
        else
        {
            not_exit = FALSE;
        }


       if (not_exit)
       { 

          /* doing actual dynamic  */

/*
	   if(ME.super_cmd->mytype == 1)
	   {

	      printf("Input zoom factor: ");
	      scanf("%lf",&zoom_factor);
	      printf("\n");

	      printf("Input pan factor: ");
	      scanf("%lf",&pan_factor);
	      printf("\n");

	      printf("Input max rotate factor in radians: ");
	      scanf("%lf",&max_rotate_factor);
	      printf("\n");

	      printf("Input stroke scale factor: ");
	      scanf("%lf",&stroke_scale_factor);
	      printf("\n");

	   }
	   else
	   {
*/
	      zoom_factor = 1.03125;
	      pan_factor = 0.1;
	      max_rotate_factor = PI/6;
	      stroke_scale_factor = 2.0;
/*
	   }
*/	    
	   status = om$send(mode = OM_e_wrt_object,
                               msg = message IGEgragad.dynamics(&msg,
				zoom_factor,pan_factor,max_rotate_factor,
				stroke_scale_factor),
                               senderid = my_id,
                               targetid = wnid[0].objid,
                               targetos = wnid[0].osnum);


	   if ( ! (1 & status) )
           {
#ifdef DEBUG
              printf("\nIN COdynamics Error send to DPzoom\n");
              om$report_error(sts = status);
#endif
              goto wrapup;	  
           } 

	}

    }/* end while	*/

wrapup:
    status = OM_S_SUCCESS;
    return ( status );
}/* end execute method */

end implementation COdynamics;
