
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/*
 * This header file contains the data structures unique to the NC verification
 * operation.
 */

#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"

#define NCbackground_z      0xffff

/* This was changed to a variable #define   NCbackground_c      0*/

#define NCbit_plane_mask    0xff
#define NCzbuf              unsigned short
#define NCcbuf              unsigned char


struct NCdexel                                /* dexel structure definition   */
{
   union
   {
      struct NCdexel      *next_free_dexel;   /* next dexel in the free list  */
      struct
      {
         NCzbuf            near_z, far_z;     /* the near and far z-values    */
      }                    z;                 /* the z-data structure         */
   }                       u;                 /* the data/pointer union       */
   unsigned short          next_lo;           /* the low bits of the next dex */
   unsigned char           next_hi;           /* the hi bits of the next dex  */
   NCcbuf                  color;             /* the color of the front face  */
};


struct NCsim_dexel            /* simulation dexel definition   */
{
   NCzbuf      near_z, far_z;      /* the near and far z-values   */
   NCcbuf      near_c, far_c;      /* the near and far colorvalues   */
};

typedef struct NCsim_dexel   simDexel;


/*
 * Data structure to keep track of NCV shading globals.
 */

struct   NC_shading_parms
{
   IGRboolean     ifb;                    /* the ifb flag               */

   unsigned int   SMOOTH_SHADING;         /* the smooth shading flag    */
   unsigned int   CONSTANT_SHADING;       /* the constant shading flag  */
   unsigned int   active_shading_style;   /* the active shading style   */

   IGRint         apparent_shades;        /* the num of apparent shades */
   IGRboolean     direct;                 /* the direct shading flag    */
   unsigned int   active_color;           /* the active color           */

   unsigned char  lineweight;             /* the active line weight     */
   unsigned char  linestyle;              /* the active line style      */

   unsigned int   active_red;             /* the active rgb             */
   unsigned int   active_green;
   unsigned int   active_blue;
};


/*
 * Data structure to keep track of NCV window parameters.
 */

struct   NC_window_parms
{
   IGRint              win_no;
   IGRint              pipe_no;
   IGRint              vsno;
   IGRdouble           win_tol;
   IGRdouble           z_scale;

                     /* PAINT REGION */
   IGRboolean          horizontal_scan;   /* horz/vrt scanline flag (sim) */
   IGRint              x_min;             /* paint region low */
   IGRint              y_min;

   IGRint              x_max;             /* paint region high */
   IGRint              y_max;

   IGRint              px_off;            /* paint region offset IN DITS */
   IGRint              py_off;

   IGRint              px_dits;           /* paint region extent in window */
   IGRint              py_dits;

                     /* DEXEL ARRAY */
   struct NCdexel      *dexarry;          /* base address of dexel array  */
   IGRint              dorg_x;            /* dexel array origin in window */
   IGRint              dorg_y;

   IGRint              dx_off;            /* dexel array offset IN DITS */
   IGRint              dy_off;

   IGRint              dx_dits;           /* dexel array extent in window */
   IGRint              dy_dits;

                     /* SIMULATION BUFFER */
   struct NCsim_dexel  *simbuf;           /* base address of simbuf */
   struct NCsim_dexel  *shadebuf;         /* shade buffer for tools */

   IGRint              sorg_x;            /* simbuf origin in window */
   IGRint              sorg_y;

   IGRint              sx_off;            /* simbuf offset IN DITS */
   IGRint              sy_off;

   IGRint              sx_dits;           /* simbuf extent in window */
   IGRint              sy_dits;

   NCzbuf              *zbuf;             /* base address of z buffer */
   NCzbuf              *zbuf2;            /* base address of 2nd z buffer */
   NCcbuf              *cbuf;             /* base address of image buffer */
   NCcbuf              *bbuf;             /* background image buffer */

   IGRint              borg_x;            /* background image buffer origin */
   IGRint              borg_y;

   IGRint              bx_dits;           /* background image buffer extent */
   IGRint              by_dits;
};

