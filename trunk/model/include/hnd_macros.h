
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/*
 * MACROS for the NC dexelizer functions.
 */


/*---DEXELIZER_VARIABLES-----------------------------------------------------*/

#define DEXELIZER_VARIABLES                                            \
                                                                       \
   int                           rxa, rxb, dxa, dxb;                   \
   int                           rsa, rsb, dsa, dsb;                   \
                                                                       \
   int                           shade, c1, c2;                        \
   char                          dither;                               \
                                                                       \
   int                           dxc, dxd;                             \
   int                           rsc, rsd, dsc;                        \
   int                           dx, dy, ds;                           \
                                                                       \
   int                           offset;                               \
   int                           using_ptc;                            \
                                                                       \
   struct HSfixedpt              rza, rzb, rzc;                        \
                                                                       \
   struct NCdexel                *prev, *curr;                         \
   unsigned char                 tmpadd_hi;                            \
   unsigned short                tmpadd_lo;                            \
                                                                       \
   register int                  x, y;                                 \
   register int                  xleft, xright;                        \
                                                                       \
   register struct NCdexel       *dexel;                               \
   register struct NCsim_dexel   *simdex;                              \
   register struct NCsim_dexel   *shadex                               \
   register NCcbuf               *cb;                                  \
   register NCzbuf               *zb, *zb2;


/*---TRANSLUCENT-------------------------------------------------------------*/

/*
 *  Perform the translucency test.  Will work for both wide and narrow spacing.
 *  In the wide case, uses the pattern buffer, trans_pat6.  For narrow spacing
 *  we exclusive or the x and y value, look at the first bit, and if it is
 *  set, turn the pixel on.
 */

#define TRANSLUCENT( x, y )                                            \
   (                                                                   \
      ((tiling_parms.processing_mode & HS_PMODE_TRANS_1x1) ?           \
                        ((x ^ y) & 1) : (!trans_pat4[y%4][x%4]))       \
   )
       

/*---GET_CONST_HT_COLOR------------------------------------------------------*/

#define GET_CONST_HT_COLOR (dither & 1) ? (c1) : (c2)


/*---GET_CONST_DM_COLOR_PTC--------------------------------------------------*/

/*Get the dithered color*/
#define GET_CONST_DM_COLOR_PTC                                         \
(                                                                      \
   IGErgb_to_index(active_window->context_no,                          \
                   x,                                                  \
                   y,                                                  \
                  (element_parms.red*tile->shade0)>>8,                 \
                  (element_parms.green*tile->shade0)>>8,               \
                  (element_parms.blue*tile->shade0)>>8 )               \
)


/*---GET_CONST_DM_COLOR_RAMP-------------------------------------------------*/

#define GET_CONST_DM_COLOR_RAMP    c1


/*---GET_SMOOTH_HT_COLOR-----------------------------------------------------*/

#define GET_SMOOTH_HT_COLOR                                            \
(                                                                      \
   ((rsc >> 16) % 16) <= pattern[(y)%4][(x)%4] ?                       \
                  (NCshading.active_color + ((rsc) >> 20))  :          \
                  (NCshading.active_color + ((rsc) >> 20) + 1)         \
)


/*---GET_SMOOTH_DM_COLOR_PTC-------------------------------------------------*/

/* Get the dithered color */

#define GET_SMOOTH_DM_COLOR_PTC                                        \
(                                                                      \
   IGErgb_to_index(active_window->context_no,                          \
                   x,                                                  \
                   y,                                                  \
                  (element_parms.red*rsc)>>24,                         \
                  (element_parms.green*rsc)>>24,                       \
                  (element_parms.blue*rsc)>>24)                        \
)

/*---GET_SMOOTH_DM_COLOR_RAMP------------------------------------------------*/

#define GET_SMOOTH_DM_COLOR_RAMP                                       \
(                                                                      \
   NCshading.active_color + (rsc >> 16)                                \
)

/*---ASSIGN_CONST_HT_DEXEL---------------------------------------------------*/

