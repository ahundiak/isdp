#include<stdio.h>
#include<math.h>
#include<alloca.h>
#include"PWminimum.h"
#include"PWerror.h"
#include<OMminimum.h>
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"

#include "PWmodel.h"
#include "PWapi/relstable.h"

static struct PWrelstable  loc_table;

static void   SwapBits
( 
  unsigned int *, 
  int, 
  int, 
  int
);

/*
 *  Application function : pwInitializeRelsTable
 *  --------------------------------------------
 *
 *  Description
 *  -----------
 *  This function will fill the local PWrelstable structure with the 
 *  incoming PWrelstable structure values. All other functions in this
 *  file can get the values by accessing this local structure.
 *
 *  Input
 *  -----
 *  struct PWrelstable        *p_intable             * input relorient table
 *                                                   *
 *  Output
 *  ------
 *  Output value is stored in a local struct PWrelstable
 */

PWresult  pwInitializeRelsTable
(
   struct PWrelstable *p_intable
)
{
   unsigned int   retval;
   int            i;
    
   retval = PW_K_Success;
   loc_table.table = NULL;

   loc_table.num_entries = p_intable->num_entries;
   loc_table.table = (unsigned int *)malloc( p_intable->num_entries*
                                             sizeof(unsigned int ));
   OnErrorState( !loc_table.table, retval,
                 SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup );

   for( i=0; i<p_intable->num_entries; i++)
      loc_table.table[i] = p_intable->table[i];
  
   wrapup:
   return retval;
}/* end of function pwInitializeRelsTable */



/*
 *   Application function : pwUninitializeRelsTable
 *   ----------------------------------------------
 *   Description
 *   -----------
 *   This function will uninitialize the local variable loc_table and 
 *   deallocate the allocated memory for the table field.
 *
 *   Input
 *   -----
 *   Output
 *   ------
 */

void  pwUninitializeRelsTable
(
)
{
   loc_table.num_entries = 0;
   if( loc_table.table )
      free( loc_table.table );
   loc_table.table = NULL;
}/* end of function pwUninitializeRelsTable */



/* 
 *    Application function : pwGetBooleanRelsTable().
 *    -----------------------------------------------
 *
 *    Description
 *    -----------
 *    This function sends the appropriate classification table for the
 *    given operation type ( union, intersection or difference ) along with
 *    the number of classifications in the set.
 *    If the 'table' field is not mallocked by the user then this function
 *    only sets the 'num_entries' field. User needs to allocate that amount
 *    of memory and again call this function to get the rels table.
 *    Input
 *    -----
 *    int     optyp                             *
 *                                              * Contains the operation type
 *                                              * ( union, intersection or
 *                                              *   difference )
 *                                              *
 *    Output
 *    ------
 *    struct PWrelstable  *p_table              * Contains the number
 *                                              * of classification in
 *                                              * the output table and a pointer
 *                                              * to the classification table.
 *                                              *
 */

void   pwGetBooleanRelsTable
(
   int                  optyp, 
   struct PWrelstable   *p_table 
)
{

   /*
    *                                  UNION
    *                                  -----
    *
    *   Operand B           Operand A              Bit pattern     Hex value
    *   -----------------    -----------------     ------------     ---------
    *   Right out, Left in   Right out, Left in    1001 1001        0x99
    *   Right out, Left on   Right out, Left on    1011 1011        0xbb
    *   Right on , Left in   Right out, Left on    1101 1011        0xdb
    *
    *
    *                                 DIFFERENCE
    *                                 ----------
    *
    *    Operand B           Operand A              Bit pattern     Hex value
    *   -----------------    -----------------     ------------     ---------
    *   Right in , Left out  Right out, Left in    0110 1001        0x69
    *   Right in , Left on   Right out, Left on    0111 1011        0x7b
    *   Right in , Left on   Right on , Left in    0111 1101        0x7d
    *
    *
    *
    *                                INTERSECTION
    *                                ------------
    *
    *   Operand B           Operand A              Bit pattern     Hex value
    *   -----------------    -----------------     ------------     ---------
    *   Right in , Left out  Right in , Left out   0110 0110        0x66
    *   Right on , Left out  Right in , Left on    1110 0111        0xe7
    *   Right in , Left on   Right in , Left on    0111 0111        0x77
    */


   /* 
    * If p_table->table is NULL then fill only the num_entries corresponding
    * to the input operation type
    */
   if( p_table->table == NULL )
   {
      switch( optyp )
      {
         case UNION:
            p_table->num_entries = 3;
            break;
         case DIFFERENCE:
            p_table->num_entries = 3;
            break;
         case INTERSECTION:
            p_table->num_entries = 3;
            break;
      }
   }
   else
   {
      switch( optyp )
      {
         case UNION:
            p_table->num_entries = 3;
            p_table->table[0] = 0x99;
            p_table->table[1] = 0xbb;
            p_table->table[2] = 0xdb;
            break;
         case DIFFERENCE:
            p_table->num_entries = 3;
            p_table->table[0] = 0x69;
            p_table->table[1] = 0x7b;
            p_table->table[2] = 0x7d;
            break;
         case INTERSECTION:
            p_table->num_entries = 3;
            p_table->table[0] = 0x66;
            p_table->table[1] = 0xe7;
            p_table->table[2] = 0x77;
            break;
      }
   }
}/* end of function pwBooleanRelsTable */



