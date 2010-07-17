
/*************************************************************************
 * I/LOFT
 *
 * File:        src/tools/VLrlocFunk.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLrlocFunk.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:41  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/04/09  21:24:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1997/11/11  14:58:42  pinnacle
# Replaced: src/tools/VLrlocFunk.I for:  by rchennup for loft
#
# Revision 1.2  1997/10/28  15:10:08  pinnacle
# Replaced: src/tools/VLrlocFunk.I for:  by rchennup for loft
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 10/28/97  Rama Rao  Added header
 * 04/09/99  ah        Rama Rao SP08 Fixes
 *************************************************************************/

class implementation GRvg ;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "madef.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "godef.h"
#include "grgsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "parametric.h"
#include "bserr.h"
#include "vlglinedef.h"
#include "vsplatedef.h"
#include "vsstrngproto.h"
#include "nddef.h"
#include "AS_status.h"

#include "bsbasisvect.h"
#include "bsbx2.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsmdistptcv.h"
#include "bsnorvec.h"

#include "maidmx.h"
#include "mainvmx.h"
#include "mamulmx.h"

#include "vlquerydef.h"
#include "vlquery.h"
#include "vsmiscmacros.h"
#include "asbox.h"

from	NDnode		import	NDget_objects;
from	NDmacro		import	ACreturn_foot;
from	NDmacro		import	ACgive_structure;
from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;

from	GRreffile	import	GRgetenvironment;
from	EMSgenbs	import	EMplace_skinning_surface;

from    VSfeature       import  VSgetSupportedElements;
from    VSfeature       import  VSforwardToOriginal;
from    VSfeature       import  VSforwardToSource;
from	VSfeature	import	VSexecuteFunctionInFuture;
from	VSfeature	import	VSexecuteFunctionAlongGeneration;

extern	GRclassid	OPP_GRgraphics_class_id;
extern	GRclassid	OPP_ACncpx_class_id;
extern	GRclassid	OPP_GRreffile_class_id;
extern	GRclassid	OPP_EMSgenbs_class_id;
extern	GRclassid	OPP_GR3dcircle_class_id;
extern	GRclassid	OPP_ACpretend_class_id;
extern	GRclassid	OPP_GRpart_class_id;

extern	IGRdouble	fabs();

extern	IGRint		LCevaction();

/*----------------------------------------------------------------------------*/
static long VLaddElemQList( elemList, elemId, elemEnv )

struct VLqList		*elemList;
struct GRid		*elemId;
struct GRmd_env 	*elemEnv; 
{

	if( elemList->count == elemList->max ){

		elemList->max += elemList->incre;
		if( elemList->list )
			elemList->list = (struct GRobj_env *)realloc(
					elemList->list,
					elemList->max * 
						sizeof(struct GRobj_env));
		else	elemList->list = (struct GRobj_env *)malloc(
					elemList->max * 
						sizeof(struct GRobj_env));
		if( elemList->list == NULL ){

			printf(" ERROR : not enought memory to allocate list\n");
			return	FALSE;
		}
	}

	(elemList->list)[elemList->count].obj_id  = *elemId ;
	(elemList->list)[elemList->count].mod_env = *elemEnv ;
	(elemList->count)++ ;

return	TRUE;
}
/*----------------------------------------------------------------------------*/
int VLrLocate_LCAH (	struct	VLqList	*LCargs,
			struct	GRlc_info	*entry,
			struct	LC_action_args	*args,
			enum	GRlocate_action	*action	)
{
		IGRint	env_flag=0;

	switch( *action ) {
		case add_all	 :
		case add_inside  :
		case add_outside :
		case add_overlap :
			VLaddElemQList ( LCargs, &entry->located_obj,
					  &entry->module_info );
		case add_nopost  :
			return LC_ACCEPT_ONE_ACTION;
		default 	 :
			return LCevaction ( (IGRchar *) LCargs,
					    entry, args, action, &env_flag );
	}
}
/*----------------------------------------------------------------------------*/
long VLrLocate( msg, range, count, list, st_env )

