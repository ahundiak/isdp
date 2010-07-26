/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).

   This class is a private class.
*/
class implementation DIbstgr;

#include <OMerrordef.h>
#include <OMmacros.h>

#include <memory.h>
#include <stdio.h>

#define DEBUG
#include "DIomac.h"


method debug ()
{
  DIint  i;
  DIgrid grid;

  printf ( "\n\nB-tree of string - grid\n" );  
  for (i = 0; i < my_free; i++)
  { memcpy ( &grid, index_id ( i ), my_size );
    printf ( "data [%2d]: '%s' (%d) - (%d, %d)\n", i, ind_nm ( i ), my_data [i],
             grid.osnum, grid.objid ); }

  return OM_S_SUCCESS;
}


method init ( DIint *sts )
{
  extern DIint DIBcomp_strings ();

  DImalloc ( my_tree, struct BTree *, sizeof ( btree ) );
  DImalloc ( my_data, int *, 1 );
  my_free = 0; my_root = NULL;
  my_cmp = DIBcomp_strings;
  my_size = sizeof ( DIgrid );
  my_type = DIR_D_STRING_GRID;
  return OM_S_SUCCESS;
}

method get_type ( DIint *type )
{
  *type = DIR_D_STRING_GRID;

  return OM_S_SUCCESS;
}


end implementation DIbstgr;

