#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "igetypedef.h"
#include "dp.h"
#include "dpdef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "DPdlist.h"


static struct DPdlist_data_block_node *DPdlist_data_block_list = NULL;
static struct DPdlist_free_chunk_node *DPdlist_free_chunk_list = NULL;

/* New prototypes */
PROTO_DPdlist_alloc_data_block
PROTO_DPdlist_free_data_blocks
PROTO_DPdlist_alloc_chunk
PROTO_DPdlist_free_chunk
PROTO_DPdlist_alloc_data_block_node
PROTO_DPdlist_free_data_block_node
PROTO_DPdlist_alloc_free_chunk_node
PROTO_DPdlist_free_free_chunk_node


/*---------DPdlist_alloc_data_block------------------------------------------*/

int DPdlist_alloc_data_block(
   int size,
   void **ptr )

/*
NAME
   DPdlist_alloc_data_block

DESCRIPTION
   This function allocates a display list data block.

SYNOPSIS
   int DPdlist_alloc_data_block(
      int size,
      void **ptr )

PARAMETERS
   size (IN) - The size of the data block to be allocated
   ptr ( OUT) - The pointer to the data block is returned

GLOBALS USED
   DPdlist_data_block_list

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   struct DPdlist_data_block_node *block_node;
   int actual_size;
   int sts;


   if ( !ptr )
   {
      return( DLIST_E_ERROR );
   }

   if ( size > DP_DLIST_MIN_BLOCK_SIZE )
   {
      actual_size = size;
   }
   else
   {
      actual_size = DP_DLIST_MIN_BLOCK_SIZE;
   }
   

   /* Allocate data block and data block node */

   sts = DPdlist_alloc_data_block_node( &block_node );
   if ( !(1 & sts) )
   {
      return( sts );
   }
   
   block_node->next = NULL;
   *ptr = ( void * ) malloc( actual_size );
   if ( *ptr )
   {
      block_node->size = actual_size;
      if ( size < actual_size )
      {

         /* Add the remaining bytes to the free chunk list */
         /* Update the free chunk list                     */

         sts = DPdlist_free_chunk( actual_size - size, 
                                    ( ( char * )*ptr ) + size );

         if ( !(1 & sts) )
         {
            DPdlist_free_data_block_node( &block_node );
            free( *ptr ); 
            *ptr = NULL;
            return( sts );
         }
      }
      block_node->address = *ptr;

      /* Adding the data block node to the data block list */
      /* Update the data block list                        */
      block_node->next = DPdlist_data_block_list;
      DPdlist_data_block_list = block_node;

   }
   else
   {
      DPdlist_free_data_block_node( &block_node );
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_alloc_data_block */


/*---------DPdlist_free_data_blocks------------------------------------------*/

int DPdlist_free_data_blocks(
   void )

/*
NAME
   DPdlist_free_data_blocks

DESCRIPTION
   This function frees all of the data blocks maintained by the display list.

SYNOPSIS
   int DPdlist_free_data_blocks()

PARAMETERS
   none

GLOBALS USED
   DPdlist_free_chunk_list
   DPdlist_data_block_list

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   struct DPdlist_data_block_node *data_node1, *data_node2;
   struct DPdlist_free_chunk_node *free_node1, *free_node2;
   int sts;
   
   /* Free the data blocks and the data block nodes  */
   data_node1 = DPdlist_data_block_list;
   while( data_node1 != NULL )
   {
      free( data_node1->address );

      /* Save the address of the next node to be freed */

      data_node2 = data_node1->next;
      sts = DPdlist_free_data_block_node ( &data_node1 );
      if ( !(1 & sts) )
      {
         return( sts );
      }
      data_node1 = data_node2;
   }

   DPdlist_data_block_list = NULL;

   /* Free the free chunk nodes */
   free_node1 = DPdlist_free_chunk_list;
   while( free_node1 != NULL )
   {
      /* Save the address of the next node to be freed */

      free_node2 = free_node1->next;
      sts = DPdlist_free_free_chunk_node ( &free_node1 );
      if ( !(1 & sts) )
      {
         return( sts );
      }
      free_node1 = free_node2;
   }
   DPdlist_free_chunk_list = NULL;

   return( DLIST_S_SUCCESS );

} /* DPdlist_free_data_blocks */