long			*msg;
GRrange 		range;
int			*count;
struct	GRobj_env	**list; 
struct	GRmd_env	*st_env;

{

long			sts, no_msg;	/* OM completion code.	      */
int			i,		/* Loop index.		      */
			size,		/* For gr$get_chord_ ...      */
			nret,		/* ... height_tolerance.      */
			layers[DP_NUM_OF_LEVELS/32 + 1];
double			point[5*3] ;	/* Bottom face definition of  */
					/* right prism. 	      */
struct	GRlc_rp_loc	rp_params ;	/* Right prism parameters.    */
enum	GRlocate_types	loc_type ;	/* Locate type for macro      */
					/* lc$query (locate elements).*/
struct VLqList		act_parms ;	/* Argument of action handler.*/

OM_S_CLASSLIST		classList;
GRclassid		clid;
struct GRlc_classes	classL;
struct	GRid		OBJ, part;


	/*| initialization */
	*count = 0 ;
	*list  = NULL;
	classList.w_flags	= OM_CLST_subclass;
	classList.w_count	= 1;
	clid			= OPP_GRgraphics_class_id;
	classList.p_classes	= &clid;
	classL.rtree_classes    = &classList;
	classL.eligible_classes = &classList;

	act_parms.count = 0;
	act_parms.max	= 0;
	act_parms.incre = 100;
	act_parms.list	= NULL ;


	// get reference file attachement into the current file
	// to get PDU reference file attachement
	OBJ.osnum	= st_env->md_id.osnum;
	for( OBJ.objid = 0; OBJ.objid<OM_GA_OSDs[OBJ.osnum]->CurSpaceMapSize; 
								OBJ.objid ++){
		if( vs$is_ancestry_valid(
			object  = &OBJ,
			classid = OPP_GRreffile_class_id ) ){

			// get owner	
			sts = om$get_objid_at_index(
					objid		= OBJ.objid,
					osnum		= OBJ.osnum,	
					p_chanselect	= &AS_to_owner,
					index 		= 0,
					objidaddr	= &part.objid,
					osnumaddr	= &part.osnum );

			if( (sts&1) && vs$is_ancestry_valid(
					object 	= &part,
					classid	= OPP_GRpart_class_id ))
				VLaddElemQList( &act_parms, &OBJ, st_env );
		}
	} // end get ref

	loc_type = GR_rp_loc ;
 
	rp_params.obj_attr.properties	= LC_LC_ONLY | LC_DP_ONLY | LC_RW;

	rp_params.obj_attr.owner_action =
			LC_RIGID_OWNER | LC_FLEX_OWNER | LC_REF_OBJECTS;

	size = sizeof( double ) ;
	sts = gr$get_chord_height_tolerance( msg    = msg,
					     sizbuf = &size,
					     buffer = &rp_params.tolerance,
					     nret   = &nret ) ;

	co$build_button( msg	= msg,
			 button = &rp_params.datapoint ) ;

	MAidmx( msg, rp_params.rt_prism.matrix ) ;
	rp_params.rt_prism.matrix[11] = range[2] ;

	rp_params.rt_prism.polygon.num_points = 5 ;
	rp_params.rt_prism.polygon.points     = point ;

	for( i=0; i<5; i++ ) {
		point[i*3]   = range[0];
		point[i*3+1] = range[1];
		point[i*3+2] = 0 ;
	}

	point[3] = point[6]  = range[3] ;
	point[7] = point[10] = range[4] ;

	rp_params.rt_prism.height = fabs( range[5] - range[2] ) ;

	memcpy( rp_params.upd_range, range, 6 * sizeof( double ) ) ;

	rp_params.is_ortho = TRUE ;
//	rp_params.prism_attr = GO_OUTSIDE | GO_INSIDE | GO_OVERLAP;
	rp_params.prism_attr = GO_INSIDE | GO_OVERLAP;

	for( i=0; i<DP_NUM_OF_LEVELS/32 + 1; i++ ) layers[i] = 0xffffffff ;

