/* $Id: VDpdmCache.c,v 1.5 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm/VDpdmCache.C
 *
 * Description: File Key functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmCache.c,v $
 *      Revision 1.5  2002/05/10 19:33:50  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/12/06 21:39:18  jdsauby
 *      JTSMP TR 5863
 *
 *      Revision 1.3  2001/11/16 15:22:00  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/11/09 21:51:29  jdsauby
 *      Made it backward compatible w/sp13, as well as forward compat w/sp14 -jds
 *
 *      Revision 1.1  2001/11/08 20:11:08  jdsauby
 *      JTS MP TR 5764, added caching of DB queries into DOM tree - jds
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/07/01  js      Creation
 * 11/16/01  ah      Don't free pointer from VDctxGetTxtAtrPtr any more
 * 05/10/02  ah      Moved static data into global
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDnfmc.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDDbDef.h"
#include "VDxdom.h"
#include "VDctx.h"

VDASSERT_FFN("vdpdm/func/VDpdmCache.c");

/* -----------------------------------------
 * The Dom Tree
 * **/
static TGRid *getTree()
{
    TGRid *treeID = vdGblStaticData11;
    
    if (!treeID) {
	 treeID = (TGRid*) malloc(1*sizeof(TGRid));
	 treeID->objid = NULL_OBJID;
         vdGblStaticData11 = treeID;
    }
    if (treeID->objid != NULL_OBJID) return treeID;
    
    // create it
    VDctxCreateXdomTree("File_Keys",NULL,treeID);

    return treeID;
}

static void deleteTree()
{
    TGRid *treeID = vdGblStaticData11;
    
    if (treeID) {
	if  (treeID->objid != NULL_OBJID) VDctxDeleteNode(treeID);
	free(treeID);
        vdGblStaticData11 = NULL;
    }

    return;
}
    

/* ---------------------------------------------
 * Get the Filekey node
 * **/
IGRstat VDpdmCgetFilekeyNodeID(IGRint *file_key,
	                       TGRid  *nodeID)
{
    VDASSERT_FN("VDpdmCgetFilekeyNodeID");
    IGRstat retFlag = 0;
    TGRid  *treeID = getTree();
    TGRid   workID;
    IGRchar fkeyAttr[72];
    IGRchar fkeyIn[72];
    IGRint  i;

    // arg check
    VDASSERTW(file_key && *file_key > 0);
    VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;

    sprintf(fkeyIn,"%d",*file_key);
    
    // see if this node already exists
    // get the node with the nodename = file_key
    for (i = 0; VDctxGetNthTreeChild(treeID,i,&workID); i++)
    {
	VDctxGetTxtAtr(&workID,VDPDM_CACHE_ATTR_FILEKEY,fkeyAttr);
	if (!strcmp(fkeyIn,fkeyAttr))
	{
	    *nodeID = workID;
	    retFlag = 1;
	    goto wrapup;
	}
    }

    // create the node with the nodename = file_key
    VDctxCreateNode(treeID,"filekey",NULL,&workID);
    if (workID.objid == NULL_OBJID) goto wrapup;

    // set the file_key attribute, just use text
    VDctxAppTxtAtr(&workID,VDPDM_CACHE_ATTR_FILEKEY,fkeyIn);

    // done
    *nodeID = workID;
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Delete the filekey cache ID, actually, it deletes the entire tree
 * */
IGRstat VDpdmCdeleteFilekeyCache(IGRint *fileKey)
{
    VDASSERT_FN("VDpdmCdelFilekeyCache");
    IGRstat retFlag = 0;
    TGRid   nodeID;

    // init
    nodeID.objid = NULL_OBJID;

    // arg check
    VDASSERTW(fileKey && *fileKey > 0);

    // get the node for file_key
    VDpdmCgetFilekeyNodeID(fileKey,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;

    // delete it
    deleteTree();

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
    
/* ----------------------------------------------
 * Cache function for VDpdmGetCPRForFilekey
 * **/
IGRstat VDpdmCgetCPRForFilekey(IGRint  *file_key,
	                       IGRchar *a_catalog,
			       IGRchar *a_part,
			       IGRchar *a_rev)
{
    VDASSERT_FN("VDpdmCgetCPRForFilekey");
    IGRstat retFlag = 0;
    TGRid   nodeID;

    IGRchar catalog[72];
    IGRchar part[72];
    IGRchar rev[72];

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);
    VDASSERTW(a_catalog); *a_catalog = 0;
    VDASSERTW(a_part);    *a_part = 0;
    VDASSERTW(a_rev);     *a_rev = 0;

    nodeID.objid = NULL_OBJID;
    *catalog = 0;
    *part    = 0;
    *rev     = 0;

    // get the node for file_key
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
    
    // catalog
    VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_CATALOG,catalog);
    if (*catalog == 0) goto wrapup;
    strcpy(a_catalog,catalog);
    
    // part
    VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_PART,part);
    if (*part == 0) goto wrapup;
    strcpy(a_part,part);
    
    // revision
    VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_REVISION,rev);
    if (*rev == 0) goto wrapup;
    strcpy(a_rev,rev);

    // done
    retFlag = 1;
    