/*
 *   Application Function name : pwValidateIntRels().
 *
 *   Description
 *   -----------
 *   This function compares the operand A and operand B intersection relorients
 *   with the standard orientation table applicable for this operation (union,
 *   intersection or difference ). If required the left and right relorient
 *   of an intersection is swaped in order to match with the table relorient.
 *   If the relorient of an intersection is swapped then the reversed field
 *   of that intobj is set appropriately. If the intobj relorients don't match
 *   with the table relorients even after swapping then the intobjs are marked
 *   deletable.
 *
 *   Input
 *   -----
 *   struct PWrelstable     *p_table      *  Classification table for the
 *                                        *  present operation
 *                                        *
 *
 *   EMSintobj        *p_this_intboj      * Intersecton curve on operand A.
 *                                        *
 *
 *   Output
 *   ------
 *   unsigned  int    p_this_intobj->classification   * This field is set
 *                                                    * properly and intobj
 *                                                    * is marked deletable if
 *                                                    * required
 *                                                    *
 *   unsigned int     p_other_intobj->classification
 *
 *   IGRboolean       p_this_intobj->reversed         * This is set properly
 *                                                    *
 *   IGRboolean       p_other_intobj->reversed
 */

void    pwValidateIntRels
(
   struct EMSintobj     *p_intcv 
)
{
   unsigned int tmp_bits=0, loc_bits=0, opA_bits=0, opB_bits=0;
   int          i, num_sets;

   if ((p_intcv->props & EMSintobj_uvdegenerate) ||
      (p_intcv->props & EMSintobj_xyzdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_uvdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_xyzdegenerate))
   {
     goto wrapup;
   }

   opA_bits = pwGetBits( p_intcv->classification, 3, 4);
   opB_bits = pwGetBits( p_intcv->other_intobj_node->classification, 3, 4);

   tmp_bits = (opB_bits << 4 ) | opA_bits ;
   loc_bits = tmp_bits;

   num_sets = loc_table.num_entries;
 
   for( i=0; i<num_sets; i++ )
   {
      if( loc_bits == loc_table.table[i] )
      {
         goto wrapup;
      }
   }
   SwapBits( &loc_bits, 3, 1, 2 );
   
   for( i=0; i<num_sets; i++)
   {
      if( loc_bits == loc_table.table[i] )
      {
         SwapBits( &(p_intcv->classification), 3, 1, 2 );
         p_intcv->reversed = TRUE;
         goto wrapup;
      }
   }

   loc_bits = tmp_bits;
   SwapBits( &loc_bits, 7, 5, 2 );
   for( i=0; i<num_sets; i++)
   {
      if( loc_bits == loc_table.table[i] )
      {
         SwapBits( &(p_intcv->other_intobj_node->classification), 3, 1, 2);
         p_intcv->other_intobj_node->reversed = TRUE;
         goto wrapup;
      }
   }

   SwapBits( &loc_bits, 3, 1, 2);
   for( i=0; i<num_sets; i++)
   {
      if( loc_bits == loc_table.table[i] )
      {
         SwapBits( &(p_intcv->classification), 3, 1, 2 );
         p_intcv->reversed = TRUE;
         SwapBits( &(p_intcv->other_intobj_node->classification), 3, 1, 2 );
         p_intcv->other_intobj_node->reversed = TRUE;
         goto wrapup;
      }
   }
   p_intcv->props |= EMSintobj_deletable;
   p_intcv->other_intobj_node->props |= EMSintobj_deletable;

wrapup: 
   return;
}/* end of function pwApplyRelsTable */
         
/*
 *   Application function: SwapBits().
 *   ---------------------------------
 *   Description
 *   -----------
 *   This function is used to interchange a given number of bits between
 *   location1 and location2. Internally this function gets the input
 *   number of bits from location1 and location2 by calling GetBits. After
 *   getting the bits, it puts bit obtained from location1 to location2
 *   and vice versa by calling SetBits.
 *
 *   Input
 *   -----
 *   unsigned int         *field                 *
 *					         * Input field where swapping
 * 						 * is to be done.
 *						 *
 *
 *   int                  location1, location2   *
 *                                               * Locations for swapping
 *						 *
 *  
 *   int                  num_bits               *
 *               				 * Number of bits to be swapped
 *                   				 *
 *   Output
 *   ------
 *   unsigned int         *field                 * 
 *              				 * It will contain the result
 *						 * after swapping.
 *						 *
 */

static void   SwapBits
( 
   unsigned int    *field, 
   int             location1, 
   int             location2,
   int             num_bits 
)
{
   unsigned int loc_var1=0, loc_var2=0;
   
   loc_var1 = pwGetBits( *field, location1, num_bits );
   loc_var2 = pwGetBits( *field, location2, num_bits );

   pwSetBits( field, location2, num_bits, loc_var1 );
   pwSetBits( field, location1, num_bits, loc_var2 );
}/* end of function SwapBits */

   
