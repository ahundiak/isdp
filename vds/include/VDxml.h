/* $Id: VDxml.h,v 1.4 2001/04/12 14:02:32 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDxml.h
 *
 * Description: xml prototypes
 *
 * Dependencies: Designed to be included by stand alone c programs
 *               As well as regular isdp modules
 *
 * Revision History:
 *      $Log: VDxml.h,v $
 *      Revision 1.4  2001/04/12 14:02:32  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/20 15:18:31  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/10 16:24:28  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  2000/10/15  15:04:56  pinnacle
 * ah
 *
 * Revision 1.3  2000/01/10  21:07:36  pinnacle
 * ah
 *
 * Revision 1.1  1999/04/21  19:51:14  pinnacle
 * PDM XML
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/99  ah      Created
 * 07/26/99  ah      Added parser routines
 * 02/18/00  ah      Many changes and enhancements
 * 03/24/00  ah      Buffer Changes
 * 07/12/00  ah      Macro wrappers
 * 01/10/01  ah      sp merge
 * 04/06/01  ah      Rev 2 xml parser routines
 ***************************************************************************/

#ifndef VDxml_include
#define VDxml_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

// Note: tag type should probably be limited to 16
#define VDXML_ELE_STACK_MAX  64
#define VDXML_TAG_TYPE_LEN   40
#define VDXML_ATR_VALUE_LEN 128

typedef IGRchar TVDxmlTagType [VDXML_TAG_TYPE_LEN];
typedef IGRchar TVDxmlAtrValue[VDXML_ATR_VALUE_LEN];

typedef struct 
{
  IGRint type; // Document, object, attribute etc.
  TVDxmlTagType  eleType;
  TVDxmlTagType  atrType;
  TVDxmlAtrValue atrValue;
} TVDxmlEleInfo;

typedef struct 
{
  IGRint type; // Document, object, attribute etc.
  TVDxmlTagType  eleType;
  TVDxmlTagType  atrType;

  /* ---------------------------------------------
   * App program needs to be careful here as this could
   * be very large
   */
  IGRchar       *atrValue;
  
} TVDxml2EleInfo;

typedef struct 
{
  // File stuff
  IGRchar  fileName[256];
  IGRlong  filePos;
  FILE    *file;
  
  // String capability
  IGRchar *buf;
  IGRint   bufMax;   // Total buffer size
  IGRint   bufPos;   // Used by parser for last position
  IGRint   bufInc;   // Amount to increment buffer size by
  IGRint   bufIndex; // Next char position to read/write
  
} TVDxmlStreamInfo;

typedef struct 
{
  // Stream I/O
  TVDxmlStreamInfo io;

  // Stop the parsing
  IGRstat stopParser;
  IGRstat retFlag;
  
  // Stack of element types
  TVDxmlTagType  eleTypes[VDXML_ELE_STACK_MAX];
  IGRint         eleIndex;
  IGRint         eleMax;
  
  // Callback for SAX type interface
  struct TVDxmlParseInfoCallback *parseInfoCallback;
  
  // Current information
  TVDxmlEleInfo eleInfo;

  // Holds user data
  void *data;
  
} TVDxmlParseInfo;

typedef struct 
{
  // Stream I/O
  TVDxmlStreamInfo io;

  // Stop the parsing
  IGRstat stopParser;
  IGRstat retFlag;
  
  // Stack of element types
  TVDxmlTagType  eleTypes[VDXML_ELE_STACK_MAX];
  IGRint         eleIndex;
  IGRint         eleMax;
  
  // Callback for SAX type interface
  struct TVDxml2ParseInfoCallback *parseInfoCallback;
  
  // Current information
  TVDxml2EleInfo eleInfo;

  // Holds user data
  void *data;
  
} TVDxml2ParseInfo;

#ifndef VD_PPL
typedef struct 
{
  IGRstat  (*parseCallback)(TVDxmlParseInfo *parseInfo);  
} TVDxmlParseInfoCallback;
typedef struct 
{
  IGRstat  (*parseCallback)(TVDxml2ParseInfo *parseInfo);  
} TVDxml2ParseInfoCallback;
#endif

typedef struct {

  TVDxmlStreamInfo io;
    
  IGRint   indent;
  IGRint   closed;
  
} TVDxmlFileInfo;

typedef struct {
  int             cnt;
  int             max;
  TVDxmlFileInfo *info;
} TVDxmlFileInfos;

