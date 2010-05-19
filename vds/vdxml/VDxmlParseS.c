/* $Id: VDxmlParseS.c,v 1.1 2001/02/20 15:19:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDxmlParseS.C
 *
 * Description: Character Stream Functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlParseS.c,v $
 *      Revision 1.1  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/01  ah      Creation, created from VDxmpParse.C
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"

VDASSERT_FFN("VDxmlParseS.c");

/* --------------------------------------
 * Wrapper to read character from stream
 * The NULL at the end of a buf string is
 * returned as EOF
 */
IGRint VDxmlGetStreamChar(TVDxmlStreamInfo *io)
{
  IGRint c = EOF;
  
  if (io->file) c = fgetc(io->file);
  if (io->buf) {
    if (io->bufIndex >= io->bufMax) c = EOF;
    else {
      c = io->buf[io->bufIndex];
      io->bufIndex++;
      if (c == 0) c = EOF;
    }
  }
  return c;
}

/* --------------------------------------
 * Wrap the get character to allow
 * handling escaped characters later
 */
IGRint VDxmlGetChar(TVDxmlParseInfo *info)
{
  IGRint  c = 0;
  IGRchar buf[256];
  IGRchar *p;

  TVDxmlStreamInfo *io = &info->io;
  
  /* Save file position */
  if (io->file) io->filePos = ftell(io->file);
  if (io->buf)  io->bufPos  = io->bufIndex;
  
  /* Get the character */
  c = VDxmlGetStreamChar(io);
  
  // Adjust
  if (c == 0) c = EOF;
  
  /* Might be an escaped character */
  if (c != '&') return c;
  
  /* Need to expand the string */
  p = buf;
  while((c != ';') && (c != EOF)) {
    c = VDxmlGetStreamChar(io);
    *p++ = c;
  }
  *p = 0;
  
  /* Translate */
  if (!strcmp(buf,"lt;"))   return -(c = '<');
  if (!strcmp(buf,"gt;"))   return -(c = '>');
  if (!strcmp(buf,"quot;")) return -(c = '"');
  if (!strcmp(buf,"amp;"))  return -(c = '&');

  /* Problem */
  printf("Parsing problem, unknown escaped string '%s'\n",buf);
  c = '&';
  return c;
}

/* --------------------------------------
 * Wrap the returning of a char to the
 * input stream
 */
IGRint VDxmlPushChar(TVDxmlParseInfo *info)
{
  IGRstat retFlag = 1;
  TVDxmlStreamInfo *io = &info->io;
  
  if (io->file) fseek(io->file,io->filePos,SEEK_SET);
  if (io->buf)  io->bufIndex = io->bufPos;
  return retFlag;
  
}

/* --------------------------------------
 * Peeks ahead in the input stream
 */
IGRint VDxmlPeekChar(TVDxmlParseInfo *info)
{
  IGRint c;

  c = VDxmlGetChar(info);
  VDxmlPushChar(info);
  return c;
}

/* --------------------------------------
 * True if the character is a whitespace
 */
IGRint VDxmlIsCharWhiteSpace(IGRint c)
{
  if (c == EOF) return 0;
  if (c < 0)    return 0;  /* Escaped characters */
  
  if (c <= ' ') return 1;
  return 0;
}

/* --------------------------------------
 * Character can be in a identifier
 */
IGRint VDxmlIsCharTag(IGRint c)
{
  if ((c >= 'A') && (c <= 'Z')) return 1;
  if ((c >= 'a') && (c <= 'z')) return 1;
  if ((c >= '0') && (c <= '9')) return 1;
  if (c == '_') return 1;
  if (c == ':') return 1;
  return 0;
}

/* ----------------------------------------
 * Returns a token which is a small
 * unit of usefull data from the input
 * stream
 */
IGRint VDxmlGetToken(TVDxmlParseInfo *info, IGRchar *buf)
{
  IGRint   c,d;
  IGRchar *p;

  /* Skip any white space */
  for(c = VDxmlGetChar(info); 
      VDxmlIsCharWhiteSpace(c); 
      c = VDxmlGetChar(info));

  switch(c) {

  case EOF: return VDXML_TOKEN_EOF;
  case '=': return VDXML_TOKEN_EQUALS;
  case '>': return VDXML_TOKEN_END_BRACKET;

  /* Could be part of a pair */
  case '<':

    d = VDxmlPeekChar(info);
    switch(d) {

    case '!': 
      VDxmlGetChar(info);
      return VDXML_TOKEN_COMMENT;

    case '/':
      VDxmlGetChar(info);
      return VDXML_TOKEN_SLASH_BRACKET;
    

    case '?':
      VDxmlGetChar(info);
      return VDXML_TOKEN_VERSION;
      
    }
  
    return VDXML_TOKEN_BEG_BRACKET;
  }

  /* Might be a identifier */
  if (VDxmlIsCharTag(c)) {

     p = buf;
    *p++ = c;
    for(c = VDxmlGetChar(info); VDxmlIsCharTag(c); c = VDxmlGetChar(info)) {
      *p++ = c;
    }
    VDxmlPushChar(info);
    *p = 0;

    return VDXML_TOKEN_TAG;

  }

  /* Might be a quoted string */
  if (c == '"') {
    p = buf;
    for(c = VDxmlGetChar(info); 
       (c != EOF) && (c != '"'); 
        c = VDxmlGetChar(info)) {
      *p++ = abs(c);     /* Deals with escaped characters */
    }
    *p = 0;
    return VDXML_TOKEN_QUOTED_STRING;
  }

  /* Give up */
  return EOF;
}