#define ASSIGN_CONST_HT_DEXEL(dexel)                                   \
                                                                       \
{                                                                      \
   dexel->u.z.near_z = dexel->u.z.far_z = (NCzbuf)rzc.active;          \
   dexel->color = GET_CONST_HT_COLOR;                                  \
}

/*---ASSIGN_CONST_DM_DEXEL---------------------------------------------------*/

#define ASSIGN_CONST_DM_DEXEL(dexel)                                   \
                                                                       \
{                                                                      \
   dexel->u.z.near_z = (NCzbuf)rzc.active;                             \
   dexel->u.z.far_z = (NCzbuf)rzc.active;                              \
   if( using_ptc )                                                     \
   {                                                                   \
      dexel->color = GET_CONST_DM_COLOR_PTC;                           \
   }                                                                   \
   else                                                                \
   {                                                                   \
      dexel->color = GET_CONST_DM_COLOR_RAMP;                          \
   }                                                                   \
}


/*---ASSIGN_CONST_HT_SIM_DEXEL_FRONT------------- 09/24/88 KMJ --------------*/

#define ASSIGN_CONST_HT_SIM_DEXEL_FRONT(simdex)                        \
                                                                       \
{                                                                      \
   simdex->near_z = simdex->far_z = (NCzbuf)rzc.active;                \
   if( using_ptc )                                                     \
   {                                                                   \
      simdex->far_c = GET_CONST_DM_COLOR_PTC;                          \
      simdex->near_c = GET_CONST_DM_COLOR_PTC;                         \
   }                                                                   \
   else                                                                \
   {                                                                   \
      simdex->far_c = GET_CONST_HT_COLOR;                              \
      simdex->near_c = GET_CONST_HT_COLOR;                             \
   }                                                                   \
}

/*---ASSIGN_CONST_DM_SIM_DEXEL_FRONT------------- 09/24/88 KMJ --------------*/

#define ASSIGN_CONST_DM_SIM_DEXEL_FRONT(simdex)                        \
                                                                       \
{                                                                      \
   simdex->near_z = simdex->far_z = (NCzbuf)rzc.active;                \
   if( using_ptc )                                                     \
   {                                                                   \
      simdex->far_c = GET_CONST_DM_COLOR_PTC;                          \
      simdex->near_c = GET_CONST_DM_COLOR_PTC;                         \
   }                                                                   \
   else                                                                \
   {                                                                   \
      simdex->far_c = GET_CONST_DM_COLOR_RAMP;                         \
      simdex->near_c = GET_CONST_DM_COLOR_RAMP;                        \
   }                                                                   \
}

/*---ASSIGN_CONST_HT_SIM_DEXEL_BACK-------------- 09/24/88 KMJ --------------*/

#define ASSIGN_CONST_HT_SIM_DEXEL_BACK(simdex)                         \
                                                                       \
{                                                                      \
   simdex->far_z = (NCzbuf)rzc.active;                                 \
   simdex->far_c = GET_CONST_HT_COLOR;                                 \
}


/*---ASSIGN_CONST_DM_SIM_DEXEL_BACK-------------- 09/24/88 KMJ---------------*/

#define ASSIGN_CONST_DM_SIM_DEXEL_BACK(simdex)                         \
                                                                       \
{                                                                      \
   simdex->far_z = (NCzbuf)rzc.active;                                 \
   if( using_ptc )                                                     \
   {                                                                   \
      simdex->far_c = GET_CONST_DM_COLOR_PTC;                          \
   }                                                                   \
   else                                                                \
   {                                                                   \
      simdex->far_c = GET_CONST_DM_COLOR_RAMP;                         \
   }                                                                   \
}


/*---ASSIGN_SMOOTH_HT_DEXEL--------------------------------------------------*/

#define ASSIGN_SMOOTH_HT_DEXEL(dexel)                                  \
                                                                       \
{                                                                      \
   dexel->u.z.near_z = dexel->u.z.far_z = (NCzbuf)rzc.active;          \
   dexel->color = GET_SMOOTH_HT_COLOR;                                 \
}


