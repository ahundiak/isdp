/* $Id: VSgetsolbeam.I,v 1.1.1.1 2001/01/04 21:10:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/ 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSgetsolbeam.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.5  1997/03/28  09:32:08  pinnacle
# Replaced: vsbeam/VSgetsolbeam.I for:  by svkadamb for struct
#
# Revision 1.4  1997/03/13  09:53:52  pinnacle
# Replaced: vsbeam/VSgetsolbeam.I for:  by svkadamb for struct
#
# Revision 1.3  1997/02/25  20:14:52  pinnacle
# Replaced: vsbeam/VSgetsolbeam.I for:  by mdong for struct
#
# Revision 1.2  1997/02/25  19:19:24  pinnacle
# Replaced: vsbeam/VSgetsolbeam.I for:  by mdong for struct
#
# Revision 1.1  1996/03/04  12:37:52  pinnacle
# Created: vsbeam/VSgetsolbeam.I by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/
/*
	I/STRUCT
*/
/*
Abstract
        Constructs the solid beam in filleted representation. If fails in
        filleted representation then constructs the beam in 3D rep.
        The message must sent to an already existing beam for getting its
        solid in filleted representation.

*/
class implementation VSsrcBeam;	

#include        "OMprimitives.h"
#include 	"EMSmsgdef.h"
#include 	"igetypedef.h"
#include 	"igrtypedef.h"
#include 	"igrdef.h"
#include 	"igrdp.h"
#include 	"godef.h"
#include 	"nddef.h"
#include        "grdpbdef.h"
#include 	"grdpbmacros.h"
#include 	"vsmiscmacros.h"
#include        "vsdbgmacros.h"

extern OMuword	OPP_VSsrcBeam_class_id ; 

method  VSgetSolidBeam ( IGRlong			*msg ;
			 struct GRmd_env		*bmEnv ;
			 struct GRid			*solidBeam )
{

	long			numberOfBytes,BytesReceived; 
	IGRlong			sts ;
	struct GRid		xsId;
	struct GRid		myBeam;
	struct GRobj_env 	surface, axis ;
	struct GRmd_env		modEnv;  
	struct GRvg_construct	cst;
	struct GRsymbology      mySymb ;       

	/*
	 * Get the support Surface
	 */
	sts = om$send ( msg = 		message VSsrcBeam.VSgetSupportSf(
								msg,
								bmEnv,
								&surface ),
	                targetid = my_id );
        __CheckRC( sts, *msg, "VSsrcBeam.VSgetSupportSf", wrapup ) ; 
	/*
	 * Get the Beam Axis
	 */
	sts = om$send ( msg =           message VSbeam.VSgetSupportAxis(
								msg,
                                                                bmEnv,
                                                                &axis ),
                        targetid = my_id );
        __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ; 
	/*
	 * Get Current Module Environment
	 */
	/*	commented in TR179603451 by Ming Dong.  */
	numberOfBytes = sizeof( struct GRmd_env );
	gr$get_module_env  (	msg     = msg,
        	                sizbuf  = &numberOfBytes,
                         	buffer  = &modEnv,
                         	nret    = &BytesReceived );


	sts = om$construct(	classid = OPP_VSsrcBeam_class_id,
				osnum 	= OM_Gw_current_OS,
				p_objid	= &myBeam.objid );
	 myBeam.osnum = OM_Gw_current_OS;

	/*
 	 * Fill construction list.
         */
        sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb ),
			targetid = my_id );
        __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ; 

        vs$fill_cnst_list(      Env_info        = bmEnv,
                                Display         = &mySymb.display_attr,
                                Level           = mySymb.level,
                                Cnst_list       = cst ) ;
	/*
	 * Extract the profile of the beam in Fillet representation
	 */
	sts = om$send ( msg = 	message VSbeam.VSextractProfile( 	
								msg,
                                				bmEnv,
                                				&surface,
                                                    		&axis,
                                				0.0,
								&cst,
								VS_m_3dWFillet,
                                				&xsId ),
                        targetid = my_id );
	if( !(sts & *msg & 1 ) )
	{
		/*
		 * If failed to extract the profile in  filleted represenation
		 * try with Detailed represenation
		 */
		sts = om$send ( msg = 	message VSbeam.VSextractProfile( 	
								msg,
                                				bmEnv,
                                				&surface,
                                                    		&axis,
                                				0.0,
								&cst,
								AC_3D_REP,
                                				&xsId ),
                        targetid = my_id );
        __CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ; 

	}

	/*
	 * Construct solid representation of beam with the extracted 
	 * cross section
	 */
	sts = om$send( msg      = message VSsrcBeam.VScnst_solid_rep(
                                                        msg,
                                                        bmEnv,
                                                        &cst,
                                                        &surface,
                                                        &axis,
                                                        &xsId,
                                                        solidBeam ),
		targetid = myBeam.objid,
		targetos = myBeam.osnum );
        __CheckRC( sts, *msg, "VSbeam.VScnst_solid_rep", wrapup ) ; 

wrapup :
	if ( xsId.objid != NULL_OBJID ) {
		sts = om$send ( msg = message GRgraphics.GRdelete (
								msg,
								bmEnv ),
				targetid = xsId.objid,
				targetos = xsId.osnum );
        }
	if ( myBeam.objid != NULL_OBJID ) {
		sts = om$send ( msg = message GRgraphics.GRdelete (
								msg,
								&modEnv ),
				targetid = myBeam.objid,
				targetos = myBeam.osnum );
	}
	return (sts & *msg & 1);
}
end implementation VSsrcBeam;
