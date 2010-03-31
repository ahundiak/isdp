
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "hnmilling.h"
#include "hntiming.h"
#include "hntoolpath.h"
#include "hnsimulate.h"
#include "hnd_macros.h"
#include "HStl_global.h"
#include "hsdisplay.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSpr_ncv_fun.h"

#define DISPLAY_SWVOL   FALSE
#define POS_(x)         ((x<0) ? 0 : x)


/**********************
 * EXTERNAL VARIABLES *
 **********************/
extern struct NC_shading_parms   NCshading;
extern struct NC_window_parms    NCwindow;
extern struct NC_toolpath_data   NCtoolpath_data;
extern struct NC_sim_data        NCsim_data;
extern struct NCdexel            *NCget_next_dexel();
extern unsigned char             trans_pat4[4][4];
extern NCcbuf                     NCbackground_c;

/*-----NCsubtract_dexel-------------------------------------------------------*/

NCsubtract_dexel ( NCzbuf         near_z,
                   NCzbuf         far_z,
                   unsigned char  color,
                   int            offset,
                   IGRboolean     *update )

/* ABSTRACT:   NCsubtract_dexel performs the boolean subtraction of the dexel
 *             defined by the given parameters from the dexels at the given
 *             offset. case 1 - 8: ref. Proceeding of SIGGRAPH, Vol 20, No 4,
 *             1986, pp 17
 *
 * HISTORY:   07/23/88   Created                        K. M. Jehng
 *            07/23/88   Integrated with dexel memories, enhancements,
 *                        and optimization.             C. M. Jablonski
 *            09/20/88   tmpadd_hi to unsigned char, optimization,
 *                       documentation                  K. M. Jehng
 *
 */

{
   unsigned char   tmpadd_hi;
   unsigned short  tmpadd_lo;
   struct NCdexel  *block;
   struct NCdexel  *curr;
   struct NCdexel  *prev;
   struct NCdexel  *temp;
   struct NCdexel  *new;
   NCcbuf          *cb;


   START_NC_TIMING(NCtd_SUBTRACT_DEX)

   /* retrieve block, color buffer addresses */
   curr = block = NCwindow.dexarry + offset;
   cb = NCwindow.cbuf + offset;
   prev = NULL;

   /* for swept volume / tool display testing */
#if DISPLAY_SWVOL
{
   *cb = color;
   *update = TRUE;
}
#else
{
   /* along z direction, retrieve block dexel and perform subtraction   */
   while (curr)
   {
      if ( far_z < curr->u.z.far_z )
      {
         /* case 2: tool is in front of dexel */
         if (far_z < curr->u.z.near_z )
         {
            /* do nothing, done  */
         }
         /* case 3: tool cuts front; update front of dexel */
         else if ( near_z < curr->u.z.near_z )
         {
            curr->u.z.near_z = far_z;
            if ( curr == block )
            {
               *cb = color;
               *update = TRUE;
            }
            else
            {
               curr->color = color;
            }
         }
         /* case 5: tool is inside dexel; add a new dexel */
         else
         {
            tmpadd_hi = curr->next_hi;
            tmpadd_lo = curr->next_lo;

            NCalloc_dexel(&new);

            curr->next_hi = new->next_hi;
            curr->next_lo = new->next_lo;

            new->next_hi = tmpadd_hi;
            new->next_lo = tmpadd_lo;

            new->u.z.near_z = far_z;
            new->u.z.far_z = curr->u.z.far_z;

            new->color = color;
            curr->u.z.far_z = near_z;
         }

         curr = NULL;         /* we are done       */
      }
      else
      {
         /* case 7: tool is behind dexel       */
         if ( near_z > curr->u.z.far_z )
         {
            /* goto next dexel */
            prev = curr;
            curr = NCget_next_dexel(curr);
         }
         /* case 6: tool cuts back; update back of dexel */
         else if ( near_z > curr->u.z.near_z )
         {
             curr->u.z.far_z = near_z;

             /* goto next dexel */
             prev = curr;
             curr = NCget_next_dexel(curr);
         }
         /* case 4: tool surrounds dexel; delete it    */
         else
         {
            /* case 4.1: delete the front (visible) dexel */
            if (curr == block)
            {
               if ((temp=NCget_next_dexel(block))==NULL)
               {  /* no dexels behind       */
                  block->u.z.near_z = NCbackground_z;
                  *cb = NCbackground_c;
                  curr = NULL;
               }
               else
               {
                  /* copy the following dexel's info then free it */
                  curr = temp;
                  block->u.z.near_z = curr->u.z.near_z;
                  block->u.z.far_z = curr->u.z.far_z;
                  block->color = curr->color;
                  tmpadd_hi = block->next_hi;
                  tmpadd_lo = block->next_lo;
                  block->next_hi = curr->next_hi;
                  block->next_lo = curr->next_lo;
                  *cb = curr->color;
                  curr->next_hi = tmpadd_hi;
                  curr->next_lo = tmpadd_lo;
                  NCfree_dexel(&curr);
                  curr = block;
               }
               *update = TRUE;
            }
            /* case 4.2: delete a hidden dexel    */
            else
            {
               tmpadd_hi = prev->next_hi;
               tmpadd_lo = prev->next_lo;
               prev->next_hi = curr->next_hi;
               prev->next_lo = curr->next_lo;
               curr->next_hi = tmpadd_hi;
               curr->next_lo = tmpadd_lo;
               NCfree_dexel(&curr);
               curr = prev;

               /* goto next dexel       */
               curr = NCget_next_dexel(curr);
            }
         }
      }
   }    /* while  */
}       /* #else  */
#endif


STOP_NC_TIMING(NCtd_SUBTRACT_DEX)
}


