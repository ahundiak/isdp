/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimColl.I
 *
 * Description: Friendly interface to various collectors
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimColl.I,v $
 *      Revision 1.1.2.3  2004/03/29 17:26:53  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj.h"
#include "VDobj2.h"
#include "VDtest.h"
#include "VDdom2.h"

#include "VDos.h"
#include "VDdir.h"
#include "VDpdm.h"
#include "VDrisc.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"

VDASSERT_FFN("VDPaimColl.I");

/* ----------------------------------------------
 * Utility routine for defaulting to the current os
 * if none was specified.
 */
static VDosnum getOS(VDosnum osnum)
{
  if (osnum == OM_K_NOT_AN_OS) 
  {
    VDosGetCurrentOS(&osnum);
  }
  return osnum;
}

/* -----------------------------------------------
 * Get the path to the AIM Global Data
 * Create the directory if it does not exist
 */
void VDPaimGetIGENODDirectory(VDosnum osnum, char *path)
{
  VDASSERT_FN("VDPaimGetIGENODDirectory");

  char fileName[128];
  char    curFileName[128];
  VDosnum curOS;

  /* Arg check */
  VDASSERTW(path); *path = 0;
  osnum = getOS(osnum);

  /* Simple Build */
  VDosGetFileName(osnum,fileName);
  if (*fileName == 0) goto wrapup;

  sprintf(path,":%s:IGENOD",fileName);

  /* Need to tweak if in reference file */
  VDosGetCurrentOS(&curOS);
  if (curOS == osnum) goto wrapup;

  VDosGetFileName(curOS,curFileName);
  sprintf(path,":%s:ref:%s:IGENOD",curFileName,fileName);

wrapup:
  return;
}

void VDPaimGetSirGlobalDirectory(VDosnum osnum, char *path)
{
  VDASSERT_FN("VDPaimGetSirGlobalDirectory");

  /* Arg check */
  VDASSERTW(path); *path = 0;
  osnum = getOS(osnum);

  VDPaimGetIGENODDirectory(osnum,path);
  strcat(path,":");
  strcat(path,"SIRGlobal");

wrapup:
  return;
}
/* -----------------------------------------------
 * Get the SIR required data collector
 * Optionally create one if it does not exist
 */
void VDPaimGetDADCollector(VDosnum osnum, int create, TGRid *collID)
{
  VDASSERT_FN("VDPaimGetDADCollector");

  int  retFlag = 0;
  char path[128];

  TGRid dirID;

  /* Arg Check */
  VDASSERTW(collID); collID->objid = NULL_OBJID;
  osnum = getOS(osnum);

  /* Grab the path */
  VDPaimGetSirGlobalDirectory(osnum,path);
  if (*path == 0) goto wrapup;

  /* Translate */
  strcat(path,":");
  strcat(path,"SRReqData");
  VDtranslate(path,collID);
  if (collID->objid != NULL_OBJID) goto wrapup;

  /* Want to create */
  if (create == 0) goto wrapup;

  /* Does the directoy exist */
  VDPaimGetSirGlobalDirectory(osnum,path);
  VDtranslate(path,&dirID);
  if (dirID.objid == NULL_OBJID)
  {
    di$mkdir(dirname = path,
	     p_dirid = &dirID.objid,
	     p_osnum = &dirID.osnum);
  }
  VDtranslate(path,&dirID);
  if (dirID.objid == NULL_OBJID)
  {
    printf("*** Failed to create directory for AIM SIR DAD Collector\n");
    goto wrapup;
  }

  /* Make the collector */  
  strcat(path,":");
  strcat(path,"SRReqData");
  VDcollCreate(osnum,path,collID);

  /* Pull it again just to be safe */
  VDtranslate(path,collID);
  if (collID->objid == NULL_OBJID) goto wrapup;

wrapup:
  return;
}

/* -----------------------------------------------
 * Get the SIR enabled item list object
 * Optionally create one if it does not exist
 */
