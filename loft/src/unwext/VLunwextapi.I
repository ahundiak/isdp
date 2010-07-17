/* $Id: VLunwextapi.I,v 1.6 2001/06/27 13:47:34 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwextapi.I
 *
 * Description: Functions for unwrap API macros.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwextapi.I,v $
 *      Revision 1.6  2001/06/27 13:47:34  ramarao
 *      Implemented a new Function VLunwGetUnwrapTransMatrix().
 *
 *      Revision 1.5  2001/06/08 20:49:27  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/08 00:27:53  ramarao
 *      Fixed a problem in VLunwGetPointOnPlate() function.
 *
 *      Revision 1.3  2001/02/20 01:07:39  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:27  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/12/06  15:45:52  pinnacle
# Replaced: loft/src/unwext/VLunwextapi.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/11/20  21:49:32  pinnacle
# Replaced: loft/src/unwext/VLunwextapi.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/24  22:45:42  pinnacle
# Created: loft/src/unwext/VLunwextapi.I by rchennup for Service Pack
#
# Revision 1.15  2000/03/23  21:03:48  pinnacle
# Replaced: src/unwext/VLunwextapi.I for:  by impd252 for loft
#
# Revision 1.14  2000/03/22  16:52:00  pinnacle
# Replaced: src/unwext/VLunwextapi.I for:  by impd252 for loft
#
# Revision 1.13  2000/03/10  19:25:28  pinnacle
# (No comment)
#
# Revision 1.12  2000/03/08  16:10:38  pinnacle
# Added surface argument in VLunwFillDevStructureFromSrf() function.
#
# Revision 1.11  2000/02/24  16:12:38  pinnacle
# (No comment)
#
# Revision 1.10  2000/01/21  11:20:54  pinnacle
# Replaced VLunwextapi.I for CR179900721 by jpulapar
#
# Revision 1.7  2000/01/12  16:36:12  pinnacle
# (No comment)
#
# Revision 1.6  2000/01/04  12:31:54  pinnacle
# Replaced VLunwextapi.I commenting debug statements by jpulapar for loft
#
# Revision 1.5  2000/01/04  11:32:24  pinnacle
# Replaced VLunwextapi.I for CR179900721 by jpulapar for loft
#
# Revision 1.2  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:31:48  pinnacle
# Created: src/unwext/VLunwextapi.I by rchennup for loft
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 10/28/97  Rama Rao  File Creation
 * 04/09/99  ah        Rama Rao SP08 Fixes
 * 02/24/00  Rama Rao  In VLunwGetFeaturesParents(), 
 *       	       if original macro is a pretend,
 *		       call ACpretend.ACfind_parent() method.
 *************************************************************************/

class implementation VDSroot;

#include   <stdio.h>
#include   <math.h>
#include   "OMerrordef.h"
#include   "EMSmsgdef.h"
#include   "asmacros.h"
#include   "ACrg_collect.h"
#include   "nddef.h"
#include   "ndmacros.h"
#include   "bserr.h"
#include   "bsdotp.h"
#include   "bssfevaln.h"
#include   "bsnorvec.h"
#include   "bsparameters.h"
#include   "vddrwattr.h"
#include   "v_miscmacros.h"
#include   "v_datamacros.h"
#include   "vlstructure.h"
#include   "vlunwext.h"
#include   "vlunfold.h"
#include   "vlmsg.h"
#include   "VDtypedef.h"
#include   "VDvla.h"
#include   "VDchn.h"
#include   "VDobj.h"
#include   "VDgeom.h"
#include   "vsplatedef.h"
#include   "vlmiscmacros.h"
#include   "vldbgmacros.h"

#include   "bssfeval.h"
#include   "bssfevaln.h"
#include   "bsnorvec.h"
#include   "bsdotp.h"
#include   "bsmdistptsf.h"
#include   "bsxtractpar.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

//#define DEBUG 1
extern IGRstar VDatGetConsumingChild();
extern  struct  GRid    NULL_GRID;

from  ACrg_collect	import	AClist_attribute;
from  ACpretend		import  ACfind_parent;

extern GRclassid 	OPP_VLmrkLine_class_id, OPP_VLrolLine_class_id,
		 	OPP_VLctrLine_class_id, OPP_VLbutLine_class_id,
			OPP_VLseaLine_class_id, OPP_VLwatLine_class_id,
			OPP_VLtrace_class_id  , OPP_VDdrwGm_class_id,
			OPP_VLunwFeat_class_id, OPP_ACpretend_class_id;

