
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "hnmilling.h"
#include "hntoolpath.h"
#include "hnd_macros.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSpr_ncv_fun.h"

/*---------------------------
 *  for functions
 *     fixed_divide
 */
 
#include "HSpr_display.h"

/*--------------------------*/


extern struct NC_window_parms    NCwindow;
extern struct NC_shading_parms   NCshading;
extern struct NC_toolpath_data   NCtoolpath_data;
extern struct NCdexel            *NCget_next_dexel();

   
/*---CALC_BLOCK_BACK_ADDRESSES------------------------------------------------*/

#define CALC_BLOCK_BACK_ADDRESSES                                        \
                                                                         \
{                                                                        \
   dexel = NCwindow.dexarry + (y * NCwindow.dx_dits + xleft);            \
}

/*---MOVE_TO_THE_NEXT_BLOCK_BACK_DEXEL----------------------------------------*/

#define MOVE_TO_THE_NEXT_BLOCK_BACK_DEXEL                                \
                                                                         \
{                                                                        \
   Fixed_add( rzc );                                                     \
   dexel++;                                                              \
}
      
/*---UPDATE_BLOCK_BACK_DEXEL--------------------------------------------------*/

#define UPDATE_BLOCK_BACK_DEXEL                                          \
                                                                         \
{                                                                        \
   if ( ( dexel->u.z.near_z != NCbackground_z ) &&                       \
        ( dexel->u.z.near_z < (NCzbuf)rzc.active ) )                     \
   {                                                                     \
      prev = dexel;                                                      \
      for ( curr = NCget_next_dexel(dexel);                              \
            ((curr) && (curr->u.z.near_z < (NCzbuf)rzc.active ) );       \
            prev = curr, curr = NCget_next_dexel(prev) );                \
                                                                         \
      if ( ( curr ) &&                                                   \
           ( curr->u.z.near_z == (NCzbuf)rzc.active ) )                  \
      {                                                                  \
         if ( curr->u.z.far_z > (NCzbuf)rzc.active )                     \
         {                                                               \
            prev->u.z.far_z = curr->u.z.far_z;                           \
         }                                                               \
                                                                         \
         /* need to put curr's own address in its next field */          \
         tmpadd_hi = curr->next_hi;                                      \
         curr->next_hi = prev->next_hi;                                  \
         prev->next_hi = tmpadd_hi;                                      \
         tmpadd_lo = curr->next_lo;                                      \
         curr->next_lo = prev->next_lo;                                  \
         prev->next_lo = tmpadd_lo;                                      \
         NCfree_dexel(&curr);                                            \
      }                                                                  \
      else if ( prev->u.z.far_z < (NCzbuf)rzc.active )                   \
      {                                                                  \
         prev->u.z.far_z = (NCzbuf)rzc.active;                           \
      }                                                                  \
   }                                                                     \
}

/*---FILL_UP_BLOCK_BACK-------------------------------------------------------*/

#define FILL_UP_BLOCK_BACK( y )                                          \
                                                                         \
{                                                                        \
   if( (dxc = rxa - rxb) == 0 )                                          \
   {                                                                     \
      rzc.sign = 1;                                                      \
      rzc.d_whole = 0;                                                   \
      rzc.d_fract = 0;                                                   \
   }                                                                     \
   else                                                                  \
   {                                                                     \
      fixed_divide((rza.active - rzb.active),                            \
                    dxc,                                                 \
                    &rzc.sign,                                           \
                    &rzc.d_whole,                                        \
                    &rzc.d_fract );                                      \
   }                                                                     \
                                                                         \
   rzc.running = 0x40000000;                                             \
   rzc.active = rzb.active;                                              \
                                                                         \
   xleft = rxb >> 16;                                                    \
   xright = rxa >> 16;                                                   \
                                                                         \
   CALC_BLOCK_BACK_ADDRESSES                                             \
                                                                         \
   for( x=xleft; x<=xright; x++ )                                        \
   {                                                                     \
      UPDATE_BLOCK_BACK_DEXEL                                            \
      MOVE_TO_THE_NEXT_BLOCK_BACK_DEXEL                                  \
   }                                                                     \
}
   
/*---MOVE_UP_TO_THE_NEXT_BLOCK_BACK_ROW---------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_BLOCK_BACK_ROW                               \
                                                                         \
{                                                                        \
   rxa += dxa;                                                           \
   Fixed_add( rza );                                                     \
                                                                         \
   if( rxb < rxa && y != tile->ya )                                      \
   {                                                                     \
      FILL_UP_BLOCK_BACK ( (y+1) )                                       \
   }                                                                     \
   rxb += dxb;                                                           \
   Fixed_add( rzb );                                                     \
}
   

/*---NCupdate_block_back_dexels-----------------------------------------------*/

void NCupdate_block_back_dexels( struct trapezoid *tile )

{
   int                       rxa;
   int                       rxb;
   int                       dxa;
   int                       dxb;

   int                       dxc;
   int                       dy;

   struct HSfixedpt          rza;
   struct HSfixedpt          rzb;
   struct HSfixedpt          rzc;

   struct NCdexel            *prev;
   struct NCdexel            *curr;
   unsigned char             tmpadd_hi;      
   unsigned short            tmpadd_lo;

   register int              x;
   register int              y;
   register int              xleft;
   register int              xright;
                     
   register struct NCdexel   *dexel;


   ADJUST_XY

   CALC_DXDY_DZDY
      
   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y <= tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX
      
      CALC_BLOCK_BACK_ADDRESSES
      
      for( x = xleft; x <= xright; x++ )
      {
         UPDATE_BLOCK_BACK_DEXEL
         MOVE_TO_THE_NEXT_BLOCK_BACK_DEXEL
      }

      MOVE_UP_TO_THE_NEXT_BLOCK_BACK_ROW            
   }
}


