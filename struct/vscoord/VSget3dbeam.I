/* $Id: VSget3dbeam.I,v 1.1.1.1 2001/01/04 21:10:31 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vscoord/VSget3dbeam.I
 *
 * Description:	Helper for cs by 2 elem
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSget3dbeam.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/11/19  16:39:02  pinnacle
# TR179702163
#
# Revision 1.2  1997/06/16  15:33:48  pinnacle
# TR179701071
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      06/16/97   ah           Added Header
 *      06/16/97   ah           TR179701071 Checkin
 *	11/19/97   ah		TR179702163 Added vscoordproto.h
 *************************************************************************/

class implementation	VSsrcBeam ;

#include "VDmaster.h"

#include "ACdb_info.h"
#include "ACcheckin.h"
#include "vsglobalmsg.h"
#include "vsattr.h"
#include "vsglobals.h"
#include "vssectiondef.h"
#include "vsbeam.h"
#include "vsbeamdef.h"
#include "vsbeammacros.h"
#include "vsoptdef.h"
#include "vsAPImacros.h"
#include "vsdbgmacros.h"

#include "vscoordproto.h"

/*	
 * Given a beam ( fromBeam ) in any representaion along with its
 * Environment( bmEnv ), this function is going to result in mybeam
 * in Detailed Representation with all the parameters being copied
 * from the fromBeam
 */
	
long VSgetDetailedRepBeam ( 	long		*msg,
				struct GRmd_env	*bmEnv,
				struct GRid 	*fromBeam ,
				struct GRid	*myBeam )
{
	long			sts;
	VSpartAttr      	attr ;
	VSbeamAttr      	info ;
	struct GRobj_env        surface, axis ;

	struct GRid		inputId[2];
	struct GRmd_env		inputEnv[2];

	attr.Iwant      = VS_m_All ;
        attr.specific   = (void *) &info ;

	/*
	 * Get the parent[0] , Support Surface of the beam
	 */
	sts = om$send ( msg =      message VSsrcBeam.VSgetSupportSf(
                                                                msg,
                                                                bmEnv,
                                                                &surface ),
			senderid = fromBeam->objid,
                        targetid = fromBeam->objid,
			targetos = fromBeam->osnum );
        __CheckRC( sts, *msg, "VSsrcBeam.VSgetSupportSf", wrapup ) ;

	/*
	 * Get the parent[1] , Support Axis of the beam
	 */	 
        sts = om$send ( msg =           message VSsrcBeam.VSgetSupportAxis(
                                                                msg,
                                                                bmEnv,
                                                                &axis ),
			senderid = fromBeam->objid,
                        targetid = fromBeam->objid,
			targetos = fromBeam->osnum );

        __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	inputId[0] = surface.obj_id ;
	inputId[1] = axis.obj_id ;

	inputEnv[0] = surface.mod_env;
	inputEnv[1] = axis.mod_env;
	
	/*
	 * Get the attributes of the given beam 
	 */
	sts = om$send( 	msg      = message GRvg.GRgetattr( 
							msg, 
							(char *) &attr ),
			senderid = fromBeam->objid,
			targetid = fromBeam->objid,
			targetos = fromBeam->osnum );
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * Place the beam wih all the attributers of the given beam
	 * but in Detailed Representation
	 */
	sts = vs$place_beam (   msg               = msg,
                              	inputId           = inputId,
                              	inputEnv          = inputEnv,
                              	representation    = AC_3D_REP,
				basename          = "S",
				matType		  = attr.info.material,
 				matGrade	  = attr.info.grade,
				partFam		  = attr.info.family,
				partNum		  = attr.info.partNum,
				fireProofing	  = attr.info.fpthickness,
				xOffset		  = info.xoff,
				yOffset		  = info.yoff,
				rotAngle	  = info.rotat,
				cardPnt		  = info.card,
				symmetry	  = info.sym,
				displayFlag	  = FALSE,
                              	beamId            = myBeam ) ;

        __CheckRC( sts, *msg, "vs$place_beam", wrapup ) ;

wrapup :
	return ( sts & *msg & 1);

}

end implementation  VSsrcBeam ;			
		   

