/* $Id: VSsimprctout.I,v 1.3 2001/03/14 01:03:20 jayadev Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSsimprctout.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSsimprctout.I,v $
 *  Revision 1.3  2001/03/14 01:03:20  jayadev
 *  VSmkPenetCyl & vs$make_bool_diff args changed
 *
 *  Revision 1.2  2001/01/17 00:11:57  ramarao
 *  *** empty log message ***
 *
# Revision 1.2  2000/12/09  16:44:42  pinnacle
# Replaced: struct/vscmd/VSsimprctout.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/12/03  18:55:36  pinnacle
# Created: struct/vscmd/VSsimprctout.I by jpulapar for Service Pack
#
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      12/03/00    Jayadev     args change in vs$make_boolean_difference  
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMmacros.h"
#include "madef.h"
#include "exmacros.h"
#include "ms.h"
#include "msmacros.h"
#include "COmdef.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "GRdpbfunc.h"
#include "GRsetinq.h"
#include "grdpbmacros.h"
#include "vdsmacros.h"
#include "vsbeamdef.h"
#include "vsglobalmsg.h"
#include "vsbtchctsdef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "VDmem.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "COm_option.h"
#include "GRfindcontex.h"
#include "vsgetchildrn.h"
#include "vsstrngproto.h"

#define MAX     VS_K_bbMAX_NOTCHES


struct VS_s_statistics {
	int	*nbMacsFound,
		*nbSuccessfulOps ;
} ;
typedef struct VS_s_statistics STATISTICS ;

extern OMuword		OPP_VSfeature_class_id,
			OPP_VSbooBeam_class_id,
			OPP_VSholPlate_class_id,
			OPP_ACconst_class_id,
			OPP_EMSsolid_class_id,
			OPP_EMSsubbs_class_id,
			OPP_GRcurve_class_id,
			OPP_ACncpx_class_id ;

from	ACcpx_defn	import ACgive_name ;

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
SetProc( VShaveAlreadyBadMacroInList ); Begin
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
	End 
	return have ;

} /* VShaveAlreadyBadMacroInList */
/*----------------------------------------------------------------------------*/
long VSperformBooleanOprt( msg, cst, feature, nbNotches, list, result )
long			*msg;
struct GRvg_construct	*cst;
int			nbNotches;
struct GRid		*feature,
			list[];
