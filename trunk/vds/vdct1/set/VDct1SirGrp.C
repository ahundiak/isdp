/* $Id: VDct1SirGrp.C,v 1.1.2.3 2003/06/13 23:23:56 ylong Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1SirGrp.C
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1SirGrp.C,v $
 *      Revision 1.1.2.3  2003/06/13 23:23:56  ylong
 *      TR7799
 *
 *      Revision 1.1.2.2  2003/05/30 16:59:16  ylong
 *      refined item names
 *
 *      Revision 1.1.2.1  2003/05/28 21:53:08  ylong
 *      Changed PPL calls
 *
 *      Revision 1.1  2003/05/23 20:15:24  ylong
 *      Created for Placement Group Tree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/19/03  yl      Creation
 ***************************************************************************/
 
#include "VDct1.h"
#include "VDct1Attrs.h"

#include "VDobj.h"
#include "VDdir.h"
#include "VDppl1.h"
#include "VDsa.h"
#include "vdrefmacros.h"
#include "VDmem.h"
#include "VDvla.h"
#include "VDassert.h"
#include "VDct1SirGrp.h"
#include "VDrisc.h"

#define	SirGrpPla	"SirGrpPla"

VDASSERT_FFN("vdct1/set/VDct1SirGrp.C");
static IGRint	traceFlag = 0;

/* ---------------------------------------------------------------------------
 * sort itemInfo: compartment->partType->grpName ?
 */
static int sortInfo( const void *e1, const void *e2 )
{
   int	retFlag = 0;
   TVDSirGrpInfo *info1 = (TVDSirGrpInfo *) e1;
   TVDSirGrpInfo *info2 = (TVDSirGrpInfo *) e2;

   retFlag = strcmp( info1->comptNo, info2->comptNo );
   if( retFlag ) return retFlag;

   retFlag = strcmp( info1->partType, info2->partType );
   if( retFlag ) return retFlag;
	
   retFlag = strcmp( info1->grpName, info2->grpName );
   if( retFlag ) return retFlag;
	
   retFlag = strcmp( info1->itemName, info2->itemName );
   if( retFlag ) return retFlag;
	
   return 0;
}

/* ---------------------------------------------------------------------------
 *  Call PPL
 */