/*---------DPdlist_alloc_chunk------------------------------------------*/

int DPdlist_alloc_chunk(
   int size,
   void **ptr )

/*
NAME
   DPdlist_alloc_chunk

DESCRIPTION
   This function allocates a chunk of memory from the display list
   data blocks.

SYNOPSIS
   int DPdlist_alloc_chunk(
      int size,
      void **ptr )

PARAMETERS
   size (IN) - The size to be allocated
   ptr (OUT) - The pointer to the memory allocated

GLOBALS USED
   DPdlist_free_chunk_list

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   struct DPdlist_free_chunk_node *free_ptr, *prev_ptr;
   int found = FALSE;
   int sts;

   free_ptr = prev_ptr = DPdlist_free_chunk_list;
   while( ( free_ptr != NULL ) && ( !found ) )
   {
      /* Look for a large enough free node */
      if ( free_ptr->size >= size )
      {
         found = TRUE;
         *ptr = free_ptr->address;

         /* Update the link list */
         if ( size == free_ptr->size )
         {
            /* Head of the list */
            if ( free_ptr == prev_ptr )
            {
               DPdlist_free_chunk_list = free_ptr->next;
            }
            else
            {
               prev_ptr->next = free_ptr->next;
            }

            sts = DPdlist_free_free_chunk_node( &free_ptr );
            if ( !(1 & sts) )
            {
               return( sts );
            }

         }
         else
         {
            /* A free node has to be updated to account for the */
            /* remaining free space                             */
            free_ptr->size = free_ptr->size - size;
            free_ptr->address = ( ( char * ) free_ptr->address ) + size;
         }
      }
      else
      {
         prev_ptr = free_ptr;
         free_ptr = free_ptr->next;
      }
   }

   if ( !found )
   {
      sts = DPdlist_alloc_data_block( size, ptr );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }

   return( DLIST_S_SUCCESS );
 
} /* DPdlist_alloc_chunk */

/*-----------DPdlist_free_chunk ---------------------------------------*/

int DPdlist_free_chunk(
   int size,
   void *ptr )

/*
NAME
   DPdlist_free_chunk

DESCRIPTION
   This function frees a chunk of memory in the display list data blocks by
   putting it on the free list.

SYNOPSIS
   int DPdlist_free_chunk(
      int size,
      void *ptr )

PARAMETERS
   size (IN) - The size to be allocated
   ptr (OUT) - The pointer to the memory allocated

GLOBALS USED
   DPdlist_free_chunk_list

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   struct DPdlist_free_chunk_node *free_ptr, *prev_ptr, *free_node;
   int sts;
   int combine_with_prev = FALSE;
   int combine_with_next = FALSE;

   free_ptr = prev_ptr = DPdlist_free_chunk_list;

   /* Kind of insertion sort. The free list is sorted by address */

   while( ( free_ptr != NULL ) && 
          ( ptr > free_ptr->address ) )
   {
      /*  Advance */
      prev_ptr = free_ptr;
      free_ptr = free_ptr->next;   
   }

   if ( ( prev_ptr ) && 
        ( ptr == ( ( char * ) prev_ptr->address ) + prev_ptr->size ) )
   {
      combine_with_prev = TRUE;
   }

   if ( ( free_ptr ) &&  ( ( char * ) ptr ) + size == free_ptr->address ) 
   {
      combine_with_next = TRUE;
   }

   /* Combine the nodes if possible */
   if ( ( combine_with_prev ) && ( combine_with_next ) )
   {
      prev_ptr->size = prev_ptr->size + size + free_ptr->size;
      prev_ptr->next  = free_ptr->next;
      sts = DPdlist_free_free_chunk_node( &free_ptr );
      if ( !(1 & sts) )
      {
         return( sts );
      }
   }
   else
   {
      if ( combine_with_prev )
      {
         prev_ptr->size += size;
      }
      else
      {
         if ( combine_with_next )
         {
            free_ptr->size += size;
            free_ptr->address = ptr;
         }
         else
         {
            /* A new node has to added */
            sts = DPdlist_alloc_free_chunk_node( &free_node );
            if ( !(1 & sts) )
            {
               return( sts );
            } 
            free_node->size = size;
            free_node->address = ptr;
            free_node->next = free_ptr;
            if ( prev_ptr == free_ptr )
            {
               DPdlist_free_chunk_list = free_node;
            }
            else
            {
                prev_ptr->next = free_node;
            }
              
         }
      }
   }
 
   return( DLIST_S_SUCCESS );

} /* DPdlist_free_chunk */

