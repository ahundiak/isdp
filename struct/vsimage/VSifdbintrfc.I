/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include <string.h>
#include <math.h>
#include "OMmacros.h"
#include "madef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
void VSimgMapAttrValues( OM_S_OBJID myId, OMuword myOS, char *s ) {

	long		sts ;
	struct GRid	mdlId ;
	struct GRmd_env	mdlEnv ;

	if(    ( '+' == s[0] || '-' == s[0] )
	    && ( 'x' == s[1] || 'y' == s[1] || 'z' == s[1] )
	    && ! s[2] ) {
	  IGRvector v, iv ;
	  int       d = '+' == s[0] ? 1 : -1 ;
	  switch( s[1] ) {
	    case 'x' : v[0] = d ; v[1] = 0 ; v[2] = 0 ; break ;
	    case 'y' : v[0] = 0 ; v[1] = d ; v[2] = 0 ; break ;
	    case 'z' : v[0] = 0 ; v[1] = 0 ; v[2] = d ; break ;
	  }
	  sts = om$send( msg      = message VSimgFeature.VSgetModel(
							      &mdlId, &mdlEnv ),
			 targetid = myId, targetos = myOS, senderid = NULL_OBJID ) ;
	  if( !( sts & 1 ) ) return ;
	  VSmxprodvc( mdlEnv._MATRIX, v, iv ) ;
	  { double absX = fabs( iv[0] ),
	           absY = fabs( iv[1] ),
	           absZ = fabs( iv[2] ) ;
	    if( absX > absY ) {
	      if( absX > absZ ) {
	        s[0] = iv[0] >= 0 ? '+' : '-' ;
	        s[1] = 'x' ;
	      } else {
	        s[0] = iv[2] >= 0 ? '+' : '-' ;
	        s[1] = 'z' ;
	      }
	    } else if( absY > absZ ) {
	      s[0] = iv[1] >= 0 ? '+' : '-' ;
	      s[1] = 'y' ;
	    } else {
	      s[0] = iv[2] >= 0 ? '+' : '-' ;
	      s[1] = 'z' ;
            }
	  }
	}

} /* VSimgMapAttrValues */
/*----------------------------------------------------------------------------*/
method ACgive_db_structure(	int			*ok,
							*notUsed ;
				char			*keyWord ;
				struct ret_struct	*attr ;
				struct GRmd_env		*myEnv ) {

	long		sts ;		/* OM return code	*/
	long		msg ;
	struct GRmd_env	modelEnv ;	/* Model of this image	*/
	struct GRid	modelId ;	/* ... and its env.	*/
	struct GRid	usrAttr ;	/* User attributes	*/

	/*
	 * First check if it is not one of our own user attributes.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetUsrAttributes(
							&msg, &usrAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "VSfeature.VSgetUsrAttribute", wrapup ) ;

	if( !IF_NULL_OBJID( usrAttr.objid ) ) {
		sts = om$send( 	msg	= message NDmacro.ACgive_structure(
							ok, notUsed, keyWord,
							attr, myEnv ),
				targetid= usrAttr.objid,
				targetos= usrAttr.osnum ) ;
		/*
		 * If success you are done, otherwise there was no attribute
		 * with name `keyWord' among the user attributes, then go on
		 * and ask your model.
		 */
		if( sts & 1 & *ok ) goto wrapup ;
	}

	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
							&modelId, &modelEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *ok = FALSE ; goto wrapup ; }

	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmulmx(	myEnv->_MATRIX,
				modelEnv._MATRIX,
				modelEnv._MATRIX,
				&modelEnv._MATRIX_TYPE ) ;
	}

	sts = om$send(	msg	= message ACdb_info.ACgive_db_structure(
								ok,
								notUsed,
								keyWord,
								attr,
								&modelEnv ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	__CheckRC( sts, *ok, "ACdb_info.ACgive_db_structure", wrapup ) ;

	if( !strcmp( keyWord, VS_K_prMbrNamAttr ) ) {
		/*
		 * Add something at the end to reflect that you are an image
		 * and not the original.
		 */
		int	max = sizeof attr->var.text_st.text_string,
			len = strlen( attr->var.text_st.text_string ),
			trunc ;

		VSstrncpy(	attr->var.text_st.text_string + len,
				"_image",
				max - strlen( "_image" ),
				&trunc ) ;
	}

	/*
	 * If an attribute has value "+x", "-x", "+y", "-y", "+z", "-z",
	 * and was obtained FROM THE MODEL, these values are relative to
	 * the model and therefore must be translated according to the
	 * position of the image.
	 */
	VSimgMapAttrValues( my_id, OM_Gw_current_OS,
	                    attr->var.text_st.text_string ) ;
 
	wrapup :
		return sts ;

} /* method ACgive_db_structure */
/*----------------------------------------------------------------------------*/
method ACget_db_info(	long			*msg ;
			struct ACdb_info	*dbInfo ; ) {

	long		sts ;		/* OM return code	*/
	struct GRid	modelId ;	/* Model of this image	*/

	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
							&modelId, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg 	= message ACdb_info.ACget_db_info(
								msg, dbInfo ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	__CheckRC( sts, *msg, "ACdb_info.ACget_db_info", wrapup ) ;

	dbInfo->serial_no = my_id ;

	wrapup :
		return sts ;

} /* method ACget_db_info */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
