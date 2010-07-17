/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
# Created: vsjoint/VSgivejntype.I by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	09/20/96	K.V.Suresh	Return the type of joint on the
					given two plates. Different joint
					types are defined in vsjointdef.h
 * -------------------------------------------------------------------*/
/*
	I/STRUCT
*/

class implementation Root;

#include 	"EMSmsgdef.h"
#include	"OMmacros.h"
#include 	"nddef.h"
#include 	"vsplatedef.h"
#include 	"vsedgedef.h"
#include 	"vsedgemacros.h"
#include 	"vsjointdef.h"
#include 	"vsmiscmacros.h"
#include 	"vsgeommacros.h"
#include        "vsdbgmacros.h"
#include	"bserr.h"
#include        "bsmdistptcv.h"
#include        "bsparameters.h"

from 	VSfeature 	import	VSgetResultType ;
from	NDnode		import	NDget_objects ;
from 	NDmacro		import	ACreturn_foot ;
from	GRcurve		import	GRtotlength ;
from 	EMSedge		import	EMget_bcxyz_geom;

extern OMuword	OPP_VSplate_class_id;
extern OMuword	OPP_GRcompcurve_class_id;
/*----------------------------------------------------------------------------*/
int	VSgetMatchType(	long		 *msg,		/* O return code      */
			struct GRmd_env	 *jnEnv,	/* I joint env        */
			struct GRid	 *jnList,	/* I component list   */
			int		 jnCount,	/* I component count  */
			char		 *srfName,	/* I surface name     */
			struct GRobj_env plate,		/* I plate object     */
			int		 *type )	/* O type of match    */
{
	long			sts ;
	struct IGRbsp_curve	*cvGeom, *edGeom ;
	struct IGRbsp_curve	edGeom1 ;
	IGRpoint		pt ;
	struct 	GRid		*edList ;
	int			edCount, i, j, onEdge ;
	short			k, n ;
	double			dist, tolerance, *pars, *intpars, ii ;
	
	struct GRobj_env	surface;

	edGeom = cvGeom = NULL ;
	edList = NULL ; 
	pars = intpars = NULL;

	/*
	 * Get the object for the corresponding surface name given 
	 */
	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
						     	msg,
							srfName,
				 			&surface._grid, 
							NULL,
							NULL ),
			senderid = plate._objid,
			targetid = plate._objid,
			targetos = plate._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	surface.mod_env = plate.mod_env;

	/*
	 * get the surface edges
	 */
	sts = vs$get_surface_edges(	msg	= msg,
                             		sfId 	= &surface._grid,
                             		sfEnv	= &surface.mod_env,
                             		edgeType= VS_K_CONTOUR_EDGES,
                             		edCount	= &edCount,
                             		edList	= &edList );
	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

	BSEXTRACTPAR( msg, BSTOLCHRDHT, tolerance );
	
	/*
	 * For each component of the joint in joint list check if that
	 * component is on the surface or matching with any of the
	 * edges of the surface
	 */

	for ( i = 0; i< jnCount ; i++ )
	{
		sts = vs$get_geometry(	msg	= msg,
					grobjId	= &jnList[i],
					grobjEnv= jnEnv,
					geometry= &cvGeom );
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		for ( j = 0; j<edCount; j++ ) 
		{

			edGeom1.knots = NULL;
			edGeom1.poles = NULL;
			edGeom1.weights = NULL;
			edGeom1.bdrys = NULL;

			 sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
		 				msg,
		 				&surface.mod_env.md_env,NULL,
						NULL,
						NULL,
						OM_K_MAXINT,
						FALSE,
						NULL,
						&edGeom1),
					senderid = edList[j].objid,
					targetid = edList[j].objid,
					targetos = edList[j].osnum );
			__CheckRC(sts,*msg,"EMSedge.EMget_bcxyz_geom", wrapup );
	
			onEdge = TRUE;

			for( ii = 0.; ii<=1.0; ii=ii+0.1)
			{
				BScveval( cvGeom, ii, 0, &pt, msg );

				if( BSERROR( *msg ) ) {
					*msg = EMS_E_BSerror ;
					goto wrapup ;
				}

				pars = intpars = NULL;

				BSmdistptcv( 	&edGeom1,
						pt,
						&k,
						&n,
						&pars,
						&dist,
						&intpars,
						msg );

				if( BSERROR( *msg ) ) {
					*msg = EMS_E_BSerror ;
					goto wrapup ;
        	                }
				if(dist > tolerance ){
					onEdge = FALSE;
					break;
				}
			}
			if(onEdge) {
			    if( jnCount > 1 ) 
			    {
				double len1,len2;
				len1 = len2 = 0;
				sts = om$send( msg = message 
							GRcurve.GRtotlength( 	
								msg,
								&jnEnv->md_env.matrix_type,
								jnEnv->md_env.matrix,
								&len1),
						senderid = jnList[i].objid,
						targetid = jnList[i].objid,
						targetos = jnList[i].osnum );
				__CheckRC( sts, *msg, 
						"GRcurve.GRtotlength",wrapup ) ;
				if( i < jnCount-1 ) {
				sts = om$send(  msg = message 
							GRcurve.GRtotlength( 	
								msg,
								&jnEnv->md_env.matrix_type,
								jnEnv->md_env.matrix,
								&len2),
						senderid = jnList[i+1].objid,
						targetid = jnList[i+1].objid,
						targetos = jnList[i+1].osnum );
				__CheckRC( sts, *msg, 
						"GRcurve.GRtotlength",wrapup ) ;
				} else {
				sts = om$send(  msg = message 
							GRcurve.GRtotlength( 	
								msg,
								&jnEnv->md_env.matrix_type,
								jnEnv->md_env.matrix,
								&len2),
						senderid = jnList[i-1].objid,
						targetid = jnList[i-1].objid,
						targetos = jnList[i-1].osnum );
				__CheckRC( sts, *msg, 
						"GRcurve.GRtotlength",wrapup ) ;
				}

				if(len1<len2) *type = SURF;
				else {	
					*type = EDGE; 
					*msg = MSSUCC; 
					return OM_S_SUCCESS; 
				     }
			    } else if( jnCount == 1 ) {
				*msg = MSSUCC;
				*type = EDGE; return OM_S_SUCCESS;
			    }
			}
		}
	} 
	*msg = MSSUCC;
	*type = SURF;