/*-----NCsubtract_sim_tool----------------------------------------------------*/

NCsubtract_sim_tool ( IGRint x1,
                      IGRint y1,
                      IGRint x2,
                      IGRint y2,
                      IGRint z_off )

/* ABSTRACT: NCsubtract_sim_tool performs the boolean subtraction of the
 *           simulated tool dexel at the given (x, y).
 *           case 1 - 8: ref. Proceeding of SIGGRAPH, Vol 20, No 4, 1986, pp 17
 *
 * HISTORY:   09/18/88  Created                       K. M. Jehng
 *            10/03/88  Changed cb to support vertical scan lines.
 *                                                    C. M. Jablonski
 *            10/14/88  Optimized processing of non-overlapping regions.
 *                                                    C. M. Jablonski
 *            11/28/88  Added 16 patterns for ht      K. M. Jehng
 *
 */

{
   unsigned char    tmpadd_hi;
   unsigned short   tmpadd_lo;

   struct NCdexel   *first;
   struct NCdexel   *curr;
   struct NCdexel   *prev;
   struct NCdexel   *temp;
   struct NCdexel   *new;

   NCcbuf           *cb;
   NCcbuf           *cb_base;
   NCcbuf           *bg_cb;
   NCcbuf           *bg_cbase;

   IGRint           delta_cb;
   IGRint           delta_cb_base;
   IGRint           delta_bg_cb;
   IGRint           sy_off_y1;
   IGRint           sy_off_y2;
   IGRint           sx_off_x1;
   IGRint           sx_off_x2;
   IGRint           delta_x;
   IGRint           x1_x2;
   IGRint           dx_dits_delta_x;
   IGRint           x_temp;
   IGRint           y_temp;
   IGRint           x1_sy_dits;

   simDexel         *tool;
   simDexel         *simbuf;
   register IGRint  x;
   register IGRint  y;
   NCzbuf           tool_near_z;
   NCzbuf           tool_far_z;

   START_NC_TIMING(NCtd_SUBTRACT_SIM)

   delta_cb_base   = (NCwindow.horizontal_scan) ? NCwindow.sx_dits : 1;
   delta_cb        = (NCwindow.horizontal_scan) ? 1 : NCwindow.sy_dits;

   sy_off_y1       = NCwindow.sy_off + y1;
   sy_off_y2       = NCwindow.sy_off + y2;
   x1_sy_dits      = x1 * NCwindow.sy_dits;

   simbuf   = NCwindow.simbuf;

   /* set up translucency matrix for tool */
   tiling_parms.processing_mode &= ~HS_PMODE_TRANS_1x1; /* patterned */


   /**************************************************************************
    * Process any part of the simbuf that is ABOVE the block dexel array,    *
    * and adjust y1 down to the top of the block dexel array.                *
    *************************************************************************/

   if (sy_off_y1 < 1)
   {
      y_temp   = (sy_off_y2 > 0) ? (1 - NCwindow.sy_off) : y2;
      x1_x2      = NCwindow.sx_dits - x2 + x1;
      tool       = simbuf + (NCwindow.sx_dits * y1) + x1;
      cb_base   = (NCwindow.horizontal_scan) ?
                   NCwindow.cbuf + y1 * NCwindow.sx_dits :
                   NCwindow.cbuf + y1;

      for (y = y1;
           y < y_temp;
           y++, cb_base += delta_cb_base, tool += x1_x2 )
      {
         /* retrieve color addresses  */
         cb = (NCwindow.horizontal_scan) ? cb_base + x1 : cb_base + x1_sy_dits;

#if DEBUG
{
         if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
         {
            fprintf(stderr,"OVERFLOW at 1: " );
            fprintf(stderr,
                   "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, sy_dits=%d\n",
                    NCwindow.cbuf,
                    cb,
                    (cb - NCwindow.cbuf),
                    NCwindow.sx_dits,
                    NCwindow.sy_dits);
         }
}
#endif

         for (x = x1; x < x2; x++, cb += delta_cb, tool++)
         {
            if (TRANSLUCENT(x, y) && NCsim_data.active_tool_trans)
            {
               *cb = NCbackground_c;
            }
            else if (tool->near_c != NCbackground_c)
            {
               *cb = tool->near_c;
            }
            else
            {
               *cb = NCbackground_c;
            }

#if DEBUG
{
            if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
            {
               fprintf(stderr, "OVERFLOW at 1a: ");
               fprintf(stderr, "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, ",
                               NCwindow.cbuf,
                               cb,
                               (cb - NCwindow.cbuf),
                               NCwindow.sx_dits );
               fprintf(stderr, "sy_dits=%d\n", NCwindow.sy_dits);
            }
}
#endif

         }
      }

      if (y_temp == y2)
      {
         goto wrapup;            /* done   */
      }

      /* adjust y1 down      */
      y1 = y_temp;
   }

/*****************************************************************************
 * Process any part of the simbuf that is BELOW the block dexel array,       *
 * and adjust y2 up to the bottom of the block dexel array.                  *
 ****************************************************************************/

   if (sy_off_y2 >= NCwindow.dy_dits)
   {
      y_temp  = (sy_off_y1 >= NCwindow.dy_dits) ?
                 y1: NCwindow.dy_dits - NCwindow.sy_off;
      x1_x2   = NCwindow.sx_dits - x2 + x1;
      tool    = simbuf + (NCwindow.sx_dits * y_temp) + x1;
      cb_base = (NCwindow.horizontal_scan) ?
                 NCwindow.cbuf + y_temp * NCwindow.sx_dits :
                 NCwindow.cbuf + y_temp;

      for ( y = y_temp;
            y < y2;
            y++, cb_base += delta_cb_base, tool += x1_x2 )
      {
         cb = (NCwindow.horizontal_scan) ? cb_base + x1 : cb_base + x1_sy_dits;

#if DEBUG
{
         if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
         {
            fprintf(stderr, "OVERFLOW at 2: ");
            fprintf(stderr,
                  "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, sy_dits=%d\n",
                  NCwindow.cbuf,
                  cb,
                  (cb - NCwindow.cbuf),
                  NCwindow.sx_dits,
                  NCwindow.sy_dits);
         }
}
#endif

         for (x = x1; x < x2; x++, cb += delta_cb, tool++)
         {
            if (TRANSLUCENT(x, y) && NCsim_data.active_tool_trans)
            {
               *cb = NCbackground_c;
            }
            else
            {
               if (tool->near_c != NCbackground_c)
               {
                  *cb = tool->near_c;
               }
               else
               {
                  *cb = NCbackground_c;
               }
            }

#if DEBUG
{
            if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
            {
               fprintf(stderr, "OVERFLOW at 2a:");
               fprintf(stderr,
                   "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, sy_dits=%d\n",
                    NCwindow.cbuf,
                    cb,
                    (cb - NCwindow.cbuf),
                    NCwindow.sx_dits,
                    NCwindow.sy_dits);
            }
}
#endif

         }
      }

      if (y_temp == y1)
      {
         goto wrapup;            /* done   */
      }

      /* adjust y2 up to the bottom of the block dexel array       */
      y2 = y_temp;
   }

   sx_off_x1 = NCwindow.sx_off + x1;
   sx_off_x2 = NCwindow.sx_off + x2;

/*******************************************************************************
 * Process any part of the simbuf that is to the LEFT of the block dexel       *
 * array, and adjust x1 over to the left edge of the block dexel array.        *
 ******************************************************************************/

   if (sx_off_x1 < 1)
   {
      x_temp  = (sx_off_x2 > 0) ? (1 - NCwindow.sx_off) : x2;
      x1_x2   = NCwindow.sx_dits - x_temp + x1;
      tool    = simbuf + (NCwindow.sx_dits * y1) + x1;
      cb_base = (NCwindow.horizontal_scan) ?
                   NCwindow.cbuf + y1 * NCwindow.sx_dits :
                   NCwindow.cbuf + y1;

      for (y = y1; y < y2; y++, cb_base += delta_cb_base, tool += x1_x2 )
      {
         cb = (NCwindow.horizontal_scan) ? cb_base + x1 : cb_base + x1_sy_dits;

#if DEBUG
{
         if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
         {
            fprintf(stderr,"OVERFLOW at 3: " );
            fprintf(stderr,
                  "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, sy_dits=%d\n",
                  NCwindow.cbuf,
                  cb,
                  (cb - NCwindow.cbuf),
                  NCwindow.sx_dits,
                  NCwindow.sy_dits);
         }
}
#endif

         for (x = x1; x < x_temp; x++, cb += delta_cb, tool++)
         {
            if (TRANSLUCENT(x, y) && NCsim_data.active_tool_trans)
            {
               *cb = NCbackground_c;
            }
            else if (tool->near_c != NCbackground_c)
            {
               *cb = tool->near_c;
            }
            else
            {
               *cb = NCbackground_c;
            }

#if DEBUG
{
            if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
            {
               fprintf(stderr,"OVERFLOW at 3a: ");
               fprintf(stderr,"NCwindow.cbuf=%d, cb=%d, diff=%d, ",
                               NCwindow.cbuf,
                               cb,
                               (cb - NCwindow.cbuf) );
               fprintf(stderr,"sx_dits=%d, sy_dits=%d\n",
                               NCwindow.sx_dits,
                               NCwindow.sy_dits);
             }
}
#endif

         }
      }

      if (x_temp == x2)
      {
         goto wrapup;            /* done   */
      }

      /* adjust x1 over to the left edge of the block dexel array       */
     x1 = x_temp;
   }


/*******************************************************************************
 * Process any part of the simbuf that is to the RIGHT of the block dexel      *
 * array, and adjust x2 over to the right edge of the block dexel array.       *
 ******************************************************************************/

   if (sx_off_x2 >= NCwindow.dx_dits)
   {
      x_temp   = (sx_off_x1 >= NCwindow.dx_dits) ?
                              x1 : NCwindow.dx_dits - NCwindow.sx_off;
      x1_x2    = NCwindow.sx_dits - x2 + x_temp;
      tool     = simbuf + (NCwindow.sx_dits * y1) + x_temp;
      cb_base  = (NCwindow.horizontal_scan) ?
                    NCwindow.cbuf + y1 * NCwindow.sx_dits : NCwindow.cbuf + y1;

      for (y = y1; y < y2; y++, cb_base += delta_cb_base, tool += x1_x2 )
      {
         cb = (NCwindow.horizontal_scan) ?
                   cb_base + x_temp : cb_base + x_temp * NCwindow.sy_dits;

#if DEBUG
{
         if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
         {
            fprintf(stderr,"OVERFLOW at 4: " );
            fprintf(stderr,"NCwindow.cbuf=%d, cb=%d, diff=%d, ",
                            NCwindow.cbuf,
                            cb,
                            (cb - NCwindow.cbuf) );
            fprintf(stderr,"sx_dits=%d, sy_dits=%d\n",
                            NCwindow.sx_dits,
                            NCwindow.sy_dits);
         }
}
#endif

         for (x = x_temp; x < x2; x++, cb += delta_cb, tool++)
         {
            if (TRANSLUCENT(x, y) && NCsim_data.active_tool_trans)
            {
               *cb = NCbackground_c;
            }
            else if (tool->near_c != NCbackground_c)
            {
               *cb = tool->near_c;
            }
            else
            {
               *cb = NCbackground_c;
            }

#if DEBUG
{
            if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
            {
               fprintf( stderr, "OVERFLOW at 4a: ");
               fprintf( stderr, "NCwindow.cbuf=%d, cb=%d, diff=%d, ",
                                NCwindow.cbuf,
                                cb,
                                (cb - NCwindow.cbuf) 0;
               fprintf( stderr, "sx_dits=%d, sy_dits=%d\n",
                                NCwindow.sx_dits,
                                NCwindow.sy_dits);
            }
}
#endif

         }
      }

      if (x_temp == x1)
      {
         goto wrapup;               /* done  */
      }

      /* adjust x2 over to the right edge of the block dexel array */
      x2 = x_temp;
   }

/******************************************************************************
 * Now process the region of the simbuf that overlaps the block dexel array.  *
 *****************************************************************************/

   delta_x  = x2 - x1;
   x1_x2    = NCwindow.sx_dits - delta_x;
   dx_dits_delta_x = NCwindow.dx_dits - delta_x;
   first    = NCwindow.dexarry + ((NCwindow.sy_off+y1) * NCwindow.dx_dits) +
              (NCwindow.sx_off + x1);
   tool     = simbuf + (NCwindow.sx_dits * y1) + x1;
   cb_base  = (NCwindow.horizontal_scan) ?
                   NCwindow.cbuf + y1 * NCwindow.sx_dits : NCwindow.cbuf + y1;
   x1_sy_dits = x1 * NCwindow.sy_dits;

   for (y = y1; y < y2; y++, cb_base += delta_cb_base, first += dx_dits_delta_x,
              tool += x1_x2 )
   {
      cb = (NCwindow.horizontal_scan) ? cb_base + x1 : cb_base + x1_sy_dits;

#if DEBUG
{
      if ((cb - NCwindow.cbuf) >= (NCwindow.sx_dits * NCwindow.sy_dits))
      {
         fprintf(stderr,"OVERFLOW at 5: ");
         fprintf(stderr,
                 "NCwindow.cbuf=%d, cb=%d, diff=%d, sx_dits=%d, sy_dits=%d\n",
                  NCwindow.cbuf,
                  cb,
                  (cb - NCwindow.cbuf),
                  NCwindow.sx_dits,
                  NCwindow.sy_dits);
      }
}
#endif

      for (x = x1; x < x2; x++, cb += delta_cb, first++, tool++ )
      {
         /* case 1: nothing or block only   */
         if (tool->near_z == NCbackground_z)
         {
            *cb = first->color;
         }
         /* case 8: tool only   */
         else if (first->u.z.near_z == NCbackground_z)
         {
            if (TRANSLUCENT(x, y) && NCsim_data.active_tool_trans)
            {
               *cb = first->color;
            }
            else
            {
               *cb = tool->near_c;
            }
         }
         else
         {
            /* adjust tool near/far z with z_buffer offset */
            tool_far_z  = tool->far_z + z_off;
            tool_near_z = tool->near_z + z_off;

            curr = first; prev = NULL;
            while (curr)
            {
               /* otherwise: cases 2 - 7   */
               if ( tool_far_z < curr->u.z.far_z )
               {
                  /* case 2: block behind tool, and no intersect with block */
                  if (tool_far_z < curr->u.z.near_z )
                  {
                     /* if no prev. block dexel exists, display tool
                      * near color, else display block.
                      */
                     if (TRANSLUCENT (x, y) && NCsim_data.active_tool_trans)
                     {
                        *cb = first->color;
                     }
                     else
                     {
                        *cb = (curr == first) ? tool->near_c : first->color;
                     }
                  }
                  else if ( tool_near_z < curr->u.z.near_z )
                  /* case 3: tool cuts front, update front of block   */
                  {
                     /* update part dexel near z      */
                     curr->u.z.near_z = tool_far_z;
                     curr->color = tool->far_c;
                     if (TRANSLUCENT (x, y) && NCsim_data.active_tool_trans)
                     {
                        *cb = first->color;
                     }
                     else
                     {
                        *cb = (curr == first) ? tool->near_c : first->color;
                     }
                  }
                  else
                  /* case 5: tool is inside block, add create block dexel */
                  {
                     /* create part dexel based on tool dexel's near z,
                      * far z, and far color
                      */
                     tmpadd_hi = curr->next_hi;
                     tmpadd_lo = curr->next_lo;
                     NCalloc_dexel(&new);
                     curr->next_hi = new->next_hi;
                     curr->next_lo = new->next_lo;
                     new->next_hi = tmpadd_hi;
                     new->next_lo = tmpadd_lo;
                     new->u.z.near_z = tool_far_z;
                     new->u.z.far_z = curr->u.z.far_z;
                     new->color = tool->far_c;

                     curr->u.z.far_z = tool_near_z;

                     /* display color of nearest part dexel   */
                     *cb = first->color;
                  }
                  curr = NULL;   /* we are done */
               }
               else
               {
                  /* case 7: tool is behind block   */
                  if ( tool_near_z > curr->u.z.far_z )
                  {
                     /* continue dexel traverse      */
                     prev = curr;
                     curr = NCget_next_dexel(curr);
                     *cb = first->color;
                  }
                  /* case 6: tool cuts back part, update back of part   */
                  else if ( tool_near_z > curr->u.z.near_z )
                  {
                     /* update part far z of part dexel   */
                     curr->u.z.far_z = tool_near_z;
                     prev = curr;
                     curr = NCget_next_dexel(curr);
                     *cb = first->color;
                  }
                  /* case 4: tool surrounds dexel; delete block dexel      */
                  /* NOTE:   we can't free block which is pointered to the */
                  /*        first part dexel                              */
                  else
                  {
                     if (curr == first)
                     /* delete the front (visible) dexel    */
                     {
                        if ((temp=NCget_next_dexel(curr))==NULL)
                        {
                           first->u.z.near_z =
                           first->u.z.far_z = NCbackground_z;
                           first->color = NCbackground_c;
                           *cb = tool->near_c;
                           curr = NULL;
                        }
                        else
                        /* copy the following dexel's info
                         * then free it, continue traverse */
                        {
                           curr = temp;
                           first->u.z.near_z=curr->u.z.near_z;
                           first->u.z.far_z=curr->u.z.far_z;
                           first->color = curr->color;
                           tmpadd_hi = first->next_hi;
                           tmpadd_lo = first->next_lo;
                           first->next_hi = curr->next_hi;
                           first->next_lo = curr->next_lo;
                           curr->next_hi = tmpadd_hi;
                           curr->next_lo = tmpadd_lo;
                           NCfree_dexel(&curr);
                           curr = first;
                           *cb = tool->near_c;
                        }
                     }
                     else
                     /* delete a hidden dexel       */
                     {
                        tmpadd_hi = prev->next_hi;
                        tmpadd_lo = prev->next_lo;
                        prev->next_hi = curr->next_hi;
                        prev->next_lo = curr->next_lo;
                        curr->next_hi = tmpadd_hi;
                        curr->next_lo = tmpadd_lo;
                        NCfree_dexel(&curr);
                        curr = prev;
                        curr = NCget_next_dexel(curr);
                        *cb = first->color;
                     }
                  }
               } /* else  */
            }    /* while */
         }       /* else  */
      }          /* for x */
   }             /* for y */

   /* go through the simulation buffer and update NCbackground_c to the  */
   /* background image buffer values */
   cb_base = NCwindow.cbuf;

   if (NCtoolpath_data.five_axis)
   {
      bg_cbase = NCwindow.bbuf +
                 ((NCwindow.sorg_y + NCsim_data.y_loc) * NCwindow.bx_dits) +
                 (NCwindow.sorg_x >> 16) +
                 NCsim_data.x_loc;
   }
   else
   {
      bg_cbase = NCwindow.bbuf +
                 (NCwindow.dorg_y + NCwindow.sy_off) * NCwindow.bx_dits +
                 (NCwindow.dorg_x >> 16) + NCwindow.sx_off;
   }

   delta_cb = (NCwindow.horizontal_scan) ? 1 : NCwindow.sy_dits;
   delta_bg_cb = (NCwindow.horizontal_scan) ? 1 : NCwindow.bx_dits;
   for (y=0; y < NCwindow.sy_dits; y++)
   {
      bg_cb =  bg_cbase + y*NCwindow.bx_dits;
      cb = (NCwindow.horizontal_scan) ?
                 cb_base + y * NCwindow.sx_dits : cb_base + y;

      for (x=0; x < NCwindow.sx_dits; x++, cb += delta_cb, bg_cb++)
      {
         if (*cb == NCbackground_c)
         {
            *cb = *bg_cb;
         }
      }
   }

wrapup:
   STOP_NC_TIMING(NCtd_SUBTRACT_SIM);
}

