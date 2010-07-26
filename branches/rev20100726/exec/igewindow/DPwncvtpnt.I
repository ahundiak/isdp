
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS  NAME  IGEwindow

     METHOD NAME  convert_pnt
 
     Abstract:  This method converts a data point from screen dit to
                world coordinate system.
-----
%SC%

        convert_pnt ( &pnt )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *pnt    struct GRbigpoint Address of a data point in IGDS format.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

        czn  03/28/86  : Creation date.
        czn  04/25/86  : change to add the resulting data point to 
                         the event queue.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEwindow;


#include "igewindef.h"

method convert_pnt ( long *msg; int *response; struct EX_button *wnpnt )

{
   OM_S_CHANSELECT  chandef;
   IGRint status;
   OMuint count;


   *msg = MSSUCC;

#ifdef ENV5
   if (ME.IGEwindow->win_type == NO_BORDER)
   {
      if ((wnpnt->x < 0) || (wnpnt->y < 0) ||
	  (wnpnt->x > (ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep)) ||
	  (wnpnt->y > (ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep)))
      {
	 Process_window_icon_menu(ME.IGEgadget->win_no,(IGRint) wnpnt->x,
						       (IGRint) wnpnt->y);

	 status = TRUE;
	 goto wrapup;
      }
   }
#endif

   chandef.type = OM_e_name;
   chandef.u_sel.name = "to_children";


   status = om$get_channel_count( objid = my_id, 
                                  p_chanselect = &chandef, 
                                  count = &count);


   if (!(1 & status))
   {
       om$report_error(sts = status);
       goto wrapup;
   }

   if (count)
   {
      status = om$send(msg = message IGEgadget.convert_pnt(msg, response, 
                                                           wnpnt), 
                       p_chanselect = &chandef);


       if (!(1 & status))
       {
           om$report_error(sts = status);
           goto wrapup;
       }

   }

wrapup:

    return ( status );
}

end implementation IGEwindow;
