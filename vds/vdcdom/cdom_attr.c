/* $Id: cdom_attr.c,v 1.3 2001/08/15 23:54:03 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdcdom/cdom_attr.c
 *
 * Description: cdom attr stuff
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: cdom_attr.c,v $
 *      Revision 1.3  2001/08/15 23:54:03  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:45:38  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/02 15:07:25  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/02/01  ah      Created
 * 08/15/01  ah      Explictly assert if attr is not created
 *                   So there is no need for calling programs to check return codes
 ***************************************************************************/

#include "VDtypedefc.h"

#include "glib.h"
#include "cdom.h"

#define	G_ALLOCATOR_CDOM_ATTR	(7)

struct _GAllocator /* from gmem.c */
{
  gchar         *name;
  guint16        n_preallocs;
  guint          is_unused : 1;
  guint          type : 4;
  GAllocator    *last;
  GMemChunk     *mem_chunk;
  CDOMattr      *free_attrs; /* implementation specific */
};

G_LOCK_DEFINE_STATIC (current_allocator);
static GAllocator *current_allocator = NULL;

/* HOLDS: current_allocator_lock */
static void cdom_attr_validate_allocator (GAllocator *allocator)
{
  g_return_if_fail (allocator != NULL);
  g_return_if_fail (allocator->is_unused == TRUE);

  if (allocator->type != G_ALLOCATOR_CDOM_ATTR)
    {
      allocator->type = G_ALLOCATOR_CDOM_ATTR;
      if (allocator->mem_chunk)
	{
	  g_mem_chunk_destroy (allocator->mem_chunk);
	  allocator->mem_chunk = NULL;
	}
    }

  if (!allocator->mem_chunk)
    {
      allocator->mem_chunk = g_mem_chunk_new (allocator->name,
					      sizeof (CDOMattr),
					      sizeof (CDOMattr) * allocator->n_preallocs,
					      G_ALLOC_ONLY);
      allocator->free_attrs = NULL;
    }

  allocator->is_unused = FALSE;
}

/* --- functions --- */
CDOMattr* cdom_attr_new (CDOMattr *attrs, gchar *name, gchar *value)
{
  CDOMattr *attr;
  CDOMattr *attrx;

  g_assert(name);
  g_assert(value);
  
  G_LOCK (current_allocator);
  if (!current_allocator)
    {
       GAllocator *allocator = g_allocator_new ("CDOMLib default CDOMattr allocator",
						128);
       cdom_attr_validate_allocator (allocator);
       allocator->last = NULL;
       current_allocator = allocator;
    }
  if (!current_allocator->free_attrs) {
    attr = g_chunk_new0(CDOMattr, current_allocator->mem_chunk);    
  }
  else
    {
      attr = current_allocator->free_attrs;
      current_allocator->free_attrs = attr->next;
      attr->next = NULL;
    }
  G_UNLOCK (current_allocator);

  g_assert(attr);
  
  if (!attr->name) attr->name = g_string_new(name);
  else             g_string_assign(attr->name,name);

  if (!attr->txt) attr->txt = g_string_new(value);
  else            g_string_assign(attr->txt,value);

  if (attrs == NULL) return attr;
  
  // Append to list
  for(attrx = attrs; attrx->next; attrx = attrx->next);
  attrx->next = attr;
  
  return attrs;
}

/* -----------------------------------------------
 * Free a single attr without worrying about the list
 * Keep the next pointer intact
 *
 */
static void cdom_attr_free (CDOMattr *attr)
{
  /* -------------------------------
   * Take care of the bin data
   * keep the actual g_string structure for possible later reuse
   * but free any data
   */
  if (attr->bin) {
    free(attr->bin);
    attr->bin = NULL;
  }
#if 0
  if (attr->bin) {
    g_free(attr->bin->str);
    attr->bin->str = NULL;
    attr->bin->len = 0;
  }
#endif 
}

/* -----------------------------------------------
 * Frees a node and all it's siblings
 */
void cdom_attrs_free (CDOMattr *attr)
{
  CDOMattr *attrx;
  
  while(attr) {

    attrx = attr->next;
    cdom_attr_free(attr);
    
    G_LOCK (current_allocator);
    attr->next = current_allocator->free_attrs;
    current_allocator->free_attrs = attr;
    G_UNLOCK (current_allocator);

    attr = attrx;
  }
}

/* ------------------------------------------------
 * Find an attribute by name
 */
CDOMattr *cdom_attr_get_by_name(CDOMattr *attrs, gchar *name)
{
  CDOMattr *attr = NULL;
  
  // Arg check
  if (attrs == NULL) goto wrapup;
  if (name  == NULL) goto wrapup;
  
  // Cycle through */
  for(attr = attrs; attr; attr = attr->next) {
    if (!strcmp(attr->name->str,name)) goto wrapup;
  }
  
 wrapup:
  return attr;
}

/* -----------------------------------------------
 * Get an attribute for a nod
 */
CDOMattr *cdom_nodeid_get_attr_by_name(TGRid *nodeID, gchar *name)
{
  CDOMnode *node;
  CDOMattr *attr = NULL;

  // Need the node
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Get the atribute
  attr = cdom_attr_get_by_name(node->attrs,name);
  
 wrapup:
  return attr;
}

  



