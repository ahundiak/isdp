/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/
class implementation Root;

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "wl.h"
#include "cm.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "igetypedef.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#define MAXIMUM(x,y) ((x>y)?x:y)
#define MINIMUM(x,y) ((x<y)?x:y)
#define ONE 65535
#define D_ONE 65535.0
#define TOLERANCE 0.01

/* maximum distance in cube is 256^2+256^2+256^2 */
#define MAXDISTSQ 196608
#define MAXDISTSQ_D 196608.0

%safe
static int  (*IGEgamma_compensate_ptr)( IGRint, IGRushort *, IGRdouble *, IGRboolean );


extern short *IGErgb_table;
extern struct WLcmap_entry       IGEphys_vlt[512]; 
static struct IGElogical_color       IGEbg_log_hl_colors[512];
static int               IGEcontext_index = -1;
static struct IGEcontext_info      *IGEcontexts_ptr[WL_MAX_CONTEXTS_POSSIBLE];
static int               num_contexts = 0;
static IGRushort         IGEcompensate_array[3*512];
static IGRboolean        IGEusing_ramp = FALSE; /* the default will be color cube (except 3*** machines) */
static IGRushort         Ambient_Light[3] = { 0, 0, 0};
static int               minimum_ramp_shades = 1;
%endsafe
from IGEuserramp import get_sim_user_ramp;

IGRint IGEload_context(WLuint32 context_no,
   struct IGEcontext_info      *context_info)
{
/*
NAME
   IGEload_context
DESCRIPTION
   this loads the physical table for the context into memory and returns
   the context information.  It is optimized to look at the last one loaded.
PARAMETERS
   context_no (in) - the context to load
   context_info (out) - the context info for given context number
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   /* this is the only place that IGEcontext_index is changed to become up to
      date.  If there is another place, IGEphys_vlt will not be current because
      it thinks it is already up to date. */
   IGRint i,j;

   /*  Check to see if the load request is the very first time */
   if (IGEcontext_index != -1)
   {

      if ((context_no == IGEcontexts_ptr[IGEcontext_index]->context_no) ||
          (context_no == WL_DEFAULT_CONTEXT))
      {
         /* If someone made changes to IGEphys_vlt and wants a 
            fresh copy we will need to load again here */
#ifdef DEBUG_CL
/*         printf("IGEload_context: %d already loaded\n",context_no);*/
#endif
         *context_info = *IGEcontexts_ptr[IGEcontext_index];
         return(TRUE);
      }
   }
   
   for (i = 0;i<num_contexts;i++)
   {
      if ( (IGEcontexts_ptr[i]->context_no == context_no)  ||
           (context_no == WL_DEFAULT_CONTEXT ) )
      {
         for (j = 0; j < (1 << IGEcontexts_ptr[i]->table_depth); j++ )
         {
            IGEphys_vlt[j].slot = j;
         }
         WLread_cmap_entries(context_no, 1 << IGEcontexts_ptr[i]->table_depth, IGEphys_vlt );
         IGEcontext_index = i;
         IGErgb_table = IGEcontexts_ptr[IGEcontext_index]->rgb_table;
         *context_info = *IGEcontexts_ptr[IGEcontext_index];
         return(TRUE);
      }
   }

#ifdef DEBUG_CL
   printf("IGEload_context: context %d doesn't exist\n",context_no);
/* TAKE THIS OUT!!!!!!!! ALLOWS TO RUN WHEN BOGUS CONTEXT ENTERED FOR INTEGRATION 53093 */
*context_info = *IGEcontexts_ptr[IGEcontext_index];
#endif
   return(FALSE);
}

IGRint IGEsave_context(WLuint32 context_no,
   struct IGEcontext_info      *context_info)
{
/*
NAME
   IGEsave_context
DESCRIPTION
   this saves the context information after you have IGEload_context and
   changed the information
PARAMETERS
   context_no (in) - the context to save info
   context_info (out) - the context info to save
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint i;

   if (context_no == IGEcontexts_ptr[IGEcontext_index]->context_no) 
   {
#ifdef DEBUG_CL
/*      printf("IGEsave_context: %d already loaded\n",context_no);*/
#endif
      *IGEcontexts_ptr[IGEcontext_index] = *context_info;
      return(TRUE);
   }

   for (i = 0;i<num_contexts;i++)
   {
      if (IGEcontexts_ptr[i]->context_no == context_no) 
      {
         *IGEcontexts_ptr[i] = *context_info;
         return(TRUE);
      }
   }
#ifdef DEBUG_CL
   printf("IGEsave_context: context %d doesn't exist\n",context_no);
/* TAKE THIS OUT!!!!!!!! ALLOWS TO RUN WHEN BOGUS CONTEXT ENTERED 53093 */
*IGEcontexts_ptr[IGEcontext_index] = *context_info;
#endif
   return(FALSE);
}

IGRint IGEload_logical_array(IGRint *bg_log_hl_colors,
   IGRint start_slot,
   IGRint num_slots)
{
/*
NAME
   IGEload_logical_array
DESCRIPTION
   this will load the logical color table array from the instance data
PARAMETERS
   bg_log_hl_colors (in) - the logical colors
   start_slot (in) - the starting slot
   num_slots (in) - the number of slots to load
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   bg_log_hl_colors
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRint i;
   /* only needs to be done once, from then on we leave it to create color table
      to change both IGEbg_log_hl_colors and me->bg_log_hl_color every time a 
      change is made to keep them parallel. */
   for ( i = start_slot; i < start_slot + num_slots; i++)
   {
      CLunpack_colors(bg_log_hl_colors[i],
         &(IGEbg_log_hl_colors[i].log_red), 
         &(IGEbg_log_hl_colors[i].log_green),
         &(IGEbg_log_hl_colors[i].log_blue));
   }
   return(TRUE);
} /* IGEload_logical_array */

/*-- IGEcolor_compensate -------------------------------------------------*/

IGRint IGEcolor_compensate(
   IGRint num_colors,
   IGRushort *colors,
   IGRdouble *gamma,
   IGRboolean convert_opt )

/*
NAME
   IGEcolor_compensate

DESCRIPTION
   Given an array of intensity values in the range [0..65535], this function
   returns a corresponding compensated or uncompensated value depending
   on the 'convert_opt' flag and the gamma value.

PARAMETERS
   num_colors (IN) - the number of colors to compensate or uncompensate
   colors (IN-OUT) - the array of size 3 * num_colors r0 g0 b0 r1 g1 ...
                    range: [0..65535]
   gamma (IN) - array of 3 double values (standard is 2.2 2.2 2.2)
   convert_opt (IN) - 1 => compensate intensity, 0 => uncompensate

RETURN VALUES
   The compensated/uncompensated intensity is returned

GLOBALS USED
   none

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint i;

   if ( convert_opt )
   {
      for ( i = 0; i<num_colors; i++ )
      {
         /* convert uncompensated intensity to compensated intensity */
         colors[(i*3)] = (IGRushort) ( pow( (double)(colors[(i*3)] / D_ONE), (1.0 / gamma[0]) ) * ONE);
         colors[(i*3)+1] = (IGRushort) ( pow( (double)(colors[(i*3)+1] / D_ONE), (1.0 / gamma[1]) ) * ONE);
         colors[(i*3)+2] = (IGRushort) ( pow( (double)(colors[(i*3)+2] / D_ONE), (1.0 / gamma[2]) ) * ONE);
      }
   }
   else
   {
      for ( i = 0; i<num_colors; i++ )
      {
         /* convert compensated intensity to uncompensated intensity */
         colors[(i*3)]   = (IGRushort) ( pow( (double)(colors[(i*3)]   / D_ONE), gamma[0] ) * ONE);
         colors[(i*3)+1] = (IGRushort) ( pow( (double)(colors[(i*3)+1] / D_ONE), gamma[1] ) * ONE);
         colors[(i*3)+2] = (IGRushort) ( pow( (double)(colors[(i*3)+2] / D_ONE), gamma[2] ) * ONE);
      }
   }
   
   return( 0 );

}  /* IGEcolor_compensate */


/*--- IGEcalc_best_match ---------------------------------------*/

void IGEcalc_best_match(
   IGRushort          red, 
   IGRushort          green, 
   IGRushort          blue,
   IGRboolean      *within_tol,
   IGRdouble      tolerance,
   IGRint         search,
   IGRint         not_search,
   IGRint         num_colors,
   IGRint         *matched_slot )

/*
NAME
   IGEcalc_best_match

DESCRIPTION
   This function calculates the closest match to a color using
   slots that satisfy search and don't satisfy not_search.

PARAMETERS
   red (IN) - the red component of the color to match
   green (IN) - the green component of the color to match
   blue (IN) - the blue component of the color to match
   within_tol (OUT) - if the match returned is within tolerance or not
   tolerance (IN) - The tolerance of matching.  It is a percentage
      of cube distance.  [range 0.0-1.0]
   search (IN) - Bit mask of which slots to search
   not_search (IN) - Bit mask of which slots to skip over in search
   num_colors (IN) - the number of colors to search for in vlt
   matched_slot (OUT) - the slot that was a closest match.  If the
      search found no matches NO_MATCH is returned.

GLOBALS USED
   none

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint temp, this_dist_sq, dist_sq;
   IGRint ii;

   dist_sq = MAXDISTSQ;

   /* shift to 8 bits so ints can be used in calculations */
   red = red >> 8;
   green = green >> 8;
   blue = blue >> 8;

   *matched_slot = NO_MATCH;
   for ( ii = 0; ii < num_colors; ii++ )
   {
      if ( (IGEphys_vlt[ii].flags & search) &&
          !(IGEphys_vlt[ii].flags & (not_search|VLT_EMPTY_SLOT)) )
      {
         temp = (IGEphys_vlt[ii].red >> 8) - red;
         this_dist_sq = (temp * temp);
         temp = (IGEphys_vlt[ii].green >> 8) - green;
         this_dist_sq += (temp * temp);
         temp = (IGEphys_vlt[ii].blue >> 8) - blue;
         this_dist_sq += (temp * temp);
         if ( this_dist_sq <= dist_sq )
         {
            dist_sq = this_dist_sq;
            /* must use ii instead of slot     */
            /* because slots are 9 bit numbers */
            /* during VLT building process     */
            *matched_slot = ii;
            
            if ( dist_sq == 0 ) goto wrapup;
         }

      }  /* end: if valid slot to check */
   }  /* end: for */
   /* To be accurate with tolerance being a percentage, we would compare 
      actual distance (sqrt(dist_sq)) and tolerance*max distance in cube.
      For comparison purposes only, we can square both sides and come up 
      with the same result of the comparison.  Therefore dist_sq compared
      with tolerance*tolerance*MAXDISTSQ is an equal comparison to above
      and is exactly correct. */
wrapup:
   if (*matched_slot != NO_MATCH)
   {
      *within_tol = (dist_sq <= (IGRint) (tolerance*tolerance*MAXDISTSQ_D));
   }
   else
   {
      *within_tol = FALSE;
   }
}  /* IGEcalc_best_match */

/*--- IGEinit_physical_vlt -------------------------------------------------*/

IGRint IGEinit_physical_vlt(
   IGRint             num_planes,
   IGRint             reserve_hilite_plane,
   IGRint             hilite_color)

/*
NAME
   IGEinit_physical_vlt

DESCRIPTION
   This function initializes the physical VLT that will be loaded into the
   hardware.  This will optionaly set up one plane of hilite.  

PARAMETERS
   num_planes (IN) - the number of planes available
   reserve_hilite_plane (IN) - if TRUE, the upper plane is loaded for
      hilite
   hilite_color (IN) - the packed representation of the hilite color
GLOBALS USED
   none
   
RETURN VALUES
   0 - success
   1 - failure

ALGORITHM
   - Mark all of the slots in the VLT as empty.
   - If a hilite plane is to be reserved, load the upper half of the VLT
     with the hilite color.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii;
   IGRushort          hl_red, hl_green, hl_blue;

   /* mark all slots in the VLT as empty */
   IGEphys_vlt[0].flags = VLT_EMPTY_SLOT;
   IGEphys_vlt[0].red = IGEphys_vlt[0].green = IGEphys_vlt[0].blue = 0;
   IGEphys_vlt[0].slot = 0;
   for ( ii = 1; ii < (1 << num_planes); ii++ )
   {
      IGEphys_vlt[ii] = IGEphys_vlt[0];
      IGEphys_vlt[ii].slot = ii;   
   }
   if ( reserve_hilite_plane == WL_HILITE_USED )
   {
      /* put hilite in the upper half of the VLT */
      CLunpack_colors( hilite_color, &hl_red, &hl_green, &hl_blue );
      for ( ii = (1 << (num_planes-1)); ii < (1 << num_planes); ii++ )
      {
         IGEphys_vlt[ii].flags = VLT_HILITE_SLOT;
         IGEphys_vlt[ii].slot = ii;
         IGEphys_vlt[ii].red = hl_red;
         IGEphys_vlt[ii].green = hl_green;
         IGEphys_vlt[ii].blue = hl_blue;
      }
   }
   return( 0 );
}  /* IGEinit_physical_vlt */

/*--- IGEres_special_area -------------------------------------------------*/

IGRint IGEres_special_area(
   IGRint         num_slots_requested,
   IGRushort      *special_colors,
   IGRint         num_slots_available,
   IGRint         num_win_mgr_colors,
   struct IGEcolor_mapping   *win_mgr_colors,
   IGRint          num_ingr_res_colors,
   struct IGEcolor_mapping *ingr_res_colors)

/*
NAME
   IGEres_special_area

DESCRIPTION
   This function reserves the number of special slots requested.

PARAMETERS
   num_slots_requested (IN) - the number of slots requested
   num_slots_available (IN) - the number of slots available.  This can be
               equal to all slots or just non-hilite slots.
               there needs to be atleast num_slots_available
               in phys_vlt.  A search will be made to find
               the highest slots.

GLOBALS USED
   none
   
RETURN VALUES
   0 - success
   1 - failure

ALGORITHM
   - Find the highest empty slot
   - reserve the special slots if room.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii,i;
   IGRint             end_slot;

   if (num_slots_requested>(num_slots_available-8))
   {
#ifdef DEBUG_CL
      printf("IGEres_special_area:too many slots requested req=%d\n",num_slots_requested);
#endif
      return (1);
   }

   for (end_slot = num_slots_available-1; end_slot >= 0;end_slot--)
   {
      if (IGEphys_vlt[end_slot].flags&VLT_EMPTY_SLOT)
      {
#ifdef DEBUG_CL
         printf("IGEres_special_area:end_slot=%d\n",end_slot);
#endif
         break;
      }
   }

   for (ii = 0; ii<num_win_mgr_colors; ii++)
   {
      if ((win_mgr_colors[ii].phys_slot == end_slot)&&
          (num_slots_available-8>num_slots_requested)) /* if only 2x2x2 cube left put in beginning */
      {
         ii = 0; /* go through again to check if new 
                  end_slot is taken */
         end_slot--;
#ifdef DEBUG_CL
         printf("IGEres_special_area:wmgr end_slot pushed forward to=%d\n",end_slot);
#endif
      }
   }

   for (ii = 0; ii<num_ingr_res_colors; ii++)
   {
      if ((ingr_res_colors[ii].phys_slot == end_slot) &&
          (num_slots_available-8 > num_slots_requested)) /* if only 2x2x2 cube left put in beginning */

      {
         ii = 0; /* go through again to check if new 
                  end_slot is taken */
         end_slot--;
#ifdef DEBUG_CL
         printf("IGEres_special_area:ingr end_slot pushed forward to=%d\n",end_slot);
#endif
      }
   }

   if (num_slots_requested-1>end_slot) return (1);

   /* We are NOT going to change the values of the special slots at all (i.e. compensate).  */
   /* The application gives the exact values they want loaded in.  If this decision changes */
   /* compensate here:                                                                      */
   /* (*IGEgamma_compensate_ptr)( num_slots_requested, special_colors, gamma, 1);           */
   
   for ( i = 0, ii = end_slot-(num_slots_requested-1); ii <= end_slot; ii++, i++ )
   {
         IGEphys_vlt[ii].flags = VLT_SPECIAL_AREA_SLOT;
         IGEphys_vlt[ii].slot = ii;
         IGEphys_vlt[ii].red = special_colors[i*3];
         IGEphys_vlt[ii].green = special_colors[(i*3)+1];
         IGEphys_vlt[ii].blue = special_colors[(i*3)+2];
   }

   return( 0 );

}  /* IGEres_special_area */

/*--- IGEload_cube ----------------------------------------------------------*/

IGRint IGEload_cube( 
   IGRint             cube_size,
   IGRint             num_slots_available,
   IGRdouble      *gamma )
