class implementation ASnode ;

#include "AS_status.h"
#include "exmacros.h"
#include "asbox.h"
#include "madef.h"
#include "OMmacros.h"

#define MAX_ELEMENTS	100
#define AS_DEBUG	1

extern long ASisPtHiddenByElem() ;

from OMindex	import translate ;

/*----------------------------------------------------------------------------*/
long ASgetElemsInRange( msg, osnum, range, count, list )

long		*msg ;		/* Completion code.			*/
OMuword 	osnum ; 	/* OS to get elements.			*/
GRrange 	range ; 	/* Range where elements is.		*/
int		*count ;	/* Count of elements found.		*/
OM_S_OBJID	**list ;	/* List of elements found.		*/

/*.ASgetElemsInRange*/ {

	long			sts ;
	int			i,
				size,
				ret ;
	OM_S_OBJID		mod_id ;
	OM_S_CHANSELECT 	chan ;
	char			name[8] ;
	OM_S_KEY_DESC		rtree_key ;
	DB_3D_DBL_BOX		rtrange ;
	OM_S_OBJARRAY		*obj_array = NULL ;
        int ifois;

	*count = 0 ;
	*list  = NULL ;

	/*
	 * Get module id of given osnum.
	 */
	/*"OS to get elements : %d\n", osnum*/
	ex$get_modid( mod_osnum = osnum,
		      mod_id	= &mod_id ) ;

	/*
	 * Construct channel.
	 */
	strcpy( name, "primary" ) ;
	chan.type	= OM_e_name ;
	chan.u_sel.name = name ;

	/*
	 * Construct R-tree.
	 */
	rtree_key.type		= KEY_3D_DBL ;
	rtree_key.key.p_3ddbl	= &rtrange ;

	rtrange.xmin		= range[0] < range[3] ? range[0] : range[3] ;
	rtrange.ymin		= range[1] < range[4] ? range[1] : range[4] ;
	rtrange.zmin		= range[2] < range[5] ? range[2] : range[5] ;

	rtrange.xmax		= range[0] > range[3] ? range[0] : range[3] ;
	rtrange.ymax		= range[1] > range[4] ? range[1] : range[4] ;
	rtrange.zmax		= range[2] > range[5] ? range[2] : range[5] ;

	/*|Range to get elements*/
	/*"Min : %g %g %g\n", rtrange.xmin, rtrange.ymin, rtrange.zmin*/
	/*"Max : %g %g %g\n", rtrange.xmax, rtrange.ymax, rtrange.zmax*/

	size = MAX_ELEMENTS * sizeof( OM_S_OBJID ) + sizeof( OM_S_OBJARRAY ) ;

for(ifois=0;ifois<2;ifois++) /* twice if size is not enought */
     {
	if( !(obj_array = (OM_S_OBJARRAY *) om$malloc( size = size ) ) ) {
		*msg	= MSFAIL ;
		sts	= OM_E_NODYNMEM ;
		goto wrapup ;
	}

	obj_array->size 	= size ;
	obj_array->count	= 0 ;
	obj_array->tree_type	= KEY_3D_DBL ;

	/*
	 * Find objects.
	 */
	sts = om$send( msg	= message OMindex.translate( obj_array,
							     &rtree_key,
							     NULL,
							     NULL,
							     &ret ),
		       senderid     = mod_id,
		       targetos     = osnum,
		       p_chanselect = &chan ) ;

	if( !(sts & 1) ) *msg = MSFAIL ;
	as$status( sts =  sts, action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;


	/* again if size is not enought */
	if(ifois == 1 || obj_array->count <= MAX_ELEMENTS) break;

	/*" realloc for %d elem \n",obj_array->count */ 
	size=obj_array->count * sizeof( OM_S_OBJID ) + sizeof( OM_S_OBJARRAY);
	if( obj_array ) om$dealloc( ptr = obj_array ) ;
      }

	/*
	 * Return elements found.
	 */
	/*"Count of elements found : %d\n", obj_array->count*/
	*count = obj_array->count ;

	OM_BLOCK_MOVE(obj_array->array,obj_array,*count*sizeof(OM_S_OBJID));
	*list = (OM_S_OBJID *) obj_array;
	*msg = MSSUCC ;
	return OM_S_SUCCESS;
	

	wrapup :
		if( obj_array ) om$dealloc( ptr = obj_array ) ;
		*list = NULL;
		*count = 0;
		return  OM_W_ABORT ;

} /* ASgetElemsInRange */
/*----------------------------------------------------------------------------*/
int ASisElemVisible( msg, element, macro, count, list_drawing, viewVect)

long		*msg ;		/* Completion code.			*/
struct GRid	*element ;	/* Element to check.			*/
struct GRid	*macro ;	/* Macro of element.			*/
int		count ; 	/* Size of list.			*/
struct GRid	*list_drawing ; /* List of availables elements. 	*/
IGRvector	viewVect ;	/* View vector. 			*/

/*.ASisElemHidden*/ {

	long		sts ;
	int		i,
			j,
			nbNeighbor,
			test ;
	short		world = FALSE ;
	GRrange 	range ;
	struct GRid	go,
			elem,
			owner,
			top_owner ;
	OM_S_OBJID	*neighbor = NULL;
	struct GRmd_env elemEnv ;
	IGRpoint	center ;
	double		fabs(), extend, delta_range ;
	OMuword 	classid ;
	int		hidden;

extern OMuword OPP_NDnode_class_id ;

	hidden = FALSE ;

	/*"Element to check : [%d,%d]\n", element->osnum, element->objid*/
	/*"Macro	    : [%d,%d]\n", macro->osnum, macro->objid*/

	/*
	 * Get range of element.
	 */
/*	sts = om$send( msg	= message NDnode.ASreturn_go(
/*						    &go,
/*						    &elemEnv.md_env.matrix_type,
/*						    elemEnv.md_env.matrix ),
/*		       senderid = element->objid,
/*		       targetid = element->objid,
/*		       targetos = element->osnum ) ;
/****/
	elemEnv.md_env.matrix_type = MAIDMX;
	MAidmx(msg,elemEnv.md_env.matrix);


	elemEnv.md_id.osnum = element->osnum ;

	ex$get_modid( mod_osnum = elemEnv.md_id.osnum,
		      mod_id	= &elemEnv.md_id.objid ) ;

	sts = om$send( msg	= message GRgraphics.GRgetrang(
						    msg,
						    &elemEnv.md_env.matrix_type,
						    elemEnv.md_env.matrix,
						    &world,
						    range ),
		       senderid = element->objid,
		       targetid = element->objid,
		       targetos = element->osnum ) ;

	as$status( sts =  sts, action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*|Range of element*/
	/*"Min : %g %g %g\n", range[0], range[1], range[2]*/
	/*"Max : %g %g %g\n", range[3], range[4], range[5]*/

	delta_range = -1;
	for( i=0; i<3; i++ ) {
		center[i] = (range[i+3] + range[i]) *0.5 ;
		extend	    = fabs(range[i+3] - range[i]);
		if(extend > delta_range) delta_range = extend;
	}

	/*"Center of element : %g %g %g\n", center[0], center[1], center[2]*/

	/*
	 * Get neighbors.
	 */
	delta_range *= 1.25;
	for( i=0; i<3; i++ ) {
		range[i]   = center[i] - delta_range*viewVect[i];
		range[i+3] = center[i] + delta_range*viewVect[i];
	}

	/*|Range to get neighbor*/
	/*"Min : %g %g %g\n", range[0], range[1], range[2]*/
	/*"Max : %g %g %g\n", range[3], range[4], range[5]*/

	sts = ASgetElemsInRange( msg,
				 element->osnum,
				 range,
				 &nbNeighbor,
				 &neighbor ) ;

	as$status( sts =  sts, action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*
	 * For each neighbor, see if its top owner hides the element.
	 */
	for( i=0; i<nbNeighbor; i++ ) {

	   /*"Neighbor n'%d : [%d]\m", i, neighbor[i]*/

	   elem.osnum = element->osnum;
	   elem.objid = neighbor[i] ;
	   owner = elem;
	   test  = FALSE ;

	   while( 1 ) {

		om$get_classid( objid	  = owner.objid,
				osnum	  = owner.osnum,
				p_classid = &classid ) ;

		if( om$is_ancestry_valid(
			superclassid	= OPP_NDnode_class_id,
			subclassid	= classid ) == OM_S_SUCCESS ) {

			if( owner.objid == macro->objid &&
			    owner.osnum == macro->osnum ) {
				/*|Top owner is macro*/
				test = FALSE ;
				break ;
			}

			top_owner = owner ;
			/*"Top owner : [%d,%d]\n", top_owner.osnum, top_owner.objid*/
			test	  = TRUE ;
		}

		sts = om$get_objid_at_index( osnum	  = owner.osnum,
					     objid	  = owner.objid,
					     p_chanselect = &AS_to_owner,
					     index	  = 0,
					     objidaddr	  = &owner.objid,
					     osnumaddr	  = &owner.osnum ) ;

		if( !( sts & 1 ) ) break ;
	   }

	   if( test ) {
		/*
		 * See if top owner is in given list.
		 */
		/*|Top owner in list*/

		for( j=0; j<count; j++ )
		       {
			sts = om$send(msg = message NDmacro.ACreturn_foot
					(msg,".",&go,NULL,NULL),
				      senderid = NULL_OBJID,
				      targetid = list_drawing[j].objid,
				      targetos = list_drawing[j].osnum);
			if(!(sts&*msg&1)) continue;

			if( top_owner.osnum == go.osnum &&
			    top_owner.objid == go.objid ) break ;
		       }

		if( j<count ) {
			/*| -> Yes*/

			sts = ASisPtHiddenByElem( msg,
						  &elem,
						  &elemEnv,
						  center,
						  viewVect,
						  &hidden ) ;

			as$status( sts =  sts, action = GOTO_VALUE,
				   value = wrapup ) ;
			as$status( sts = *msg, action = GOTO_VALUE,
				   value = wrapup ) ;

			if( hidden ) break ;
		} else {
			/*| -> No*/
		}
	   }
	}

	wrapup :
		if( neighbor ) om$dealloc( ptr = neighbor ) ;
		/*"HIDDEN ? %d\n", hidden*/
		return hidden ? FALSE : TRUE ;

} /* ASisElemHidden */
/*----------------------------------------------------------------------------*/

end implementation ASnode ;
