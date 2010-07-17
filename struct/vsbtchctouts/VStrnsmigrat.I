/* $Id: VStrnsmigrat.I,v 1.3 2001/08/25 18:43:30 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbtchctouts/VStrnsmigrat.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VStrnsmigrat.I,v $
 *      Revision 1.3  2001/08/25 18:43:30  jayadev
 *      changes for TR#MP5410
 *
 *      Revision 1.2  2001/03/14 00:59:57  jayadev
 *      VSmakePenetratingCyl() args changed
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:22  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/26  15:08:20  pinnacle
# TR179701283
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		added status message
 *      08/25/01        Jayadev         TR#MP5410 - operator curve scaled
 ***************************************************************************/

class implementation VSfeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "EMSmsgdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "EMSsffmacros.h"
#include "vsmkpenetcyl.h"

extern IGRint VSscaleCurve();

/*----------------------------------------------------------------------------*/
static long VSfindCandidateResult( msg, divCount, divList, type,
				        nbOpOutputs, opOutputs, index )

long			*msg ;
int			divCount,
			nbOpOutputs,
			*index ;
unsigned long		type ;
struct GRid		*divList ;
struct GRobj_env	*opOutputs ; {

	long			sts ;		/* OM return code	*/
	int			i,		/* Loop-on-results	*/
				j,		/* Loop on outputs	*/
				nbInters,
				*intWithRes , retSts;
	struct GRmd_env		cstEnv,
				optrEnv ;
	struct GRlc_info	cylinder,
				botSf ;
	struct GRvg_construct	cst ;
	struct GRid		*interIds,
				operator, cvCopy;
	const char		*output ;

	*index		= -1 ;
	intWithRes	= NULL ;

	if( !( intWithRes = _CALLOC( divCount, int ) ) ) vs$mem_fail() ;

	/*
	 * All results of division supposed to be in the same OS.
	 */
	cstEnv._MD_OS = divList->osnum ;
	cstEnv._MD_ID = NULL_OBJID ;

	MAidmx( msg, cstEnv._MATRIX ) ;
	cstEnv._MATRIX_TYPE = MAIDMX ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= &cstEnv,
				Cnst_list	= cst ) ;

	botSf.module_info = cylinder.module_info = cstEnv ;

	output = type & VS_m_PLATE ? VS_K_plTopSfPath : VS_K_bmGrCmpName ;
	for( i = 0 ; i < divCount ; i++ ) {
	  sts = om$send( msg	 = message NDmacro.ACreturn_foot(
				      msg, (char*) output, &botSf.located_obj,
				      NULL, NULL ),
			  senderid= NULL_OBJID,
			  targetid= divList[i].objid,
			  targetos= divList[i].osnum ) ;
	  __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	  
	  for( j = 0 ; j < nbOpOutputs ; j++ ) {
	    sts = om$send( msg	  = message NDmacro.ACreturn_foot(
	                               msg, "", &operator, &optrEnv._MATRIX_TYPE,
	                               optrEnv._MATRIX ),
			   senderid= NULL_OBJID,
			   targetid= opOutputs[j]._objid,
			   targetos= opOutputs[j]._osnum ) ;
	    if( !( sts & 1 & *msg ) ) {
	      continue ;
	    }
	    optrEnv._MD_OS = operator.osnum ;
	    optrEnv._MD_ID = NULL_OBJID ;
	    
            cvCopy.objid = NULL_OBJID;
	    
            // scaling operator curve for TR#MP5410 
            retSts = VSscaleCurve(&operator,&optrEnv,
				  &cst,&cvCopy, 0.5);
            if(((retSts&1)) && (cvCopy.objid != NULL_OBJID))
            {
	      sts = VSmakePenetratingCyl(msg, divList + i, &optrEnv,
					 &cvCopy, cst.env_info,
					 &cst, &cylinder.located_obj,NULL );
            }	
            else
            {  
	      sts = VSmakePenetratingCyl(msg, divList + i, &optrEnv,
					 &operator, &opOutputs[j].mod_env,
					 &cst, &cylinder.located_obj,NULL );
            }
	    
	    if( !( sts & 1 & *msg ) ) {
	      if(cvCopy.objid != NULL_OBJID)
		vs$bulk_delete(	grids	= &cvCopy,
				theEnv	= cst.env_info ) ;
	      continue ;
	    }
	    
	    nbInters = 0 ; interIds = NULL ;
	    sts = EMintersect_two_element(	&botSf,
						&cylinder,
						TRUE,
						&cst,
						&nbInters,
						&interIds,
						msg ) ;
	    
	    if( ( sts & 1 & *msg ) ) {
	      if( nbInters ) {
		intWithRes[i]++ ;
		vs$bulk_delete(	grids	= interIds,
				count	= nbInters,
				theEnv	= cst.env_info ) ;
		_FREE( interIds ) ;
		nbInters = 0 ; interIds = NULL ;
	      }
	    }
	    vs$bulk_delete(	grids	= &cylinder.located_obj,
				theEnv	= &cylinder.module_info ) ;	   
	    vs$bulk_delete(	grids	= &cvCopy,
				theEnv	= cst.env_info ) ;
	  }
	}

	/*
	 * Retain the result which has most intersections.
	 */
	j = 0 ; *index = -1 ;
	for( i = 0 ; i < divCount ; i++ ) {
	  if( intWithRes[i] > j ) {
	    j = intWithRes[i] ; *index = i ;
	  }
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( intWithRes ) ;
		return sts ;

} /* VSfindCandidateResult */
/*----------------------------------------------------------------------------*/
static void VScheckForLoops( divCount, divList, nbOpOutputs, opOutputs,
				newCount )

