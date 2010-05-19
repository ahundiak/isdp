/* $Id: cdom_node.c,v 1.3 2001/08/15 23:54:04 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdcdom/cdom_node.c
 *
 * Description: cdom node stuff
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: cdom_node.c,v $
 *      Revision 1.3  2001/08/15 23:54:04  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/07 18:56:46  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/02 15:07:25  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/02/01  ah      Created
 * 08/15/01  ah      Explictly assert if node is not created
 *                   So there is no need for calling programs to check return codes
 ***************************************************************************/

/* -----------------------------------------------
 * Using the gnode as a template, implement the low level
 * cdom_node stuff mainly for efficient memory management
 */

/* GLIB - Library of useful routines for C programming
 * Copyright (C) 1995-1997  Peter Mattis, Spencer Kimball and Josh MacDonald
 *
 * GNode: N-way tree implementation.
 * Copyright (C) 1998 Tim Janik
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * Modified by the GLib Team and others 1997-2000.  See the AUTHORS
 * file for a list of people on the GLib Team.  See the ChangeLog
 * files for a list of changes.  These files are distributed with
 * GLib at ftp://ftp.gtk.org/pub/gtk/. 
 */

/* 
 * MT safe
 */

#include "VDtypedefc.h"
#include "glib.h"
#include "cdom.h"

#define	G_ALLOCATOR_CDOM_NODE	(6)

struct _GAllocator /* from gmem.c */
{
  gchar         *name;
  guint16        n_preallocs;
  guint          is_unused : 1;
  guint          type : 4;
  GAllocator    *last;
  GMemChunk     *mem_chunk;
  CDOMnode      *free_nodes; /* implementation specific */
};

G_LOCK_DEFINE_STATIC (current_allocator);
static GAllocator *current_allocator = NULL;


/* HOLDS: current_allocator_lock */
static void
cdom_node_validate_allocator (GAllocator *allocator)
{
  g_return_if_fail (allocator != NULL);
  g_return_if_fail (allocator->is_unused == TRUE);

  if (allocator->type != G_ALLOCATOR_CDOM_NODE)
    {
      allocator->type = G_ALLOCATOR_CDOM_NODE;
      if (allocator->mem_chunk)
	{
	  g_mem_chunk_destroy (allocator->mem_chunk);
	  allocator->mem_chunk = NULL;
	}
    }

  if (!allocator->mem_chunk)
    {
      allocator->mem_chunk = g_mem_chunk_new (allocator->name,
					      sizeof (CDOMnode),
					      sizeof (CDOMnode) * allocator->n_preallocs,
					      G_ALLOC_ONLY);
      allocator->free_nodes = NULL;
    }

  allocator->is_unused = FALSE;
}

/* --- functions --- */
CDOMnode* cdom_node_new (gchar *name)
{
  CDOMnode *node = NULL;

  g_assert(name);
  
  G_LOCK (current_allocator);
  if (!current_allocator)
    {
       GAllocator *allocator = g_allocator_new ("CDOMLib default CDOMnode allocator",
						128);
       cdom_node_validate_allocator (allocator);
       allocator->last = NULL;
       current_allocator = allocator;
    }
  if (!current_allocator->free_nodes) {
    node = g_chunk_new0(CDOMnode, current_allocator->mem_chunk);    
  }
  
  else
    {
      node = current_allocator->free_nodes;
      current_allocator->free_nodes = (CDOMnode*)node->gnode.next;
      node->gnode.next = NULL;
    }
  G_UNLOCK (current_allocator);

  g_assert(node);
  
  if (!node->name) node->name = g_string_new(name);
  else             g_string_assign(node->name,name);
  
  
  return node;
}

/* -----------------------------------------------
 * Free a single node without worrying about kids and stuff
 * Keep the next pointer intact
 *
 * What to do about the name?  Could free it or could keep it around
 * for the next time the node is used
 *
 * Go ahead and free any content for now
 */
static void cdom_node_free (CDOMnode *node)
{
  // The GNode pointers
  node->gnode.data = NULL;
  node->gnode.prev = NULL;
  node->gnode.parent = NULL;
  node->gnode.children = NULL;

  // printf("Free %s\n",node->name->str);
  
  // The name
  // g_string_free(node->name,1);
  // node->name = NULL;

  // The content
  if (node->content) {
    g_string_free(node->content,1);
    node->content = NULL;
  }
  
  // The attributes
  cdom_attrs_free(node->attrs);
  node->attrs = NULL;

}

/* -----------------------------------------------
 * Frees a node and all it's children
 */
static void cdom_nodes_free (CDOMnode *node)
{
  CDOMnode *parent;

  parent = node;
  while (1)
    {
      if (parent->gnode.children) {
	cdom_nodes_free ((CDOMnode*)parent->gnode.children);
      }
      cdom_node_free(parent);

      if (parent->gnode.next)
	parent = (CDOMnode*)parent->gnode.next;
      else
	break;
    }
  
  G_LOCK (current_allocator);
  parent->gnode.next = (GNode*)current_allocator->free_nodes;
  current_allocator->free_nodes = node;
  G_UNLOCK (current_allocator);
}

/* -----------------------------------------------
 * Unlink a node from the tree then free it and
 * all it's children
 */
void cdom_node_destroy (CDOMnode *root)
{
  // printf(">>> cdom_node_destroy\n");
  
  g_return_if_fail (root != NULL);
  
  if (!G_NODE_IS_ROOT(root)) {  
    //printf("    about to  cdom_node_unlink\n");
    cdom_node_unlink(root);
    //printf("    back from cdom_node_unlink\n");
  }
  
  cdom_nodes_free (root);
}

/* -----------------------------------------------
 * Convert objid into a node
 */
CDOMnode *cdom_nodeid_get_node(TGRid *nodeID)
{
  CDOMnode *node = NULL;

  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if (nodeID->osnum != CDOM_OSNUM) goto wrapup;
  
  // Convert it
  node = GUINT_TO_POINTER(nodeID->objid);

 wrapup:
  return node;
}
void cdom_nodeid_set_node(TGRid *nodeID, CDOMnode *node)
{
  // Arg check
  if (nodeID == NULL) goto wrapup;
  nodeID->osnum = CDOM_OSNUM;

  // Convert it
  if (node) nodeID->objid = GPOINTER_TO_UINT(node);
  else      nodeID->objid = NULL_OBJID;
  
 wrapup:
  return;
  
}
gboolean cdom_nodeid_is_node(TGRid *nodeID)
{
  gboolean retFlag = 0;
  
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if (nodeID->osnum != CDOM_OSNUM) goto wrapup;

  retFlag = 1;
  
 wrapup:
  return retFlag;
}
