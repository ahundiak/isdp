/* $Id: VSprccutouts.I,v 1.1.1.1 2001/01/04 21:10:22 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSprccutouts.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSprccutouts.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:10:22  cvs
 *  Initial import to CVS
 *
# Revision 1.3  2000/03/14  21:11:00  pinnacle
# Replaced: vsbtchctouts/VSprccutouts.I for:  by impd252 for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/14/00        adz          	TR179900127 Check Operand as Pretend.
 ***************************************************************************/

class implementation VSfeature ;

#include <stdlib.h>
#include <string.h>
#include "OMmacros.h"
#include "madef.h"
#include "exmacros.h"
#include "ms.h"
#include "msmacros.h"
#include "COmdef.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsbtchctsdef.h"
#include "vsstfnrdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "COm_option.h"
#include "GRfindcontex.h"
#include "vsgetchildrn.h"
#include "vsstrngproto.h"

#define VS_K_PROCESS_CUTOUTS	0
#define VS_K_TRANSMIGRATE	1

struct VS_s_statistics {
	int	*nbMacsFound,
		*nbSuccessfulOps ;
} ;
typedef struct VS_s_statistics STATISTICS ;

extern OMuword		OPP_VSfeature_class_id,
			OPP_VSbooBeam_class_id,
			OPP_VSholPlate_class_id,
			OPP_ACconst_class_id,
			OPP_ACpretend_class_id,
			OPP_EMSsolid_class_id,
			OPP_EMSsubbs_class_id,
			OPP_GRcurve_class_id,
			OPP_ACncpx_class_id ;
extern IGRboolean       IGEstop();
from	ACcpx_defn	import ACgive_name ;
from	ACpretend	import ACfind_parent ;
/*----------------------------------------------------------------------------*/
static int VShaveAlreadyBadMacroInList( list, macro )

char	*list,
	*macro ; {

	/*
	 * This funtion returns TRUE if given name of macro is inside the list
	 * of macros which have a bad operator output for cutout.
	 */
	char	*beg,
		*fin ;
	int	have = FALSE ;

	beg = fin = list ;
	while( fin = strchr( beg, ' ' ) ) {
		*fin = '\0' ;

		if( !strcmp( beg, macro ) ) {
			*fin = ' ' ;
			have = TRUE ;
			break ;
		}

		*fin = ' ' ;
		beg = fin + 1 ;
	}

	if( !have && !strcmp( beg, macro ) ) have = TRUE ;

	return have ;

} /* VShaveAlreadyBadMacroInList */
/*----------------------------------------------------------------------------*/
int VSkeepOperatorForCutout( msg, type, operatorId, operatorEnv )

long		*msg ;
unsigned long	type ;
struct GRid	*operatorId ;
struct GRmd_env *operatorEnv ; {

	/*
	 * This function returns TRUE if given operator is :
	 * - For a beam :
	 *	a solid.
	 *	a surface.
	 *	a closed planar curve.
	 *
	 * - For a plate :
	 *	not a sub class of ACncpx.
	 *
	 * Otherwise returns FALSE.
	 */
	long		sts ;		/* OM completion code.		      */
	int		keep = FALSE ;	/* TRUE / FALSE.		      */
	struct GRprops	operatorProps ; /* Properties of operator.	      */

