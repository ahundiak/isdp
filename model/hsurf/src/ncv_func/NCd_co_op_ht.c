
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#include "hnmilling.h"
#include "hnsimulate.h"
#include "hntoolpath.h"
#include "hnd_macros.h"
#include "HStl_window.h"
#include "hsmath.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HStl_element.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSpr_ncv_fun.h"

/*--------------------------
 *  for function
 *     fixed_divide
 */

#include "HSpr_display.h"

/*--------------------------*/


extern struct NC_window_parms    NCwindow;
extern struct NC_shading_parms   NCshading;
extern struct NC_toolpath_data   NCtoolpath_data;
extern struct NC_sim_data        NCsim_data;
extern struct NCdexel            *NCget_next_dexel();
static int                       x_px, y_py;

extern unsigned char patterns[4][16][4];

/*---CALC_BLOCK_FRONT_ADDRESSES-----------------------------------------------*/

#define CALC_BLOCK_FRONT_ADDRESSES                                        \
                                                                          \
{                                                                         \
   dexel = NCwindow.dexarry + (offset = (y) * NCwindow.dx_dits + xleft);  \
   cb = NCwindow.cbuf + offset;                                           \
}

/*---MOVE_TO_THE_NEXT_BLOCK_FRONT_DEXEL---------------------------------------*/

#define MOVE_TO_THE_NEXT_BLOCK_FRONT_DEXEL                                \
                                                                          \
{                                                                         \
   Fixed_add( rzc );                                                      \
                                                                          \
   dexel++;                                                               \
   cb++;                                                                  \
                                                                          \
   dither = CSHIFT( dither );                                             \
}

/*---UPDATE_BLOCK_FRONT_DEXEL--------------------------------------------------*/

#define UPDATE_BLOCK_FRONT_DEXEL                                          \
                                                                          \
{                                                                         \
   if (dexel->u.z.near_z==NCbackground_z)                                 \
   {                                                                      \
      ASSIGN_CONST_HT_DEXEL(dexel)                                        \
      *cb = dexel->color;                                                 \
   }                                                                      \
   else                                                                   \
   {                                                                      \
      if (dexel->u.z.near_z > (NCzbuf) rzc.active)                        \
      {                                                                   \
         NCalloc_dexel(&curr);                                            \
         tmpadd_hi = curr->next_hi;                                       \
         tmpadd_lo = curr->next_lo;                                       \
         curr->next_hi = dexel->next_hi;                                  \
         curr->next_lo = dexel->next_lo;                                  \
         dexel->next_hi = tmpadd_hi;                                      \
         dexel->next_lo = tmpadd_lo;                                      \
                                                                          \
         curr->u.z.near_z = dexel->u.z.near_z;                            \
         curr->u.z.far_z = dexel->u.z.far_z;                              \
         curr->color = dexel->color;                                      \
                                                                          \
         ASSIGN_CONST_HT_DEXEL(dexel)                                     \
         *cb = dexel->color;                                              \
      }                                                                   \
      else if (dexel->u.z.near_z != (NCzbuf) rzc.active)                  \
      {                                                                   \
         prev = dexel;                                                    \
         for ( curr = NCget_next_dexel(dexel);                            \
               (curr) &&  (curr->u.z.near_z < (unsigned int)rzc.active);  \
               prev = curr, curr = NCget_next_dexel(prev) );              \
         NCalloc_dexel(&curr);                                            \
         tmpadd_hi = curr->next_hi;                                       \
         tmpadd_lo = curr->next_lo;                                       \
         curr->next_hi = prev->next_hi;                                   \
         curr->next_lo = prev->next_lo;                                   \
         prev->next_hi = tmpadd_hi;                                       \
         prev->next_lo = tmpadd_lo;                                       \
                                                                          \
         ASSIGN_CONST_HT_DEXEL(curr)                                      \
      }                                                                   \
   }                                                                      \
}

/*---FILL_UP_BLOCK_FRONT------------------------------------------------------*/