int			*result ;
{
	long		sts;
        struct GRid     resultId,
			parentInput;    /* My parent beam's input       */
	struct GRobj_env
			notchList[MAX],
			validList[MAX], /* (possibly) valid notches     */
			operandSolid ;
	int		i,		/* iterative loop...		*/
			validCount;     /* Count of valid notches       */
	char            cylsToDel[MAX] ;/* Flags cyls to be deleted     */
        VSdspRep        myRep ;         /* My display representation    */


 	SetProc( VSperformBooleanOprt ); Begin
	__DBGpr_int( " Number of notches", nbNotches );
	*result = 0;
	memset( cylsToDel, 0, MAX ) ;

	sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &myRep ),
                        senderid= feature->objid,
                        targetid= feature->objid,
			targetos= feature->osnum ) ;
        __CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	sts = vs$consume(	msg	= msg,
				objId	= feature,
				ftEnv	= cst->env_info,
				nbfeet	= 1,
				feet	= &parentInput );
	__CheckRC( sts, *msg, "vs$consume", wrapup );

        operandSolid._grid      = parentInput ;
        operandSolid.mod_env    = *cst->env_info;

	if( nbNotches > MAX ) nbNotches = MAX ;

	/*
         * For operators which are curves (supposed closed and planar),
         * generate a cutting cylinder.
         */
	sts = om$send(  msg = message VScpx.VSget_graphic_input(
						msg,
						nbNotches,
						list,
						notchList ),
			senderid= feature->objid,
			targetid= feature->objid,
			targetos= feature->osnum );
        __CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

        for( i = 0 ; i < nbNotches ; i++ ) {
	if( vs$is_ancestry_valid(
			object  = &notchList[i]._grid,
			classid = OPP_GRcurve_class_id ) ) {

		struct GRid     cylinder ;
		int             saveStyle ;

                saveStyle               = cst->display->style ;
                cst->display->style     = 3 ;

                sts = VSmakePenetratingCyl(     msg,
						&parentInput,
						cst->env_info,
						&notchList[i]._grid,
						&notchList[i].mod_env,
						cst,
						&cylinder,
						NULL ) ;
                cst->display->style      = saveStyle ;
		__CheckRC( sts, *msg, "VSmakePenetratingCyl", wrapup );
		cylsToDel[i]            = TRUE ;
                notchList[i]._grid      = cylinder ;
		notchList[i].mod_env    = *(cst->env_info) ;
	}
	}
	/*
         * Filter input notches: only keep those susceptible to make boolean
         * difference succeed...
         */

	sts = VSfilterNotches( msg, &operandSolid, nbNotches, notchList,
                                &validCount, validList ) ;
        __CheckRC( sts, *msg, "VSfilterNotches", wrapup ) ;
 
        if( !validCount ) {
                /*
                 * On placement: err off, on recompute: output parent's input,
                 * eg. solid left intact.
                 */
		vs$bulk_delete(	count 	= 1,
				grids	= &parentInput,
				theEnv	= cst->env_info );
		*msg = EMS_E_NoSolution ; goto wrapup ;
        } else {
                sts = vs$make_boolean_difference(
                                                msg             = msg,
                                                optrCount       = validCount,
                                                optrList        = validList,
                                                operand         = &operandSolid,
                                                resCst          = cst,
                                                compress        = TRUE,
                                                oneAtATime      = TRUE,
                                                result          = &resultId,
						refList         = NULL,
						refCount	= 0 ,
						range           = NULL) ;

                if( !( sts & 1 & *msg ) ) {
			/*
                         * Output parent's input, eg. solid left intact.
			 * Delete the virtual feet of beam
			 */
			vs$bulk_delete(	count 	= 1,
					grids	= &parentInput,
					theEnv	= cst->env_info );
                } 
		if( sts & *msg & 1 ) {
			/*
			 * Delete the solid result of the boolean operation
			 */
			vs$bulk_delete( count   = 1,
       					grids   = &resultId,
       		       			theEnv  = cst->env_info ) ;

			*result = TRUE ;
		}
        }
wrapup :
	vs$unconsume(	msg	= msg,
			object	= feature,
			mod_env	= cst->env_info,
			rep 	= myRep,
			compute = FALSE );

	for( i = 0 ; i < MAX ; i++ ) {
		/*
		 * Delete the created cutting cylinders
		 */
		if( cylsToDel[i] ) {
			vs$bulk_delete( objenvs = notchList + i ) ;
		}
        }
	End 
	return sts ;

}/* VSperformBooleanOprt */
/*----------------------------------------------------------------------------*/
void VScutOutProcessing1( feature, macCount, macNames, isMacValid, count, list )

struct GRid		*feature;
struct GRobj_env	list[] ;
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
	struct GRobj_env
			*oneMac ;
	extern char	DIR_G_car_dir ;

 	SetProc( VScutOutProcessing1 ); Begin

	__DBGpr_int( "macro Count", macCount );
	__DBGpr_int( " operator count", count );

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
					senderid= oneMac->_objid,
					targetid= oneMac->_objid,
					targetos= oneMac->_osnum ) ;
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
	End 

} /* VScutOutProcessing1 */
/*----------------------------------------------------------------------------*/
long VSgetOperatorOutputs1( msg, feature, macDef, macOcc, nbOpOutputs,
			   opOutputs, isOperand, foundOperator )

long			*msg ;
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
 	SetProc( VSgetOperatorOutputs1 ); Begin
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
	if( *opOutputs ) _FREE( opOutputs );
	*opOutputs = _MALLOC( nbOprtrs, struct GRobj_env ) ;
	if( !*opOutputs ) vs$mem_fail() ;

	for( i = 0 ; i < nbOprtrs ; i++ ) {
		(*opOutputs)[*nbOpOutputs+i]._grid	= oprtrIds[i] ;
		(*opOutputs)[*nbOpOutputs+i].mod_env	= OutputsEnv[i] ; 
	}


	*nbOpOutputs = nbOprtrs ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *opOutputs ) ;
			*opOutputs = NULL ; *nbOpOutputs = 0 ;
		}
		End 
		return sts ;

} /* VSgetOperatorOutputs1 */
/*----------------------------------------------------------------------------*/
long VSprocessFeature1( msg, feature, macCount, macNames, nbChildren,
			children, cst, stats, badMacro, failCount, fName, 
			objCount, fObject )