	/*
	 * Beam.
	 */
	if( type & VS_m_BEAM ) {
		/*
		 * See if operator is a solid or a surface.
		 */
		if( vs$is_ancestry_valid( object  = operatorId,
					  classid = OPP_EMSsolid_class_id ) ||
		    vs$is_ancestry_valid( object  = operatorId,
					  classid = OPP_EMSsubbs_class_id ) ) {
			keep = TRUE ;
			goto wrapup ;
		}

		/*
		 * See if operator is a closed planar curve.
		 */
		if( vs$is_ancestry_valid( object  = operatorId,
					  classid = OPP_GRcurve_class_id ) ) {

			sts = om$send( msg	= message GRvg.GRgeomprops(
						     msg,
						     &operatorEnv->_MATRIX_TYPE,
						     operatorEnv->_MATRIX,
						     &operatorProps ),
				       senderid = operatorId->objid,
				       targetid = operatorId->objid,
				       targetos = operatorId->osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

			if( operatorProps.phy_closed	&&
			    operatorProps.planar	) {
				keep = TRUE ;
			}
		}
	}

	/*
	 * Plate.
	 */
	if( type & VS_m_PLATE ) {
		if( !vs$is_ancestry_valid( object  = operatorId,
					   classid = OPP_ACncpx_class_id ) ) {
			keep = TRUE ;
		}
	}

	*msg = MSSUCC ;

	wrapup :
		return keep ;

} /* VSkeepOperatorForCutout */
/*----------------------------------------------------------------------------*/
void VScutOutProcessing( feature, macCount, macNames, isMacValid, count, list )

struct GRid		*feature,
			list[] ;
int			macCount,
			**isMacValid,
			count ;
char			**macNames ; {

	long		sts,
			msg ;
	int		i,
			j,
			nchars,
			first ;
#define MAXCHRS 52
	char		buf[MS_MAX_MSG_LENGTH],
			*n ;
	GRname		name ;
	struct GRid	*oneMac ;
	extern char	DIR_G_car_dir ;

	sts = om$send(	msg	= message GRgraphics.GRgetname( &msg, name ),
			senderid= feature->objid,
			targetid= feature->objid,
			targetos= feature->osnum ) ;
	if( !( sts & 1 & msg ) || !*name ) {
		n = strcpy( name, "" ) ;
	} else {
		n = strrchr( name, DIR_G_car_dir ) ;
		n = n ? n + 1 : name ;
	}

	ex$message(	msgnumb = VS_gI_PrcsE1WithE2,
			type	= "%s%s",
			var	= `n, " "`,
			buff	= buf ) ;

	nchars = strlen( buf ) ;

	first = TRUE ;
	for( i = 0 ; i < macCount ; i++ ) {
		for( j = 0 ; j < count ; j++ ) {
			if( !isMacValid[i][j] ) continue ;

			oneMac = list + j ;
			sts = om$send(	msg	= message GRgraphics.GRgetname(
								&msg, name ),
					senderid= oneMac->objid,
					targetid= oneMac->objid,
					targetos= oneMac->osnum ) ;
			if( !( sts & 1 & msg ) || !*name ) {
				/*
				 * No name for macro occurrence, use name of
				 * macros definition.
				 */
				n = macNames[i] ;
			} else {
				n = strrchr( name, DIR_G_car_dir ) ;
				n = n ? n + 1 : name ;
			}

			if( first ) {
				if( nchars + strlen( n ) >= MAXCHRS ) break ;
				nchars += sprintf( buf + nchars, "%s", n ) ;
				first = FALSE ;
			} else {
				if( nchars + strlen( n ) + 1 >= MAXCHRS ) break;
				nchars += sprintf( buf + nchars, ",%s", n ) ;
			}
		}
	}

	ex$message(	field		= KEYIN_FIELD,
			justification	= CENTER_JUS,
			in_buff 	= buf ) ;

} /* VScutOutProcessing */
/*----------------------------------------------------------------------------*/
long VSperformCutouts( msg, operand, nbOperators, operators )

long			*msg ;
struct GRid		*operand ;
int			nbOperators ;
struct GRobj_env	operators[] ; {

	long			sts ;		/* OM return code	*/
	int			i ;		/* Loop index		*/
	struct VScnst_list	vsargs ;	/* Construction args	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	struct GRid		result ;	/* Result of operation	*/
	struct GRobj_env	*parents ;	/* List of parents	*/
	struct GRmd_env 	actEnv ;	/* Env. of active file	*/
	unsigned long		type,		/* Type of operand	*/
				mask ;		/* Unused		*/
	OMuword 		resClassid ;	/* Class of result	*/

	parents = NULL ;
	if( !( parents = _MALLOC( nbOperators + 1, struct GRobj_env ) ) ) {
		vs$mem_fail() ;
	}

	for( i = 0 ; i < nbOperators ; i++ ) {
		parents[i+1]	= operators[i] ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			senderid= operand->objid,
			targetid= operand->objid,
			targetos= operand->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	if( ( type & VS_m_FRZ_generic ) || ( type & VS_m_IMG_generic ) ) {
		/*
		 * We do not allow modification of `frozen' or image elements.
		 */
		vs$inv_arg() ;
	}
	sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &mask ),
			senderid= operand->objid,
			targetid= operand->objid,
			targetos= operand->osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	parents[0]._grid = *operand ;
	parents[0]._md_os= operand->osnum ;
	ex$get_modid(	mod_osnum	= parents[0]._md_os,
			mod_id		= &parents[0]._md_id ) ;