#define FILL_UP_BLOCK_FRONT( y )                                          \
                                                                          \
{                                                                         \
   if( (dxc = rxa - rxb) == 0 )                                           \
   {                                                                      \
      rzc.sign = 1;                                                       \
      rzc.d_whole = 0;                                                    \
      rzc.d_fract = 0;                                                    \
   }                                                                      \
   else                                                                   \
   {                                                                      \
      fixed_divide((rza.active - rzb.active),                             \
                    dxc,                                                  \
                    &rzc.sign,                                            \
                    &rzc.d_whole,                                         \
                    &rzc.d_fract );                                       \
   }                                                                      \
                                                                          \
   rzc.running = 0x40000000;                                              \
   rzc.active = rzb.active;                                               \
                                                                          \
   xleft = rxb >> 16;                                                     \
   xright = rxa >> 16;                                                    \
                                                                          \
   CALC_BLOCK_FRONT_ADDRESSES                                             \
                                                                          \
   dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];                      \
                                                                          \
   for( x=xleft; x<=xright; x++ )                                         \
   {                                                                      \
      UPDATE_BLOCK_FRONT_DEXEL                                            \
      MOVE_TO_THE_NEXT_BLOCK_FRONT_DEXEL                                  \
   }                                                                      \
}

/*---MOVE_UP_TO_THE_NEXT_BLOCK_FRONT_ROW--------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_BLOCK_FRONT_ROW                               \
                                                                          \
{                                                                         \
   rxa += dxa;                                                            \
   Fixed_add( rza );                                                      \
                                                                          \
   if( rxb < rxa && y != tile->ya )                                       \
   {                                                                      \
      FILL_UP_BLOCK_FRONT ( (y+1) )                                       \
   }                                                                       \
   rxb += dxb;                                                            \
   Fixed_add( rzb );                                                      \
}


/*---NCupdate_const_ht_block_front_dexels-------------------------------------*/

void NCupdate_const_ht_block_front_dexels( struct trapezoid *tile )


{
   int                      rxa;
   int                      rxb;
   int                      dxa;
   int                      dxb;
   int                      shade;
   int                      c1;
   int                      c2;

   char                     dither;

   int                      dxc;
   int                      dy;

   int                      offset;

   struct HSfixedpt         rza;
   struct HSfixedpt         rzb;
   struct HSfixedpt         rzc;

   struct NCdexel           *prev;
   struct NCdexel           *curr;
   unsigned char            tmpadd_hi;
   unsigned short           tmpadd_lo;

   register int             x;
   register int             y;
   register int             xleft;
   register int             xright;

   register struct NCdexel  *dexel;
   register NCcbuf          *cb;


   ADJUST_XY

   SCALE_CONST_HT_SHADE

   CALC_DXDY_DZDY

   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y < tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX

      CALC_BLOCK_FRONT_ADDRESSES

      dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];

      for( x=xleft; x < xright; x++ )
      {
         UPDATE_BLOCK_FRONT_DEXEL
         MOVE_TO_THE_NEXT_BLOCK_FRONT_DEXEL
      }

      MOVE_UP_TO_THE_NEXT_BLOCK_FRONT_ROW
   }
}


/*---CALC_SWVOL_BACK_ADDRESSES------------------------------------------------*/

#define CALC_SWVOL_BACK_ADDRESSES                                       \
                                                                        \
{                                                                       \
   zb = NCwindow.zbuf + (offset = (y) * NCwindow.dx_dits + xleft);      \
   zb2 = NCwindow.zbuf2 + offset;                                       \
}

/*---MOVE_TO_THE_NEXT_SWVOL_BACK_DEXEL----------------------------------------*/

#define MOVE_TO_THE_NEXT_SWVOL_BACK_DEXEL                               \
                                                                        \
{                                                                       \
                                                                        \
   /*                                                                   \
    *  Move to the next pixel                                           \
    */                                                                  \
                                                                        \
   Fixed_add( rzc );                                                    \
                                                                        \
   zb++;                                                                \
   zb2++;                                                               \
   offset++;                                                            \
                                                                        \
   dither = CSHIFT( dither );                                           \
}


/*---UPDATE_SWVOL_BACK_DEXEL--------------------------------------------------*/

