#include <stdio.h>
#include <math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "OMminimum.h"
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

/*
 *   Application function   SetContainIntobj
 *   ----------------------------------------
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 */

void    SetContainIntobj
( 
   struct EMSintobj       *p_intcv, 
   int                    side,
   enum  PWcontaintype    containment
)
{
   unsigned int       *p_field=NULL;

   p_field = &(p_intcv->classification );

   if( side == LEFT )
   {
      switch( containment )
      {
         case  PWcontain_in:
            pwSetBits( p_field, 1, 2, PW_CONTAIN_IN );
            break;
         case  PWcontain_out:
            pwSetBits( p_field, 1, 2, PW_CONTAIN_OUT );
            break;
         case  PWcontain_on:
            pwSetBits( p_field, 1, 2, PW_CONTAIN_ON );
            break;
         case  PWcontain_unknown:
            pwSetBits( p_field, 1, 2, PW_CONTAIN_UNKNOWN );
            break;
      }
   }
   else if( side == RIGHT )
   {
      switch( containment )
      {
         case  PWcontain_in:
            pwSetBits( p_field, 3, 2, PW_CONTAIN_IN );
            break;
         case  PWcontain_out:
            pwSetBits( p_field, 3, 2, PW_CONTAIN_OUT );
            break;
         case  PWcontain_on:
            pwSetBits( p_field, 3, 2, PW_CONTAIN_ON );
            break;
         case  PWcontain_unknown:
            pwSetBits( p_field, 3, 2, PW_CONTAIN_UNKNOWN );
            break;
      }
   }

}/* end of function SetContainIntobj */



/*
 *   Application function  GetContainIntobj 
 *   --------------------------------------
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 */

enum PWcontaintype   GetContainIntobj
(
   struct EMSintobj  *p_intcv,
   int               side
)
{
   unsigned int          *p_field, loc_var=0;
   enum PWcontaintype    retval;

   retval = PWcontain_unknown;
   p_field = &(p_intcv->classification);

   if( side == LEFT )
      loc_var = pwGetBits( *p_field, 1, 2 );
   else if( side == RIGHT )
      loc_var = pwGetBits( *p_field, 3, 2 );
   switch( loc_var )
   {
      case  PW_CONTAIN_IN:
         retval = PWcontain_in;
         break;
      case  PW_CONTAIN_OUT:
         retval = PWcontain_out;
         break;
      case  PW_CONTAIN_ON:
         retval = PWcontain_on;
         break;
      case  PW_CONTAIN_UNKNOWN:
         retval = PWcontain_unknown;
         break;
   }
   return retval;
}/* end of function GetContainIntobj */       

