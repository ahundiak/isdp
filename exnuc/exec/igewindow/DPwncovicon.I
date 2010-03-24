/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEwindow
	METHOD NAME:	covicon

	Abstract:
		This method will handle window uncovered condition
-----
%SC%

	VALUE = covicon (*msg )

      This method will send update message to window that is uncovered.
----*/
/*EH*/


class implementation IGEwindow;

#include "igewindef.h"
#ifdef X11
#include "igewinmacros.h"
#endif

method covicon( IGRlong *msg;struct IGEdit_range *range)
{	
    IGRlong status;
    OMuint  count;
    OM_S_CHANSELECT  chandef;
   
	*msg = MSSUCC;

#ifdef X11
     /* have to clear win_is_notmapped flag here since we have to
        clear MapNotify after ConfigureNotify to avoid multiple 
	refresh of graphic window.   */ 

        ME.IGEwindow->flags &= ~WIN_IS_NOTMAPPED;
#endif
	if (ME.IGEwindow->win_type == NO_BORDER)
	{
	   if (ME.IGEwindow->draw_border == TRUE)
	   {
	      status = om$send(msg = message IGEwindow.draw_border(0xffffffff),
		       targetid = my_id);

	      if (!(status & 1))
	      {
		 om$report_error(sts = status);
		 *msg = MSFAIL;
		 goto wrapup;
	      }
	   }
	   else
	   {
	      status = om$send(msg = message IGEwindow.draw_border(0),
		       targetid = my_id);

	      if (!(status & 1))
	      {
		 om$report_error(sts = status);
		 *msg = MSFAIL;
		 goto wrapup;
	      }

	   }
	}


	chandef.type = OM_e_name;
	chandef.u_sel.name = "to_children";



	status = om$get_channel_count(objid = my_id, 
				  p_chanselect =&chandef, 
				  count = &count);

				
	if ( ! ( 1 & status ) )
	{
	   om$report_error(sts = status );
	   *msg = MSFAIL;
	   goto wrapup;
	}

	if (count)
	{
	   status = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgadget.covicon(msg, range),
                     senderid = my_id,
                     p_chanselect = &chandef);

	   if ( ! ( 1 & status ) )
	   {
	      om$report_error(sts = status );
	      *msg = MSFAIL;
	   }
	}

wrapup:

    return ( status );
}

end implementation IGEwindow;
