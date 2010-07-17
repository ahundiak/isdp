/* $Id: VSferetnfoot.I,v 1.2 2001/02/22 16:18:28 ramarao Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsfeature/VSferetnfoot.I        
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: VSferetnfoot.I,v $
*      Revision 1.2  2001/02/22 16:18:28  ramarao
*      Removed unnecessary debugs.
*
*      Revision 1.1.1.1  2001/01/04 21:10:37  cvs
*      Initial import to CVS
*
# Revision 1.4  2000/03/31  14:41:56  pinnacle
# Replaced VSferetnfoot.I by jpulapar
#
# Revision 1.3  2000/03/24  17:48:30  pinnacle
# ah
#
# Revision 1.2  1999/11/12  19:43:04  pinnacle
# tr179900782
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      09/28/99  Jayadev Changes made for TR179900782 - Introduced functions
*                        VScheckCaps and VScheckComps
*
*	03/24/00 ah	Removed VDgeom2.h
***************************************************************************/
class implementation VSfeature ;

#include <string.h>
#include <math.h>
#include "exmacros.h"
#include "madef.h"
#include "macro.h"
#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "VDtypedef.h"
#include "VDchn.h"
#include "VDvla.h"
#include "VDvla2.h"
#include "vsattr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VDgeom.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern long	VSmakeUnitPretend __(( struct GRid * )) ;
extern char	DIR_G_car_dir ;
extern  GRclassid       OPP_EMSplane_class_id;

from ACrg_collect import ACget_named_attribute ;
from VSbeam       import VSgetSegmentEnds ;
from VSbeam       import VSgetSupportAxis;
from EMSplane     import EMplaneDef;
/*----------------------------------------------------------------------------*/