#define VDXML_TYPE_BEG_DOCUMENT      0x01
#define VDXML_TYPE_END_DOCUMENT      0x02
#define VDXML_TYPE_BEG_ELEMENT       0x03
#define VDXML_TYPE_END_ELEMENT_ATTRS 0x04
#define VDXML_TYPE_END_ELEMENT       0x05

#define VDXML_TYPE_ATTRIBUTE         0x06
#define VDXML_TYPE_COMMENT           0x07
#define VDXML_TYPE_CHARACTERS        0x08
#define VDXML_TYPE_VERSION           0x09

/* ---------------------------------------------
 * The parser interface
 */
extern IGRstat VDxmlParseFile
__((TVDxmlParseInfo *info,
    IGRchar         *fileName,
    IGRstat (*callback)(TVDxmlParseInfo *info),
    void            *user));

extern IGRstat VDxmlParseBuf
__((TVDxmlParseInfo *info,
    IGRchar         *bufName,
    IGRchar         *bufData,
    IGRint           bufMax,
    IGRstat (*callback)(TVDxmlParseInfo *info),
    void            *user));

extern IGRstat VDxmlParseGetParentEleType
__((TVDxmlParseInfo *info,
    IGRint           nth,
    TVDxmlTagType    type));

extern IGRstat VDxml2ParseFile
__((TVDxml2ParseInfo *info,
    IGRchar          *fileName,
    IGRstat (*callback)(TVDxml2ParseInfo *info),
    void             *user));

extern IGRstat VDxml2ParseBuf
__((TVDxml2ParseInfo *info,
    IGRchar          *bufName,
    IGRchar          *bufData,
    IGRint            bufMax,
    IGRstat (*callback)(TVDxml2ParseInfo *info),
    void             *user));

extern IGRstat VDxml2ParseGetParentEleType
__((TVDxml2ParseInfo *info,
    IGRint            nth,
    TVDxmlTagType     type));

/* ---------------------------------------------
 * Need to move!
 */
extern void VDstrupr __((IGRchar *str));
extern void VDstrlwr __((IGRchar *str));

/* -----------------------------------------------
 * Misc BS
 */
extern IGRstat VDxmlIsXMLFile
__((IGRchar         *fileName, 
    IGRchar         *docType,
    TVDxmlFileInfos *fileInfos));

extern IGRstat VDxmlFindXMLFilesInDir
__((IGRchar         *dirName, 
    IGRchar         *docType,
    TVDxmlFileInfos *fileInfos));

extern IGRstat VDxmlFindXMLFiles
__((IGRint           localFlag,
    IGRchar         *configPath,
    IGRchar         *docType,
    TVDxmlFileInfos *fileInfos));

extern IGRstat VDxmlGetNameValue
__((IGRchar *buf, 
    IGRchar *name, 
    IGRchar *value));

extern IGRstat VDxmlLoadBufferFromFile 
__((IGRchar *fileName, 
    IGRchar *buf));

extern IGRstat VDxmlSaveBufferToFile 
__((IGRchar *fileName, 
    IGRchar *buf));

 
/* -------------------------------------------
 * Output stuff
 */
extern IGRstat VDxmlOpenOutputFile  
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *fileName,
    IGRchar        *docType,
    IGRchar        *dtdName));

extern IGRstat VDxmlOpenOutputBuf
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *buf,
    IGRint          bufMax,
    IGRint          bufInc,
    IGRchar        *docType,
    IGRchar        *dtdName));

// -----------------------------------------------
extern IGRstat VDxmlOpenOutputStream  
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *fileName,    /* I - File or Buffer Stream */
    IGRchar        *docType,
    IGRchar        *dtdName,
    IGRchar        *buf,         /* IO - Optional pre allocated buffer */
    IGRint          bufMax,
    IGRint          bufInc,
    IGRint          stripColons,
    IGRdouble       version,
    IGRint          standAlone));

#ifndef c_ONLY
#omdef vdxml$OpenOutputStream(info,
			      fileName = NULL,
			      docType  = NULL,
			      dtdName  = NULL,
			      buf      = NULL,
			      bufMax   = 0,
			      bufInc   = 0,
			      stripColons = 0,
			      version     = 1.0,
			      standAlone  = 1)

VDxmlOpenOutputStream((info),
		      (fileName),
		      (docType),(dtdName),
		      (buf),(bufMax),(bufInc),
		      (stripColons),
		      (version),(standAlone))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlCloseOutputFile 
__((TVDxmlFileInfo *fileInfo));

extern IGRstat VDxmlCloseOutputStream 
__((TVDxmlFileInfo *fileInfo));

