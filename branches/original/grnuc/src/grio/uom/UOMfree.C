/*
 *  functions to deallocate unit lists
 */

#include "xc/hash.h"

#include "OMerrordef.h"
#include "UOMdef.h"
#include "UOM.h"

int UOM_free_type( type )
UOM_TYPE **type;
{
  if ( type && *type ) {
    UOM_TYPE *tt;

    while ( *type ) {
      UOM_list_remove_head( type, &tt );

      if ( tt->aliashashtab )
        hashfree( (HASHTABLE *) tt->aliashashtab ), tt->aliashashtab = 0;

      UOM_free_alias( &tt->defalias );
      UOM_free_variant( &tt->variant );

      free( tt );
    }
  }

  return OM_S_SUCCESS;
}

int UOM_free_variant( variant )
UOM_VARIANT **variant;
{
  if ( variant && *variant ) {
    UOM_VARIANT *vv;

    while ( *variant ) {
      UOM_list_remove_head( variant, &vv );

      UOM_free_alias( &vv->alias );

      free( vv );
    }
  }

  return OM_S_SUCCESS;
}

int UOM_free_alias( alias )
char ***alias;
{

  if ( alias && *alias ) {
    int ii = 0;

    while ( (*alias)[ii] )
      free( (*alias)[ii++] );

    free( *alias );
    *alias = 0;
  }

  return OM_S_SUCCESS;
}
