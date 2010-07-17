/* $Id: VSpljoint.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSpljoint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSpljoint.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/20  15:59:50  pinnacle
# CR179800807
#
# Revision 1.2  1997/11/14  12:38:40  pinnacle
# Replaced: vsapis/VSpljoint.I for:  by svkadamb for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1997/03/13  11:14:36  pinnacle
# Replaced: vsapis/VSpljoint.I for:  by svkadamb for struct
#
# Revision 1.1  1996/02/20  23:45:32  pinnacle
# Created: ./vsapis/VSpljoint.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *	04/17/1998	Manoj 		CR 1798000807
 *                                      Facility to assign 
 *                                      1. Field weld 
 *					2. Weld Position 
 *                                      3. Shrinkage Ratio
 *
 ***************************************************************************/

class implementation VSjoint ;

#include <stdio.h>
#include <string.h>
#include "madef.h"
#include "exmacros.h"
#include "VDSsymb_def.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "VDScheckdef.h"
#include "vsattr.h"
#include "vsjoint.h"
#include "vswelddef.h"
#include "vsAPIwelddef.h"
#include "vsnamemacros.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsAPImacros.h" // CR 179800807
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

/*----------------------------------------------------------------------------*/
long VSplace_joint( 
long			*msg ,
struct GRid		elemId[2] ,
struct GRmd_env		elemEnv[2] ,
int			transtable ,
char			*directory ,
struct IGRdisplay	*display ,
short			level ,
int			weldCode ,
int			weldProcess ,
int			weldInfo ,
int			weldContour ,
int			weldSide ,
double			allowance ,
double			grooveAngle ,
double			pitch ,
double			lengthOfIncr ,
char			*usrSymbol ,
struct GRid		*UAid  ,
int 			fieldWeld,    //CR 179800807
int 			weldPosition, //CR 179800807
double 			shrinkage,    //CR 179800807
struct GRid		*jointId )
{


	/*
	 * This function is interfaced by macro 'vs$place_joint'.
	 */

	long			sts ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cstargs ;
	VSpartAttr		jnPart ;
	VSjointAttr		jointAttr ;
	struct GRobj_env	elements[2] ;
	char			loc_directory[DI_PATH_MAX] ;
	short			loc_level ;
	struct IGRdisplay	loc_display ;
	struct VDSsymb		symb ;
	int			isWritable,
				dirInModel ;
	char			*jnDir ;
	struct	ACdb_info	dbInfo ;

	SetProc( VSplace_joint ) ; Begin

	jointId->objid = NULL_OBJID ;