wrapup:
    return retFlag;
}

IGRstat VDpdmCsetCPRForFilekey(IGRint  *file_key,
	                       IGRchar *catalog,
			       IGRchar *part,
			       IGRchar *rev)
{
    VDASSERT_FN("VDpdmCsetCPRForFilekey");
    IGRstat retFlag = 0;
    TGRid   nodeID;

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);
    VDASSERTW(catalog && *catalog);
    VDASSERTW(part && *part);
    VDASSERTW(rev && *rev);

    nodeID.objid = NULL_OBJID;

    // get the node with the nodename = file_key
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;

    // set the CPR attributes
    VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_CATALOG,catalog);
    VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_PART,part);
    VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_REVISION,rev);

    // done
    retFlag = 1;
    
wrapup:
    return retFlag;
}

/* ----------------------------------------------
 * Cache function for VDpdmGetCPRForFilekey
 * **/
IGRstat VDpdmCgetFilekeyForCPR(IGRchar *a_cat,
	                       IGRchar *a_part,
			       IGRchar *a_rev,
			       IGRint  *file_key)
{
    VDASSERT_FN("VDpdmCgetFilekeyForCPR");
    IGRstat retFlag = 0;
    TGRid  *treeID = getTree();
    TGRid   nodeID;
    IGRint  i;
    IGRchar cat[72];
    IGRchar part[72];
    IGRchar rev[72];
    IGRchar fkey[72];

    // arg check / init
    *cat  = 0;
    *part = 0;
    *rev  = 0;
    *fkey = 0;

    VDASSERTW(a_cat  && *a_cat);
    VDASSERTW(a_part && *a_part);
    VDASSERTW(a_rev  && *a_rev);
    VDASSERTW(file_key);

    // get the node with the matching CPR attributes
    for (i = 0; VDctxGetNthTreeChild(treeID,i,&nodeID); i++)
    {
	// get the attributes
	VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_CATALOG,cat);
	VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_PART,part);
	VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_REVISION,rev);
	if ( (!strcmp(a_cat ,cat))  &&
	     (!strcmp(a_part,part)) &&
	     (!strcmp(a_rev ,rev))  )
	{
	    VDctxGetTxtAtr(&nodeID,VDPDM_CACHE_ATTR_FILEKEY,fkey);
	    if (*fkey == 0) goto wrapup;
	    
	    *file_key = atoi(fkey);
	    retFlag = 1;
	    goto wrapup;
	}
    }

    // done, none found

wrapup:
    return retFlag;
}

/* ----------------------------------------------
 * Cache function for VDpdmGetHullAppforFilekey
 * **/
