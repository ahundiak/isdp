/* $Id: VDdrw_PlITls.I,v 1.4 2001/10/02 16:09:57 paul_noel Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func/VDdrw_PlITblTls.I
 *
 * Description:
 *	Functions used by the "Create Table by Import" command.
 *		
 *
 * Dependencies:
 *
 * History:
 *	08/23/01	pnoel		Created for CR5006
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;
#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"

#include "igewindef.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "vdtblmacros.h"
#include "VDfrm.h"
#include "VDatmacros.h"
#include "vdtr_macros.h"
/* ---- SPEEDUP -------------------------------------------------------- */

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDct1Attrs.h"
#include "VDobj.h"
#include "vdtvwtools.h"
#include "VDtblXml.h"
#include "VDxdom.h"
/************************************************
 *
 * Determine if the file name has ".xml" at the
 * end or any version of that 
 *
 ***********************************************/
IGRint  VDdrw_IsFileExtXML(IGRchar *fileName)
{
  IGRint    retFlag = 0;
  IGRchar   buf[1023],*p,ext[1023];
  IGRint    strLength = 0,i = 0;
  
  if(!fileName) goto wrapup;
  strcpy(buf,fileName);
  strLength = strlen(buf);
  p = buf;
  for(i = 0;i < strLength;i++) {
    if(*p == '.') {
      strcpy(ext,p);
      VDstrupr(ext);
      if(!strcmp(ext,".XML")) {
	retFlag = 1;
	break;
      }
    }
    p++;
  }
  
 wrapup:
  return retFlag;
}


/***********************************************
 *
 * Check to see if a file is XML 
 * protected from getting non .xml extensions
 *
 ***********************************************/
IGRint VDdrw_CheckIfXML(IGRchar *fileName)
{
  IGRint    retFlag      = 0;
  IGRint    sts          = 0;
  IGRint    i            = 0;
  IGRint    fileLinesCnt = 0;
  IGRchar **fileLines;
  IGRchar  *p,*q,*r;
  IGRchar   buffer[8192];
  IGRchar   testStr1[128];
  IGRchar   testStr2[128];
  
  if(!fileName) goto wrapup;
  /* check the file extension */
  retFlag = VDdrw_IsFileExtXML(fileName);
  if(retFlag == 0) goto wrapup;
  /* reset the retFlag = 0 */
  retFlag = 0;
  //printf("fileName at VDdrw_CheckIfXML is [%s]\n",fileName);
  
  /* open the file and read the lines */
   sts = vdio$ReadAnyFile(fileName  = fileName,
			  partPath  = "",
			  fileLines = &fileLines,
			  lineCnt   = &fileLinesCnt); 

   /* no lines no business */
   if(fileLinesCnt < 1) goto wrapup;
   
   /* loop through and check for the xml file type stuff */
   r = fileLines[0];
   if(!(*r == '<')) goto wrapup;
   strcpy(testStr1,"<?xml");
   strcpy(testStr2,"version=");
   VDstrupr(testStr1);
   VDstrupr(testStr2);
   for(i = 0;i < fileLinesCnt;i++) {
     strcpy(buffer,fileLines[i]);
     VDstrupr(buffer);
     p = strstr(buffer,testStr1);
     q = strstr(buffer,testStr2);
     if((p != NULL) && (q != NULL)) {
       retFlag = 1;
       goto wrapup;
     }
   }
  
 wrapup:

  if(fileLinesCnt > 0) _LOOPFREE( fileLines,fileLinesCnt );
  return retFlag;
}


/***********************************************
 *
 * Check to see if a file is XML 
 * protected from getting non .xml extensions
 * get the style sheet data 
 * for posting to the form
 *
 ***********************************************/