	__DBGpr_obj( "First element",  elemId[0] ) ;
	__DBGpr_obj( "Second element", elemId[1] ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * If we want to use the transTable, retrieve informations to place the
	 * joint.
	 */
	if( transtable ) {
		sts = vs$cnstDefaults( msg	= msg,
				       symb_id	= curEnv.md_id,
				       symb	= &symb,
				       matchKey = "joint",
				       matchId  = elemId +0,
				       path	= loc_directory,
				       level	= &loc_level,
				       display	= &loc_display ) ;

		__CheckRC( sts, *msg, "vs$cnstDefaults", wrapup ) ;

	} else {
		strncpy( loc_directory, directory, DI_PATH_MAX ) ;
		loc_level   = level ;
		loc_display = *display ;
	}

	/*
	 * Fill construction list.
	 */
 	vs$fill_cnst_list( Cnst_list	= cstargs,
			   Msg		= msg,
			   Env_info	= &curEnv,
			   Display	= &loc_display,
			   Level	= loc_level,
			   Class_attr	= &jnPart ) ;

	jnPart.specific	= (void *) &jointAttr ;
	jnPart.Iwant	= VS_m_All ;

	jointAttr.allowance	= allowance ;
	jointAttr.grooveAngle	= grooveAngle ;
	jointAttr.pitch		= pitch ;
	jointAttr.incrLength	= lengthOfIncr ;


	jointAttr.weldAttr.code	= weldCode ;
	jointAttr.weldAttr.process	= weldProcess ;
	jointAttr.weldAttr.info	= 0 ;
	jointAttr.weldAttr.side	= weldSide ;

	///Start CR 179800807	
	jointAttr.addWldAttr.position  = weldPosition;
	jointAttr.addWldAttr.fieldweld = fieldWeld;
	jointAttr.shrinkage	= shrinkage ;
	///End CR 179800807	

	switch( weldInfo ) {
		case VS_WI_No_No_No :
			jointAttr.weldAttr.info |= 0 ;
			break ;
		case VS_WI_Fw_No_No :
			jointAttr.weldAttr.info |= VS_m_wldFieldWeld ;
			break ;
		case VS_WI_No_Mt_No :
			jointAttr.weldAttr.info |= VS_m_wldMeltThru ;
			break ;
		case VS_WI_Fw_Mt_No :
			jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
						   VS_m_wldMeltThru  ;
			break ;
		case VS_WI_No_No_Wa :
			jointAttr.weldAttr.info |= VS_m_wldWeldAllAround ;
			break ;
		case VS_WI_Fw_No_Wa :
			jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
						   VS_m_wldWeldAllAround ;
			break ;
		case VS_WI_No_Mt_Wa :
			jointAttr.weldAttr.info |= VS_m_wldMeltThru	|
						   VS_m_wldWeldAllAround ;
			break ;
		case VS_WI_Fw_Mt_Wa :
			jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
						   VS_m_wldMeltThru	|
						   VS_m_wldWeldAllAround ;
			break ;
		default:
			break ;
	}

	switch( weldContour ) {
		case VS_WK_Flush :
			jointAttr.weldAttr.info |= VS_m_wldFlushContour ;
			break ;
		case VS_WK_Concave :
			jointAttr.weldAttr.info |= VS_m_wldConcaveContour ;
			break ;
		case VS_WK_Convex :
			jointAttr.weldAttr.info |= VS_m_wldConvexContour ;
			break ;
		default:
			break ;
	}

	if( usrSymbol )
		strncpy( jointAttr.usrSymbol, usrSymbol, VS_K_MAXUSRSYMSZ ) ;
	else
		jointAttr.usrSymbol[0] = '\0' ;

	if( !UAid )
		jnPart.Iwant	&= ~VS_m_UsrAttr ;
	else
		jnPart.usrAttr	= *UAid ;

	/*
	 * See if directory where joint will name itself is usable.
	 */
	vs$isDirUsable(	dirname	 = loc_directory,
			inModel	 = &dirInModel,
			writable = &isWritable ) ;

	jnDir = dirInModel && isWritable ? loc_directory : NULL ;

	/*
	 * Place joint.
	 */
	elements[0]._grid   = elemId[0] ;
	elements[0].mod_env = elemEnv[0] ;

	elements[1]._grid   = elemId[1] ;
	elements[1].mod_env = elemEnv[1] ;

	sts = om$send( msg	= message VSfeature.VSputJoint(
							msg,
							&elements[0].mod_env,
							elements + 1,
							NULL,
							AC_NO_REP, // not used
							&cstargs,
							jnDir,
							jointId ),
		       senderid = NULL_OBJID,
		       targetid = elements[0]._objid,
		       targetos = elements[0]._osnum ) ;

	__CheckRC( sts, *msg, "VSfeature.VSputJoint", wrapup ) ;

	__DBGpr_obj( "Constructed joint", *jointId ) ;

	/*
	 * Display joint.
	 */
	vs$bulk_display( grids	= jointId,
			 theEnv = &curEnv ) ;
	/* Put db info */
        dbInfo.quantity   = VD_CKIN_STRUCT_JNT_OBJ;
        sts = om$send(msg = message ACdb_info.ACset_db_info(msg,
                                                           &dbInfo),
		       	senderid = NULL_OBJID,
                        targetid = jointId->objid,
                        targetos = jointId->osnum);


	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( jointId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = jointId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VSplace_joint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
