/* $Id: VDxml.C,v 1.5 2001/09/14 19:23:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDxml.C
 *
 * Description: Basic xml functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxml.C,v $
 *      Revision 1.5  2001/09/14 19:23:12  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/05/22 15:47:36  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/07 20:53:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.2  2000/07/17  18:34:06  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.3  2000/03/24  15:20:54  pinnacle
 * bsp
 *
 * Revision 1.2  2000/02/18  16:26:22  pinnacle
 * sms
 *
 * Revision 1.1  2000/01/26  15:36:20  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/99  ah      Created
 * 01/10/00  ah      New output interface
 * 01/26/00  ah      Changed to .C for stand alone programs
 * 03/20/00  ah      Added buffer for output
 * 09/14/01  ah      Fixed a crash in IsXmlFile
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDxml.h"

#include <sys/types.h>
#include "dirent.h"

/* ---------------------------------------------------------
 * Convert to upper case
 */
void VDstrupr(IGRchar *str)
{
  IGRchar *p;

  if (str == NULL) return;
  for(p = str; *p; p++) {
    *p = toupper(*p);
  }
  return;
}
/* ---------------------------------------------------------
 * Convert to lower case
 */
void VDstrlwr(IGRchar *str)
{
  IGRchar *p;

  if (str == NULL) return;
  for(p = str; *p; p++) {
    *p = tolower(*p);
  }
  return;
}

static int stripTagNameColons;

/* ---------------------------------------------------------
 * Determines if given file is an xml file and 
 * optionally, if of a particular type
 */