IGRint VDdrw_GetStyleSheetNameFromXML(IGRchar *fileName,IGRchar *f_href,IGRchar *f_type)
{
  IGRint    retFlag      = 0;
  IGRint    sts          = 0;
  IGRint    i            = 0;
  IGRint    fileLinesCnt = 0;
  IGRchar **fileLines;
  IGRchar  *p,*q,*r;
  IGRchar   buffer[8192];
  IGRchar   testStr1[128];
  IGRchar   testStr2[128];
  
  if(!fileName) goto wrapup;

  /* make some inits */
  f_href[0] = '\0';
  f_type[0] = '\0';

  /* open the file and read the lines */
   sts = vdio$ReadAnyFile(fileName  = fileName,
			  partPath  = "",
			  fileLines = &fileLines,
			  lineCnt   = &fileLinesCnt); 

   /* no lines no business */
   if(fileLinesCnt < 1) goto wrapup;
   /* <?xml-stylesheet type="text/xsl" href="test1.xsl"?> */
   /* loop through and check for the xml file type stuff */
   r = fileLines[0];
   if(!(*r == '<')) goto wrapup;
   strcpy(testStr1,"<?xml");
   strcpy(testStr2,"styleSheet");
   for(i = 0;i < fileLinesCnt;i++) {
     strcpy(buffer,fileLines[i]);
     p = strstr(buffer,testStr1);
     q = strstr(buffer,testStr2);
     /* we found it now check for the type and the href */
     if((p != NULL) && (q != NULL)) {
       strcpy(buffer,q);
       strcpy(testStr1,"type");
       strcpy(testStr2,"href");
       p = strstr(buffer,testStr1);
       q = strstr(buffer,testStr2);
       /* we have a type */
       if(p != NULL) {
	 vdtr$GetDelimitedStr(impStr = p,
			      outStr = f_type,
			      delChr = '"',
			      posStr = 2);
       }
       /* we have a filename */
       if(q != NULL) {
	 vdtr$GetDelimitedStr(impStr = q,
			      outStr = f_href,
			      delChr = '"',
			      posStr = 2);
       }
       break;
     }
   }
   /* double check to make sure the file has a stylesheet */
   p = strstr(f_href,"xsl");
   if(p == NULL) {
     goto wrapup;
   }
   q = strstr(f_href,"xsl");
   if(q == NULL) {
     goto wrapup;
   }
   retFlag = 1;
   
  
 wrapup:

  if(fileLinesCnt > 0) _LOOPFREE( fileLines,fileLinesCnt );
  return retFlag;
}





/**************************************************
 *
 * Compose a string from a set of strings
 * that is <strData><SeperatorString><strData> etc
 *
 * sepStrBuf is declared so big as to prevent any 
 * accidents and get rid of memory allocation stuff
 *
 **************************************************/
IGRstat VDdrwMakeSepDataString(IGRchar   *sepString,
			       IGRchar   *separator,
			       IGRchar  **strsIn,
			       IGRint     strsInCnt)
{
  IGRint retFlag = 0;
  IGRint i;
  IGRchar buf[128];
  IGRchar sepStrBuf[8192];
  IGRchar strBuf[1028];
  
  // say hi
  __DBGpr_com(">>> VDdrwMakeSepDataString");
  
  /* args check */
  if(!sepString) goto wrapup;
  if(!separator) goto wrapup;
  if(!strsIn) goto wrapup;
  if(strsInCnt < 1) goto wrapup;
  
  /* initialize the data string */
  sepString[0] = '\0';
  sepStrBuf[0] = '\0';
  for(i = 0;i < strsInCnt;i++) {
    strcpy(strBuf,strsIn[i]);
    if(i < (strsInCnt -1)) strcat(strBuf,separator);
    strcat(sepStrBuf,strBuf);
  }
  /* copy it to the sepSting */
  strcpy(sepString,sepStrBuf);
  retFlag = 1;

 wrapup:
  // say bye
  sprintf(buf,"<<< VDdrwMakeSepDataString(%d)",retFlag);
  __DBGpr_com(buf);
  return retFlag;
}


