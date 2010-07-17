/* $Id: VSmopBeam.I,v 1.1 2001/01/17 00:10:43 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VSmopBeam.I
 *
 * Description: Modify Operator Beam Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopBeam.I,v $
 *      Revision 1.1  2001/01/17 00:10:43  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/06/01  15:22:22  pinnacle
# Created: struct/vscmdsup/VSmopBeam.I by mdong for Service Pack
#
 *
 * History:
 * MM/DD/YY  	AUTHOR  	DESCRIPTION
 * 05/10/00  	Ming      	Creation
 ***************************************************************************/

class implementation Root;

#include "acrepdef.h"

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"

#include "vsmiscmacros.h"
#include "VSmop.h"

from GRgraphics import GRconstruct;

extern VDclassid OPP_VSbeam_class_id;
extern VDclassid OPP_VSsrcBeam_class_id;
extern VDclassid OPP_VSstfBeam_class_id;
extern VDclassid OPP_VSbooBeam_class_id;

static int traceFlag;

/* ------------------------------------------------------
** Master routine for filling in op info
*/
IGRstat VSmopBeamFillOpInfoVLA( TVSmopItemInfo *itemInfo )
{
  IGRstat retFlag = 0;
  IGRint  i;


  /*
  ** Init
  */
  VSmopOpInfoVLA_Init(&itemInfo->opInfoVLA);

  /* 
  ** Only certain ones have ops
  */
/*
  if ((itemInfo->classID != OPP_VSholPlate_class_id) &&
      (itemInfo->classID != OPP_VSbooPlate_class_id) &&
      (itemInfo->classID != OPP_VSsplPlate_class_id) &&
      (itemInfo->classID != OPP_VSgapPlate_class_id)) {
    goto wrapup;
  }
*/

  /*
  ** Cycle through op parents
  */
  for( i = 1 ; VSmopFillOpInfo(itemInfo,i) ; i++ );
  
  /*
  ** Done
  */
  if( traceFlag )
  {
    IGRint cnt;

    VSmopOpInfoVLA_GetCnt(&itemInfo->opInfoVLA,&cnt);
    printf("Op Count %d\n",cnt);
  }
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------
** Go through vla looking for op macroID
*/
IGRstat VSmopMatchOpInfoBymacroID(TVSmopOpInfoVLA *infoVLA,
			          TGRid           *macroID)
{
  IGRstat      retFlag = 0;
  IGRint       i;
  TVSmopOpInfo *infoX;
  

  /*
  ** Arg check
  */
  if( infoVLA == NULL || macroID == NULL ) goto wrapup;
  
  /*
  ** Cycle through
  */
  for( i = 0;
       VSmopOpInfoVLA_GetNth(infoVLA,i,NULL,&infoX);
       i++ )
  {
    if( (macroID->objid == infoX->macroID.objid) && 
	(macroID->osnum == infoX->macroID.osnum))
    {
      retFlag = 1;
      goto wrapup;
    }
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
** Recusre routine for filling one beam info
** then going to parent
*/
IGRstat VSmopFillBeamItemInfo( TVSmopItemInfoVLA *itemInfoVLA,
                               TGRobj_env        *pieceOE )
{
  IGRstat retFlag = 1;
  IGRstat sts;
  TVSmopItemInfo *itemInfo;
  TGRobj_env parentOE;


  /*
  ** Make sure it is a beam
  */
  sts = vdobj$IsAncestryValid( objOE = pieceOE,
			       superClassID = OPP_VSbeam_class_id );
  if( !(sts&1) ) goto wrapup;

  /*
  ** Initialize next item
  */
  VSmopItemInfoVLA_GetAppend( itemInfoVLA, &itemInfo );
  if( itemInfo == NULL )
  {
    printf("Problem getting itemInfo from vla\n");
    goto wrapup;
  }
  
  itemInfo->miscFlag    = 0;
  itemInfo->statusFlag  = 0;
  itemInfo->hilitedFlag = 0;

  itemInfo->itemOE = *pieceOE;
  vdobj$Get( objOE  =  pieceOE, classID = &itemInfo->classID );

  /*
  ** The vla should be empty but does not hurt
  */
  VSmopOpInfoVLA_Empty( &itemInfo->opInfoVLA );
  
  /*
  ** Done for source beams
  */
  if( (itemInfo->classID == OPP_VSstfBeam_class_id) || 
      (itemInfo->classID == OPP_VSsrcBeam_class_id) )
  {
    retFlag = 1;
    goto wrapup;
  }

  /*
  ** Now fill in ops data, note that the vla should be empty 
  */
  VSmopBeamFillOpInfoVLA( itemInfo );

  /*
  ** Now recusre on first parent
  */
  vdobj$GetTemplate( objOE      = &itemInfo->itemOE, 
                     nth        =  0, 
                     templateOE = &parentOE );

  VSmopFillBeamItemInfo( itemInfoVLA, &parentOE );

wrapup:
  return retFlag;
}

/* --------------------------------------------------
** Fill in item vla for a beam
** The vla must already be initialized and empty
** Just a buffer between the world and the recurse routine
*/
IGRstat VSmopFillBeamItemVLA( TVSmopPieceInfo *beamInfo )
{
  IGRstat retFlag = 0;


  traceFlag = 0;
  
  /*
  ** Arg check
  */
  if( beamInfo == NULL ) goto wrapup;
  
  /*
  ** The vla should be empty but does not hurt
  */
  VSmopItemInfoVLA_Empty( &beamInfo->itemInfoVLA );
  
  /*
  ** Rescurse fill
  */
  retFlag = VSmopFillBeamItemInfo( &beamInfo->itemInfoVLA, 
				   &beamInfo->pieceOE );

  /*
  ** Check
  */
  if( traceFlag )
  {
    IGRint cnt;

    VSmopItemInfoVLA_GetCnt( &beamInfo->itemInfoVLA, &cnt );
    printf("Item Count %d\n", cnt);
  }
  
wrapup:
  return retFlag;
}

/*
** --------------------------------------------------------
** Construct the brand new beam object of class VSbooBeam
** --------------------------------------------------------
*/
IGRstat VSmopBeamConstructNewBeam( TGRmd_env  *cstEnv,
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
  attr.representation = myRep;
  attr.parent_count   = 1;
  attr.parent_list    = parentOE ;
  attr.feature_att    = NULL;
  vs$fill_cnst_list( Cnst_list       = cst,
                     Msg             = &msg,
                     Env_info        = cstEnv,
                     Display         = NULL,
                     Level           = 0,
                     Class_attr      = &attr );

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
    if( !(sts&1) )
    {
      printf("GRconstruct failed!\n");
      goto wrapup;
    }
  }

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamConstructNewBeam */

end implementation Root;