/*
NAME
   IGEload_cube

DESCRIPTION
   This function loads the color cube into the phys_vlt into the highest slots
   available.

PARAMETERS
   screen_no (IN) - the screen number for the screen that the physical VLT
                    it to be built for
   cube_size (IN) - the size of one side of the color cube
   num_slots_available (IN) - number of slots available in the physical vlt
   gamma (IN) - The gamma values to compensate for each gun

GLOBALS USED

RETURN VALUES
   0 - success
   1 - failure

ALGORITHM
   - Load a contiguous color cube of size, 'cube_size', into the high end
     of the VLT so that it ends at the last available slot before special area
     or hilite plane.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii;
   IGRint         slot_num,num_slots;
   IGRint             red, grn, blu;
   IGRushort          base_shade[16*3];

   /* fill in the base_shade array; remember that the values */
   /* for the base shades are NOT calibrated. There is a diff*/
   /* value for each gun */
   base_shade[0] = base_shade[1] = base_shade[2] = 0x0000;
   base_shade[(cube_size-1)*3] = base_shade[((cube_size-1)*3)+1] = base_shade[((cube_size-1)*3)+2] = 0xFFFF;
   switch ( cube_size )
   {
      case 2:
         break;

      case 3:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x7FFF;
         break;

      case 4:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x5555;
         base_shade[6] = base_shade[7] = base_shade[8] = 0xAAAA;
         break;

      case 5:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x3FFF;
         base_shade[6] = base_shade[7] = base_shade[8] = 0x7FFF;
              base_shade[9] = base_shade[10] = base_shade[11] = 0xBFFF;
         break;

      case 6:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x3333;
         base_shade[6] = base_shade[7] = base_shade[8] = 0x6666;
         base_shade[9] = base_shade[10] = base_shade[11] = 0x9999;
         base_shade[12] = base_shade[13] = base_shade[14] = 0xCCCC;
         break;

      case 7:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x2AAA;
         base_shade[6] = base_shade[7] = base_shade[8] = 0x5555;
         base_shade[9] = base_shade[10] = base_shade[11] = 0x7FFF;
         base_shade[12] = base_shade[13] = base_shade[14] = 0xAAAA;
         base_shade[15] = base_shade[16] = base_shade[17] = 0xD554;
         break;

      case 8:
         base_shade[3] = base_shade[4] = base_shade[5] = 0x2492;
         base_shade[6] = base_shade[7] = base_shade[8] = 0x4924;
         base_shade[9] = base_shade[10] = base_shade[11] = 0x6DB6;
         base_shade[12] = base_shade[13] = base_shade[14] = 0x9248;
         base_shade[15] = base_shade[16] = base_shade[17] = 0xB6DA;
         base_shade[18] = base_shade[19] = base_shade[20] = 0xDB6C;
         break;

      default :
#ifdef DEBUG_CL
         printf("IGEload_cube: cube size %d unsupported\n",cube_size);
#endif
         return( 1 );  /* cannot support this configuration */
   }

   if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)
   {
      /* calibration is on => calibrate the base shades */
      (*IGEgamma_compensate_ptr)( cube_size, base_shade, gamma, 1);
   }

   /* load color cube in high-end of the vlt */
   for (ii = 0,num_slots = 0; ii<num_slots_available;ii++)
   {
      if (IGEphys_vlt[ii].flags&VLT_EMPTY_SLOT)
      {
         num_slots++;
      }
   }
   
#ifdef DEBUG_CL
   printf("IGEload_cube:total_slots=%d num_slots=%d\n",num_slots_available,num_slots);
#endif

   /* Build vlt, with 9-bit rgb value stored for the vlt slot  */
   /* number.  */
   slot_num = num_slots-(cube_size*cube_size*cube_size);
   if (slot_num<0) 
   {
#ifdef DEBUG_CL
      printf("IGEload_cube: cube won't fit\n");
#endif
      return(1);
   }

   for ( blu = 0; blu < cube_size; blu++ )
   {
      for ( grn = 0; grn < cube_size; grn++ )
      {
         for ( red = 0; red < cube_size; red++ )
         {
            if (!(IGEphys_vlt[slot_num].flags&VLT_EMPTY_SLOT))
            {
               /* when we reserved a slot after special area (win mgr in env5)
                  and we use it/them to fit the cube */
               for (ii = slot_num+1; ii<num_slots_available;ii++)
               {
                  if (IGEphys_vlt[ii].flags&VLT_EMPTY_SLOT)
                  {
                     slot_num = ii;
                     break;
                  }
               }
            }
            /* set = to color cube slot so we will know it was overwritten */
            IGEphys_vlt[slot_num].flags = VLT_COLOR_CUBE_SLOT;
            IGEphys_vlt[slot_num].slot = (blu << 6) | (grn << 3) | red;
            IGEphys_vlt[slot_num].red = base_shade[(red*3)];
            IGEphys_vlt[slot_num].green = base_shade[(grn*3)+1];
            IGEphys_vlt[slot_num].blue = base_shade[(blu*3)+2];
            slot_num++;
         }
      }
   }
   return( 0 );

}  /* IGEload_cube */

/*--- IGEload_window_manager -------------------------------------------------*/

IGRint IGEload_window_manager( 
   IGRboolean      assign_slot,
   IGRdouble      tolerance,
   IGRint          num_win_mgr_colors,
   struct IGEcolor_mapping   *win_mgr_colors,
   IGRint          total_colors )

/*
NAME
   IGEload_window_manager

DESCRIPTION
   This function loads the window manager colors into the physical vlt.  The
   assign_slot flag will be TRUE the first time and subsequent calls will all
   be FALSE.  This is because the window manager colors are assigned slots 
   (which will be the same ones they were queried from).  The window manager 
   colors are loaded again to see if a swap with the cube can be made.

PARAMETERS
   assign_slot (IN) - flag if going to change slot mapped to.
   tolerance (IN) - the percentage in rgb distance to be close enough
   num_win_mgr_colors (IN) - number of colors to load
   win_mgr_colors (IN) - the colors to load
   total_colors (IN) - number of colors in phys_vlt

GLOBALS USED

RETURN VALUES
   0 - success
   1 - failure

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii;
   IGRboolean      within_tol;
   IGRint             matched_slot;
   IGRint             available_slot;

   for ( ii = 0; ii < num_win_mgr_colors; ii++ )
   {
      if (assign_slot)
      {
         if (IGEphys_vlt[win_mgr_colors[ii].phys_slot].flags&VLT_EMPTY_SLOT)
         {
            IGEcreate_exact_match(VLT_WIN_MGR_SLOT, 
                  &win_mgr_colors[ii], win_mgr_colors[ii].phys_slot);
         }
         else
         {
            /* if hilite slot or special area just assign */
#ifdef DEBUG_CL
            printf("IGEload_win_mgr: assigning window manager to non empty slot\n");
#endif
            IGEassign_to_slot(VLT_INGR_RES_SLOT, &win_mgr_colors[ii], 
               win_mgr_colors[ii].phys_slot);
         }      
      }
      else
      {
         if (IGEphys_vlt[win_mgr_colors[ii].phys_slot].flags&VLT_INGR_RES_SLOT)
         {
            /* don't swap a ingr res slot just assign */
            IGEassign_to_slot(VLT_WIN_MGR_SLOT, 
               &win_mgr_colors[ii], win_mgr_colors[ii].phys_slot);
         }
         else
         {
            IGEcalc_best_match(win_mgr_colors[ii].log_red, win_mgr_colors[ii].log_green,
               win_mgr_colors[ii].log_blue, &within_tol, tolerance,
               VLT_COLOR_CUBE_SLOT, VLT_INGR_RES_SLOT|VLT_HILITE_SLOT|
               VLT_WIN_MGR_SLOT|VLT_CANNOT_SWAP_SLOT|VLT_SPECIAL_AREA_SLOT,
               total_colors, &matched_slot);
            /*If win_mgr slot designated is a cube slot (not ingr_res), it was written over*/
            /*by load cube.  we then need to swap the cube color that overwrote it*/
            /*with the one that is a best match.  The win mgr slot should be marked*/
            /*win_mgr, color_cube, and cannot swap.  The other marked color_cube.*/
            if ((IGEphys_vlt[win_mgr_colors[ii].phys_slot].flags&VLT_COLOR_CUBE_SLOT)&&
               (matched_slot != NO_MATCH))
            {
#ifdef DEBUG_CL
               printf("IGEload_win_mgr: win_mgr written over by color cube WM slot %d match %d tol=%d\n",
                  win_mgr_colors[ii].phys_slot,matched_slot,within_tol);
#endif
               if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, total_colors))
               {
                  /* swap the cube out to an empty slot and create exact match */
                  IGEphys_vlt[available_slot] = IGEphys_vlt[win_mgr_colors[ii].phys_slot];
                  if (matched_slot == win_mgr_colors[ii].phys_slot)
                  {
                     /* the matched slot was just moved out to available slot */
                     matched_slot = available_slot;
                  }
                  IGEcreate_exact_match(VLT_WIN_MGR_SLOT, &win_mgr_colors[ii], 
                     win_mgr_colors[ii].phys_slot);
                  if (within_tol) 
                  {
                     IGEswap(IGE_WIN_MGR_CUBE_TO_CUBE_SWAP, &win_mgr_colors[ii],
                        matched_slot);
                  }
               }
               else
               {
                  IGEswap(IGE_WIN_MGR_CUBE_TO_CUBE_SWAP, &win_mgr_colors[ii],
                     matched_slot);
               }
            }
            else
            /* Swapped out a color cube slot with an earlier default slot overwritten by load cube*/
            if (IGEphys_vlt[win_mgr_colors[ii].phys_slot].flags&VLT_EMPTY_SLOT)
            {
               IGEcreate_exact_match(VLT_WIN_MGR_SLOT, &win_mgr_colors[ii], 
                  win_mgr_colors[ii].phys_slot);
               if (within_tol) 
               {
                  IGEswap(IGE_WIN_MGR_TO_CUBE_SWAP, &win_mgr_colors[ii],
                     matched_slot);
               }
            }
            else
            {   
               if (within_tol&&
                  !(IGEphys_vlt[win_mgr_colors[ii].phys_slot].flags&
                   (VLT_CANNOT_SWAP_SLOT|VLT_SPECIAL_AREA_SLOT|VLT_HILITE_SLOT))) 
                   /* Don't swap if already swapped or special or hilite */
               {
#ifdef DEBUG_CL
                  printf("IGEload_win_mgr: win_mgr outside of win mgr IR slot %d matched %d\n",
                     win_mgr_colors[ii].phys_slot,matched_slot);
#endif
                  IGEswap(IGE_WIN_MGR_TO_CUBE_SWAP, &win_mgr_colors[ii],
                     matched_slot);
               }
               else
               {
                  /* if can't swap within tolerance assign to initial slot chosen */
                  IGEassign_to_slot(VLT_WIN_MGR_SLOT, 
                     &win_mgr_colors[ii], win_mgr_colors[ii].phys_slot);
               }
            }
         }
      }
   }
   return(0);
}  /* IGEload_window_manager */

/*--- IGEload_ingr_res -------------------------------------------------*/

IGRint IGEload_ingr_res( 
   IGRboolean      assign_slot,
   IGRdouble      tolerance,
   IGRint          num_ingr_res_colors,
   struct IGEcolor_mapping   *ingr_res_colors,
   IGRint          total_colors )

/*
NAME
   IGEload_ingr_res

DESCRIPTION
   This function loads the intergraph reserved colors into the physical vlt.  The
   assign_slot flag will be TRUE the first time and subsequent calls will all
   be FALSE.  This is because the intergraph colors are assigned slots 
   once and then don't change.  The intergraph reserved 
   colors are loaded again to see if a swap with the cube can be made that is 
   not already a window manager color.

PARAMETERS
   assign_slot (IN) - flag if going to change slot mapped to.
   tolerance (IN) - the percentage in rgb distance to be close enough
   num_ingr_res_colors (IN) - number of colors to load
   ingr_res_colors (IN) - the colors to load
   total_colors (IN) - number of colors in phys_vlt

GLOBALS USED
   none
   
RETURN VALUES
   0 - success
   1 - failure

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii, index, suggested_slot;
   IGRboolean      within_tol;
   IGRint             matched_slot;
   IGRint             available_slot;
   struct WLcmap_entry temp_entry;

   if (assign_slot && ( num_ingr_res_colors == 14 ))
   {
      /* We do not want to assign an intergraph reserved color to slot 0, */
      /* Env5 case should be in 1-14, X case needs to be greater than 1,  */
      /* since the colormap_notify starts looking at slot 1-...  We will  */
      /* therefore reserve it as special area.  Set back when done.       */
      /* EXCEPTION: on rop slot 0 is black num_ingr_res_colors = 5        */
      temp_entry = IGEphys_vlt[0];
      IGEphys_vlt[0].flags = VLT_SPECIAL_AREA_SLOT;
   }

   for ( index = 0; index < num_ingr_res_colors; index++ )
   {
      if ( num_ingr_res_colors == 14 )
      {
         /* for the common case (non-rop) and standard 14 ingr menu colors
            do a priority search through colors to get the cube colors first
            for overall performance */
         switch ( index )
         {
            case 0: /* black */
               ii = 2;
               break;
            case 1: /* white */
               ii = 6;
               break;
            case 2: /* red */
               ii = 7;
               break;
            case 3: /* green */
               ii = 8;
               break;
            case 4: /* blue */
               ii = 9;
               break;
            case 5: /* yellow */
               ii = 3;
               break;
            case 6: /* off white */
               ii = 0;
               break;
            case 7: /* mid gray */
               ii = 1;
               break;
            case 8: /* light gray */
               ii = 4;
               break;
            case 9: /* dark gray */
               ii = 5;
               break;
            default:
               ii = index;
               break;
         }
      }
      else
      {
         ii = index;
      }

      if (assign_slot)
      {
         suggested_slot = ingr_res_colors[ii].phys_slot;
         if ((IGEphys_vlt[suggested_slot].flags & VLT_WIN_MGR_SLOT) &&
             !(IGEphys_vlt[suggested_slot].flags & (VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT)) &&
             (IGEphys_vlt[suggested_slot].red == ingr_res_colors[ii].log_red) &&
             (IGEphys_vlt[suggested_slot].green == ingr_res_colors[ii].log_green) &&
             (IGEphys_vlt[suggested_slot].blue == ingr_res_colors[ii].log_blue))
         {
            /* the suggested slot is an EXACT match so we will assign it here.  This is a
               way of breaking ties between exact matches (instead of selecting the first
               one).  NOTE: this was added for Clipper case of background of screen (slot 0) 
               was black and so was slot 3.  The best match function would match ingr black
               to slot 0 instead of slot 3 and if there were no more exact match slots, slot
               3 would be closest match to black. */
            within_tol = TRUE;
            matched_slot = suggested_slot;
         }
         else
         {
            /* suggested slot is not an exact match... search for best match */
            IGEcalc_best_match(ingr_res_colors[ii].log_red, ingr_res_colors[ii].log_green,
               ingr_res_colors[ii].log_blue, &within_tol, tolerance,
   /* if win_mgr and hilite_slot match is it o.k.? */
               VLT_WIN_MGR_SLOT, VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
               total_colors, &matched_slot);
         }
                  
         if (within_tol) 
         {
            IGEassign_to_slot(VLT_INGR_RES_SLOT, 
               &ingr_res_colors[ii], matched_slot);
         }
         else
         {
            if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, total_colors))
            {
               IGEcreate_exact_match(VLT_INGR_RES_SLOT, 
                  &ingr_res_colors[ii],available_slot);
            }
            else
            {
               if (matched_slot != NO_MATCH)
               {
#ifdef DEBUG_CL
                  printf("IGEload_ingr_res: assigning to win_mgr out of tol\n");
#endif
                  IGEassign_to_slot(VLT_INGR_RES_SLOT, 
                     &ingr_res_colors[ii], matched_slot);
               }
               else
               {
                  if (IGEslot_available( VLT_SPECIAL_AREA_SLOT, &available_slot, 
                     total_colors))
                  {
#ifdef DEBUG_CL
                     printf("IGEload_ingr_res: no slot available using special area\n");
#endif
                     IGEassign_to_slot(VLT_INGR_RES_SLOT, 
                        &ingr_res_colors[ii], matched_slot);
                  }
                  else
                  {
#ifdef DEBUG_CL
                     printf("IGEload_ingr_res: NO PLACE for ingr_res\n");
#endif
                  }
               }
            }
         }
      }
      else
      {
         IGEcalc_best_match(ingr_res_colors[ii].log_red, ingr_res_colors[ii].log_green,
            ingr_res_colors[ii].log_blue, &within_tol, tolerance, 
            VLT_COLOR_CUBE_SLOT, VLT_CANNOT_SWAP_SLOT|VLT_SPECIAL_AREA_SLOT|
            VLT_INGR_RES_SLOT|VLT_WIN_MGR_SLOT|VLT_HILITE_SLOT, total_colors, 
            &matched_slot);
         /*If winmgr slot designated is only a cube slot, then it was written over*/
         /*by load cube.  we then need to swap the cube color that overwrote it*/
         /*with the one that is a best match.  The win mgr slot should be marked*/
         /*ingr_res, color_cube, and cannot swap.  The other marked color_cube.*/
         if ((IGEphys_vlt[ingr_res_colors[ii].phys_slot].flags&VLT_COLOR_CUBE_SLOT)&&
            (matched_slot != NO_MATCH))
         {
#ifdef DEBUG_CL
            printf("IGEload_ingr_res: ingr_res written over by color cube WM slot %d match %d tol=%d\n",
               ingr_res_colors[ii].phys_slot,matched_slot,within_tol);
#endif
            if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, total_colors))
            {
               /* swap the cube out to an empty slot and create exact match */
               IGEphys_vlt[available_slot] = IGEphys_vlt[ingr_res_colors[ii].phys_slot];
               if (matched_slot == ingr_res_colors[ii].phys_slot)
               {
                  /* the matched slot was just moved out to available slot */
                  matched_slot = available_slot;
               }
               IGEcreate_exact_match(VLT_INGR_RES_SLOT, &ingr_res_colors[ii], 
                  ingr_res_colors[ii].phys_slot);
               if (within_tol) 
               {
                  IGEswap(IGE_INGR_RES_TO_CUBE_SWAP, &ingr_res_colors[ii],
                     matched_slot);
               }
            }
            else
            {
               IGEswap(IGE_INGR_RES_CUBE_TO_CUBE_SWAP, &ingr_res_colors[ii],
                  matched_slot);
            }
         }
         else
         /* Swapped out a color cube slot with an earlier window manager slot overwritten by load cube*/
         if (IGEphys_vlt[ingr_res_colors[ii].phys_slot].flags&VLT_EMPTY_SLOT)
         {
            IGEcreate_exact_match(VLT_INGR_RES_SLOT, &ingr_res_colors[ii],
               ingr_res_colors[ii].phys_slot);
            if (within_tol) 
            {
               IGEswap(IGE_INGR_RES_TO_CUBE_SWAP, &ingr_res_colors[ii],
                  matched_slot);
            }
         }
         else
         {   
            if (within_tol&&
               !(IGEphys_vlt[ingr_res_colors[ii].phys_slot].flags&
                (VLT_CANNOT_SWAP_SLOT|VLT_SPECIAL_AREA_SLOT|VLT_HILITE_SLOT))) 
                /* Don't swap if already swapped or special or hilite */
            {
               IGEswap(IGE_INGR_RES_TO_CUBE_SWAP, &ingr_res_colors[ii],
                  matched_slot);
            }
         }
      }
   }

   if (assign_slot && ( num_ingr_res_colors == 14 ))
   {
      /* Setting back slot 0 from earlier change */
      IGEphys_vlt[0] = temp_entry;
   }

   return(0);
}  /* IGEload_ingr_res */

