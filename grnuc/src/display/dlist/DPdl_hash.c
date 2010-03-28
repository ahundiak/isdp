#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "DPdlist.h"

extern struct DPdlist_hash_table *DPhash_tables;

/* New Prototypes */
PROTO_DPdlist_hash_add
PROTO_DPdlist_hash_lookup
PROTO_DPdlist_hash_delete
PROTO_DPdlist_hash_delete_all
PROTO_DPdlist_alloc_hash_table
PROTO_DPdlist_free_hash_table
PROTO_DPdlist_resize_hash_table
PROTO_DPdlist_print_hash_table
PROTO_DPdlist_print_fixed_data
PROTO_DPdlist_delete_variable_data

/*--- DPdlist_hash_add -------------------------------------------*/

int DPdlist_hash_add(
   OM_S_OBJID objid,
   OMuword osnum,
   struct DPdlist_fixed_data **fixed_data )

/*
NAME
   DPdlist_hash_add

DESCRIPTION
   This function adds an element to the hash table and gives back a pointer
   to its fixed length data.

SYNOPSIS
   int DPdlist_hash_add(
      OM_S_OBJID objid,
      OMuword osnum,
      struct DPdlist_fixed_data **fixed_data )

PARAMETERS
   objid (IN) - the object id of the element
   osnum (IN) - the object space number of the element
   fixed_data (OUT) - pointer to the fixed data in the hash table

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   unsigned int stop, index, entry;
   struct DPdlist_hash_table *table;

   *fixed_data = NULL;

   /* resize hash table, if necessary,  before adding new entry */
   /* this is done at the top of this function instead of the   */
   /* so an empty table will have space allocated before the    */
   /* first add                                                 */
   sts = DPdlist_resize_hash_table( osnum );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   table = &DPhash_tables[osnum];

   entry = UINT_MAX;;
   stop = index = DLIST_HASH_FUNCTION( objid, table->size );
   do
      {
         if ( (table->fixed_data[index].hash_flags & DP_DLIST_HASH_USED) &&
              (table->fixed_data[index].objid == objid) )
         {
            /* found an entry for this object already in the table => use it */
            entry = index;
            break;
         }
         else if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_EMPTY )
         {
            /* found an empty entry in the table => use it if we haven't */
            /* already found a deleted slot                              */
            if ( entry == UINT_MAX )
            {
               entry = index;
            }

            break;
         }
         else if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_DELETED )
         {
            /* found a deleted entry in the table => remember its position but keep    */
            /* searching in case we find an entry for this object already in the table */
            if ( entry == UINT_MAX )
            {
               entry = index;
            }
         }

         index++;
         if ( index == table->size )
         {
            /* wrap around to the beginning of the table */
            index = 0;
         }
      }
   while ( index != stop );
   
   if ( entry != UINT_MAX )
   {
      /* found an unused entry */
      table->fixed_data[index].objid = objid;
      table->fixed_data[index].hash_flags &= ~DP_DLIST_HASH_EMPTY;
      table->fixed_data[index].hash_flags |= DP_DLIST_HASH_USED;
      *fixed_data = &(table->fixed_data[index]);

      table->used++;

      return( DLIST_S_SUCCESS );
   }

   return( DLIST_E_ERROR );

} /* DPdlist_hash_add */


/*--- DPdlist_hash_lookup --------------------------------------*/

int DPdlist_hash_lookup(
   OM_S_OBJID objid,
   OMuword osnum,
   struct DPdlist_fixed_data **fixed_data )

/*
NAME
   DPdlist_hash_lookup

DESCRIPTION
   This function looks up an element in the hash table and gives back a
   pointer to its fixed length data.  The pointer is NULL, if the element
   is not in the hash table.

SYNOPSIS
   int DPdlist_hash_lookup(
      OM_S_OBJID objid,
      OMuword osnum,
      struct DPdlist_fixed_data **fixed_data )

PARAMETERS
   objid (IN) - the object id of the element
   osnum (IN) - the object space number of the element
   fixed_data (OUT) - pointer to the fixed data in the hash table

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   unsigned int stop, index;
   struct DPdlist_hash_table *table;

   *fixed_data = NULL;

   table = &DPhash_tables[osnum];
   if ( table->size == 0 )
   {
      return( DLIST_E_ERROR );
   }

   stop = index = DLIST_HASH_FUNCTION( objid, table->size );

   /* search until we find an empty slot or the object in question */
   do
      {
         if ( table->fixed_data[index].hash_flags & DP_DLIST_HASH_EMPTY )
         {
            /* empty slot found */
            return( DLIST_E_ERROR );
         }

         if ( (table->fixed_data[index].hash_flags & DP_DLIST_HASH_USED) &&
              (table->fixed_data[index].objid == objid) )
         {
            *fixed_data = &(table->fixed_data[index]);
            return( DLIST_S_SUCCESS );
         }

         index++;
         if ( index == table->size )
         {
            /* wrap around to the beginning of the table */
            index = 0;
         }
      }
   while( index != stop );

   return( DLIST_E_ERROR );

} /* DPdlist_hash_lookup */

   
/*--- DPdlist_hash_delete ----------------------------------------*/