IGRstar VDxmlIsXMLFile(IGRchar         *fileName, 
                       IGRchar         *docType,
                       TVDxmlFileInfos *fileInfos) 
{
  IGRstat retFlag = 0;
  FILE *file = NULL;

  IGRchar buf[256];
  IGRchar cmp[256];
  IGRchar *p;
  
  IGRint len;
  
  // Arg check
  if (fileName == NULL) goto wrapup;

  // First need to open
  file = fopen(fileName,"rt");
  if (file == NULL) goto wrapup;

  // Read first 240 characters (to prevent buffer overflows)
  *buf = 0;
  fgets(buf,sizeof(buf),file);

  // Check header for version
  strcpy(cmp,"<?XML VERSION=");
  if (strncasecmp(buf,cmp,sizeof(cmp)) == NULL) goto wrapup;

  // Second line is type
  if ((docType == NULL) || (*docType == 0)) {
    retFlag = 1;
    goto wrapup;
  }

  // Read next line 
  // Warning, it could be long so don't rely on NULL terminator
  *buf = 0;
  fgets(buf,sizeof(buf),file);

  // Check the doc type
  sprintf(cmp,"<!DOCTYPE %s",docType);
  if (strncasecmp(buf,cmp,strlen(cmp))) goto wrapup;

  // Append
  if ((fileInfos) && (fileInfos->cnt < fileInfos->max)) {
    strcpy(fileInfos->info[fileInfos->cnt].io.fileName,fileName);
    fileInfos->cnt++;
  }

  // Done
  retFlag = 1;

wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* ---------------------------------------------------------
 * Search one director for xml files
 */
IGRstar VDxmlFindXMLFilesInDir(IGRchar         *dirName, 
                               IGRchar         *docType,
                               TVDxmlFileInfos *fileInfos)
{
  IGRstat retFlag = 0;

  DIR		*dirInfo = NULL;
  struct dirent	*dirEntry;

  IGRchar dirPath [256];
  IGRchar fileName[256];

  IGRchar *p;

  // Arg check
  if (dirName == NULL) strcpy (dirPath,"./");
  else                 sprintf(dirPath,"%s/",dirName);

  // Open directry
  dirInfo = opendir(dirPath);
  if (dirInfo == NULL) goto wrapup;

  // Cycle through
  while(dirEntry = readdir(dirInfo)) {

    // Filter all but xml files
    p = strrchr(dirEntry->d_name,'.');
    if ((p) && (!strcmp(p,".xml"))) {

      sprintf(fileName,"%s%s",dirPath,dirEntry->d_name);
      VDxmlIsXMLFile(fileName,docType,fileInfos);
    }
  }

  // Done
  retFlag = 1;

wrapup:
  if (dirInfo) closedir(dirInfo);
  return retFlag;
}

/* ---------------------------------------------------
 * Break a line into name value pair
 */
IGRstar VDxmlGetNameValue(IGRchar *buf, 
                          IGRchar *name, 
                          IGRchar *value)
{
  IGRstat retFlag;
  IGRchar *pEqual;
  IGRchar *p;

  // Init
  retFlag = 0;
  *name  = 0;
  *value = 0;

  // Look for equal
  pEqual = strchr(buf,'=');
  if (pEqual == NULL) goto wrapup;
  if (strlen(pEqual) < 2) goto wrapup;

  // Pull the name
  for(p = buf; *p <= ' '; p = p + 1);
  *pEqual = 0;
  strcpy(name,p);

  // Pull the value
  strcpy(value,pEqual+2);
  p = strchr(value,'"');
  if (p) *p = 0;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Utility routine to generate text file name from
 * the regular xml file name
 */
IGRstar VDxmlGetTextFileName(TVDxmlFileInfo *fileInfo,
                             IGRchar        *txtFileName)
{
  IGRstat retFlag = 0;
  IGRchar *p;

  // Arg check
  if (txtFileName == NULL) goto wrapup;
  *txtFileName = 0;

  if (fileInfo == NULL) goto wrapup;
  strcpy(txtFileName,fileInfo->io.fileName);
  if (*txtFileName == 0) goto wrapup;

  p = strrchr(txtFileName,'.');
  if (p == NULL) strcat(txtFileName,".txt");
  else           strcpy(p,".txt");

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write string to stream buffer
 */
IGRstat VDxmlWriteBufToStream(TVDxmlStreamInfo *io, IGRchar *buf)
{
  IGRstat retFlag = 1;
  IGRint  len;
  IGRchar *bufx;
  
  if (io->file) {
    fputs(buf,io->file);
  }
  //printf("ADD %2d '%s'\n",strlen(buf),buf);
  
  if (io->buf) {
    len = strlen(buf);

    // Check for room
    while ((io->bufIndex + len + 1) >= io->bufMax) {
      bufx = realloc(io->buf,io->bufMax + io->bufInc);
      if (bufx == NULL) goto wrapup;
      io->buf  = bufx;
      io->bufMax += io->bufInc;
      //printf("REA %3d\n",io->bufMax);
    }

    // Add it
    strcpy(io->buf+io->bufIndex,buf);
    io->bufIndex += len;

  }
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write char to stream buffer
 */
IGRstat VDxmlWriteCharToStream(TVDxmlStreamInfo *io, IGRchar c)
{
  IGRstat retFlag = 1;
  IGRchar *buf;
  
  if (io->file) {
    fputc(c,io->file);
  }
  
  if (io->buf) {

    // Check for room
    if ((io->bufIndex + 1) >= io->bufMax) {
      buf = realloc(io->buf,io->bufMax + io->bufInc);
      if (buf == NULL) goto wrapup;
      io->buf = buf;
      io->bufMax += io->bufInc;
    }
    
    // Add It
    *(io->buf+io->bufIndex) = c;
      io->bufIndex++;
    *(io->buf+io->bufIndex) = 0;
  
  }
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Open xml buffer for output
 * Obsolete - Replace with VDxmlOpenOutputStream
 *
  IGRchar *buf;
  IGRint   bufMax;
  IGRint   bufPos;
  IGRint   bufInc;
  IGRint   bufIndex;
 */
IGRstat VDxmlOpenOutputBuf(TVDxmlFileInfo *a_fileInfo,
			   IGRchar        *a_buf,
			   IGRint          a_bufMax,
			   IGRint          a_bufInc,
			   IGRchar        *a_docType,
			   IGRchar        *a_dtdName) 
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  IGRchar docType[256];
  IGRchar dtdName[256];

  TVDxmlStreamInfo *io;
  IGRchar bufx[256];
  
  // Arg check
  if (a_fileInfo == NULL) goto wrapup;
  memset(a_fileInfo,0,sizeof(TVDxmlFileInfo));
  io = &a_fileInfo->io;
  
  // Buffer initialization
  if (a_bufMax <= 0) io->bufMax = 256;
  else               io->bufMax = a_bufMax;
  
  if (a_bufInc <= 0) io->bufInc = 256;
  else               io->bufInc = a_bufInc;
  
  if (a_buf) io->buf = a_buf;  // Assume a_bufMax has been sent correctly
  else       io->buf = malloc(io->bufMax);
  if (io->buf == NULL) goto wrapup;
  
  *io->buf = 0;
  
  // Doc and dtd stuff
  if (a_docType == NULL) strcpy(docType,"docType");
  else                   strcpy(docType,a_docType);

  if (a_dtdName == NULL) strcpy(dtdName,"dtdName");
  else                   strcpy(dtdName,a_dtdName);

  p = strchr(dtdName,'.');
  if (p == NULL) strcat(dtdName,".dtd");
  
  // XML Flag line
  sprintf(bufx,"<?xml version=\"1.0\" standalone=\"yes\"?>\n");
  VDxmlWriteBufToStream(io,bufx);
 
  // Skip this so browsers don't complain
  // sprintf(bufx,"<!DOCTYPE %s SYSTEM \"%s\">\n\n",docType,dtdName);
  // VDxmlWriteBufToStream(io,bufx);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Open xml file for output
 * Obsolete - Replace with VDxmlOpenOutputStream
 */
IGRstat VDxmlOpenOutputFile(TVDxmlFileInfo *a_fileInfo,
                            IGRchar        *a_fileName, 
                            IGRchar        *a_docType,
                            IGRchar        *a_dtdName) 
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  IGRchar docType[256];
  IGRchar dtdName[256];

  TVDxmlStreamInfo *io;
  IGRchar bufx[256];
  
  // Arg check
  if (a_fileInfo == NULL) goto wrapup;
  memset(a_fileInfo,0,sizeof(TVDxmlFileInfo));
  io = &a_fileInfo->io;
  
  if (a_fileName == NULL) goto wrapup;
  strcpy(io->fileName,a_fileName);

  if (a_docType == NULL) strcpy(docType,"docType");
  else                   strcpy(docType,a_docType);

  if (a_dtdName == NULL) strcpy(dtdName,"dtdName");
  else                   strcpy(dtdName,a_dtdName);

  p = strchr(dtdName,'.');
  if (p == NULL) strcat(dtdName,".dtd");
    
  // Open it
  io->file = fopen(io->fileName,"wt");
  if (io->file == NULL) {
    printf("*** Unable to open xml file %s for writing\n",io->fileName);
    goto wrapup;
  }
  
  // XML Flag line
  sprintf(bufx,"<?xml version=\"1.0\" standalone=\"yes\"?>\n");
  VDxmlWriteBufToStream(io,bufx);
  
  // sprintf(bufx,"<!DOCTYPE %s SYSTEM \"%s\">\n\n",docType,dtdName);
  // VDxmlWriteBufToStream(io,bufx);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Opens either file or buffer stream
 */
IGRstat VDxmlOpenOutputStream(TVDxmlFileInfo *fileInfo,
			      IGRchar        *fileName,
			      IGRchar        *docType,
			      IGRchar        *dtdName,
			      IGRchar        *bufXml,
			      IGRint          bufMax,
			      IGRint          bufInc,
			      IGRint          stripColons,
			      IGRdouble       version,
			      IGRint          standAlone)
{
  IGRstat retFlag = 0;
  
  TVDxmlStreamInfo *io;

  IGRchar buf    [512];
  IGRchar ver     [32];
  IGRchar alone   [32];
  IGRchar dtdNamex[64];
  IGRchar *p;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  memset(fileInfo,0,sizeof(TVDxmlFileInfo));
  io = &fileInfo->io;

  // Open file
  if (fileName) {
    
    strcpy(io->fileName,fileName);
    io->file = fopen(io->fileName,"wt");
    if (io->file == NULL) {
      printf("*** Unable to open xml file %s for writing\n",io->fileName);
      goto wrapup;
    }
  }
  // Open Buf
  else {

    // Fake Filename
    strcpy(io->fileName,"Buffer");
    
    // Buffer initialization
    if (bufMax <= 0) io->bufMax = 256;
    else             io->bufMax = bufMax;
  
    if (bufInc <= 0) io->bufInc = 256;
    else             io->bufInc = bufInc;
  
    if (bufXml) io->buf = bufXml;  // Assume bufMax has been sent correctly
    else        io->buf = malloc(io->bufMax);

    if (io->buf == NULL) {
      printf("*** Problem allocating xml output buffer\n");
      goto wrapup;
    } 
    *io->buf = 0;
  }

  // XML Flag line
  sprintf(ver,"%.1f",version);
  if (standAlone) strcpy(alone,"yes");
  else            strcpy(alone,"no");
  
  sprintf(buf,"<?xml version=\"%s\" standalone=\"%s\"?>\n",ver,alone);
  VDxmlWriteBufToStream(io,buf);
  
  // DTD and doctype
  if (docType) {

    // Mess around a bit
    if (dtdName) strcpy(dtdNamex, dtdName);
    else         strcpy(dtdNamex,"dtdName");
    p = strchr(dtdNamex,'.');
    if (p == NULL) strcat(dtdNamex,".dtd");
  
    // Skip so browsers don't complain
    // sprintf(buf,"<!DOCTYPE %s SYSTEM \"%s\">\n\n",docType,dtdNamex);
    // VDxmlWriteBufToStream(io,buf);
  }
  
  // Should store in the info structure
  stripTagNameColons = stripColons;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

/* -----------------------------------------
 * Close file and/or buffer
 */
IGRstar VDxmlCloseOutputStream(TVDxmlFileInfo *fileInfo)
{
  IGRstat retFlag = 0;
  IGRchar cmd[256];

  TVDxmlStreamInfo *io;

  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  fileInfo->indent = 0;
  
  // Check for file
  if (io->file) {
    
    fclose(io->file);
    io->file = NULL;

    // Change mode just for grins
    sprintf(cmd,"chmod 777 %s",io->fileName);
    system (cmd);
  }
  
  // For the buffer ???

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
/* -----------------------------------------
 * # Close file if it is open
 * Keep for now just a wrapper 
 */
IGRstar VDxmlCloseOutputFile(TVDxmlFileInfo *fileInfo)
{
  return VDxmlCloseOutputStream(fileInfo);
}

/* -----------------------------------------------
 * Little bit of processing on tags
 */
IGRstat VDxmlWriteProcessTag(IGRchar *i_tag, IGRchar *o_tag)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  // Arg check
  if (o_tag == NULL) goto wrapup;
  if (i_tag == NULL) {
    *o_tag = 0;
    goto wrapup;
  }
  strcpy(o_tag,i_tag);
  
  // Strip colons
  if (stripTagNameColons) {
    for(p = o_tag; *p; p++) {
      if (*p == ':') *p = '_';
    }
  }

  // Drop []
  p = strchr(o_tag,'[');
  if (p) strcpy(p,p+1);
  p = strchr(o_tag,']');
  if (p) *p = 0;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Make writing object headers easier
 */
IGRstat VDxmlWriteObjBeg(TVDxmlFileInfo *fileInfo,
			 IGRchar        *objName, 
			 IGRint          atrFlag,
			 IGRint          returnFlag)
{
  IGRstat retFlag = 0;
  
  IGRchar tag [256];
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  if ((objName  == NULL) || (*objName == 0)) goto wrapup;
  
  // Indent
  VDxmlWriteIndent(fileInfo);
  fileInfo->indent++;

  // Adjust tag
  VDxmlWriteProcessTag(objName,tag);
  
  // Doit
  if (atrFlag) sprintf(bufx,"<%s", tag);
  else         sprintf(bufx,"<%s>",tag);
  VDxmlWriteBufToStream(io,bufx);
  
  if (returnFlag) VDxmlWriteCharToStream(io,'\n');
  else            VDxmlWriteCharToStream(io,' ');
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * # Make writing object enders easier
 */
IGRstat VDxmlWriteObjEnd(TVDxmlFileInfo *fileInfo,
			 IGRchar        *objName,
			 IGRint          indentFlag)
{
  IGRstat retFlag = 0;
  
  IGRchar tag [256];
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  if ((objName  == NULL) || (*objName == 0)) goto wrapup;
  
  // Indent
  if (fileInfo->indent) fileInfo->indent--;
  if (indentFlag) VDxmlWriteIndent(fileInfo);

  // Adjust tag
  VDxmlWriteProcessTag(objName,tag);

  // Do it
  sprintf(bufx,"</%s>\n",tag);
  VDxmlWriteBufToStream(io,bufx);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * # Make writing attribute enders easier
 */
IGRstat VDxmlWriteAtrEnd(TVDxmlFileInfo *fileInfo,
			 IGRint          indentFlag,
			 IGRint          returnFlag)
{
  IGRstat retFlag = 0;
  
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;

  // Indent
  if (indentFlag) VDxmlWriteIndent(fileInfo);

  // Do it
  if (returnFlag) VDxmlWriteBufToStream(io,">\n");
  else            VDxmlWriteBufToStream(io,">");

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * # Writes out indent spaces
 */
IGRstat VDxmlWriteIndent(TVDxmlFileInfo *fileInfo)
{
  IGRstat retFlag = 0;
  IGRint  i;
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  
  // Do it
  for(i = 0; i < fileInfo->indent; i++) {
    VDxmlWriteCharToStream(io,' ');
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Write text attribute
 */
IGRstat VDxmlWriteAtrTxt(TVDxmlFileInfo *fileInfo,
			 IGRchar        *atrName,
			 IGRchar        *atrValue,
			 IGRint          indentFlag,
			 IGRint          returnFlag)
{
  IGRchar retFlag = 0;
  IGRchar *p;
  
  IGRchar tag[256];
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  if ((atrName  == NULL) || (*atrName == 0)) goto wrapup;
  if ( atrValue == NULL) goto wrapup;
  
  // Indent
  if (indentFlag) VDxmlWriteIndent(fileInfo);

  // Adjust tag
  VDxmlWriteProcessTag(atrName,tag);
  
  // attribute
  sprintf(bufx,"%s=\"",tag);
  VDxmlWriteBufToStream(io,bufx);
  
  // Char by char to allow conversion to & stuff
  for(p = atrValue; *p; p++) {
    switch(*p) {
    case '&': 
      VDxmlWriteBufToStream(io,"&amp;");
      break;
    case '<': 
      VDxmlWriteBufToStream(io,"&lt;");
      break;
    case '>': 
      VDxmlWriteBufToStream(io,"&gt;");
      break;
    case '"': 
      VDxmlWriteBufToStream(io,"&quot;");
      break;
    case '\'': 
      VDxmlWriteBufToStream(io,"&apos;");
      break;
    case '\n': 
      VDxmlWriteCharToStream(io,*p);
      break;
    case '\t': 
      VDxmlWriteCharToStream(io,*p);
      break;
    default:
      /* -----------------------------------------
       * There really should not be anything but straight
       * text at this point
       */
      if (*p >= ' ') VDxmlWriteCharToStream(io,*p);
      else {
	printf("*** In VDxmlWriteAtrTxt with control char of %x in %s = %s\n",
	       *p,atrName,atrValue);
      }
    }
  }
  // Done with attribute
  VDxmlWriteCharToStream(io,'\"');

  // Either return or add blank
  if (returnFlag) VDxmlWriteCharToStream(io,'\n');
  else            VDxmlWriteCharToStream(io,' ');
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write double attribute
 */
IGRstat VDxmlWriteAtrDbl(TVDxmlFileInfo *fileInfo,
			 IGRchar        *atrName,
			 IGRdouble       atrValue,
			 IGRint          indentFlag,
			 IGRint          returnFlag)
{
  IGRchar retFlag = 0;
  IGRchar buf[128],*p;
  
  IGRchar tag[256];
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  if ((atrName  == NULL) || (*atrName == 0)) goto wrapup;
  
  // Indent
  if (indentFlag) VDxmlWriteIndent(fileInfo);
  
  // Clean up a bit
  sprintf(buf,"%f",atrValue);
  for(p = buf + strlen(buf) - 1; (p >= buf) && (*p == '0'); p--);
  if (p < buf) strcpy(buf,"0.0");
  else {
    if (*p == '.') strcpy(p,".0");
    else *(p+1) = 0;
  }
  
  // Adjust tag
  VDxmlWriteProcessTag(atrName,tag);
  
  // Attribute
  sprintf(bufx,"%s=\"%s\"",tag,buf);
  VDxmlWriteBufToStream(io,bufx);
  
  // Either return or add blank
  if (returnFlag) VDxmlWriteCharToStream(io,'\n');
  else            VDxmlWriteCharToStream(io,' ');
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * Write integer attribute
 */
IGRstat VDxmlWriteAtrInt(TVDxmlFileInfo *fileInfo,
			 IGRchar        *atrName,
			 IGRint          atrValue,
			 IGRint          indentFlag,
			 IGRint          returnFlag)
{
  IGRchar retFlag = 0;

  IGRchar tag[256];
  IGRchar bufx[256];
  TVDxmlStreamInfo *io;
  
  // Arg check
  if (fileInfo == NULL) goto wrapup;
  io = &fileInfo->io;
  if ((atrName  == NULL) || (*atrName == 0)) goto wrapup;
  
  // Indent
  if (indentFlag) VDxmlWriteIndent(fileInfo);
  
  // Adjust tag
  VDxmlWriteProcessTag(atrName,tag);
  
  // Attribute
  sprintf(bufx,"%s=\"%d\"",tag,atrValue);
  VDxmlWriteBufToStream(io,bufx);
  
  // Either return or add blank
  if (returnFlag) VDxmlWriteCharToStream(io,'\n');
  else            VDxmlWriteCharToStream(io,' ');
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Load a file into a buffer 
 */
IGRstat VDxmlLoadBufferFromFile(IGRchar *fileName, IGRchar *buf)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  IGRint  c;
  
  FILE *file = NULL;
  
  // Arg check
  if (buf      == NULL) goto wrapup;
  *buf = 0;
  if (fileName == NULL) goto wrapup;
  
  // Open it
  file = fopen(fileName,"rb");
  if (file == NULL) goto wrapup;
  
  // Cycle through
  p = buf;
  while((c = fgetc(file)) != EOF) {
    *p++ = c;
  }
  *p = 0;
  fclose(file);
  file = NULL;
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Save a buffer into a file
 */
IGRstat VDxmlSaveBufferToFile(IGRchar *fileName, IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  FILE *file = NULL;
  
  // Arg check
  if (buf      == NULL) goto wrapup;
  if (fileName == NULL) goto wrapup;
  
  // Open it
  file = fopen(fileName,"wb");
  if (file == NULL) goto wrapup;
  
  // Write it
  fputs(buf,file);
  fclose(file);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