/*--- IGEload_logical -------------------------------------------------*/

IGRint IGEload_logical( 
   IGRdouble      tolerance,
   IGRdouble      *gamma,
   IGRint          num_bg_log_hl_colors,
   struct IGEphys_color_mapping *bg_log_hl_mapping,
   struct IGElogical_color *bg_log_hl_colors,
   IGRint          total_colors )

/*
NAME
   IGEload_logical

DESCRIPTION
   This function loads the logical colors into the physical vlt.  It loads
   the bg and hilite colors first then the logical colors.  There can be a
   many to one mapping of logical colors to a physical slot.

PARAMETERS
   tolerance (IN) - the percentage in rgb distance to be close enough
   num_bg_log_hl_colors (IN) - number of colors to load
   bg_log_hl_colors (IN) - the colors to load
   total_colors (IN) - number of colors in phys_vlt

GLOBALS USED
   none
   
RETURN VALUES
   0 - success
   1 - failure

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii,index;
   IGRboolean      within_tol, using_ramp;
   IGRint             matched_slot;
   IGRint             available_slot;

   if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
   {
      for ( ii = 0; ii<num_bg_log_hl_colors; ii++ )
      {
         IGEcompensate_array[(ii*3)] = bg_log_hl_colors[ii].log_red;
         IGEcompensate_array[(ii*3)+1] = bg_log_hl_colors[ii].log_green;
         IGEcompensate_array[(ii*3)+2] = bg_log_hl_colors[ii].log_blue;
      }
      (*IGEgamma_compensate_ptr)( num_bg_log_hl_colors, IGEcompensate_array, gamma, 1);
      for ( ii = 0; ii<num_bg_log_hl_colors; ii++ )
      {
         bg_log_hl_mapping[ii].phys_red = IGEcompensate_array[(ii*3)];
         bg_log_hl_mapping[ii].phys_green = IGEcompensate_array[(ii*3)+1];
         bg_log_hl_mapping[ii].phys_blue = IGEcompensate_array[(ii*3)+2];
      }
   }
   else
   {
      for ( ii = 0; ii<num_bg_log_hl_colors; ii++ )
      {
         bg_log_hl_mapping[ii].phys_red = bg_log_hl_colors[ii].log_red;
         bg_log_hl_mapping[ii].phys_green = bg_log_hl_colors[ii].log_green;
         bg_log_hl_mapping[ii].phys_blue = bg_log_hl_colors[ii].log_blue;
      }
   }

   using_ramp = IGEget_using_ramp_mode( );
   for ( ii = 0, index = 0; ii<num_bg_log_hl_colors; ii++ )
   {
      /* this is to search bg [0], hilite [num-1], then logical colors [1:num-2] */
      if (ii > 1) index = ii-1;
      else if (ii == 1) index = num_bg_log_hl_colors-1;

      /* calc best match with compensated values if compensated */
      if (using_ramp && (ii > 1))
      {
         /* if using ramp and not background or highlight searc base slots*/
         IGEcalc_best_match(bg_log_hl_mapping[index].phys_red, bg_log_hl_mapping[index].phys_green,
            bg_log_hl_mapping[index].phys_blue, &within_tol, tolerance,
            VLT_RAMP_BASE_COLOR_SLOT, VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
            total_colors, &matched_slot);
         /* For mapping to ramp base colors always assign to closest slot (don't exact match) */
         within_tol = TRUE;
      }
      else
      {
         IGEcalc_best_match(bg_log_hl_mapping[index].phys_red, bg_log_hl_mapping[index].phys_green,
            bg_log_hl_mapping[index].phys_blue, &within_tol, tolerance,
            VLT_USED_SLOTS, VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
            total_colors, &matched_slot);
      }
      if (within_tol) 
      {
         IGElog_assign_to_slot(0, &bg_log_hl_mapping[index], matched_slot);
      }
      else
      {
         if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, total_colors))
         {
            IGElog_create_exact_match( 0, &bg_log_hl_mapping[index] ,available_slot);
         }
         else
         {
            if (matched_slot != NO_MATCH)
            {
#ifdef DEBUG_CL
               printf("IGEload_logical: assigning log %d beyond tol to %d\n", 
                  index, matched_slot);
#endif
               IGElog_assign_to_slot(0, &bg_log_hl_mapping[index], matched_slot);
            }
            else
            {
#ifdef DEBUG_CL
               printf("IGEload_logical: NO PLACE for logical color\n");
#endif
            }
         }
      }
   }

   return(0);
}  /* IGEload_logical */

/*--- IGEremap_logical_table -------------------------------------------------*/

IGRint IGEremap_logical_table( 
   WLuint32       context_no, 
   IGRdouble      tolerance,
   IGRdouble      *gamma,
   IGRint         *bg_log_hl, 
   IGRint         num_bg_log_hl_colors, 
   IGRint         start_color, 
   IGRint         num_changed_colors)

/*
NAME
   IGEremap_logical_table

DESCRIPTION
   This function loads the logical colors into the physical vlt.  It loads
   the bg and hilite colors first then the logical colors.  There can be a
   many to one mapping of logical colors to a physical slot.

PARAMETERS
   context_no (IN) - the context to remap
   tolerance (IN) - the percentage in rgb distance to be close enough
   num_bg_log_hl_colors (IN) - number of colors to load
   bg_log_hl_colors (IN) - the colors to load
   total_colors (IN) - number of colors in phys_vlt

GLOBALS USED
   none
   
RETURN VALUES
   0 - success
   1 - failure

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint             ii, index, sts = 0;
   IGRboolean      within_tol;
   IGRint             matched_slot;
   IGRint             available_slot;
   void         *tmp_ptr;
   IGRushort      *IGEcompensate_array_ptr = (IGRushort *)NULL;
   struct WLcontext_info WLcontext_info;
   struct IGEcontext_info IGEcontext_info;
   WLcolorref   color_ref;
   
   IGEload_context( context_no, &IGEcontext_info );
   WLget_context_info( context_no, &WLcontext_info );

   if ( IGEcontext_info.num_bg_log_hl_colors<num_bg_log_hl_colors )
   {
      /* number of colors increased malloc larger arrays */
      tmp_ptr = malloc( sizeof(struct IGEphys_color_mapping)*num_bg_log_hl_colors );
      if ( tmp_ptr == NULL )
      {
#ifdef DEBUG_CL
         printf("IGEremap_logical_table: could not allocate larger color table\n");
#endif
         sts = 1;
         goto wrapup;
      }
      memcpy( tmp_ptr, IGEcontext_info.bg_log_hl, 
         sizeof(struct IGEphys_color_mapping)*IGEcontext_info.num_bg_log_hl_colors );
      free( IGEcontext_info.bg_log_hl );
      IGEcontext_info.bg_log_hl = (struct IGEphys_color_mapping *)tmp_ptr;
      for ( ii = IGEcontext_info.num_bg_log_hl_colors; ii<num_bg_log_hl_colors; ii++ )
      {
         /* we can't IGEfree_slot these slots because never assigned */
         IGEcontext_info.bg_log_hl[ii].phys_slot = -1;
      }
      IGEcontext_info.num_bg_log_hl_colors = num_bg_log_hl_colors;
      IGEsave_context( context_no, &IGEcontext_info );
   }

   /* enter value to search for into the phys_* values */
   if ( gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0 )   
   {
      if ( num_changed_colors>512 )
      {
         /* IGEcompensate array can be used almost all of the time w/size 512 */
         IGEcompensate_array_ptr = (IGRushort *) 
            malloc(sizeof(IGRushort)*num_changed_colors*3);   
      }
      else
      {
         IGEcompensate_array_ptr = IGEcompensate_array;
      }
   
      for ( ii = 0; ii<num_changed_colors; ii++ )
      {
         CLunpack_colors( bg_log_hl[start_color+ii], &(IGEcompensate_array_ptr[(ii*3)]),
            &(IGEcompensate_array_ptr[(ii*3)+1]), &(IGEcompensate_array_ptr[(ii*3)+2]));
      }
      (*IGEgamma_compensate_ptr)( num_changed_colors, IGEcompensate_array_ptr, gamma, 1);
      for ( ii = 0; ii<num_changed_colors; ii++ )
      {
         IGEcontext_info.bg_log_hl[start_color+ii].phys_red = IGEcompensate_array_ptr[(ii*3)];
         IGEcontext_info.bg_log_hl[start_color+ii].phys_green = IGEcompensate_array_ptr[(ii*3)+1];
         IGEcontext_info.bg_log_hl[start_color+ii].phys_blue = IGEcompensate_array_ptr[(ii*3)+2];
      }
   }
   else
   {
      for ( ii = start_color; ii<start_color+num_changed_colors; ii++ )
      {
         CLunpack_colors( bg_log_hl[ii], &(IGEcontext_info.bg_log_hl[ii].phys_red),
            &(IGEcontext_info.bg_log_hl[ii].phys_green), &(IGEcontext_info.bg_log_hl[ii].phys_blue) );
      }
   }

   if (!(WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR))
   {
      for ( ii = start_color; ii<start_color+num_changed_colors; ii++ )
      {
         /* this is to search bg [0], hilite [num-1], then logical colors [1:num-2] */
         if (start_color+num_changed_colors == num_bg_log_hl_colors)
         {
            /* hilight is one of the changed colors */
            if (ii>0) /* leave background index of ii = 0 alone */
            {
               if (((ii == start_color) && (start_color > 0)) || (ii == 1)) 
               /* (ii==1) ==> ((ii==start_color+1)&&(start_color==0)))*/
               {
                  /* give priority to hilight */
                  index = num_bg_log_hl_colors-1;
               }
               else
               {
                  /* in the logical colors part */
                  index = ii-1;
               }
            }
            else
            {
               index = 0;
            }
         }
         else
         {
            index = ii;
         }
   
         if ( IGEcontext_info.bg_log_hl[index].phys_slot != -1 )
         {
            /* changing an existing color */
            if (!IGEfree_slot( index, IGEcontext_info.bg_log_hl[index].phys_slot,
                IGEcontext_info.num_bg_log_hl_colors, IGEcontext_info.bg_log_hl ))
            {
               /* Freed the slot; save the flag of free */
               WLload_cmap_entries( context_no, 1, &(IGEphys_vlt[IGEcontext_info.bg_log_hl[index].phys_slot]) );
            }
         }
         
         /* calc best match with compensated values if compensated */
         if (IGEcontext_info.using_ramp && (index != 0) && (index != IGEcontext_info.num_bg_log_hl_colors))
         {
            /* if using ramp and not background or highlight searc base slots*/
            IGEcalc_best_match(IGEcontext_info.bg_log_hl[index].phys_red, IGEcontext_info.bg_log_hl[index].phys_green,
               IGEcontext_info.bg_log_hl[index].phys_blue, &within_tol, tolerance,
               VLT_RAMP_BASE_COLOR_SLOT, VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
               1 << IGEcontext_info.table_depth, &matched_slot);
            /* For mapping to ramp base colors always assign to closest slot (don't exact match) */
            within_tol = TRUE;
         }
         else
         {
            /* Pseudo True color or Ramp bg or hl */
            IGEcalc_best_match(IGEcontext_info.bg_log_hl[index].phys_red, IGEcontext_info.bg_log_hl[index].phys_green,
               IGEcontext_info.bg_log_hl[index].phys_blue, &within_tol, tolerance,
               VLT_USED_SLOTS, VLT_SPECIAL_AREA_SLOT|VLT_HILITE_SLOT,
               1 << IGEcontext_info.table_depth, &matched_slot);
         }
   
         if (within_tol) 
         {
            IGElog_assign_to_slot(0, &IGEcontext_info.bg_log_hl[index], matched_slot);
         }
         else
         {
            if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, 
               1 << IGEcontext_info.table_depth))
            {
               IGElog_create_exact_match( 0, &IGEcontext_info.bg_log_hl[index], 
                  available_slot);
               /* created an exact match, now load in the changes */
               WLload_cmap_entries( context_no, 1, &(IGEphys_vlt[available_slot]) );
            }
            else
            {
               if (matched_slot != NO_MATCH)
               {
#ifdef DEBUG_CL
                  printf("IGEremap_logical_table: ctx %X assigning log %d beyond tol to %d\n", 
                     context_no, index, matched_slot);
#endif
                  IGElog_assign_to_slot( 0, &IGEcontext_info.bg_log_hl[index], matched_slot );
               }
#ifdef DEBUG_CL
               else
               {
                  printf("IGEremap_logical_table: NO PLACE for logical color\n");
               }
#endif
            }
         }
      }
   }

   if (WLcontext_info.hilite_used && (start_color + num_changed_colors == num_bg_log_hl_colors))
   {
      /* filling in the hilight plane is always an exact match so check to see if the logical
         value of the highlight plane is the same as in physical table.  The phys_red etc; values
         may change if it was not an exact match for the one slot it matched to.  If not reload 
         hilight plane */

      /* We can use IGEcompensate_array instead of IGEcompensate_array_ptr since we are only using
         one color (i.e. not over 512) */
      CLunpack_colors( bg_log_hl[num_bg_log_hl_colors - 1], &(IGEcompensate_array[0]),
         &(IGEcompensate_array[1]), &(IGEcompensate_array[2]));
      if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)
      {
         (*IGEgamma_compensate_ptr)( 1, IGEcompensate_array, gamma, 1);
      }
      if ((IGEphys_vlt[1 << (IGEcontext_info.table_depth - 1)].red != IGEcompensate_array[0]) ||
          (IGEphys_vlt[1 << (IGEcontext_info.table_depth - 1)].green != IGEcompensate_array[1]) ||
          (IGEphys_vlt[1 << (IGEcontext_info.table_depth - 1)].blue != IGEcompensate_array[2]))
      { 
         /* using the hilite plane and hilite color changed.  load the top half of color table */
         for (ii = 1 << (IGEcontext_info.table_depth - 1); ii < 1 << IGEcontext_info.table_depth; ii++)
         { 
            IGEphys_vlt[ii].red = IGEcompensate_array[0];
            IGEphys_vlt[ii].green = IGEcompensate_array[1];
            IGEphys_vlt[ii].blue = IGEcompensate_array[2];
         }
         WLload_cmap_entries( context_no, 1 << (IGEcontext_info.table_depth - 1), 
            &(IGEphys_vlt[1 << (IGEcontext_info.table_depth - 1)]) );
      }
   }
