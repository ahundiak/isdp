/* $Id: VDchn.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDchn.I
 *
 * Description: Channel toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDchn.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.1  2000/08/16  15:10:08  pinnacle
# Created: vds/vdah/VDchn.I by aharihar for Service Pack
#
# Revision 1.4  1999/10/26  18:37:04  pinnacle
# ah
#
# Revision 1.3  1999/05/28  22:10:26  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/31/98  ah      Creation
 * 05/28/99  ylong   TR179900636 
 * 08/14/99  ah      Added VDCHN_NAME_MK_NAT_BDRY

 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDvla.h"
#include "VDchn.h"
#include "VDobj.h"

#ifndef   v_misc_include
#include "v_miscmacros.h" /* Gets VDmem.h as well */
#endif

/* -------------------------------------------------
 * Channel select sub system
 * Buffer commonly used channel selecta
 * Returns pointer directly to internal static data
 * so be careful
 */
static struct {
  IGRint          init;
  OM_S_CHANSELECT select;
} g_chnSELECTs[16];

OM_S_CHANSELECT *VDchnGetChnSelect(IGRint a_chnIDX)
{
  IGRint sts;

  OM_S_CHANSELECT *chnSELECT = NULL;
  IGRchar          chnNAME[32];

  // Bounds check
  if ((a_chnIDX < 0) || (a_chnIDX > 15)) goto wrapup;

  // Return pointer if inited
  chnSELECT = &g_chnSELECTs[a_chnIDX].select;
  if (g_chnSELECTs[a_chnIDX].init) goto wrapup;

  // Get channel name
  *chnNAME = 0;
  switch(a_chnIDX) {

  case VDCHN_IDX_FATHER:        strcpy(chnNAME,VDCHN_NAME_FATHER);        break;
  case VDCHN_IDX_CHILDREN:      strcpy(chnNAME,VDCHN_NAME_CHILDREN);      break;
  case VDCHN_IDX_NOTIFICATION:  strcpy(chnNAME,VDCHN_NAME_NOTIFICATION);  break;
  case VDCHN_IDX_LISTENER:      strcpy(chnNAME,VDCHN_NAME_LISTENER);      break;
  case VDCHN_IDX_TO_OWNERS:     strcpy(chnNAME,VDCHN_NAME_TO_OWNERS);     break;
  case VDCHN_IDX_TO_COMPONENTS: strcpy(chnNAME,VDCHN_NAME_TO_COMPONENTS); break;
  case VDCHN_IDX_BT_TO_NOTIFY:  strcpy(chnNAME,VDCHN_NAME_BT_TO_NOTIFY);  break;
  case VDCHN_IDX_TO_LOOPSET:    strcpy(chnNAME,VDCHN_NAME_TO_LOOPSET);    break;
  case VDCHN_IDX_CT1_TO_NOTIFY: strcpy(chnNAME,VDCHN_NAME_CT1_TO_NOTIFY); break;
    
  default:
    chnSELECT = NULL; 
    goto wrapup;
  }

  // Make selection
  sts = om$make_chanselect(
    channame     = chnNAME, 
    p_chanselect = chnSELECT
  );
  if (!(sts & 1)) {
    printf("Problem making channel selector %s\n",chnNAME);
    chnSELECT = NULL;
    goto wrapup;
  }

wrapup:
  return chnSELECT;
}

#define VDCHN_LINK_MAX  1024

/* -------------------------------------------------
 * Main routine for getting objects on a channel
 */
