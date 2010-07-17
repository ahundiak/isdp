/* $Id: VSbmgivestrc.I,v 1.4 2002/03/06 15:56:08 jayadev Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbmgivestrc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmgivestrc.I,v $
 *      Revision 1.4  2002/03/06 15:56:08  jayadev
 *      added TR# number
 *
 *      Revision 1.3  2002/03/06 15:52:44  jayadev
 *      fix for etl#12395
 *
 *      Revision 1.2  2001/11/09 23:28:12  ramarao
 *      Implemented CR# 3976.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:11  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/03/25  15:08:38  pinnacle
# TR179800336
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/25/98        Manoj           ref: TR#179800336
 *      03/06/02        Jayadev         TR# 6113
 ***************************************************************************/


class implementation VSbeam ;

#Include <string.h>
#include "ACrg_collect.h"
#include "vsRDBdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsbeammacros.h"
#include "vsbeamdef.h"

#define TRUE	1
#define	FALSE	0


#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )
from ACrg_collect	import ACget_named_attribute ;
/*
 * The function VSgetAttrValue () was written to solve 
 * TR # 179800336
 */
long VSgetAttrValue( struct GRid bmObj, char *attrName , struct ACrg_coll *list_attr) {
	long			msg, sts ;
	struct GRid		UAid ;

	UAid.objid = NULL_OBJID ;
	/*
	 * From the beam object get the User attribute collection object.
	 * If the user attribute collection object doesn't exist, it means that
	 * there are no user attributes and hence cannot have store even 
	 * the overlengths for the beam.
	 */
	sts = om$send( msg	= message VSfeature.VSgetUsrAttributes(
							&msg, &UAid ),
			senderid = NULL_OBJID,
			targetid= bmObj.objid,
			targetos= bmObj.osnum ) ;
	__CheckRC(sts, msg, "VSfeature.VSgetUsrAttributes", wrapup );
	if( UAid.objid == NULL_OBJID ) {
		/*
		 * No user attribute collection
		 */
		goto wrapup ;
	}
	strcpy( list_attr->name, attrName);
	/*
	 * Get the value of the corresponding attribute name 
	 */
	sts = om$send( msg 	= message ACrg_collect.ACget_named_attribute(
							&msg, list_attr ),
			senderid = NULL_OBJID,
			targetid = UAid.objid,
			targetos = UAid.osnum );

wrapup :
	return ( sts & msg & 1 ) ? TRUE : FALSE ;
}
/*----------------------------------------------------------------------------*/
method ACgive_structure(	int			*ok ,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long			sts,		/* OM completion code	*/
				msg ;		/* Return status	*/
	IGRint 			isPlane, numFaces, i ;
	char			**faceNames = NULL;
	struct GRid		faceObj ;
	IGRshort		matType ;
	IGRmatrix		mat ;
	struct GRid		my_Obj ;
	struct GRobj_env	beamOE;
	long			*descrs = NULL ;

	enum {
		getNothing,	/* Don't do anything		*/
		wrtMsg		/* Send to self wrt message	*/
	} msgType ;
	__DBGpr_str(" Name of attribute", attrName);

	beamOE.obj_id.objid = my_id;
	beamOE.obj_id.osnum = OM_Gw_current_OS;
	if(myEnv) beamOE.mod_env      = *myEnv;
	/*
	 * Get value for "virtual output".
	 * Note that strings are truncated to fit RDB's specification of
	 * character string lengths.
	 */
	if( EQ_STRING( attrName, VS_K_bmLengthAttr ) ) {
	  double	l ;
	  attrVal->type = double_type ;
	  sts = om$send( msg	= message VSbeam.VSgetBeamLength(
							&msg, myEnv, &l ),
			targetid= my_id ) ;

	  if( !( sts & 1 & msg ) ) {
	    l = 0 ;  sts = OM_S_SUCCESS ; msg = MSSUCC ;
	  }

	  attrVal->var.root_pm_st.value = l ;
	  msgType		= getNothing ;

	} else if( EQ_STRING( attrName, VS_K_prMbrGeoAttr ) ) {
	  struct GRobj_env	suppAxis ;
	  VSdspRep              myRep ;
	  struct GRobj_env	suppSf;

	  attrVal->type		= double_type ;
	  msgType		= getNothing ;

	  /*
	   * Initialize beam to be Non Planar
	   */
	  isPlane = FALSE ;

	/*
	 *  old code : Commented for TR # 179527501. Using following
	 *  algorithm for determining if beam is linear, curved or twisted.
	 */

	  sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &myRep ),
                          targetid= my_id ) ;
	  if (!( myRep & AC_3D_REP ) ) {
		  sts = om$send( msg	 = message VSbeam.VSgetSupportSf(
							&msg, myEnv, &suppSf ),
				 targetid= my_id ) ;
		  __CheckRC( sts, msg, "VSbeam.VSgetSupportSf", wrapup ) ;

		  if( vs$is_surface_planar(	msg	= &msg,
						surfId	= &suppSf._grid,
						surfEnv	= &suppSf.mod_env ) ) 
			isPlane = TRUE ;
	  } else {
		  /*
		   * Get all the faces of the Beam
		   */
		  my_Obj.objid = my_id;
		  my_Obj.osnum = OM_Gw_current_OS ;

		  sts = vs$listBeamFaces (	msg 	= &msg,
						beam 	= &my_Obj,
						count 	= &numFaces,
						names 	= &faceNames,
						descrs 	= &descrs );
		  __CheckRC( sts, msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

		  /*
		   * For each face name except last two which are end caps
		   * get its corresponding surface and check if the surface 
		   * is planar. The macro vs$listBeamFaces always gives end 
		   * caps at the end of list.
		   */
		  for (i = 0; i < numFaces-2; i++ ) 
		  {
			sts = om$send ( msg = message NDmacro.ACreturn_foot ( 
							&msg,
							faceNames[i],
							&faceObj,
							&matType,
							mat ),
					targetid = my_id );
			if( ! ( sts & msg & 1) ) 
			{
			/*
			 * Do not be too hard on Failure 
			 */
			sts = om$send( msg = message VSbeam.VSgetSupportSf(
							&msg, myEnv, &suppSf ),
					 	targetid= my_id ) ;
		  	__CheckRC( sts, msg, "VSbeam.VSgetSupportSf", wrapup);

		  	if( vs$is_surface_planar(msg	= &msg,
						 surfId	= &suppSf._grid,
						 surfEnv= &suppSf.mod_env ) ) 
				isPlane = TRUE ;
			break ;
			}

			/*
			 * If any of the surface is planar then set isPlane 
			 * to 1 & b
			 */
			if( vs$is_surface_planar(	msg	= &msg,
							surfId	= &faceObj,
							surfEnv = myEnv ) ) {
				isPlane = TRUE ;
				break;
			}
		}
	  }

	  if( isPlane )
	  {

	    sts = om$send( msg	    = message VSbeam.VSgetSupportAxis(
						    &msg, myEnv, &suppAxis ),
			   targetid = my_id ) ;
	    __CheckRC( sts, msg, "VSbeam.VSgetSupportAxis", wrapup ) ; 

	    if( vs$is_curve_linear(
				msg		= &msg,
				curveId 	= &suppAxis._grid,
				curveEnv	= &suppAxis.mod_env ) ) {
	      attrVal->var.root_pm_st.value = VS_rdb_bmLINEAR ;

	    } else {
	      attrVal->var.root_pm_st.value = VS_rdb_bmCURVED ;
	    }
	  } else {
	    attrVal->var.root_pm_st.value = VS_rdb_bmTWISTED ;
	  }

	} else if( EQ_STRING( attrName, VS_K_bmHeightAttr )
		|| EQ_STRING( attrName, VS_K_bmWidthAttr  )
		|| EQ_STRING( attrName, VS_K_bmFlgThkAttr )
 		|| EQ_STRING( attrName, VS_K_bmWebThkAttr )
		|| EQ_STRING( attrName, VS_K_bmFltRadAttr ) ) {
	  double value ;
	  /*
	   * May be the name of a section parameter.
	   */
	  sts = om$send( msg	 = message VSbeam.VSgetSectionParameter(
					&msg, attrName, myEnv, &value ),
			 targetid= my_id ) ;
	  attrVal->type	= double_type ;
	  msgType	= getNothing ;

	  attrVal->var.root_pm_st.value = sts & 1 & msg ? value : -1 ;

	} else if( EQ_STRING( attrName, VS_K_bmCmpsitAttr ) ) {
	  struct GRid	moi ;

	  moi.objid = my_id ;
	  moi.osnum = OM_Gw_current_OS ;
	  attrVal->type		        = double_type ;
	  attrVal->var.root_pm_st.value = VSisBeamComposite( &moi ) ;
	  msgType = getNothing ;
	}
          /* 
           * Start: to fix TR #179800336
           */   
          else if( EQ_STRING( attrName, VS_K_OVRLENVAL0 ) ) {
		struct GRid		moi ;
		struct ACrg_coll	UAcoll;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;
		attrVal->type = double_type ;
		
		VSgetAttrValue( moi, VS_K_bmOvrLen0Val, &UAcoll) ;
		attrVal->var.root_pm_st.value = UAcoll.desc.value.att_exp ;
	
		msgType = getNothing ;

	}  else if( EQ_STRING( attrName, VS_K_OVRLENVAL1 ) ) {
		struct GRid		moi ;
		struct ACrg_coll	UAcoll;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;
		attrVal->type = double_type ;
		
		VSgetAttrValue( moi, VS_K_bmOvrLen1Val,&UAcoll ) ;
		attrVal->var.root_pm_st.value = UAcoll.desc.value.att_exp ;
		msgType = getNothing ;

	}else if( EQ_STRING( attrName, VS_K_OVRLENPOS0 ) ) {
		struct ACrg_coll	UAcoll;
		struct GRid		moi ;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;
		attrVal->type = text_type ;
		
		VSgetAttrValue( moi, VS_K_bmOvrLen0Pos,&UAcoll ) ;
		strcpy ( attrVal->var.text_st.text_string , UAcoll.desc.value.att_txt );

		msgType = getNothing ;

	}else if( EQ_STRING( attrName, VS_K_OVRLENPOS1 ) ) {
		struct GRid		moi ;
		struct ACrg_coll	UAcoll;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;
		attrVal->type = text_type ;
		
		VSgetAttrValue( moi, VS_K_bmOvrLen1Pos, &UAcoll ) ;
		strcpy ( attrVal->var.text_st.text_string , UAcoll.desc.value.att_txt );
		msgType = getNothing ;
	}  // End: to fix TR 179800336 
	else if( EQ_STRING( attrName, "declivity0" ) ) {
		attrVal->type = double_type ;
		VSstfGetDeclivityAngle( beamOE, 0, 
				&attrVal->var.root_pm_st.value );
		msgType = getNothing ;
	} else if( EQ_STRING( attrName, "declivity1" ) ) {
                attrVal->type = double_type ;
                VSstfGetDeclivityAngle( beamOE, 1, 
                                &attrVal->var.root_pm_st.value );
		msgType = getNothing ;
	}
              else {
	         /*
	          * Not a virtual output: get structure of output from
                  * ancestor class.
                  */	
		msgType = wrtMsg ;		
	}
	switch( msgType ) {
		case wrtMsg	:
		sts = om$send(	msg	= message VSfeature.ACgive_structure(
								ok,
								notUsed,
								attrName,
								attrVal,
								myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		msg = *ok ? MSSUCC : MSFAIL ;
		break ;

		case getNothing	: sts = OM_S_SUCCESS ; msg = MSSUCC ; 
		break ;

		default		: sts = OM_E_INVARG ; msg = MSINARG ; 
		break ;
	}		

	wrapup :

		VSfreeList( numFaces, faceNames );
		_FREE( descrs );
		*ok = ( msg & 1 ) != 0 ;
		return sts ;

} /* method ACgive_structure */
end implementation VSbeam ;