/*---ASSIGN_SMOOTH_DM_DEXEL--------------------------------------------------*/

#define ASSIGN_SMOOTH_DM_DEXEL(dexel)                                  \
                                                                       \
{                                                                      \
   dexel->u.z.near_z = dexel->u.z.far_z = (NCzbuf)rzc.active;          \
                                                                       \
   if( using_ptc)                                                      \
   {                                                                   \
      dexel->color = GET_SMOOTH_DM_COLOR_PTC;                          \
   }                                                                   \
   else                                                                \
   {                                                                   \
      dexel->color = GET_SMOOTH_DM_COLOR_RAMP;                         \
   }                                                                   \
}


/*---ASSIGN_SMOOTH_DM_SIM_DEXEL_FRONT--------- 09/24/88 KMJ -----------------*/

/*
#define ASSIGN_SMOOTH_DM_SIM_DEXEL_FRONT(simdex)                       \
                                                                       \
{                                                                      \
   simdex->near_z = simdex->far_z = (NCzbuf)rzc.active;                \
                                                                       \
   if( using_ptc)                                                      \
   {                                                                   \
      simdex->near_c = GET_SMOOTH_DM_COLOR_PTC;                        \
      simdex->far_c = GET_SMOOTH_DM_COLOR_PTC;                         \
   }                                                                   \
   else                                                                \
   {                                                                   \
      simdex->near_c = GET_SMOOTH_DM_COLOR_RAMP;                       \
      simdex->far_c = GET_SMOOTH_DM_COLOR_RAMP;                        \
   }                                                                   \   
}
*/


/*---ASSIGN_SMOOTH_DM_SIM_DEXEL_BACK----------- 09/24/88 KMJ ----------------*/
/*
#define ASSIGN_SMOOTH_DM_SIM_DEXEL_BACK(simdex)                        \
                                                                       \
{                                                                      \
   simdex->far_z = (NCzbuf)rzc.active;                                 \
                                                                       \
   if( using_ptc)                                                      \
   {                                                                   \
      simdex->far_c = GET_SMOOTH_DM_COLOR_PTC;                         \
   }                                                                   \
   else                                                                \
   {                                                                   \
      simdex->far_c = GET_SMOOTH_DM_COLOR_PTC;                         \
   }                                                                   \   
}
*/

/*---INIT_Z_VARIABLE---------------------------------------------------------*/

#define INIT_Z_VARIABLE                                                \
                                                                       \
{                                                                      \
   rzc.active = rza.active;                                            \
   rzc.running = rza.running;                                          \
}


/*---INIT_X_VARIABLE---------------------------------------------------------*/

#define INIT_X_VARIABLE                                                \
                                                                       \
{                                                                      \
   xleft = rxa >> 16;                                                  \
   xright = rxb >> 16;                                                 \
}


/*---INIT_SHADE_VARIABLE-----------------------------------------------------*/

#define INIT_SHADE_VARIABLE                                            \
                                                                       \
{                                                                      \
   rsc = rsa;                                                          \
}


/*---ADJUST_XY---------------------------------------------------------------*/

/*
 *  Adjust the x,y values of the trapezoid to fit the dexel array.
 */

#define ADJUST_XY                                                      \
                                                                       \
{                                                                      \
   tile->x0 -= NCwindow.dorg_x;                                        \
   tile->x1 -= NCwindow.dorg_x;                                        \
   tile->x2 -= NCwindow.dorg_x;                                        \
   tile->x3 -= NCwindow.dorg_x;                                        \
   tile->ya -= NCwindow.dorg_y;                                        \
   tile->yb -= NCwindow.dorg_y;                                        \
}


/*---ADJUST_SIM_XYZ----------------------------------------------------------*/

/*
 *  Adjust the x,y,z values of the trapezoid to fit the simulation buffer.
 */