int DPdlist_hash_delete(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_hash_delete

DESCRIPTION
   This function deletes an element from the hash table

SYNOPSIS
   int DPdlist_hash_delete(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the element
   osnum (IN) - the object space number of the element

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_I_NOTFOUND - Element not in hash table
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   int ii;
   struct DPdlist_fixed_data *fixed_data;
   struct DPdlist_hash_table *table;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );

   if ( (1 & sts) && fixed_data )
   {
      table = &DPhash_tables[osnum];
      fixed_data->hash_flags |= DP_DLIST_HASH_DELETED;
      fixed_data->hash_flags &= ~DP_DLIST_HASH_USED;

      /*  make sure the ele_flags is zero, so that when re-used by a new  */
      /*  element, the old mask will not be there */

      fixed_data->ele_flags = 0;
      table->used--;

      if ( table->used == 0 )
      {
         /* all elements deleted => reset hash flags to empty */
         /* to get better performance                         */
         for ( ii = 0; ii < table->size; ii++ )
         {
            table->fixed_data[ii].hash_flags = DP_DLIST_HASH_EMPTY;
         }
      }

      return( DLIST_S_SUCCESS );
   }
   else
   {
      return( DLIST_I_NOTFOUND );
   }

} /* DPdlist_hash_delete */

/*--- DPdlist_hash_delete_all ----------------------------------------*/

int DPdlist_hash_delete_all(
   OMuword osnum,
   IGRboolean set_to_empty )

/*
NAME
   DPdlist_hash_delete_all

DESCRIPTION
   This function deletes all the elements from a hash table

SYNOPSIS
   int DPdlist_hash_delete_all(
      OMuword osnum,
      IGRboolean set_to_empty )

PARAMETERS
   osnum (IN) - the object space number of the hash table
   set_to_empty (IN) - if TRUE, mark the hash slot as
                       empty; if FALSE, just free variable
                       data

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/09/93 S.P. Rogers
      Initial specification, design, and implementation
   07/14/93 S.P. Rogers
      Added 'set_to_empty' parameter
*/