#define UPDATE_SWVOL_BACK_DEXEL                                         \
                                                                        \
{                                                                       \
   if ((*zb!=NCbackground_z) && (*zb < (NCzbuf)rzc.active ))            \
   {                                                                    \
      color = GET_CONST_HT_COLOR;                                       \
      if ((NCtoolpath_data.five_axis)   &&                              \
          ((*zb2 != NCbackground_z) && (*zb2 <= (NCzbuf)rzc.active)))   \
      {                                                                 \
         NCsubtract_dexel( *zb2,                                        \
                          (NCzbuf)rzc.active,                           \
                           color,                                       \
                           offset,                                      \
                           &update );                                   \
      }                                                                 \
      else                                                              \
      {                                                                 \
         NCsubtract_dexel( *zb,                                         \
                          (NCzbuf)rzc.active,                           \
                           color,                                       \
                           offset,                                      \
                           &update );                                   \
      }                                                                 \
   }                                                                    \
}

/*---FILL_UP_SWVOL_BACK-------------------------------------------------------*/

#define FILL_UP_SWVOL_BACK( y )                                         \
                                                                        \
{                                                                       \
   if( (dxc = rxa - rxb) == 0 )                                         \
   {                                                                    \
      rzc.sign = 1;                                                     \
      rzc.d_whole = 0;                                                  \
      rzc.d_fract = 0;                                                  \
   }                                                                    \
   else                                                                 \
   {                                                                    \
      fixed_divide((rza.active - rzb.active),                           \
                    dxc,                                                \
                    &rzc.sign,                                          \
                    &rzc.d_whole,                                       \
                    &rzc.d_fract );                                     \
   }                                                                    \
                                                                        \
   rzc.running = 0x40000000;                                            \
   rzc.active = rzb.active;                                             \
                                                                        \
   xleft = rxb >> 16;                                                   \
   xright = rxa >> 16;                                                  \
                                                                        \
   CALC_SWVOL_BACK_ADDRESSES                                            \
                                                                        \
   dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];                    \
                                                                        \
   for( x=xleft; x<=xright; x++ )                                       \
   {                                                                    \
      UPDATE_SWVOL_BACK_DEXEL                                           \
      MOVE_TO_THE_NEXT_SWVOL_BACK_DEXEL                                 \
   }                                                                    \
}

/*---MOVE_UP_TO_THE_NEXT_SWVOL_BACK_ROW---------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_SWVOL_BACK_ROW                              \
                                                                        \
{                                                                       \
                                                                        \
   /*                                                                   \
    *  Move up to the next row                                          \
    */                                                                  \
                                                                        \
   rxa += dxa;                                                          \
   Fixed_add( rza );                                                    \
                                                                        \
   if( rxb < rxa && y != tile->ya )                                     \
   {                                                                    \
      FILL_UP_SWVOL_BACK ( (y+1) )                                      \
   }                                                                    \
   rxb += dxb;                                                          \
   Fixed_add( rzb );                                                    \
}


/*---NCupdate_const_ht_swvol_back_dexels--------------------------------------*/

void NCupdate_const_ht_swvol_back_dexels( struct trapezoid *tile )

{
   int               rxa;
   int               rxb;
   int               dxa;
   int               dxb;

   int               shade;
   int               c1;
   int               c2;
   char              dither;

   int               dxc;
   int               dy;

   int               offset;

   struct HSfixedpt  rza;
   struct HSfixedpt  rzb;
   struct HSfixedpt  rzc;

   register int      x;
   register int      y;
   register int      xleft;
   register int      xright;

   register NCzbuf    *zb;
   register NCzbuf    *zb2;

   int               color;
   IGRboolean        update = FALSE;


   SCALE_CONST_HT_SHADE

   CALC_DXDY_DZDY

   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y < tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX

      CALC_SWVOL_BACK_ADDRESSES

      dither = patterns[ xleft % 4 ][ shade ][ y % 4 ];

      for( x = xleft; x < xright; x++ )
      {
         UPDATE_SWVOL_BACK_DEXEL
         MOVE_TO_THE_NEXT_SWVOL_BACK_DEXEL
      }

      if (update)
      {
         if (y < NCwindow.y_min)
         {
            NCwindow.y_min = y;
         }
         else if (y > NCwindow.y_max)
         {
            NCwindow.y_max = y;
         }

         update = FALSE;
      }
      MOVE_UP_TO_THE_NEXT_SWVOL_BACK_ROW
   }
}

/*   09/24/88   Added            KMJ         */