IGRlong		VLunwGetPlatePlane(	IGRlong			*msg,
			     		struct GRobj_env	*plate,
			     		IGRint			*plan_ind )
{
BSrc			sts, rc;
IGRint			numNormals;
IGRpoint		pnt;
IGRvector		x_axis, y_axis, z_axis, normal[1];
IGRdouble		cos_alpha_plane, cos_beta_plane, cos_gamma_plane;
struct IGRplane		plane;
struct GRobj_env	base_surface_id;	
struct IGRbsp_surface	*baseGeom=NULL;

   SetProc( VLunwGetPlatePlane  ); Begin

   sts = MSSUCC;

   *plan_ind = 2;

   __DBGpr_obj( "Input Plate Object", plate->obj_id );
   sts = om$send( msg = message NDmacro.ACreturn_foot( msg, VS_K_plBotSfPath,
                        &base_surface_id.obj_id, &base_surface_id._matrix_type,
                        base_surface_id._matrix ),
                       senderid = plate->_objid,
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:Base", wrapup ) ;
   base_surface_id._md_os = base_surface_id._osnum;
   sts = ex$get_modid( mod_osnum = base_surface_id._md_os,
                       mod_id    = &base_surface_id._md_id );
   __DBGpr_obj("Base Surface Id ", base_surface_id.obj_id );

   vdgeom$Get2( objOE = &base_surface_id, srf = &baseGeom );

   BSsfevaln( baseGeom, 0.5, 0.5, 1, &numNormals, pnt, normal, &rc );
   if( rc != BSSUCC )  goto wrapup;

   BSnorvec( &rc, normal[0] );
   if( rc != BSSUCC )  goto wrapup;
   __DBGpr_vec("Base Surface Normal ", normal[0] );

   x_axis[1] = x_axis[2] = y_axis[0] = y_axis[2] = z_axis[0] = z_axis[1] = 0.0;

   x_axis[0] = y_axis[1] = z_axis[2] = 1.0;

   cos_alpha_plane = fabs( BSdotp( &rc, x_axis, normal[0] ) );
   cos_beta_plane  = fabs( BSdotp( &rc, y_axis, normal[0] ) );
   cos_gamma_plane = fabs( BSdotp( &rc, z_axis, normal[0] ) );

   if( (cos_alpha_plane - cos_beta_plane)  > 1e-5 &&
       (cos_alpha_plane - cos_gamma_plane) > 1e-5 )	
   {
	__DBGpr_com( "Plate is in YZ plane" );
	*plan_ind = 0 ;
   }


   if( (cos_beta_plane - cos_alpha_plane) >  1e-5 &&
       (cos_beta_plane - cos_gamma_plane) >  1e-5 )
   {
        __DBGpr_com( "Plate is in XZ plane" );
        *plan_ind = 1 ;
   }

   if( (cos_gamma_plane - cos_alpha_plane) >  1e-5 &&
       (cos_gamma_plane - cos_beta_plane)  >  1e-5 )
   {
        __DBGpr_com( "Plate is in XY plane" );
        *plan_ind = 2 ;
   }

wrapup:
   _FREE( baseGeom );
   End
   return sts;
}

IGRlong		VLunwGetUnwrapEdges(	IGRlong 	  *msg,
					struct GRid	  unw_obj,
					IGRint		  *edge_count,
					struct EdgeMatch  **edge_match )
{
   IGRlong       	     sts;
   VDpartAttr    	     attr;
   struct edge_match_list    match_lst;

	SetProc( VLunwGetUnwrapEdges  ); Begin

        if( unw_obj.objid == NULL_OBJID || !edge_count )
        return OM_E_INVARG;

	/* Initialization */
	*msg = MSSUCC;
	match_lst.Count    = 0;
	match_lst.EdgeList = NULL;
	if( edge_count ) *edge_count = 0;
	if( edge_match ) *edge_match = NULL;

        attr.Iwant = VL_I_edgeMatch ;
        attr.specific = (void *) &match_lst ;
        sts = _VD_SEND_OBJN( unw_obj, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

	if( edge_count )  *edge_count = match_lst.Count;
	if( edge_match )  *edge_match = match_lst.EdgeList;
	else		  _FREE( match_lst.EdgeList );

wrapup:
	End
	return sts;
}

// This function will check and remove the dummy VLunwFeat Objs for the input
// macro on the unwrap

IGRint VLunwCheckAndRem(struct GRid macID)
{
  int sts,msg,feat_count; //feature objects on the children channel
  int ii;
  int retFlag;          // geometry flag
  
  TVDvlaID featVLA;
  TGRid featID;
  TGRobj_env featOE;
  OMuword    classID;
  
  if(macID.objid == NULL_OBJID) goto wrapup;
  //init
  feat_count = 0;
  featID.objid = NULL_OBJID;
  retFlag = FALSE; 
  
  vdvla_id$Construct(vla = &featVLA);
  
  
  vdchn$Get2(objID=&macID,chnIDx = VDCHN_IDX_CHILDREN,cnt =&feat_count,outVLA=&featVLA);
  if(feat_count == 0) goto wrapup;
  
  for(ii=0;ii<feat_count;ii=ii+1)
  {
    // get the unwrap feature objects
    vdvla_id$GetAt(vla = &featVLA,nth = ii,objID = &featID);
    if(featID.objid == NULL_OBJID) goto wrapup;
    
    // check for the VLunwFeat class
    sts = om$get_classid(objid = featID.objid,
			 osnum = featID.osnum,
			 p_classid = &classID);
    if(!(sts&1)) goto wrapup;
    if(classID != OPP_VLunwFeat_class_id) continue;
    
    // function to check the graphic contents of the VLunwFeat Object
    // return value of true means that the graphics are in_tact
    // otherwise, delete the redundant VLunwFeat object
    
    retFlag = VLunwcheckGraphics(&featID);
    if(!retFlag) // dummy feature - delete 
    {
      VDahGetObjectEnv(&featID,&featOE);
      if(featOE.obj_id.objid == NULL_OBJID) goto wrapup;
      
      vdobj$Delete(objOE = &featOE,objCNT = 1);
    }
    
  }
  retFlag = TRUE;
 wrapup:
  vdvla_id$Delete(vla = &featVLA);
  return retFlag;
}

IGRint VLunwcheckGraphics(struct GRid *featObj)
{
  int retFlag;
  int ii,sts;
  int geom_count;       //geometry objects on the component channel of features
  int comp_count;       //components of the geom objs containing the graphics
  OMuword    classID;
  TGRid geomID;
  TVDvlaID compVLA,geomVLA;
  
  // init 
  retFlag = TRUE;
  geom_count = comp_count = 0;
  geomID.objid = NULL_OBJID;
  
  
  vdvla_id$Construct(vla = &compVLA);
  vdvla_id$Construct(vla = &geomVLA);
  
  vdchn$Get2(objID=featObj,chnIDx = VDCHN_IDX_TO_COMPONENTS,cnt =&geom_count,outVLA=&geomVLA);
  if(geom_count == 0) // no components for the feature 
  {
    retFlag = FALSE;
    goto wrapup;
  }
  for(ii=0;ii<geom_count;ii=ii+1)
  {
    // get the geometry objects
    vdvla_id$GetAt(vla = &geomVLA,nth = ii,objID = &geomID);
    if(geomID.objid == NULL_OBJID) goto wrapup;
    
    // check for the VDdrwGm class
    sts = om$get_classid(objid = geomID.objid,
			 osnum = geomID.osnum,
			 p_classid = &classID);
    if(!(sts&1)) goto wrapup;
    if(classID != OPP_VDdrwGm_class_id) continue;
    vdchn$Get2(objID=&geomID,chnIDx = VDCHN_IDX_TO_COMPONENTS,cnt =&comp_count,outVLA=&compVLA);
    if(comp_count == 0) // no components  - empty geometry 
    {
      retFlag = FALSE;
      goto wrapup;
    }
    
  }   
 wrapup:
  vdvla_id$Delete(vla = &compVLA);
  vdvla_id$Delete(vla = &geomVLA);
  return retFlag;
}

IGRlong	VLunwGetFeaturesParents(	IGRlong 	  *msg,
					struct GRid	  unw_obj,
					IGRint		  *optlines,
					IGRint		  *feature_count,
					struct EdgeMatch  **feature_match )
{
   IGRint		i, j, cnt;
   IGRlong      	sts;
   OM_S_CHANSELECT 	to_obj ;
   struct GRid		featObj;
   struct GRobj_env     org_mac;

	SetProc( VLunwGetFeaturesParents ); Begin

        if( unw_obj.objid == NULL_OBJID || !feature_count || !optlines )
        return OM_E_INVARG;

	/* Initialization */
	*msg = MSSUCC;
	if( feature_count ) *feature_count = 0;
	if( feature_match ) *feature_match = NULL;

        to_obj.type        = OM_e_name;
        to_obj.u_sel.name  = "VLunwObj.to_feat";

        sts = om$get_channel_count( objid        = unw_obj.objid,
				    osnum        = unw_obj.osnum,
                                    p_chanselect = &to_obj,
                                    count        = (OMuint *)&cnt );
        __CheckRC( sts, 1, "om$get_channel_count:VLunwObj.to_feat", wrapup );

	__DBGpr_int( " Number of Objects on to_feat Channel ", cnt );

	if( !cnt ) goto wrapup;

	if( !( *feature_match = _MALLOC( cnt, struct EdgeMatch ) ) ) 
		vd_$mem_fail();

	for( i=0; i<cnt; ++i )
	{
	     __DBGpr_int( " Index ", i );
             sts = om$get_objid_at_index(  objid           = unw_obj.objid,
                                	   osnum           = unw_obj.osnum,
                                	   p_chanselect    = &to_obj,
                                	   index           = i,
                                	   objidaddr       = &featObj.objid,
                                	   osnumaddr       = &featObj.osnum );
             __CheckRC( sts, 1, "om$get_objid_at_index:VLunwObj.to_feat", wrapup );
	     __DBGpr_obj( " Feature Object ", featObj );

	     (*feature_match)[(*feature_count)].EdgeId = featObj;

             sts = _VD_SEND_OBJN( featObj, NDnode.NDget_objects( ND_ROOT,
                                &org_mac.obj_id, 1, NULL, 1, 1, &j ));
             __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

   	     if( vd_$is_ancestry_valid( object  = &org_mac.obj_id,
                                        classid = OPP_ACpretend_class_id ))
 	     {
     		sts = _VD_SEND_OBJN( org_mac.obj_id, ACpretend.ACfind_parent(
			&org_mac.obj_id, &org_mac.mod_env.md_env.matrix_type,
			org_mac.mod_env.md_env.matrix ) );
                if( !(sts&1) )
                {
                   vdobj$Delete(objID = &featObj, objCNT = 1 );
                   continue;
                }
	     }
	     __DBGpr_obj( " Original Macro in Model ", org_mac.obj_id );

	     (*feature_match)[*feature_count].EdgeMac = org_mac.obj_id;
	     (*feature_count)++;
	}

  	__DBGpr_int( " Feature Count ", *feature_count );
	*msg = MSSUCC;

wrapup:
	End
	return sts;
}

// This function checks whether the supplied parents correspond to that 
// of the marking line
IGRint VLchkMarkingLine(struct GRobj_env *parent1,struct GRobj_env *parent2,struct GRobj_env *mrkOE)
{
  IGRint retFlag = FALSE;
  struct GRobj_env mrkPar1OE,mrkPar2OE;
  
  if (mrkOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdobj$GetTemplate(objOE = mrkOE,
		    nth   = 1,
		    templateOE = &mrkPar1OE);
  if (mrkPar1OE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdobj$GetTemplate(objOE = mrkOE,
		    nth   = 2,
		    templateOE = &mrkPar2OE);
  if (mrkPar2OE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  if((parent1->obj_id.objid == mrkPar1OE.obj_id.objid) && (parent1->obj_id.osnum == mrkPar1OE.obj_id.osnum) && (parent2->obj_id.objid == mrkPar2OE.obj_id.objid) && (parent2->obj_id.osnum == mrkPar2OE.obj_id.osnum))
  {
#ifdef DEBUG
    printf("\n Supplied parents are that of the marking line\n");
    printf("\n Parent1[%d,%d] Parent2[%d,%d] Marking[%d,%d] \n",parent1->obj_id.objid,parent1->obj_id.osnum,parent2->obj_id.objid,parent2->obj_id.osnum,mrkOE->obj_id.objid,mrkOE->obj_id.osnum);
#endif
    retFlag = TRUE;
    goto wrapup;
  }
  
 wrapup:
  return retFlag;
}
// This function returns TRUE and mrkOE if parent1 and parent2 are  
// combined parents of a marking line. Returns FALSE otherwise. 
// Returns -1 is something goes wrong in the process

IGRint VLmrkGetMarkingLine(struct GRobj_env *parent1, struct GRobj_env *parent2, struct GRobj_env *mrkOE)
{
  IGRint retFlag = -1;
  int stat,i;
  TVDvlaID mrkVLA;
  struct GRid mrkID;
  int mrkCount = 0;
  
  // arg check
  if((parent1->obj_id.objid == NULL_OBJID)||(parent2->obj_id.objid == NULL_OBJID)) goto wrapup;
  //init
  mrkOE->obj_id.objid = NULL_OBJID;
  mrkID.objid = NULL_OBJID;
  vdvla_id$Construct(vla = &mrkVLA);
  
  // Get the marking line children of parent1
  vdchn$GetChildrenByClass(objOE     = parent1,
			   className = "VLmrkLine",
			   vla       = &mrkVLA);
  mrkCount = vdvla_id$GetCnt(vla = &mrkVLA);
  
  if(!mrkCount) goto wrapup;
  
#ifdef DEBUG
  printf("\n No. of marking line children of parent1 : %d \n",mrkCount);
#endif
  for(i = 0;
      vdvla_id$GetAt(vla = &mrkVLA, nth = i, objID = &mrkID);
      i++) {
    VDahGetObjectEnv(&mrkID,mrkOE);
    if(mrkOE->obj_id.objid == NULL_OBJID) goto wrapup;
    stat = VLchkMarkingLine(parent1,parent2,mrkOE);
    if(stat&1) 
    {
      retFlag = TRUE;
      goto wrapup;
    }
  }
  retFlag = FALSE; // no marking common to both the supplied parents
 wrapup:
#ifdef DEBUG
  if(!retFlag)
    printf("\n no marking line in common for the supplied parents \n");
  else
    printf("\n marking line [%d,%d] is common for the supplied parents \n",mrkOE->obj_id.objid,mrkOE->obj_id.osnum);
#endif
  vdvla_id$Delete(vla = &mrkVLA);
  return retFlag;
}

// This function returns TRUE if it successfully hooks up the new parents to
// the supplied marking line

IGRint VLhookmrkLine(struct GRobj_env *mrkOE,struct GRobj_env *par1OE,struct GRobj_env *par2OE)
{
  IGRint retFlag = FALSE;
  struct GRid source1ID,source2ID;
  struct GRid parents[3];
  IGRint cn_type;
  IGRstat sts;
  
  source1ID.objid = source2ID.objid = NULL_OBJID;
  
  // Get the parent collector information for posting
  vdobj$GetParent(objOE = mrkOE, idx = 0, parentID = &parents[0]);
  if (parents[0].objid == NULL_OBJID) {
    UI_status("Can't find parent collector\n");
    goto wrapup;
  }
  // create the source objects for the first parent
  as$make_source( go_grid = par1OE->obj_id,
		  mod_env = &par1OE->mod_env,
		  as_os   = mrkOE->obj_id.osnum ,
		  as_grid = &source1ID);
  if(source1ID.objid == NULL_OBJID) goto wrapup;
  
  parents[1] = source1ID;
  
#ifdef DEBUG
  printf("\n Successfully created the source object[%d,%d] for first parent[%d,%d]of marking line[%d,%d] \n",source1ID.objid,source1ID.osnum,par1OE->obj_id.objid,par1OE->obj_id.osnum,mrkOE->obj_id.objid,mrkOE->obj_id.osnum);
#endif
  
  // create the source objects for the second parent
  as$make_source( go_grid = par2OE->obj_id,
		  mod_env = &par2OE->mod_env,
		  as_os   = mrkOE->obj_id.osnum ,
		  as_grid = &source2ID);
  if(source2ID.objid == NULL_OBJID) goto wrapup;
  
  parents[2] = source2ID;
  
#ifdef DEBUG
  printf("\n Successfully created the source object[%d,%d] for second  parent[%d,%d]of marking line[%d,%d] \n",source2ID.objid,source2ID.osnum,par2OE->obj_id.objid,par2OE->obj_id.osnum,mrkOE->obj_id.objid,mrkOE->obj_id.osnum);
#endif
  
  /* Reconnect */
  sts = om$send(
    msg = message NDnode.NDconnect(
      3,parents,NULL_GRID,ND_FULL),
    senderid = NULL_OBJID,
    targetid = mrkOE->obj_id.objid,
    targetos = mrkOE->obj_id.osnum
  );
  if(!(sts&1)) goto wrapup;
  
  /* Recompute */
  cn_type = ND_COMP;
  
  nd$wait_batch(
    type = GR_GEOM_POSTED,
    nb_obj     = 1,
    l_object   = &mrkOE->obj_id,
    l_obj_info = &cn_type
  );
  
  nd$exec_batch();
  retFlag = TRUE; // everything went fine
 wrapup:
  return retFlag;
}
// Given a marking line this function checks its either of the parents   
// is consumed and if so re-hooks the marking line to the consuming children
// If either of the parents are missing, the marking line will be deleted

IGRint VLdetDupMarks(struct GRobj_env *mrkOE)
{
  IGRint retFlag = FALSE,existFlag = FALSE;
  struct GRobj_env par1OE,par2OE;
  struct GRobj_env child1OE,child2OE; // consuming children
  IGRlong     sts,msg,isConsumed1,isConsumed2;
  struct GRobj_env markOE;
  
  if(mrkOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  par1OE.obj_id.objid = par2OE.obj_id.objid = NULL_OBJID;
  child1OE.obj_id.objid = child2OE.obj_id.objid = NULL_OBJID;
  
  // Get the parents of the marking line 
  
  // Get the marked parent(I) lying under ACpretend
  
  vdobj$GetTemplate(objOE = mrkOE,
		    nth   = 1,
		    templateOE = &par1OE);
  if (par1OE.obj_id.objid == NULL_OBJID) // first parent missing 
  {
    retFlag = -1;
    vdobj$Delete(objOE = mrkOE,objCNT = 1);
    mrkOE->obj_id.objid = NULL_OBJID;
    goto wrapup;
  }
#ifdef DEBUG
  printf("\n First Parent of marking line[%d,%d] = [%d,%d] \n",mrkOE->obj_id.objid,mrkOE->obj_id.osnum, par1OE.obj_id.objid,par1OE.obj_id.osnum);
#endif
  
  // Get the marking parent(II) lying under ACpretend
  
  vdobj$GetTemplate(objOE = mrkOE,
		    nth   = 2,
		    templateOE = &par2OE);
  if (par2OE.obj_id.objid == NULL_OBJID) // second parent missing 
  {
    retFlag = -1;
    vdobj$Delete(objOE = mrkOE,objCNT = 1);
    mrkOE->obj_id.objid = NULL_OBJID;
    goto wrapup;
  }
#ifdef DEBUG
  printf("\n Second Parent of marking line[%d,%d] = [%d,%d] \n",mrkOE->obj_id.objid,mrkOE->obj_id.osnum, par2OE.obj_id.objid,par2OE.obj_id.osnum);
#endif
  // check if either of the parents are consumed 
  sts = om$send(msg = message NDmacro.ACtest_consumed( &isConsumed1),
		senderid = NULL_OBJID,
		targetid = par1OE.obj_id.objid,
		targetos = par1OE.obj_id.osnum );
  
  __CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
  if( isConsumed1 & 1 ) {
    // Get the consuming child
    VDatGetConsumingChild(&par1OE,&child1OE);
    if (child1OE.obj_id.objid == NULL_OBJID) goto wrapup;
#ifdef DEBUG
    printf("\n Consuming child of First parent = [%d,%d] \n",child1OE.obj_id.objid,child1OE.obj_id.osnum);
#endif
  }
  else child1OE = par1OE;
  
  sts = om$send(msg = message NDmacro.ACtest_consumed( &isConsumed2),
		senderid = NULL_OBJID,
		targetid = par2OE.obj_id.objid,
		targetos = par2OE.obj_id.osnum );
  
  __CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
  if( isConsumed2 & 1 ) {
    // Get the consuming child
    VDatGetConsumingChild(&par2OE,&child2OE);
    if (child2OE.obj_id.objid == NULL_OBJID) goto wrapup;
#ifdef DEBUG
    printf("\n Consuming child of Second parent = [%d,%d] \n",child2OE.obj_id.objid,child2OE.obj_id.osnum);
#endif
  }
  else child2OE = par2OE;
  
  // if neither of the parents are consumed, do nothing
  if(!(isConsumed1&1) && !(isConsumed2&1)) goto wrapup;
  
  // check if a marking line already exist with child1 & child2 as parents
  // if that is the case, the current marking line should be deleted
  
  existFlag = VLmrkGetMarkingLine(&child1OE,&child2OE,&markOE);
  
  if(existFlag == TRUE && (markOE.obj_id.objid!=NULL_OBJID))
  {
#ifdef DEBUG
    printf("\n Another marking line already exist with these consuming children as parents \n");
    printf("\n This marking line is eligible for deletion \n");
#endif
    retFlag = TRUE;
    goto wrapup;
  }
  else if(existFlag == FALSE)
  {
    // hook the current marking line to the new parents [child1,child2]
    existFlag = VLhookmrkLine(mrkOE,&child1OE,&child2OE); // reusing the flag
#ifdef DEBUG
    if(!existFlag) 
      printf("\n Something went wrong in hooking the marking line to new parents \n");
    else
      printf("\n Marking line successfully hooked up to the consuming children as its new parents \n");
#endif
  }
  else if(existFlag == -1)
  {
    //something went wrong inside the function VLmrkGetMarkingLine()
    goto wrapup;
  }
  else goto wrapup;
  
 wrapup:
  return retFlag;
}
// This function gets all the macros on the unwrap (markings, waterlines, etc.)
// and removes redundant VLunwfeat objs (without graphics)connected to these

IGRint VLunwRedFeats(IGRlong           *msg,
		     struct GRid       unwObj)
{
  IGRlong sts;
  IGRint i,feature_count = 0,optlines[UNWEXT_NB_OPT];
  IGRint 		    retFlag    = FALSE,ret_type = FALSE;
  struct EdgeMatch        *match_list=NULL; 
  
  *msg = MSSUCC;
  if(unwObj.objid == NULL_OBJID) goto wrapup;

  for ( i=0; i<UNFOLD_NB_OPTLINE; i=i+1 ) optlines[i] = 1;
  
  /*
   * In match_list EdgeId  : Feature Object ( VLunwFeat )
   * EdgeMac : Model Macro ( Like WaterLine, MarkingLine,.
   */
  sts = VLunwGetFeaturesParents(  msg, unwObj, optlines,
				  &feature_count, &match_list  );
  __CheckRC( sts, *msg, "VLunwGetFeaturesParents", wrapup );

  for( i=0; i<feature_count; ++i )
  {
    ret_type =  VLunwCheckAndRem(match_list[i].EdgeMac);
  }
  retFlag = TRUE;
  
 wrapup:
  _FREE(match_list);
  return retFlag;
}


IGRlong		VLunwGetFeatureLines(	IGRlong 	  *msg,
					struct GRid	  unw_obj,
					IGRint		  *optlines,
					IGRint		  *feature_count,
					struct EdgeMatch  **feature_match )
{
   IGRint		i, j, cnt;
   IGRlong      	sts;
   OM_S_CHANSELECT 	to_obj ;
   struct GRid		featObj, org_mac, gmObj, feat_2d;
   struct GRmd_env	modEnv;

	SetProc( VLunwGetFeatureLines  ); Begin

        if( unw_obj.objid == NULL_OBJID || !feature_count || !optlines )
        return OM_E_INVARG;

	/* Initialization */
	*msg = MSSUCC;
	if( feature_count ) *feature_count = 0;
	if( feature_match ) *feature_match = NULL;

        to_obj.type        = OM_e_name;
        to_obj.u_sel.name  = "VLunwObj.to_feat";

        sts = om$get_channel_count( objid        = unw_obj.objid,
				    osnum        = unw_obj.osnum,
                                    p_chanselect = &to_obj,
                                    count        = (OMuint *)&cnt );
        __CheckRC( sts, 1, "om$get_channel_count:VLunwObj.to_feat", wrapup );

	__DBGpr_int( " Number of Objects on to_feat Channel ", cnt );

	if( !cnt ) goto wrapup;

	if( !( *feature_match = _MALLOC( cnt, struct EdgeMatch ) ) ) 
		vd_$mem_fail();

	for( i=0; i<cnt; ++i )
	{
	  __DBGpr_int( " Index ", i );
          sts = om$get_objid_at_index(	objid           = unw_obj.objid,
                                	osnum           = unw_obj.osnum,
                                	p_chanselect    = &to_obj,
                                	index           = i,
                                	objidaddr       = &featObj.objid,
                                	osnumaddr       = &featObj.osnum );
          __CheckRC( sts, 1, "om$get_objid_at_index:VLunwObj.to_feat", wrapup );
	  __DBGpr_obj( " Feature Object ", featObj );

          sts = _VD_SEND_OBJN( featObj, NDnode.NDget_objects( ND_ROOT,
                                &org_mac, 1, NULL, 1, 1, &j ));
          __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
	  __DBGpr_obj( " Original Macro in Model ", org_mac );

	  if( optlines[UNFOLD_ATT_IDX_MARK] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLmrkLine_class_id )){

		__DBGpr_com( " In the Marking Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$2",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_ROL] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLrolLine_class_id )){

		__DBGpr_com( " In the Roll Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_CTRL] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLctrLine_class_id )){

		__DBGpr_com( " In the Control Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_TRACE] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLtrace_class_id )){

		__DBGpr_com( " In the Trace Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_WATER] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLwatLine_class_id )){

		__DBGpr_com( " In the Water Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_BUTT] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLbutLine_class_id )){

		__DBGpr_com( " In the Butt Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }

	  if( optlines[UNFOLD_ATT_IDX_SEAM] )
	  {
             if( vd_$is_ancestry_valid( object  = &org_mac,
                                        classid = OPP_VLseaLine_class_id )){

		__DBGpr_com( " In the Seam Line " );

		(*feature_match)[*feature_count].EdgeMac = org_mac;

        	sts = _VD_SEND_OBJN(   featObj,
                        	       NDmacro.ACreturn_foot(  
						msg,
                                                "geom",
                                                &gmObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " VDdrwGm Object ", gmObj );

        	sts = _VD_SEND_OBJN(   gmObj,
                        	       NDmacro.ACreturn_foot(  
				       		msg,
                                       		"$0",
                                       		&feat_2d,
                                       		&modEnv.md_env.matrix_type,
                                       		modEnv.md_env.matrix ));
		if( !(sts&(*msg)&1) ) continue;
	  	__DBGpr_obj( " 2-D graphics Object ", feat_2d );
		(*feature_match)[(*feature_count)++].EdgeId = feat_2d ;
	     }
	  }
	}
  	__DBGpr_int( " Feature Count ", *feature_count );
	*msg = MSSUCC;

wrapup:
	End
	return sts;
}

IGRlong	VLunwGetPointOnPlate(TGRobj_env *unwrapOE,
			     IGRint	 num_pt,
			     IGRdouble  *pt_unw,
			     IGRdouble  *pt_plate )
{
  IGRlong       	     rc, sts;
  IGRstat 		     retFlag = 0;
  IGRstat 		     msg = MSSUCC;
  IGRboolean		     first_time=TRUE; 
  IGRint		     i, j;
  struct unw_obj_plat	     dev;
  struct GRobj_env	     unwSrfObj ;
  VDpartAttr    	     attr;
  struct IGRbsp_surface     *unwSrfGm=NULL, *surfGm=NULL;
  IGRdouble		     u_par=0.0, v_par=0.0;
  IGRdouble		     vect[3], tmp[6];
   IGRint    cn_type = ND_COMP;
  
  SetProc( VLunwGetPointOnPlate  ); Begin

  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (unwrapOE->obj_id.objid == NULL) goto wrapup;
  if (num_pt < 1)       goto wrapup;
  if (pt_unw == NULL)   goto wrapup;
  if (pt_plate == NULL) goto wrapup;

  __DBGpr_int( " Number of input points ", num_pt );

  /* Initialization */
  msg = MSSUCC;

get_it_again:
  sts = vl$return_foot(msg = &msg,
                       name    = UNFOLD_NAM_UNWSRF,
                       objId   = &unwrapOE->obj_id,
                       objEnv  = &unwrapOE->mod_env,
                       footId  = &unwSrfObj.obj_id,
                       footEnv = &unwSrfObj.mod_env );
  __CheckRC( sts, msg, "vd_$return_foot", wrapup ) ;
  __DBGpr_obj( " UnwwrapSrf Feet ", unwSrfObj.obj_id );

  sts = VLgetGeometry( &unwSrfObj, FALSE, NULL_OBJID,
                       (IGRchar **)&unwSrfGm, &msg );
  __CheckRC( sts, msg, "VLgetGeometry: For Unwrap", wrapup );

  if( ( unwSrfGm->u_num_poles > 2000 || unwSrfGm->v_num_poles > 2000 ) &&
      ( first_time ) )
  {
      sts = om$send(msg = message NDnode.NDs_compute_node(
                                        &msg, ND_COMP, &unwrapOE->mod_env ),
                        senderid = unwrapOE->obj_id.objid,
                        targetid = unwrapOE->obj_id.objid,
                        targetos = unwrapOE->obj_id.osnum );
      first_time = FALSE;
      _FREE( unwSrfGm );

      goto get_it_again;
  }

  attr.Iwant = VL_I_getOpts ;
  attr.specific = (void *) &dev ;

  sts = om$send(msg = message GRvg.GRgetattr(&msg,(char *)&attr),
		senderid = NULL_OBJID,
		targetid = unwrapOE->obj_id.objid,
		targetos = unwrapOE->obj_id.osnum);
  __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

  sts = VLgetGeometry( &dev.surf_id, FALSE, NULL_OBJID,
		       (IGRchar **)&surfGm, &msg );
  __CheckRC( sts, msg, "VLgetGeometry: For Plate", wrapup );

  if (surfGm == NULL) {
    printf("*** No surface geomoetry\n");
    goto wrapup;
  }
  
  for( i=0; i<num_pt; ++i )
  {
    __DBGpr_vec( " Input Point ", &pt_unw[i*3] );
    for( j=0; j<3; ++j ) vect[j] = pt_unw[i*3+j];
    
    BSmdistptsf( &rc, unwSrfGm, vect, &u_par,&v_par, tmp, &tmp[5] );
    if( rc != BSSUCC )  goto wrapup;
    
    __DBGpr_dbl( " U parameter ", u_par );
    __DBGpr_dbl( " V parameter ", v_par );
    
    BSsfeval( surfGm, u_par, v_par, 0, (IGRpoint *) vect, &rc );
    if( rc != BSSUCC )  goto wrapup;
    
    for( j=0; j<3; ++j ) (pt_plate)[i*3+j] = vect[j];
    __DBGpr_vec( " Point on Base Surface ", &(pt_plate)[i*3] );
  }
 wrapup:
  _FREE( unwSrfGm  ) ;
  _FREE( surfGm  ) ;
  
  End
    return sts;
}

IGRlong  VLunwFillDevStructureFromSrf(  IGRlong           	*msg,
					struct IGRbsp_surface   *uvSurf,
				        struct unw_obj_plat     *dev )
{
BSrc		rc;
IGRlong		sts;
IGRint 		i, j, tmp;
IGRdouble	*norm=NULL;

  SetProc( VLunwFillDevStructureFromSrf  ); Begin

  if( !dev || !(uvSurf) ) return OM_E_INVARG;

  sts  = MSSUCC;
  *msg = MSSUCC;

  if( dev->Param_u ) _FREE( dev->Param_u );
  if( dev->Param_v ) _FREE( dev->Param_v );
  if( dev->P	   ) _FREE( dev->P	 );
  if( dev->def     ) _FREE( dev->def     );

  dev->Nb_u = uvSurf->u_num_poles;
  dev->Nb_v = uvSurf->v_num_poles;

  if( !(dev->Param_u = _MALLOC( dev->Nb_u, IGRdouble )) ) vd_$mem_fail();
  tmp = dev->Nb_u - 1;
  for (i=0;i<dev->Nb_u;i++)  dev->Param_u[i] = (IGRdouble) i/tmp ;

  if( !(dev->Param_v = _MALLOC( dev->Nb_v, IGRdouble )) ) vd_$mem_fail(); 
  tmp = dev->Nb_v - 1;
  for (i=0;i<dev->Nb_v;i++) dev->Param_v[i] = (IGRdouble) i/tmp ;

  if( !(dev->P = _MALLOC( 3*dev->Nb_u*dev->Nb_v, IGRdouble)) ) vd_$mem_fail();
  if( !(norm = _MALLOC( 3*dev->Nb_u*dev->Nb_v, IGRdouble)) ) vd_$mem_fail();

  for(i=0;i<(3*dev->Nb_u*dev->Nb_v); i+=3)
  {
    BSsfevaln(dev->surface, uvSurf->poles[i], uvSurf->poles[i+1],
	      1, &j, &(dev->P[i]),&norm[i], &rc );
  }

  if( !(dev->def = _MALLOC( (  dev->Nb_u*dev->Nb_v*3 +
                               4*(dev->Nb_u-1)*(dev->Nb_v-1) +
                               3*(2*(dev->Nb_u-1 + dev->Nb_v-1)+1) +
                               2*(dev->Nb_u + dev->Nb_v) -1 ), IGRdouble)) ) 
	vd_$mem_fail();

  memcpy((IGRchar *) dev->def,(IGRchar *) uvSurf->poles,
       (IGRint) (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble)));
  FAsetRng((IGRshort) 3, dev->def, dev->Nb_u, dev->Nb_v, msg);

  sts = *msg = MSSUCC;

wrapup:
    if( !(sts&(*msg)&1) )
    {
	_FREE( dev->P       );
	_FREE( dev->def     );
	_FREE( dev->Param_u );
	_FREE( dev->Param_v );
    }
    _FREE( norm );
    End
    return sts;
}

IGRlong	   VLunwRemoveDuplicatePoints(	IGRint		phy_closed,
					IGRint		*nb_points,
					IGRdouble	**points	)
{
BSrc	   rc;
IGRint     i, j, loc_nb_points, *dup=NULL;
IGRlong    sts;
IGRdouble  cht;

  SetProc( VLunwRemoveDuplicatePoints  ); Begin

  if( !nb_points ||  !points || !(*nb_points) || !(*points) )	
	return OM_E_INVARG;

  __DBGpr_int("Number of input points ", *nb_points );

  BSxtractpar ( &rc, BSTOLCHRDHT, &cht );
  __DBGpr_dbl("Chord Height Tolerance ", cht );

  if( !( dup = _MALLOC( *nb_points, IGRint )) ) vd_$mem_fail(msg=&rc);
  for( i=0; i<(*nb_points); ++i )	
  {
     __DBGpr_vec("Point ", &(*points)[3*i] );
     dup[i] = FALSE;
  }

  for( i=0; i<(*nb_points)-1; ++i )
  {
     if( dup[i] ) continue;
     if( phy_closed && ( i == 0 || i==((*nb_points)-1) ) ) continue;
     for( j=i+1; j<(*nb_points); ++j )
     {
	if( dup[j] ) continue;
	if( VLsame_point( &(*points)[3*i], &(*points)[3*j], cht ) )
        {
	   __DBGpr_int("Duplicate Point ", j );
	   dup[j] = TRUE;
        }
     }
  }

  loc_nb_points = 0;

  for( i=0; i<(*nb_points); ++i )
  {
     if( dup[i] == FALSE )
     {
	dblcpy( &(*points)[3*loc_nb_points], &(*points)[3*i], 3 );
	loc_nb_points++;
     }
  }

  *nb_points = loc_nb_points;

  __DBGpr_int("After duplication, Total number of points ", *nb_points );
  for( i=0; i<(*nb_points); ++i )
  {
     __DBGpr_vec("Revised Point ", &(*points)[3*i] );
  }

  sts = MSSUCC;

wrapup:
   _FREE( dup );
   End
   return sts;
}

IGRlong	   VLunwGetUnwrapTransMatrix(  	struct GRobj_env  *unwrapOE,
				        IGRboolean  	  unw_to_plt, /* 1 = 2d to 3d */
					IGRshort         *matrix_type,
					IGRmatrix	  matrix      )
{
  BSrc			     rc;
  IGRlong		     sts, msg;
  IGRint                     i, j;
  IGRshort		     type;
  IGRboolean		     first_time=TRUE;
  struct unw_obj_plat        dev;
  struct GRobj_env           unwSrfObj ;
  VDpartAttr                 attr;
  struct IGRbsp_surface     *unwSrfGm=NULL, *surfGm=NULL, *uvSurf=NULL;
  IGRdouble                  u_par=0.0, v_par=0.0;
  IGRdouble                  points[18];

  SetProc( VLunwGetUnwrapTransMatrix  ); Begin

  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (unwrapOE->obj_id.objid == NULL) goto wrapup;

  /* Initialization */
  msg = MSSUCC;

get_it_again:
  sts = vl$return_foot( msg     = &msg,
                        name    = UNFOLD_NAM_UNWSRF,
                        objId   = &unwrapOE->obj_id,
                        objEnv  = &unwrapOE->mod_env,
                        footId  = &unwSrfObj.obj_id,
                        footEnv = &unwSrfObj.mod_env );
  __CheckRC( sts, msg, "vd_$return_foot", wrapup ) ;
  __DBGpr_obj( " UnwwrapSrf Feet ", unwSrfObj.obj_id );

  sts = VLgetGeometry( &unwSrfObj, FALSE, NULL_OBJID,
                       (IGRchar **)&unwSrfGm, &msg );
  __CheckRC( sts, msg, "VLgetGeometry: For Unwrap", wrapup );

  if( ( unwSrfGm->u_num_poles > 2000 || unwSrfGm->v_num_poles > 2000 ) &&
      ( first_time ) )
  {
      sts = om$send(msg = message NDnode.NDs_compute_node(
                                        &msg, ND_COMP, &unwrapOE->mod_env ),
                        senderid = unwrapOE->obj_id.objid,
                        targetid = unwrapOE->obj_id.objid,
                        targetos = unwrapOE->obj_id.osnum );

      first_time = FALSE;
      _FREE( unwSrfGm );

      goto get_it_again;
  }

  attr.Iwant = VL_I_getOpts ;
  attr.specific = (void *) &dev ;

  sts = om$send(msg = message GRvg.GRgetattr(&msg,(char *)&attr),
                senderid = NULL_OBJID,
                targetid = unwrapOE->obj_id.objid,
                targetos = unwrapOE->obj_id.osnum);
  __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

  sts = VLgetGeometry( &dev.surf_id, FALSE, NULL_OBJID,
                       (IGRchar **)&surfGm, &msg );
  __CheckRC( sts, msg, "VLgetGeometry: For Plate", wrapup );

  if (surfGm == NULL) {
    printf("*** No surface geomoetry\n");
    goto wrapup;
  }

  if( dev.tesselation_option == ARC_LENGTH )
  {
      sts = vl$return_foot( msg     = &msg,
                            name    = UNFOLD_NAM_UVSRF,
                            objId   = &unwrapOE->obj_id,
                            objEnv  = &unwrapOE->mod_env,
                            footId  = &unwSrfObj.obj_id,
                            footEnv = &unwSrfObj.mod_env );
      __CheckRC( sts, msg, "vd_$return_foot", wrapup ) ;
      __DBGpr_obj( " UnwwrapSrf Feet ", unwSrfObj.obj_id );

      sts = VLgetGeometry( &unwSrfObj, FALSE, NULL_OBJID,
                            (IGRchar **)&uvSurf, &msg );
      __CheckRC( sts, msg, "VLgetGeometry: UV Surface", wrapup );

      BSsfeval( surfGm, uvSurf->poles[0], uvSurf->poles[1], 0, 
		(IGRpoint *) &points[0], &rc );
      if( rc != BSSUCC )  goto wrapup;

      BSsfeval( surfGm, uvSurf->poles[3*(uvSurf->u_num_poles-1)], 
		uvSurf->poles[3*(uvSurf->u_num_poles-1)+1], 0,
                (IGRpoint *) &points[3], &rc );
      if( rc != BSSUCC )  goto wrapup;

      BSsfeval( surfGm, 
		uvSurf->poles[3*uvSurf->u_num_poles*(uvSurf->v_num_poles-1)], 
                uvSurf->poles[3*uvSurf->u_num_poles*(uvSurf->v_num_poles-1)+1], 
		0, (IGRpoint *) &points[6], &rc );
      if( rc != BSSUCC )  goto wrapup;

      dblcpy( &points[9], &unwSrfGm->poles[0], 3 );
      dblcpy( &points[12], &unwSrfGm->poles[3*(uvSurf->u_num_poles-1)], 3 );
      dblcpy( &points[15], 
	      &unwSrfGm->poles[3*uvSurf->u_num_poles*(uvSurf->v_num_poles-1)],
	      3 );
  }
  else
  {
     for( i=0; i<3; ++i )
     {
        if( i==0 ) { u_par = 0.0; v_par = 0.0; }
        if( i==1 ) { u_par = 0.0; v_par = 1.0; }
  	if( i==2 ) { u_par = 1.0; v_par = 0.0; }

        BSsfeval( surfGm, u_par, v_par, 0, 
		  (IGRpoint *) &points[3*i], &rc );
        if( rc != BSSUCC )  goto wrapup;

        BSsfeval( unwSrfGm, u_par, v_par, 0,
                  (IGRpoint *) &points[3*(i+3)], &rc );
        if( rc != BSSUCC )  goto wrapup;
     }
  }

  if( unw_to_plt ) VDgeom2GenMatrix( &points[9], &points[0], &type, matrix );
  else		   VDgeom2GenMatrix( &points[0], &points[9], &type, matrix );

  if (matrix_type) *matrix_type = type;
  
wrapup:
  _FREE( unwSrfGm  ) ;
  _FREE( surfGm  ) ;
  _FREE( uvSurf );

  End
  return sts;
}

end implementation VDSroot;