#ifndef c_ONLY
#omdef vdxml$CloseOutputStream(info)
VDxmlCloseOutputStream((info))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlGetTextFileName
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *txtFileName));

#ifndef c_ONLY
#omdef vdxml$GetTextFileName(info,fileName)
VDxmlCloseOutputStream((info),(fileName))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteObjBeg
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *objType,
    IGRint          attrFlag,
    IGRint          returnFlag));

#ifndef c_ONLY
#omdef vdxml$WriteObjBeg(info,tag,attr=0,ret=0)
VDxmlWriteObjBeg((info),(tag),(attr),(ret))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteObjEnd
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *objType,
    IGRint          indentFlag));

#ifndef c_ONLY
#omdef vdxml$WriteObjEnd(info,tag,indent=0)
VDxmlWriteObjEnd((info),(tag),(indent))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteAtrEnd
__((TVDxmlFileInfo *fileInfo,
    IGRint          indentFlag,
    IGRint          returnFlag));

#ifndef c_ONLY
#omdef vdxml$WriteAtrEnd(info,indent=0,ret=0)
VDxmlWriteAtrEnd((info),(indent),(ret))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteAtrTxt 
__((TVDxmlFileInfo *file,
    IGRchar        *atrName,
    IGRchar        *atrValue,
    IGRint          indentFlag,
    IGRint          returnFlag));

#ifndef c_ONLY
#omdef vdxml$WriteAtrTxt(info,tag,value,indent=0,ret=0)
VDxmlWriteAtrTxt((info),(tag),(value),(indent),(ret))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteAtrDbl 
__((TVDxmlFileInfo *file,
    IGRchar        *atrName,
    IGRdouble       atrValue,
    IGRint          indentFlag,
    IGRint          returnFlag));

#ifndef c_ONLY
#omdef vdxml$WriteAtrDbl(info,tag,value,indent=0,ret=0)
VDxmlWriteAtrDbl((info),(tag),(value),(indent),(ret))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteAtrInt 
__((TVDxmlFileInfo *file,
    IGRchar        *atrName,
    IGRint          atrValue,
    IGRint          indentFlag,
    IGRint          returnFlag));

#ifndef c_ONLY
#omdef vdxml$WriteAtrInt(info,tag,value,indent=0,ret=0)
VDxmlWriteAtrInt((info),(tag),(value),(indent),(ret))
#endomdef
#endif

// -----------------------------------------------
extern IGRstat VDxmlWriteIndent
__((TVDxmlFileInfo *fileInfo));

#ifndef c_ONLY
#omdef vdxml$WriteIndent(info)
VDxmlWriteIndent((info))
#endomdef
#endif

/* -----------------------------------------------
 * Private stream parsing routines
 * VDxmlParseS.c
 * Might want to use for another parsing project.
 */
extern IGRint VDxmlGetStreamChar    __((TVDxmlStreamInfo *io));
extern IGRint VDxmlGetChar          __((TVDxmlParseInfo  *info));
extern IGRint VDxmlPushChar         __((TVDxmlParseInfo  *info));
extern IGRint VDxmlPeekChar         __((TVDxmlParseInfo  *info));
extern IGRint VDxmlGetToken         __((TVDxmlParseInfo  *info, IGRchar *buf));
extern IGRint VDxmlIsCharWhiteSpace __((IGRint c));
extern IGRint VDxmlIsCharTag        __((IGRint c));

extern IGRint VDxml2GetStreamChar    __((TVDxmlStreamInfo *io));
extern IGRint VDxml2GetChar          __((TVDxml2ParseInfo  *info));
extern IGRint VDxml2PushChar         __((TVDxml2ParseInfo  *info));
extern IGRint VDxml2PeekChar         __((TVDxml2ParseInfo  *info));
extern IGRint VDxml2GetToken         __((TVDxml2ParseInfo  *info, IGRchar *buf));
extern IGRint VDxml2IsCharWhiteSpace __((IGRint c));
extern IGRint VDxml2IsCharTag        __((IGRint c));

#define VDXML_TOKEN_EOF           EOF
#define VDXML_TOKEN_BEG_BRACKET   0x01
#define VDXML_TOKEN_END_BRACKET   0x02
#define VDXML_TOKEN_SLASH_BRACKET 0x03
#define VDXML_TOKEN_COMMENT       0x04
#define VDXML_TOKEN_TAG           0x05
#define VDXML_TOKEN_EQUALS        0x06
#define VDXML_TOKEN_QUOTED_STRING 0x07
#define VDXML_TOKEN_TEXT          0x08
#define VDXML_TOKEN_VERSION       0x09

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif

