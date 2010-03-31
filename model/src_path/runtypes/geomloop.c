#include <stdio.h>
#include <malloc.h>
#include "bsvalues.h"
#include "bsgeom_cvsf.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWapi/linklist.h"
#include "PWapi/mdstptgm.h"


struct PWgeomloop *pwCreateGeomloop 
(
  struct PWgeomloop **p_loops
)
{
  return (struct PWgeomloop *) pwCreateNode ((char **) p_loops, 
                                         sizeof (struct PWgeomloop));
} 

PWboolean pwRemoveGeomloop
(
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_remove_node
)
{
  return pwRemoveNode ((char **)p_loops, (char *)p_remove_node);
}

void pwFreeGeomloop
(
  struct PWgeomloop *p_loops 
)
{
  struct PWgeomloop *p_node, *p_next_node;

  /*
   * for each node in the linked list, till the end of the list is reached
   */ 
  for( p_node = p_loops; p_node; p_node = p_next_node )
  { 
    p_next_node = p_node->p_next;

    /*
     * Free the data in PWcvregion_list structure.
     *      o Free the attrib dta on this node.
     */
    if (p_node->p_attrib) pwFreeAttribList(p_node->p_attrib);

    /*
     * Free the geometry.
     */
    if (p_node->free_edge)
    {
      (*(p_node->free_edge)) (&p_node->edge); 
    }
    else
    {
      switch (p_node->edge.datatype)
      {
        case PWcvdata_py2d :
          free (p_node->edge.data.py2d.p_pts);
          break;

        case PWcvdata_py : 
          free (p_node->edge.data.py.p_pts);
          break;

        case PWcvdata_bspcv :
          free (p_node->edge.data.p_bspcv);
          break;

        case PWcvdata_gmbspcv :
          free (p_node->edge.data.p_gmbspcv->bspcv);
          free (p_node->edge.data.p_gmbspcv);
          break;
      }
    }
  }

  return;
}   

void pwInsertAtInxGeomloop 
(
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_insert_node, 
  int index
)
{
  pwInsertNodeAtInx ((char **) p_loops, (char *) p_insert_node, index);
}

PWboolean pwSwapNodesGeomloop 
( 
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_a_node, 
  struct PWgeomloop *p_b_node
)
{
  return pwSwapNodes ((char **) p_loops, (char *) p_a_node, 
                      (char *) p_b_node);
}

void pwAppendGeomloop 
(
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_append_node
)
{
  pwAppendNode ((char **) p_loops, (char *) p_append_node);
}

void pwPrefixGeomloop 
(
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_prefix_node
)
{
  pwPrefixNode ((char **) p_loops, (char *) p_prefix_node);
}

int pwNumGeomloop
(
  struct PWgeomloop *p_from_node
)
{
  return pwNumNodes ((char *) p_from_node);
}

struct PWgeomloop *pwNodeAtInxGeomloop 
(
  struct PWgeomloop *p_from_node, 
  int index
)
{
  return (struct PWgeomloop *) pwNodeAtInx ((char *) p_from_node, index);
}

PWboolean pwInxOfNodeGeomloop 
(
  struct PWgeomloop *p_from_node,
  struct PWgeomloop *p_node, 
  int *index
)
{
  return pwInxOfNode ((char *) p_from_node, (char *) p_node, index);
}

struct PWgeomloop *pwHeadGeomloop 
(
  struct PWgeomloop *p_loops
)
{
  return (struct PWgeomloop *) pwHead ((char *) p_loops);
}

struct PWgeomloop *pwTailGeomloop 
(
  struct PWgeomloop *p_loops
)
{
  return (struct PWgeomloop *) pwTail ((char *) p_loops);
}