IGRstat VDpdmCgetHullAppforFilekey(IGRint       *file_key,
	                           VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmCgetHullAppforFilekey");
    IGRstat retFlag = 0;
    IGRstat sts;
    TGRid   nodeID;
    IGRchar *p;
    IGRchar *appString = NULL;
    IGRchar buf[1024];

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);
    VDASSERTW(ships);

    memset(ships,0,sizeof(VDpdmHullApp));
    nodeID.objid = NULL_OBJID;
    
    // get the nodeID
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
    
    // get the appString
    sts = VDctxGetTxtAtrPtr(&nodeID,VDPDM_CACHE_ATTR_APPL_TO,&appString);
    if (!(sts & 1)) goto wrapup;
    strcpy(buf,appString);

    if (!strcmp(buf,"NA"))
    {
	ships->file_key = *file_key;
	ships->cnt      = 1;
	strcpy(ships->hulls[0],buf);
	retFlag = 1;
	goto wrapup;
    }

    // fill up the VDpdmHullApp structure from the appString attribute
    ships->file_key = *file_key;
    ships->cnt      = 0;
    while (p = strchr(buf,'|'))
    {
	*p = 0;
	strcpy(ships->hulls[ships->cnt],buf);
	ships->cnt++;
	strcpy(buf,p+1);
    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

IGRstat VDpdmCsetHullAppforFilekey(IGRint       *file_key,
	                           VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmCsetHullAppforFilekey");
    IGRstat retFlag = 0;
    TGRid   nodeID;
    IGRchar appString[1024];
    IGRchar buf[81];
    IGRint  i;

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);

    *buf = 0;
    *appString = 0;
    nodeID.objid = NULL_OBJID;

    // set the attribute on the node
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
    
    if (!ships) {
	VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_APPL_TO,"NA");
	goto wrapup;
    }

    // set the appString
    for (i = 0; i < ships->cnt; i++)
    {
	strcpy(buf,ships->hulls[i]);
	strcat(buf,"|");
	strcat(appString,buf);
    }
    VDASSERTW(*appString);

    
    VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_APPL_TO,appString);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ----------------------------------------------
 * Cache function for VDpdmGetApprCfgForFilekey
 * **/
IGRstat VDpdmCgetApprCfgforFilekey(IGRint       *file_key,
	                           VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmCgetApprCfgforFilekey");
    IGRstat retFlag = 0;
    IGRstat sts;
    
    TGRid   nodeID;
    IGRchar *p;
    IGRchar *appString = NULL;
    IGRchar buf[1024];

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);
    VDASSERTW(ships);

    memset(ships,0,sizeof(VDpdmHullApp));
    nodeID.objid = NULL_OBJID;
    
    // get the nodeID
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
    
    // get the appString
    sts = VDctxGetTxtAtrPtr(&nodeID,VDPDM_CACHE_ATTR_APPR_FOR,&appString);
    if (!(sts & 1)) goto wrapup;

    strcpy(buf,appString);

    if (!strcmp(buf,"NA"))
    {
	ships->file_key = *file_key;
	ships->cnt      = 1;
	strcpy(ships->hulls[0],buf);
	retFlag = 1;
	goto wrapup;
    }

    // fill up the VDpdmHullApp structure from the appString attribute
    ships->file_key = *file_key;
    ships->cnt      = 0;
    while (p = strchr(buf,'|'))
    {
	*p = 0;
	strcpy(ships->hulls[ships->cnt],buf);
	ships->cnt++;
	strcpy(buf,p+1);
    }
    VDASSERTW(ships->cnt > 0);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

IGRstat VDpdmCsetApprCfgforFilekey(IGRint       *file_key,
	                           VDpdmHullApp *ships)
{
    VDASSERT_FN("VDpdmCsetApprCfgforFilekey");
    IGRstat retFlag = 0;
    TGRid   nodeID;
    IGRchar appString[1024];
    IGRchar buf[81];
    IGRint  i;

    // init / Arg check
    VDASSERTW(file_key && *file_key > 0);

    *buf = 0;
    *appString = 0;
    nodeID.objid = NULL_OBJID;
    
    // set the attribute on the node
    VDpdmCgetFilekeyNodeID(file_key,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
 
    if (!ships) {
	VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_APPR_FOR,"NA");
	goto wrapup;
    }

    // set the appString
    for (i = 0; i < ships->cnt; i++)
    {
	strcpy(buf,ships->hulls[i]);
	strcat(buf,"|");
	strcat(appString,buf);
    }
    VDASSERTW(*appString);

    // done
    VDctxAppTxtAtr(&nodeID,VDPDM_CACHE_ATTR_APPR_FOR,appString);
    retFlag = 1;

wrapup:
    return retFlag;
}


/* ----------------------------------------------
 * Cache function for VDpdmUpdatePurposeInfoDB
 * **/