	om$send(msg	= message NDmacro.ACreturn_foot(
						msg, "", &result,
						&parents[0]._matrix_type,
						parents[0]._matrix ),
		senderid= operand->objid,
		targetid= operand->objid,
		targetos= operand->osnum ) ;

	vsargs.parent_count	= nbOperators + 1 ;
	vsargs.parent_list	= parents ;
	vsargs.feature_att	= NULL ;

	ex$get_cur_mod( osnum = &actEnv._MD_OS, id = &actEnv._MD_ID ) ;
	MAidmx( msg, actEnv._MATRIX ) ; actEnv._MATRIX_TYPE = MAIDMX ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= &actEnv,
				Display 	= NULL,
				Level		= 0,
				Class_attr	= &vsargs,
				Cnst_list	= cst ) ;

	/*
	 * Find what to construct: beam -> boolean beam, plate -> holed plate.
	 */
	if( type & VS_m_BEAM )		resClassid = OPP_VSbooBeam_class_id ;
	else if( type & VS_m_PLATE )	resClassid = OPP_VSholPlate_class_id ;
	else				vs$inv_arg() ;

	result.osnum = actEnv._MD_OS ;
	sts = om$construct(	classid = resClassid,
				osnum	= result.osnum,
				p_objid = &result.objid ) ;
	if( !( sts & 1 ) ) {
		vs$error( msgval = EMS_E_OMerror ) ;
	}

	vs$bulk_display(	objenvs = vsargs.parent_list,
				count	= vsargs.parent_count,
				dpmode	= GRbe ) ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &cst ),
			senderid= result.objid,
			targetid= result.objid,
			targetos= result.osnum ) ;

	if( sts & 1 & *msg ) {
		/*
		 * Display result.
		 */
		vs$bulk_display(	grids	= &result,
					theEnv	= cst.env_info,
					dpmode	= GRbd ) ;
	} else {
		/*
		 * Redisplay operand.
		 */
		vs$bulk_display(	objenvs = parents + 0,
					dpmode	= GRbd ) ;
	}

	vs$bulk_display(	objenvs = operators,
				count	= nbOperators,
				dpmode	= GRbd ) ;

	wrapup :
		_FREE( parents ) ;
		return sts ;

} /* VSperformCutouts */
/*----------------------------------------------------------------------------*/
long VSisOperandInList( msg, pmBxId, pmBxEnv, macOcc, operand, oprndIndex )

long			*msg ;		/* O */
struct GRid		*pmBxId,	/* I */
			*macOcc,	/* I */
			*operand ;	/* I */
struct GRmd_env 	*pmBxEnv ;	/* I */
int			*oprndIndex ; {	/* O */

	long			sts ;
	int			i,
				j,
				index,
				ACrc ;
	GRname			nm ;
	struct ret_struct	rs ;
	struct GRid		oprndId ;

	*oprndIndex = -1 ;

	for( i = 0 ; i < VS_K_MAX_OPNDS ; i++ ) {
		/*
		 * Try "~~operand" before "~~operand0", "~~operand1", etc.
		 */
		if( i >= 1 ) {
			sprintf( nm, "%s%d", VS_K_opndKyWord, i - 1 ) ;
			j = i - 1 ;
		} else {
			strcpy( nm, VS_K_opndKyWord ) ;
			j = 0 ;
		}

		__DBGpr_str( "Trying", nm ) ;

		index = -1 ;
		sts = om$send(	msg	= message NDmacro.ACgive_structure(
						&ACrc, &index, nm,
						&rs, pmBxEnv ),
				senderid= pmBxId->objid,
				targetid= pmBxId->objid,
				targetos= pmBxId->osnum ) ;
		if( !( sts & 1 & ACrc ) || rs.type != text_type ) {
			__DBGpr_com(" nm not found ");
			if( i < 1 )	continue ;
			else		break ;
		}
		strcpy( nm, rs.var.text_st.text_string ) ;
		__DBGpr_str(" nm ", nm );
		/*
		 * Get id of operand from macro occurrence.
		 */
		sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
							&ACrc, nm, &oprndId ),
				senderid= macOcc->objid,
				targetid= macOcc->objid,
				targetos= macOcc->osnum ) ;
		if( !( sts & 1 & ACrc ) ) {
			__DBGpr_com(" Template not found ");
			continue ;
		}

		__DBGpr_obj(" *operand ", *operand );
		__DBGpr_obj(" oprndId ", oprndId );

		if( vs$is_ancestry_valid( object  = &oprndId,
					  classid = OPP_ACpretend_class_id )) {
			/* 
                         * Operator is a pretend: find macro occurrence which is
                         * its parent.
                         */
			__DBGpr_com(" Find ACprenend parent ");
                        sts = om$send(
                                msg     = message ACpretend.ACfind_parent(
                                                        &oprndId, NULL, NULL ),
                                senderid= oprndId.objid,
                                targetid= oprndId.objid,
                                targetos= oprndId.osnum ) ;
                        if( !( sts & 1 ) ) continue ;	

			__DBGpr_obj(" oprndId ", oprndId );
		}

		if( IF_EQ_GRID( *operand, oprndId ) ) {
			*oprndIndex = j ;
			break ;
		}
	}

	__DBGpr_int(" oprndIndex ", *oprndIndex );

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	return sts ;

} /* VSisOperandInList */
/*----------------------------------------------------------------------------*/
long VSgetOperatorOutputs( msg, etype, feature, macDef, macOcc, nbOpOutputs,
			   opOutputs, isOperand, foundOperator )