wrapup:   
   IGEsave_context( context_no, &IGEcontext_info );

   if (start_color == 0)
   {
      /* save the new background mapping */
      WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
      WLset_background( WL_UNDEFINED_WINDOW, color_ref );
   }

   if ( num_bg_log_hl_colors>512 )
   {
      if ( IGEcompensate_array_ptr != NULL )
      {
         free( IGEcompensate_array_ptr );   
      }
   }

   return( sts );
}  /* IGEremap_logical_table */

/* --- IGEindex_to_rgb -------------------------------------------------*/

void IGEindex_to_rgb( 
   WLuint32 context_no,
   IGRint flag,
   IGRint index,
   IGRint *out_red,
   IGRint *out_green,
   IGRint *out_blue )

/*
NAME
   IGEindex_to_rgb

DESCRIPTION
   This function gets the RGB value for a given index into a VLT.

PARAMETERS
   context_no (IN) - the context to use
   flag (in) - the type of rgb to return
   index (IN) - the index into the VLT
   red (OUT) - the red component of the RGB value
   green (OUT) - the green component of the RGB value
   blue (OUT) - the blue component of the RGB value

GLOBALS USED
   none

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   struct IGEcontext_info      context_info;
   
   switch (flag)
   {
      case IGE_LOGICAL_INDEX_TO_LOG:
         *out_red = (IGRint) IGEbg_log_hl_colors[index].log_red >> 8;
         *out_green = (IGRint) IGEbg_log_hl_colors[index].log_green >> 8;
         *out_blue = (IGRint) IGEbg_log_hl_colors[index].log_blue >> 8;
         break;
      case IGE_LOGICAL_INDEX_TO_PHYS:
         IGEload_context(context_no,&context_info);
         *out_red = (IGRint) context_info.bg_log_hl[index].phys_red >> 8;
         *out_green = (IGRint) context_info.bg_log_hl[index].phys_green >> 8;
         *out_blue = (IGRint) context_info.bg_log_hl[index].phys_blue >> 8;
         break;
      case IGE_PHYSICAL_INDEX:
         IGEload_context(context_no,&context_info);
         *out_red = (IGRint) IGEphys_vlt[index].red >> 8;
         *out_green = (IGRint) IGEphys_vlt[index].green >> 8;
         *out_blue = (IGRint) IGEphys_vlt[index].blue >> 8;
         break;
      default:
#ifdef DEBUG_CL
         printf("IGEindex_to_rgb: invalid flag\n");
#endif
         break;
   }

}  /* IGEindex_to_rgb */

 
/*--- IGErgb_to_index ------------------------------------------------------*/

IGRint IGErgb_to_index( 
   WLuint32 context_no,
   IGRint x, 
   IGRint y, 
   IGRint red, 
   IGRint grn, 
   IGRint blu)

/*
NAME
   IGErgb_to_index

DESCRIPTION
   This function calculates the VLT index that should be used to
   draw a pixel given the XY coordinates of the pixel and its
   RGB color.  (For Psuedo True Color)

PARAMETERS
   x (IN) - x coordinate of pixel to be drawn
   y (IN) - y coordinate of pixel to be drawn
   red (IN) - red component of pixel color; [0..255]
   green (IN) - green component of pixel color; [0..255]
   blue (IN) - blue component of pixel color; [0..255]

GLOBALS USED

RETURN VALUES
   The VLT index that should be used to draw the pixel is returned.

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint num_intens;
   register int dither_val;
   static int   dither_mat[16] = {  0,  8,  2, 10,   /* 4x4 ordered */
                                   12,  4, 14,  6,   /*   dither    */
                                    3, 11,  1,  9,
                                   15,  7, 13,  5 };

   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);
   
   /* Scale to actual number of intensities allowed. */
   num_intens = ((context_info.cube_size-1)*16)+1;
   red = (red * num_intens) >> 8;
   grn = (grn * num_intens) >> 8;
   blu = (blu * num_intens) >> 8;

   /* Calculate dither value. */
   dither_val = dither_mat[((y & 3) << 2) | (x & 3)];

   /* Perform dithering to achieve halftones. */
   red = (((red & 15) > dither_val) ? ((red >> 4) + 1) : (red >> 4));
   grn = (((grn & 15) > dither_val) ? ((grn >> 4) + 1) : (grn >> 4));
   blu = (((blu & 15) > dither_val) ? ((blu >> 4) + 1) : (blu >> 4));

   /* Return vlt color index value which corresponds to calculated */
   /*   9-bit rgb dither value.                                    */
   return( context_info.rgb_table[(blu << 6) | (grn << 3) | red] );

} /* IGErgb_to_index */

/*--- IGEcopy_pack_to_map ------------------------------------------------------*/

void   IGEcopy_pack_to_map(
   IGRint num_colors,
   IGRint *packed_colors,
   struct IGEcolor_mapping *map_colors)

/*
NAME
   IGEcopy_pack_to_map

DESCRIPTION
   This function copies an array of packed colors (10 bit)
   into an IGEcolor_mapping structure.

PARAMETERS
   num_colors (IN) - the number of colors to transfer.
   packed_colors (IN) - the array of packed colors to copy
   map_colors (OUT) - the array of structs to receive colors
   
GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint i;
   
   for (i = 0;i<num_colors;i++)
   {
      CLunpack_colors(packed_colors[i],&(map_colors[i].log_red),
         &(map_colors[i].log_green),&(map_colors[i].log_blue));
   }
} /* IGEcopy_pack_to_map */

/*--- IGEcopy_map_to_pack ------------------------------------------------------*/

void   IGEcopy_map_to_pack(
   IGRint num_colors,
   struct IGEcolor_mapping *map_colors,
   IGRint *packed_colors)
/*
NAME
   IGEcopy_map_to_pack

DESCRIPTION
   This function copies an array of IGEcolor_mapping structures
   into an packed colors (10 bit) array.

PARAMETERS
   num_colors (IN) - the number of colors to transfer.
   map_colors (IN) - the array of structs to receive colors
   packed_colors (OUT) - the array of packed colors to copy
   
GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGRint i;
   
   for (i = 0;i<num_colors;i++)
   {
      packed_colors[i] = CLpack_colors(map_colors[i].log_red,
         map_colors[i].log_green,map_colors[i].log_blue);
   }
} /* IGEcopy_map_to_pack */

/*--- IGEswap ------------------------------------------------------*/

IGRint IGEswap(
   IGRboolean swap_type,
   struct IGEcolor_mapping *map_colors,
   IGRint slot)
/*
NAME
   IGEswap

DESCRIPTION
   This function swaps 2 physical slots.  It swaps the map_colors->phys_slot
   with the slot keeping the rgb value of slot (which is a cube).  It then 
   assigns the slot to empty if sharing between a reserved color.

PARAMETERS
   swap_type (IN) - the type of swap occuring
   map_colors (IN) - the color_map structure to change
   slot (IN) - the slot to change with
   
GLOBALS USED
   none

RETURN VALUES
   0 = success

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   struct WLcmap_entry tmp_vlt;

   tmp_vlt = IGEphys_vlt[map_colors->phys_slot];
   IGEphys_vlt[map_colors->phys_slot] = IGEphys_vlt[slot];
   IGEphys_vlt[slot] = tmp_vlt;
   map_colors->phys_red = IGEphys_vlt[map_colors->phys_slot].red;
   map_colors->phys_green = IGEphys_vlt[map_colors->phys_slot].green;
   map_colors->phys_blue = IGEphys_vlt[map_colors->phys_slot].blue;
      
   if (map_colors->phys_slot == slot)
   {
#ifdef DEBUG_CL
      printf("IGEswap: Swapping the same slot %d\n",slot);
#endif
   }

   switch (swap_type)
   {
      /* Assign the slot phys vlt first in case slot = map_colors->phys_slot*/
      case IGE_WIN_MGR_TO_CUBE_SWAP:
         IGEphys_vlt[slot].flags = VLT_EMPTY_SLOT;
         IGEphys_vlt[map_colors->phys_slot].flags = VLT_CANNOT_SWAP_SLOT|
            VLT_COLOR_CUBE_SLOT|VLT_WIN_MGR_SLOT;
         break;
      case IGE_INGR_RES_TO_CUBE_SWAP:
         IGEphys_vlt[slot].flags = VLT_EMPTY_SLOT;
         IGEphys_vlt[map_colors->phys_slot].flags = VLT_CANNOT_SWAP_SLOT|
            VLT_COLOR_CUBE_SLOT|VLT_INGR_RES_SLOT;
         break;
      case IGE_WIN_MGR_CUBE_TO_CUBE_SWAP:
         IGEphys_vlt[slot].flags = VLT_COLOR_CUBE_SLOT;
         IGEphys_vlt[map_colors->phys_slot].flags = VLT_CANNOT_SWAP_SLOT|
            VLT_COLOR_CUBE_SLOT|VLT_WIN_MGR_SLOT;
         break;
      case IGE_INGR_RES_CUBE_TO_CUBE_SWAP:
         IGEphys_vlt[slot].flags = VLT_COLOR_CUBE_SLOT;
         IGEphys_vlt[map_colors->phys_slot].flags = VLT_CANNOT_SWAP_SLOT|
            VLT_COLOR_CUBE_SLOT|VLT_INGR_RES_SLOT;
         break;
      default:
#ifdef DEBUG_CL
         printf("IGEswap: improper swap_type\n");
#endif
         return(1);
   }
   return(0);
}

/*--- IGEcreate_exact_match ------------------------------------------------------*/

IGRint IGEcreate_exact_match( 
   IGRint assign,
   struct IGEcolor_mapping *color,
   IGRint slot)
/*
NAME
   IGEcreate_exact_match

DESCRIPTION
   This function creates an exact match to a color at phys_vlt[slot]

PARAMETERS
   assign (IN) - What flag to assign to slot
   colors (IN) - the color_map structure to create
   slot (IN) - the slot to create exact match
   
GLOBALS USED
   none

RETURN VALUES
   0 = success

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGEphys_vlt[slot].slot = slot;
   IGEphys_vlt[slot].red = color->log_red;
   IGEphys_vlt[slot].green = color->log_green;
   IGEphys_vlt[slot].blue = color->log_blue;
   IGEphys_vlt[slot].flags = assign|VLT_EXACT_MATCH_SLOT;
   color->phys_slot = slot;
   color->phys_red = color->log_red;
   color->phys_green = color->log_green;
   color->phys_blue = color->log_blue;
   return(0);
}

/*--- IGElog_create_exact_match ------------------------------------------------------*/

IGRint IGElog_create_exact_match( 
   IGRint assign,
   struct IGEphys_color_mapping *color_mapping,
   IGRint slot)
/*
NAME
   IGEcreate_exact_match

DESCRIPTION
   This function creates an exact match to a color at phys_vlt[slot]

PARAMETERS
   assign (IN) - What flag to assign to slot
   colors (IN) - the color_map structure to create
   slot (IN) - the slot to create exact match
   
GLOBALS USED
   none

RETURN VALUES
   0 success
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGEphys_vlt[slot].slot = slot;
   IGEphys_vlt[slot].red = color_mapping->phys_red;
   IGEphys_vlt[slot].green = color_mapping->phys_green;
   IGEphys_vlt[slot].blue = color_mapping->phys_blue;
   IGEphys_vlt[slot].flags = assign|VLT_EXACT_MATCH_SLOT;
   color_mapping->phys_slot = slot;
   return(0);
}

/*--- IGEassign_to_slot ------------------------------------------------------*/

IGRint IGEassign_to_slot( 
   IGRint assign,
   struct IGEcolor_mapping *color,
   IGRint slot)
/*
NAME
   IGEassign_to_slot

DESCRIPTION
   This function assigns a color to phys_vlt[slot]

PARAMETERS
   assign (IN) - What flag to assign to slot
   color (IN) - the color_map structure to create
   slot (IN) - the slot to assign
   
GLOBALS USED
   none

RETURN VALUES
   0 success
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGEphys_vlt[slot].flags |= assign;
   color->phys_slot = slot;
   color->phys_red = IGEphys_vlt[slot].red;
   color->phys_green = IGEphys_vlt[slot].green;
   color->phys_blue = IGEphys_vlt[slot].blue;
   return(0);
}

/*--- IGElog_assign_to_slot ------------------------------------------------------*/

IGRint IGElog_assign_to_slot( 
   IGRint assign,
   struct IGEphys_color_mapping *color,
   IGRint slot)
/*
NAME
   IGEassign_to_slot

DESCRIPTION
   This function assigns a color to phys_vlt[slot]

PARAMETERS
   assign (IN) - What flag to assign to slot
   color (IN) - the color_map structure to create
   slot (IN) - the slot to assign
   
GLOBALS USED
   none

RETURN VALUES
   0 success

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   IGEphys_vlt[slot].flags |= assign;
   color->phys_slot = slot;
   color->phys_red = IGEphys_vlt[slot].red;
   color->phys_green = IGEphys_vlt[slot].green;
   color->phys_blue = IGEphys_vlt[slot].blue;
   return(0);
}

/*--- IGEfree_slot ------------------------------------------------------*/

IGRint IGEfree_slot( 
   IGRint         index,
   IGRint         slot,  
   IGRint         num_bg_log_hl_colors,
   struct IGEphys_color_mapping   *bg_log_hl_colors)
/*
NAME
   IGEfree_slot

DESCRIPTION
   This function frees a slot if noone is using it.  This will only 
   be done with a vacated logical color exact match slot.

PARAMETERS
   slot (IN) - the slot to free
   num_bg_log_hl_colors (IN) - number of logical colors
   bg_log_hl_colors (IN) - logical colors
   
GLOBALS USED
   none

RETURN VALUES
   0 freed the slot
   1 didn't free the slot

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   IGRint i;
   
   if ( IGEphys_vlt[slot].flags&(VLT_COLOR_CUBE_SLOT | VLT_RAMP_SLOT |
      VLT_WIN_MGR_SLOT | VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT) )
   {
      return(1);
   }
   
   for (i = 0;i<num_bg_log_hl_colors;i++)
   {
      if ( (bg_log_hl_colors[i].phys_slot == slot)
         &&(i != index) )
      {
         return( 1 );
      }
   }
   /*free the slot*/
#ifdef DEBUG_CL
   printf("IGEfree_slot: freeing slot %d for bg_log_hl[%d] \n",slot,index);
#endif   
   IGEphys_vlt[slot].flags = VLT_EMPTY_SLOT;
   
   return(0);
}

/*--- IGEslot_available ------------------------------------------------------*/

IGRint IGEslot_available( 
   IGRint available, 
   IGRint *available_slot, 
   IGRint num_slots)