void VDPaimGetEnabledItemListObject(VDosnum osnum, int create, TGRid *enabledID)
{
  VDASSERT_FN("VDPaimGetEnabledItemListObject");

  int  retFlag = 0;
  char path[128];

  /* Arg Check */
  VDASSERTW(enabledID); enabledID->objid = NULL_OBJID;
  osnum = getOS(osnum);

  /* Grab the path */
  VDPaimGetSirGlobalDirectory(osnum,path);
  if (*path == 0) goto wrapup;

  /* Translate */
  strcat(path,":");
  strcat(path,"SIREnabledList");
  VDtranslate(path,enabledID);
  if (enabledID->objid != NULL_OBJID) goto wrapup;

  /* Want to create */
  if (create == 0) goto wrapup;

  /* Create */

wrapup:
  return;
}
/* -----------------------------------------------
 * Get the SIR transaction list object
 * Optionally create one if it does not exist
 */
void VDPaimGetTransactionListObject(VDosnum osnum, int create, TGRid *transID)
{
  VDASSERT_FN("VDPaimGetTransactionListObject");

  int  retFlag = 0;
  char path[128];

  /* Arg Check */
  VDASSERTW(transID); transID->objid = NULL_OBJID;
  osnum = getOS(osnum);

  /* Grab the path */
  VDPaimGetSirGlobalDirectory(osnum,path);
  if (*path == 0) goto wrapup;

  /* Translate */
  strcat(path,":");
  strcat(path,"SIRTransList");
  VDtranslate(path,transID);
  if (transID->objid != NULL_OBJID) goto wrapup;

  /* Want to create */
  if (create == 0) goto wrapup;

  /* Create */

wrapup:
  return;
}
/* -----------------------------------------------
 * Get the SIR transaction list object
 * Optionally create one if it does not exist
 */
void VDPaimGetSavedTransactionListObject(VDosnum osnum, int create, TGRid *transID)
{
  VDASSERT_FN("VDPaimGetSavedTransactionListObject");

  int  retFlag = 0;
  char path[128];

  /* Arg Check */
  VDASSERTW(transID); transID->objid = NULL_OBJID;
  osnum = getOS(osnum);

  /* Grab the path */
  VDPaimGetSirGlobalDirectory(osnum,path);
  if (*path == 0) goto wrapup;

  /* Translate */
  strcat(path,":");
  strcat(path,"SIRTransListSav");
  VDtranslate(path,transID);
  if (transID->objid != NULL_OBJID) goto wrapup;

  /* Want to create */
  if (create == 0) goto wrapup;

  /* Create */

wrapup:
  return;
}

/* ----------------------------------------------
 * Get the drawing setup parameter collector
 */
void VDPaimGetDrawingCollector(VDosnum osnum, TGRid *collID)
{
  VDASSERT_FN("VDPaimGetDrawingCollector");

  int  retFlag = 0;
  char path[128];

  /* Arg Check */
  VDASSERTW(collID); collID->objid = NULL_OBJID;
  osnum = getOS(osnum);

  /* Grab the path */
  VDPaimGetIGENODDirectory(osnum,path);
  if (*path == 0) goto wrapup;

  /* Translate */
  strcat(path,":");
  strcat(path,"VDDgnSetupInfo");
  VDtranslate(path,collID);

wrapup:
  return;
}
/* ----------------------------------------------
 * Generate a list of aim enabled items
 */
from VDPenabObj import VDPgetPMenabledList;

domNode VDPaimCreateEnabledItemNodeList(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("VDPaimCreateEnabledItemNodeList");

  IGRstat sts,msg;

  domNode enabledNodes = NULL;
  domNode enabledNode;

  TGRid enabledListID;

  TGRobj_env *enabledOEs = NULL;
  TGRobj_env *enabledOE;
  int         enabledOEcnt;
  int         i;

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Grab the list object */
  VDPaimGetEnabledItemListObject(osnum,0,&enabledListID);
  if (enabledListID.objid == NULL_OBJID) goto wrapup;

  /* Make the list */
  enabledNodes = domCreateNode(parentNode,"aim_enabled_items");

  /* Get the objects */
  sts = om$send(msg = message 
    VDPenabObj.VDPgetPMenabledList(&msg,&enabledOEcnt,&enabledOEs),
    senderid = NULL_OBJID,
    targetid = enabledListID.objid,
    targetos = enabledListID.osnum );
  if(!(sts & msg & 1)) goto wrapup;

  for(i = 0; i < enabledOEcnt; i++)
  {
    enabledNode = domCreateNode(enabledNodes,"aim_enabled_item");
    domCreateIntAttrNode(enabledNode,"objid",enabledOEs[i].obj_id.objid);
  }

wrapup:
  if (enabledOEs) free(enabledOEs);
  return enabledNodes;
}