/*-----------DPdlist_alloc_data_block_node -------------------------------*/

int DPdlist_alloc_data_block_node(
   struct DPdlist_data_block_node **node_ptr )

/*
NAME
   DPdlist_alloc_data_block_node

DESCRIPTION
   This function allocates the DPdlist_data_block_node structure

SYNOPSIS
   int DPdlist_alloc_data_block_node(
      struct DPdlist_data_block_node **node_ptr )

PARAMETERS
   node_ptr (OUT) - The pointer to the DPdlist_data_block_node structure to be
                   allocated.

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 Shridar Subramanian
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   if ( !node_ptr )
   {
      return( DLIST_E_ERROR );
   }
   *node_ptr = ( struct DPdlist_data_block_node * )malloc(
                                   sizeof ( struct DPdlist_data_block_node ) );
 
   return ( DLIST_S_SUCCESS );

} /* DPdlist_alloc_data_block_node */

/*-----------DPdlist_free_data_block_node -------------------------------*/

int DPdlist_free_data_block_node(
   struct DPdlist_data_block_node **node_ptr )

/*
NAME
   DPdlist_free_data_block_node

DESCRIPTION
   This function frees the DPdlist_data_block_node structure

SYNOPSIS
   int DPdlist_free_data_block_node(
      struct DPdlist_data_block_node **node_ptr )

PARAMETERS
   node_ptr (IN) - The pointer to the DPdlist_data_block_node structure to be
                   freed.

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 Shridar Subramanian
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   if ( !node_ptr )
   {
      return( DLIST_E_ERROR );
   }

   if ( *node_ptr )
   {
      free( *node_ptr );
      *node_ptr = NULL;
   }

   return ( DLIST_S_SUCCESS );

} /* DPdlist_free_data_block_node */

/*-----------DPdlist_alloc_free_chunk_node -------------------------------*/

int DPdlist_alloc_free_chunk_node(
   struct DPdlist_free_chunk_node **node_ptr )

/*
NAME
   DPdlist_alloc_free_chunk_node

DESCRIPTION
   This function allocates the DPdlist_free_chunk_node structure

SYNOPSIS
   int DPdlist_alloc_free_chunk_node(
      struct DPdlist_free_chunk_node **node_ptr )

PARAMETERS
   node_ptr (OUT) - The pointer to the DPdlist_free_chunk_node structure to be
                   allocated.

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 Shridar Subramanian
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   if ( !node_ptr )
   {
      return( DLIST_E_ERROR );
   }
   *node_ptr = ( struct DPdlist_free_chunk_node * )malloc( 
                                   sizeof ( struct DPdlist_free_chunk_node ) );

   return ( DLIST_S_SUCCESS );

} /* DPdlist_alloc_free_chunk_node */

/*-----------DPdlist_free_free_chunk_node -------------------------------*/

int DPdlist_free_free_chunk_node(
   struct DPdlist_free_chunk_node **node_ptr )

