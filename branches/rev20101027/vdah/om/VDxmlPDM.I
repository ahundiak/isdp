/* $Id: VDxmlPDM.I,v 1.3 2001/01/11 16:34:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/VDxmlPDM.I
 *
 * Description: PDM specific xml functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlPDM.I,v $
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/02/18  14:38:20  pinnacle
# ah
#
# Revision 1.1  2000/01/26  15:32:36  pinnacle
# ah
#
# Revision 1.2  2000/01/10  21:15:52  pinnacle
# ah
#
# Revision 1.1  1999/04/21  20:01:14  pinnacle
# xml
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/99  ah      Created
 * 01/10/00  ah      New output interface
 * 01/26/00  ah      Moved to vdah for cleanup
 * 02/18/00  ah      Changed the text file code to use static file pointer
 *                   since the xml infor structure no longer has spare pointers
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDfrm.h"

#include "VDxml.h"
#include "VDxmlPDM.h"

#include "v_risproto.h"

static Form          form;
static int           listRow;
static TVDxmlPDMInfo pdmInfo;
static FILE         *file1;

extern IGRchar VDSenvir_name[];

/* ---------------------------------------------------------
 * Master search routine for xml files
 */
IGRstar VDxmlFindXMLFiles(IGRint           a_localFlag,
                          IGRchar         *a_configPath,
                          IGRchar         *a_docType,
                          TVDxmlFileInfos *a_fileInfos) 
{
  IGRstat retFlag = 0;
  IGRchar docType[128];

  IGRchar dirPath[256];
  IGRint  i;

  // Arg check
  if (docType == NULL) goto wrapup;
  strcpy  (docType,a_docType);
  VDstrupr(docType);

  // Start by looking in current directory and ingr dir
  if (a_localFlag) {
    VDxmlFindXMLFilesInDir(".",docType,a_fileInfos);
    VDxmlFindXMLFilesInDir("/usr/tmp/ingr/config/xml",docType,a_fileInfos);
  }

  // Now look through config directories
  if (a_configPath) {

    for(i = 0;
        ex$get_path(index=i,path=dirPath,len=sizeof(dirPath)); 
        i++ ) {

      strcat(dirPath,a_configPath);
      VDxmlFindXMLFilesInDir(dirPath,docType,a_fileInfos);
    }  
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Searches one line in the file
 */
IGRstar VDxmlPDMSearchFileLine(IGRchar *buf,
                               IGRchar *searchStr)

{
  IGRstat retFlag;

  IGRchar str[256];
  IGRchar partDesc[256];
  IGRchar *p;

  IGRint matchFlag;

  IGRchar name [128];
  IGRchar value[128];

  // Init
  retFlag = 0;

  // Break into name/value
  VDxmlGetNameValue(buf,name,value);
  if (*name == 0) goto wrapup;

  // printf("%-20s %s\n",name,value);

  // Looking for certain key words
  retFlag = 1;
  if (!strcmp(name,VDXML_IN_PDM_CATALOG_NAME)) {
    strcpy(pdmInfo.catName,value);
    goto wrapup;
  }
  if (!strcmp(name,VDXML_IN_PDM_CATALOG_DESC)) {
    strcpy(pdmInfo.catDesc,value);
    goto wrapup;
  }
  if (!strcmp(name,VDXML_IN_PDM_PART_NAME)) {
    strcpy(pdmInfo.partName,value);
    goto wrapup;
  }
  if (!strcmp(name,VDXML_IN_PDM_PART_DESC)) {
    strcpy(pdmInfo.partDesc,value);
    goto wrapup;
  }
  if (!strcmp(name,VDXML_IN_PDM_PART_REV)) {
    strcpy(pdmInfo.partRev,value);
    goto wrapup;
  }
  if (strcmp(name,VDXML_IN_PDM_FILE_NAME)) {
    retFlag = 0;
    goto wrapup;
  }
  strcpy(pdmInfo.fileName,value);

  // Filter the row
#if 0
  printf("%-20s %-20s %-20s\n",
         pdmInfo.catName,pdmInfo.partName,pdmInfo.partDesc);
#endif
  // A * just gets everything
  matchFlag = 0;
  if (*str == '*') {
    matchFlag = 1;
    goto got_match;
  }

  strcpy(str,searchStr);
  VDstrupr(str);

  strcpy(partDesc,pdmInfo.partDesc);
  VDstrupr(partDesc);
 
  while(*str) {

    // Strip any leading blank
    for(p = str; (*p != 0) && (*p <= ' '); p = p + 1);
    if (*p != 0) {

      strcpy(str,p);

      // Strip any trailing blanks
      p = strchr(str,' ');
      if (p) {
        *p = 0;
        p = p + 1;
      }
      else p = str + strlen(str); 

      // Do the compare
      if (strstr(partDesc,str) == NULL) goto wrapup;
      
      // Got a match
      matchFlag = 1;
      strcpy(str,p);

    }
  }

  if (matchFlag == 0) goto wrapup;
got_match:
#if 0
  printf("%-20s %-20s %-20s\n",
         pdmInfo.catName,pdmInfo.partName,pdmInfo.partDesc);
#endif

  if (form == NULL) goto wrapup;

  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                row    = listRow,
                col    = 0,
                txt    = pdmInfo.catName);

  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                row    = listRow,
                col    = 1,
                txt    = pdmInfo.partName);

  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                row    = listRow,
                col    = 2,
                txt    = pdmInfo.partRev);

  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                row    = listRow,
                col    = 3,
                txt    = pdmInfo.partDesc);

  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                row    = listRow,
                col    = 4,
                txt    = pdmInfo.fileName);

  listRow = listRow + 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Implements the file search routine
 * Much faster than a ppl based solution
 */
