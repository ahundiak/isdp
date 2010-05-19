/* $Id: VDxml2ParseS.c,v 1.1 2001/04/12 14:04:45 ahundiak Exp $  */

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
 *      $Log: VDxml2ParseS.c,v $
 *      Revision 1.1  2001/04/12 14:04:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/01  ah      Creation, created from VDxmpParse.C
 * 04/06/01  ah      Parser V2
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"

VDASSERT_FFN("VDxml2ParseS.c");

/* --------------------------------------
 * Wrapper to read character from stream
 * The NULL at the end of a buf string is
 * returned as EOF
 */
IGRint VDxml2GetStreamChar(TVDxmlStreamInfo *io)
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
IGRint VDxml2GetChar(TVDxml2ParseInfo *info)
{
  IGRint  c = 0;
  IGRchar buf[256];
  IGRchar *p;

  TVDxmlStreamInfo *io = &info->io;

  IGRint bufIndex;
  
  /* Save file position */
  if (io->file) io->filePos = ftell(io->file);
  if (io->buf)  io->bufPos  = io->bufIndex;
  
  /* Get the character */
  c = VDxml2GetStreamChar(io);
  
  // Adjust
  if (c == 0) c = EOF;
  
  /* Might be an escaped character */
  if (c != '&') return c;
  
  /* Need to expand the string */
  p = buf;
  while((c != ';') && (c != EOF) && ((p - buf) < 8)) {
    c = VDxml2GetStreamChar(io);
    *p++ = c;
  }
  *p = 0;
  
  /* Translate */
  if (!strcmp(buf,"lt;"))   return -(c = '<');
  if (!strcmp(buf,"gt;"))   return -(c = '>');
  if (!strcmp(buf,"quot;")) return -(c = '"');
  if (!strcmp(buf,"amp;"))  return -(c = '&');

  /* ---------------------------------------------
   * 11 April 2001 
   * Getting some individual & in the spades.xml file
   * need to review how this file is being generated
   * It has it's own routine so maybe it's easy to adjust
   *
   * What about other characters?
   *
   * For now, just go back to the & and pretend it's an &&
   */
  VDxml2PushChar(info);
  c = VDxml2GetStreamChar(io);  
  return c;
}

/* --------------------------------------
 * Wrap the returning of a char to the
 * input stream
 */
IGRint VDxml2PushChar(TVDxml2ParseInfo *info)
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
IGRint VDxml2PeekChar(TVDxml2ParseInfo *info)
{
  IGRint c;

  c = VDxml2GetChar(info);
  VDxml2PushChar(info);
  return c;
}

/* --------------------------------------
 * True if the character is a whitespace
 */
IGRint VDxml2IsCharWhiteSpace(IGRint c)
{
  if (c == EOF) return 0;
  if (c < 0)    return 0;  /* Escaped characters */
  
  if (c <= ' ') return 1;
  return 0;
}

/* --------------------------------------
 * Character can be in a identifier
 */
IGRint VDxml2IsCharTag(IGRint c)
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
IGRint VDxml2GetToken(TVDxml2ParseInfo *info, IGRchar *buf)
{
  IGRint   c,d;
  IGRchar *p;

  /* Skip any white space */
  for(c = VDxml2GetChar(info); 
      VDxml2IsCharWhiteSpace(c); 
      c = VDxml2GetChar(info));

  switch(c) {

  case EOF: return VDXML_TOKEN_EOF;
  case '=': return VDXML_TOKEN_EQUALS;
  case '>': return VDXML_TOKEN_END_BRACKET;

  /* Could be part of a pair */
  case '<':

    d = VDxml2PeekChar(info);
    switch(d) {

    case '!': 
      VDxml2GetChar(info);
      return VDXML_TOKEN_COMMENT;

    case '/':
      VDxml2GetChar(info);
      return VDXML_TOKEN_SLASH_BRACKET;
    

    case '?':
      VDxml2GetChar(info);
      return VDXML_TOKEN_VERSION;
      
    }
  
    return VDXML_TOKEN_BEG_BRACKET;
  }

  /* Might be a identifier */
  if (VDxml2IsCharTag(c)) {

     p = buf;
    *p++ = c;
    for(c = VDxml2GetChar(info); VDxml2IsCharTag(c); c = VDxml2GetChar(info)) {
      *p++ = c;
    }
    VDxml2PushChar(info);
    *p = 0;

    return VDXML_TOKEN_TAG;

  }

  /* Might be a quoted string */
  if (c == '"') {
    p = buf;
    for(c = VDxml2GetChar(info); 
       (c != EOF) && (c != '"'); 
        c = VDxml2GetChar(info)) {
      *p++ = abs(c);     /* Deals with escaped characters */
    }
    *p = 0;
    return VDXML_TOKEN_QUOTED_STRING;
  }

  /* Give up */
  return EOF;
}
