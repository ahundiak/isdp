/*
    H.Bequet 08/17/1988                                           complexi.I 

    ABSTRACT :
    --------

    This is the implementation file of the class IGRdir.  This class provides
    a layered naming capability with full support of the UNIX directory
    system user interface.  It doesn't provide group protection.

    HISTORY :
    -------

    08/15/1988 : HGB - Creation Date
*/

class implementation complex;

#include <string.h>
#include "OMobjid.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"
#include "DIprims.h"


method i_find ( DIint *status; DIchar *my_name; DIchar **exp_buf; DIint buf_count;
                DIint level, max_level, *deep; DIchar ***lines; DIgrid **grids;
                DIint *count; DIchar options )
{
  *status = OM_S_SUCCESS;
  if (!me->tree)
  {
    om_send ( DIstorage.wakeup ( status ), my_id, my_id );
  }

  if (*status == OM_S_SUCCESS)
  {
    om_send_msg ( IGRdir.i_find ( status, my_name, exp_buf, buf_count, level,
                                  max_level, deep, lines, grids, count, options ),
                  my_id, my_id );
  }
  return OM_S_SUCCESS;
}


method init ( DIint *status )
{
  om_send_msg ( IGRdir.init ( status ), my_id, my_id );
  om_send ( DIstorage.init ( status ), my_id, my_id );

  return OM_S_SUCCESS;
}

method debug ()
{
  om_send_msg ( DIbstob.debug (), my_id, my_id );

  return OM_S_SUCCESS;
}


%safe
string_objid *DIcomplex_pool = NULL;
DIint DIcomplex_is_space = NULL;
%endsafe


method add_index ( DIint *status; DIint *index; DIobjid objid; )
   /* to add the objid to the target directory. */
{
  string_objid *node;

  *status = DIR_S_SUCCESS;

  /*|malloc node */
  if (DIcomplex_pool)
  {
    node = DIcomplex_pool;
    DIcomplex_pool = NULL;
  }
  else
    node = (DIstring_objid *) malloc ( sizeof ( DIstring_objid ) );

  if (node)
  {
    extern char *DIbstob_mem;

    /* info points to an objid */
    node->str = NULL;
    DIbstob_mem = node->str;
    node->id = objid;

    if (!DIcomplex_is_space)
      me->tree->data = (char **) realloc ( me->tree->data,
                        (me->tree->free + 1) * DIB_ptr_sizes [me->tree->type] );
    else
      DIcomplex_is_space--;

    if (!me->tree->data)
    {
      DIfree ( node );
      *status = DIR_E_ABORT;
    }
    else
    {
      me->tree->data [me->tree->free] = node;
      if (index)
        *index = me->tree->free - 1;
      me->tree->free++;
    }
  }
  else
   *status = DIR_E_ABORT;

  return OM_S_SUCCESS;
} /* method add_index */



method remove_by_index ( DIint *status; DIint index; DIchar *name;
                         DIobjid *p_objid )
/* 
   This method removes the given object (by index) from the directory,
   if any
*/
{
  DIstring_objid *buffer;

  /*"index : %d, me->tree->free : %d\n", index, me->tree->free */
  if ((index < 0) || (index >= me->tree->free - 1))
    return DIR_E_OVFLOW;
  else
  {
    DIstring_objid *node = me->tree->data [++index];

    {
      int i;

      /*|not in the B-tree --> remove from array */
      *status = DIR_S_SUCCESS;

      /*"compress the array from %d\n", index */
      for (i = index; i < me->tree->free - 1; i++)
        me->tree->data [i] = me->tree->data [i + 1];

      /*|realloc the array */
      me->tree->free--;
      DIcomplex_is_space++;

      if (index < me->tree->free)
      {
        extern int DIBdec_index, DIBdec ();

        /*"update the B-tree, index : %d\n", index */
        DIBdec_index = index;
        twalk ( me->tree->root, DIBdec );
      }

      buffer = (char *)node;
    }
  }

  if (DIR_S_SUCCESS == *status)
  {
    extern char *DIbstob_mem;

    DIbstob_mem = NULL;

    if (buffer)
    {
      if (p_objid)
        *p_objid = buffer->id;

      DIcomplex_pool = buffer;
    }
  }

  return OM_S_SUCCESS;
} /* method remove_by_index */



method index ( DIint *status; DIint index; DIchar *name; DIobjid *p_objid )
/* 
   This method is sent to translate an index into an objid.
*/
{
  om_send ( DIstorage.retrieve_index ( status, index, name, p_objid ), my_id, my_id );

  return OM_S_SUCCESS;
} /* method index */


end implementation complex;
