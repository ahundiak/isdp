/* $Id: SMMgrOver.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / SMMgrOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMMgrOver.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 15 Jul 91	  creation date.
/*
/* */

class implementation SMCpTxt;


#include "AS_status.h"

#define AS_DEBUG

/* from ov_ci_mac	import	NDdelete; is inherited	*/

/* ******************* MSG SMWhoAreYou() ************************	*/

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{

 if(sub_type != NULL) *sub_type = 0xffff;

 if(type != NULL) *type = SM_SRF;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}



/* ******************* MSG  NDdelete() ************************	*/



method NDdelete(struct GRmd_env *md_env)

{
 IGRlong 	status;
 IGRint		stat;
 IGRshort	is_consume, is_display;
 struct GRid	as_text;


 status = om$send( msg = message  ACcpx.ACfind_exp_temp_obj
					(&stat,1,&as_text),
                    targetid = my_id );
 as$status( action = RET_STATUS );
 if(!stat) goto wrapup;

 is_consume = 0; /* unconsume the template */
 is_display = 1;
 status = VDconsume_and_display( as_text, is_consume, is_display, md_env );
 as$status( action = RET_STATUS );

 
wrapup:
        status = om$send( msg      = message ACncpx.NDdelete(md_env),
	         targetid = my_id,
                 mode     = OM_e_wrt_message );
 	as$status( action = RET_STATUS );
 return(1);
}

end implementation SMCpTxt;
 

