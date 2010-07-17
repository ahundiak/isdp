/*
	I/STRUCT
*/
class implementation VSrflBeam ;

#include <string.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#define GRint  IGRint
#define GRchar IGRchar
#include "GRprims.h"
#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsrfldef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsaddmodattr.h"

extern void	VSmkProfilePathName() ;
extern OMuword	OPP_ACrg_collect_class_id ;

extern int	VSisBeamComposite() ;
extern long 	VSgetDataForAxisRegeneration();
extern long 	VSfindFindNameForRflElem();

from ACdiowner		import	ACcreate ;
/*----------------------------------------------------------------------------*/
method VSimportData( long *msg ; int placement ; struct GRobj_env *fromBeam ) {

	long			sts ;		/* OM return code	*/
	struct GRid		moi,		/* Who else ?		*/
				pDef,		/* Cached profile def.	*/
				copy ;		/* Of profile def.	*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSbeamAttr		myInfo ;	/* Some attributes	*/
	struct ACdb_info	dbInfo ;	/* Info for RDB 	*/
	GRname			faceName ;	/* Face to regenerate	*/
						/*  our supports	*/
	IGRvector		delta ; 	/* Translation from iso */
						/*  at u=0 to axis	*/
	int			changedGroup ;
	struct GRmd_env 	copyEnv ;

	changedGroup	= FALSE ;
	copy.objid	= NULL_OBJID ;

	moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

	__DBGpr_int( "Placement ?", placement ) ;

	/*
	 * At placement, take parent's representation and symbology.
	 */
	if( placement ) {
		VSdspRep		myRep ; /* My display repres.	*/
		struct GRsymbology	mySymb ;/* My symbology 	*/

		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

		__DBGpr_int( "My rep", myRep ) ;
		sts = om$send(	msg	= message ACncpx.ACput_NV_rep( myRep ),
				targetid= my_id ) ;

		sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb),
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

		sts = om$send(	msg	= message GRvg.GRputsymb( msg, &mySymb),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	}

	/*
	 * Set same database info as that of parent, parent beam may have been
	 * modified so as to be a composite beam, and composite beams perform
	 * their checkin as plates.
	 */
	om$send(msg	= message ACdb_info.ACget_db_info( msg, &dbInfo ),
		targetid= fromBeam->_objid,
		targetos= fromBeam->_osnum ) ;

	om$send(msg	= message ACdb_info.ACset_db_info( msg, &dbInfo ),
		targetid= my_id ) ;

	/*
	 * Get attributes of parents.
	 */
	myAttr.Iwant	= VS_m_All ;
	myAttr.specific = (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= fromBeam->_objid,
			targetos= fromBeam->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * NOTE: If parent has a collection of user attributes, it will be
	 * copied to the same Object Space as this object.
	 */
	if( IF_NULL_OBJID( myAttr.usrAttr.objid ) ) {
		myAttr.Iwant &= ~VS_m_UsrAttr ;
	}

	/*
	 * Now feed attributes to self.
	 */
	sts = om$send(	msg	= message GRvg.GRputattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

	/*
	 * If profile is composite, we must copy it from parent's OS.
	 */
	if( VSisBeamComposite( &moi ) ) {
		GRname		pathName ;
		struct GRid	previous ;

		__DBGpr_com( "Composite beam" ) ;

		/*
		 * Should delete previous one here ...
		 */
		sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
								msg, &pDef ),
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;
#ifdef vsDEBUG
	printf( "\tParent's cached profile" ) ; ShowObj( &pDef ) ;
#endif

		VSmkProfilePathName(	OM_Gw_current_OS,
					myAttr.info.material,
					/*
					 * Skip leading '#' since this function
					 * will put one.
					 */
					myAttr.info.family + 1,
					"",
					pathName ) ;
		__DBGpr_str( "Profile path", pathName ) ;

		gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
		changedGroup = TRUE ;

		*msg = di$mkpath( pathname = pathName ) ;
		if( !( *msg & 1 ) && *msg != DIR_E_DIR_DUP ) {
			__DBGpr_com( "di$mkpath FAILED\n" ) ;
			sts = OM_W_ABORT ; goto wrapup ;
		}

		copyEnv._MD_OS		= OM_Gw_current_OS ;
		copyEnv._MD_ID		= NULL_OBJID ;
		copyEnv._MATRIX_TYPE	= MAIDMX ;
		MAidmx( msg, copyEnv._MATRIX ) ;

		sts = vs$grCopy(	msg	= msg,
					frEnv	= &fromBeam->mod_env,
					frObj	= &pDef,
					toEnv	= &copyEnv,
					toObj	= &copy ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

#ifdef vsDEBUG
	printf( "\tCopy of composite profile" ) ; ShowObj( &copy ) ;
#endif
		di$strcat(	to	= pathName,
				from	= myAttr.info.partNum ) ;

		__DBGpr_str( "Profile pathname", pathName ) ;

		/*
		 * Was there a previous one here that goes by the same name ?
		 * If so get rid of it.
		 */
		sts = di$translate(	objname = pathName,
					p_objid = &previous.objid,
					p_osnum = &previous.osnum ) ;
		if( sts & 1 ) {
			__DBGpr_obj( "Previous", previous ) ;
			vs$bulk_delete( grids = &previous,
					theEnv= &copyEnv ) ;
		} else previous.objid = NULL_OBJID ;

		sts = om$send(	msg	= message GRgraphics.GRputname(
							 msg, pathName ),
				targetid= copy.objid,
				targetos= copy.osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;

		gr$cg( groupname = "-" ) ;
		changedGroup = FALSE ;
	}
	/*
	 * If profile is not composite, what follows will force the creation
	 * of a cached profile in your OS similar to that of parent's, if
	 * cached profile is not already here.
	 * It will also force the loading of RDB data ( material, grade, etc. )
	 * If profile is composite, we still need the material, grade, etc.
	 * which will also be loaded via the following message.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetProfileDef( msg, &pDef ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

#ifdef vsDEBUG
	printf( "\tRetrieved profile" ) ; ShowObj( &pDef ) ;
#endif

	/*
	 * Get the necessary data so as to regenerate your support surface and
	 * axis when parent is no longer here (ie. the reference file in which
	 * parent lives is not present).
	 */
	sts = VSgetDataForAxisRegeneration(	msg,
						&fromBeam->_grid,
						&fromBeam->mod_env,
						faceName,
						delta ) ;
	__CheckRC( sts, *msg, "VSgetDataForAxisRegeneration", wrapup ) ;
	/*
	 * Now store these data in your collection of user attributes.
	 */
	myAttr.Iwant = VS_m_UsrAttr ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	if( IF_NULL_OBJID( myAttr.usrAttr.objid ) ) {
		/*
		 * Create new user attributes.
		 */
		myAttr.usrAttr.osnum = OM_Gw_current_OS ;
		sts = om$construct(	classid = OPP_ACrg_collect_class_id,
					osnum	= myAttr.usrAttr.osnum,
					p_objid = &myAttr.usrAttr.objid ) ;
		if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

		sts = om$send(	msg	= message ACdiowner.ACcreate( msg, "" ),
				targetid= myAttr.usrAttr.objid,
				targetos= myAttr.usrAttr.osnum ) ;
		__CheckRC( sts, *msg, "ACdiowner.ACcreate", wrapup ) ;

		sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH, ND_DEL_NO_CH ),
				targetid= myAttr.usrAttr.objid,
				targetos= myAttr.usrAttr.osnum ) ;

		myAttr.Iwant = VS_m_UsrAttr ;
		sts = om$send(	msg	= message GRvg.GRputattr(
							msg, (char *) &myAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;
	}

	sts = VSaddOrModAttr( msg, &myAttr.usrAttr,
			      VS_K_rbFaceNameAttr, AC_ATTRIB_TEXT, faceName ) ;
	__CheckRC( sts, *msg, "VSaddOrModAttr", wrapup ) ;
	sts = VSaddOrModAttr( msg, &myAttr.usrAttr,
			      VS_K_rbDxAttr, AC_ATTRIB_DOUBLE, delta + 0 ) ;
	__CheckRC( sts, *msg, "VSaddOrModAttr", wrapup ) ;
	sts = VSaddOrModAttr( msg, &myAttr.usrAttr,
			      VS_K_rbDyAttr, AC_ATTRIB_DOUBLE, delta + 1 ) ;
	__CheckRC( sts, *msg, "VSaddOrModAttr", wrapup ) ;
	sts = VSaddOrModAttr( msg, &myAttr.usrAttr,
			      VS_K_rbDzAttr, AC_ATTRIB_DOUBLE, delta + 2 ) ;
	__CheckRC( sts, *msg, "VSaddOrModAttr", wrapup ) ;

	if( placement ) {
		sts = VSfindFindNameForRflElem( msg, &fromBeam->_grid, &moi ) ;
	}

	wrapup :
		if( changedGroup ) gr$cg( groupname = "-" ) ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids = &copy,
					theEnv= &copyEnv ) ;
		}

		return sts ;

} /* method VSimportData */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;