/*
NAME
   IGEslot_available

DESCRIPTION
   This function checks for the first available slot that matches
   the available flag (i.e. empty or cube to swap).

PARAMETERS
   available (IN) - flag for which slot to look for
   available_slot (OUT) - the available slot found -1 in none
   num_slots (IN) - the number of physical slots
   
GLOBALS USED
   none

RETURN VALUES
   1 if found a slot
   0 if no slot found

HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   IGRint ii;
   
   *available_slot = -1;
   for (ii = 0;ii<num_slots;ii++)
   {
      if ((IGEphys_vlt[ii].flags&available)&&
         !(IGEphys_vlt[ii].flags&VLT_CANNOT_SWAP_SLOT))
      {
         *available_slot = ii;
         return(1);
      }
   }
   return(0);
}

IGRint IGEconfigure_table( 
   WLuint32   context_no,
   IGRshort   cube_dimension, 
   IGRshort   special_size,
   IGRushort   *special_colors,
   IGRdouble   tolerance_pct,
   IGRdouble   *gamma)
{
/*
NAME
   IGEconfigure_table
DESCRIPTION
   This functions does a complete configuration of the color table
PARAMETERS
   context_no (in) - the context to configure
   cube_dimension (in) - the cube_dimension requested (2 if 2x2x2=8 cube)
   special_size (in) - the number of special slots requested to set aside
   special_colors (in) - what to set the special slots to
   tolerance_pct (in) - the tolerance of how close a color can be to another
      to be considered a match.
   gamma (in) - the values of the gamma function for red green and blue 
      (array of size 3)
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint sts = 1, ii, jj;
   IGRint slots_left_over,left_over_cube_dim,total_slots, num_color_slots;
   IGRint hilite_color;
   struct WLcontext_info WLcontext_info;
   struct IGEcontext_info IGEcontext_info;
   int shifter;
   int min_ramp_size = 0, num_ramp_reserved;
   int num_contiguous_slots, max_num_contiguous_slots, num_used_slots, slot_ok, start_slot;
   WLcolorref   color_ref;

   IGEload_context( context_no, &IGEcontext_info );
   WLget_context_info( context_no, &WLcontext_info );
   total_slots = 1 << IGEcontext_info.table_depth;
   
   if (WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR)
   {
      num_color_slots = 1 << (WLcontext_info.base_depth / 3);
      shifter = 8 + (8 - (WLcontext_info.base_depth / 3));
      if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)
      {
         /* compensate the highlight color if compensation is on */
         IGEcompensate_array[0] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_red;
         IGEcompensate_array[1] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_green;
         IGEcompensate_array[2] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_blue;
         (*IGEgamma_compensate_ptr)( 1 /* num_colors */, IGEcompensate_array, gamma, 1 /* compensate */);
         hilite_color = CLpack_colors( IGEcompensate_array[0], IGEcompensate_array[1], IGEcompensate_array[2]);
      }
      else
      {
         /* don't compensate just give the uncompensated value */
         hilite_color = CLpack_colors(IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_red,
            IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_green,
            IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_blue);
      }

      sts = IGEinit_physical_vlt( IGEcontext_info.table_depth, WLcontext_info.hilite_used, 
         hilite_color);

      if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)
      {
         for (ii = 0; ii < num_color_slots; ii++)
         {
            /* add precision to the shift for loading this TRUE color phys_vlt */
            if (shifter == 12)
            {
               IGEcompensate_array[ii*3] = IGEcompensate_array[(ii*3)+1] = 
                  IGEcompensate_array[(ii*3)+2] = ii << 12 | ii << 8 | ii << 4 | ii;
            }
            else
            {
               if (shifter == 8)
               {
                  IGEcompensate_array[ii*3] = IGEcompensate_array[(ii*3)+1] = 
                     IGEcompensate_array[(ii*3)+2] = ii << 8 | ii;
               }
               else
               {
                  IGEcompensate_array[ii*3] = IGEcompensate_array[(ii*3)+1] = 
                     IGEcompensate_array[(ii*3)+2] = ii << shifter;
               }
            }
         }
         (*IGEgamma_compensate_ptr)( num_color_slots, IGEcompensate_array, gamma, 1 );
      
         for (ii = 0; ii < num_color_slots; ii++)
         {
            IGEphys_vlt[ii].slot = ii;
            IGEphys_vlt[ii].red = IGEcompensate_array[ii*3];
            IGEphys_vlt[ii].green = IGEcompensate_array[(ii*3)+1];
            IGEphys_vlt[ii].blue = IGEcompensate_array[(ii*3)+2];
            IGEphys_vlt[ii].flags = 0;
         }
      }
      else
      {
         for (ii = 0; ii < num_color_slots; ii++)
         {
            IGEphys_vlt[ii].slot = ii;
            /* add precision to the shift for loading this TRUE color phys_vlt */
            if (shifter == 12)
            {
               IGEphys_vlt[ii].red = IGEphys_vlt[ii].green = 
                  IGEphys_vlt[ii].blue = ii << 12 | ii << 8 | ii << 4 | ii;
            }
            else
            {
               if (shifter == 8)
               {
                  IGEphys_vlt[ii].red = IGEphys_vlt[ii].green = 
                     IGEphys_vlt[ii].blue = ii << 8 | ii;
               }
               else
               {
                  IGEphys_vlt[ii].red = IGEphys_vlt[ii].green = 
                     IGEphys_vlt[ii].blue = ii << shifter;
               }
            }
            IGEphys_vlt[ii].flags = 0;
         }
      }
      /* load all of the logical colors */
      for ( ii = 0; ii<IGEcontext_info.num_bg_log_hl_colors; ii++ )
      {
         IGEcontext_info.bg_log_hl[ii].phys_red =
            IGEphys_vlt[IGEbg_log_hl_colors[ii].log_red >> shifter].red;
         IGEcontext_info.bg_log_hl[ii].phys_green =
            IGEphys_vlt[IGEbg_log_hl_colors[ii].log_green >> shifter].green;
         IGEcontext_info.bg_log_hl[ii].phys_blue =
            IGEphys_vlt[IGEbg_log_hl_colors[ii].log_blue >> shifter].blue;
      }
      /* save the context info and load table */
      goto wrapup;
   }

   /* index color map */
   num_color_slots = 1 << WLcontext_info.base_depth;

   if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)
   {
      /* compensate the highlight color if compensation is on */
      IGEcompensate_array[0] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_red;
      IGEcompensate_array[1] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_green;
      IGEcompensate_array[2] = IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_blue;
      (*IGEgamma_compensate_ptr)( 1 /* num_colors */, IGEcompensate_array, gamma, 1 /* compensate */);
      hilite_color = CLpack_colors( IGEcompensate_array[0], IGEcompensate_array[1], IGEcompensate_array[2]);
   }
   else
   {
      /* don't compensate just give the uncompensated value */
      hilite_color = CLpack_colors(IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_red,
         IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_green,
         IGEbg_log_hl_colors[IGEcontext_info.num_bg_log_hl_colors-1].log_blue);
   }

   /* need to see where special area and window manager and ingr reserve are and then count up spots */
   sts = IGEinit_physical_vlt( IGEcontext_info.table_depth, WLcontext_info.hilite_used, hilite_color);

   if (special_size)
   {
      sts = IGEres_special_area( special_size, special_colors, num_color_slots,
         IGEcontext_info.num_win_mgr_colors, IGEcontext_info.win_mgr, 
         IGEcontext_info.num_ingr_res_colors, IGEcontext_info.ingr_res);
   }

   if (IGEcontext_info.using_ramp)
   {
      max_num_contiguous_slots = num_contiguous_slots = num_used_slots = 0;
      for (ii = 0; ii < num_color_slots; ii++)
      {
         slot_ok = TRUE;
         for (jj = 0; jj < IGEcontext_info.num_win_mgr_colors; jj++)
         {
            if ((IGEcontext_info.win_mgr[jj].phys_slot == ii))
            {
               num_contiguous_slots = 0;
               num_used_slots++;
               slot_ok = FALSE;
            }
         }
         if (slot_ok)
         {
            for (jj = 0; jj < IGEcontext_info.num_ingr_res_colors; jj++)
            {
               if ((IGEcontext_info.ingr_res[jj].phys_slot == ii))
               {
                  num_contiguous_slots = 0;
                  num_used_slots++;
                  slot_ok = FALSE;
               }
            }
         }
         if (slot_ok)
         {
            if (IGEphys_vlt[ii].flags & VLT_SPECIAL_AREA_SLOT)
            {
               num_contiguous_slots = 0;
               slot_ok = FALSE;
            }
         }
   
         if (slot_ok)
         {
            num_contiguous_slots++;
            if (num_contiguous_slots > max_num_contiguous_slots)
            {
               start_slot = ii + 1 - num_contiguous_slots;
               max_num_contiguous_slots = num_contiguous_slots;
            }
         }
      }
      if (num_used_slots < 8)
      {
         max_num_contiguous_slots = max_num_contiguous_slots - (8 - num_used_slots);
      }
      min_ramp_size = MINIMUM(minimum_ramp_shades * IGEcontext_info.num_ramp_colors, 
         max_num_contiguous_slots - (max_num_contiguous_slots % minimum_ramp_shades));

      num_ramp_reserved = 0;
      /* reserve atleast minimum_ramp_shades * num_ramp_colors spots for ramp (minimum) */
      start_slot = start_slot + max_num_contiguous_slots - min_ramp_size;
      for ( ii = start_slot; ii < start_slot + min_ramp_size; ii++ )
      {
         num_ramp_reserved++;
         IGEphys_vlt[ii].flags = VLT_RAMP_SLOT;  
      }  /* end: for */
   }
   else
   {
      min_ramp_size = 0;
   }

   slots_left_over = num_color_slots - special_size - min_ramp_size;
 
   if (num_color_slots >= 8 + min_ramp_size)
   {
      if (slots_left_over < 8)
      {
#ifdef DEBUG_CL
         printf("IGEconfigure_table: special_size too big was %d now %d\n",
            special_size,num_color_slots - (8 + min_ramp_size));
#endif
         slots_left_over = 8 + min_ramp_size;
         special_size = num_color_slots - slots_left_over;
      }

      if (IGEcontext_info.user_cube_size != IGE_USER_CUBE_SIZE_DEFAULT)
      {
         if (slots_left_over < 8)
         {
#ifdef DEBUG_CL
            printf("IGEconfigure_table: special_size too big was %d now %d\n",
               special_size,num_color_slots - (8 + min_ramp_size));
#endif
            slots_left_over = 8 + min_ramp_size;
            special_size = num_color_slots - slots_left_over;
         }

         left_over_cube_dim = (IGRint)pow((IGRdouble)slots_left_over + 0.9,1.0/3.0);
         switch (IGEcontext_info.user_cube_size)
         {
            case IGE_USER_CUBE_SIZE_MAX: 
               IGEcontext_info.cube_size = MAXIMUM(2,left_over_cube_dim);
               break;
            case IGE_USER_CUBE_SIZE_MAX_MINUS_1:
               IGEcontext_info.cube_size = MAXIMUM(2,left_over_cube_dim - 1);
               break;
            case IGE_USER_CUBE_SIZE_MIN:
               IGEcontext_info.cube_size = 2;
               break;
            case IGE_USER_CUBE_SIZE_MIN_PLUS_1:
               IGEcontext_info.cube_size = MINIMUM(3,left_over_cube_dim);
               break;
         }
      }
      else
      {  
         if (cube_dimension != 0x7FFF)
         {
            if (slots_left_over < cube_dimension * cube_dimension * cube_dimension )
            {
#ifdef DEBUG_CL
               printf("IGEconfigure_table: special_size %d/cube_dimension %d too large\n",
                  special_size,cube_dimension);
#endif
               special_size = 0;
               slots_left_over = num_color_slots - min_ramp_size;
               IGEcontext_info.cube_size = 2;
            }
            else
            {
               IGEcontext_info.cube_size = cube_dimension;
            }
         }
         else
         {
            if (IGEcontext_info.using_ramp)
            {
               /* default for ramp is min + 1 or 3 (if possible) */
               left_over_cube_dim = (IGRint)pow((IGRdouble)slots_left_over+0.9,1.0/3.0);
               IGEcontext_info.cube_size = MINIMUM(3,left_over_cube_dim);
            }
            else
            {
               left_over_cube_dim = (IGRint)pow((IGRdouble)slots_left_over+0.9,1.0/3.0);
               IGEcontext_info.cube_size = MAXIMUM(2,MINIMUM(cube_dimension,left_over_cube_dim));
            }
         }

         if (slots_left_over<8)
         {
            slots_left_over = 8 + min_ramp_size;
#ifdef DEBUG_CL
            printf("IGEconfigure_table: special_size too big was %d now %d\n",
               special_size,total_slots - slots_left_over);
#endif
            special_size = num_color_slots - slots_left_over;
            IGEcontext_info.cube_size = left_over_cube_dim = 2;
         }
      }
   }
   else
   {
      /* 2 bits for colors or less case */
      IGEcontext_info.cube_size = 0;
      special_size = 0;
   }
   
   if (IGEcontext_info.cube_size)
   {
      sts = IGEload_cube( IGEcontext_info.cube_size, num_color_slots,
         gamma);
   }

   /* give priority to intergraph reserved colors to get color cube colors.
      The slots have already been assigned in cmap_init */

   if (IGEcontext_info.num_ingr_res_colors)
   {
      sts = IGEload_ingr_res( FALSE, tolerance_pct, 
         IGEcontext_info.num_ingr_res_colors, IGEcontext_info.ingr_res, 
         num_color_slots);
   }

   if (IGEcontext_info.num_win_mgr_colors)
   {
      sts = IGEload_window_manager( FALSE, tolerance_pct, 
         IGEcontext_info.num_win_mgr_colors, IGEcontext_info.win_mgr, 
         num_color_slots);
   }

   if (num_color_slots > 2)
   {
      if (IGEcontext_info.using_ramp)
      {
          IGEload_ramps( IGEcontext_info.num_bg_log_hl_colors, IGEbg_log_hl_colors,
            gamma, &IGEcontext_info);
      }

      /* load the logical colors to closest match accept for 2 color slots case */
      sts = IGEload_logical(tolerance_pct, gamma, IGEcontext_info.num_bg_log_hl_colors, 
         IGEcontext_info.bg_log_hl, IGEbg_log_hl_colors, num_color_slots);

      /* Build 9-bit rgb to vlt_index map */
      for ( ii = 0; ii < num_color_slots; ii++ )
      {
         if ( (IGEphys_vlt[ii].flags & VLT_COLOR_CUBE_SLOT) )
         {
            IGEcontext_info.rgb_table[IGEphys_vlt[ii].slot] = ii;
         }
   
         IGEphys_vlt[ii].slot = ii;
      }  /* end: for */
   }
   else
   {
      /* 2 bit plane case with highlight (back of EdgeII).  Map all of the logical colors
         to slot 1 and background to slot 0 */
      if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
      {
         IGEcompensate_array[0] = IGEbg_log_hl_colors[0].log_red;
         IGEcompensate_array[1] = IGEbg_log_hl_colors[0].log_green;
         IGEcompensate_array[2] = IGEbg_log_hl_colors[0].log_blue;
         /* 80% light gray .8*65535 = 52428*/
         IGEcompensate_array[3] = 0xCCCC;
         IGEcompensate_array[4] = 0xCCCC;
         IGEcompensate_array[5] = 0xCCCC;
         (*IGEgamma_compensate_ptr)( 2, IGEcompensate_array, gamma, 1);
         IGEphys_vlt[0].red = IGEcompensate_array[0];
         IGEphys_vlt[0].green = IGEcompensate_array[1];
         IGEphys_vlt[0].blue = IGEcompensate_array[2];
         IGEphys_vlt[1].red = IGEcompensate_array[3];
         IGEphys_vlt[1].green = IGEcompensate_array[4];
         IGEphys_vlt[1].blue = IGEcompensate_array[5];
      }
      else
      {
         IGEphys_vlt[0].red = IGEbg_log_hl_colors[0].log_red;
         IGEphys_vlt[0].green = IGEbg_log_hl_colors[0].log_green;
         IGEphys_vlt[0].blue = IGEbg_log_hl_colors[0].log_blue;
         /* 80% light gray .8*65535 = 52428 or .8*0xFFFF=0xCCCC*/
         IGEphys_vlt[1].red = 0xCCCC;
         IGEphys_vlt[1].green = 0xCCCC;
         IGEphys_vlt[1].blue = 0xCCCC;
      }
      IGEphys_vlt[0].flags = IGEphys_vlt[1].flags = VLT_EXACT_MATCH_SLOT;
   
      IGEcontext_info.bg_log_hl[0].phys_slot = 0;
      IGEcontext_info.bg_log_hl[0].phys_red = IGEphys_vlt[0].red;
      IGEcontext_info.bg_log_hl[0].phys_green = IGEphys_vlt[0].green;
      IGEcontext_info.bg_log_hl[0].phys_blue = IGEphys_vlt[0].blue;
      /* map all of the logical colors to slot 1 */
      for (ii = 1; ii < IGEcontext_info.num_bg_log_hl_colors; ii++)
      {
         IGEcontext_info.bg_log_hl[ii].phys_slot = 1;
         IGEcontext_info.bg_log_hl[ii].phys_red = IGEphys_vlt[1].red;
         IGEcontext_info.bg_log_hl[ii].phys_green = IGEphys_vlt[1].green;
         IGEcontext_info.bg_log_hl[ii].phys_blue = IGEphys_vlt[1].blue;
      }
   }

wrapup:   
   /* This saves the internal color data set here */
   sts = IGEsave_context( context_no, &IGEcontext_info);

   /* This loads the physical entries into the context of WL */
   WLload_cmap_entries( context_no, total_slots, IGEphys_vlt );
   
   /* save the new background mapping */
   WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
   WLset_background( WL_UNDEFINED_WINDOW, color_ref );

   return(sts);
}