wrapup:
	_FREE(pars) ;
	_FREE(intpars) ;
	_FREE(edList) ;
	_FREE(edGeom) ;
	_FREE(cvGeom) ;

	return sts ;

} /* 	VSgetMatchType */
/*----------------------------------------------------------------------------*/
/*	This function is interface by the macro vs$giveJointType	      */
/*----------------------------------------------------------------------------*/
long	VSgiveJointType ( 	
			long			*msg,	  /* O return code  */
			struct GRobj_env	*joint,	  /* I joint object */
			struct GRobj_env	plate0,   /* I first plate  */
			struct GRobj_env	plate1,   /* I second plate */
			int			*jnType ) /* O joint type   */
{
	unsigned long           elType1,        /* Type of element 1    */
                                elType2 ;       /* Type of element 2    */
	struct	 GRid		*myParents ;	/* Parents of Joint 	*/
	int			p0IsValid ,	/* Is plate0 give valid */
				p1IsValid ;	/* Is plate1 give valid */
	int			nbRoots ;	/* No of roots of Joint */
	long			sts ;

	p0IsValid = p1IsValid = FALSE ;
	myParents = NULL ;

	/*
	 * Get the result type for the first plate to make sure it is a 
	 * plate object
	 */
	sts = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                msg, &elType1),
                        senderid= plate0._objid,
                        targetid= plate0._objid,
                        targetos= plate0._osnum ) ;
        __CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	/*
	 * Get the result type for the second plate to make sure it is a 
	 * plate object
	 */
        sts = om$send(  msg     = message VSfeature.VSgetResultType(
                                                                msg, &elType2 ),
                        senderid= plate1._objid,
                        targetid= plate1._objid,
                        targetos= plate1._osnum ) ;
        __CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	/*
	 * If both are plate objects then get the parents of the joint
	 * and check if the given parent objects are in the parent list of 
	 * the given joint
	 */
	if( ( elType1 & VS_m_PLATE ) && ( elType2 & VS_m_PLATE ) ) 
	{
		sts = om$send(  msg     = message NDnode.NDget_objects( 
							ND_ROOT  | ND_IN_BUF,
                                                        NULL,
                                                        0,
                                                        &myParents,
                                                        0,
                                                        OM_K_MAXINT,
                                                        &nbRoots ),
                        senderid= joint->_objid,
                        targetid= joint->_objid,
                        targetos= joint->_osnum ) ;
		if( nbRoots ) 
		{
			struct GRid	plId;
			int		i;

			for ( i= 0; i< nbRoots; i++ ) 
			{
				VSgetVirtualInfo( 	msg, 
							myParents[i], 
							&plate0.mod_env, 
							&plId ) ;
				if( vs$is_ancestry_valid(
                                        object  = &myParents[i],
                                        classid = OPP_VSplate_class_id ) ) 
				{
				/*
				 * Check If this Plate is matching with one of
				 * the given plate
				 */
				if( IF_EQ_GRID( myParents[i], plate0._grid ) ) 
					p0IsValid = TRUE;
				if( IF_EQ_GRID( myParents[i] , plate1._grid ) )
					p1IsValid = TRUE;

				}
			}
		}
	} else {
		*msg	= OM_E_INVARG ;
		goto wrapup;
	}

	if( p0IsValid && p1IsValid ) {
		struct GRid		jnGroup;
		struct GRid		*compList;
		int			noComp, type, i,
					pl0Type,pl1Type ;
		struct	GRid		*jnList = NULL;
		int			compCount = 0;

		sts = om$send(  msg     = message NDmacro.ACreturn_foot(
						     msg,"joint",
				 		     &jnGroup, NULL,NULL ),
				senderid = joint->_objid,
				targetid = joint->_objid,
				targetos = joint->_osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = vs$get_components( msg	   = msg,
					 grobjId   = &jnGroup,
					 grobjEnv  = &joint->mod_env,
					 number	   = &noComp,
					 components= &compList );
		__CheckRC( sts, *msg, "vs$get_components", wrapup ) ;

		compCount = 0;

		jnList = om$calloc(	num	  = 1,
					structure = struct GRid );

		for( i = 0; i<noComp; i++ )
		{
			if( vs$is_ancestry_valid(
					object  = &compList[i],
					classid = OPP_GRcompcurve_class_id )) {

				struct GRid	*crvList;
				int		j, nbCrvs = 0;
		
				sts = vs$get_components( 
						msg       = msg,
						grobjId   = &compList[i],
						grobjEnv  = &joint->mod_env,
						number    = &nbCrvs,
						components= &crvList );
				__CheckRC( sts,*msg,"vs$get_components",wrapup);

				compCount = compCount + nbCrvs;
				jnList = (struct GRid *)realloc( jnList,
						sizeof(struct GRid)*compCount );
				for(j=0; j< nbCrvs; j++ )
					jnList[compCount-nbCrvs+j] = crvList[j];
	
				_FREE(crvList);
					
			} else {
				compCount++;
				jnList = (struct GRid *)realloc( jnList,
						sizeof(struct GRid)*compCount );
				jnList[compCount-1] = compList[i];
			}
		}

		_FREE(compList);

		sts = VSgetMatchType(	msg,
					&joint->mod_env,
					jnList,
					compCount,
					VS_K_plBotSfPath,
					plate0,
					&type);
		__CheckRC( sts, *msg, "VSgetMatchType", wrapup ) ;

		if( type == SURF ) {
			sts = VSgetMatchType( 	msg, 
						&joint->mod_env, 
						jnList,
					      	compCount,
						VS_K_plTopSfPath,
					 	plate0,
						&type);
			__CheckRC( sts, *msg, "VSgetMatchType", wrapup ) ;

		}
		if( type == SURF ) 		pl0Type = SURF ;
		else if ( type == EDGE ) 	pl0Type = EDGE ;

		sts = VSgetMatchType(	msg,
					&joint->mod_env,
					jnList,
					compCount,
					VS_K_plBotSfPath,
					plate1,
					&type);
		__CheckRC( sts, *msg, "VSgetMatchType", wrapup ) ;

		if( type == SURF ) {
			sts = VSgetMatchType( 	msg, 
						&joint->mod_env, 
						jnList,
					      	compCount,
						VS_K_plTopSfPath,
					 	plate1,
						&type);
			__CheckRC( sts, *msg, "VSgetMatchType", wrapup ) ;

		}

		if( type == SURF ) 		pl1Type = SURF ;
		else if ( type == EDGE ) 	pl1Type = EDGE ;
	

		if( pl0Type == SURF ) {
		    if( pl1Type == SURF )	     *jnType = VS_K_SURF_SURF;
			else if( pl1Type == EDGE )   *jnType = VS_K_SURF_EDGE;
		} else if( pl0Type == EDGE ) {
		    if( pl1Type == SURF ) 	     *jnType = VS_K_EDGE_SURF;
			else if( pl1Type == EDGE )   *jnType = VS_K_EDGE_EDGE;
		}
		
	} else {
		*msg = OM_E_INVARG ;
		goto wrapup;
	}
wrapup :
	return sts ;

} /* VSgiveJointType  */
/*----------------------------------------------------------------------------*/

end implementation Root;
