/* $Id: xdom_xslt.c,v 1.1 2001/09/20 14:36:27 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxdom/xdom_xslt.c
 *
 * Description: stylesheet routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: xdom_xslt.c,v $
 *      Revision 1.1  2001/09/20 14:36:27  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/20/01  ah      Created
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"

#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>

VDASSERT_FFN("xdom_xslt.c");

/* -----------------------------------------------
 * Load a stylesheet from a file
 */
void VDxdomCreateStyleSheetFromFile(IGRchar *fileName, TGRid *styleSheetID)
{
  VDASSERT_FN("VDxdomCreateStyleSheetFromFile");
  
  xsltStylesheetPtr cur = NULL;  

  // Arg check
  VDASSERTW(styleSheetID); styleSheetID->objid = NULL_OBJID;
  VDASSERTW(fileName && *fileName);

  // Load it
  cur = xsltParseStylesheetFile((const xmlChar *)fileName);
  if (cur == NULL) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load stylesheet %s",fileName);
    goto wrapup;
  }

  // Convert to GRid
  styleSheetID->osnum = XDOM_STYLE_OSNUM;
  styleSheetID->objid = GPOINTER_TO_UINT(cur);
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Delete a stylesheet
 */
void VDxdomDeleteStyleSheet(TGRid *styleSheetID)
{
  VDASSERT_FN("VDxdomDeleteStyleSheet");
  
  xsltStylesheetPtr cur = NULL;  

  // Arg check
  VDASSERTW(styleSheetID);
  if (styleSheetID->objid == NULL_OBJID) goto wrapup;
  if (styleSheetID->objid == 0)          goto wrapup;
  VDASSERTW(styleSheetID->osnum == XDOM_STYLE_OSNUM);
  
  cur = GUINT_TO_POINTER(styleSheetID->objid);
  
  xsltFreeStylesheet(cur);

 wrapup:
  return;
}
/* -----------------------------------------------
 * Apply a stylesheet
 */
void VDxdomApplyStyleSheet(TGRid *styleSheetID, TGRid *treeID, IGRchar *params[], TGRid *resID)
{
  VDASSERT_FN("VDxdomApplyStyleSheet");

  xsltStylesheetPtr style = NULL;
  xmlNodePtr tree;
  xmlNodePtr root;
  xmlDocPtr  res;
  
  // Arg check
  VDASSERTW(resID); resID->objid = NULL_OBJID;
  VDASSERTW(styleSheetID && styleSheetID->osnum == XDOM_STYLE_OSNUM);
  VDASSERTW(treeID       &&       treeID->osnum == XDOM_OSNUM);

  style = GUINT_TO_POINTER(styleSheetID->objid);
  tree  = GUINT_TO_POINTER(      treeID->objid);
  VDASSERTW(style);
  VDASSERTW(tree);
  
  // Apply it
  res = xsltApplyStylesheet(style, tree->doc, (const IGRchar **)params);
  VDASSERTW(res);
  root = xmlDocGetRootElement(res);
  VDASSERTW(root);
  
  resID->osnum = XDOM_OSNUM;
  resID->objid = GPOINTER_TO_UINT(root);

 wrapup:
  return;
}