/* ----------------------------------------------
 * Generate a tranaction list
 */
#include "VDPtrTbl.h"

from VDPtrTbl import VDPprintTransTable;

extern struct VDPtrObjList *VDgetTrTable();
extern int                  VDgetTrSize();

domNode VDPaimCreateTransactionNodeList(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("VDPaimCreateTransactionNodeList");

  IGRstat sts,msg;

  domNode transNodes = NULL;
  domNode transNode;

  TGRid transListID;

  int i,cnt;

  struct VDPtrObjList *trans;
  struct VDPtrObjList *tran;

  TGRid   objID;
  IGRchar buf[128];

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Grab the list object */
  VDPaimGetTransactionListObject(osnum,0,&transListID);
  if (transListID.objid == NULL_OBJID) goto wrapup;

  /* Make the list */
  transNodes = domCreateNode(parentNode,"aim_transactions");

  /* Get the objects */
  sts = om$send(msg = message 
    VDPtrTbl.VDPprintTransTable(&msg),
    senderid = NULL_OBJID,
    targetid = transListID.objid,
    targetos = transListID.osnum );
  if(!(sts & msg & 1)) goto wrapup;

  cnt   = VDgetTrSize ();
  trans = VDgetTrTable();

  for(i = 0; i < cnt; i++)
  {
    tran = &trans[i];

    transNode = domCreateNode(transNodes,"aim_transaction");

    domCreateIntAttrNode(transNode,"action_code",tran->ActionCode);
    domCreateIntAttrNode(transNode,"cur_objid",  tran->VDSobjid);
    domCreateIntAttrNode(transNode,"old_objid",  tran->oldVDSobjid);
    domCreateIntAttrNode(transNode,"posted",     tran->posted);

    /* ------------------------------------------
     * It turns out that the sirid is not being stored
     * in the transaction list.  In fact, the id was not being initialized
     * and thus had garbage.
     */
    /* domSetNodeTextProp(transNode,"aim_obid",  trans->PMEobid); */

    /* Go ahead and grab it from the object itself. */
    objID.osnum = osnum;
    objID.objid = tran->VDSobjid;
    VDobjGetTxtAtr(NULL,&objID,  "sirid",buf);
    domCreateTextAttrNode(transNode,"sirid",buf);
  }

wrapup:
  return transNodes;
}

/* ----------------------------------------------
 * Clone of VDfunc.I VDobjInActiveSpace but allows
 * specifying the object space
 *
 * added for the diagram object searching
 */
#include "VDmem.h"

long VDobjInSpace(long   *msg,
                  VDosnum osnum,
		  int    *count, 
		  struct GRid **list, 
		  OMuword class )
{
	OMuword 	objClassid;	/* Class of `curObj'		*/
	struct GRid	curObj;
	int		i,		/* Loop index			*/
			cnt,		/* Count of children		*/
			maxObjs ;	/* Max. of objs in Object Space */
					/* or in given list of parts.	*/
	long		sts = OM_S_SUCCESS ;

	cnt = 0;
	
	maxObjs = OM_GA_OSDs[osnum]->CurSpaceMapSize ;
	curObj.osnum = osnum ;
		
	*list = _MALLOC ( maxObjs, struct GRid );

	for( i = 0 ; i < maxObjs ; i++ ) {

		curObj.objid = i ;

		sts = om$get_classid(	objid		= curObj.objid,
					osnum		= curObj.osnum,
					p_classid	= &objClassid ) ;
		if( !( sts & 1 ) ) {
			/*
			 * Not an object id.
			 */
			continue ;
		}
		sts = om$is_ancestry_valid(
				superclassid	= class,
				subclassid	= objClassid ) ;
		if( sts != OM_S_SUCCESS ) {
			/*
			 * Not a VSfeature. But check if it is a reference file
			 */
			continue ;
		} else {
			(*list)[cnt] = curObj;
			cnt++;
		}
	}

	if( cnt) *count = cnt;
	
	return( sts & *msg & 1 );
}

end implementation Root;