IGRint IGEget_special_area_info(
   WLuint32   context_no,
   IGRint      *beginning_special_slot,
   IGRint      *num_special_area_slots)
{
/*
NAME
   IGEget_special_area_info
DESCRIPTION
   get the actual special area start slot and num_colors
PARAMETERS
   conetxt_no (in) - the context to get info from
   beginning_special_slot (out) - the physical slot where it starts
   num_special_area_slots (out) - number of special slots
RETURN VALUES
   0 success
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint i,j;
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);

   *beginning_special_slot = 0;
   *num_special_area_slots = 0;
   
   for (i = 0;i<(1<<context_info.table_depth);i++)
   {
      if (IGEphys_vlt[i].flags&VLT_SPECIAL_AREA_SLOT)
      {
         *beginning_special_slot = i;
         for (j = 0;i<(1<<context_info.table_depth);i++)
         {
            if (IGEphys_vlt[i].flags&VLT_SPECIAL_AREA_SLOT)
            {
               j++;
            }
            else
            {
               break;
            }
         }
         *num_special_area_slots = j;
         return(0);
      }
   }
   return(0);
}

IGRint IGEinq_cube_wmgr_ingr_sizes(
   WLuint32   context_no,
   IGRint      *cube_size,
   IGRint      *wmgr_size,
   IGRint      *ingr_size)
{
/*
NAME
   IGEinq_cube_wmgr_ingr_size
DESCRIPTION
   get the cube dimension window manager size and intergraph reserved
   colors size.
PARAMETERS
   context_no (in) - the context to inquire
   cube_size (out) - the cube dimension
   wmgr_size (out) - the number of window manager colors
   ingr_size (out) - the number of intergraph reserved colors
RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);

   if (cube_size)
   {
      *cube_size = context_info.cube_size;
   }
   if (wmgr_size)
   {
      *wmgr_size = context_info.num_win_mgr_colors;
   }
   if (ingr_size)
   {
      *ingr_size = context_info.num_ingr_res_colors;
   }
   return(0);
}

IGRint IGErgb_to_logical(
   WLuint32   context_no,
   IGRint      color,
   IGRint      *logical_index)
{
/*
NAME
   IGErgb_to_logical
DESCRIPTION
   This functions converts an rgb packed (using CLpack_colors) to 
   a logical color index
PARAMETERS
   context_no (in) - the context you want to use
   color (in) - the packed color
   logical_index (out)  =  the logical index that is closest to the rgb 
      value
RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRint temp, this_dist_sq, dist_sq;
   IGRint red,green,blue;
   IGRint ii;
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);

   /* shift to 8 bits so ints can be used in calculations */
   CLunpack_colors(color,&red,&green,&blue);
   red = red >> 8;
   green = green >> 8;
   blue = blue >> 8;

   dist_sq = MAXDISTSQ;
   for ( ii = 0; ii < context_info.num_bg_log_hl_colors; ii++ )
   {
      temp = (IGEbg_log_hl_colors[ii].log_red >> 8) - red;
      this_dist_sq = (temp * temp);
      temp = (IGEbg_log_hl_colors[ii].log_green >> 8) - green;
      this_dist_sq += (temp * temp);
      temp = (IGEbg_log_hl_colors[ii].log_blue >> 8) - blue;
      this_dist_sq += (temp * temp);
      if ( this_dist_sq < dist_sq )
      {
         dist_sq = this_dist_sq;
         /* must use ii instead of slot     */
         /* because slots are 9 bit numbers */
         /* during VLT building process     */
         *logical_index = ii;
         
         if ( dist_sq == 0 ) goto wrapup;
      }
   }  /* end: for */
wrapup:
   return(0);
}

void IGEcolor_debug()
{
/*
NAME
   IGEcolor_debug 
DESCRIPTION
   prints out the phys vlt currently loaded
PARAMETERS

RETURN VALUES
   none
GLOBALS USED
   IGEphys_vlt
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint i;
   
   printf("log\tred\tgrn\tblu\n");
   for (i = 0;i<512;i++)
   {
      printf("%d\t%d\t%d\t%d\n",
         i,IGEphys_vlt[i].red >> 8,
         IGEphys_vlt[i].green >> 8,
         IGEphys_vlt[i].blue >> 8);
   }
   printf("/* logical colors */\n{\n");
   for (i = 0; i < 260; i+=5)
   {
      printf("   %#lX, %#lX, %#lX, %#lX, %#lX, /* %d - %d */\n",
CLpack_colors(IGEbg_log_hl_colors[i].log_red, IGEbg_log_hl_colors[i].log_green, IGEbg_log_hl_colors[i].log_blue),
CLpack_colors(IGEbg_log_hl_colors[i+1].log_red, IGEbg_log_hl_colors[i+1].log_green, IGEbg_log_hl_colors[i+1].log_blue),
CLpack_colors(IGEbg_log_hl_colors[i+2].log_red, IGEbg_log_hl_colors[i+2].log_green, IGEbg_log_hl_colors[i+2].log_blue),
CLpack_colors(IGEbg_log_hl_colors[i+3].log_red, IGEbg_log_hl_colors[i+3].log_green, IGEbg_log_hl_colors[i+3].log_blue),
CLpack_colors(IGEbg_log_hl_colors[i+4].log_red, IGEbg_log_hl_colors[i+4].log_green, IGEbg_log_hl_colors[i+4].log_blue),
i,i+4);
   }
   printf("}\n");


}

IGRint   IGEcmap_color_to_index(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index)
/*
NAME
   IGEcmap_color_to_index
DESCRIPTION
   function provided for WL to call converting a color (given in a logical index
   or a r g b value) to a physical slot.  For rgb value don't return a slot that 
   is undefined, hilite or special area.  
PARAMETERS
   context_no (IN) - The context number
   index (IN) - The logical color index 0-number of logical colors - 1
   red (IN) - The red component 0-65535
   green (IN) - The green component 0-65535
   blue (IN) - The blue component 0-65535
   flag (IN) - indicates whether index or rgb should be used in the 
          conversion
   phy_index (OUT) - The physical index

RETURN VALUES
   0 = SUCCESS
   1 = warning index too large => mod by num colors
   1 = warning r g or b out of range
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   IGRint            sts = 0,max_index,max_rgb;
   struct IGEcontext_info      context_info;
   IGRboolean         within_tol;
   
   if( !(IGEload_context(context_no,&context_info)) ) return 1;

   max_index = context_info.num_bg_log_hl_colors-1;
   max_rgb = 0xFFFF;
   if ( flag & WL_COLOR_RGB )
   { /* WL_COLOR_RGB */ 
      if ( red>max_rgb ) 
      {
         red = max_rgb;
         sts = 1;
      }
      if ( green>max_rgb ) 
      {
         green = max_rgb;
         sts = 1;
      }
      if ( blue>max_rgb ) 
      {
         blue = max_rgb;
         sts = 1;
      }
      IGEcalc_best_match( (IGRushort) red, (IGRushort) green, (IGRushort) blue,
         &within_tol, 0.0, VLT_USED_SLOTS, VLT_EMPTY_SLOT|VLT_HILITE_SLOT|VLT_SPECIAL_AREA_SLOT,
         (1<<context_info.table_depth), (WLint32 *) phy_index);
   }
   else
   {
      /* IGE_LOGICAL_HILITE and IGE_LOGICAL_BACKGROUND are short defines */
      index = index & 0xFFFF;
      /* color index */
      if ( ( index == IGE_LOGICAL_HILITE ) )
      {
         index = max_index;
      }
      else
      {
         if ( ( index == IGE_LOGICAL_BACKGROUND ) )
         {
            index = 0;
         }
         else
         {         
            if ( index>max_index )
            {
               index = index%max_index;
               sts = 1; /* Warning index too large */
            }
         }
      }
      *phy_index = (WLuint32) context_info.bg_log_hl[index].phys_slot;
   }

   return(sts);
} /* IGEcmap_color_to_index */
   
IGRint   IGEcmap_color_to_rgb(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue)
/*
NAME
   IGEcmap_color_to_rgb
DESCRIPTION
   function provided for WL to call converting a color (given in a logical index
   or a r g b value) to a rgb.    

PARAMETERS
   context_no (IN) - The context number
   index (IN) - The logical color index 0-number of logical colors - 1
   red (IN) - The red component 0-65535
   green (IN) - The green component 0-65535
   blue (IN) - The blue component 0-65535
   flag (IN) - indicates whether index or rgb should be used in the 
          conversion
   out_red (OUT) - The converted red component 0-65535
   out_green (OUT) - The converted green component 0-65535
   out_blue (OUT) - The converted blue component 0-65535

RETURN VALUES
   0 = SUCCESS
   1 = warning index too large => mod by num colors
   1 = warning r g or b out of range
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   IGRint            sts = 0,max_index,max_rgb;
   struct IGEcontext_info      context_info;
   struct WLcontext_info WLcontext_info;
   IGRuint            tmp_red,tmp_green,tmp_blue;
   
   IGEload_context(context_no,&context_info);
   WLget_context_info( context_no, &WLcontext_info );

   max_index = context_info.num_bg_log_hl_colors-1;
   max_rgb = 0xFFFF;
   if ( flag & WL_COLOR_RGB )
   { /* WL_COLOR_RGB */
      if ( red>max_rgb ) 
      {
         red = max_rgb;
         sts = 1;
      }
      if ( green>max_rgb ) 
      {
         green = max_rgb;
         sts = 1;
      }
      if ( blue>max_rgb ) 
      {
         blue = max_rgb;
         sts = 1;
      }
      
      if (WLcontext_info.flags & WL_COLORMAP_READ_ONLY )
      {
         /* use the compensated value, because the table had not been changed
            to have loaded the compensated value.  Therefore a net of one
            compensation if on */
         tmp_red = (WLuint32) IGEphys_vlt[red >> 8].red;
         tmp_green = (WLuint32) IGEphys_vlt[green >> 8].green;
         tmp_blue = (WLuint32) IGEphys_vlt[blue >> 8].blue;    
      }
      else
      {
         /* We are going to return what they sent in.  When they use that value
            the look up will have the compensation if turned on.  */
         tmp_red = red;
         tmp_green = green;
         tmp_blue = blue;
      }
   }
   else
   {
      /* IGE_LOGICAL_HILITE and IGE_LOGICAL_BACKGROUND are short defines */
      index = index & 0xFFFF;
      if ( index == IGE_LOGICAL_HILITE ) 
      {
         index = max_index;
      }
      else
      {
         if ( ( index == IGE_LOGICAL_BACKGROUND ) )
         {
            index = 0;
         }
         else
         {         
            if ( index>max_index )
            {
               index = index%max_index;
               sts = 1; /* Warning index too large */
            }
         }
      }
      if (WLcontext_info.flags & WL_COLORMAP_READ_ONLY )
      {
         /* We are going to return logical value.  When they use that value
            the look up will have the compensation if turned on. */
         tmp_red = (WLuint32) context_info.bg_log_hl[index].phys_red;
         tmp_green = (WLuint32) context_info.bg_log_hl[index].phys_green;
         tmp_blue = (WLuint32) context_info.bg_log_hl[index].phys_blue; 
      }
      else
      {
         /* the changed physical vlt will have the compensation, when they
            use the uncompensated value in the table it will net 1 compensation */
         tmp_red = (WLuint32) IGEbg_log_hl_colors[index].log_red;
         tmp_green = (WLuint32) IGEbg_log_hl_colors[index].log_green;
         tmp_blue = (WLuint32) IGEbg_log_hl_colors[index].log_blue;
      }
   }
   *out_red = tmp_red;
   *out_green = tmp_green;
   *out_blue = tmp_blue;

   return(sts);
} /* IGEcmap_color_to_rgb */

IGRint   IGEcmap_init(WLuint32 context_no)
/*
NAME
   IGEcmap_init
DESCRIPTION
   this initializes the context and is called by WL.  If the context has an
   color object id associated with it it does a full configure otherwise it
   will just set up the wmgr, ingr res and hilite plane.

PARAMETERS
   context_no (IN) - The context number

RETURN VALUES
   0 = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   int i;
   int num_win_mgr,num_ingr_res,num_slots,num_color_slots,num_loaded_slots;
   struct IGEcolor_mapping *color_mapping;
   struct WLcmap_entry *WLwin_mgr = (struct WLcmap_entry *)NULL;
   struct WLcmap_entry *WLingr_res = (struct WLcmap_entry *)NULL;
   struct WLcontext_info WLcontext_info;
   struct IGEcontext_info IGEcontext_info;
   OM_S_OBJID  color_objid;
   IGRdouble gamma_correction[3];
   IGRdouble tolerance;
   IGRint hilite_color;
   void *colors = NULL;
   IGRshort num_colors;
   int (*cmap_color_to_index_ptr)( WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32 *);
   int (*cmap_color_to_rgb_ptr)( WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, WLuint32, 
      WLuint32 *, WLuint32 *, WLuint32 *);
   int (*cmap_init_ptr)( WLuint32 );
   struct WLcontext_info CMcontext_info;
   int shifter;

   color_objid = NULL_OBJID;

   CMget_context_info( context_no, &color_objid, &cmap_color_to_index_ptr, 
      &cmap_color_to_rgb_ptr, &cmap_init_ptr, &CMcontext_info );

   WLget_context_info(context_no,&WLcontext_info);
   if (WLcontext_info.base_cmap_type&WL_CMAP_TRUE_COLOR)
   {
      if ( color_objid != NULL_OBJID )
      {
         num_colors = 0;
         /* just get the number of colors */
         ige$read_color_table( num_colors = &num_colors, colors = colors, 
                              flags = PACKED_COLORS|IGE_READ_BACKGROUND|IGE_READ_HIGHLIGHT ); 
         IGEadd_context(context_no, 0, 0, num_colors);
      }
      else
      {
         IGEadd_context(context_no, 0, 0, DEFAULT_NUM_BG_LOG_HL);
      }
      IGEload_context(context_no, &IGEcontext_info);
      
      /* compute the number of slots with and without hilite plane */
      num_slots = 1 << IGEcontext_info.table_depth;
      num_color_slots = 1 << WLcontext_info.base_depth / 3;
      shifter = 8 + (8 - (WLcontext_info.base_depth / 3));

      if ( color_objid != NULL_OBJID )
      {
         ige$read_reserved_colors( hilite_color = &hilite_color, flags = PACKED_COLORS ); 
         ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma_correction ); 
         if (gamma_correction[0] != 1.0 || gamma_correction[1] != 1.0 || gamma_correction[2] != 1.0)
         {
            /* compensate the highlight color if compensation is on */
            CLunpack_colors( hilite_color, &IGEcompensate_array[0], &IGEcompensate_array[1], &IGEcompensate_array[2]);
            (*IGEgamma_compensate_ptr)( 1 /* num_colors */, IGEcompensate_array, gamma_correction, 1 /* compensate */);
            hilite_color = CLpack_colors( IGEcompensate_array[0], IGEcompensate_array[1], IGEcompensate_array[2]);
         }
      }
      else
      {
         /* white packed */
         hilite_color = 0x3FFFFFFF;
      }
      
      IGEinit_physical_vlt( IGEcontext_info.table_depth, WLcontext_info.hilite_used, 
         hilite_color);
      if ( color_objid != NULL_OBJID )
      {
         if (gamma_correction[0] != 1.0 || gamma_correction[1] != 1.0 || gamma_correction[2] != 1.0)
         {
            for (i = 0;i<num_color_slots;i++)
            {
               IGEcompensate_array[i*3] = IGEcompensate_array[(i*3)+1] = 
                  IGEcompensate_array[(i*3)+2] = i << shifter;
            }
            (*IGEgamma_compensate_ptr)( num_color_slots, IGEcompensate_array, gamma_correction, 1 );
         
            for (i = 0;i<num_color_slots;i++)
            {
               IGEphys_vlt[i].slot = i;
               IGEphys_vlt[i].red = IGEcompensate_array[i*3];
               IGEphys_vlt[i].green = IGEcompensate_array[(i*3)+1];
               IGEphys_vlt[i].blue = IGEcompensate_array[(i*3)+2];
               IGEphys_vlt[i].flags = 0;
            }
         }
         else
         {
            for (i = 0;i<num_color_slots;i++)
            {
               IGEphys_vlt[i].slot = i;
               IGEphys_vlt[i].red = IGEphys_vlt[i].green = IGEphys_vlt[i].blue = i << shifter;
               IGEphys_vlt[i].flags = 0;
            }
         }
      }
      else
      {
         for (i = 0;i<num_color_slots;i++)
         {
            IGEphys_vlt[i].slot = i;
            IGEphys_vlt[i].red = IGEphys_vlt[i].green = IGEphys_vlt[i].blue = i << shifter;
            IGEphys_vlt[i].flags = 0;
         }
      }
      /* about to load configured color table if color object is there */
      if ( color_objid == NULL_OBJID )
      {
         WLload_cmap_entries(context_no, num_slots, IGEphys_vlt );
      }
   }
   else
   {
      /* WL_CMAP_INDEXED */
      WLget_wm_colors(context_no,&num_win_mgr,&WLwin_mgr,&num_ingr_res,&WLingr_res);  
      if ( color_objid != NULL_OBJID )
      {
         num_colors = 0;
         /* just get the number of colors */
         ige$read_color_table( num_colors = &num_colors, colors = colors, 
                               flags = PACKED_COLORS|IGE_READ_BACKGROUND|IGE_READ_HIGHLIGHT ); 
         IGEadd_context(context_no, num_win_mgr, num_ingr_res, num_colors);
      }
      else
      {
         IGEadd_context(context_no, num_win_mgr, num_ingr_res, DEFAULT_NUM_BG_LOG_HL);
      }
      
      IGEload_context(context_no, &IGEcontext_info);
      num_slots = 1 << IGEcontext_info.table_depth;
      
      if ( color_objid != NULL_OBJID )
      {
         ige$read_reserved_colors( hilite_color = &hilite_color, flags = PACKED_COLORS ); 
         ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma_correction ); 
         if (gamma_correction[0] != 1.0 || gamma_correction[1] != 1.0 || gamma_correction[2] != 1.0)
         {
            /* compensate the highlight color if compensation is on */
            CLunpack_colors( hilite_color, &IGEcompensate_array[0], &IGEcompensate_array[1], &IGEcompensate_array[2]);
            (*IGEgamma_compensate_ptr)( 1 /* num_colors */, IGEcompensate_array, gamma_correction, 1 /* compensate */);
            hilite_color = CLpack_colors( IGEcompensate_array[0], IGEcompensate_array[1], IGEcompensate_array[2]);
         }
      }
      else
      {
         /* white packed */
         hilite_color = 0x3FFFFFFF;
      }
      
      IGEinit_physical_vlt( IGEcontext_info.table_depth, WLcontext_info.hilite_used, 
         hilite_color);

      for (i = 0;i<num_win_mgr;i++)
      {
         color_mapping = &(IGEcontexts_ptr[IGEcontext_index]->win_mgr[i]);
         color_mapping->phys_slot = WLwin_mgr[i].slot;
         color_mapping->phys_red = color_mapping->log_red = WLwin_mgr[i].red;
         color_mapping->phys_green = color_mapping->log_green = WLwin_mgr[i].green;
         color_mapping->phys_blue = color_mapping->log_blue = WLwin_mgr[i].blue;
      }
      
      for (i = 0;i<num_ingr_res;i++)
      {
         color_mapping  =  &(IGEcontexts_ptr[IGEcontext_index]->ingr_res[i]);
         color_mapping->phys_slot = WLingr_res[i].slot;
         color_mapping->phys_red = color_mapping->log_red = WLingr_res[i].red;
         color_mapping->phys_green = color_mapping->log_green = WLingr_res[i].green;
         color_mapping->phys_blue = color_mapping->log_blue = WLingr_res[i].blue;
      }

      if (WLwin_mgr)
      {
         free(WLwin_mgr);
      }
      if (WLingr_res)
      {
         free(WLingr_res);
      }

      if ( color_objid != NULL_OBJID )
      {
         ige$set_inq_colortable_parameters(inq0_set1 = 0, tolerance_pct = &tolerance ); 
      }
      else
      {
         tolerance = TOLERANCE;
      }
         
      IGEload_window_manager( TRUE, tolerance, num_win_mgr, IGEcontexts_ptr[IGEcontext_index]->win_mgr, 
         num_slots );
      IGEload_ingr_res( TRUE, tolerance, num_ingr_res, IGEcontexts_ptr[IGEcontext_index]->ingr_res, 
         num_slots );

      /* only load the slots which have been changed/added */
      for ( i = 0, num_loaded_slots = 0; i<num_slots; i++ )
      {
         if (!(IGEphys_vlt[i].flags&VLT_EMPTY_SLOT))
         {
            if (num_slots != i)
            {
               IGEphys_vlt[num_loaded_slots] = IGEphys_vlt[i];
            }
            num_loaded_slots++;
         }
      }

      /* about to load configured color table if color object is there */
      if ( color_objid == NULL_OBJID )
      {
         WLload_cmap_entries(context_no, num_loaded_slots, IGEphys_vlt );
      }
   }

   if ( color_objid != NULL_OBJID )
   {
      ige$configure_color_table( context_no = context_no ); 
   }
   return(0);
}

