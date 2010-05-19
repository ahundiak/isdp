/* $Id: VDtvwSearch.I,v 1.8 2001/09/20 18:56:54 paul_noel Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/cmd/VDtvwSearch.I
 *
 * Description: Fetching and manipulating the data on the form
 *              Utilities for this purpose
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/29/01  pn      Creation
 ***************************************************************************/

// Generic node operations routines

class implementation VDct1Base;
/*
#define vdsDEBUG 
#define vdserrDEBUG
*/

#include "vdtvw.h"
#include "vdtr_macros.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDfrm.h"
#include <sys/stat.h>
#include "ci.h"
#include <dirent.h>
#include "VDppl1.h"
#include "VDchn.h"
#include "VDfile.h"
#include "vdtvwtools.h"


IGRint VDtvwDoesNodeHaveThisAttribute(TGRid   *nodeID,
				      IGRchar *attrName,
				      IGRchar *attrValue,
				      IGRchar *blnTxt);


VDASSERT_FFN("vds/vdtvw/VDtvwSearch.I");

/********************************************
 *
 * Get Range Nodes List from the form
 * *NOTICE* involves memory allocation *NOTICE*
 *
 ********************************************/
IGRint VDtvwGetRangeNodesList(Form    form,
			      IGRint  gadget,
			      TGRid  *fromID,
			      TGRid  *toID, 
			      TGRid **rangeList,
			      IGRint *rangeListCnt)
{
  VDASSERT_FN("VDtvwGetRangeNodesList");
  IGRint retFlag = 0;
  IGRint fromRow,toRow,tmpRow,rows,rangeCnt,i,selFlag,pos,row;
  TGRid  nodeID;
  IGRchar attr[128],exp[128];
  IGRchar data[128];
  IGRchar node[128];
  
   
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  if(*rangeListCnt > 0) _FREE( *rangeList );
   *rangeListCnt = 0;
  /* checks */
  VDASSERTW(form);

  /* inits */
  fromRow = toRow = tmpRow = rows = rangeCnt = i = 0;
  selFlag = row = pos = 0;
  *rangeList == NULL;

  /* make sure we have data to work with */
  if(fromID->objid == NULL_OBJID) goto wrapup;
  if(toID->objid == NULL_OBJID) goto wrapup;

  /* get the count of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) goto wrapup;

  /*find the rows for the ID's */
  VDtvwFormFindNode(form,gadget,*fromID,&fromRow);
  VDtvwFormFindNode(form,gadget,*toID,&toRow);

  /* put the rows in order */
  if(fromRow > toRow) {
    tmpRow = toRow;
    toRow = fromRow;
    fromRow = tmpRow;
  }
  /* set the count of rows to search */
  rangeCnt = (toRow - fromRow) + 1;

  /* fetch the count of nodes in the range */
  rows = 0;
  for(row = fromRow;row <= toRow;row++) {
      /* get the nodes data */
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&nodeID,&selFlag,&pos);
    if(nodeID.objid != NULL_OBJID) {
      rows++;
    }
  }

   if(traceFlag) printf("The number of rows scanned was [%d] found [%d]\n",rangeCnt,rows);
  
  if(rows < 1) goto wrapup;
  
  /* allocate the memory */
  if( !( *rangeList = _MALLOC( ((rows) +1), TGRid )))
  {
    printf("Memory Allocation failed for [rangeList]\n");
    goto wrapup;
  }
  /* fetch the data this time for the */
  i = 0;
  for(row = fromRow;row <= toRow;row++) {
  /*  get the nodes data */
  VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&nodeID,&selFlag,&pos);
  if(nodeID.objid != NULL_OBJID) {
    /* add the data into the list */
    (*rangeList)[i] = nodeID;
    i++;
    }
  }
  *rangeListCnt = i;
  retFlag = 1;
