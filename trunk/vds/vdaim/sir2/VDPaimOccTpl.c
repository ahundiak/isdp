/* $Id: VDPaimOccTpl.c,v 1.1.2.3 2004/02/27 15:00:07 ahundiak Exp $  */

/***************************************************************************
 * I/AIM
 *
 * File:        src/sir2/VDPaimOccTpl.c
 *
 * Description:	Occurence Template Sub System
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDPaimOccTpl.c,v $
 * Revision 1.1.2.3  2004/02/27 15:00:07  ahundiak
 * ah
 *
 * Revision 1.1.2.2  2003/06/05 16:45:17  ahundiak
 * ah
 *
 * Revision 1.1.2.1  2003/06/04 18:13:42  ahundiak
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/04/03  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDdom2.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

VDASSERT_FFN("VDPaimOccTpl.c");

typedef struct 
{
  domNode occTemplatesNode;
} Tinfo;

static Tinfo *s_info;

/* ----------------------------------------------
 * Get the cached list of nodes
 * Initializing if required
 */
static domNode getOccTemplatesNode()
{
  char path[128];

  if (s_info == NULL)
  {
    s_info = (Tinfo *)calloc(1,sizeof(Tinfo));
  }
  if (s_info->occTemplatesNode == NULL)
  {
    VDsysFindFile("config/xml","SirValidate.xml",path);
    if (*path == 0)
    {
      printf("*** Unable to find SirValidate.xml\n");
      return NULL;
    }
    s_info->occTemplatesNode = domCreateDocFromFile(path);
  }
  return s_info->occTemplatesNode;
}

/* ----------------------------------------------
 * Get a node of interest
 */
domNode VDPaimGetOccTemplateNode(char *name)
{
  domNode occTemplatesNode = getOccTemplatesNode();
  domNode occTemplateNode = NULL;
  int i;
  char buf[128];

  if (occTemplatesNode == NULL) return NULL;

  for(i = 0; occTemplateNode = domGetNthChildNode(occTemplatesNode,i); i++)
  {
    domGetNodeProp(occTemplateNode,VDP_XML_ATTR_ASIR_CLASS_NAME,buf);
    if (!strcmp(name,buf)) return occTemplateNode;
  }
  return NULL;
}