/*---CALC_TOOL_ADDRESSES------------------------------------------------------*/

#define CALC_TOOL_ADDRESSES                                            \
                                                                       \
{                                                                      \
   simdex = NCwindow.simbuf + (offset = (y)                            \
            * NCwindow.sx_dits + xleft);                               \
}

/*---MOVE_TO_THE_NEXT_TOOL_DEXEL----------------------------------------------*/

#define MOVE_TO_THE_NEXT_TOOL_DEXEL                                    \
                                                                       \
{                                                                      \
   Fixed_add( rzc );                                                   \
                                                                       \
   simdex++;                                                           \
                                                                       \
   dither = CSHIFT( dither );                                          \
}

/*---UPDATE_TOOL_FRONT_DEXEL--------------------------------------------------*/

#define UPDATE_TOOL_FRONT_DEXEL                                        \
                                                                       \
{                                                                      \
   if (simdex->near_z > (NCzbuf) rzc.active)                           \
   {                                                                   \
      ASSIGN_CONST_HT_SIM_DEXEL_FRONT(simdex)                          \
   }                                                                   \
}

/*---FILL_UP_TOOL_FRONT-------------------------------------------------------*/

#define FILL_UP_TOOL_FRONT( y )                                        \
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
      fixed_divide((rza.active - rzb.active),                          \
                   dxc,                                                \
                   &rzc.sign,                                          \
                   &rzc.d_whole,                                       \
                   &rzc.d_fract );                                     \
   }                                                                   \
                                                                       \
   rzc.running = 0x40000000;                                           \
   rzc.active = rzb.active;                                            \
                                                                       \
   xleft = rxb >> 16;                                                  \
   xright = rxa >> 16;                                                 \
                                                                       \
   CALC_TOOL_ADDRESSES                                                 \
                                                                       \
   dither = patterns[ x_px % 4 ][ shade ][ y_py % 4 ];                 \
                                                                       \
   for( x=xleft; x<=xright; x++ )                                      \
   {                                                                   \
      UPDATE_TOOL_FRONT_DEXEL                                          \
      MOVE_TO_THE_NEXT_TOOL_DEXEL                                      \
   }                                                                   \
}

/*---MOVE_UP_TO_THE_NEXT_TOOL_FRONT_ROW---------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_TOOL_FRONT_ROW                             \
                                                                       \
{                                                                      \
   rxa += dxa;                                                         \
   Fixed_add( rza );                                                   \
                                                                       \
   if( rxb < rxa && y != tile->ya )                                    \
   {                                                                   \
      FILL_UP_TOOL_FRONT( (y+1) )                                      \
   }                                                                   \
   rxb += dxb;                                                         \
   Fixed_add( rzb );                                                   \
}


/*---NCupdate_const_tool_front_dexels-----------------------------------------*/

void NCupdate_const_ht_tool_front_dexels( struct trapezoid *tile )

{
   int                          rxa;
   int                          rxb;
   int                          dxa;
   int                          dxb;

   int                          shade;
   int                          c1;
   int                          c2;
   char                         dither;

   int                          dxc;
   int                          dy;

   int                          offset;
   int                          using_ptc = TRUE;

   struct HSfixedpt             rza;
   struct HSfixedpt             rzb;
   struct HSfixedpt             rzc;

   register int                 x;
   register int                 y;
   register int                 xleft;
   register int                 xright;

   register struct NCsim_dexel  *simdex;


   if( IGEget_using_ramp_mode() )
   {
      using_ptc = FALSE;
   }

   ADJUST_SIM_XYZ

   SCALE_CONST_HT_SHADE

   CALC_DXDY_DZDY

   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y < tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX

      CALC_TOOL_ADDRESSES

      if (NCtoolpath_data.five_axis)
      {
         x_px = xleft + (NCsim_data.x_loc % 4);
         y_py = y     + (NCsim_data.y_loc % 4);
      }
      else
      {
         x_px = xleft;
         y_py = y;
      }

      dither = patterns[ x_px % 4 ][ shade ][ y_py % 4 ];

      for( x=xleft; x < xright; x++ )
      {
         UPDATE_TOOL_FRONT_DEXEL
         MOVE_TO_THE_NEXT_TOOL_DEXEL
      }

      MOVE_UP_TO_THE_NEXT_TOOL_FRONT_ROW
   }
}


