/* $Id: VSmopPlate.I,v 1.3 2001/04/18 22:20:23 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VSmopPlate.I
 *
 * Description: Modify Operator Plate Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopPlate.I,v $
 *      Revision 1.3  2001/04/18 22:20:23  jayadev
 *      TR# MP 5030
 *
 *      Revision 1.2  2001/01/17 00:10:19  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/06/06  21:02:46  pinnacle
# Replaced: struct/vscmdsup/VSmopPlate.I for:  by mdong for Service Pack
#
# Revision 1.2  2000/06/01  15:21:38  pinnacle
# Replaced: struct/vscmdsup/VSmopPlate.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/05/03  19:56:50  pinnacle
# initial revision
#
# Revision 1.5  1999/07/27  20:25:52  pinnacle
# (No comment)
#
# Revision 1.4  1999/06/16  15:52:28  pinnacle
# (No comment)
#
# Revision 1.3  1999/05/06  21:44:16  pinnacle
# (No comment)
#
# Revision 1.2  1999/05/06  21:29:08  pinnacle
# (No comment)
#
# Revision 1.1  1999/04/26  20:53:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Creation
 * 05/15/00  Ming    Modify function VSmopFillOpInfo()
 * 04/18/01  Jayadev Fix for TR# MP 5030
 ***************************************************************************/

class implementation Root;

#include "acrepdef.h"

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"

#include "vsmiscmacros.h"
#include "VSmop.h"

from ACpretend  import ACgive_downscan;
from ACcpx      import find_macro;
from ACcpx      import ACconnect_pretend;
from NDmacro    import ACgive_structure;
from GRgraphics import GRconstruct;

extern VDclassid OPP_ACpretend_class_id;
extern VDclassid OPP_ASsource_class_id;
extern VDclassid OPP_ACconst_class_id;

extern VDclassid OPP_VSplate_class_id;
extern VDclassid OPP_VSsrcPlate_class_id;
extern VDclassid OPP_VSvarPlate_class_id;
extern VDclassid OPP_VSgapPlate_class_id;
extern VDclassid OPP_VSsplPlate_class_id;
extern VDclassid OPP_VSsubPlate_class_id;
extern VDclassid OPP_VSholPlate_class_id;
extern VDclassid OPP_VSbooPlate_class_id;

static int traceFlag;

/* -----------------------------------------------------
 * Look for macro cutting curves
 */