{
   int sts;
   int ii;
   struct DPdlist_hash_table *table;

   table = &DPhash_tables[osnum];
   for ( ii = 0; ii < table->size; ii++ )
   {
      if ( table->fixed_data[ii].hash_flags & DP_DLIST_HASH_USED )
      {
         sts = DPdlist_delete_variable_data( table->fixed_data[ii].objid, osnum,
                                             DP_DLIST_DELETE_SH_DATA | DP_DLIST_DELETE_WF_DATA );
         if ( !(1 & sts) )
         {
            return( sts );
         }
      }

      /* make sure the ele_flags is zero, so that when re-used by a new element */
      /* the old mask will not be there */

      table->fixed_data[ii].ele_flags = 0;
      if ( set_to_empty )
      {
         table->fixed_data[ii].hash_flags = DP_DLIST_HASH_EMPTY;
      }
   }

   if( set_to_empty )
   {
      table->used = 0;
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_hash_delete_all */

/*--- DPdlist_alloc_hash_table -------------------------------------*/

int DPdlist_alloc_hash_table(
   OMuword osnum,
   int size )
/*
NAME
   DPdlist_alloc_hash_table

DESCRIPTION
   This function allocates a hash table for the fixed length disllay
   list data.

SYNOPSIS
   int DPdlist_alloc_hash_table(
      OMuword osnum,
      int size )

PARAMETERS
   osnum (IN) - the object space number of the hash table
   size (IN) - the size of the hash table

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   unsigned int ii;
   unsigned int orig_size;
   unsigned int stop, index;
   struct DPdlist_hash_table *table;
   struct DPdlist_fixed_data *orig_fixed_data;

   table = &DPhash_tables[osnum];

   /* save the current data */
   orig_size = table->size;
   orig_fixed_data = table->fixed_data;

   /* allocate new table */
   table->fixed_data = (struct DPdlist_fixed_data *)
                      malloc( size * sizeof( struct DPdlist_fixed_data ) );

   if ( ! table->fixed_data )
   {
      table->fixed_data = orig_fixed_data;
      return( DLIST_E_ERROR );
   }

   /* initialize the new table */
   table->size = size;
   table->used = 0;

   for ( ii = 0; ii < size; ii++ )
   {
      table->fixed_data[ii].hash_flags = DP_DLIST_HASH_EMPTY;
      table->fixed_data[ii].objid = NULL_OBJID;
      table->fixed_data[ii].wf_data = NULL;
      table->fixed_data[ii].ele_flags = 0;
   }

   if ( (orig_size) && (orig_fixed_data) )
   {
      /* re-hash the entries in the old table into the new table */
      for ( ii = 0; ii < orig_size; ii++ )
      {
         if ( orig_fixed_data[ii].hash_flags & DP_DLIST_HASH_USED )
         {
            stop = index = DLIST_HASH_FUNCTION( orig_fixed_data[ii].objid, table->size );
            do
            {
               if ( !(table->fixed_data[index].hash_flags & DP_DLIST_HASH_USED) )
               {
                  /* found an unused entry */
                  table->fixed_data[index] = orig_fixed_data[ii];
                  table->fixed_data[index].hash_flags = DP_DLIST_HASH_USED;
                  table->used++;
                  break;
               }
               else
               {
                  index++;
                  if ( index == table->size )
                  {
                     /* wrap around to the beginning of the table */
                     index = 0;
                  }
               }
            }
            while ( index != stop );
         }
      }  /* end: for */

      /* free the old table */
      free( orig_fixed_data );
   }

   return( DLIST_S_SUCCESS );
} /* DPdlist_alloc_hash_table */

/*--- DPdlist_free_hash_table ---------------------------------*/

int DPdlist_free_hash_table(
   OMuword osnum )

/*
NAME
   DPdlist_free_hash_table

DESCRIPTION
   This function frees a hash table for an object space.

SYNOPSIS
   int DPdlist_free_hash_table(
      OMuword osnum )

PARAMETERS
   osnum (IN) - the object space whose hash table is to be freed

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/09/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   struct DPdlist_hash_table *table;

   table = &DPhash_tables[osnum];

   if ( table->fixed_data )
   {
      free( table->fixed_data );
   }

   table->fixed_data = NULL;
   table->size = 0;
   table->used = 0;

   return( DLIST_S_SUCCESS );

} /* DPdlist_free_hash_table */

/*--- DPdlist_resize_hash_table -------------------------------*/

int DPdlist_resize_hash_table(
   OMuword osnum )

/*
NAME
   DPdlist_resize_hash_table

DESCRIPTION
   This function resizes a hash table, if it is required.  A heuristic is 
   used to decide if the hash table should be resized.

SYNOPSIS
   int DPdlist_resize_hash_table(
      OMuword osnum )

PARAMETERS
   osnum (IN) - the object space number of the hash table

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   int sts;
   int new_size;
   double percent_used;
   struct DPdlist_hash_table *table;

   table = &DPhash_tables[osnum];

   if ( table->size == 0 )
   {
      sts = DPdlist_alloc_hash_table( osnum, DP_DLIST_MIN_HASH_SIZE );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }
   else
   {
      percent_used = (double)table->used / (double)table->size;

      if ( percent_used > 0.75 )
      {
         new_size = 2 * table->used;
      }
      else if ( percent_used < 0.25 )
      {
         new_size = 2 * table->used;
      }
      else
      {
         new_size = 0;
      }

      /* make sure we're not trying to get too small */
      if ( new_size > DP_DLIST_MIN_HASH_SIZE )
      {
         sts = DPdlist_alloc_hash_table( osnum, new_size );
         if ( !(1 & sts) )
         {
            return( sts );
         }
      }
   }

   return( DLIST_S_SUCCESS );
} /* DPdlist_resize_hash_table */