IGRstat VDct1SirGrpGetTxtValFromPPL( TGRobj_env *objOE, IGRchar *funcName, IGRchar *txt )
{
  IGRint        sts = 0;
  TGRid         pplID;
  IGRint        pplRet;
  Tret_struct	rsData;
 
  // say hi
  if(traceFlag) printf(">>> IGRstat VDct1SirGrpGetTxtValFromPPL\n");

  // args check
  if( txt )	txt[0] = '\0';
  else		goto wrapup;

  if( !funcName || funcName[0] == '\0' )  goto wrapup;
  if( !objOE || objOE->obj_id.objid == NULL_OBJID) goto wrapup; 

  // The ppl does the work
  vdppl$Load(name = SirGrpPla, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 
  
  vdppl$SetData(pplID = &pplID,
                name  = "OBJECT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&(objOE->obj_id) );
 
  vdppl$SetData(pplID = &pplID,
                name  = "OBJECT_ENV",
                size  = sizeof(TGRmd_env),
                data  = (IGRchar*)&(objOE->mod_env) );
 
  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = funcName, 
	    ret   = &pplRet);
  
  // get data
  *rsData.var.text_st.text_string = 0;
  vdppl$GetData(pplID = &pplID,
                name  = "OBJECT_RS",
                size  = sizeof(Tret_struct),
                data  = (IGRchar*)&rsData);
 
  // Check
  if (*rsData.var.text_st.text_string == 0) goto wrapup;
  strcpy(txt,rsData.var.text_st.text_string);

  // success status set
  sts = pplRet;
  
wrapup:
  if(traceFlag) printf("<<< IGRstat VDct1SirGrpGetTxtValFromPPL(%d)\n",sts);
  return sts;
}


/* ------------------------------------------------
 * get category info from table by calling ppl
 */
IGRstat VDct1SirGrpGetCatInfo(IGRchar *inputData, IGRchar *funcName, IGRchar *attrVal)
{
  IGRstat       sts = 0;
  Tret_struct	rsData;
  TGRid		pplID;
  IGRint	pplRet;
  
  // say hi
  if(traceFlag) printf(">>> VDct1SirGrpGetFilter\n");

  // Arg check
  if( attrVal )	attrVal[0] = '\0';
  else		goto wrapup;

  if( !funcName || funcName[0] == '\0' )  goto wrapup;

  // Load the ppl
  vdppl$Load(name = "SirGrpPla", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    goto wrapup;
  }

  if( inputData && inputData[0] != '\0' )
  {
     vdppl$SetData(pplID = &pplID,
                   name  = "OBJECT_DATA",
                   size  = 128,
                   data  = (char*)inputData);
  }

  vdppl$Run(pplID = &pplID, name = funcName, ret = &pplRet); 

  vdppl$GetData(pplID = &pplID,
                name  = "OBJECT_RS",
                size  = sizeof(Tret_struct),
                data  = (IGRchar*)&rsData);
 
  // Check
  if (*rsData.var.text_st.text_string == 0) goto wrapup;
  strcpy(attrVal,rsData.var.text_st.text_string);

  sts = pplRet;
  
wrapup:
  if(traceFlag) printf("<<< IGRstat VDct1SirGrpGetCatInfo(%d)\n",sts);
  return sts;
}

/* ------------------------------------------------
 * get calss filter from ppl
 */
IGRstat VDct1SirGrpGetFilter(OM_S_CLASSLIST *classList)
{
  IGRstat       sts = 0;
  TGRid		pplID;
  IGRint	pplRet;
  
  // say hi
  if(traceFlag) printf(">>> VDct1SirGrpGetFilter\n");

  // Load the ppl
  vdppl$Load(name = "SirGrpPla", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    goto wrapup;
  }

  vdppl$SetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof(OM_S_CLASSLIST),
                data  = (char*)classList);

  vdppl$Run(pplID = &pplID, name = "getFilter", ret = &pplRet); 

  vdppl$GetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof(OM_S_CLASSLIST),
                data  = (char*)classList);

  sts = pplRet;
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SirGrpGetFilter(%d)\n",sts);
  return sts;
}

/* ---------------------------------------------------------------------------
 *  Check if objet is placeable
 */
IGRstat VDct1SirGrpIsPlaceable( TGRobj_env *objOE )
{
  IGRint        sts = 0;
  IGRchar	txt[128];
 
  // say hi
  if(traceFlag) printf(">>> IGRstat VDct1SirGrpIsPlaceable\n");

  sts = VDct1SirGrpGetTxtValFromPPL(objOE, "isGroupPlaceable", txt);
  if( !sts ) goto wrapup;

  if( strcmp( txt, "Yes" ) ) goto wrapup;

  sts = 1;
wrapup:
  if(traceFlag) printf("<<< IGRstat VDct1SirGrpIsPlaceable(%d)\n",sts);
  return sts;
}


/* ------------------------------------------------
 * get attribute from ppl
 */