/*---UPDATE_TOOL_BACK_DEXEL---------------------------------------------------*/

#define UPDATE_TOOL_BACK_DEXEL                                       \
                                                                     \
{                                                                    \
   if (simdex->far_z < (NCzbuf) rzc.active)                          \
   {                                                                 \
      ASSIGN_CONST_HT_SIM_DEXEL_BACK(simdex)                         \
   }                                                                 \
}

/*---FILL_UP_TOOL_BACK--------------------------------------------------------*/

#define FILL_UP_TOOL_BACK( y )                                       \
                                                                     \
{                                                                    \
   if( (dxc = rxa - rxb) == 0 )                                      \
   {                                                                 \
      rzc.sign = 1;                                                  \
      rzc.d_whole = 0;                                               \
      rzc.d_fract = 0;                                               \
   }                                                                 \
   else                                                              \
   {                                                                 \
      fixed_divide( (rza.active - rzb.active),                       \
                    dxc,                                             \
                    &rzc.sign,                                       \
                    &rzc.d_whole,                                    \
                    &rzc.d_fract );                                  \
   }                                                                 \
                                                                     \
   rzc.running = 0x40000000;                                         \
   rzc.active = rzb.active;                                          \
                                                                     \
   xleft = rxb >> 16;                                                \
   xright = rxa >> 16;                                               \
                                                                     \
   CALC_TOOL_ADDRESSES                                               \
                                                                     \
   dither = patterns[ x_px % 4 ][ shade ][ y_py % 4 ];               \
                                                                     \
   for( x=xleft; x<=xright; x++ )                                    \
   {                                                                 \
      UPDATE_TOOL_BACK_DEXEL                                         \
      MOVE_TO_THE_NEXT_TOOL_DEXEL                                    \
   }                                                                 \
}

/*---MOVE_UP_TO_THE_NEXT_TOOL_BACK_ROW----------------------------------------*/

#define MOVE_UP_TO_THE_NEXT_TOOL_BACK_ROW                            \
                                                                     \
{                                                                    \
   rxa += dxa;                                                       \
   Fixed_add( rza );                                                 \
                                                                     \
   if( rxb < rxa && y != tile->ya )                                  \
   {                                                                 \
      FILL_UP_TOOL_BACK ( (y+1) )                                    \
   }                                                                 \
   rxb += dxb;                                                       \
   Fixed_add( rzb );                                                 \
}


/*---NCupdate_const_ht_tool_back_dexels--------------------------------------*/

void NCupdate_const_ht_tool_back_dexels( struct trapezoid *tile )

{
   int                          rxa;
   int                          rxb;
   int                          dxa;
   int                          dxb;

   int                          shade;
   int                          c1;
   int                          c2;
   char                         dither;

   int                          dxc;
   int                          dy;

   int                          offset;

   struct HSfixedpt             rza;
   struct HSfixedpt             rzb;
   struct HSfixedpt             rzc;

   register int                 x;
   register int                 y;
   register int                 xleft;
   register int                 xright;

   register struct NCsim_dexel  *simdex;


   ADJUST_SIM_XYZ

   SCALE_CONST_HT_SHADE


   CALC_DXDY_DZDY

   /*
    *  Main loop, start at the bottom of the trapezoid and move up
    */

   for( y=tile->yb; y < tile->ya; y++ )
   {
      INIT_Z_VARIABLE
      INIT_X_VARIABLE
      CALC_DZ_DX

      CALC_TOOL_ADDRESSES

      if (NCtoolpath_data.five_axis)
      {
         x_px = xleft + (NCsim_data.x_loc % 4);
         y_py = y     + (NCsim_data.y_loc % 4);
      }
      else
      {
         x_px = xleft;
         y_py = y;
      }

      dither = patterns[ x_px % 4 ][ shade ][ y_py % 4 ];

      for( x=xleft; x < xright; x++ )
      {
         UPDATE_TOOL_BACK_DEXEL
         MOVE_TO_THE_NEXT_TOOL_DEXEL
      }

      MOVE_UP_TO_THE_NEXT_TOOL_BACK_ROW
   }
}