	sts = lc$query( rc		= msg,
			mod		= st_env,
			locate_type	= &loc_type,
			loc_parms	= (char *) &rp_params,
			act_handler	= VLrLocate_LCAH,
			act_parms	= &act_parms,
			classptr	= &classL,
			levels		= layers );
	if( ! (sts & *msg & 1)){ sts = MSFAIL; goto wrapup; }

	// return locate data
	*count = act_parms.count ;
	*list  = act_parms.list ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

wrapup :

	lc$check_id ( rc   = &no_msg,
		      mode = LC_DELETE );

	if( !( sts & 1 & (*msg) )){
		if(*list)	free(*list);
		*count = 0;
		*list  = NULL;
	}

return sts ;
}
/*----------------------------------------------------------------------------*/


/* *************** FCT VLrLocRef() ***********************************	*/
/* Locate element(only owner) into the given range, even if a reference file is 
/* include into the range.
/* This function allocate the list returned objects. 
/* 
/* FCT RETURN : 	MSSUCC or MSFAIL
/* */

long VLrLocRef( range, count, list, st_env )

GRrange 		range;		/* I  : Range			*/
int			*count;		/* O  : number			*/
struct	GRobj_env	**list; 	/* O  : List of objects found	*/
struct	GRmd_env	*st_env;	/* I  : Start environment definition */

{
long			sts, msg;
int			i,j,k;
GRclassid		clid;
struct	GRmd_env	newEnv;
double			invMat[16];
struct	GRobj_env	*newList;
int			newCount;
GRrange			newRange;
struct	GRobj_env	*locList;
int			locCount;
short			four = 4;


	/* Initialization */
	newList		= NULL;
	newCount 	= 0;
	locList		= NULL;
	locCount	= 0;


	// send VLrLocate with st_env
	sts = VLrLocate(&msg, range, count, list, st_env);
	if( ! (sts & msg & 1)){ sts = MSFAIL; goto wrapup; }

	// check reference file
	for( i=0; i<*count; i++ ){

		om$get_classid(	osnum		= (*list)[i].obj_id.osnum, 
				objid		= (*list)[i].obj_id.objid, 
				p_classid	= &clid );
		if( om$is_ancestry_valid(
				subclassid	= clid,
				superclassid	= OPP_GRreffile_class_id)
						== OM_S_SUCCESS ){

			// get element in file.
			sts = om$send(	msg	 = 
				message GRreffile.GRgetenvironment
						( &msg, st_env, &newEnv ),
					targetid = (*list)[i].obj_id.objid,
					targetos = (*list)[i].obj_id.osnum,
					senderid = NULL_OBJID );
			if( ! (sts & msg & 1))	continue;

			MAinvmx(&msg, &four, newEnv.md_env.matrix, invMat);
			if( ! (sts & msg & 1))	continue;
			
			VLxformRange(invMat, range, newRange);

			newEnv.md_env.matrix_type = MAIDMX;
			MAidmx( &msg, newEnv.md_env.matrix);
			sts = VLrLocRef(newRange, &newCount, &newList, &newEnv);
			if( ! (sts&1) || ! newCount  )	continue;

			// realloc list
			locCount = *count + newCount - 1;
			locList = (struct GRobj_env *)malloc(
					locCount * sizeof(struct GRobj_env));
			if( ! locList ){
				printf(" Error : not enought memory to allocate locList \n");
				*count 	= 0;
				*list	= NULL;
				sts = MSFAIL;
				goto wrapup;
			}

			for(j=0; j<i; j++)	
				locList[j] = (*list)[j];
			for(j=i,k=0; k<newCount; j++,k++)
				locList[j] = newList[k];
			for(j=i+newCount,k=i+1; j<locCount; j++,k++)
				locList[j] = (*list)[k];
	
			i += newCount - 1;

			if( *list )	free( *list );
			if( newList ){ free( newList ); newList = NULL; }
			*list	= locList;
			*count	= locCount;
		} 
	}

	sts = MSSUCC;

wrapup :

return	sts;
}

/* ******************** FCT VLxformRange () **************************	*/

long VLxformRange(mat, inRange, outRange)

double	*mat;
GRrange	inRange, outRange;