/**************************************************
 *
 * Decompose a string to a set of strings
 * that is <strData><SeperatorString><strData> etc
 *
 * sepStrBuf is declared so big as to prevent any 
 * accidents and get rid of memory allocation stuff
 *
 **************************************************/
IGRstat VDdrwUnMakeSepDataString(IGRchar   *sepString,
				 IGRchar   *separator,
				 IGRchar ***strsOut,
				 IGRint    *strsOutCnt)
{
  IGRint  retFlag      = 0;
  IGRint  i            = 0;
  IGRint  sepLen       = 0;
  IGRint  bufLen       = 0;
  IGRint  newLen       = 0;
  IGRchar sepStrBuf[8192];
  IGRchar newStrBuf[8192];
  IGRchar *p,*q,*r;
  IGRchar buf[1024];

  // say hi
  __DBGpr_com(">>> VDdrwUnMakeSepDataString");
  /* args check */
  if(!sepString) goto wrapup;
  if(!separator) goto wrapup;
  if(!strsOut) goto wrapup;
  /* initialize the data string */
   sepStrBuf[0] = '\0';

  /* clean up any memory allocation troubles */
  if(*strsOutCnt > 0) _LOOPFREE( *strsOut,*strsOutCnt );
  *strsOutCnt = 0;

  /* copy the string over to work */
  strcpy(sepStrBuf,sepString);

  /* start looping through and getting the seperator strings */
  sepLen = strlen(separator);
  bufLen = strlen(sepStrBuf);

   /* special case of no separator length */
  if(sepLen < 1) {
    vdtvw$AddStrList(item    = sepStrBuf,
		     List    = strsOut,
		     ListCnt = strsOutCnt);
    retFlag = 1;
    goto wrapup;
  }

  /* this case copy newStrBuf */
  strcpy(newStrBuf,sepStrBuf);
  
  while(bufLen > 0) {
    p = newStrBuf;
    q = strstr(newStrBuf,separator);
    /* no separator found so the remainder goes to the list */
    if(q == NULL)  {
      vdtvw$AddStrList(item    = newStrBuf,
		       List    = strsOut,
		       ListCnt = strsOutCnt);
      retFlag = 1;
      goto wrapup;
    }
    if(p == q) {
      /* add a blank to the list if this has no data */
      vdtvw$AddStrList(item    = " ",
		       List    = strsOut,
		       ListCnt = strsOutCnt);
      /* if this is the last sep item add a blank and go home */
      if(bufLen == sepLen) {
	vdtvw$AddStrList(item    = " ",
			 List    = strsOut,
			 ListCnt = strsOutCnt);
	retFlag = 1;
	goto wrapup;
      }
      q += sepLen;
      strcpy(newStrBuf,q);
    } else {
      buf[0] = '\0';
      /* clip the string */
      newLen = strlen(p) - strlen(q);
      if(newLen < 0) newLen = 0;
	
       strncat(buf,p,newLen);

      /* add it to the list */
      vdtvw$AddStrList(item    = buf,
		       List    = strsOut,
		       ListCnt = strsOutCnt);
      bufLen = strlen(q);
      if(bufLen == sepLen) {
	vdtvw$AddStrList(item    = " ",
			 List    = strsOut,
			 ListCnt = strsOutCnt);
	retFlag = 1;
	goto wrapup;
      } else {
	q += sepLen;
	strcpy(newStrBuf,q);
	bufLen = strlen(newStrBuf);
      }
    }
  }
  
  

 wrapup:
 __DBGpr_com("\n\tPrinting out the strsOut list");
  for(i = 0;i < *strsOutCnt;i++) {
    sprintf(buf,"\t%s",(*strsOut)[i]);
    __DBGpr_com(buf);
  }
  __DBGpr_com("\tDone printing out the strsOut list");
  retFlag = 1;
  // say bye
  sprintf(buf,"<<< VDdrwUnMakeSepDataString(%d)",retFlag);
  __DBGpr_com(buf);
  return retFlag;
}