int			divCount,
			nbOpOutputs,
			*newCount ;
struct GRid		*divList ;
struct GRobj_env	*opOutputs ; {

	long		msg,
			sts ;
	int		i,
			j,
			k,
			opCount ;
	VSoperator	*opList ;
	struct GRid	operator ;

	*newCount = 0 ;

	for( k = 0 ; k < divCount ; k++ ) {
	  sts = om$send(msg	= message VSfeature.VSgetOperators(
						      &msg, &opCount, &opList ),
			senderid= NULL_OBJID,
			targetid= divList[k].objid,
			targetos= divList[k].osnum ) ;
	  __CheckRC( sts, msg, "VSfeature.VSgetOperators", wrapup ) ;

	  for( i = 0 ; i < nbOpOutputs ; i++ ) {
	    operator = opOutputs[i]._grid ;

	    for( j = 0 ; j < opCount ; j++ ) {
	      if( IF_EQ_OBJID( operator.objid, opList[j].id )
	          && operator.osnum == opList[j].os ) {
		/*
		 * Eliminate this one.
		 */
		  divList[k].osnum = OM_K_NOT_AN_OS ;

		}
	      }					
	   }
	   _FREE( opList ) ; opList = NULL ; opCount = 0 ;
	}

	for( i = j = 0 ; i < divCount ; i++ ) {
	  if( OM_K_NOT_AN_OS != divList[i].osnum ) {
	    divList[j++].osnum = divList[i].osnum ;
	  }
	}
	*newCount = j ;

	wrapup : ;

} /* VScheckForLoops */
/*----------------------------------------------------------------------------*/
long VStransMigrateOperatingMacro( msg, oldOperand, operatingMacro, nbOpOutputs,
				   opOutputs, newOperand )

long			*msg ;
struct GRid		*oldOperand,
			*operatingMacro,
			*newOperand ;
int			nbOpOutputs ;
struct GRobj_env	*opOutputs ; {

	long		sts,			/* OM return code	*/
			isConsumed ;		/* Is operand consumed ?*/
	unsigned long	type ;			/* Operand type		*/
	struct GRid	*divList = NULL ;	/* Divided results	*/
	int		divCount = 0,		/* Count of above stuff	*/
			i,
			j,
			index ;			/* Index of result where*/
						/* macro will be migr'ed*/

	char macName[DI_PATH_MAX];
	char stsBuf [DI_PATH_MAX];
	