{
double	col1[4], col2[4], colRes[4];
short	one = 1, four = 4;
long	nbPoints = 8;
double	Point[24];
int	i,j,k;
BSrc	rc;
long	msg;

	for(i=0;i<3;i++) col1[i] = inRange[i];
	col1[3]	 = 1;
	for(i=0;i<3;i++) col2[i] = inRange[i];
	col2[0]  = inRange[3];
	col2[3]	 = 1;
	j=0;
	k=4;

	// pt1
	MAmulmx( &msg, &four, &four, &one, mat, col1, colRes );
	for(i=0;i<3;i++) Point[(j*3)+i] = colRes[i];	
	j++;
	MAmulmx( &msg, &four, &four, &one, mat, col2, colRes );
	for(i=0;i<3;i++) Point[(k*3)+i] = colRes[i];	
	k++;

	// pt2
	col1[1] = inRange[4];
	MAmulmx( &msg, &four, &four, &one, mat, col1, colRes );
	for(i=0;i<3;i++) Point[(j*3)+i] = colRes[i];	
	j++;
	col2[1] = inRange[4];
	MAmulmx( &msg, &four, &four, &one, mat, col2, colRes );
	for(i=0;i<3;i++) Point[(k*3)+i] = colRes[i];	
	k++;

	// pt3
	col1[2] = inRange[5];
	MAmulmx( &msg, &four, &four, &one, mat, col1, colRes );
	for(i=0;i<3;i++) Point[(j*3)+i] = colRes[i];	
	j++;
	col2[2] = inRange[5];
	MAmulmx( &msg, &four, &four, &one, mat, col2, colRes );
	for(i=0;i<3;i++) Point[(k*3)+i] = colRes[i];	
	k++;
	
	// pt4
	col1[1] = inRange[1];
	MAmulmx( &msg, &four, &four, &one, mat, col1, colRes );
	for(i=0;i<3;i++) Point[(j*3)+i] = colRes[i];	
	j++;
	col2[1] = inRange[1];
	MAmulmx( &msg, &four, &four, &one, mat, col2, colRes );
	for(i=0;i<3;i++) Point[(k*3)+i] = colRes[i];	
	k++;

	BSbx2( &rc, &nbPoints, (IGRpoint *)Point, NULL,
	       &outRange[0], &outRange[3] );

return	MSSUCC;
}

/* ********************* FCT VLgetStifAtStep () *****************	*/

int VLgetStifAtStep( const struct GRid *curPlt, 
				struct VLlistElmtId *cumulatedList )

{
long		sts, msg;
struct	GRid	*locStif;
int		locCount;
int		i, j;


	/* Initialization */
	locStif		= NULL;
	locCount	= 0;

	sts = om$send(	msg	= message VSfeature.VSgetSupportedElements(
					&msg,
					TRUE,
					&locCount,
					&locStif ),
			targetid = curPlt->objid,
			targetos = curPlt->osnum,
			senderid = NULL_OBJID );

	if( ! (sts&msg&1) || ! locCount )	return	TRUE;

	// cumulate result
	if( ! (*(cumulatedList->pList))){ 
		*(cumulatedList->pList)  = locStif; 
		*(cumulatedList->pCount) = locCount; 
		return	TRUE;
	}

	// realloc *pList
	*(cumulatedList->pList) = (struct GRid *) realloc( 
		*(cumulatedList->pList),
		sizeof(struct GRid) * (locCount + *cumulatedList->pCount ));
	if( ! (*(cumulatedList->pList))){
		printf(" Error : not enought memory to allocate resList\n");
		return	FALSE;
	} 

	for( i=*(cumulatedList->pCount), j=0; j<locCount; j++, i++ ) 
		(*(cumulatedList->pList))[i] = locStif[j];

	*(cumulatedList->pCount) += locCount;

	//free memory
	if( locStif )	free( locStif );

return	TRUE;
}

/* ********************* FCT VLgetStifByTree() **********************	*/
/* This function generate the list of stiffner attached to the input plate
/*
/* FCT RETURN : 	MSSUCC or MSFAIL 
/* */

long	VLgetStifByTree( plate, count, list )

