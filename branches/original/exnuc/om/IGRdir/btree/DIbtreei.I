/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).  The methods implementation
   uses the generic routines located in DIbtree.c.

   This class is a private class.
*/

class implementation DIbtree;

#undef close
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DIomac.h"

#define DEBUG

#include <stdio.h>

method debug ()
{
  printf ( "DIbtree.debug : (%d, %d)\n", OM_Gw_current_OS, my_id );

  return OM_S_SUCCESS;
}


method is_empty ( DIint *status )
{
  *status = my_buf_size () == 0;
  return OM_S_SUCCESS;
}


method close ( DIint *status )
{
  /* must be empty to be deleted */
  if (my_buf_size ())
    *status = DIR_E_INVARG;
  else
  { *status = DIR_S_SUCCESS;
    DIfree ( me->tree->data );
    DIfree ( me->tree ); }
 
  return OM_S_SUCCESS;
}


end implementation DIbtree;
