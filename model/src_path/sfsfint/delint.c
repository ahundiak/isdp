#include<stdio.h>
#include<math.h>
#include<alloca.h>
#include "PWminimum.h"
#include "PWerror.h"
#include<OMminimum.h>
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "maidmx.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsedgedef.h"

extern struct EMSintobj *EMdelintobj ( long  *, struct EMSintobj *);
extern void EMcmpinters ( long *, struct EMSinters  **);

/*
 *   Application function:  pwDeleteInt().
 *   -------------------------------------
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 */

PWresult   pwDeleteInt
(
   struct EMSinters **pp_inters
)
{
   long              msg_loc;
   unsigned int      retval;
   struct EMSinters  *p_inters_loc;
   struct EMSintobj  *p_intobj_loc;

   retval = PW_K_Success;

   p_inters_loc = *pp_inters;

   while( p_inters_loc )
   {
      p_intobj_loc = p_inters_loc->cvs;
      while( p_intobj_loc )
      {
         if( p_intobj_loc->props & EMSintobj_deletable )
         {
            p_intobj_loc = EMdelintobj( &msg_loc, p_intobj_loc );
            if( !(1&msg_loc) )
            {
               retval = SetError( 0, PW_K_Internal );
               goto wrapup;
            }
         }
         else
            p_intobj_loc = p_intobj_loc->next;
      }/* end of p_intobj_loc */
      p_inters_loc = p_inters_loc->next;
   }/* end of p_inetes_loc */

   EMcmpinters( &msg_loc, &pp_inters[0]);
   if( !(1&msg_loc) )
   {
      retval = SetError( 0, PW_K_Internal );
      goto wrapup;
   }

   EMcmpinters( &msg_loc, &pp_inters[1]);
   if( !(1&msg_loc) )
   {
      retval = SetError( 0, PW_K_Internal );
      goto wrapup;
   }
   wrapup:
   return retval;
}/* end of function pwDeleteInt */