IGRstar VDchnGet(
  TGRobj_env *il_objOE,
  TGRid      *il_objID,

  IGRchar    *ic_NAME,
  IGRint      ic_IDX,

  IGRint     *oc_CNT,

  IGRint      ir_objIDX,
  TGRid      *or_objID,

  TVDvlaID   *or_vlaID,

  OM_S_CHANSELECT **oc_SEL
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT    chnSELECT;
  OM_S_CHANSELECT *p_chnSELECT = NULL;

  TGRid   chnID;
  IGRuint chnCNT = 0;

  TGRid   objID;

  // Used to get all objects
  OM_S_OBJECT_LINKAGE   chnLinkStack[VDCHN_LINK_MAX];
  OM_S_OBJECT_LINKAGE  *chnLinks = NULL;
  IGRuint               chnLinkCnt;
  IGRuint               chnLinkSize;
  IGRuint               i;

  // Reset output data
  if (oc_CNT   != NULL) *oc_CNT = 0;
  if (or_objID != NULL)  or_objID->objid = NULL_OBJID;
  if (oc_SEL   != NULL) *oc_SEL = NULL;
  
  // Find channel (Could be all we want)
  if (ic_NAME == NULL) p_chnSELECT = VDchnGetChnSelect(ic_IDX);
  else {

    /* Make a channel selector */
    sts = om$make_chanselect(
      channame     =  ic_NAME, 
      p_chanselect = &chnSELECT
    );
    if (!(sts & 1)) {
      printf("Problem making channel selector %s\n",ic_NAME);
      goto wrapup;
    }
    p_chnSELECT = &chnSELECT;
  }
  if (p_chnSELECT == NULL) goto wrapup;
  if (oc_SEL != NULL) *oc_SEL = p_chnSELECT;
  
  // Pull the object with channels
  chnID.objid   = NULL_OBJID;
  if (il_objID != NULL) chnID = *il_objID;
  if (il_objOE != NULL) chnID =  il_objOE->obj_id;
  if (chnID.objid == NULL_OBJID) goto wrapup;

  // Want the number of objects on channel
  if ((oc_CNT != NULL) || (or_vlaID != NULL)) {

    sts = om$get_channel_count ( 
      osnum        =  chnID.osnum,
      objid        =  chnID.objid,
      p_chanselect =  p_chnSELECT,
      count        = &chnCNT
    );
    if (!(sts & 1)) goto wrapup;

    if (oc_CNT != NULL) *oc_CNT = chnCNT;
    
  }

  // Want the object at a particular index
  if (or_objID != NULL) {

    objID.objid = NULL_OBJID;

    sts = om$get_objid_at_index ( 
      osnum         = chnID.osnum,
      objid         = chnID.objid,
      p_chanselect  = p_chnSELECT,
      index         =  ir_objIDX,
      objidaddr     = &objID.objid,
      osnumaddr     = &objID.osnum);

    if (!(sts & 1)) goto wrapup;
    
    *or_objID = objID;

  }

  // Fill up vla with all elements?
  if ((or_vlaID != NULL) && (chnCNT > 0)) {

    // Allocate more room if need be
    if (chnCNT <= VDCHN_LINK_MAX) {
      chnLinks    = chnLinkStack;
      chnLinkSize = sizeof(chnLinkStack);
    }
    else {
      chnLinks = (OM_S_OBJECT_LINKAGE*)_CALLOC(chnCNT,OM_S_OBJECT_LINKAGE);
      if (chnLinks == NULL) {
        printf("Could not allocate memory for channel objects\n");
        goto wrapup;
      }
      chnLinkSize = chnCNT * sizeof(OM_S_OBJECT_LINKAGE);
    }
    chnLinkCnt = 0;

    /* Grab the objects */
    sts  = om$get_channel_objects(
      osnum = chnID.osnum,
      objid = chnID.objid,
      p_chanselect = p_chnSELECT,
      list  =  chnLinks,
      size  =  chnLinkSize,
      count = &chnLinkCnt
    );
    if (!(sts & 1)) {
      printf("Problem getting channel objects\n");
      goto wrapup;
    }

    /* Xfer Over */
    for(i = 0; i  < chnLinkCnt; i++) {
      objID.osnum = chnLinks[i].osnum;
      objID.objid = chnLinks[i].S_objid;
      
      vdvla_id$Append(vla = or_vlaID, objID = &objID);
    }
  }

  retFlag = 1;

wrapup:
  if (chnLinks != chnLinkStack) _FREE(chnLinks);
  return retFlag;
}

/* -----------------------------------------------
 * Gets list of objects on a channel
 * Useful for unordered channels
 * Prevents overflow of output buffer
 */