#define ADJUST_SIM_XYZ                                                 \
                                                                       \
{                                                                      \
   tile->x0 -= (NCwindow.sorg_x - NCwindow.dorg_x);                    \
   tile->x1 -= (NCwindow.sorg_x - NCwindow.dorg_x);                    \
   tile->x2 -= (NCwindow.sorg_x - NCwindow.dorg_x);                    \
   tile->x3 -= (NCwindow.sorg_x - NCwindow.dorg_x);                    \
   tile->ya -= (NCwindow.sorg_y - NCwindow.dorg_y);                    \
   tile->yb -= (NCwindow.sorg_y - NCwindow.dorg_y);                    \
}


/*---SCALE_CONST_HT_SHADE----------------------------------------------------*/

/*
 *  Scale the constant shade.
 */

#define SCALE_CONST_HT_SHADE                                           \
                                                                       \
{                                                                      \
   shade = tile->shade0 ^ 0xff;                                        \
   shade = ( shade * NCshading.apparent_shades ) >> 8;                 \
   c1 = NCshading.active_color + (shade >> 4);                         \
   c2 = c1 + 1;                                                        \
   shade %= 16;                                                        \
}

/*---SCALE_CONST_DM_SHADE----------------------------------------------------*/

/*
 *  Scale the constant shade.
 */

#define SCALE_CONST_DM_SHADE                                           \
                                                                       \
{                                                                      \
   c1 = NCshading.active_color +                                       \
        (((tile->shade0 ^ 0xff) * NCshading.apparent_shades) >> 8);    \
}

/*---SCALE_SMOOTH_SHADE_PTC--------------------------------------------------*/

/*Shift intensity 16 to keep more accuracy during calculations*/
#define SCALE_SMOOTH_SHADE_PTC                                         \
                                                                       \
{                                                                      \
   rsa = ( (tile->shade2)  ) << 16;                                    \
   rsb = ( (tile->shade3)  ) << 16;                                    \
   rsc = ( (tile->shade0)  ) << 16;                                    \
   rsd = ( (tile->shade1)  ) << 16;                                    \
}


/*---SCALE_SMOOTH_SHADE_RAMP--------------------------------------------------*/

/*Shift intensity 16 to keep more accuracy during calculations*/
#define SCALE_SMOOTH_SHADE_RAMP                                        \
                                                                       \
{                                                                      \
   rsa = ( (tile->shade2 ^ 0xff) * NCshading.apparent_shades ) << 8;   \
   rsb = ( (tile->shade3 ^ 0xff) * NCshading.apparent_shades ) << 8;   \
   rsc = ( (tile->shade0 ^ 0xff) * NCshading.apparent_shades ) << 8;   \
   rsd = ( (tile->shade1 ^ 0xff) * NCshading.apparent_shades ) << 8;   \
}


/*---CALC_DZ_DX--------------------------------------------------------------*/

/*
 *  Calculate the delta change in z for a single step in x.
 *  If the x coordinate are equal, then set the delta to 0.
 */

#define CALC_DZ_DX                                                     \
                                                                       \
{                                                                      \
   if( (dxc = xright - xleft) == 0 )                                   \
   {                                                                   \
      rzc.sign = 1;                                                    \
      rzc.d_whole = 0;                                                 \
      rzc.d_fract = 0;                                                 \
      rzc.running = 0;                                                 \
   }                                                                   \
   else                                                                \
   {                                                                   \
      fixed_divide((rzb.active - rza.active),                          \
                    dxc,                                               \
                    &rzc.sign,                                         \
                    &rzc.d_whole,                                      \
                    &rzc.d_fract );                                    \
   }                                                                   \
}


/*---CALC_DSHADE_DX----------------------------------------------------------*/

/*
 *  Calculate the change in shade with respect to x.
 *  If the x coordinate are equal, then set the delta to 0.
 */

#define CALC_DSHADE_DX                                                 \
                                                                       \
{                                                                      \
   if( (dx = xright - xleft) == 0 )                                    \
   {                                                                   \
      dsc = 0;                                                         \
   }                                                                   \
   else                                                                \
   {                                                                   \
      dsc = ( rsb - rsc ) / dx;                                        \
   }                                                                   \
}


