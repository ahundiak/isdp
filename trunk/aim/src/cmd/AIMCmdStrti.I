/* $Id: AIMCmdStrti.I,v 1.2 2002/05/23 17:08:04 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/AIMSIR
 *
 * File:	aim/src/cmd/AIMCmdStrti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: AIMCmdStrti.I,v $
 *	Revision 1.2  2002/05/23 17:08:04  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/06/01 20:06:28  tlstalli
 *	Creating aim module
 *	
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation AIMCmdStrt ;

#define AIM_PROD_NAME                 "aim"

#include "nddef.h"
#include "ndmacros.h"
#include "AIMincludes.h"
#include "vadbgmacros.h"

#include "VDtypedef.h"
#include "VDppl1.h"

/* prototypes */

#define AIM_SESSION_STARTUP	0
#define AIM_DGNFILE_STARTUP	1

/*----------------------------------------------------------------------------*/
method init( int type ; char *s ) {

	SetProc( AIMCmdStrt_init ); Begin

	__DBGpr_int(" myType ", type );

	me->mytype = type ;

	End
	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method execute(	int *response ; char *response_data ; int pos ) {

	SetProc( AIMCmdStrt_execute ); Begin

	
	
	nd$mod_broadcast(	request     = ND_SET,
				req_mode    = ND_NO_BROAD_DEL ) ;

	if( me->mytype == AIM_SESSION_STARTUP ) {

		/*
		 *Session startup. See if user has a license to use I/AIM
                 *
		 * gr$get_license(
		 *		product_id      = "CM01063",
                 *              run_name        = "AIMSIR",
		 *		options		= GRDisableOnError ) ;
                 */

	  __DBGpr_com(" AIM_SESSION_STARTUP ");

		/*
		 * initialization of globals.
		 */

	} else if( me->mytype == AIM_DGNFILE_STARTUP ) {

	  TGRid   pplID;
	  IGRint  pplRET;
	  IGRchar pplProduct[16];

	  __DBGpr_com(" AIM_DGNFILE_STARTUP ");

	  // Inform the ppl about to start
	  strcpy(pplProduct,"aim");
	  vdppl$Load(pplID = &pplID, name = "aimstartup.u");
	  vdppl$SetData(pplID = &pplID, 
			name  = "PRODUCT", 
			size  = 16, 
			data  = pplProduct);

	  vdppl$Run(pplID = &pplID, name = "startup1", ret = &pplRET);

	  /* ------------------------------------------
	   * Fooling ourselves here, dgnfile does not get called
	   * for extr so these never get loaded
	   */
	  AIM_prdLoadCorrections( AIM_PROD_NAME );
	  vdppl$Run(pplID = &pplID, name = "startup2", ret = &pplRET);

	  vdppl$Delete(pplID = &pplID);
	} 

        *response = TERMINATE ;

	End ;
	return OM_S_SUCCESS ;

} /* method execute */
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

end implementation AIMCmdStrt ;