/***************************************************
 *
 * Reorient stringlist data to match CTBI map
 * Requires the data from the map and the Separator
 *
 ***************************************************/
IGRstat VDdrwApplyMapToDataStrs(IGRchar ***strList,
				IGRchar   *strListCnt,
				IGRchar   *separator,
				IGRchar  **maps,
				IGRchar    mapRows)
{
  IGRint     retFlag      = 0;
  IGRint     i            = 0;
  IGRint     j            = 0;
  IGRint     k            = 0;
  IGRint     rowLocation  = 0;
  IGRchar    buf[128],strBuf[8192];
  IGRchar **localStrs;
  IGRint    localStrsCnt  = 0;
  IGRchar **dataStrs;
  IGRint    dataStrsCnt   = 0;
  
  // say hi
  __DBGpr_com(">>> VDdrwApplyMapToDataStrs");
  /* args check */
  if(!strList) goto wrapup;
  if(!separator) goto wrapup;
  if(!maps) goto wrapup;
  if(mapRows < 1) goto wrapup;
  if(*strListCnt < 1) goto wrapup;

  /* inits */
  buf[0] = '\0';
  strBuf[0] = '\0';
  
  /* loop through the strList and fetch a string*/
  for(i = 0;i < *strListCnt;i++) {
    strcpy(strBuf,(*strList)[i]);
    /* cut it up into its dataStrs*/ 
    __DBGpr_com("at loc #1");
    VDdrwUnMakeSepDataString(strBuf,separator,&dataStrs,&dataStrsCnt);
    
    /* fetch the map data  and map the strBuf*/
    strBuf[0] = '\0';
    for(j = 0;j < mapRows;j++) {
      rowLocation = atoi(maps[j]);
      rowLocation--;
      if(rowLocation < 0) {
	if(j > 0) strcat(strBuf,separator);
	strcat(strBuf," ");
      } else {
	if(j > 0) strcat(strBuf,separator);
	strcat(strBuf,dataStrs[rowLocation]);
      } 
    }
    vdtvw$AddStrList(item    = strBuf,
		     List    = &localStrs,
		     ListCnt = &localStrsCnt);
  }
    __DBGpr_com("at loc #2");
  _LOOPFREE( *strList,*strListCnt );
  *strList = localStrs;
  *strListCnt = localStrsCnt;
      __DBGpr_com("at loc #3");
  retFlag = 1;

 wrapup:
  if(dataStrsCnt > 0) _LOOPFREE( dataStrs,dataStrsCnt );
  // say bye
  sprintf(buf,"<<< VDdrwApplyMapToDataStrs(%d)",retFlag);
  __DBGpr_com(buf);
  return retFlag;

}

/***************************************************
 *
 *  Count the number of columns in a 
 * Separator/token string
 * <token><separator><token><separator><token>...
 *
 ***************************************************/
IGRstat VDdrwGetTokenCnt(IGRchar *testString,
			 IGRchar *separator,
			 IGRint  *colCnt)
{
  IGRint     retFlag      = 0;
  IGRchar    *p,buf[128],wkBuf[4192];
  IGRint     sepLength = 0;
  IGRint     wkBufLen  = 0;

  
  // say hi
  __DBGpr_com(">>> VDdrwGetTokenCnt");

  /* init */
  *colCnt = 0;

  /* args check */
  if(!testString) goto wrapup;
  if(!separator)  goto wrapup;

  strcpy(wkBuf,testString);
  sepLength = strlen(separator);
  if(sepLength < 1) goto wrapup;
  *colCnt = *colCnt + 1;
  /* start getting the string token stuff going */
  do {
    p = strstr(wkBuf,separator);
    if(!p) goto wrapup;
     *colCnt = *colCnt + 1;
    wkBufLen = strlen(wkBuf);
    if(wkBufLen > sepLength) {
      p = p + sepLength;
      strcpy(wkBuf,p);
      continue;
    }
    break;
  } while (1);
  
  retFlag = 1;

 wrapup:

  sprintf(buf,"<<< VDdrwGetTokenCnt(%d)[%d]\n",retFlag,*colCnt);
  __DBGpr_com(buf);
  return retFlag;

}