/*---CALC_DXDY_DZDY(_DSDY)---------------------------------------------------*/

/*
 *  Calculate the delta change in x, z (and shade) for a single step in y.
 *  If the y coordinate are equal, then set the deltas to 0.
 */

#define CALC_DXDY_DZDY                                                 \
                                                                       \
{                                                                      \
   if( ( dy = (tile->ya - tile->yb)) == 0 )                            \
   {                                                                   \
      dxa = 0;                                                         \
      dxb = 0;                                                         \
                                                                       \
      rza.sign = 1;                                                    \
      rza.d_whole = 0;                                                 \
      rza.d_fract = 0;                                                 \
      rza.running = 0;                                                 \
                                                                       \
      rzb.sign = 1;                                                    \
      rzb.d_whole = 0;                                                 \
      rzb.d_fract = 0;                                                 \
      rzb.running = 0;                                                 \
   }                                                                   \
   else                                                                \
   {                                                                   \
      dxa = ( tile->x0 - tile->x2 ) / dy;                              \
      dxb = ( tile->x1 - tile->x3 ) / dy;                              \
                                                                       \
      fixed_divide((tile->z0 - tile->z2),                              \
                   dy,                                                 \
                   &rza.sign,                                          \
                   &rza.d_whole,                                       \
                   &rza.d_fract );                                     \
                                                                       \
      rza.running = 0x40000000;                                        \
                                                                       \
      fixed_divide((tile->z1 - tile->z3),                              \
                   dy,                                                 \
                   &rzb.sign,                                          \
                   &rzb.d_whole,                                       \
                   &rzb.d_fract );                                     \
                                                                       \
      rzb.running = 0x40000000;                                        \
   }                                                                   \
                                                                       \
   rza.active = tile->z2;                                              \
   rzb.active = tile->z3;                                              \
                                                                       \
   rxa = tile->x2 + 32768;                                             \
   rxb = tile->x3 + 32768;                                             \
}

#define   CALC_DXDY_DZDY_DSDY                                          \
                                                                       \
{                                                                      \
   if( ( dy = tile->ya - tile->yb ) == 0 )                             \
   {                                                                   \
      dxa = 0;                                                         \
      dsa = 0;                                                         \
                                                                       \
      dxb = 0;                                                         \
      dsb = 0;                                                         \
                                                                       \
      rza.sign = 1;                                                    \
      rza.d_whole = 0;                                                 \
      rza.d_fract = 0;                                                 \
      rza.running = 0;                                                 \
                                                                       \
      rzb.sign = 1;                                                    \
      rzb.d_whole = 0;                                                 \
      rzb.d_fract = 0;                                                 \
      rzb.running = 0;                                                 \
   }                                                                   \
   else                                                                \
   {                                                                   \
      dxa = ( tile->x0 - tile->x2 ) / dy;                              \
      dsa = ( rsc - rsa ) / dy;                                        \
                                                                       \
      dxb = ( tile->x1 - tile->x3 ) / dy;                              \
      dsb = ( rsd - rsb ) / dy;                                        \
                                                                       \
      fixed_divide((tile->z0 - tile->z2),                              \
                   dy,                                                 \
                   &rza.sign,                                          \
                   &rza.d_whole,                                       \
                   &rza.d_fract );                                     \
                                                                       \
      rza.running = 0x40000000;                                        \
                                                                       \
      fixed_divide((tile->z1 - tile->z3),                              \
                   dy,                                                 \
                   &rzb.sign,                                          \
                   &rzb.d_whole,                                       \
                   &rzb.d_fract );                                     \
                                                                       \
      rzb.running = 0x40000000;                                        \
   }                                                                   \
                                                                       \
   rza.active = tile->z2;                                              \
   rzb.active = tile->z3;                                              \
                                                                       \
   rxa = tile->x2 + 32768;                                             \
   rxb = tile->x3 + 32768;                                             \
}
