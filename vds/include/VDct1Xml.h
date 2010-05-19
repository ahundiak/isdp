/* $Id: VDct1Xml.h,v 1.2 2001/03/12 20:36:04 jdsauby Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDct1Xml.h
 *
 * Description: XML Related Tree Routines
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDct1Xml.h,v $
 *	Revision 1.2  2001/03/12 20:36:04  jdsauby
 *	Cleaned out unnecessary functions from vdct1/set
 *	
 *	Revision 1.1  2001/01/09 22:17:57  art
 *	ah
 *	
 * Revision 1.1  2000/07/17  18:57:22  pinnacle
 * ah
 *
 *
 * History:
 * 07/11/00 ah  Created
 *
 * -------------------------------------------------------------------*/
#ifndef VDct1Xml_include
#define VDct1Xml_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

#if 0
extern IGRstat VDct1WriteXmlNode  __((TVDxmlFileInfo *fileInfo, TGRid *nodeID));
#endif

#if 0
extern IGRstat VDct1GetXmlNodeBuf __((TGRid *nodeID, IGRchar **xmlBuf));
#endif

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif




