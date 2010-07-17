/*
	I/STRUCT
*/ 
class implementation VSrflPlate ;

#include "OMmacros.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

from  ACpretend import ACpconnect ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					count ;
			struct GRid	list[] ;
			struct GRmd_env	*myEnv ;
			int		*fcount ;
			struct GRid 	*feet_list ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	parentPlate ;	/* Parent plate		*/
	int			placement,	/* TRUE/FALSE		*/
				parentHere,	/* TRUE/FALSE		*/
				cnt ;
	struct GRid		myUsrAttr,	/* My user attr.	*/
				myColl,		/* My private attr.	*/
				assoc,		/* Put on surface      	*/
				copy,		/* Copy of parent's sf.	*/
				computeList[3] ;

        SetProc( VSrflPlate_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

	placement = purpose & VS_K_InitialPlacement ;

	copy.objid = NULL_OBJID ;

	/*
	 * This object may have 2 or 3 parents :
	 * #0	: parent plate which is in a reference file, actually it is not
	 *        the plate itself but an ACpretendin.
	 * #1	: private attibutes in same file as this object.
	 * #2	: user attributes in same file as this object (optional).
	 *
	 * At placement we have count=1 (we had private attributes and user 
	 * attributes -if any- ) in this method.
	 * At recompute we have count=2 or 3.
	 */
	if( !count ) vs$inv_arg() ;

	/*
	 * Since parent #0 is an ACpretendin (in the same file as me) pointing
	 * to parent plate in the reference file, get the plate. If the
	 * reference file is not attached, the following call will fail.
	 */
	sts = VSgetVirtualInfo( msg, list + 0,
				&parentPlate.mod_env, &parentPlate._grid ) ;
	if( !( sts & 1 & *msg ) ) {
		/*
		 * Reference file not attached: at placement, this is an error
		 * at recompute, do nothing.
		 */
		if( placement ) {
			 vs$inv_arg() ;
		} else {
			parentHere = FALSE ;
		}
	} else {
		parentHere = TRUE ;

		__DBGpr_mat( "Parent's matrix", parentPlate._matrix ) ;
	
		sts = om$send(	msg	= message VSrflPlate.VSimportData(
						msg, placement, &parentPlate ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSrflPlate.VSimportData", wrapup ) ;
	}

	/*
	 * Now compute as a source plate, passing the base surface of your
	 * parent as your support surface, if parent is here, else your
	 * own surface foot. In fact we put some associativity on the
	 * surface (the invoked software expects an associative object),
	 * by connecting
	 * - a ACpretend (pointing to the surface) on the ACpretendin (pointing
	 *   to the plate in reference file ) if reference file is attached.
	 * - a pretend pointing to our own foot otherwise.
	 */

	if( !parentHere ) {
		struct GRid	moi ;

		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

		sts = VSconnectPretend( &moi, VS_K_plBotSfPath, &assoc ) ;
		__CheckRC( sts, 1, "VSconnectPretend", wrapup ) ;

#ifdef vsDEBUG
	printf( "\tConnected pretend" ) ; ShowObj( &assoc ) ;
#endif
	} else {
		struct GRid	botSfId ;
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&botSfId,
							NULL,
							NULL ),
				targetid= parentPlate._objid,
				targetos= parentPlate._osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = vs$grCopy(	msg	= msg,
					frEnv	= &parentPlate.mod_env,
					frObj	= &botSfId,
					toEnv	= myEnv,
					toObj	= &copy ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		sts = as$make_source(	go_grid	= copy,
					mod_env	= myEnv,
					as_os	= OM_Gw_current_OS,
					as_grid	= &assoc ) ;
		__CheckRC( sts, 1, "as$make_source", wrapup ) ;

	}
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &myColl ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	om$send(msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, &myUsrAttr ),
		targetid= my_id ) ;

	cnt = 0 ;
	computeList[cnt++] = assoc ;
	computeList[cnt++] = myColl ;
	if( !IF_NULL_OBJID( myUsrAttr.objid ) ) {
		computeList[cnt++] = myUsrAttr ;
	}
	sts = om$send(	msg	= message VSsrcPlate.ACconstruct_feet(
							msg,
							purpose,
							cnt,
							computeList,
							myEnv,
							fcount,
							feet_list ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSsrcPlate.ACconstruct_feet", wrapup ) ;
				
        __DBGpr_obj( "Foot `plate'", feet_list[0] ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

        wrapup :
		vs$bulk_delete(	grids	= &copy,
				theEnv	= myEnv ) ;
        	End
                return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/
int VSconnectPretend( macroOcc, footName, pretend )

char		*footName ;
struct GRid	*macroOcc,
		*pretend ; {

	long	sts ;
	extern OMuword	OPP_ACpretend_class_id ;

	pretend->objid = NULL_OBJID ;
	sts = om$construct(	classid = OPP_ACpretend_class_id,
				osnum	= macroOcc->osnum,
				p_objid	= &pretend->objid ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	pretend->osnum = macroOcc->osnum ;

	sts = om$send(	msg	= message ACpretend.ACpconnect( 0,
								*macroOcc,
								footName ),
			senderid= NULL_OBJID,
			targetid= pretend->objid,
			targetos= pretend->osnum ) ;
	wrapup :
		return sts ;

} /* VSconnectPretend */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;
