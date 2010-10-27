#ifndef xdom_include
#define xdom_include

#ifndef __XML_ERROR_H__
#include <libxml/xmlerror.h>
#endif

#ifndef __XML_MEMORY_H__
#include <libxml/xmlmemory.h>
#endif

#ifndef __XML_PARSER_H__
#include <libxml/parser.h>
#endif

/* -----------------------------------------------
 * Low level interface to xdom routines
 */
#define XDOM_OSNUM       9080
#define XDOM_STYLE_OSNUM 9081

extern xmlNodePtr xdom_nodeid_get_node(TGRid *nodeID);
extern void       xdom_nodeid_set_node(TGRid *nodeID, xmlNodePtr node);
extern gboolean   xdom_nodeid_is_node (TGRid *nodeID);

extern void *xmlGetBinProp __((xmlNodePtr node, xmlChar *name));
extern void  xmlSetBinProp __((xmlNodePtr node, xmlChar *name, 
			       void *binData, void (*binFree)(void *data)));


#endif