wrapup:
  /* say bye */
  if(traceFlag) {
    printf("count of nodes in range is [%d]\n",*rangeListCnt);
    if(*rangeListCnt > 0) {
    }
    for(i = 0;i < *rangeListCnt;i++) {
      printf("node #%d [%d][%d]\n",i,(*rangeList)[i].osnum,(*rangeList)[i].objid);
    }
  }
  

  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * filter to see if a node Has attribute
 * attribute by name and by value 
 *
 ********************************************/
IGRint VDtvwDoesNodeHaveThisAttribute(TGRid   *nodeID,
				      IGRchar *attrName,
				      IGRchar *attrValue,
				      IGRchar *blnTxt)
{
  VDASSERT_FN("VDtvwDoesNodeHaveThisAttribute");
  IGRint retFlag = 0;
  TVDfld  flds[VDFLD_MAX_CNT];
  IGRint  i,fldsCnt = 0;
  IGRchar *p,data[128],nameStr[128],valueStr[128],typeStr[128],*q;
  IGRint  attrValueSts = 0,valueStrSts = 0,equal = 0;
  IGRdouble difference,control,attribute;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* inits */

  /* args check */
  VDASSERTW(nodeID);
  if(!strcmp(attrName,"")) goto wrapup;
  if(!strcmp(blnTxt,"")) goto wrapup;
 
  if(strcmp(attrName," ")) {
    VD_stripStringEnd(testStr = attrName);
    VD_stripString(attrName);
  }
  if(strcmp(attrValue," ")) {
    VD_stripStringEnd(testStr = attrValue);
    VD_stripString(attrValue);
  }
  

  /* get the fields */
  VDctxGetFldAtrsID(NULL,nodeID,&fldsCnt,flds);

  /* set it up */
  strcpy(data,"");
  p = data;

  /* find the field by name */
  for(i = 0;i < fldsCnt;i++) {
    /* get the field description */
    VDfldGetFldDesc(&flds[i],p);
    /* clip this data */
    vdtr$GetDelimitedStr(impStr = data,
			 outStr = nameStr,
			 delChr = ' ',
			 posStr = 2); 
    if(!strcmp(attrName,nameStr)) break;
  }

  /* reject any invalid attributes */
  if(strcmp(attrName,nameStr)) {
    if(traceFlag) printf("nodeID[%d][%d] has no [%s] attribute\n",
			 nodeID->osnum,nodeID->objid,attrName);
    retFlag = 0;
    goto wrapup;
  }
  

  if(traceFlag) printf("\nnameStr [%s] attrName[%s]\n",nameStr,attrName);
  nameStr[0] = '\0';

  /* clip the data */  
  /*
  vdtr$GetDelimitedStr(impStr = data,
		       outStr = valueStr,
		       delChr = ' ',
		       posStr = 4); 
  */

  p = data;
  p = strrchr(data,'=');
  if(p == NULL) goto wrapup;
  p += 2;
  strcpy(valueStr,p);

  vdtr$GetDelimitedStr(impStr = data,
		       outStr = typeStr,
		       delChr = ' ',
		       posStr = 1);  
  if((strcmp(valueStr," ")) || (strcmp(valueStr,"  "))) {
    VD_stripStringEnd(testStr = valueStr);
  }
  
  if(traceFlag) printf("attrValue[%s] valueStr[%s] typeStr[%s]\n",attrValue,valueStr,typeStr);
  if(traceFlag) printf("blnTxt [%s]\n",blnTxt);
  q = strchr(attrValue,'*');
  /*if there are no wildcards */
  if(q == NULL) {
    if(traceFlag) printf("no Wildcards found \n");
    /* do string evaluations */
    if(!strcmp(typeStr,"TXT")) {
      if(traceFlag) printf("the type is [TXT]\n");
      equal = strcmp(valueStr,attrValue);
      /* double check the strings for any numbers */
      attrValueSts = VDtvwIsStrNumber(attrValue);
      valueStrSts  = VDtvwIsStrNumber(valueStr);
      if((!(attrValueSts == 0)) && (!(valueStrSts == 0))) {
	/* use the type of double  */
	attribute = atof(valueStr);
	control = atof(attrValue);
	difference = attribute - control;
	/* set up equal */
	if(difference < 0) equal = -1;
	if(difference > 0) equal = 1;  
      }
      
      if(traceFlag) printf("attrValueSts [%d] valueStrSts [%d]\n",attrValueSts,valueStrSts);
      
      if(traceFlag) printf("equal [%d]\n",equal);
      /* apply the logic */
      if(equal == 0) {
	if(!strcmp(blnTxt,"=")) retFlag = 1;
	if(!strcmp(blnTxt,">=")) retFlag = 1;
	if(!strcmp(blnTxt,"<=")) retFlag = 1;
	if(traceFlag) printf("The result was EQUAL(%d)\n",retFlag);
	goto wrapup;
      } else if(equal < 0) {
	if(!strcmp(blnTxt,"<")) retFlag = 1;
	if(!strcmp(blnTxt,"!=")) retFlag = 1;
	if(!strcmp(blnTxt,"<=")) retFlag = 1;
	if(traceFlag) printf("The result was Less than 0(%d)\n",retFlag);
	goto wrapup;
      } else if(equal > 0) {
	if(!strcmp(blnTxt,">")) retFlag = 1;
	if(!strcmp(blnTxt,"!=")) retFlag = 1;
	if(!strcmp(blnTxt,">=")) retFlag = 1;
	if(traceFlag) printf("The result was greater than 0(%d)\n",retFlag);
	goto wrapup;
      }
    } else if(!strcmp(typeStr,"DBL")) {
      difference = 0;
      attribute = atof(valueStr);
      control = atof(attrValue);
      difference = attribute - control;
      if(traceFlag) printf("difference[%f]\n",difference);
      if(difference == 0.0) {
	/* situation is equal */
	if(!strcmp(blnTxt,"=")) retFlag = 1;
	if(!strcmp(blnTxt,">=")) retFlag = 1;
	if(!strcmp(blnTxt,"<=")) retFlag = 1;
	if(traceFlag) printf("The dif was EQUAL(%d)\n",retFlag);
	goto wrapup;
      } else if (difference < 0) {
	if(!strcmp(blnTxt,"<")) retFlag = 1;
	if(!strcmp(blnTxt,"!=")) retFlag = 1;
	if(!strcmp(blnTxt,"<=")) retFlag = 1;
	if(traceFlag) printf("The dif was Less than 0(%d)\n",retFlag);
	goto wrapup;
      } else if (difference > 0) {
	if(!strcmp(blnTxt,">")) retFlag = 1;
	if(!strcmp(blnTxt,"!=")) retFlag = 1;
	if(!strcmp(blnTxt,">=")) retFlag = 1;
	if(traceFlag) printf("The dif was greater than 0(%d)\n",retFlag);
	goto wrapup;
      }
    } 
  } else {
    /* there are wildcards */
    if(traceFlag) printf("wildCards were found \n");

    /* special case of any string checked against '*' */
    if(!strcmp(attrValue,"*")) {
      retFlag = 1;
      goto wrapup;
    }
      
    
    if(VDtvwIsWildCardMatchItem(attrValue,valueStr)) {
      if(traceFlag) printf("wildcard check of [%s][%s] was[%d]\n",attrValue,valueStr,1);
      if(!strcmp(blnTxt,"=")) retFlag = 1;
    } else {
      if(traceFlag) printf("wildcard check of [%s][%s] was[%d]\n",attrValue,valueStr,0);
      if(!strcmp(blnTxt,"!=")) retFlag = 1;
    }
    
  }
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}




#if 0
/********************************************
 *
 *
 *
 ********************************************/
IGRint VDtvw(TGRid *nodeID)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
   traceFlag = 1;
  
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

#endif

end implementation VDct1Base;



