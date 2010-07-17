/*
	I/STRUCT
    10/25/95	tlb		EMS 3.2: change cs.h to grcoordsys.h
    2/21/96	Raju		Implementation of p_macro attribute
*/
class implementation ACconst ;

#include <string.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#define GRint	IGRint
#define GRchar	IGRchar
#include "GRprims.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsconstrctcs.h"
#include "vsexpvalue.h"
#include "vsstrngproto.h"
#include "vsRDBproto.h"

extern struct GRid	NULL_GRID ;
extern OMuword		OPP_GRgencs_class_id,
			OPP_ACdb_info_class_id,
			OPP_ACconst_class_id ;
/*----------------------------------------------------------------------------*/
long VScnstAGsrcCS( msg, matrix, CSenv, CSid )

long		*msg ;
IGRmatrix	matrix ;
struct GRmd_env	*CSenv ;
struct GRid	*CSid ; {

	long			sts ;
	struct IGRlbsys		geometry ;
	struct GRcs_construct	args ;
	struct GRvg_construct	cst ;
	struct IGRdisplay	dsp ;
	struct GRid		GRcsId ;
	OM_S_OBJID		saveId ;

	CSid->objid = GRcsId.objid = NULL_OBJID ;

	/*
	 * CS is wanted non-locatable, non-displayable.
	 */
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= CSenv,
				Geometry	= &geometry,
				Properties	= 0,
				Class_attr	= &args,
				Level		= 1,
				Display		= &dsp,
				Cnst_list	= cst ) ;
	dsp.color	= 1 ;
	dsp.weight	= 0 ;
	dsp.style	= 0 ;

	/*
	 * Do not put object in the R-tree.
	 */
	saveId		= CSenv->_MD_ID ;
	CSenv->_MD_ID	= NULL_OBJID ;

	sts = VSconstructCS( msg, matrix, &cst, &GRcsId ) ;

	CSenv->_MD_ID = saveId ;

	__CheckRC( sts, *msg, "VSconstructCS", wrapup ) ;

	sts = as$make_source(	go_grid	= GRcsId,
				as_os	= CSenv->_MD_OS,
				as_grid	= CSid ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids = &GRcsId, theEnv = CSenv ) ;
		}
		return sts ;

} /* VScnstAGsrcCS */
/*----------------------------------------------------------------------------*/
long VSloadParametricPart( msg, errStr, family, part, material, dir_name,
				partGRid )
long		*msg ;
char   		*errStr,
		*family,
		*part,
		*material,
		*dir_name ;
struct GRid	*partGRid ; {

	long			sts,
				MSG ;
	struct GRmd_env 	actEnv ;
	int			i,
				rc,
				count				= 0,
				changedGroup			= FALSE ;
	IGRmatrix		CSmx ;
	double			pmValues[VS_K_MAX_PARMS] ;
	struct GRid		parents[1+VS_K_MAX_PARMS] ;
	struct ACdb_info	db_info ;  
	char			searchCriteria[VS_K_MAX_CHARS],
				partType[2],
				**list = NULL,
				macLib[DI_PATH_MAX],
				*pmNames[VS_K_MAX_PARMS],
				pathname[DI_PATH_MAX],
				macDefFullName[DI_PATH_MAX],
				*p,
				saveChar,
				macro_name[VS_K_MAX_CHARS];

	if( errStr ) *errStr = '\0' ;

	i = sizeof actEnv ;

	gr$get_module_env(	msg	= &MSG,
				sizbuf	= &i,
				buffer	= &actEnv,
				nret	= &rc ) ;

	partGRid->objid = NULL_OBJID ;
	partGRid->osnum = actEnv._MD_OS ;

	VSsetGRids( actEnv._MD_OS, VS_K_MAX_PARMS + 1, parents ) ;

	MSG	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	/*
	 * Find if not already loaded ...
	 */
	di$translate(  	objname   = dir_name,
        	       	p_objid   = &partGRid->objid,
		    	osnum     = actEnv._MD_OS ) ;

	if( !IF_NULL_OBJID( partGRid->objid ) ) {

		partGRid->osnum = actEnv._MD_OS ;
		*msg = MSSUCC ; goto wrapup ;
	}

	/*
	 * Find the type of the part (parametric/graphic,etc.) :
	 *
	 * SELECT	p_parttype
	 * FROM		<family>
	 * WHERE		n_itemname = '<part>'
	 *		AND	n_itemrev  = '<material>'
	 */
	sprintf( searchCriteria, "%s='%s' AND %s='%s'",
		 PDU_PARTID_ATTR, part, PDU_REVISION_ATTR, material ) ;

	sts = vs$RISquery(	table	= family,
				select	= PDU_PARTTYPE_ATTR,
				where	= searchCriteria,
				p_count	= &count,
				p_list	= &list ) ;
	if( !sts ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyTypFailed,
					type	= "%s",
					var	= `part`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	} else if( !count ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoPartType,
					type	= "%s",
					var	= `part`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}
	partType[0] = *list[0] ; partType[1] = '\0' ;

	VSfreeList( count, list ) ; count = 0 ; list = NULL ;

	if( partType[0] != 'P' ) {
		/*
		 * Not a parametric part. Just construct a db-info.
		 */
		sts = om$construct(	classid	= OPP_ACdb_info_class_id,
					osnum	= actEnv._MD_OS,
					p_objid	= &partGRid->objid ) ;
		if( !( sts & 1 ) ) goto wrapup ;

		*msg = MSSUCC ;
		goto DB_INFO ;
		
	}