long			*msg ;
int			etype ;
struct GRid		*feature,	   /* Supposed to be the operand */
			*macDef,	   /* Macro definition of macOcc */
			*macOcc ;	   /* Macro occurrence		 */
int			*nbOpOutputs ;	   /* Count of operator outputs	 */
struct GRobj_env	**opOutputs ;	   /* List of operator outputs	 */
int			*isOperand,	   /* Is `feature' the operand ? */
			*foundOperator ; { /* Found operator for macro	 */
					   /* occurrence ?		 */

#define MAX	VS_K_MAX_OPTRS
	long			sts ;		/* OM return code	   */
	unsigned long		type ;		/* Type of operand.	   */
	int			i,		/* Loop index		   */
				nbOprtrs ;	/* Nb. of operator outputs */
	struct GRid		pmBox,		/* Options of macro def.   */
				footId, 	/* One output		   */
				oprtrIds[MAX] ; /* Ids of operator outputs */
	struct GRmd_env 	bxEnv,		/* Module env. of pmBox    */
				OutputsEnv[MAX];/* Module env. of outputs  */
	VSoprtrOprndMap 	map[VS_K_MAX_OPTRS] ;
	int			count,
				mapSize ;
	char			*oprtrNms[VS_K_MAX_OPTRS] ;
	OMuword 		actOs ; 	/* OS of active dgn file*/

	*isOperand = *foundOperator = FALSE ;

	sts = COm_get_option_grid( macDef, &pmBox, NULL ) ;
	if( !( sts & 1 ) || IF_NULL_OBJID( pmBox.objid ) ) {
		/*
		 * Macro definition has no options, hence does not specify
		 * operand template or operator outputs: skip it.
		 */
		vs$error( stsval = OM_S_SUCCESS, msgval = MSSUCC ) ;
	}

	/*
	 * Get name of operand from options object.
	 */
	MAidmx( msg, bxEnv._MATRIX ) ; bxEnv._MATRIX_TYPE = MAIDMX ;
	bxEnv._MD_OS = pmBox.osnum ;
	ex$get_modid( mod_osnum = bxEnv._MD_OS, mod_id = &bxEnv._MD_ID ) ;

	/*
	 * Try "~~operand", "~~operand0", "~~operand1", ...
	 */
	VSisOperandInList( msg, &pmBox, &bxEnv, macOcc, feature, &i ) ;

	if( -1 == i ) {
		/*
		 * No template of that name, or operand template is not
		 * the input feature: skip.
		 */
		vs$error( stsval = OM_S_SUCCESS, msgval = MSSUCC ) ;
	}

	*isOperand = TRUE ;

	/*
	 * Get names of operator outputs from options object, then get outputs.
	 */
	sts = VSgetOperatorToOperandsMap( msg, &pmBox, map, &mapSize ) ;
	__CheckRC( sts, *msg, "VSgetOperatorToOperandsMap", wrapup ) ;

	VSgetOperatorsForOperand( i, mapSize, map, oprtrNms, &count ) ;

	ex$get_cur_mod( osnum = &actOs ) ;

	nbOprtrs = 0 ;
	for( i = 0 ; i < count ; i++ ) {
		struct GRmd_env mdEnv ;
		struct GRid	pretend ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg, oprtrNms[i],
							&footId,
							&mdEnv._MATRIX_TYPE,
							mdEnv._MATRIX ),
				senderid= macOcc->objid,
				targetid= macOcc->objid,
				targetos= macOcc->osnum ) ;
		if( !( sts & 1 & *msg ) || IF_NULL_OBJID( footId.objid ) ) {
			continue ;
		}

		/*
		 * For beam operand, keep only outputs which are a solid, a
		 * surface or a closed planar curve.
		 */
		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								   msg, &type ),
				senderid= feature->objid,
				targetid= feature->objid,
				targetos= feature->osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

		mdEnv._MD_OS = footId.osnum ;
		ex$get_modid(	mod_osnum = mdEnv._MD_OS,
				mod_id	  = &mdEnv._MD_ID ) ;

		if( !VSkeepOperatorForCutout( msg, type, &footId, &mdEnv ) ) {
			continue ;
		}

		*foundOperator = TRUE ;

		/*
		 * NOTE: ordinarilly, giving "footId" as parent should
		 * be enough, BUT symbol macros (ACheader) will not
		 * handle make-source properly, given "footId".
		 * The trick is to connect a pretend to the macro here
		 * and feed it as a parent to the object to construct.
		 * This will also work if no ACheader is involved.
		 */
		if( macOcc->osnum == actOs ) {
			int		rc ;

			sts = om$send(	msg	= message ACcpx.ACconnect_pretend(
								&rc,
								oprtrNms[i],
								&pretend ),
					senderid= macOcc->objid,
					targetid= macOcc->objid,
					targetos= macOcc->osnum ) ;
			__CheckRC( sts, rc, "ACconnect_pretend", wrapup ) ;
		} else {
			/*
			 * Operator is in a different file. Since I have no
			 * way to know the transformation matrix
			 * reference file -> active file
			 * I suppose it is the identity (which it will most
			 * probably be).
			 */
			int		rc ;
			IGRmatrix	idMx ;
			short		idMxType ;
			struct GRid	context ;

			idMxType = MAIDMX ;
			MAidmx( msg, idMx ) ;

			sts = GRfindcontext(	msg,
						&idMxType,
						idMx,
						&macOcc->osnum,
						&context ) ;
			if( sts != OM_S_SUCCESS || *msg != MSSUCC ) {
				/*
				 * No context with identity matrix between
				 * ref. file and active file, there is nothing
				 * I can do ...
				 */
				sts = OM_W_ABORT ; *msg = MSFAIL ;
				goto wrapup ;
			}
			sts = om$send(	msg	= message ACcpx.ACconnect_pretendin(
								&rc,
								oprtrNms[i],
								&pretend,
								&context ),
					senderid= macOcc->objid,
					targetid= macOcc->objid,
					targetos= macOcc->osnum ) ;
			__CheckRC( sts, rc, "ACconnect_pretendin", wrapup ) ;
		}
		oprtrIds   [nbOprtrs] = pretend ;
		OutputsEnv [nbOprtrs] = mdEnv ;

		nbOprtrs++ ;
	}

	if( !nbOprtrs ) {
		/*
		 * Well, no candidates found among outputs.
		 */
		vs$error( stsval = OM_S_SUCCESS, msgval = MSSUCC ) ;
	}

	/*
	 * Add found outputs to input list.
	 */
	if( !*nbOpOutputs ) {
		*opOutputs = _MALLOC( nbOprtrs, struct GRobj_env ) ;
		if( !*opOutputs ) vs$mem_fail() ;
	} else {
		char		*new ;
		unsigned	size ;

		size = ( *nbOpOutputs + nbOprtrs ) * sizeof( struct GRobj_env ) ;

		new = realloc( *opOutputs, size ) ;
		if( new )	*opOutputs = (struct GRobj_env *) new ;
		else		vs$mem_fail() ;
	}
	for( i = 0 ; i < nbOprtrs ; i++ ) {
		(*opOutputs)[*nbOpOutputs+i]._grid	= oprtrIds[i] ;
		(*opOutputs)[*nbOpOutputs+i].mod_env	= OutputsEnv[i] ;
	}

	if( VS_K_TRANSMIGRATE == etype && nbOprtrs ) {
		struct GRid newOperand ;
		VStransMigrateOperatingMacro(	msg,
						feature,
						macOcc,
						nbOprtrs,
						*opOutputs + *nbOpOutputs,
						&newOperand ) ;
	}

	*nbOpOutputs += nbOprtrs ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *opOutputs ) ;
			*opOutputs = NULL ; *nbOpOutputs = 0 ;
		}
		return sts ;

} /* VSgetOperatorOutputs */
/*----------------------------------------------------------------------------*/
int VSgetMacDefIndex( name, count, list ) char *name, **list ; int count ; {

	int	i,
		found = -1 ;

	for( i = 0 ; i < count ; i++ ) {

		/*
		 * We accept regular expressions similar to those accepted
		 * by the UNIX shell.
		 */
		if( VSmatchRE( list[i], name ) ) {
			found = i ;
			break ;
		}
	}
	return found ;

} /* VSgetMacDefIndex */
/*----------------------------------------------------------------------------*/
long VSprocessFeature( msg, etype, feature, macCount, macNames, nbChildren,
			children, stats, badMacro )