IGRstar VDxmlPDMSearchFile(Form a_form)
{
  IGRstat retFlag = 0;

  IGRchar dataFileName[256];
  IGRchar searchStr[256];
  IGRchar buf[256];

  FILE *file = NULL;

  // Init
  form = a_form;
  if (form == NULL) goto wrapup;

  // Init
  memset(&pdmInfo,0,sizeof(pdmInfo));

  // Nothing found yet
  vdfrm$SetText(form   = form,
                gadget = VDXML_PDM_FORM_LIST,
                rows   = 0);
  listRow = 0;

  // Pull args
  vdfrm$GetText(form = form,
                gadget = VDXML_PDM_FORM_FILES,
                txt    = dataFileName);

  if (*dataFileName == 0) goto wrapup;

  vdfrm$GetText(form = form,
                gadget = VDXML_PDM_FORM_SEARCH,
                txt    = searchStr);
  if (*searchStr == 0) goto wrapup;
  VDstrupr(searchStr);

  // Open file
  file = fopen(dataFileName,"rt");
  if (file == NULL) goto wrapup;

  UI_status("Searching ...");

  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {

    VDxmlPDMSearchFileLine(buf,searchStr);

  }
  sprintf(buf,"Search Complete, %d matches",listRow);
  UI_status(buf);

  // Done
  retFlag = 1;

wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* -----------------------------------------------
 * Query parts for catalog
 * Need to handle multiple files per part
 * Filter out files with 3 backup versions
 */
IGRstat VDxmlPDMQueryParts(TVDxmlFileInfo *fileInfo,
                           IGRchar        *catName,
                           IGRint         *partCnt,
                           IGRint         *fileCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  rows = 0;
  IGRint  cols = 0;
  IGRchar **buf = NULL;
  IGRchar qry[256];

  IGRint  i,j;
  IGRchar partName[64];
  IGRchar partRev [64];
  IGRchar fileName[64];

  // Build the query
  sprintf(qry,
	  "Select "
          "n_itemno,n_itemname,n_itemrev,n_itemdesc,"
          "n_itemnum,n_fileno,n_cofilename,p_filedesc "
          "from %s, f_%s where n_itemno = n_itemnum "
          "order by n_itemname,n_itemrev,n_cofilename;",
	  catName, catName);

  sts = VDSsql_query(qry, &cols, &rows, &buf);
  if (!(sts & 1) || (rows < 1) || (cols != 8) || (buf == NULL)) {
    goto wrapup;
  }

  // Cycle through
  *partName = 0;
  *partRev  = 0;
  *fileName = 0;
  
  for(i = 0; i < rows; i++) {

    j = i * cols;

    // Have a new part?
    if (strcmp(partName,buf[j+1]) || strcmp(partRev,buf[j+2])) {

      // Finish previous part
      if (i > 0) {
	VDxmlWriteObjEnd(fileInfo,VDXML_IN_PDM_PART,1);
      }

      // Start new one
      VDxmlWriteObjBeg(fileInfo,VDXML_IN_PDM_PART,1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_PART_NO,  buf[j+0],1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_PART_NAME,buf[j+1],1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_PART_REV, buf[j+2],1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_PART_DESC,buf[j+3],1,0);
      VDxmlWriteAtrEnd(fileInfo,0,1);
      
      strcpy(partName,buf[j+1]);
      strcpy(partRev, buf[j+2]);
      *fileName = 0;
      *partCnt = *partCnt + 1;
    }

    // Deal with file
    if (strcmp(fileName,buf[j+6])) {
	  
      VDxmlWriteObjBeg(fileInfo,VDXML_IN_PDM_FILE,1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_FILE_NO,  buf[j+5],1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_FILE_NAME,buf[j+6],1,1);
      VDxmlWriteAtrTxt(fileInfo,VDXML_IN_PDM_FILE_DESC,buf[j+7],1,0);
      VDxmlWriteAtrEnd(fileInfo,0,1);
      VDxmlWriteObjEnd(fileInfo,VDXML_IN_PDM_FILE,1);
      strcpy(fileName,buf[j+6]);
      *fileCnt = *fileCnt + 1;
      
      // Add entry to text file
      if (file1) {

	fprintf(file1,
		"%-17s %-17s %-3s %-15s %s\n",
		catName,
		buf[j+1],buf[j+2],buf[j+6],buf[j+3]);
      }
    }
  }

  VDxmlWriteObjEnd(fileInfo,VDXML_IN_PDM_PART,1);

  // Done
  retFlag = 1;
  
wrapup:
 
  // Free the buffer (checks for null ptr)
  VdsRisFreeBuffer(buf, rows * cols);

  return retFlag;
}

/* -----------------------------------------------
 * Query for catalogs/parts/files
 */
IGRstar VDxmlPDMQueryCatsParts()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDxmlFileInfo fileInfo;
  IGRchar *p;

  IGRint  rows = 0;
  IGRint  cols = 0;
  IGRchar **buf = NULL;
  IGRchar qry[256];
  IGRchar fileName[256];
  
  IGRint i,j;
  IGRint partCnt,fileCnt;

  // Init
  memset(&fileInfo,0,sizeof(fileInfo));
  file1 = NULL;
  
  // Make sure logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) {
    UI_status("Need to log in to a database");
    goto wrapup;
  }

  //  Create filename
  //  VDSenvir_name's start with "pdme_"; external filled at login
  p = strchr(VDSenvir_name,'_');
  if(p == NULL){
    UI_status("Expected an underbar, '_', in envir_name, didn't get it");
    goto wrapup;
  }
  sprintf(fileName,"%s.xml",p+1);

  // Open eXtended Markup Language file
  sts = VDxmlOpenOutputFile(&fileInfo,
			     fileName,
                            VDXML_IN_PDM_ROOT,
                            VDXML_IN_PDM_SYSTEM);
  if(!(sts & 1))  goto wrapup;

  // Open a little working file as well
  p = strrchr(fileName,'.');
  if (p) strcpy(p,",txt");
  file1 = fopen(fileName,"wt");

  // Put out root object
  VDxmlWriteObjBeg(&fileInfo,VDXML_IN_PDM_ROOT,    0,1);
  VDxmlWriteObjBeg(&fileInfo,VDXML_IN_PDM_CATALOGS,0,1);

  // Get the catalogs
  UI_status("Querying for catalogs...");

  // Get the list; 'C' = parts catalogs
  sprintf(qry,
	  "Select n_catalogno,n_catalogname,n_catalogdesc "
          "from nfmcatalogs where n_type = 'C' " 
          "order by n_catalogname;");
  
  sts  = VDSsql_query(qry, &cols, &rows, &buf);

  // Verify got something
  if (!(sts & 1) || (rows < 1) || (cols != 3) || (buf == NULL)) {
    UI_status("Query for catalogs failed");
    goto wrapup;
  }

  partCnt = 0;
  fileCnt = 0;

  // Cycle through
  for(i = 0; i < rows; i++) {

    j = i * cols;

    // Give user feedback on progress
    if((i % 20) == 0) {
      sprintf(qry,"Processing Catalog %d of %d",i,rows);
      UI_status(qry);
    }
    // Some reason, get pdmlibraries
    if (strcmp(buf[j+1],"pdmlibraries")) {

    VDxmlWriteObjBeg(&fileInfo,VDXML_IN_PDM_CATALOG,1,1);

    VDxmlWriteAtrTxt(&fileInfo,
                      VDXML_IN_PDM_CATALOG_NO,
                      buf[j+0],1,1);

    VDxmlWriteAtrTxt(&fileInfo,
                      VDXML_IN_PDM_CATALOG_NAME,
                      buf[j+1],1,1);

    VDxmlWriteAtrTxt(&fileInfo,
                      VDXML_IN_PDM_CATALOG_DESC,
                      buf[j+2],1,0);

    VDxmlWriteAtrEnd(&fileInfo,0,1);

    VDxmlPDMQueryParts(&fileInfo,
                       buf[j+1],
                       &partCnt,&fileCnt);

    VDxmlWriteObjEnd(&fileInfo,VDXML_IN_PDM_CATALOG,1);

  }}

  // Status
  sprintf(qry,
          "Done, %d catalogs, %d parts, %d files",
          rows,partCnt,fileCnt);
  UI_status(qry);

  // Done
  VDxmlWriteObjEnd(&fileInfo,VDXML_IN_PDM_CATALOGS,1);
  VDxmlWriteObjEnd(&fileInfo,VDXML_IN_PDM_ROOT,1);
  retFlag = 1;
  
wrapup:
 
  VDxmlCloseOutputFile(&fileInfo);
  if (file1) fclose(file1);
  file1 = NULL;
  sprintf(qry,"chmod 777 %s",fileName);
  system (qry);

  // Free the buffer (checks for null ptr)
  VdsRisFreeBuffer(buf, rows * cols);

  return retFlag;
}

end implementation Root;
