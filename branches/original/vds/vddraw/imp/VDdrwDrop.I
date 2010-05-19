/* $Id: VDdrwDrop.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwDrop.I
 *
 * Description:
 *
 *      This file implements the Drop methods for visualization objects.
 *
 * Dependencies:
 *	VDdrwObj.S
 *
 * History:
 *      06/17/97        adz		Creation Date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwObj;

#include "EMSutlmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

/*----------------------------------------------------------------------------*/
method GRdrop( long *msg ; struct GRmd_env *myEnv ) {

	long		sts ;		/* OM return code		*/
	struct GRid	myObj,
			gmId ;

	SetProc( VDdrwObj_GRdrop ); Begin

	*msg	= MSSUCC ;

	myObj.objid	= my_id ;
	myObj.osnum	= OM_Gw_current_OS ;
	gmId.objid	= NULL_OBJID ;

	/*
	 * Get the "geom" feet of the VDdrw2d & VDdrw3d obejct.
	 */
        sts =
        _VD_SEND_MY( NDmacro.ACreturn_foot( msg, "geom", &gmId, NULL, NULL ));

        if( gmId.objid != NULL_OBJID ){
		IGRint 		count, cnt1, i;
		struct GRid	objects;

		sts = om$send (msg = message GRconnector.GRdisconn (msg,&myObj),
                   targetid = gmId.objid,
                   targetos = gmId.osnum);
		__CheckRC( sts, *msg, "GRconnector.GRdisconn", wrapup ) ;

		sts = om$send( msg = message GRowner.GRget_number_components( 
					msg, &count ),
				targetid = gmId.objid,
				targetos = gmId.osnum);
            	__CheckRC( sts,*msg,"GRowner.GRget_number_components",wrapup );
 
            	for(i=count-1; i>=0; i--) {
                	sts = om$send ( msg = message GRowner.GRget_components (
                                                        msg,
                                                        myEnv,
                                                        &objects,
                                                        1,
                                                        &cnt1,
                                                        i,
                                                        i ),
				targetid = gmId.objid,
                                targetos = gmId.osnum );
                if(!(sts&1)) break;
 
                sts = om$send(  msg = message GRconnector.GRdisconn(msg,&gmId),
				targetid = objects.objid,
                                targetos = objects.osnum);
            	__CheckRC( sts, *msg, "GRowner.GRdisconn", wrapup );
 
            }
	}

	/*
	 * Delete the draw object.
	 */

	sts = om$send(	msg	= message GRgraphics.GRdelete( msg, myEnv ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup ) ;

	/*
	 * Delete the VDdrwGm.
	 */
	sts = om$send(	msg	= message GRgraphics.GRdelete( msg, myEnv ),
			targetid=  gmId.objid,
			targetos = gmId.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup ) ;

	wrapup :
		End
		return sts ;

} /* method GRdrop */
/*----------------------------------------------------------------------------*/

end implementation VDdrwObj ;