/*---CALC_SWVOL_FRONT_ADDRESSES-----------------------------------------------*/

#define CALC_SWVOL_FRONT_ADDRESSES                                      \
                                                                        \
{                                                                       \
   zb = NCwindow.zbuf + (offset = (y) * NCwindow.dx_dits + xleft);      \
   zb2 = NCwindow.zbuf2 + offset;                                       \
   dexel = NCwindow.dexarry + offset;                                   \
}

/*---MOVE_TO_THE_NEXT_SWVOL_FRONT_DEXEL---------------------------------------*/

#define MOVE_TO_THE_NEXT_SWVOL_FRONT_DEXEL                              \
                                                                        \
{                                                                       \
   Fixed_add( rzc );                                                    \
                                                                        \
   zb++;                                                                \
   zb2++;                                                               \
   dexel++;                                                             \
}
      
/*---UPDATE_SWVOL_FRONT_DEXEL-------------------------------------------------*/

#define UPDATE_SWVOL_FRONT_DEXEL                                       \
                                                                       \
{                                                                      \
   if (*zb == NCbackground_z)                                          \
   {                                                                   \
      if (dexel->u.z.near_z != NCbackground_z)                         \
      {                                                                \
         *zb = (NCzbuf)rzc.active;                                     \
      }                                                                \
   }                                                                   \
   else                                                                \
   {                                                                   \
      if (NCtoolpath_data.five_axis)                                   \
      {                                                                \
         if (*zb != (NCzbuf)rzc.active)                                \
         {                                                             \
            if (*zb2 == NCbackground_z)                                \
            {                                                          \
               if (*zb > (NCzbuf)rzc.active)                           \
               {                                                       \
                  *zb2 = *zb;                                          \
                  *zb = (NCzbuf)rzc.active;                            \
               }                                                       \
               else                                                    \
               {                                                       \
                  *zb2 = (NCzbuf)rzc.active;                           \
               }                                                       \
            }                                                          \
            else                                                       \
            {                                                          \
               if (*zb > (NCzbuf)rzc.active)                           \
               {                                                       \
                  *zb = (NCzbuf)rzc.active;                            \
               }                                                       \
               else if (*zb2 < (NCzbuf)rzc.active)                     \
               {                                                       \
                  *zb2 = (NCzbuf)rzc.active;                           \
               }                                                       \
            }                                                          \
         }                                                             \
      }                                                                \
      else                                                             \
      {                                                                \
         if (*zb > (NCzbuf)rzc.active)                                 \
         {                                                             \
            *zb = (NCzbuf)rzc.active;                                  \
         }                                                             \
      }                                                                \
   }                                                                   \
}

/*---FILL_UP_SWVOL_FRONT------------------------------------------------------*/

#define FILL_UP_SWVOL_FRONT( y )                                       \
                                                                       \
{                                                                      \
   if( (dxc = rxa - rxb) == 0 )                                        \
   {                                                                   \
      rzc.sign = 1;                                                    \
      rzc.d_whole = 0;                                                 \
      rzc.d_fract = 0;                                                 \
   }                                                                   \
   else                                                                \
   {                                                                   \
      fixed_divide( (rza.active - rzb.active),                         \
                    dxc,                                               \
                    &rzc.sign,                                         \
                    &rzc.d_whole,                                      \
                    &rzc.d_fract );                                    \
   }                                                                   \
                                                                       \
   rzc.running = 0x40000000;                                           \
   rzc.active = rzb.active;                                            \
                                                                       \
   xleft = rxb >> 16;                                                  \
   xright = rxa >> 16;                                                 \
                                                                       \
   CALC_SWVOL_FRONT_ADDRESSES                                          \
                                                                       \
   for( x=xleft; x<=xright; x++ )                                      \
   {                                                                   \
      UPDATE_SWVOL_FRONT_DEXEL                                         \
      MOVE_TO_THE_NEXT_SWVOL_FRONT_DEXEL                               \
   }                                                                   \
}
   
/*---MOVE_UP_TO_THE_NEXT_SWVOL_FRONT_ROW--------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_SWVOL_FRONT_ROW                            \
                                                                       \
{                                                                      \
   rxa += dxa;                                                         \
   Fixed_add( rza );                                                   \
                                                                       \
   if( rxb < rxa && y != tile->ya )                                    \
   {                                                                   \
      FILL_UP_SWVOL_FRONT ( (y+1) )                                    \
   }                                                                    \
   rxb += dxb;                                                         \
   Fixed_add( rzb );                                                   \
}


/*---NCupdate_swvol_front_dexels----------------------------------------------*/

void NCupdate_swvol_front_dexels( struct trapezoid *tile )

{
   int                      rxa;
   int                      rxb;
   int                      dxa;
   int                      dxb;

   int                      dxc;
   int                      dy;

   int                      offset;

   struct HSfixedpt         rza;
   struct HSfixedpt         rzb;
   struct HSfixedpt         rzc;

   register int             x;
   register int             y;
   register int             xleft;
   register int             xright;

   register struct NCdexel  *dexel;
   register NCzbuf          *zb;
   register NCzbuf          *zb2;



   CALC_DXDY_DZDY
      
   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y <= tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX

      /*
       *  Calculate the address in the near-z buffer of the left most value 
       *  of the current row and the corresponding dexel.
       */

      CALC_SWVOL_FRONT_ADDRESSES
            
      for( x=xleft; x <= xright; x++ )
      {
         UPDATE_SWVOL_FRONT_DEXEL
         MOVE_TO_THE_NEXT_SWVOL_FRONT_DEXEL
      }

      MOVE_UP_TO_THE_NEXT_SWVOL_FRONT_ROW            
   }
}