long		*msg ;
struct GRid	*feature,
		children[] ;
int 		macCount,
		nbChildren,
		*objCount,
		*failCount ;
char		**macNames,
		**badMacro ,
		***fName,
		***fObject;
struct GRvg_construct *cst;
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
	struct GRobj_env
			*opOutputs ;	/* List of operator outputs.	    */
	OMuword 	childClassid ;	/* Classid of one child.	    */
	char		*name ; 	/* Name of macro.		    */
	GRname		macName ;	/* Name of macro (local).	    */
	extern char	DIR_G_car_dir ;
	int		fCount = 0, 
			result = 0, 
			objCnt = 0;
SetProc (VSprocessFeature1 ); Begin
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
			continue ;
		}

		/*
		 * Now get operator outputs and make sure that feature is the
		 * operand!
		 * Note: `opOutputs' is malloc'd 
		 * This function should take the feature macro defintion, and
		 * the chilren of the feature which is macro occurence,
		 * and preform the is_operand test and return the oputput.
		 */
		sts = VSgetOperatorOutputs1(msg,
					feature,	/* Operand feature  */
					&macDef,	/* Macro definition */
					children + i,	/* Macro occurrence */
					&nbOpOutputs,
					&opOutputs,
					&isOperand,
					&foundOperator ) ;
		__CheckRC( sts, *msg, "VSgetOperatorOutputs1", wrapup ) ;

		if( isOperand ) {
			stats->nbMacsFound[macIndex] += 1 ;
		}

		if( foundOperator ) {

			struct GRid	*optrList = NULL;
			int 		ii;
	  		/*
	   		 * Inform user of what's going on.
	   		 */
			isMacValid[macIndex][i] = TRUE ;

			VScutOutProcessing1( 	feature, 
						macCount, 
						macNames,
					   	isMacValid, 
						nbOpOutputs,  /*This should be 
								children but 
								the opOutputs */
						opOutputs ) ;
			/*
			 * Now that having the feature and and the macro
			 * occurences on the feature try to perform a boolean
			 * operation and check if it is successful, in 
			 * performing the boolean operation.
			 */
			optrList = _MALLOC( nbOpOutputs, struct GRid ) ;

			for( ii = 0 ; ii < nbOpOutputs ; ii++ ) {
			    optrList[ii] = opOutputs[ii]._grid;
			}

			VSperformBooleanOprt( 	msg, cst, feature, nbOpOutputs,
 							optrList, &result );

			if( result ) {
				/*
				 * do nothing
				 */
		   		stats->nbSuccessfulOps[macIndex] += 1 ;
			}else {
				/*
				 * Store the macro that failed in performing
				 * the boolean operation and hilite the macro
				 */
				GRname		mcOccNm ;
				char		objId[80];

				mcOccNm[0] = '\0' ;
				vd$get_name( 	obj	= children + i, 
						name	= mcOccNm );

				if( mcOccNm[0] == '\0' ) {
					strcpy( mcOccNm, macName );
				}
			    	if( *fName ) {
					int	incr = 1;
				 	if( !(*fName = _REALLOC( 
							  *fName, 
							  ((*failCount) + incr),
							  char* ) ) )
						vs$mem_fail() ;
					(*fName)[(*failCount)] = NULL ;

					if(!( (*fName)[(*failCount)] = VSstrdup( mcOccNm) ) )
						vs$mem_fail() ;
					(*failCount)++;
			    	} else {
				 	*fName = _MALLOC (1, char* );
					(*fName)[0] = NULL;
					if(!( *fName[0] = VSstrdup( mcOccNm) ) )
						vs$mem_fail() ;
					*failCount = 1;
				}
				sts = vs$bulk_display(	count  = 1,
							dpmode = GRhd,
							grids  = children + i,
							theEnv = cst->env_info );
				sprintf( objId, "%d %d", children[i].objid,
						         children[i].osnum );
			    	if( *fObject ) {
					int	incr = 1;
				 	if( !(*fObject = _REALLOC( *fObject, ((*objCount) + incr), char* ) ) )
						vs$mem_fail() ;
					(*fObject)[(*objCount)] = NULL ;

					if(!( (*fObject)[(*objCount)] = VSstrdup( objId) ) )
						vs$mem_fail() ;
					(*objCount)++;
			    	} else {
				 	*fObject = _MALLOC (1, char* );
					(*fObject)[0] = NULL;
					if(!( (*fObject)[0] = VSstrdup( objId) ) )
						vs$mem_fail() ;
					(*objCount) = 1;
				}
			}
			_FREE( optrList );

		} else if( isOperand ) {
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
		if( nbOpOutputs ) {
			_FREE( opOutputs );
			nbOpOutputs = 0;
		}
	}

	if( nbOpOutputs ) {
	  /*
	   * Inform user of what's going on.
	    VScutOutProcessing( feature, macCount, macNames,
					isMacValid, nbChildren, children ) ;

	    sts = VSperformCutouts( msg, feature, nbOpOutputs, opOutputs ) ;
	  _FREE( opOutputs ) ;
	*/
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
	End
	return sts ;

} /* VSprocessFeature1 */
/*----------------------------------------------------------------------------*/
long VSsimulateCutOuts( msg, partCount, parts, count, macNames, nbFoundMacs,
		    nbSuccessOps, badOperatorInMacDef, fCount, macFail, 
		    objCount, fObject)