/**************************************************
 *
 * make a xmlFile and xslFile into an XML tree and 
 * get the data from it for OPE table
 * kills all the trees when done
 * inputs
 * xmlSchema     -> the path of the file for the xmlSchema 
 *                  to be used
 * xslStyleSheet -> the path of the file for the 
 *                  xsl StyleSheet to be used
 * separator     -> The separator to be used to make
 *                  the delimiters in the strings
 * outputs
 * colBuf        -> a list of text rows for the data
 *                  this is <data><separator><data>...
 * nbCols        -> a count of the number of rows of 
 *                  data supplied
 *
 * all XML structures are transient in this process
 * Process tested but not incorporated for use 
 * 09/27/01 Prototyped vdtbl$ProcessXMLstyle(..) 
 * available for use.
 *
 **************************************************/
IGRstat VDtblProcessXMLstyle(IGRchar   *xmlSchema,
			     IGRchar   *xslStyleSheet,
			     IGRchar   *separator,
			     IGRchar  **colBuf,
			     IGRint    *nbCols)
{
  IGRint  retFlag      = 0;
  IGRchar buf[128];
  TGRid   xmlTreeID,xslTreeID,xmlOutTreeID;
  
  // say hi
  strcpy(buf,">>> VDtblProcessXMLstyle");
  // printf("%s\n",buf);
  __DBGpr_com(buf);

  /* inits */
  xmlTreeID.objid = NULL_OBJID;
  xslTreeID.objid = NULL_OBJID;
  xmlOutTreeID.objid = NULL_OBJID;
  *nbCols = 0;

  /* check the input */
  if(!xmlSchema) goto wrapup;
  if(!xslStyleSheet) goto wrapup;
  if(!separator) goto wrapup;

  /* check the content */
  if( !VD_wordcount( xmlSchema ) )
  {
    goto wrapup;
  }

  /* check the content */
  if( !VD_wordcount( xslStyleSheet ) )
  {
    goto wrapup;
  } 

  /* check the content */
  if( !VD_wordcount( separator ) )
  {
    goto wrapup;
  } 

  /* make the xmlTreeID */
  VDxdomCreateTreeFromXmlFile(xmlSchema,&xmlTreeID);
  if(xmlTreeID.objid == NULL_OBJID) goto wrapup;

  /* make the xslTreeID */
  VDxdomCreateStyleSheetFromFile(xslStyleSheet,&xslTreeID);
  if(xslTreeID.objid == NULL_OBJID) goto wrapup;

  /* make the xmlOutTreeID */
  VDxdomApplyStyleSheet(&xslTreeID,&xmlTreeID,NULL,&xmlOutTreeID);
  if(xmlOutTreeID.objid == NULL_OBJID) goto wrapup;

  retFlag = vd$xmltbl_getRowData (xtreeID         = &xmlOutTreeID,
				  separator       = separator,
				  colBuf          = colBuf,
				  nbCols          = nbCols  );
  if (*nbCols > 0) retFlag = 1;
  
 wrapup:
  /* clean up the ID's */
  if(xmlTreeID.objid != NULL_OBJID)       VDxdomDeleteNode(&xmlTreeID);
  if(xslTreeID.objid != NULL_OBJID)       VDxdomDeleteStyleSheet(&xslTreeID);
  if(xmlOutTreeID.objid != NULL_OBJID)    VDxdomDeleteNode(&xmlOutTreeID);

  // say bye
 sprintf(buf,"<<< VDtblProcessXMLstyle(%d)",retFlag);
 //printf("%s\n",buf);
  __DBGpr_com(buf);
  return retFlag;
}


end implementation Root;