long		*msg ;
struct GRid	*feature,
		children[] ;
int		etype,
		macCount,
		nbChildren ;
char		**macNames,
		**badMacro ;
STATISTICS	*stats ; {

	long		sts ;		/* OM return code.		    */
	int		i,		/* Loop index.			    */
			j,		/* Loop index.			    */
			macIndex,	/* Index of macro in macNames.	    */
			**isMacValid,	/* Index of child macro if valid.   */
			nbOpOutputs,	/* Nb. of operator outputs.	    */
			isOperand,	/* Is `feature' the operand ?	    */
			foundOperator ; /* Found operator for child macro ? */
	struct GRid	macDef ;	/* Macro definition.		    */
	struct GRobj_env*opOutputs ;	/* List of operator outputs.	    */
	OMuword 	childClassid ;	/* Classid of one child.	    */
	char		*name ; 	/* Name of macro.		    */
	GRname		macName ;	/* Name of macro (local).	    */
	extern char	DIR_G_car_dir ;

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	opOutputs = NULL ; nbOpOutputs = 0 ; isMacValid = NULL ;

	if( !( isMacValid = _CALLOC( macCount, int * ) ) ) vs$mem_fail() ;
	for( i = 0 ; i < macCount ; i++ ) {
		isMacValid[i] = _MALLOC( nbChildren, int ) ;
		if( !isMacValid[i] ) vs$mem_fail() ;
		for( j = 0 ; j < nbChildren ; j++ ) {
			isMacValid[i][j] = FALSE ;
		}
	}

	for( i = 0 ; i < nbChildren ; i++ ) {

		__DBGpr_obj(" CHILD", children[i] );
		sts = om$get_classid(	objid		= children[i].objid,
					osnum		= children[i].osnum,
					p_classid	= &childClassid ) ;
		__CheckRC( sts, 1, "om$get_classid", wrapup ) ;

		sts = om$is_ancestry_valid( superclassid= OPP_ACconst_class_id,
					    subclassid	= childClassid ) ;
		if( sts != OM_S_SUCCESS ) {
			/*
			 * Not an ACconst...
			 */
			__DBGpr_com(" Not an ACconst... ");
			continue ;
		}
		sts = om$send(	msg	= message ACcpx.find_macro( &macDef ),
				senderid= children[i].objid,
				targetid= children[i].objid,
				targetos= children[i].osnum ) ;
		__CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

		sts = om$send(	msg	= message ACcpx_defn.ACgive_name( &name ),
				senderid= macDef.objid,
				targetid= macDef.objid,
				targetos= macDef.osnum ) ;
		__CheckRC( sts, 1, "ACcpx_defn.ACgive_name", wrapup ) ;

		strcpy( macName, name ) ;

		/*
		 * Is macro name among those listed ?
		 */
		macIndex = VSgetMacDefIndex( macName, macCount, macNames ) ;

		if( -1 == macIndex ) {
			/*
			 * Not in wanted list.
			 */
			__DBGpr_com(" Not in wanterd list ");
			continue ;
		}

		/*
		 * Now get operator outputs and make sure that feature is the
		 * operand!
		 * Note: `opOutputs' is malloc'd (1st time) then realloc'd (next
		 * times).
		 */
		sts = VSgetOperatorOutputs(msg,
					etype,
					feature,	/* Operand feature  */
					&macDef,	/* Macro definition */
					children + i,	/* Macro occurrence */
					&nbOpOutputs,
					&opOutputs,
					&isOperand,
					&foundOperator ) ;
		__CheckRC( sts, *msg, "VSgetOperatorOutputs", wrapup ) ;

		if( isOperand ) {
			stats->nbMacsFound[macIndex] += 1 ;
			__DBGpr_com(" isOperand +1 ");
		}

		if( foundOperator ) {
			isMacValid[macIndex][i] = TRUE ;
			__DBGpr_com(" foundOperator TRUE ");
		} else if( isOperand ) {
			__DBGpr_str(" Bad Macro ", macName );
			    if( *badMacro ) {
				if( !VShaveAlreadyBadMacroInList( *badMacro,
								  macName ) ) {
					*badMacro = realloc( *badMacro,
							     strlen(*badMacro) +
							     strlen( macName ) +
							    1 ) ;
					if( !*badMacro ) vs$mem_fail() ;

					strcat( *badMacro, " " ) ;
					strcat( *badMacro, macName ) ;
				}
			    } else {
				if( !( *badMacro = VSstrdup( macName ) ) )
					vs$mem_fail() ;
			    }
		}
	}

	if( nbOpOutputs ) {
	  /*
	   * Inform user of what's going on.
	   */
	  if(  VS_K_PROCESS_CUTOUTS == etype ) {
	    VScutOutProcessing( feature, macCount, macNames,
					isMacValid, nbChildren, children ) ;

	    sts = VSperformCutouts( msg, feature, nbOpOutputs, opOutputs ) ;
	  }
	  _FREE( opOutputs ) ;
	  if( sts & 1 & *msg ) {
	    for( i = 0 ; i < macCount ; i++ ) {
	      for( j = 0 ; j < nbChildren ; j++ ) {
		if( isMacValid[i][j] ) {
		   stats->nbSuccessfulOps[i] += 1 ;
		}
	      }
	    }
	  }
	}
	wrapup :
		if( isMacValid ) {
			for( i = 0 ; i < macCount ; i++ ) {
				_FREE( isMacValid[i] ) ;
			}
			_FREE( isMacValid ) ;
		}
		return sts ;

} /* VSprocessFeature */
/*----------------------------------------------------------------------------*/
long VScutOutEdition( msg, etype, partCount, parts, count, macNames,
		      nbFoundMacs, nbSuccessOps, badOperatorInMacDef )

