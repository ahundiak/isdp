/* #######################    APOGEE COMPILED   ######################## */
class implementation COreviewele;

#include  "coimport.h"
#include  "msdef.h"
#include  "grmessage.h"
#include  "exmacros.h"
#include  "msmacros.h"
/* #include  "FIchan.h" */
#include  <stdio.h>
#include  "revieweledef.h"
#include  "FI.h"
 
/*  from GRgraphics import GRgetsfsize, GRloadform; */

#define MAIN_FORM 0
#define RESTORE_DEFAULTS 1

method  form_notification(int form_label; 
                          int gadget_label;
                          double value;
                          char *form_ptr)

{

    IGRlong		status,
    			i;

    IGRint		msg;

    extern  void  notify();

    switch (form_label) 
    {
      case MAIN_FORM :

      switch ( gadget_label )
	{
	    case MAIN_DISMISS_BUTTON:
	    {
		 /*  erase the main form
		 */
            for ( i = me->number_of_forms -1 ; i >= 0;  i-- ) {
            /*
             *  erase the displayed form
             */

            if( me->forms[i].displayed ) {
                status = om$send (
                    msg = message CEO.erase_form_by_label
                            (me->forms[i].label, 1, &msg),
                        targetid = my_id );
            }
        }
		break;
        }
	    case MAIN_MORE_INFO:
	    {
          if (!me->display) {
             status = FIg_set_state_off(me->forms[0].form_ptr,
                          MAIN_MORE_INFO);
             status = om$send (msg = message COreviewele.update_subform (&msg),
                      targetid = my_id );
             if (!(status & msg & 1))
               return (OM_E_ABORT);
          }
          else
             status = FIg_set_state_off(me->forms[0].form_ptr,
                          MAIN_MORE_INFO);
          break;
       }
     }
    default:
	switch ( gadget_label )
	{
	    case MAIN_DISMISS_BUTTON:
	    {
		/*
		 *  erase the subform
		 */

             status = om$send ( msg = message CEO.erase_form_by_label
                            (me->sub_form, 1, &msg),
                   targetid = my_id );
             me->display = 0;		
		break;
	    }
	}
  }   

    /*
     * Trashed any malloced memory.
     */
    return(OM_S_SUCCESS);
}

end implementation COreviewele;