	/*
	 * Get parametric part data.
	 */
	vs$getPpartData(	msg	= msg,
				errStr	= errStr,
				family	= family,
				material= material,
				part	= part,
				size	= VS_K_MAX_PARMS,
				p_count	= &count,
				pmNames	= pmNames,
				pmValues= pmValues,
				file	= macLib ) ;
	if( ! ( *msg & 1 ) ) {
		goto wrapup ;
	}

	/*
	 * Now it is success as far as the Data Base is concerned...
	 */
	*msg = MSSUCC ;

	/*
	 * Create co-ordinate system, will be parent #0.
	 */
	MAidmx( &MSG, CSmx ) ;
	sts = VScnstAGsrcCS( &MSG, CSmx, &actEnv, parents + 0 ) ;
	if( !( sts & 1 & MSG ) ) goto wrapup ;

	for( i = 0 ; i < count ; i++ ) {
		/*
		 * Create expression with no name ( "" ).
		 */
		sts = VScreateExp(	"",
					pmValues[i],
					actEnv._MD_OS,
					&parents[i+1].objid ) ;
		if( !( sts & 1 ) ) goto wrapup ;

        }

	/*
	 * Now place macro occurrence.
	 */

	/*
	 * get macro_name from p_macro attribute of the part
	 */
	sts = VSgetMacroNameFromPmacro( family, material, part, macro_name );
	if ( !(sts&1) )
	{
	   printf("%s[%d] : Error getting macro_name for the part\n",
		  __FILE__, __LINE__ );
	   *msg = MSFAIL;
	   goto wrapup;
	}

	VSgetMacDefFullName( macLib, macro_name, macDefFullName ) ;

	sts = om$construct(	classid	= OPP_ACconst_class_id,
				osnum	= actEnv._MD_OS,
				p_objid = &partGRid->objid ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message ACncpx.ACmplace(
							&rc,
							AChdr_norange,
							TRUE,
							macDefFullName,
							count + 1, 
							parents,
							&actEnv ) ,
			senderid= partGRid->objid,
			targetid= partGRid->objid,
			targetos= partGRid->osnum ) ;
	MSG = rc ? MSSUCC : MSFAIL ;
	if( !( sts & 1 & MSG ) ) {
		goto wrapup ;
	}

	DB_INFO :
	/*
	 * Add or create db_info.
	 */
	strcpy( db_info.catalog , family	) ; 
	strcpy( db_info.part_num, part		) ; 
	strcpy( db_info.revision, material	) ; 
	strcpy( db_info.usage   , "..."		) ;
	db_info.serial_no = 0 ; 
	db_info.quantity  = 0 ; 

	sts = om$send(	msg	= message ACdb_info.ACset_db_info(
							&MSG, &db_info ),
			senderid= partGRid->objid,
			targetid= partGRid->objid,
			targetos= partGRid->osnum ) ;

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif
	changedGroup = TRUE ;

	/*
	 * Create directories where name of (parametric) part is to be stored.
	 * Beware that to have di$mkpath make directories but not do a
	 * di$add_name at the end, the pathname input to it must end with the
	 * directory separator.
	 */
	di$give_pathname(	osnum	= actEnv._MD_OS,
				pathname= pathname ) ;
	sts = di$strcat(	to	= pathname,
				from	= dir_name ) ;
	if( !( sts & 1 ) ) {
		/*
		 * Resulting name is way too long !
		 */
		 *pathname = '\0' ;
		 goto wrapup ;
	}

	p = strrchr( pathname, DIR_G_car_dir ) ;
	if( !p ) {
		/* Error !*/
		MSG = MSFAIL ; goto wrapup ;
	} else {
		saveChar	= p[1] ;
		p[1]		= '\0' ;
	}

	sts = di$mkpath( pathname = pathname ) ;
	if( !( sts & 1 ) && sts != DIR_E_DIR_DUP ) {
		di$report_error( sts = sts ) ;
		goto wrapup ;
	}

	p[1] = saveChar ;

	if( partType[0] == 'P' ) {
		/*
		 * Object is a macro occurrence: use GRputname.
		 */
		sts = om$send(	msg	= message GRgraphics.GRputname(
							 &MSG, pathname ),
				senderid=partGRid->objid,
				targetid=partGRid->objid,
				targetos=partGRid->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;
	} else {
		/*
		 * Object is a db-info: use di$add_name.
		 */
		sts = di$add_name(	objname	= pathname,
					objid	= partGRid->objid,
					osnum	= partGRid->osnum ) ;
		__CheckRC( sts, 1, "di$add_name", wrapup ) ;
	}


	wrapup :

	if( !( sts & 1 & MSG ) ) {
		/*
		 * Clean up : delete macro occurrence, CS, expressions ;
		 */
		if( partType[0] == 'P' ) {
			vs$bulk_delete(	grids	= partGRid,
					theEnv	= &actEnv ) ;
			vs$bulk_delete(	grids	= parents + 0,
					theEnv = &actEnv ) ;

			for( i = 1 ; i < count + 1 ; i++ ) {
				if( !IF_NULL_OBJID( parents[i].objid ) ) {
					om$send(msg	= message NDnode.NDdelete(
								&actEnv ),
						senderid= parents[i].objid,
						targetid= parents[i].objid,
						targetos= parents[i].osnum ) ;
				}
			}
		} else {
			if( !IF_NULL_OBJID( partGRid->objid ) ) {
				if( *pathname ) di$rm_name( regexp = pathname );

				om$send(msg	= message Root.delete( 0 ),
					senderid= parents[i].objid,
					targetid= parents[i].objid,
					targetos= parents[i].osnum ) ;
			}
		}
		*msg = MSFAIL ;
	}
	if( changedGroup ) {
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
		gr$cg( groupname = "-" ) ;
#endif
	}

	return *msg & 1 ;

} /* VSloadParametricPart */
/*----------------------------------------------------------------------------*/

end implementation ACconst ;
