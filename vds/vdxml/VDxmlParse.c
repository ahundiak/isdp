/* $Id: VDxmlParse.c,v 1.3 2001/05/22 15:47:41 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDxmlParse.C
 *
 * Description: Basic xml functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlParse.c,v $
 *      Revision 1.3  2001/05/22 15:47:41  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/12 14:04:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.3  2000/03/17  18:07:48  pinnacle
 * ah
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
 * 01/26/99  ah      Changed to .C for stand alone programs
 * 03/17/00  ah      Clean return when callback sets parseInfo->retFlag
 * 02/19/01  ah      Cleaned up parseInfo structure and removed dom stuff
 * 05/22/01  ah      TR5235 Clear out control codes in text buffers
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"

VDASSERT_FFN("VDxmlParse.C");

/* -----------------------------------------------
 * Utility routine to access element stack
 */
IGRstat VDxmlParseGetParentEleType(TVDxmlParseInfo *info,
				   IGRint           nth,
				   TVDxmlTagType    type)
{
  VDASSERT_FN("VDxmlParseGetParentEleType");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(type);*type = 0;
  VDASSERTW(info);
    
  // Bounds check
  if ((nth < 0) || (nth >= info->eleIndex)) goto wrapup;
  
  // Get it (reverse order)
  strcpy(type,info->eleTypes[info->eleIndex - nth - 1]);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Interfaces to the applications call back routine
 */
static IGRstat xmlParseCallback(TVDxmlParseInfo *info,
				IGRint   type,
				IGRchar *tag,
				IGRchar *value)
{
  VDASSERT_FN("xmlParseCallback");
  
  IGRstat retFlag = 0;
  IGRint  sts;

  TVDxmlParseInfoCallback *callback;
  TVDxmlEleInfo *eleInfo = &info->eleInfo;
  
  // Do nothing if parse should be stopped
  if (info->stopParser) goto wrapup;
  
  // Maintain backwards compatibility for now
  memset(eleInfo,0,sizeof(TVDxmlEleInfo));
  eleInfo->type = type;

  // Validate tag
  if (tag) {
    if (strlen(tag) >= VDXML_TAG_TYPE_LEN) {
      printf("*** XML Truncating tag '%s'\n",tag);
      *(tag + VDXML_TAG_TYPE_LEN - 1) = 0;
    }
  }
  
  // Validate value
  if (value) {
    if (strlen(value) >= VDXML_ATR_VALUE_LEN) {
      printf("*** XML Truncating value '%s'\n",value);
      *(value + VDXML_ATR_VALUE_LEN - 1) = 0;
    }
  }

  // Copy the element type from the stack
  if (info->eleIndex > 0) strcpy(eleInfo->eleType,info->eleTypes[info->eleIndex-1]);
  
  // Update more specific information
  switch(type) {

  case VDXML_TYPE_BEG_ELEMENT:

    // Save it
    strcpy(eleInfo->eleType,              tag);
    strcpy(info->eleTypes[info->eleIndex],tag);

    // Update stack
    VDASSERTW((info->eleIndex +1) < info->eleMax);
    info->eleIndex++;
   
    break;

    case VDXML_TYPE_ATTRIBUTE:
      strcpy(eleInfo->atrType, tag);
      strcpy(eleInfo->atrValue,value);
    break;

    case VDXML_TYPE_END_ELEMENT:
      break;    
  }
  
  // See if have a callback routine
  callback = (TVDxmlParseInfoCallback*)info->parseInfoCallback;
  if (callback) {
    sts = (*callback->parseCallback)(info);
    VDASSERTW(sts == 1);
  }

  // Pop element off the stack after the callback is done
  switch(type) {
  case VDXML_TYPE_END_ELEMENT:

    VDASSERTW(info->eleIndex > 0);
    info->eleIndex--;
    
    break;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Comment is happening
 */
static void xmlParseComment(TVDxmlParseInfo *info, IGRchar *buf)
{
  IGRint   c;
  IGRchar *p;
  
  p = buf;

  for(c = VDxmlGetChar(info); 
     (c != EOF) && (c != '>');
      c = VDxmlGetChar(info)) {
    *p++ = abs(c);
  }
  *p = 0;

  xmlParseCallback(info,VDXML_TYPE_COMMENT,NULL,buf);
  
  return;
}

/* ------------------------------------------
 * Version is happening
 */
static void xmlParseVersion(TVDxmlParseInfo *info, IGRchar *buf)
{
  IGRint   c;
  IGRchar *p;
  
  p = buf;

  for(c = VDxmlGetChar(info); 
     (c != EOF) && (c != '>');
      c = VDxmlGetChar(info)) {
    *p++ = abs(c);
  }
  *p = 0;

  xmlParseCallback(info,VDXML_TYPE_VERSION,NULL,buf);
  
  return;
}

/* ----------------------------------------
 * Parse an attribute
 */
static void xmlParseAttribute(TVDxmlParseInfo *info, IGRchar *buf)
{
  VDASSERT_FN("xmlParseAttribute");
  
  IGRint  token;
  IGRchar name[128];

  // Save the attribute name
  strcpy(name,buf);

  // Do nothing if parse should be stopped
  if (info->stopParser) goto wrapup;
  
  /* Token should be equals */
  token = VDxmlGetToken(info,buf);
  VDASSERTW(token == VDXML_TOKEN_EQUALS);

  /* Token should be quoted string */
  token = VDxmlGetToken(info,buf);
  VDASSERTW(token == VDXML_TOKEN_QUOTED_STRING);

  xmlParseCallback(info,VDXML_TYPE_ATTRIBUTE,name,buf);
  
 wrapup:
  return;
}

/* ----------------------------------------
 * Parse an object
 */
static void xmlParseBegBracket(TVDxmlParseInfo *info, IGRchar *buf)
{
  VDASSERT_FN("xmlParseBegBracket");
  
  IGRint token;

  IGRint   c;
  IGRchar *p;

  IGRchar type[128];
  
  /* Token should be a tag */
  token = VDxmlGetToken(info,buf);
  VDASSERTW(token == VDXML_TOKEN_TAG);
  strcpy(type,buf);
  
  // Parse it
  xmlParseCallback(info,VDXML_TYPE_BEG_ELEMENT,type,NULL);
  if (info->stopParser) goto wrapup;
  
  /* Either have closing bracket or attribute identifiers */
  for(token  = VDxmlGetToken(info,buf);
      token == VDXML_TOKEN_TAG;
      token  = VDxmlGetToken(info,buf)) {
  
    /* Process attribute */
    xmlParseAttribute(info,buf);
    if (info->stopParser) goto wrapup;
  }
  VDASSERTW(token == VDXML_TOKEN_END_BRACKET);

  /* Says that the attribute section is done */
  xmlParseCallback(info,VDXML_TYPE_END_ELEMENT_ATTRS,type,NULL);

  /* ------------------------------------------------
   * Between the end bracket and the next beg bracket
   * could have a some text data which is different
   * than the attrribute data
   */

  /* Skip any white space */
  for(c = VDxmlGetChar(info); VDxmlIsCharWhiteSpace(c); c = VDxmlGetChar(info));

  switch(c) {
    case EOF:
    case '<':
      VDxmlPushChar(info);
      return;
  }

  /* Pull out the data */
  p = buf;
  *p++ = c;
  for(c = VDxmlGetChar(info); 
     (c != EOF) && (c != '<');
      c = VDxmlGetChar(info)) {
    *p++ = c;
  }
  VDxmlPushChar(info);

  /* Want to back up and strip white space from end */
  for(p--; (p >= buf) && (VDxmlIsCharWhiteSpace(*p)); p--);
  *(p+1) = 0;

  xmlParseCallback(info,VDXML_TYPE_CHARACTERS,NULL,buf);

 wrapup:
  /* Onto the next item */
  return;
}

/* ----------------------------------------
 * Slash bracket
 */
static void xmlParseSlashBracket(TVDxmlParseInfo *info, IGRchar *buf)
{
  VDASSERT_FN("xmlParseSlashBracket");
  
  IGRint token;

  /* Token should be a tag */
  token = VDxmlGetToken(info,buf);
  VDASSERTW(token == VDXML_TOKEN_TAG);
  
  // Parse it
  xmlParseCallback(info,VDXML_TYPE_END_ELEMENT,buf,NULL);

  /* Should be an end bracket */
  token = VDxmlGetToken(info,buf);
  VDASSERTW(token == VDXML_TOKEN_END_BRACKET);

 wrapup:
  return;
}

/* ----------------------------------------
 * Main recursive parser routine
 */
static void xmlParseStream(TVDxmlParseInfo *info, IGRchar *buf)
{
  VDASSERT_FN("xmlParseStream");
  
  IGRint  token;

  /* Get the next token */
  token = VDxmlGetToken(info,buf);
  
  switch(token) {

  case VDXML_TOKEN_BEG_BRACKET:
    xmlParseBegBracket(info,buf);
    if (info->stopParser) goto wrapup;
    break;

  case VDXML_TOKEN_SLASH_BRACKET:
    xmlParseSlashBracket(info,buf);
    if (info->stopParser) goto wrapup;
    break;

  case VDXML_TOKEN_COMMENT:
    xmlParseComment(info,buf);
    if (info->stopParser) goto wrapup;
    break;

  case VDXML_TOKEN_VERSION:
    xmlParseVersion(info,buf);
    if (info->stopParser) goto wrapup;
    break;

  case VDXML_TOKEN_EOF:
    return;

  default:
    VDASSERTW(0);
  }

  /* Recurse to next object? */
  xmlParseStream(info,buf);

 wrapup:
  return;
  
}

/* ----------------------------------------
 * Parses the already opened io stream
 * The caller needs to close the input stream
 *
 * Dynamically alloc the working buffer
 * Make it big enough for very long attributes and
 * Included data
 */
static void xmlParseIO(TVDxmlParseInfo *info,
		       IGRstat (*callback)(TVDxmlParseInfo *info))
{
  VDASSERT_FN("xmlParseIO");
  
  IGRstat sts;
  
  TVDxmlParseInfoCallback parseInfoCallback;
  TVDxmlStreamInfo *io = &info->io;
  
  IGRchar *buf = NULL;

  // Alloc buf
  buf = malloc(100000);
  VDASSERTW(buf);
  
  /* All attempts at placing the callback pointer directly in the
   * parseInfo structure failed with at some sort of warning.
   * Give up for now and just use another structure
   */
  if (callback) {  
    parseInfoCallback.parseCallback = callback;
    info->parseInfoCallback = (struct TVDxmlParseInfoCallback*)&parseInfoCallback;
  }
  
  /* Tell the document handler */
  xmlParseCallback(info,VDXML_TYPE_BEG_DOCUMENT,NULL,io->fileName);
  if (info->stopParser) goto wrapup;
    
  /* Parse It */
  xmlParseStream(info,buf);
  if (info->stopParser) goto wrapup;

  /* Tell document handler */
  xmlParseCallback(info,VDXML_TYPE_END_DOCUMENT,NULL,io->fileName);
  if (info->stopParser) goto wrapup;
  
wrapup:

  // Be sure pointer is not used
  if (info) info->parseInfoCallback = NULL;
  if (buf) free(buf);
  
  return ;
}


/* -----------------------------------------------
 * Parse a buffer
 */
IGRstat VDxmlParseBuf(TVDxmlParseInfo *info,
		      IGRchar         *bufName,
		      IGRchar         *bufData,
		      IGRint           bufMax,
		      IGRstat (*callback)(TVDxmlParseInfo *info),
		      void            *data)
{
  VDASSERT_FN("VDxmlParseBuf");
  
  IGRstat retFlag = 1;
  TVDxmlStreamInfo *io;
  
  IGRchar *p;
  
  IGRchar bufx[256];
  IGRint  i;
  IGRchar *px;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(bufData);
  io = &info->io;
  
  // Clear it
  memset(info,0,sizeof(TVDxmlParseInfo));
  info->eleMax = VDXML_ELE_STACK_MAX;
  info->data   = data;
  
  *bufx = 0;
  
  // Setup the buffer
  io->buf = bufData;

  if (bufMax > 0) io->bufMax = bufMax;
  else            io->bufMax = strlen(bufData);
  
  if (bufName) strcpy(io->fileName,bufName);
  else         strcpy(io->fileName,"BUFFER");
  
  /* ---------------------------------------------
   * Until some upstream code gets fixed
   * Gaurd against control codes
   */
  for(p = bufData; *p; p++) {
    if (*p < ' ') {
      if (*p != '\n') {
	*p = ' ';
	
	// Debug out the control code
#if 0
	if (*bufx == 0) {	  
	  if (p - bufData > 100) px = p - 100;
	  else                   px = bufData;
	  for(i = 0; (i < 120) && (*px); i++,px++) {
	    bufx[i] = *px;
	  }
	  bufx[i] = 0;
	  printf("XML %s\n",bufx);
	}
#endif
      }
    }
  }
  
  // Doit
  xmlParseIO(info,callback);

wrapup:  
  return retFlag;
}

/* ----------------------------------------
 * Parse a file
 */
IGRstat VDxmlParseFile(TVDxmlParseInfo *info,
		       IGRchar         *fileName,
		       IGRstat (*callback)(TVDxmlParseInfo *info),
		       void            *data)
{
  VDASSERT_FN("VDxmlParseFile");
  
  IGRstat retFlag = 1;
  
  TVDxmlStreamInfo *io;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(fileName && *fileName);
  io = &info->io;
  
  // Clear it
  memset(info,0,sizeof(TVDxmlParseInfo));
  info->eleMax = VDXML_ELE_STACK_MAX;
  info->data   = data;
  
  /* Open it */
  strcpy(io->fileName,fileName);
  io->file = fopen(io->fileName,"rb");
  if (io->file == NULL) {
    printf("Could not open %s for xml parsing\n",io->fileName);
    goto wrapup;
  }

  // Doit
  xmlParseIO(info,callback);
  
wrapup:

  // Close up
  if ((info) && (io->file)) {
    fclose(io->file);
    io->file = NULL;
  }
  
  return retFlag;
}