struct	GRobj_env	*plate;		/* I  : Plate	*/
int			*count;		/* O  : Number of objects in list */
struct	GRobj_env	**list;		/* O  : List of object		  */

{
long			sts;

//	extern	int	VLgetStifAtStep();
//	extern	long	VLbrowseFctInTree();

	/* Initialization */
	*list	= NULL;
	*count	= 0;

	sts = VLbrowseFctInTree( plate, VL_Q_TOP_ORIGINAL, NULL,
				VL_Q_DOWN_DIRECT | VL_Q_DOWN_AFTER, 
				VLgetStifAtStep,
				count, list );

return	sts;
}

/* ********************* FCT VLgetMacrosAtStep () *****************	*/
/* Returns all associative element attached to this Associative Node
/* directly or via a Pretend(in).
/* */

int VLgetMacrosAtStep( const struct GRid *step, 
				struct VLlistElmtId *cuList )
{
long		sts, msg;
int		count, i, j;
struct	GRid	*pChild;

	/* Initialization */
	pChild	= NULL;
	count	= 0;

	sts = VSgetChildrenGoThruPretends( &msg, step, &count, &pChild );
	if( ! (sts&msg&1))	goto	wrapup;

	// accumulate this elements 
	if( count ){

		// allocate accumulate memory
		if( *(cuList->pList))
			*(cuList->pList) = (struct GRid *) realloc(
				*(cuList->pList),
				sizeof(struct GRid) * 
					(*(cuList->pCount) + count) );

	  	else *(cuList->pList) = (struct GRid *) malloc(
						sizeof(struct GRid) * count );

		if( ! (*(cuList->pList)) ){
			printf(" Error : not enought memory to allocate pList\n");
			return	FALSE;
		}

		for( i=*cuList->pCount, j=0; j<count; i++, j++ )
			(*cuList->pList)[i] = pChild[j];

		*cuList->pCount += count;
	}

wrapup :

	if( pChild )	free( pChild );

return	TRUE;
}

/* ********************* FCT VLgetStepInfo () *****************	*/
/* Return info on the current state
/* */

int VLgetStepInfo( const struct GRid *step, 
				struct VLlistElmtId *cuList )
{

	// accumulate this elements 
	if( *(cuList->pList))
		*(cuList->pList) = (struct GRid *) realloc(
					*(cuList->pList),
					sizeof(struct GRid) * 
						(*(cuList->pCount) + 1) );

  	else *(cuList->pList) = (struct GRid *) malloc(sizeof(struct GRid));

	if( ! (*(cuList->pList)) ){
		printf(" Error : not enought memory to allocate pList\n");
		return	FALSE;
	}

	(*cuList->pList)[*(cuList->pCount)] = *step;
	(*cuList->pCount) ++;

return	TRUE;
}

/* ************************* FCT VLprintStep () ************************ */
#argsused
int VLprintStep( const struct GRid *step, struct VLlistElmtId *noUsed )
{

	printf(" Step : %d/%d\n", step->objid, step->osnum );

return 	TRUE;
}

/* ********************* FCT VLbrowseFctInTree() **********************	*/
/* This function executes the given function on all nodes include in a 
/* structure history portion.
/*
/* FCT RETURN : 	MSSUCC or MSFAIL 
/* */

long VLbrowseFctInTree
(
struct	GRobj_env	*entry,		/* I  : Entry node in the history */
short			topProps,	/* I  : Define top limit 	  */
struct	GRobj_env	*limId,		/* I  : limit object if known else
						NULL (entry is taken)     */
short			downProps,	/* I  : Define bottom limit	  */ 
int			(*fct)(),	/* I  : function to brouse	  */
int			*count,		/* O  : Number of objects in list */
struct	GRobj_env	**list		/* O  : List of object		  */
)