long		 *msg ;
int		 etype,
		 partCount ;		/* Count of parts for cutouts. If 0   */
					/* all parts on design file will be   */
					/* processed.			      */
struct GRobj_env *parts ;		/* List of parts for cutouts.	      */
int		 count, 		/* Count of macNames		      */
		 nbFoundMacs[], 	/* Must have size `count'	      */
		 nbSuccessOps[] ;	/* Must have size `count'	      */
char		 **macNames,
		 **badOperatorInMacDef ; {

	long		sts ;		/* OM return code		*/
	int		i,		/* Loop index			*/
			cnt,		/* Count of children		*/
			maxObjs ;	/* Max. of objs in Object Space */
					/* or in given list of parts.	*/
	struct GRid	curObj, 	/* Currently processed object	*/
			*list ; 	/* List of children		*/
	unsigned long	type ;		/* Type of VS feature		*/
	long		isConsumed ;	/* Id feature consumed ?	*/
	OMuword 	objClassid,	/* Class of `curObj'		*/
			actOs ; 	/* OS number of active file	*/
	STATISTICS	stats ; 	/* # of macs found & successes	*/

	list = NULL ; cnt = 0 ;

	stats.nbMacsFound	= nbFoundMacs ;
	stats.nbSuccessfulOps	= nbSuccessOps ;
	for( i = 0 ; i < count ; i++ ) {
		nbFoundMacs[i] = nbSuccessOps[i] = 0 ;
	}

	if( !partCount ) {
		/*
		 * Process cutouts in current design file.
		 */
		ex$get_cur_mod( osnum = &actOs ) ;
		maxObjs = OM_GA_OSDs[actOs]->CurSpaceMapSize ;
		curObj.osnum = actOs ;
	} else {
		/*
		 * Process cutouts on given list of parts.
		 */
		maxObjs = partCount ;
	}

	for( i = 0 ; i < maxObjs ; i++ )
        {
		if( !partCount ) curObj.objid = i ;
		else		 curObj = parts[i]._grid ;

                if( IGEstop()){
                  /*
                   * Request to stop process.
                   */
                  goto wrapup ;
                }

		sts = om$get_classid(	objid		= curObj.objid,
					osnum		= curObj.osnum,
					p_classid	= &objClassid ) ;
		if( !( sts & 1 ) ) {
			/*
			 * Not an object id.
			 */
			continue ;
		}
		sts = om$is_ancestry_valid(
				superclassid	= OPP_VSfeature_class_id,
				subclassid	= objClassid ) ;
		if( sts != OM_S_SUCCESS ) {
			/*
			 * Not a VSfeature.
			 */
			continue ;
		}

		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
				senderid= curObj.objid,
				targetid= curObj.objid,
				targetos= curObj.osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

		if( !( ( type & VS_m_PLATE ) || ( type & VS_m_BEAM ) ) ) {
			/*
			 * Not a plate, not a beam...
			 */
			continue ;
		}

		sts = om$send(	msg	= message NDmacro.ACtest_consumed(
								&isConsumed ),
				senderid= curObj.objid,
				targetid= curObj.objid,
				targetos= curObj.osnum ) ;
		if( isConsumed & 1 ) {
			/*
			 * Object consumed, cannot be a candidate for
			 * process cutouts, but is for transmigrate.
			 */
			if( etype == VS_K_PROCESS_CUTOUTS ) {
				continue ;
			}
		}
		/*
		 * Get children of feature, to find a macro occurrence among
		 * them.
		 */
		list = NULL ; cnt = 0 ;
		sts = VSgetChildrenGoThruPretends( msg, &curObj,&cnt, &list ) ;
		__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;

		if( !cnt ) {
			/*
			 * Feature has no children.
			 */
			continue ;
		}
		__DBGpr_objlist( "Children", cnt, list ) ;

		/*
		 * The following may fail, don't exit upon error.
		 */
		sts = VSprocessFeature( msg, etype, &curObj, count, macNames,
					cnt, list, &stats, badOperatorInMacDef);
		_FREE( list ) ; list = NULL ; cnt = 0 ;
	}

	/*
	 * Clear possible info displayed to keyin field.
	 */
	ex$message(	field		= ERROR_FIELD,
			justification	= CENTER_JUS,
			msgnumb 	= VS_gI_Done ) ;
	ex$message(	field		= KEYIN_FIELD,
			justification	= CENTER_JUS,
			in_buff 	= "" ) ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
          _FREE( list ) ;
          return sts ;

} /* VScutOutEdition */
/*----------------------------------------------------------------------------*/
long VSfindCutOuts( msg, partCount, parts, count, macNames, nbFoundMacs,
		    nbSuccessOps, badOperatorInMacDef )