IGRint IGEadd_context(
   WLuint32 context_no,
   IGRint num_win_mgr,
   IGRint num_ingr_res,
   IGRint num_bg_log_hl)
{
/*
NAME
   IGEadd_context
DESCRIPTION
   this mallocs the arrays for the given context
PARAMETERS
   context_no (in) - the context to add
   num_win_mgr (in) - the number of window manager slots to malloc
   num_ingr_res (in) - the number of intergraph menu colors to malloc
   num_bg_log_hl (in) - the number of logical colors + bg and hl
RETURN VALUES
   1 = context already added
   0 = success
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint i;
   struct WLcontext_info WLcontext_info;

   WLget_context_info(context_no,&WLcontext_info);

   for (i = 0;i<num_contexts;i++)
   {
      if (IGEcontexts_ptr[i]->context_no == context_no)
      {
#ifdef DEBUG_CL
         printf("IGEadd_context: context %d already exists\n",context_no);
#endif
         /* check for changed number of colors */
         if (IGEcontexts_ptr[i]->num_win_mgr_colors != num_win_mgr)
         {
            if (IGEcontexts_ptr[i]->win_mgr)
            {
               free(IGEcontexts_ptr[i]->win_mgr);
            }
            IGEcontexts_ptr[i]->num_win_mgr_colors = num_win_mgr;
            if (num_win_mgr) 
            {
               IGEcontexts_ptr[i]->win_mgr = (struct IGEcolor_mapping *) 
                  malloc(sizeof(struct IGEcolor_mapping)*num_win_mgr);
            }
         }
            
         if (IGEcontexts_ptr[i]->num_ingr_res_colors != num_ingr_res)
         {
            if (IGEcontexts_ptr[i]->ingr_res)
            {
               free(IGEcontexts_ptr[i]->ingr_res);
            }
            IGEcontexts_ptr[i]->num_ingr_res_colors = num_ingr_res;
            if (num_ingr_res) 
            {
               IGEcontexts_ptr[i]->ingr_res = (struct IGEcolor_mapping *) 
                  malloc(sizeof(struct IGEcolor_mapping)*num_ingr_res);
            }
         }

         if (IGEcontexts_ptr[i]->num_bg_log_hl_colors != num_bg_log_hl)
         {
            if (IGEcontexts_ptr[i]->bg_log_hl)
            {
               free(IGEcontexts_ptr[i]->bg_log_hl);
            }
            IGEcontexts_ptr[i]->num_bg_log_hl_colors = num_bg_log_hl;
            if (num_bg_log_hl) 
            {
               IGEcontexts_ptr[i]->bg_log_hl = (struct IGEphys_color_mapping *) 
                  malloc(sizeof(struct IGEphys_color_mapping)*num_bg_log_hl);
            }
         }
         return(1);
      }
   }
   
#ifdef DEBUG_CL
   printf("IGEadd_context: adding IGEcontext_ptr[%d] context %d\n",num_contexts,context_no);
#endif
   IGEcontexts_ptr[num_contexts] = (struct IGEcontext_info *) malloc(sizeof(struct IGEcontext_info));
   IGEcontexts_ptr[num_contexts]->context_no = context_no;

   if (WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR)
   {
      IGEcontexts_ptr[num_contexts]->table_depth = WLcontext_info.base_depth / 3;
   }
   else
   {
      IGEcontexts_ptr[num_contexts]->table_depth = WLcontext_info.base_depth;
   }

   if (WLcontext_info.hilite_used == WL_HILITE_USED) 
   {
      IGEcontexts_ptr[num_contexts]->table_depth++;
   }
   
   IGEcontexts_ptr[num_contexts]->num_win_mgr_colors = num_win_mgr;
   if (num_win_mgr) 
   {
      IGEcontexts_ptr[num_contexts]->win_mgr = (struct IGEcolor_mapping *) 
         malloc(sizeof(struct IGEcolor_mapping)*num_win_mgr);
   }
   else
   {
      IGEcontexts_ptr[num_contexts]->win_mgr = NULL;
   } 

   IGEcontexts_ptr[num_contexts]->num_ingr_res_colors = num_ingr_res;
   if (num_ingr_res) 
   {
      IGEcontexts_ptr[num_contexts]->ingr_res = (struct IGEcolor_mapping *) 
         malloc(sizeof(struct IGEcolor_mapping)*num_ingr_res);
   }
   else
   {
      IGEcontexts_ptr[num_contexts]->ingr_res = NULL;
   } 

   IGEcontexts_ptr[num_contexts]->num_bg_log_hl_colors = num_bg_log_hl;
   if (num_bg_log_hl) 
   {
      IGEcontexts_ptr[num_contexts]->bg_log_hl = (struct IGEphys_color_mapping *) 
         malloc(sizeof(struct IGEphys_color_mapping)*num_bg_log_hl);
   }
   else
   {
      IGEcontexts_ptr[num_contexts]->bg_log_hl = NULL;
   } 

   IGEcontexts_ptr[num_contexts]->rgb_table = (IGRshort *) malloc(sizeof(IGRshort)*512);   
   IGEcontexts_ptr[num_contexts]->cube_size = 0;
   IGEcontexts_ptr[num_contexts]->user_cube_size = IGE_USER_CUBE_SIZE_DEFAULT;
   IGEcontexts_ptr[num_contexts]->num_ramp_colors = 10;
   IGEcontexts_ptr[num_contexts]->num_ramp_shades = minimum_ramp_shades;
   IGEcontexts_ptr[num_contexts]->using_ramp = IGEget_using_ramp_mode();
   IGEcontexts_ptr[num_contexts]->user_ramp_start_slot = -1;
   num_contexts++;
   
   return(0);
}

IGRint IGEdelete_context(WLuint32 context_no)
{
/*
NAME
   IGEdelete_context
DESCRIPTION
   deleting the context arrays and information
PARAMETERS
   context_no (in) - the context to delete
RETURN VALUES
   0 = success
   1 = context not there to delete
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
 
   IGRint i, sts = 0;
   struct IGEcontext_info      context_info;
   
   sts = IGEload_context(context_no,&context_info);
#ifdef DEBUG_CL
   printf("IGEdelete_context: context %d\n",context_no);
#endif
   if (sts)
   {
      if (context_info.win_mgr)
      {
         free(context_info.win_mgr);
      }
      if (context_info.ingr_res)
      {
         free(context_info.ingr_res);
      }
      if (context_info.bg_log_hl)
      {
         free(context_info.bg_log_hl);
      }
      if (context_info.rgb_table)
      {
         free(context_info.rgb_table);
      }
      if (IGEcontexts_ptr[IGEcontext_index])
      {
         free(IGEcontexts_ptr[IGEcontext_index]);
      }
   
      for (i = IGEcontext_index+1;i<num_contexts;i++)
      { /* move remaining contexts up one */
         IGEcontexts_ptr[i-1] = IGEcontexts_ptr[i];
      }
      num_contexts--;
   }   
   /* this assures that we will load the data since this one is being deleted */
   IGEcontext_index = -1;

   return(sts);
}

IGRint    ( *IGEset_gamma_compensate_ptr   ( 
                  IGRint (*func)( IGRint, IGRushort *, IGRdouble *, IGRboolean ) 
               ) 
   ) ( IGRint, IGRushort *, IGRdouble *, IGRboolean )
{
/*
NAME
   IGEset_gamma_compensate_ptr
DESCRIPTION
   this function sets the function pointer of the function used to compensate 
   and uncompensate an array of color values
PARAMETERS
   func (in) - the new compensate function
RETURN VALUES
   the old gamma compensate function
GLOBALS USED
   IGEgamma_compensate_ptr
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
    int (*temp_func)( IGRint, IGRushort *, IGRdouble *, IGRboolean );

    temp_func = IGEgamma_compensate_ptr;
    IGEgamma_compensate_ptr = func;

    return(temp_func);
}

IGRint    ( *IGEget_gamma_compensate_ptr   ( ) 
   ) ( IGRint, IGRushort *, IGRdouble *, IGRboolean )
{
/*
NAME
   IGEget_gamma_compensate_ptr
DESCRIPTION
   this function sets the function pointer of the function used to compensate 
   and uncompensate an array of color values
PARAMETERS
   
RETURN VALUES
   the current gamma compensate function
GLOBALS USED
   IGEgamma_compensate_ptr
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
    return( IGEgamma_compensate_ptr );
}

IGRboolean IGEset_ramp_mode_getenv( void )
{
/*
NAME
   IGEset_ramp_mode_getenv
DESCRIPTION
   This is called when coming up (set_path.C) for us to read RAMP environment
   value and if defined set the appropriate.

PARAMETERS
   void
   
RETURN VALUES
   the current using ramp mode

GLOBALS USED
   static IGEusing_ramp

HISTORY
   8/27/93   Joel D. Underwood
      This sets the mode up for ramps or color cube
*/
   /* reads environment value RAMP to set up using ramp (1) or not (0) */
   char *RAMP;
   int ramp_value;
#if defined ( ENV5 )
   struct scr_info vs_info[MAX_SCREENS];
   int             i;
#endif

   RAMP = getenv("RAMP");
   if (RAMP)
   {
      sscanf(RAMP,"%d",&ramp_value);
      if (ramp_value)
      {
         IGEset_using_ramp_mode( TRUE );
      }
      else
      {
         IGEset_using_ramp_mode( FALSE );
      }
   }
#if defined ( ENV5 )
   else
   {
      Inq_screen_info( vs_info );
   
      for( i = 0; i < MAX_SCREENS; i++ )
      {
         if ((vs_info[i].vsi_flags & VSI_VIRTUAL_SCREEN) && (vs_info[i].vsi_flags & VSI_DB_ABILITY) &&
            (vs_info[i].vsi_VLT_size == 512) && (vs_info[i].vsi_flags & VSI_32_ZB_ABILITY) &&
            !(vs_info[i].vsi_flags & VSI_24_ZB_ABILITY) )
         {
            /* The default for 3*60 and 3*40 machines will be ramp */
            IGEset_using_ramp_mode( TRUE );
         }
      }
   }
#endif

   return ( IGEusing_ramp );
}


IGRboolean IGEset_using_ramp_mode( IGRboolean using_ramp )
{
/*
NAME
   IGEset_using_ramp_mode

DESCRIPTION
   This is called to set the using ramp mode.

PARAMETERS
   using_ramp (IN) - True if using ramp False if using PTC
   
RETURN VALUES
   the old using ramp mode

GLOBALS USED
   static IGEusing_ramp

HISTORY
   8/27/93   Joel D. Underwood
      This sets the mode up for ramps or color cube
*/
   IGRboolean old_using_ramp;

   old_using_ramp = IGEusing_ramp;
   IGEusing_ramp = using_ramp;
   return( old_using_ramp );
}

IGRboolean IGEget_using_ramp_mode( void )
{
/*
NAME
   IGEget_using_ramp_mode

DESCRIPTION
   This is called to get the using ramp mode, and will be the interface for
   others to find out the mode.

PARAMETERS
   void
   
RETURN VALUES
   True if using ramp False if using PTC

GLOBALS USED
   static IGEusing_ramp

HISTORY
   8/27/93   Joel D. Underwood
      This sets the mode up for ramps or color cube
*/
   return( IGEusing_ramp );
}

IGRint IGEget_ambient_light( IGRushort *red, IGRushort *green, IGRushort *blue)
{
/*
NAME
   IGEget_ambient_light

DESCRIPTION
   This is called to get the ambient light value.  It defaults to
   black, but when hsurf comes up it will set to ambient light and 
   reconfigure the color tables.

PARAMETERS
   red (OUT) - value of red component (0 - 255)
   green (OUT) - value of green component (0 - 255)
   blue (OUT) - value of blue component (0 - 255)
   
RETURN VALUES
   0 success

GLOBALS USED
   static Ambient_light

HISTORY
   8/27/93   Joel D. Underwood
      This gets the Ambient Light
*/
   *red = Ambient_Light[0];
   *green = Ambient_Light[1];
   *blue = Ambient_Light[2];
   return( 0 );
}