{
long			sts, msg;
struct	GRid		*mc;
int			i;
struct	VLlistElmtId	fctArgs;
struct	GRid		locTarget;


	/* Initialization */
	mc		= NULL;
	*list		= NULL;
	*count		= 0;

	if( limId )	locTarget = limId->obj_id;
	else		locTarget = entry->obj_id;

	fctArgs.pList = &mc;
	fctArgs.pCount = count;

	msg = -2;

	switch( topProps & VL_Q_TOP_LIM_MASK ){

	case VL_Q_TOP_ORIGINAL	:
		sts = om$send(	msg	 =  
			message VSfeature.VSforwardToOriginal(
                                             &msg,
                                             OM_e_wrt_object,
			message VSfeature.VSexecuteFunctionAlongGeneration(
				downProps & VL_Q_DOWN_DIRECT ? 
							&entry->obj_id : NULL,
				fct,
				(void*)&fctArgs,
				downProps & VL_Q_DOWN_AFTER )),
                      targetid	= locTarget.objid,
                      targetos	= locTarget.osnum,
                      senderid	= NULL_OBJID );
		break;

	case VL_Q_TOP_SOURCE	:
		sts = om$send(	msg	 =  
			message VSfeature.VSforwardToSource(
                                             &msg,
                                             OM_e_wrt_object,
			message VSfeature.VSexecuteFunctionAlongGeneration(
				downProps & VL_Q_DOWN_DIRECT ? 
							&entry->obj_id : NULL,
				fct,
				(void*)&fctArgs,
				downProps & VL_Q_DOWN_AFTER )),
                      targetid	= locTarget.objid,
                      targetos	= locTarget.osnum,
                      senderid	= NULL_OBJID );
		break;

	case VL_Q_TOP_CURRENT	:
	default			:
		sts = om$send(	msg	 =  
			message VSfeature.VSexecuteFunctionAlongGeneration(
				downProps & VL_Q_DOWN_DIRECT ? 
							&entry->obj_id : NULL,
				fct,
				(void*)&fctArgs,
				downProps & VL_Q_DOWN_AFTER ),
                      targetid	= locTarget.objid,
                      targetos	= locTarget.osnum,
                      senderid	= NULL_OBJID );
		if( sts & 1 )	msg	= MSSUCC;
	}

	if( msg == -2 ){

		// proccess function on current AS node.
		sts = fct( &locTarget, &fctArgs );
		if( sts & 1 )	msg	= MSSUCC;
	}

	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

	// build GRobj_env list
	if( *count ){
		*list = (struct GRobj_env *) malloc 
					(*count * sizeof(struct GRobj_env));
		if( ! (*list)){

			printf(" Error : Not enought memory to allocate list\n");
			sts = MSFAIL;
			goto	wrapup;
		}
	}

	for(i=0; i<*count; i++){

		(*list)[i].obj_id	= mc[i];
		(*list)[i].mod_env	= entry->mod_env; 
	}

	sts = MSSUCC;

wrapup :

	if( mc )	free( mc );

return	sts;
}

/* ************************ FCT VLinterList() *********************	*/
/* This function return the intersection of two listes.			*/
/*
/* Remark : The first input list can be used for output list.
/* */

void VLinterList( len1, l1, len2, l2, fct_test, count, lint )

int			len1, len2;	/* I  : Length of input listes	*/
struct	GRobj_env	*l1, *l2;	/* I  : input list		*/
int			*count;		/* O  : Length of output list	*/
struct	GRobj_env	*lint;		/* O  : ouput list		*/
int			(*fct_test)();	/* I  : function use for test	*/

{
int	i, j;

	/* Initialization */
	*count	= 0;

	for(i=0; i<len1; i++)
		for(j=0; j<len2; j++)
			if( fct_test(&l1[i],&l2[j]) ){
				lint[(*count)++] = l1[i];
				break;
			}
}

/* ********************** FCT VLtstObjEnv() **************************	*/
/* Test the equality of two structure GRobj_env.
/*
/* FCT RETURN : TRUE is the 2 structures are equal else FALSE; 
/* */

int VLtstObjEnv( atom1, atom2 )

struct	GRobj_env	*atom1, *atom2;		/* I  : input structures */

{
return	atom1->obj_id.objid == atom2->obj_id.objid && 
	atom1->obj_id.osnum == atom2->obj_id.osnum;
}

end implementation GRvg ;