IGRstat VDct1SirGrpGetTxtAttr(TGRobj_env *objOE, IGRchar *attrName, IGRchar *attrVal)
{
  IGRstat	sts = 0;
  IGRstat	traceFlag = 0;
  IGRchar	funcName[40];
  
  // say hi
  if(traceFlag) printf(">>> VDct1SirGrpGetTxtAttr\n");

  // arg check
  if( !attrName || !attrVal ) goto wrapup;
  if( !objOE || objOE->obj_id.objid == NULL_OBJID ) goto wrapup;

  if( !strcmp(attrName,"isGroupPlaceable") )
  {
    strcpy( funcName, "isGroupPlaceable" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if( !strcmp(attrName,"getCategoryId") )
  {
    strcpy( funcName, "getCategoryId" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp( attrName, VDCT1_ATTR_PART_TYPE) || !strcmp( attrName, "getPartType"))
  {
    strcpy( funcName, "getPartType" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ISDP_ATTR_COMPARTMENT) || !strcmp(attrName, "getCompartment") ||
     !strcmp(attrName,VDCT1_ATTR_COMPARTMENT) )
  {
    strcpy( funcName, "getCompartment" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_GROUP_NAME) || !strcmp(attrName, "getGroupName"))
  {
    strcpy( funcName, "getGroupName" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ITEM_NAME) || !strcmp(attrName, "getItemName"))
  {
    strcpy( funcName, "getItemName" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_CAGE) || !strcmp(attrName, "getCage"))
  {
    strcpy( funcName, "getCage" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_MINO) || !strcmp(attrName, "getMino"))
  {
    strcpy( funcName, "getMino" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_MODEL_ID) || !strcmp(attrName, "getModelId"))
  {
    strcpy( funcName, "getModelId" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ISDP_NAME) || !strcmp(attrName, "getIsdpName"))
  {
    strcpy( funcName, "getIsdpName" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ISDP_PATH) || !strcmp(attrName, "getIsdPath"))
  {
    strcpy( funcName, "getIsdpPath" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ITEM_DESC) || !strcmp(attrName, "getDesc"))
  {
    strcpy( funcName, "getDesc" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ITEM_COPICS_DESC) || !strcmp(attrName, "getCopicsDesc"))
  {
    strcpy( funcName, "getCopicsDesc" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_ZONE) || !strcmp(attrName, "getZone") ||
     !strcmp(attrName,VDCT1_ISDP_ATTR_ZONE) )
  {
    strcpy( funcName, "getZone" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  if(!strcmp(attrName,VDCT1_ATTR_UNIT) || !strcmp(attrName, "getUnit") ||
     !strcmp(attrName,VDCT1_ISDP_ATTR_UNIT) )
  {
    strcpy( funcName, "getUnit" );
    sts = VDct1SirGrpGetTxtValFromPPL(objOE, funcName, attrVal);
    goto wrapup;
  }

  // final try
  sts = VDct1SirGrpGetTxtValFromPPL(objOE, attrName, attrVal);

wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SirGrpGetCopicsDesc(%d)\n",sts);
  return sts;
}


/* ------------------------------------------------
 * get all placeable objects
 */
IGRstat VDct1SirGrpGetItemInfo(IGRint *itemCnt, TVDSirGrpInfo **itemInfo)
{
  IGRstat		sts = 0;
  IGRlong		msg;
  OM_S_CLASSLIST	classList;
  GRclassid		classids[20];
  GRspacenum		cur_osnum, osnum, *refOsList = NULL;
  IGRint		i, j;
  IGRint		refOsCnt = 0, objCnt = 0;
  IGRint		max = 0, catCnt = 0, catId = 0;
  TGRmd_env		*refEnvList = NULL, env;
  TGRobj_env		objOE;
  IGRchar		partType[128], compt[128], grpName[128], txt[40], cat[40];
  IGRchar		*p = NULL;

  struct CategoryInfo {
	IGRint	catId;
	IGRint	count;
  } *catInfo;


  // say hi
  if(traceFlag) printf(">>> VDct1SirGrpGetItemInfo\n");

  catInfo = NULL;
  if( !itemCnt && !itemInfo ) goto wrapup;
  if( itemCnt )  *itemCnt  = 0;
  if( itemInfo ) *itemInfo = NULL;

  ex$get_cur_mod (osnum = &cur_osnum) ;

  sts = vd$get_ref_os_list(msg          = &msg,
                           main_os      = &cur_osnum,
                           num_ref_os   = &refOsCnt,
                           ref_os_list  = &refOsList,
			   ref_env_list = &refEnvList);
  if( !(sts&msg&1) || !refOsList ) refOsCnt = 0;
  //printf("refOsCnt = %d\n", refOsCnt);

  objCnt = 0;
  for( i = 0; i <= refOsCnt; i++ )
  {
    if( i == 0 )
    {
      osnum = cur_osnum;
      gr$get_module_env(buffer = &env);
    }
    else
    {
      osnum = refOsList[i-1];
      env   = refEnvList[i-1];
    }

    max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
    objOE.mod_env = env;
    objOE.obj_id.osnum = osnum;
    for( j = 0; j < max; j++ )
    {
       objOE.obj_id.objid = j;
       if( VDct1SirGrpIsPlaceable( &objOE ) ) objCnt++;
    }
  }

  //printf("objCnt = %d\n", objCnt);
  if( itemCnt ) *itemCnt = objCnt;

  if( objCnt > 0 && itemInfo )
  {
    // fill objects and info
    *itemInfo = _MALLOC( objCnt, TVDSirGrpInfo );
    if( !(*itemInfo) ) goto wrapup;

    objCnt = 0;
    for( i = 0; i <= refOsCnt; i++ )
    {
      if( i == 0 )
      {
        osnum = cur_osnum;
        gr$get_module_env(buffer = &env);
      }
      else
      {
        osnum = refOsList[i-1];
        env   = refEnvList[i-1];
      }

      max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
      objOE.mod_env = env;
      objOE.obj_id.osnum = osnum;
      for( j = 0; j < max; j++ )
      {
         objOE.obj_id.objid = j;
         if( VDct1SirGrpIsPlaceable( &objOE ) )
	 {
	   (*itemInfo)[objCnt].objOE = objOE;

           VDct1SirGrpGetTxtAttr(&objOE,
			VDCT1_ATTR_COMPARTMENT, (*itemInfo)[objCnt].comptNo);
           VDct1SirGrpGetTxtAttr(&objOE,
			VDCT1_ATTR_PART_TYPE,   (*itemInfo)[objCnt].partType);
           VDct1SirGrpGetTxtAttr(&objOE,
			VDCT1_ATTR_GROUP_NAME,  (*itemInfo)[objCnt].grpName);
           VDct1SirGrpGetTxtAttr(&objOE,
			VDCT1_ATTR_ITEM_NAME,   (*itemInfo)[objCnt].itemName);
	   objCnt++;
	 }
      }
    }

    // sort item list
    qsort((*itemInfo), objCnt, sizeof(TVDSirGrpInfo), sortInfo);

    // reset item names by category and order, such as Lighting 1-1, Lighting 1-2
    *txt = 0;
    sts = VDct1SirGrpGetCatInfo(NULL, "getCategoryCount", txt);
    if( sts && *txt ) catCnt = atoi(txt);
     
    if( catCnt ) catInfo = _MALLOC( catCnt, struct CategoryInfo );
    if( !catInfo ) goto wrapup;
   
    for( i = 0; i < catCnt; i++ )
    {
      *cat = 0;
      sprintf(txt, "%d", i);
      sts = VDct1SirGrpGetCatInfo(txt, "getNthCategory", cat);
      catInfo[i].catId = atoi(cat);
      catInfo[i].count = 0;
    }
     
    for( i = 0; i < objCnt; i++ )
    {
      *cat = 0;
      sts = VDct1SirGrpGetTxtAttr(&(*itemInfo)[i].objOE, "getCategoryId", cat);
      if( !sts ) continue;
      catId = atoi(cat);
   
      for( j = 0; j < catCnt; j++ )
      {
        if( catId == catInfo[j].catId )
        {
           catInfo[j].count++;
   	   sprintf(txt, " %d-%d",catId, catInfo[j].count);
   	   strcat((*itemInfo)[i].itemName, txt);
	   break;
        }
      }
    }
  }
  
  sts = 1;
wrapup:
  _FREE(refOsList);
  _FREE(refEnvList);
  _FREE(catInfo);
  // say bye
  if(traceFlag) printf("<<< VDct1SirGrpGetItemInfo(%d)\n",sts);
  return sts;
}