IGRint IGEset_ambient_light( IGRushort red, IGRushort green, IGRushort blue)
{
/*
NAME
   IGEset_ambient_light

DESCRIPTION
   This is called to set the ambient light value.  It defaults to
   black, but when hsurf comes up it will set to ambient light and 
   reconfigure the color tables.

PARAMETERS
   red (IN) - value of red component (0 - 255)
   green (IN) - value of green component (0 - 255)
   blue (IN) - value of blue component (0 - 255)
   
RETURN VALUES
   0 success

GLOBALS USED
   static Ambient_light

HISTORY
   8/27/93   Joel D. Underwood
      This sets the Ambient Light
*/
   Ambient_Light[0] = red;
   Ambient_Light[1] = green;
   Ambient_Light[2] = blue;
   return( 0 );
}

IGRint IGEset_min_ramp_shades( int min_ramp_shades )
{
/*
NAME
   IGEset_min_ramp_shades

DESCRIPTION
   This is called to set the minimum number of ramp shades.  It defaults to
   one, but when hsurf comes up it will set to 2 for shading.

PARAMETERS
   min_ramp_shades (IN) - the minimum shades per ramp
   
RETURN VALUES
   0 success

GLOBALS USED
   static minimum_ramp_shades

HISTORY
   8/27/93   Joel D. Underwood
      This sets the minimum ramp shades
*/
   minimum_ramp_shades = min_ramp_shades;
   return( 0 );
}

IGRint IGEload_ramp(
   IGRint          start_slot,
   IGRushort       red,
   IGRushort       green,
   IGRushort       blue,
   IGRdouble      *gamma,
   struct IGEcontext_info *IGEcontext_info
 )
{
/*
NAME
   IGEload_ramp

DESCRIPTION
   This is called to load 1 ramp into physical table  (used by the
   create color table command when changing 1-num_ramp_colors color)

PARAMETERS
   start_slot (IN) - physical slot ramp starts
   red (IN) - value of red component (0 - 65535)
   green (IN) - value of green component (0 - 65535)
   blue (IN) - value of blue component (0 - 65535)
   gamma (IN) - gamma value for red green and blue component
   IGEcontext_info (IN) - context info

RETURN VALUES
   0 success

GLOBALS USED
   IGEphys_vlt
   static Ambient_light

HISTORY
   8/27/93   Joel D. Underwood
      Changes for ramp
*/
   int i;
   int ramp_shade, num_ramp_slots, slot;
   double  num_shd_minus_1,    /* num_shades - 1 */
           base_r, base_g, base_b,    /* base color intensities */
           range_r, range_g, range_b,    /* range of color intensities */
           step_r, step_g, step_b,    /* color intensity steps */
           rval, gval, bval,    /* color intensity values */
           amb_intens;    /* averaged ambient light color intensities */

   i = 0;
   num_shd_minus_1 = (double)(IGEcontext_info->num_ramp_shades - 1);
   num_ramp_slots = IGEcontext_info->num_ramp_shades;

   /* use an ambient intensity that is an average so we don't change the base color */
   amb_intens = (double) (Ambient_Light[0] + Ambient_Light[1] + Ambient_Light[2]) / 765.0/*(3.0 * 255.0)*/;
   rval = base_r = ((double)(red)) / 65535.0;    /* get    */
   gval = base_g = ((double)(green)) / 65535.0;  /*  base  */
   bval = base_b = ((double)(blue)) / 65535.0;   /*  color */

   range_r = base_r - (amb_intens * base_r);    /* calculate range of   */
   range_g = base_g - (amb_intens * base_g);    /*   brightest shade to */
   range_b = base_b - (amb_intens * base_b);    /*   darkest shade      */

   step_r = range_r / num_shd_minus_1;    /* calculate step */
   step_g = range_g / num_shd_minus_1;
   step_b = range_b / num_shd_minus_1;

   for (ramp_shade = num_shd_minus_1; ramp_shade >= 0; ramp_shade--, i++)
   {
      /* fill in all of the values of all shades */
      IGEcompensate_array[(i * 3)] = (IGRushort) ((rval * 65535.0) + 0.5);
      IGEcompensate_array[(i * 3) + 1] = (IGRushort) ((gval * 65535.0) + 0.5);
      IGEcompensate_array[(i * 3) + 2] = (IGRushort) ((bval * 65535.0) + 0.5);

      rval = rval - step_r;    /* calculate next shade */
      gval = gval - step_g;
      bval = bval - step_b;
   }

   if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
   {
      /* if gamma compensation on -> compensate */
      (*IGEgamma_compensate_ptr)( num_ramp_slots, IGEcompensate_array, gamma, 1);
   }

   slot = start_slot;
   /* first slot is base color */
   for ( i = 0; i < num_ramp_slots; i++, slot++ )
   {
      IGEphys_vlt[slot].flags = VLT_RAMP_SLOT;
      IGEphys_vlt[slot].red = IGEcompensate_array[(i*3)];
      IGEphys_vlt[slot].green = IGEcompensate_array[(i*3)+1];
      IGEphys_vlt[slot].blue = IGEcompensate_array[(i*3)+2];
   }
   IGEphys_vlt[start_slot].flags |= VLT_RAMP_BASE_COLOR_SLOT;

   /* this actualy loads it into the physical table */
   WLload_cmap_entries(IGEcontext_info->context_no, num_ramp_slots, &IGEphys_vlt[start_slot] );

   return(0);
}


IGRint IGEload_ramps( 
   IGRint          num_bg_log_hl_colors,
   struct IGElogical_color *bg_log_hl_colors,
   IGRdouble      *gamma,
   struct IGEcontext_info *IGEcontext_info
 )
{
/*
NAME
   IGEload_ramps

DESCRIPTION
   This is called to load the ramps into physical table (during the configure
   table process)

PARAMETERS
   num_bg_log_hl_colors (IN) - num colors
   bg_log_hl_colors (IN) - what the logical values are for the colors
   gamma (IN) - gamma value for red green and blue component
   IGEcontext_info (IN) - context info

RETURN VALUES
   0 success

GLOBALS USED
   IGEphys_vlt
   static Ambient_light

HISTORY
   8/27/93   Joel D. Underwood
      Changes for ramp
*/
   int i, j;
   int num_contiguous_slots, max_num_contiguous_slots;
   int start_slot, end_slot, slot;
   int start_empty_slot, num_empty_slots, num_valid_entries;
   IGRint available_slot;
   int num_phys_slots;
   int ramp_shade, ramp_color, num_ramp_slots;
   double  num_shd_minus_1,    /* num_shades - 1 */
           base_r, base_g, base_b,    /* base color intensities */
           range_r, range_g, range_b,    /* range of color intensities */
           step_r, step_g, step_b,    /* color intensity steps */
           rval, gval, bval,    /* color intensity values */
           amb_intens;    /* averaged ambient light color intensities */
   IGRboolean switched;
   IGRint status;
   IGRlong msg;
   OMuint count = 0;
   OM_S_CHANSELECT   chandef;
   GRobjid      modid;
   GRobjid      clr_id, app_id;
   GRspacenum   modos, app_osnum;
   IGRint *test_userramp = NULL;
   IGRint num_userramp_colors = 0,which_userramp = 0;

   end_slot = -1;
   num_phys_slots = 1 << IGEcontext_info->table_depth;

   /* move all of the cube slots torward beginning of table (to make the most space)*/
   for (i = num_phys_slots - 1; i >= 0; i--)
   {
      if ((IGEphys_vlt[i].flags & VLT_COLOR_CUBE_SLOT) &&
         !(IGEphys_vlt[i].flags & ( VLT_CANNOT_SWAP_SLOT | VLT_WIN_MGR_SLOT | 
         VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT )))
      {
         if (IGEslot_available( VLT_EMPTY_SLOT, &available_slot, num_phys_slots))
         {
            if (available_slot < i)
            {
               IGEphys_vlt[available_slot] = IGEphys_vlt[i];
               IGEphys_vlt[i].flags = VLT_EMPTY_SLOT;
            }
         }
      }
   }

   max_num_contiguous_slots = num_contiguous_slots = 0;
   /* find the amount of contiguous slots we have for all ramps */
   for (i = 0; i < num_phys_slots; i++)
   {
      if (IGEphys_vlt[i].flags & (VLT_HILITE_SLOT | VLT_CANNOT_SWAP_SLOT | 
         VLT_WIN_MGR_SLOT | VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT | VLT_COLOR_CUBE_SLOT))
      {
         num_contiguous_slots = 0;
      }
      else
      {
         /* count the reserved ramp slots */
         num_contiguous_slots++;
         if (num_contiguous_slots > max_num_contiguous_slots)
         {
            max_num_contiguous_slots = num_contiguous_slots;
            end_slot = i;
         }
      }
   }

   msg = om$make_chanselect(channame = "IGEcolor2.to_IGEuserramp", p_chanselect = &chandef);
   if (IGEget_color_id(&clr_id))
   {
   
      ex$get_cur_mod( id = &modid, osnum = &modos);
      msg = om$get_channel_count(osnum = modos,objid = clr_id, p_chanselect = &chandef, count = (OMuint *)&count);
   
      if (count)
      {
         /* get the application object id and osnum */
         status = om$get_objid_at_index( osnum		= modos,
                                         objid		= clr_id,
                                         p_chanselect	= &chandef,
                                         index		= count - 1,
                                         objidaddr	= &app_id,
                                         osnumaddr	= &app_osnum );
   
         /* get parameters from object */
         msg = om$send( msg = message IGEuserramp.get_sim_user_ramp( &which_userramp, &num_userramp_colors,
                                       &test_userramp ), 
                        senderid = clr_id,
                        targetid = app_id,
                        targetos = app_osnum );
   
         /* get_sim_user_ramp will return an error when the object has not woken up yet, */
         /* but after it has woken up, it will reconfigure the table                     */
         if (msg & 1)
         {
            /* enough room for 1 color minimum_ramp_shades shades and the userramp */
            if (max_num_contiguous_slots - minimum_ramp_shades >= num_userramp_colors)
            {
               for (i = 0; i < num_userramp_colors; i ++ )
               {
                  CLunpack_colors(test_userramp[i], &IGEcompensate_array[(i * 3)], 
                     &IGEcompensate_array[(i * 3) + 1], &IGEcompensate_array[(i * 3) + 2]);
               }
            
               if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
               {
                  /* compensate if compensation is on */
                  (*IGEgamma_compensate_ptr)( num_userramp_colors, IGEcompensate_array, gamma, 1);
               }
      
               max_num_contiguous_slots -= num_userramp_colors;
               end_slot -= num_userramp_colors;
               slot = end_slot + 1;
               IGEcontext_info->user_ramp_start_slot = slot;
               for (i = 0; i < num_userramp_colors; i ++, slot++ )
               {
                  IGEphys_vlt[slot].red = IGEcompensate_array[(i * 3)];
                  IGEphys_vlt[slot].green = IGEcompensate_array[(i * 3) + 1];
                  IGEphys_vlt[slot].blue = IGEcompensate_array[(i * 3) + 2];
                  IGEphys_vlt[slot].flags = VLT_USER_RAMP_SLOT | VLT_RAMP_SLOT;
               }
            }
      
            if (test_userramp)
            {
               free(test_userramp);
            }
         }
      }
   }
   /* num_ramp_colors = the number requested (cct subform) or limits of space w/minimum_ramp_shades shades */
   IGEcontext_info->num_ramp_colors = MAXIMUM( 1, IGEcontext_info->num_ramp_colors ); 
   IGEcontext_info->num_ramp_colors = MINIMUM( num_bg_log_hl_colors,
      MINIMUM( IGEcontext_info->num_ramp_colors,  max_num_contiguous_slots / minimum_ramp_shades ));
   /* num shades is just size in slots divided by the colors */
   IGEcontext_info->num_ramp_shades = max_num_contiguous_slots / IGEcontext_info->num_ramp_colors;
   num_ramp_slots = IGEcontext_info->num_ramp_colors * IGEcontext_info->num_ramp_shades;

   i = 0;
   num_shd_minus_1 = (double)(IGEcontext_info->num_ramp_shades - 1);

   /* use an ambient intensity that is an average so we don't change the base color */
   amb_intens = (double) (Ambient_Light[0] + Ambient_Light[1] + Ambient_Light[2]) / 765.0/*(3.0 * 255.0)*/;

   for (ramp_color = 1; ramp_color <= IGEcontext_info->num_ramp_colors; ramp_color++)
   {
      /* for every ramp color compute */
      rval = base_r = ((double)(bg_log_hl_colors[ramp_color].log_red)) / 65535.0;    /* get    */
      gval = base_g = ((double)(bg_log_hl_colors[ramp_color].log_green)) / 65535.0;  /*  base  */
      bval = base_b = ((double)(bg_log_hl_colors[ramp_color].log_blue)) / 65535.0;   /*  color */

      range_r = base_r - (amb_intens * base_r);    /* calculate range of   */
      range_g = base_g - (amb_intens * base_g);    /*   brightest shade to */
      range_b = base_b - (amb_intens * base_b);    /*   darkest shade      */

      step_r = range_r / num_shd_minus_1;    /* calculate step */
      step_g = range_g / num_shd_minus_1;
      step_b = range_b / num_shd_minus_1;

      for (ramp_shade = num_shd_minus_1; ramp_shade >= 0; ramp_shade--, i++)
      {
         /* for every shade and base load into the array */
         IGEcompensate_array[(i * 3)] = (IGRushort) ((rval * 65535.0) + 0.5);
         IGEcompensate_array[(i * 3) + 1] = (IGRushort) ((gval * 65535.0) + 0.5);
         IGEcompensate_array[(i * 3) + 2] = (IGRushort) ((bval * 65535.0) + 0.5);

         rval = rval - step_r;    /* calculate next shade */
         gval = gval - step_g;
         bval = bval - step_b;
      }
   }

   if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
   {
      /* compensate if compensation is on */
      (*IGEgamma_compensate_ptr)( num_ramp_slots, IGEcompensate_array, gamma, 1);
   }

   start_slot = slot = end_slot - num_ramp_slots + 1;
   for ( i = 0; i < num_ramp_slots; i++, slot++ )
   {
      /* load into phys_vlt structure */
      IGEphys_vlt[slot].flags = VLT_RAMP_SLOT;
      if ((slot - start_slot) % IGEcontext_info->num_ramp_shades == 0)
      {
         /* extra flag for base color */
         IGEphys_vlt[slot].flags |= VLT_RAMP_BASE_COLOR_SLOT;
      }
      IGEphys_vlt[slot].red = IGEcompensate_array[(i*3)];
      IGEphys_vlt[slot].green = IGEcompensate_array[(i*3)+1];
      IGEphys_vlt[slot].blue = IGEcompensate_array[(i*3)+2];
   }

   /* move all of the cube slots back right before beginning of ramps  */
   /* to have empty slots at beginning and load in colors from default */
   /* table, but to us it is still empty.                              */
   start_empty_slot = num_empty_slots = 0;
   for (i = start_slot - 1; i >= 0; i--)
   {
      if (IGEphys_vlt[i].flags & VLT_EMPTY_SLOT)
      {
         switched = FALSE;
         start_empty_slot = i;
         for (j = 0; (j < i) && !switched; j++)
         {
            if ((IGEphys_vlt[j].flags & VLT_COLOR_CUBE_SLOT) &&
               !(IGEphys_vlt[j].flags & ( VLT_CANNOT_SWAP_SLOT | VLT_WIN_MGR_SLOT | 
               VLT_INGR_RES_SLOT | VLT_SPECIAL_AREA_SLOT )))
            {
               /* found a cube slot that can be switched... swap with empty slot */
               IGEphys_vlt[i] = IGEphys_vlt[j];
               IGEphys_vlt[j].flags = VLT_EMPTY_SLOT;
               switched = TRUE;
            }
         }
         if (!switched)
         {
            num_empty_slots++;
         }
      }
   }

   start_empty_slot = num_empty_slots = 0;
   for (i = 0; i < num_phys_slots; i++ )
   {
      if (IGEphys_vlt[i].flags == VLT_EMPTY_SLOT)
      {
         start_empty_slot = i;
         while ((i < num_phys_slots) && (IGEphys_vlt[i].flags == VLT_EMPTY_SLOT))
         {
            num_empty_slots++;
            i++;
         }
         WLget_default_colormap_entries( IGEcontext_info->context_no,
            start_empty_slot, num_empty_slots, &num_valid_entries, 
            &(IGEphys_vlt[start_empty_slot]));
#ifdef DEBUG_CL
         printf("Thorough Default Colormap context_no = %#X start_empty_slot %d num_empty_slots %d\n", 
            IGEcontext_info->context_no, start_empty_slot, num_empty_slots);
#endif
         num_empty_slots = 0;   
      }
   }
   return(0);
}

end implementation Root;

