/* $Id: VSmbgetsolbm.I,v 1.1.1.1 2001/01/04 21:10:12 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSmbgetsolbm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmbgetsolbm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/12/08  10:48:22  pinnacle
# Replaced: vsbeam/VSmbgetsolbm.I for:  by manoj for struct
#
# Revision 1.1  1997/10/06  09:28:32  pinnacle
# Created: vsbeam/VSmbgetsolbm.I by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/
/*
	I/STRUCT
*/
/*
	Abstract
	Gets the solid from the beam name for modified beams.
	If the beam is not in detailed rep then a computaion
	od the object in detail rep is done to evaluate the 
	exact mass props..
*/
class implementation VSmodBeam;	

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
#include	"ndmacros.h"
#include 	"vsmiscmacros.h"
#include        "vsdbgmacros.h"

method  VSgetSolidBeam ( IGRlong			*msg ;
			 struct GRmd_env		*bmEnv ;
			 struct GRid			*solidBeam )
{
	long 		sts;
	struct GRid	segment ;	/* Beam segment			*/
        VSdspRep        myRep ;         /* My display representation    */
	int		chgRep = FALSE;


	sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &myRep ),
                        targetid= my_id ) ;
        __CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

/*
	if( !(myRep & AC_3D_REP) )	{
		sts = om$send(  msg     = message ACncpx.ACset_NV_rep(
							AC_3D_REP,
							bmEnv ),
				targetid = my_id );
		nd$exec_batch() ;
		chgRep = TRUE ;
	}
*/
	if( !(myRep & VS_m_3dWFillet) )	{
		sts = om$send(  msg     = message ACncpx.ACset_NV_rep(
							VS_m_3dWFillet,
							bmEnv ),
				targetid = my_id );
		nd$exec_batch() ;
		chgRep = TRUE ;
	}

	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                                        msg,
                                                        VS_K_bmGrCmpName,
							&segment ,
                                                        NULL, NULL ),
                                targetid= my_id ) ;
                *msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	solidBeam->osnum = segment.osnum ;
	sts = om$send(  msg     = message GRgraphics.GRcopy(
                                                        msg,
                                                        bmEnv,
                                                        bmEnv,
                                                        &solidBeam->objid ),
                                targetid= segment.objid,
                                targetos= segment.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

	if( chgRep ) {
		sts = om$send(  msg     = message ACncpx.ACset_NV_rep(
						myRep ,
						bmEnv ),
				targetid = my_id );
		nd$exec_batch() ;
	}


wrapup :

	return (sts & *msg & 1);
}

end implementation VSmodBeam;
