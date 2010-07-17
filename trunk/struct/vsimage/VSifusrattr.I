/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h" 

from ACrg_collect import	ACget_attribute_at_index,
				AClist_attribute,
				ACmod_list_attribute ;
/*----------------------------------------------------------------------------*/
method VSgetUsrAttributes( long *msg ; struct GRid *p_UsrAttr ) {

	long		sts ;	/* OM return code	*/
	struct GRid	model ;
	struct GRid	UAid ;

	sts = om$send(	msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, p_UsrAttr ),
			targetid= my_id ) ;
	if( sts & 1 & *msg ) goto wrapup ;

	/*
	 * I do not have user attributes, let's see if my parent has any.
	 */
	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
								&model, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "VSimgFeature.VSgetModel", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
								 msg, &UAid ),
			targetid= model.objid,
			targetos= model.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetUsrAttributes", wrapup ) ;

	if( *msg != EMS_I_Fail ) {
	  int		 size ;
	  int		 i ;
	  struct ACrg_coll oneAttr ;
	  /*
	   * Put them to yourself: this message will connect a
	   * collection of user attributes to me as a 3rd parent.
	   */
	  sts = om$send( msg      = message VSfeature.VSputUsrAttributes(
								 msg, &UAid ),
			 targetid = my_id ) ;
	  __CheckRC( sts, *msg, "VSfeature.VSputUsrAttributes", wrapup ) ;

	  /*
	   * Get the id of YOUR collection of user attributes (it might
	   * be different from "UAid").
	   */
	  sts = om$send( msg     = message VSfeature.VSfindCollection(
					      msg, VS_K_prUsrAttr, p_UsrAttr ),
			 targetid= my_id ) ;
	  __CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	  /*
	   * If an attribute has value "+x", "-x", "+y", "-y", "+z", "-z",
	   * and was obtained FROM THE MODEL, these values are relative to
	   * the model and therefore must be translated according to the
	   * position of the image.
	   */
	  sts = om$send( msg	  = message ACrg_collect.AClist_attribute(
							msg, 0, NULL, &size ),
			 targetid = p_UsrAttr->objid,
			 targetos = p_UsrAttr->osnum ) ;
	  __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;

	  for( i = 0 ; i < size ; i++ ) {
	    sts = om$send(
			msg	= message ACrg_collect.ACget_attribute_at_index(
							     msg, i, &oneAttr ),
			targetid= p_UsrAttr->objid,
			targetos= p_UsrAttr->osnum ) ;
	    __CheckRC( sts, *msg, "ACrg_collect.ACget_attribute_at_index", next ) ;

	    if( AC_ATTRIB_TEXT == oneAttr.desc.type ) {
	      VSimgMapAttrValues( my_id, OM_Gw_current_OS,
	                          oneAttr.desc.value.att_txt ) ;
	      sts = om$send(
			msg	= message ACrg_collect.ACmod_list_attribute(
							     msg, 1, &oneAttr ),
			targetid= p_UsrAttr->objid,
			targetos= p_UsrAttr->osnum ) ;
	      __CheckRC( sts, *msg, "ACrg_collect.ACmod_list_attribute", next ) ;
	    }
            next: ;
	  }
	} else {
		/*
		 * Parent has no user attributes.
		 */
		p_UsrAttr->objid = NULL_OBJID ;
		*msg	= EMS_I_Fail ;
		sts	= OM_S_SUCCESS ;
	}

	wrapup :
		return sts ;

} /* method VSgetUsrAttributes */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

