class implementation  SFCoConvBm;

/* -------------------------------------------------------------------------
   Doc : form_notification

   Description : 

   History :
   05-30-1994	Raju	Creation
-----------------------------------------------------------------------------*/
#include "stdio.h"
#include "FI.h"

#include "griodef.h"
#include "APunitdef.h"
#include "SFconvBmDef.h"

method  form_notification (
        int                     form_label;
        int                     gadget_label;
        double                  value;
        char                    *form_ptr;
)

{
long	sts1, status, msg;


    FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );

    switch ( gadget_label )
    {
	case FI_ACCEPT:
		sts1 = om$send ( msg = message SFCoConvBm.PerformAcceptOp(
								&msg ),
				 targetid = my_id );
		FIg_set_state ( form_ptr, FI_ACCEPT, 0 );

		if ( msg == SF_BM_CONVERTED )
		     break;
		else if ( sts1 & msg & 1 )
		{    _put_response ( resp = EX_FORM_FINISHED ); }
		else
		   printf("form_notif : SFCoConvBm.PerformAcceptOp failure\n");

		break;

	case FI_CANCEL:
		sts1 = om$send ( msg = message SFCoConvBm.PerformDeleteOp(),
				 targetid = my_id );
		_put_response ( resp = EX_FORM_FINISHED );
		break;
    }

quit:
    return OM_S_SUCCESS;
}

end implementation  SFCoConvBm;

