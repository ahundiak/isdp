 /* ID: not yet in Pinnacle
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1CSMatrix.I
 *
 * Description: Set routines for Matrix recovery and use
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: 
# Virsion 1.0  
# pn
#
# 
# 
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 00/25/00  pn      Creation
 * 
 ***************************************************************************/ 

#include "VDct1.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"
#include "VDppl1.h"
#include "VDsa.h"
#include "growner.h"
#include "ACrg_collect.h"
#include "VDtypedef.h"
#include "v_miscmacros.h"
#include "vdparmacros.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1CSMatrix.C");


/* #define vdsDEBUG 1 */
#include "v_dbgmacros.h"

from    GRgencs  import GRgetmatrix;
#define UNDEFINED  "undefined"
/* ----------------------------------------
 * External Routines
 */
extern IGRint     GRconfirm_box();
extern IGRint     VDnotify_box();
#if 0
// display a message
IGRstat VDct1SetNotifyBox(IGRchar msg[256])
{
  return VDnotify_box(msg);
}
#endif
#if 0
/* -----------------------------------------------------------------
 * Pick up the Location of the Part
 */

IGRstat VDct1GetPartLocation(TGRid *nodeID, TGRmd_env *nodeEnv, IGRdouble *location )
{
  IGRstat       retFlag;
  IGRstat       traceFlag;
  IGRlong       pMsg;
  TACrg_coll    Collect[3];
  
  

  // initalize
  SetProc( VDct1GetPartLocation ); Begin

  retFlag = 0 ;
  if( ! location ) goto wrapup ;

  strcpy ( Collect[0].name , "loc_x" );
  strcpy ( Collect[1].name , "loc_y" );
  strcpy ( Collect[2].name , "loc_z" );

  retFlag = vd$review_params (pMsg       = &pMsg,
			      pComponent = nodeID,
			      NbParams   = 3,
			      pList      = Collect,
			      pMdEnv     = nodeEnv);
  
  if ( !(retFlag&pMsg&1)) goto wrapup ;

    
  location[0] = Collect[0].desc.value.att_exp ;
  location[1] = Collect[1].desc.value.att_exp ;
  location[2] = Collect[2].desc.value.att_exp ;
 
    __DBGpr_vec( "Position" , location );
  

  // success
  retFlag = 1;
  // oh well
wrapup:
  // say bye
  End
  return retFlag;
  
}
#endif
#if 0

/* -----------------------------------------------------------------
 * Start the CS node matrix at undefined
 */
IGRstat VDct1CSStartNodeMatrix(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  IGRlong I       = 0.0;

  TVDfld fld;
  IGRchar    fldName[256];
  
  strcpy(fldName,UNDEFINED);
 
 // get the Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat1", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,fldName);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat2", 
		fld   = &fld);
  sprintf(fld.val.txt,fldName);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat3", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,fldName);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat4", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,fldName);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  


  // success
  retFlag = 1;
  // oh well  
wrapup:
  
  return retFlag;
  
}

#endif

#if 0
/* ----------------------------------------------------------------
 * get the matrix for a node
 */
IGRstat VDct1CSGetNodeMatrix(TGRid *nodeID,TGRobj_env *csOE)
{
  IGRstat retFlag= 0;
  IGRstat traceFlag = 0;
  
  
  IGRint  I = 0;
  
  IGRstat sts,msg;
  IGRchar tmp[256], nameCS[256], nameNode[256];

  TVDctBaseInfo baseInfo;
  TVDfld fld;
  
  IGRmatrix mat;
  
  // Say Hi
  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CSGetNodeMatrix\n");

  // Arg Check
  if ((nodeID  == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if (csOE == NULL) goto wrapup;// || (csOE->obj_id.objid == NULL_OBJID)) goto wrapup;

   // Go get the data
  if (traceFlag) printf("Sending the request\n");

  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,mat),
		senderid = NULL_OBJID,
		targetid = csOE->obj_id.objid,
		targetos = csOE->obj_id.osnum);

  if (traceFlag) printf("Returned from request\n");
  // test if the mat(s) are to be changed 
  // Rule: change if (mat1 = "undefined") -> initial condition before linking 
  //       except if the Name of the CS and Coordinate System are same
  sprintf(tmp,UNDEFINED);
  
  // get the Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat1", 
		fld   = &fld);
  // if the value is not "undefined"
  if (strcmp(fld.val.txt,tmp)) sts = 1;

 //  get the names
 vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
 strcpy(nameNode,baseInfo.nodeName);
 

 vdobj$Get(objOE    = csOE,
	   objName  = nameCS);

 // if the names are the same it is ok! 
 if (!strcmp(nameCS,nameNode)) sts = 0;

  if (!(sts & 1)) goto wrapup;
  
  // get the Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat1", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,"%12.2f %12.2f %12.2f %12.2f",mat[0],mat[1],mat[2],mat[3]);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat2", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,"%12.2f %12.2f %12.2f %12.2f",mat[4],mat[5],mat[6],mat[7]);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat3", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,"%12.2f %12.2f %12.2f %12.2f",mat[8],mat[9],mat[10],mat[11]);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  

  // get the next Attribute
  vdcol$GetAttr(objID = nodeID, 
		name  = "mat4", 
		fld   = &fld);

  // set the Attribute
  sprintf(fld.val.txt,"%12.2f %12.2f %12.2f %12.2f",mat[12],mat[13],mat[14],mat[15]);
  if (*fld.name) vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);  


 
  // Rename the Coordinate system ==========================
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  strcpy(tmp,baseInfo.nodeName);
  // special exception for Renaming node  
  if (!strcmp(baseInfo.nodeType,"CS"))
      {
	
	vdobj$ChgName(objOE = csOE,
		      name  = tmp);
      }
	
	// connect it up
	VDct1ConnectNodeToModelObject(nodeID, csOE);

	// flash the update to the screen
	VDct1CmdMgrRenamedNode(&nodeID);

    
	// success
	retFlag = 1;
	// oh well  
wrapup:
  if (traceFlag) printf("<<< VDct1CSGetNodeMatrix %d\n",retFlag);
  
  return retFlag;
  
}
#endif
