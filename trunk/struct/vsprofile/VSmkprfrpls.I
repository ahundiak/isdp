/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include <string.h>
#include "EMSutlmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#define GRint	IGRint
#define GRchar	IGRchar
#include "GRprims.h"
#include "acrepdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsconstrctcs.h"

extern OMuword		OPP_VSproffrplts_class_id ;
/*----------------------------------------------------------------------------*/
void VSdelCmpProfile( env, id ) struct GRmd_env *env ; struct GRid *id ; {

	long		msg ;
	struct GRid	csId ;
	int		ACrc ;
	GRname		name ;
	OM_S_OBJID	mdid ;

	om$send(msg	= message ACcpx.ACfind_temp_obj(
					&ACrc, VS_K_ppParentCS, &csId ),
		senderid= id->objid,
		targetid= id->objid,
		targetos= id->osnum ) ;

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif
	om$send(msg	= message GRgraphics.GRgetname( &msg, name ),
		senderid= id->objid,
		targetid= id->objid,
		targetos= id->osnum ) ;
	DIunlink_dir( name, TRUE ) ;

	mdid		= env->_MD_ID ;
	env->_MD_ID	= NULL_OBJID ;
	vs$bulk_delete(	grids	= id,
			theEnv	= env ) ;

	env->_MD_ID	= mdid ;
	vs$bulk_delete(	grids	= &csId,
			theEnv	= env ) ;
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = "-" ) ;
#endif

} /* VSdelCmpProfile */
/*----------------------------------------------------------------------------*/
void VSmkProfilePathName( osnum, material, family, partName, pathName )

OMuword		osnum ;
char		*material,
		*family,
		*partName,
		*pathName ; {

	GRname		startDir,
			prflFam ;

	di$give_pathname( osnum	= osnum, pathname = startDir ) ;
	__DBGpr_str( "startDir", startDir ) ;

	/*
	 * Make profile family from plates' family.
	 */
	sprintf( prflFam, "#%s", family ) ;

	DIstmcpy(	pathName,
			startDir,
			"struct",
			material,
			prflFam,
			partName,
			NULL ) ;

} /* VSmkProfilePathName */
/*----------------------------------------------------------------------------*/
int VSdoesCmpPrflExist( osnum, material, family, partName )

OMuword		osnum ;
char		*material,
		*family,
		*partName ; {

	long		sts ;
	GRname		pathName ;
	OM_S_OBJID	objid ;

	VSmkProfilePathName( osnum, material, family, partName, pathName ) ;

	sts = di$translate(	objname	= pathName,
				p_objid	= &objid ) ;
#ifdef vsDEBUG
	di$report_error( sts = sts, comment = pathName ) ;
#endif

	return sts & 1 ? TRUE : FALSE ;

} /* VSdoesCmpPrflExist */
/*----------------------------------------------------------------------------*/
long VSmkProfileFrPlDefs( msg, plCount, plDefs, cnxCount, plCnxs, cst, type,
			  thicknesses, profile )

long			*msg ;
int			plCount,
			cnxCount ;
VSxsPlateDef		plDefs[] ;
VSxsPlConn		plCnxs[] ;
struct GRvg_construct	*cst ;
VSxsPlType		*type ;
char			*thicknesses[] ;
struct GRid		*profile ; {

	long			sts ;		/* OM return code	*/
	int			i ;		/* Loop index		*/
	struct VScnst_list	vsargs ;	/* Construction args	*/
	VSxsFrPlsAttr		attr ;		/* Specific attributes	*/
	char			*p ;
	IGRmatrix		matrix ;	/* Of coordinate system	*/
	struct GRobj_env	CS ;
	GRname			name ;		/* Of created profile	*/
	struct GRvg_construct	locCst ;
	int			chgGrp,
				rmRng ;

	chgGrp = FALSE ;

	vsargs.feature_att	= (char *) &attr ;
	vsargs.representation	= AC_NO_REP ;

	attr.plCount	= plCount ;
	attr.cnxCount	= cnxCount ;
	attr.plDefs	= plDefs ;
	attr.plCnxs	= plCnxs ;

	vsargs.parent_list	= &CS ;
	vsargs.parent_count	= 1 ;

	for( i = 0 ; i < plCount ; i++ ) {
		attr.thicknesses[i] = thicknesses[i] ;
		__DBGpr_str( "Thk", thicknesses[i] ) ;
	}

	vs$fill_cnst_list(	Msg		= cst->msg,
				Env_info	= cst->env_info,
				Display		= cst->display,
				Level		= cst->level,
				Properties	= 0,
				Cnst_list	= locCst ) ;
	CS._objid = NULL_OBJID ;
	MAidmx( msg, matrix ) ;

	sts = VSconstructCS( msg, matrix, &locCst, &CS._grid ) ;
	__CheckRC( sts, *msg, "VSconstructCS", wrapup ) ;

	profile->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_VSproffrplts_class_id,
				osnum	= profile->osnum,
				p_objid	= &profile->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	VSmkProfilePathName(	profile->osnum,
				type->material,
				type->family,
				type->profileType,
				name ) ;

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif
	chgGrp = TRUE ;

	p = strrchr( name, DIR_G_car_dir ) ;
	p[1] = '\0' ;
	sts = di$mkpath( pathname = name ) ;
	if( !( sts & 1 ) && sts != DIR_E_DIR_DUP ) {
#ifdef vsDEBUG
		di$report_error( sts = sts, comment = "di$mkpath" ) ;
#endif
		vs$error( stsval = sts, msgval = EMS_E_DirName ) ;
	}
	p[1] = *type->profileType ;

	__DBGpr_str( "Name", name ) ;

	vs$fill_cnst_list(	Msg		= cst->msg,
				Env_info	= cst->env_info,
				Display		= cst->display,
				Level		= cst->level,
				Properties	= cst->properties,
				Name		= name,
				Class_attr	= &vsargs,
				Cnst_list	= locCst ) ;

	if( locCst.properties & GRNOT_IN_RTREE ) {
		locCst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
		rmRng = TRUE ;
	} else	rmRng = FALSE ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &locCst ),
			senderid= profile->objid,
			targetid= profile->objid,
			targetos= profile->osnum ) ;

	*msg = *cst->msg ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	if( rmRng ) {
		OM_S_CHANSELECT toCmps ;
		ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		             chan_selector = &toCmps ) ;
	
		om$send(msg	= message GRgraphics.GRremwrng(
							msg, cst->env_info ),
			senderid	= profile->objid,
			p_chanselect	= &toCmps,
			targetos	= profile->osnum ) ;
	}

	wrapup :
		if( chgGrp ) {
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
			gr$cg( groupname = "-" ) ;
#endif
		}
			

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	objenvs	= &CS ) ;
			profile->objid = NULL_OBJID ;
		}
		return sts ;

} /* VSmkProfileFrPlDefs */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