	/* Say Hi */
	*macName = 0;
	di$untranslate(
	  objname = macName,
	  objid = operatingMacro->objid,
	  osnum = operatingMacro->osnum
	);
	sprintf(stsBuf,"Migrating %s",macName);
	UI_status(stsBuf);
	
	
	newOperand->objid = NULL_OBJID ;
	*msg		  = MSSUCC ;
	
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &isConsumed),
			senderid= NULL_OBJID,
			targetid= oldOperand->objid,
			targetos= oldOperand->osnum ) ;
	if( !( isConsumed & 1 ) ) {
	  *newOperand = *oldOperand ; sts = OM_S_SUCCESS ; goto wrapup ;
	}
	
	sts = om$send(	msg	= message VSfeature.VSgetResultType(
                                   	  msg, &type ),
			senderid= NULL_OBJID,
			targetid= oldOperand->objid,
			targetos= oldOperand->osnum ) ;
	/* RM IF OK
	   if( !( type & VS_m_PLATE ) ) { sts = OM_S_SUCCESS ; goto wrapup ; }
	   END Rm */
	
	sts = om$send(	msg	= message VSfeature.VSgetVisDivRes(
	                                  msg, &divCount, &divList ),
			senderid= NULL_OBJID,
			targetid= oldOperand->objid,
			targetos= oldOperand->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetVisDivRes", wrapup ) ;
	if( !divCount ) {
	  *newOperand = *oldOperand ; sts = OM_S_SUCCESS ; goto wrapup ;
	}
	
	/*
	 * Make sure that none of the outputs (in fact here they're pretends)
	 * are not by chance a parent of the operand. This may happen since
	 * we accept consumed objects if `oldOperand' has been processed with
	 * the macro's outputs. We would then try to connect the macro as our
	 * child with a pretend child of the macro which is our parent as
	 * follows
	 *
	 *	PLATE				PLATE
	 *	|   |				|   +-----------+
	 *	|   MACRO OCCURRENCE --->	|   |		|
	 *      |   |				|   PRETEND	|
	 *	|   PRETEND			|   |		|
	 *	|   |				HOLED PLATE	|
	 *      HOLED PLATE			|		|
	 *					MACRO OCCURRENCE|
	 *					|		|
	 *					+---------------+
	 */
	VScheckForLoops( divCount, divList, nbOpOutputs, opOutputs, &j ) ;
	divCount = j ;
	
	if( !divCount ) {
	  sts = OM_S_SUCCESS ; goto wrapup ;
	}
	
	if( 1 == divCount && oldOperand->osnum == divList->osnum ) {
	  *newOperand = *divList ;
	} else {
	  /*
	   * Only retain results in same OS as operand.
	   */
	  
	  for( i = 0 ; i < divCount ; i++ ) {
	    if( divList[i].osnum != oldOperand->osnum ) {
	      divList[i].osnum = OM_K_NOT_AN_OS ;
	    }
	  }
	  
	  for( i = j = 0 ; i < divCount ; i++ ) {
	    if( OM_K_NOT_AN_OS != divList[i].osnum ) {
	      divList[j++].osnum = divList[i].osnum ;
	    }
	  }
	  divCount = j ;
	  
	  VSfindCandidateResult(	msg,
					divCount,
					divList,
					type,
					nbOpOutputs,
					opOutputs,
				  	&index ) ;
	  __CheckRC( sts, *msg, "VSfindCandidateResult", wrapup ) ;
	  
	  if(    -1 == index
		 || divList[index].osnum != oldOperand->osnum ) {
	    sts = OM_S_SUCCESS ; goto wrapup ;	
	  }
	  *newOperand = divList[index] ;
	}
	
	/*
	 * Change parent of macro occurrence.
	 */
	sts = om$send(	msg	= message NDnode.NDchange_connect(
	                                  1, oldOperand, newOperand ),
			senderid= NULL_OBJID,
			targetid= operatingMacro->objid,
			targetos= operatingMacro->osnum ) ;
	
	sts = om$send(	msg	= message NDnode.NDchange_node(
					  &opOutputs->mod_env ),
			senderid= NULL_OBJID,
			targetid= operatingMacro->objid,
			targetos= operatingMacro->osnum ) ;
	
	wrapup :
	  _FREE( divList ) ;
	
	UI_status("Migrate Macro Complete");
	if (!(sts & *msg & 1)) {
	  printf("Problem Migrating %s\n",macName);
	}
	else
	{
	  if(isConsumed)
	  {
	    __DBGpr_str(" Successful Migrate of operatingMacro ",macName);
	    __DBGpr_obj(" operatingMacro ID",*operatingMacro);
	    __DBGpr_obj(" Old Operand ",*oldOperand);
	    __DBGpr_obj(" New Operand ",*newOperand);
	  }
	}
	
	return sts ;
	
} /* VStransMigrateOperatingMacro */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