long		 *msg ;
int		 partCount ;		/* Count of parts for cutouts. If 0   */
					/* all parts on design file will be   */
					/* processed.			      */
struct GRobj_env *parts ;		/* List of parts for cutouts.	      */
int		 count, 		/* Count of macNames		      */
		 nbFoundMacs[], 	/* Must have size `count'	      */
		 nbSuccessOps[],	/* Must have size `count'             */
		 *objCount,		/* object count of failed ids         */
		 *fCount ;		/* Returns the count of failed macros */
char		 **macNames,
		 **badOperatorInMacDef ,/* List of macro def name which have  */
					/* a bad operator outputs. 	      */
		 ***macFail ,		/* List of macro def name which have  */
					/* failed to perform process cutout   */
		 ***fObject ;		/* List of ids stored as strings      */

{
 
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

	struct GRvg_construct	cst;	/* construction list for cutout	*/
	struct GRmd_env		actEnv ;
	IGRint			size, 
				locMsg ,
				nret ;
        struct GRsymbology	symb ;

SetProc (VSsimulateCutouts ); Begin

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

	ex$get_cur_mod( osnum = &actEnv._MD_OS, id = &actEnv._MD_ID ) ;
        MAidmx( msg, actEnv._MATRIX ) ; actEnv._MATRIX_TYPE = MAIDMX ;

	size = sizeof(struct GRsymbology);
 	gr$get_active_display(  msg    = &locMsg,
				sizbuf = &size,
				buffer = (char *)&symb.display_attr,
				nret   = &nret  );

 	gr$get_active_level( 	msg    = &locMsg,
				sizbuf = &size,
				buffer = (char *)&symb.level,
				nret   = &nret   );

	vs$fill_cnst_list(      Msg             = msg,
                                Env_info        = &actEnv,
                                Display         = &symb.display_attr,
                                Level           = symb.level,
				Cnst_list       = cst ) ;
	for( i = 0 ; i < maxObjs ; i++ ) {

		if( !partCount ) curObj.objid = i ;
		else		 curObj = parts[i]._grid ;

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
			continue ;
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
		sts = VSprocessFeature1( msg, &curObj, count, macNames,
					     cnt, list, &cst, &stats, 
						badOperatorInMacDef, fCount,
						macFail, objCount, fObject );
		/*
		 * Redisplay the feature in backgrond draw mode
		 * since it was erase before perfoming the actual
		 * boolean operaion
		 */
		vs$bulk_display( count	= 1,
				 dpmode = GRbd,
				 grids	= &curObj,
				 theEnv	= cst.env_info );
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
		End
		return sts ;
} /* VSsimulateCutOuts */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