IGRstat VDchnGetList(
  TGRobj_env *objOE,
  TGRid      *objID,

  IGRchar    *chnName,
  IGRint      chnIDx,
  IGRint      maxCnt,

  IGRint     *cnt,
  TGRid      *outIDs)
{
  IGRstat retFlag = 0;
  
  TVDvlaID vlaID;
  IGRint   i;
  
  // Setup for vla
  vdvla_id$Construct(vla = &vlaID);

  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;

  // Get the objects
  vdchn$Get2(objOE   = objOE,
	     objID   = objID,

	     chnName = chnName,
	     chnIDx  = chnIDx,

	     cnt     = cnt,
	     outVLA  = &vlaID);
  
  // Limit the count
  if (*cnt > maxCnt) *cnt = maxCnt;
  
  // Xfer
  if (outIDs) {  
    for(i = 0; i < *cnt; i++) {
      vdvla_id$GetAt(vla = &vlaID, nth = i, objID = &outIDs[i]);
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  vdvla_id$Delete(vla = &vlaID);
  return retFlag;
}

/* -----------------------------------------------
 * Gets the list of objects that either belong to or derived from a specified
   class on a specified channel of a given object.
 * Prevents overflow of output buffer
   ----------------------------------------------- */
#include "v_dbgmacros.h"

IGRstat VDchnGetFilteredList( TGRobj_env *objOE, TGRid *objID,
			      IGRchar *chnName, IGRint chnIDx, IGRint maxCnt,
			      IGRint *cnt, TGRid *outIDs,
			      GRclassid FltrClsId, IGRchar *FltrClNam)
{
    struct GRid	ListOfIDs[100]; // A hard-coded max value of 100 assumed.
    GRclassid	ClsIDofFilter;
    IGRint	i,NumFltObjs;

    SetProc(VDchnGetFilteredList); Begin

    if(cnt==NULL)
    {
	printf(" VDchnGetFilteredList called with cnt=NULL!\n");
	End
	return OM_E_INVARG;
    }

    if (FltrClNam)
    {
	om$get_classid( classname = FltrClNam,
			p_classid = &ClsIDofFilter );
    }
    else
	ClsIDofFilter = FltrClsId;

    /* If outIDs is NULL, caller wants to know how many objects in the filtered
     * list. Therefore, have to call vdchn$GetList with maxCnt hardcoded to 100
     * (assumed to be conservative). */

    vdchn$GetList( objOE	= objOE,
		   objID	= objID,
		   chnName	= chnName,
		   chnIDx	= chnIDx,
		   maxCnt	= 100,
		   cnt		= cnt,
		   outIDs	= ListOfIDs );
    __DBGpr_objlist("Entire obj list",*cnt,ListOfIDs);

    for( i=0,NumFltObjs=0 ; i<(*cnt) ; i++ )
    {
	if( vdobj$IsAncestryValid( objID	= &ListOfIDs[i],
				   superClassID = ClsIDofFilter )
			    == OM_S_SUCCESS )
	{
	    NumFltObjs++;

	    if( outIDs && NumFltObjs<=maxCnt )
	    {
		(outIDs+NumFltObjs-1)->objid = ListOfIDs[i].objid;
		(outIDs+NumFltObjs-1)->osnum = ListOfIDs[i].osnum;
	    }
	}
    }
    *cnt = NumFltObjs;
#ifdef vdsDEBUG
    if( *cnt && outIDs )
	__DBGpr_objlist("Filtered class list",*cnt,outIDs);
#endif 

    End
    return OM_S_SUCCESS;

}


extern VDclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_ASsource_class_id;

/* --------------------------------------------------------
 * Helper function for finding a child of an object
 *
 */
IGRstar VDchnGetChildrenByClass(TGRobj_env *i_objOE,
				TGRid      *i_objID,
				VDclassid   i_classID,
				IGRchar    *i_className,
				TGRid      *o_childID,
				TVDvlaID   *o_vla)
{
  IGRstat retFlag = 0;
  IGRstat sts, sts1;
  
  IGRint  i,j;

  TGRid     parentID;
  
  TGRid     childID;
  VDclassid childCLASS;

  TGRid     notifyID;
  TVDvlaID  notifyVLA;

  // Init
  vdvla_id$Construct(vla = &notifyVLA);

  // vdobj$Print(objID = i_objID);

  // Arg check
  if (o_childID) o_childID->objid = NULL_OBJID;
  
  // Init
  parentID.objid = NULL_OBJID;
  if (i_objID) parentID = *i_objID;
  if (i_objOE) parentID =  i_objOE->obj_id;
  if (parentID.objid == NULL_OBJID) goto wrapup;

  if (i_className) {
    om$get_classid(classname =  i_className,
		   p_classid = &childCLASS);
  }
  else childCLASS = i_classID;

  // vdobj$Print(objID = &parentID);
  
  // Start by adding any directly connected
  for(i = 0; 
      vdchn$Get2(objID = &parentID, chnIDx = VDCHN_IDX_CHILD, nth = i, outID = &childID); 
      i++) {

    sts = vdobj$IsAncestryValid(objID = &childID, superClassID = childCLASS);
    if (sts & 1) {
      if (o_childID) {
	*o_childID = childID;
	retFlag = 1;
	goto wrapup;
      }
      if (o_vla) {
	vdvla_id$Append(vla = o_vla, objID = &childID);
      }
    }    
  }

  // Cycle through listener looking for ACpretendins
  vdchn$Get2(objID  = &parentID,
             chnIDx = VDCHN_IDX_NOTIFICATION,
             outVLA = &notifyVLA);
  
  for(i = 0; vdvla_id$GetAt(vla = &notifyVLA, nth = i, objID = &notifyID); i++) {

    // vdobj$Print(objID = &notifyID);

    sts = vdobj$IsAncestryValid(objID = &notifyID, superClassID = OPP_ACpretendin_class_id);

    /* TR179900636 */
    sts1 = vdobj$IsAncestryValid(objID = &notifyID, superClassID = OPP_ASsource_class_id);
    if ((sts & 1) || (sts1 & 1)) {
            
      for(j = 0; 
	  vdchn$Get2(objID = &notifyID, chnIDx = VDCHN_IDX_CHILD, nth = j, outID = &childID); 
	  j++) {

	// vdobj$Print(objID = &childID);
	
	sts = vdobj$IsAncestryValid(objID = &childID, superClassID = childCLASS);
	if (sts & 1) {
	  if (o_childID) {
	    *o_childID = childID;
	    retFlag = 1;
	    goto wrapup;
	  }
	  if (o_vla) {
	    vdvla_id$Append(vla = o_vla, objID = &childID);
	  }
	}
      }
    }
  }
  
  retFlag = 1;

wrapup:
  vdvla_id$Delete(vla = &notifyVLA);

  return retFlag;
}

end implementation Root;