long		 *msg ;
int		 partCount ;		/* Count of parts for cutouts. If 0   */
					/* all parts on design file will be   */
					/* processed.			      */
struct GRobj_env *parts ;		/* List of parts for cutouts.	      */
int		 count, 		/* Count of macNames		      */
		 nbFoundMacs[], 	/* Must have size `count'	      */
		 nbSuccessOps[] ;	/* Must have size `count'	      */
char		 **macNames,
		 **badOperatorInMacDef ;/* List of macro def name which have  */
					/* a bad operator outputs. 	      */
{

	return VScutOutEdition( msg,
				VS_K_PROCESS_CUTOUTS,
				partCount, parts,
				count, macNames, nbFoundMacs, nbSuccessOps,
				badOperatorInMacDef ) ;
} /* VSfindCutOuts */
/*----------------------------------------------------------------------------*/
long VStransmigrateOperations( msg ) long *msg ; {

	long	sts ;
	char	*macNames[1],
		*badOperatorInMacDef,
		buf[100] ;
	int	nbFoundMacs,
		nbSuccessOps ;

	macNames[0] = "*" ;
	badOperatorInMacDef = NULL ;

	sts = VScutOutEdition( msg,
			       VS_K_TRANSMIGRATE,
			       0, (struct GRobj_env *) NULL,
			       1, macNames, &nbFoundMacs, &nbSuccessOps,
			       &badOperatorInMacDef ) ;
	__CheckRC( sts, *msg, "VScutOutEdition", wrapup ) ;

	if( badOperatorInMacDef && *badOperatorInMacDef ) {
		ex$message( msgnumb = VS_gI_InvalidOperator,
			    type    = "%s",
			    var     = `badOperatorInMacDef`,
			    buff    = buf ) ;
		UI_error( buf ) ;
	}

	wrapup :
		_FREE( badOperatorInMacDef ) ;
		return sts ;

} /* VStransmigrateOperations */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