IGRstat VSmopGetOps(TGRobj_env      *opOE, 
		    TVSmopOpInfoVLA *opInfoVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid       macroDefID;
  TGRobj_env *macroOE;
  TGRobj_env  macroOptOE;
  IGRchar     macroOptPath[DI_PATH_MAX];

  TVSmopOpInfo opInfo;

  TGRobj_env  cutOE;

  IGRint i,cnt;

  IGRint index,ACrc;
  Tret_struct  rs;

  DIchar **lines = NULL;

  IGRchar opName [128];
  IGRchar opValue[128];

  TGRid   parentID;
  
  // Arg Check
  if ((opOE == NULL) || (opInfoVLA == NULL)) goto wrapup;
  
  
  // Must be aconst
  sts = vdobj$IsAncestryValid(objOE        = opOE,
                              superClassID = OPP_ACconst_class_id);
  if (!(sts & 1)) {

    // Must be a simple cutting objects, just source it
    VDahMakeSource(opOE,&parentID);
    if (parentID.objid == NULL_OBJID) goto wrapup;

    opInfo.cutOE         = *opOE;
    opInfo.macroID.objid = NULL_OBJID;
    opInfo.parentID      = parentID;
    
    VSmopOpInfoVLA_Append(opInfoVLA,&opInfo);

    retFlag = 1;    
    goto wrapup;
  }

  // It's a macro
  macroOE = opOE;

  // Need the macro defination
  sts = om$send(msg = message ACcpx.find_macro(&macroDefID),
		senderid = NULL_OBJID,
                targetid = macroOE->obj_id.objid,
                targetos = macroOE->obj_id.osnum);
  if (!(sts & 1)) goto wrapup;

  // Need to macro options collector
  *macroOptPath = 0;
  sts = COm_get_option_grid(&macroDefID, &macroOptOE.obj_id, macroOptPath ) ;
  if (!(sts & 1)) goto wrapup;

  gr$get_module_env(buffer = &macroOptOE.mod_env);

//  vdobj$Print(objOE = &macroOptOE);
//  printf("Path %s\n",macroOptPath);

  sts = di$find(regexp    = "~~operator*",
		start_dir = macroOptPath,
		lines     = &lines,
		options   = OPT_LEVEL,
                max_level = 0,
		ptr       = &cnt );
		
  if (sts != DIR_S_SUCCESS) goto wrapup;

  // Cycle through each operator
  for(i = 0; i < cnt; i++) {

    strcpy(opName,lines[i]);
    
    // First get the foot name
    index = -1 ;
    sts = om$send(msg = message NDmacro.
                  ACgive_structure(&ACrc, 
                                   &index, 
                                    opName,
				   &rs, 
                                   &macroOptOE.mod_env),
                  senderid = NULL_OBJID,
                  targetid = macroOptOE.obj_id.objid,
                  targetos = macroOptOE.obj_id.osnum);

    if((!(sts & 1 & ACrc)) || (rs.type != text_type)) {
      goto wrapup;
    }
    
    strcpy(opValue,rs.var.text_st.text_string);

    // Need to use a trick to get proper pretend

    sts = om$send(msg = message ACcpx.
		  ACconnect_pretend(&ACrc,
				    opValue,
				    &parentID),
		  senderid = macroOE->obj_id.objid,
		  targetid = macroOE->obj_id.objid,
		  targetos = macroOE->obj_id.osnum);

    if (!(sts & ACrc & 1)) {
      printf("Problem getting pretend object\n");
      goto wrapup;
    }
    
    // Get the foot from the macro occurance
    vdobj$GetFoot(objOE    = macroOE, 
		  footName = opValue, 
		  footOE   = &cutOE);

    // vdobj$Print(objOE = &cutOE);
    if (cutOE.obj_id.objid == NULL_OBJID) {
      printf("Problem getting operator from macro\n");
      goto wrapup;
    }
    
    opInfo.cutOE    = cutOE;
    opInfo.macroID  = macroOE->obj_id;
    opInfo.parentID = parentID;

    VSmopOpInfoVLA_Append(opInfoVLA,&opInfo);

  }
  di$free(lines = lines,count = cnt);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
** Fill in ope for item
*/
IGRstat VSmopFillOpInfo(TVSmopItemInfo *itemInfo, IGRint nth)
{
  IGRstat       retFlag = 0;
  TVSmopOpInfo  *opInfo;
  TGRid         parentID, macroID;
  IGRint        i;


  parentID.objid = NULL_OBJID;
  macroID.objid  = NULL_OBJID;

  /*
  ** Get it's parent, should be either pretend or source
  */
  vdchn$Get2(objOE  = &itemInfo->itemOE,
             chnIDx = VDCHN_IDX_FATHER,
             nth    = nth,
             outID  = &parentID);

  if( parentID.objid == NULL_OBJID ) goto wrapup;

  retFlag = 1;

  /*
  ** For ACpretend
  */
  if( vdobj$IsAncestryValid(objID        = &parentID,
                            superClassID = OPP_ACpretend_class_id) )
  {
    /*
    ** Use this as a trick to get any attached macros
    */
    vdobj$GetPretendParent(pretendID = &parentID,
                           parentID  = &macroID);

    if( macroID.objid == NULL_OBJID ) goto wrapup;

    /*
    ** Search if the same opertor already exists
    */
    /*
    if( VSmopMatchOpInfoBymacroID(&itemInfo->opInfoVLA, &macroID) ) goto wrapup;
    */

    /*
    ** Get the opInfo spot
    */
    VSmopOpInfoVLA_GetAppend( &itemInfo->opInfoVLA, &opInfo );
    if( opInfo == NULL )
    {
      printf("Problem getting next opInfo\n");
      goto wrapup;
    }
    opInfo->parentID = parentID;
    opInfo->macroID  = macroID;

    /*
    ** Actual cutting object, it might be missing
    */
    vdobj$GetTemplate(objOE      = &itemInfo->itemOE,
                      nth        = nth,
                      templateOE = &opInfo->cutOE);
  }
  else
  {
    /*
    ** Get the opInfo spot
    */
    VSmopOpInfoVLA_GetAppend( &itemInfo->opInfoVLA, &opInfo );
    if( opInfo == NULL )
    {
      printf("Problem getting next opInfo\n");
      goto wrapup;
    }
    opInfo->parentID = parentID;
    opInfo->macroID.objid  = NULL_OBJID;

    /*
    ** Actual cutting object, it might be missing
    */
    vdobj$GetTemplate(objOE      = &itemInfo->itemOE,
                      nth        = nth,
                      templateOE = &opInfo->cutOE);
  }

  /*
  ** Misc
  */
  opInfo->miscFlag    = 0;
  opInfo->statusFlag  = 0;
  opInfo->hilitedFlag = 0;

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Master routine for filling in op info
 */
IGRstat VSmopFillOpInfoVLA(TVSmopItemInfo *itemInfo)
{
  IGRstat retFlag = 0;
  IGRint  i;

  // Init
  VSmopOpInfoVLA_Init(&itemInfo->opInfoVLA);

  // Only certain ones have ops
  if ((itemInfo->classID != OPP_VSholPlate_class_id) &&
      (itemInfo->classID != OPP_VSbooPlate_class_id) &&
      (itemInfo->classID != OPP_VSsplPlate_class_id) &&
      (itemInfo->classID != OPP_VSgapPlate_class_id)) {
    goto wrapup;
  }

  // Cycle through op parents
  for(i = 1; VSmopFillOpInfo(itemInfo,i); i++);
  
  // Done
  if (traceFlag) {
    IGRint cnt;
    VSmopOpInfoVLA_GetCnt(&itemInfo->opInfoVLA,&cnt);
    printf("Op Count %d\n",cnt);
  }
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Go through vla looking for op
 */
IGRstat VSmopFindOpInfoByID(TVSmopOpInfoVLA *infoVLA,
			    TGRid           *infoID,
			    IGRchar	    *opMacName,
			    TVSmopOpInfo   **info,
			    IGRint	    *NthRow)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVSmopOpInfo *infoX;
  IGRchar      macName[64];
  
  // Arg check
  if (info == NULL) goto wrapup;
  *info = NULL;
  if (infoVLA == NULL) goto wrapup;
  if (infoID  == NULL) goto wrapup;
  
  // Cycle through
  for(i = 0;
      VSmopOpInfoVLA_GetNth(infoVLA,i,NULL,&infoX);
      i++) {
    
    if ((infoID->objid == infoX->cutOE.obj_id.objid) && 
	(infoID->osnum == infoX->cutOE.obj_id.osnum))
    {
      vdobj$Get( objID = &infoX->macroID, objName = macName );
      if( *macName == 0 )
      {
	vdobj$Get( objID = &infoX->macroID, macName = macName );
	if( *macName == 0 ) strcpy( macName, "MACRO_NAME_NOT_FOUND" );
      }
      if( !(strcmp(macName,opMacName)) )
      {
        *info = infoX;
        if( NthRow ) *NthRow = i;
        retFlag = 1;
        goto wrapup;
      }
    }
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Go through vla looking for item
 */
IGRstat VSmopFindItemInfoByID(TVSmopItemInfoVLA *infoVLA,
			      TGRid           *infoID,
			      TVSmopItemInfo   **info)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVSmopItemInfo *infoX;
  
  // Arg check
  if (info == NULL) goto wrapup;
  *info = NULL;
  if (infoVLA == NULL) goto wrapup;
  if (infoID  == NULL) goto wrapup;
  
  // Cycle through
  for(i = 0;
      VSmopItemInfoVLA_GetNth(infoVLA,i,NULL,&infoX);
      i++) {
    
    if ((infoID->objid == infoX->itemOE.obj_id.objid) && 
	(infoID->osnum == infoX->itemOE.obj_id.osnum)) {
      *info = infoX;
      retFlag = 1;
      goto wrapup;
    }
    
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Go through vla looking for piece
 */
IGRstat VSmopFindPieceInfoByID(TVSmopPieceInfoVLA *infoVLA,
			       TGRid              *infoID,
			       TVSmopPieceInfo   **info)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVSmopPieceInfo *infoX;
  
  // Arg check
  if (info == NULL) goto wrapup;
  *info = NULL;
  if (infoVLA == NULL) goto wrapup;
  if (infoID  == NULL) goto wrapup;
  
  // Cycle through
  for(i = 0;
      VSmopPieceInfoVLA_GetNth(infoVLA,i,NULL,&infoX);
      i++) {
    
    if ((infoID->objid == infoX->pieceOE.obj_id.objid) && 
	(infoID->osnum == infoX->pieceOE.obj_id.osnum)) {
      *info = infoX;
      retFlag = 1;
      goto wrapup;
    }
    
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Recusre routine for filling one plate info
 * then going to parent
 */
IGRstat VSmopFillPlateItemInfo(TVSmopItemInfoVLA *itemInfoVLA,
                               TGRobj_env        *pieceOE)
{
  IGRstat retFlag = 1;
  IGRstat sts;

  TVSmopItemInfo *itemInfo;

  TGRobj_env parentOE;

  // Say hi
  if (traceFlag) {  
    printf(">>> VSmopFillPlateItemInfo\n");
    vdobj$Print(objOE = pieceOE);
  }
  
  // Make sure it is a plate
  sts = vdobj$IsAncestryValid(objOE = pieceOE,
			      superClassID = OPP_VSplate_class_id);
  if (!(sts & 1)) goto wrapup;

  // Initialize next item
  VSmopItemInfoVLA_GetAppend(itemInfoVLA,&itemInfo);
  if (itemInfo == NULL) {
    printf("Problem getting itemInfo from vla\n");
    goto wrapup;
  }
  
  itemInfo->miscFlag    = 0;
  itemInfo->statusFlag  = 0;
  itemInfo->hilitedFlag = 0;

  itemInfo->itemOE = *pieceOE;
  vdobj$Get(objOE  =  pieceOE, classID = &itemInfo->classID);

  // The vla should be empty but does not hurt
  VSmopOpInfoVLA_Empty(&itemInfo->opInfoVLA);
  
  // Base surface serves as graphics
  vdobj$GetFoot(objOE    =  pieceOE, 
                footName = "plate:base", 
                footOE   = &itemInfo->graphicOE);
  // Done for source plates
  if ((itemInfo->classID == OPP_VSsrcPlate_class_id) || 
      (itemInfo->classID == OPP_VSvarPlate_class_id)) {
    retFlag = 1;
    goto wrapup;
  }

  // Combine sub plates and their parent into one step
  if (itemInfo->classID == OPP_VSsubPlate_class_id) {

    itemInfo->subOE = itemInfo->itemOE;

    vdobj$GetTemplate(objOE      = &itemInfo->itemOE, 
                      nth        =  0, 
                      templateOE = &parentOE);

    // Make sure it is a plate
    sts = vdobj$IsAncestryValid(objOE = &parentOE,
			        superClassID = OPP_VSplate_class_id);
    if (!(sts & 1)) goto wrapup;

    itemInfo->itemOE =  parentOE;
    vdobj$Get(objOE  = &parentOE, classID = &itemInfo->classID);
  }

  // Now fill in ops data, note that the vla should be empty 
  VSmopFillOpInfoVLA(itemInfo);

  // Now recusre on first parent
  vdobj$GetTemplate(objOE      = &itemInfo->itemOE, 
                    nth        =  0, 
                    templateOE = &parentOE);

  VSmopFillPlateItemInfo(itemInfoVLA,&parentOE);

wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Fill in item vla for a plate
 * The vla must already be initialized and empty
 * Just a buffer between the world and the recurse routine
 */
IGRstat VSmopFillPlateItemVLA(TVSmopPieceInfo *plateInfo)
{
  IGRstat retFlag = 0;

  traceFlag = 0;
  
  // Arg check
  if (plateInfo == NULL) goto wrapup;
  
  // The vla should be empty but does not hurt
  VSmopItemInfoVLA_Empty(&plateInfo->itemInfoVLA);
  
  // Rescurse fill
  retFlag = VSmopFillPlateItemInfo(&plateInfo->itemInfoVLA, 
				   &plateInfo->pieceOE);

  // Check
  if (traceFlag) {
    IGRint cnt;
    VSmopItemInfoVLA_GetCnt(&plateInfo->itemInfoVLA,&cnt);
    printf("Item Count %d\n",cnt);
  }
  
wrapup:
  return retFlag;
}

/*
** --------------------------------------------------------
** Construct the brand new plate object of class VSholPlate
** --------------------------------------------------------
*/
IGRstat VSmopConstructNewPlate( TGRmd_env  *cstEnv,
                                TGRobj_env *parentOE,
				IGRchar    *className,
                                TGRobj_env *constructedObject )
{
  IGRstat               retFlag;
  IGRlong               msg, sts;
  struct GRvg_construct cst ;
  struct VScnst_list    attr ;
  VSdspRep              myRep;


  retFlag      = 0;
  myRep        = AC_NO_REP;

  /*
  ** Fill construction list, do not specify the display
  ** parameters since object will take its parent part's.
  */
  vs$fill_cnst_list( Cnst_list       = cst,
                     Msg             = &msg,
                     Env_info        = cstEnv,
                     Display         = NULL,
                     Level           = 0,
                     Class_attr      = &attr );

  attr.representation = myRep;
  attr.parent_count   = 2;
  attr.parent_list    = parentOE ;
  attr.feature_att    = NULL;

  /*
  ** Construct the object
  */
  constructedObject->obj_id.osnum = cstEnv->_MD_OS;
  sts = om$construct( classname = className,
                      osnum     = cstEnv->_MD_OS,
                      p_objid   = &constructedObject->obj_id.objid,
                      msg       = message GRgraphics.GRconstruct(&cst) );
  if( !(sts&1) )
  {
    goto wrapup;
  }
  else
  {
    constructedObject->mod_env = *cstEnv;
    vs$bulk_display( count   = 1,
                     objenvs = constructedObject,
                     theEnv  = cstEnv,
                     dpmode  = GRbd ) ;
  }

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopConstructNewPlate */

end implementation Root;