IGRboolean VScheckCaps(struct GRid *beam,struct GRid *face,int faceFlag)
{
  int                   retFlag = FALSE,ii,jj,bs_res = 0;
  IGRlong               msg       = MSFAIL;
  IGRlong               sts;
  struct GRobj_env      stiffObj,faceOE;
  IGRvector             surf_norm;      /* Unit normal to the beam face */
  BSrc                  rc ;
  double                pointPlane[3],dotp_val=0.0 ;
  struct IGRplane       planeDef ;
  struct GRobj_env      axis;
  struct IGRbsp_curve   *axisBspCrv = NULL;
  IGRdouble             *points=NULL;
  IGRdouble             pars[2],mag0,mag1;
  IGRvector             end_vec[2]; //unit tangent vectors at curve ends
  double                dist1=0.0,dist2=0.0;
  OMuword               face_cl;
 
  stiffObj.obj_id.objid = beam->objid;
  stiffObj.obj_id.osnum = beam->osnum;
  //printf("\n entered VScheckCaps for face[%d,%d] \n",face->objid,face->osnum); 
  VDahGetObjectEnv(beam,&stiffObj);
  if(stiffObj.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // get the end points of the stiffener axis 
  
  sts = om$send( msg = message VSbeam.VSgetSupportAxis(
						       &msg,
						       &stiffObj.mod_env,
						       &axis ),
		 senderid = NULL_OBJID,
		 targetid = stiffObj.obj_id.objid,
		 targetos = stiffObj.obj_id.osnum  );
  if( ! (sts&msg&1)) goto wrapup;
  
  vdgeom$Get2(objOE = &axis, crv = &axisBspCrv);
  pars[0] = 0.0;
  pars[1] = 1.0;
  points = _MALLOC(12, IGRdouble);
  // get the tangents at the ends of the curve
  BScvarreval(&rc,axisBspCrv,pars,2,1,points);
  if ( BSSUCC != rc ) {
    goto wrapup ;
  }
  // get the unit tangent vectors at the ends of the curve
  mag0 = sqrt((points[3]*points[3])+(points[4]*points[4])+(points[5]*points[5]));
  mag1 = sqrt((points[9]*points[9])+(points[10]*points[10])+(points[11]*points[11]));
  
  for(ii=0;ii<3;ii++)
    end_vec[0][ii] = points[ii+3]/mag0; 
  
  for(ii=0;ii<3;ii++)
    end_vec[1][ii] = points[ii+9]/mag1; 
  
  VDahGetObjectEnv(face,&faceOE);
  if(faceOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  planeDef.normal = surf_norm ;
  planeDef.point  = pointPlane ;
 
  sts = om$send( msg = message EMSplane.EMplaneDef(
						   &msg,
						   &faceOE._matrix_type,
						   faceOE._matrix,
						   &planeDef ) ,
		 senderid = faceOE._objid,
		 targetid = faceOE._objid,
		 targetos = faceOE._osnum ) ;
  __CheckRC( sts, msg, "EMSplane.EMplaneDef", wrapup ) ;
  
 //printf("\n point on the plane [%f,%f,%f] \n",pointPlane[0],pointPlane[1],pointPlane[2]); 
  //bs_res = BSdotp( &rc,axis_vec,surf_norm);
  // check to which of the end vectors of the curve is this plane normal to
  
  for(ii=0;ii<3;ii++)
    dist1 += (points[ii] - pointPlane[ii])*(points[ii] - pointPlane[ii]);
  
  for(ii=0;ii<3;ii++)
    dist2 += (points[ii+6] - pointPlane[ii])*(points[ii+6] - pointPlane[ii]);
  
  for(ii=0;ii<2;ii++)
  {
    dotp_val = 0.0;
    bs_res   = 0;

    for(jj=0;jj<3;jj++)
      dotp_val += (end_vec[ii][jj]*surf_norm[jj]);
    
    //printf("\n End_vector : %fi+%fj+%fk \n",end_vec[ii][0],end_vec[ii][1],end_vec[ii][2]);
    //printf("\n Surf_norm  : %fi+%fj+%fk \n",surf_norm[0],surf_norm[1],surf_norm[2]);
    //printf("\n dotproduct value = %f \n",dotp_val);
   
    if(fabs(dotp_val)<0.01) 
    {
      //bs_res = 0;
      continue;
    }
    else if(fabs(fabs(dotp_val) - 1.0) < 0.04) 
    {
      bs_res = 1;
    }
    else continue;
    
    if(bs_res==1)
    {   
        /* Check the face we got */
        om$get_classid ( osnum     = face->osnum,
                         objid     = face->objid,
                         p_classid = &face_cl ) ;
    if(face_cl == OPP_EMSplane_class_id) bs_res = 1;
    }
    else continue; 
    
    if(bs_res==1)
    {
      if(faceFlag==1) //begin cap wanted
      {
	// the point on the face should be closest to end_pt[1] of stiffener
	if(dist2<dist1)
	{
	  retFlag = TRUE;
	  goto wrapup;
	} 
      }
      else if(faceFlag==2) //end cap wanted
      {
	// the point on the face should be closest to end_pt[0] of stiffener
	if(dist1<dist2)
	{
	  retFlag = TRUE;
	  goto wrapup;
	} 
      }
      else goto wrapup;
      
    }
  }
wrapup:
  return retFlag;
}

int VScheckComps( struct GRid *beam, char *capName,struct GRid *capID)
{
  int retFlag = FALSE,capFlag = FALSE,ii;
  int beginCap=FALSE,endCap = FALSE,stat = 0;
  struct GRid     gensolID,bmcapID,compID;
  int comp_count = 0;
  int sub_count  = 0;
  TVDvlaID compVLA,subCmpVla;
  struct GRid   beamID;
  
  gensolID.objid = NULL_OBJID;
  bmcapID.objid  = NULL_OBJID;
  beamID.objid   = NULL_OBJID;
  
  if(!strcmp(capName,"beam:beginCap")) beginCap = TRUE;
  if(!strcmp(capName,"beam:endCap"))   endCap   = TRUE;
  
  vdvla_id$Construct(vla = &compVLA);
  vdvla_id$Construct(vla = &subCmpVla);

  beamID = *beam ;
 
  vdchn$Get2(objID=&beamID,chnIDx = VDCHN_IDX_TO_COMPONENTS,cnt =&comp_count,outVLA=&compVLA);
  if(comp_count == 0) goto wrapup;
  vdvla_id$GetAt(vla = &compVLA,nth = 0,objID = &gensolID);
  if(gensolID.objid == NULL_OBJID) goto wrapup;
  
  vdchn$Get2(objID=&gensolID,chnIDx = VDCHN_IDX_TO_COMPONENTS,cnt =&sub_count,outVLA=&subCmpVla);
  if(sub_count == 0) goto wrapup;
  
  compID.objid = NULL_OBJID;
  
  for(ii=0;ii<sub_count;ii++)
  {
    vdvla_id$GetAt(vla = &subCmpVla,nth = ii,objID = &compID);
    if(compID.objid == NULL_OBJID) goto wrapup;
    
    if(beginCap) 
      capFlag = VScheckCaps(&beamID,&compID,1);
    else if(endCap) 
      capFlag = VScheckCaps(&beamID,&compID,2);
    else  goto wrapup;
    
    if(capFlag)
    { 
      capID->objid = compID.objid;
      capID->osnum = compID.osnum;
      //printf("\n capID[%d,%d] \n",compID.objid,compID.osnum);
      retFlag = TRUE;
      goto wrapup;
    }
    
  }
  
wrapup:
  vdvla_id$Delete(vla = &subCmpVla);
  vdvla_id$Delete(vla = &compVLA);
  return retFlag;
}

method ACreturn_foot(	long		*rc ;
			char		*oNm ;
			struct GRid	*oId ;
			short		*mxType ;
			IGRmatrix	oMx ) {

	long			msg,	/* Completion code		*/
				sts ;	/* OM return code		*/
	int			irc,	/* Yet Another Completion Code	*/
				action ;/* What to do ?			*/
#define	WANT_SELF		0
#define WANT_USRATTR_COLL	1
#define WANT_COLL_MEMBER	2
#define WANT_SUB_CMP		3
#define WANT_SIMPLE_FOOT	4
	char			*sep ;	/* Pointer to dir. separator	*/
	unsigned long		myType ;/* My object type		*/
	struct ret_struct	rs ;	/* Struct of pretend		*/
	struct GRmd_env		myEnv ;	/* My module environment	*/
	struct GRid		myGRid ;
        int                     status2 = FALSE; 
	/*
	 * Now take your pick !.
	 */

	if( sep = strchr( oNm, DIR_G_car_dir ) ) {
		/*
		 * Foot name is <name>:<path> where <path> is <n1>:...:<np>
		 * or possibly empty (ie. foot name is <n>: ).
		 */
		*sep = '\0' ;
		if( !strcmp( oNm, VS_K_prUsrAttr ) ) {
			/*
			 * First component of path is the collection of user
			 * attributes.
			 */
			if( sep[1] ) {
				/*
				 * There's more after the ':', it's a member of
				 * the collection of user attributes.
				 */
					action	= WANT_COLL_MEMBER ;
			} else {
				/*
				 * Path is `VS_K_prUsrAttr:', the collection of
				 * user attributes is wanted.
				 */
					action	= WANT_USRATTR_COLL;
			}
		} else {
			/*
			 * A component of one of our graphic feet is wanted.
			 */
			action = WANT_SUB_CMP ;
		}
		*sep = DIR_G_car_dir ;

	} else if( !*oNm || oNm[0] == '.' && oNm[1] == '\0' ) {
		/*
		 * Path is "" or ".", we want ourself.
		 */
		action	= WANT_SELF ;

	} else if( !strcmp( oNm, VS_K_prUsrAttr ) ) {
		/*
		 * Path is `VS_K_prUsrAttr' (no ending ':'), the collection of
		 * user attributes is wanted.
		 */
		action	= WANT_USRATTR_COLL ;
	} else {
		/*
		 * Just want a simple foot.
		 */
		action = WANT_SIMPLE_FOOT ;
	}

	/*
	 * Action !
	 */
	switch( action ) {

	case WANT_SELF		:
		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
						rc, "", oId, mxType, oMx ),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;
		break ;

	case WANT_USRATTR_COLL	:		
		/*
		 * User attributes : if source part, get parent collection of
		 * user attributes, if modified part, get that of source up in
		 * the consume history.
		 */
		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &myType ),
				targetid= my_id ) ;

		if( !( myType & VS_m_SRC_generic ) ) {

			sts = om$send(
				msg	= message VSfeature.VSforwardToSource(
					rc,
					OM_e_wrt_object,
					message VSfeature.VSgetUsrAttributes(
								&msg, oId ) ),
				targetid= my_id ) ;

		} else {
			sts = om$send(
				msg	= message VSfeature.VSgetUsrAttributes(
								&msg, oId ),
				targetid= my_id ) ;

		}
		if( !( sts & 1 & msg ) ) {
			*rc = FALSE ;
		} else {
			/*
			 * "EMS_I_Fail" means there is no collection.
			 */
			*rc = msg == EMS_I_Fail ? FALSE : TRUE ;
		}
		if( mxType ) *mxType = MAIDMX ;
		if( oMx    ) MAidmx( &msg, oMx ) ;

		break ;

	case WANT_COLL_MEMBER	:
		/*
		 * We want a member of the user attributes: connect pretend to
		 * self with `VS_K_prUsrAttr:<member>' as a downscan. This
		 * pretend will know how to get the value by first sending an
		 * ACreturn_foot with `oNm = VS_K_prUsrAttr', and in this
		 * case we will return the id of the collection. Then the
		 * collection will be sent an ACreturn_foot with <member> and
		 * will return the ad hoc value. This mechanism will make us
		 * having a pretend corresponding to downscan
		 * `VS_K_prUsrAttr:<member>', instead of having the collection
		 * with a pretend of downscan <member>. Phooey !
		 */
		
		/*
		 * The member name can be an invalid name. So make sure that 
		 * the member is existing in the user attribute collector.
		 * If the member doesn't exist in the collector then exit, 
		 * donot get the pretend object.
		 */
		{

		struct	GRid	coll ; 
		struct ACrg_coll	list_attr ;
		long			loc_msg ;

		/*
		 * User attributes : if source part, get parent collection of
		 * user attributes, if modified part, get that of source up in
		 * the consume history.
		 */
		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &myType ),
				targetid= my_id ) ;

		if( !( myType & VS_m_SRC_generic ) ) {

			sts = om$send(
				msg	= message VSfeature.VSforwardToSource(
					rc,
					OM_e_wrt_object,
					message VSfeature.VSgetUsrAttributes(
								&msg, &coll ) ),
				targetid= my_id ) ;

		} else {
			sts = om$send(
				msg	= message VSfeature.VSgetUsrAttributes(
								&msg, &coll ),
				targetid= my_id ) ;

		}
		if( !( sts & 1 & msg ) ) {
			*rc = FALSE ;
		} else {
			/*
			 * "EMS_I_Fail" means there is no collection.
			 */
			*rc = msg == EMS_I_Fail ? FALSE : TRUE ;
		}
		if( mxType ) *mxType = MAIDMX ;
		if( oMx    ) MAidmx( &msg, oMx ) ;

		strcpy( list_attr.name, (sep+1) );

		sts = om$send( msg = message ACrg_collect.ACget_named_attribute(
					  &loc_msg, &list_attr ),
				targetid = coll.objid,
				targetos = coll.osnum );

		if( loc_msg == FALSE ) { *rc = FALSE ; 	break ; }

		}
		sts = om$send(	msg	= message ACcpx.ACconnect_pretend(
							&irc, oNm, oId ),
				targetid= my_id ) ;
		*rc = irc ;

		if( mxType )	*mxType = MAIDMX ;
		if( oMx )	MAidmx( &msg, oMx ) ;

		break ;

	case WANT_SUB_CMP	:

		__DBGpr_str(" Call VSget_sub_cmp_id", oNm );
		sts = om$send(	msg	= message VSpart.VSget_sub_cmp_id(
							&msg, oNm, oId ),
				targetid= my_id ) ;
		// changes for TR179900782 begin
		if(!( sts & 1 & msg ))
		{
		  myGRid.objid = my_id ;
		  myGRid.osnum = OM_Gw_current_OS ;

		  if( vs$is_ancestry_valid( object = &myGRid,
					    classid = OPP_VSbeam_class_id )){
		    __DBGpr_com(" VScheckComps ");
		    status2 = VScheckComps( &myGRid, oNm,oId);
		    if(status2) { sts = 1; msg =1; } 
		  }
		}
		// changes for TR179900782 end 

		if( sts & 1 & msg ) {
			/*
			 * Get matrix if requested.
			 */
			if( oMx || mxType ) {
				struct GRid moi ;
				om$send(msg	= message ACncpx.ACreturn_foot(
							&msg, "",
							&moi, mxType, oMx ),
					mode	= OM_e_wrt_message,
					targetid= my_id ) ;
			}

			*rc = TRUE ;
			break ; 
		}

		/*
		 * Well it failed! Just in case try ancestor's method...
		 */
		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
						rc, oNm, oId, mxType, oMx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__DBGpr_int(" sts ", sts );
		__DBGpr_int(" *rc ", *rc );
		if( !( sts & 1 ) || !*rc ) *rc = FALSE ;
		break ;
	
case WANT_SIMPLE_FOOT	:
	
		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
						rc, oNm, oId, mxType, oMx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		if( !( sts & 1 ) || !*rc ) { *rc = FALSE ; break ; }

		/*
		 * We want pretends corresponding to numeric feet to print
		 * themselves nicely. Put identity matrix: it does not matter.
		 */

		myEnv._MATRIX_TYPE = MAIDMX ;
		MAidmx( &msg, myEnv._MATRIX ) ;
		myEnv._MD_OS = OM_Gw_current_OS ;

		ex$get_modid(	mod_osnum	= OM_Gw_current_OS,
				mod_id		= &myEnv._MD_ID ) ;
		sts = om$send(	msg	= message NDnode.NDgive_structure(
							&msg, &rs, &myEnv ),
				targetid= oId->objid,
				targetos= oId->osnum ) ;

		if( ( sts & 1 & msg ) && rs.type == double_type ) {
			VSmakeUnitPretend( oId ) ;
		}
		*rc = TRUE ;

		break ;

		default : /* Should never get here */ break ;
	
	}

	if( !*rc ) oId->objid = NULL_OBJID ;

	/*
	 * Must always return OM_S_SUCCESS !
	 */
	return OM_S_SUCCESS ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSfeature ;
