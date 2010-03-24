/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).

   This class is a private class.
*/
class implementation DIbstob;

#include <OMerrordef.h>
#include <OMmacros.h>

#include <memory.h>
#include <stdio.h>

#define DEBUG
#include "DIomac.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


method debug ()
{
  DIint i, objid;

  printf ( "\n\nB-tree of string - objid\n" );  
  for (i = 0; i < my_free; i++)
  { memcpy ( &objid, index_id ( i ), my_size );
    printf ( "data [%2d]: '%s' (%d) - %d\n", i, ind_nm ( i ), my_data [i], objid ); }

  return OM_S_SUCCESS;
}


method init ( DIint *sts )
{
  extern DIint DIBcomp_strings ();

  DImalloc ( my_tree, btree *, sizeof ( btree ) );
  DImalloc ( my_data, DIint *, 1 );
  my_free = 0; my_root = NULL;
  my_cmp = DIBcomp_strings;
  my_size = sizeof ( DIobjid );
  my_type = DIR_D_STRING_OBJID;

  return OM_S_SUCCESS;
}


method get_type ( DIint *type )
{
  *type = DIR_D_STRING_OBJID;

  return OM_S_SUCCESS;
}

end implementation DIbstob;