/*
NAME
   DPdlist_free_free_chunk_node

DESCRIPTION
   This function frees the DPdlist_free_chunk_node structure

SYNOPSIS
   int DPdlist_free_free_chunk_node(
      struct DPdlist_free_chunk_node **node_ptr )

PARAMETERS
   node_ptr (IN) - The pointer to the DPdlist_free_chunk_node structure to be
                   freed.

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/13/93 Shridar Subramanian
      Initial specification and design

   05/14/93 Shridar Subramanian
      Initial implementation

*/

{
   if ( !node_ptr )
   {
      return( DLIST_E_ERROR );
   }

   if ( *node_ptr )
   {
      free( *node_ptr );
      *node_ptr = NULL;
   }

   return ( DLIST_S_SUCCESS );

} /* DPdlist_free_free_chunk_node */

/*--- DPdlist_print_data_blocks --------------------------------------------*/

int DPdlist_print_data_blocks(
   short show_nodes )

/*
NAME
   DPdlist_print_data_blocks

DESCRIPTION
   This function prints out statistics on display list data block usage

SYNOPSIS
   int DPdlist_print_data_blocks(
      short show_nodes )

PARAMETERS
   show_nodes (IN) - if TRUE, print out each individual node

GLOBALS USED
   DPdlist_data_block_list

RETURN VALUES
   DLIST_S_SUCCESS - Success

HISTORY
   05/19/93 S.P. Rogers
      Initial implementation
*/


{
   int total_blocks = 0;
   int total_size = 0;
   struct DPdlist_data_block_node *node;

   node = DPdlist_data_block_list;
   while ( node )
   {
      total_blocks++;
      total_size += node->size;
      node = node->next;
   }

   fprintf( stderr, "\nData Block Statistics\n" );
   fprintf( stderr, "   Total Blocks: %-10d  Total Size: %-10d\n",
            total_blocks, total_size );


   if ( show_nodes )
   {
      fprintf( stderr, "   Individual Nodes\n" );
      node = DPdlist_data_block_list;
      while ( node )
      {
         fprintf( stderr, "      Size: %-10d  Address: %#X\n",
                  node->size, node->address );
         node = node->next;
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_print_data_blocks */


/*--- DPdlist_print_free_chunks --------------------------------------------*/

int DPdlist_print_free_chunks(
   short show_chunks )

/*
NAME
   DPdlist_print_free_chunks

DESCRIPTION
   This function prints out statistics on display list free chunk storage

SYNOPSIS
   int DPdlist_print_free_chunks(
      short show_chunks )

PARAMETERS
   show_chunks (IN) - if TRUE, print out each individual node

GLOBALS USED
   DPdlist_free_chunk_list

RETURN VALUES
   DLIST_S_SUCCESS - Success

HISTORY
   05/19/93 S.P. Rogers
      Initial implementation
*/


{
   int total_nodes = 0;
   int total_size = 0;
   int largest_chunk = 0;
   int smallest_chunk = INT_MAX;
   struct DPdlist_free_chunk_node *node;

   node = DPdlist_free_chunk_list;
   while ( node )
   {
      total_nodes++;
      total_size += node->size;
      if ( node->size > largest_chunk )
      {
         largest_chunk = node->size;
      }

      if ( node->size < smallest_chunk )
      {
         smallest_chunk = node->size;
      }

      node = node->next;
   }

   fprintf( stderr, "\nData Block Statistics\n" );
   fprintf( stderr, "   Total Chunks: %-10d  Total Size: %-10d\n",
            total_nodes, total_size );
   fprintf( stderr, "   Smallest Chunk: %-10d  Largest Chunk: %-10d\n",
            smallest_chunk, largest_chunk );

   if ( show_chunks )
   {
      fprintf( stderr, "   Individual Chunks\n" );
      node = DPdlist_free_chunk_list;
      while ( node )
      {
         fprintf( stderr, "      Size: %-10d  Address: %#X\n",
                  node->size, node->address );
         node = node->next;
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_print_free_chunks */

