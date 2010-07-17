#ifndef APlabels
#define APlabels

/*****************************************************************************

   Doc: APlabel.h

   Abstract: Defines constants used in labeling.
	
   History:

	Date		Who	Why
	---------	---	----------------------------------------
	23 Jun 89	msl	Creation
	13 Oct 92	qxn,aea	moved from POlabel.h, added DATA_INTID
 ****************************************************************************/

#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"

#define DATA_UID	0
#define DATA_COORDS	1
#define DATA_VALUE	2
#define DATA_INTID	3

typedef struct app_text_parms {
		struct GRdpb_text_symb	app_text_symb;
		char			justification;
		long			num_dec_places;
	} AP_textparms;

#endif

