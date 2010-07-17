class implementation  SFCoStfndPl;

/* -------------------------------------------------------------------------
   Doc : form_notification

   History :
   06-20-1994	Raju	Creation
------------------------------------------------------------------------- */

#include "stdio.h"
#include "FI.h"
#include "griodef.h"
#include "APunitdef.h"
#include "ACrg_collect.h"
#include "SFconvDef.h"
#include "SFstfndPlDef.h"

extern  double  APu_default_to_dbase();

method  form_notification (
	int			form_label;
	int			gadget_label;
	double			value;
	char			*form_ptr;
)

{
long	sts1, status, msg;
double  offset, offset_db;
char    text[80],
	DefaultUnitName[GRIO_MAX_ALIAS_SIZE];


    FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );

    switch ( gadget_label )
    {

        case SF_PLACE_AT_FLD :
		FIg_get_text ( form_ptr, SF_PLACE_AT_FLD, text );
		if ( strcmp( text, SF_TXT_KEYIN ) )
		{  FIg_erase ( form_ptr, SF_OFFSET_TXT);
		   FIg_erase ( form_ptr, SF_OFFSET_FLD);
		   FIg_erase ( form_ptr, SF_OFFSET_UNIT_TXT);
		}
		if ( !strcmp( text, SF_TXT_BOT_SURF ) )
		  sts1 = om$send ( msg = message SFCoStfndPl.PlacePlateAtBot(),
				    targetid = my_id );

		if ( !strcmp( text, SF_TXT_MID_SURF ) )
		  sts1 = om$send ( msg = message SFCoStfndPl.PlacePlateAtMid(),
				    targetid = my_id );

		if ( !strcmp( text, SF_TXT_TOP_SURF ) )
		  sts1 = om$send ( msg = message SFCoStfndPl.PlacePlateAtTop(),
				    targetid = my_id );

		if ( !strcmp( text, SF_TXT_KEYIN ) )
		{
		   FIg_display ( form_ptr, SF_OFFSET_TXT);
		   FIg_display ( form_ptr, SF_OFFSET_FLD);
		   sts1 = (long) APu_getTypeDefaultUnit ( GRIO_DISTANCE,
							  DefaultUnitName );
		   FIg_set_text (form_ptr, SF_OFFSET_UNIT_TXT,
							  DefaultUnitName);

		   FIg_display ( form_ptr, SF_OFFSET_UNIT_TXT);

		   FIg_get_value ( form_ptr, SF_OFFSET_FLD, &offset );
		   offset_db = APu_default_to_dbase ( GRIO_DISTANCE, offset );
#ifdef SF_DBG
	printf("offset_db : [%lf]\n", offset_db );		
#endif
		   sts1 = om$send ( msg = message SFCoStfndPl.PlacePlateAtKeyin(
								offset_db ),
				    targetid = my_id );
		}
		break;

	case SF_OFFSET_FLD:
		FIg_get_value ( form_ptr, SF_OFFSET_FLD, &offset );
		FIg_set_value ( form_ptr, SF_OFFSET_FLD, offset );
		offset_db = APu_default_to_dbase ( GRIO_DISTANCE, offset );
#ifdef SF_DBG
	printf("offset_db : [%lf]\n", offset_db );
#endif
		sts1 = om$send ( msg = message SFCoStfndPl.PlacePlateAtKeyin(
								offset_db ),
				 targetid = my_id );
		break;

	case FI_ACCEPT:
		sts1 = om$send ( msg = message SFCoStfndPl.PerformAcceptOp(
								&msg ),
				 targetid = my_id );
		FIg_set_state ( form_ptr, FI_ACCEPT, 0 );
		if ( msg == SF_CONVERTED )
		   break;
		else if ( sts1 & msg & 1 )
		   {  _put_response ( resp = EX_FORM_FINISHED ); }
		else
		   printf("form_notif : accept operation failed\n");
		break;

	case FI_CANCEL:
		sts1 = om$send ( msg = message SFCoStfndPl.PerformDeleteOp(),
				 targetid = my_id );
		_put_response ( resp = EX_FORM_FINISHED );
		break;
    }

quit:
    return OM_S_SUCCESS;
}

end implementation  SFCoStfndPl;

