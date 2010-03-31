/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*
These functions are not being used , see if you can remove them. Shridar 
                                                                   May 5 92 
*/

#include <stdio.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "igecolordef.h"
#include "msdef.h"
#include "gr.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "hssymb.h"

#include "HSpr_bundle.h"


#define HSSYMB_SIZE  (sizeof(struct HS_symb_and_app) + 4)
static   IGRchar  *HSsymb_map[266];


#if defined(__STDC__) || defined(__cplusplus)
	IGRint  HSsymb_update_ptr( IGRlong *msg,
				GRspacenum osnum,
				   IGRchar *entry_ptr )
#else
	IGRint  HSsymb_update_ptr(msg,osnum,entry_ptr)

	IGRlong		*msg;
	GRspacenum	osnum;
	IGRchar		*entry_ptr;
#endif
{

    IGRint	status = TRUE;
       
	*msg = MSSUCC;

	HSsymb_map[osnum] = entry_ptr;
	
	return(status);
}


#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSget_symb( IGRlong *msg,
			 GRspacenum osnum,
			     IGRint index,
	     struct HS_symb_and_app *dis_attr )
#else
	IGRint	HSget_symb(msg,osnum,index,dis_attr)

	IGRlong		*msg;
	GRspacenum	osnum;
	IGRint		index;
	struct HS_symb_and_app *dis_attr;
#endif
{

    IGRint status = TRUE;
    struct HS_symb_and_app *inst_dis_attr;

	*msg = MSSUCC;


	inst_dis_attr = (struct HS_symb_and_app *) (HSsymb_map[osnum] + (index * HSSYMB_SIZE) + 4);

	*dis_attr = *inst_dis_attr;

	return(status);
}
