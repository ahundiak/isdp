/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:51 $
$Locker:  $
*/

class implementation IGEcolor2;

#ifndef BASE_EMS
#include <string.h>
#include "OMmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "execmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "cm.h"
#include "exmacros.h"

method sleep(IGRint type_sleep)
{
/*
NAME
   IGEcolor2.sleep
DESCRIPTION
   This is called when IGEcolor2 is going to sleep.  It will change
   the objid == my_id to NULL_OBJID and delete IGEcolor2 internal 
   arrays.
PARAMETERS
   type_sleep (in) - the type of sleep being done
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   sts = 1;
   int num_contexts, i;
   struct CMctx_mgr *cm_contexts;
   
   if (! ex$is_invis(mod_osnum = OM_Gw_current_OS) && (type_sleep == EX_REAL_SLEEP))
   {
      if ( ex$is_interactive() )
      {
         CMget_contexts( &cm_contexts, &num_contexts );
         for (i = 0; i < num_contexts; i++)
         {
            /* for all contexts with my_id give them back */
            if (cm_contexts[i].color_objid == my_id)
            {
               CMchange_context_info(cm_contexts[i].context_no, NULL_OBJID,
                  (int (*)()) NULL,(int (*)()) NULL,(int (*)()) NULL);
               IGEdelete_context(cm_contexts[i].context_no);
            }
         }
         if (cm_contexts)
         {
            free( cm_contexts );
         }
      }
   }
   IGEset_color_id(0);
   return(sts);
}

method change_clr_tbl( IGRshort start_color; IGRshort num_colors;
         void *bg_log_hl_colors; IGRint flags)
{

/* 
NAME
   IGEcolor2.change_clr_tbl
DESCRIPTION
   This function is for changing the logical color table for bg 
   logcial colors and hilight.  the order is bg logical colors hl.
   This method is called with macros: ige$change_color_table
   and ige$modify_color_table.
      The first entry in bg_log_hl_colors will always be used 
      to change the color table.  The parameter start_color is the 
      slot to change in the instance data's array.
      if (flags&IGE_CHANGE_HIGHLIGHT)
         The last index (hilight) of instance data will be 
         changed IF start_color+num_colors ends up at hilite
         spot or higher
      else
         The last index will be the same value (and moved to the 
         last index if the color table is enlarged  The first
         value of array passed in will go into initial hl spot in
         this case i.e. hl is always in last spot)
      if (flags&IGE_CHANGE_BACKGROUND)
         IF start_color is 0 which is where 
         the background index is in instance data.
      else
         start_color will be forced to 1 if <1 so that bg
         is not changed.
   If the macro is ige$change_reserved colors, it will be called with number
   of colors equal to 1 and the start slot will be set correctly.

PARAMETERS
   start_color (IN) - the first color to change
   num_colors (IN) - the number of colors to change
   bg_log_hl_colors (IN) - the new values of the colors
   flags (IN) - flags that determine characteristics
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   
   IGRint          sts = TRUE;
   IGRint          i,upper_slot,lower_slot,highlight_slot;
   struct IGEvlt   *unpacked_colors = NULL;
   IGRint          *packed_colors = NULL;
   WLcolorref   color_ref;
   
   if (flags & PACKED_COLORS)
   {
      packed_colors = (IGRint *)bg_log_hl_colors;
   }
   else
   {
      unpacked_colors = (struct IGEvlt *)bg_log_hl_colors;
   }

   lower_slot=1;
   upper_slot=ME.IGEcolor2->num_bg_log_hl_colors-2;
   if ( flags&IGE_CHANGE_BACKGROUND )
   {
      if ( num_colors==1 )
      {
         /* if it is the only color changing make start_color correct */
         start_color=0;
      }
#ifdef DEBUG_CL
      if ( start_color!=0 )
      {
         printf("IGEcolor2.change_clr_tbl: start_color %d even though change bg\n",start_color);
      }
#endif
      lower_slot=0;
   }
   
   if ( start_color<lower_slot )
   {
      /* don't change bg unless flag is set.  if start color<0 set to 0 */
#ifdef DEBUG_CL
      printf("IGEcolor2.change_clr_tbl: start_color(%d) forcing to %d\n",start_color,lower_slot);
#endif
      start_color=lower_slot;
   }
   
   if ( flags&IGE_CHANGE_HIGHLIGHT )
   {
      if ( num_colors==1 )
      {
         /* if it is the only color changing make start_color correct */
         start_color=ME.IGEcolor2->num_bg_log_hl_colors-1;
      }
#ifdef DEBUG_CL
      if ( start_color+num_colors-1<ME.IGEcolor2->num_bg_log_hl_colors-1 )
      {
         printf("IGEcolor2.change_clr_tbl: start_color %d even though change hl @ %d\n",
            start_color,ME.IGEcolor2->num_bg_log_hl_colors-1);
      }
#endif
      upper_slot=ME.IGEcolor2->num_bg_log_hl_colors-1;
   }
   
   if ( start_color>upper_slot+1 )
   {
      /* don't allow to start at next available logical color +1  */
#ifdef DEBUG_CL
      printf("IGEcolor2.change_clr_tbl: start_color(%d)>upper slot + 1 (%d)\n",start_color,upper_slot + 1);
#endif
      return( FALSE );
   }

   if ( (start_color+num_colors-1) > upper_slot )
   {
      /*  last slot changing > current last changable slot ==>enlarge */
      if ( flags&IGE_CHANGE_HIGHLIGHT )
      {
         highlight_slot = ( start_color+num_colors-1 );
      }
      else
      {
         highlight_slot = ( start_color+num_colors );
      }

      sts = om$vla_set_dimension( varray = ME.IGEcolor2->bg_log_hl_colors,
                   size = highlight_slot+1 );

      if (! (sts & 1))
      {
#ifdef DEBUG_CL
         om$report_error(sts = sts);
#endif
         return( FALSE );
      }
      /* move hilite out to end */
      ME.IGEcolor2->bg_log_hl_colors[ highlight_slot ] =
         ME.IGEcolor2->bg_log_hl_colors[ME.IGEcolor2->num_bg_log_hl_colors-1];
      ME.IGEcolor2->num_bg_log_hl_colors = highlight_slot+1;
   }

   if (flags & PACKED_COLORS)
   {
      for ( i = start_color; i < (start_color + num_colors); i++)
      {
         ME.IGEcolor2->bg_log_hl_colors[i]  = *packed_colors++;
      }
   }
   else
   {
      for ( i = start_color; i < (start_color + num_colors); i++)
      {
         ME.IGEcolor2->bg_log_hl_colors[i]  = CLpack_colors(unpacked_colors->red,
         unpacked_colors->green,unpacked_colors->blue);
         unpacked_colors++;
      }
   }

   IGEload_logical_array(me->bg_log_hl_colors,0,me->num_bg_log_hl_colors);

   /* map the CHANGED logical colors for each context */
   sts = om$send( msg      = message IGEcolor2.remap_logical_color_table( start_color, num_colors ),
                  targetid = my_id );

   if (start_color == 0)
   {
      /* changed background so need to reset background color for all windows */
      WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
      WLset_background( WL_UNDEFINED_WINDOW, color_ref );
   }
   return(sts == 0);

}

method change_clr_nam(   IGRshort num_names; struct IGEcol_names *names;
         IGRint flags)
{
/*
NAME
   IGEcolor2.change_clr_nam
DESCRIPTION
   This method will change color names stored in the object.
PARAMETERS
   num_names (IN) - number of names to be changed
   names (IN) - the names to changed
   flags (IN) - whether to change all names or add names/change names within

RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   sts = TRUE;
   IGRint   i,j;
   IGRint   found;

   
   if (!flags)
   {
      sts = om$vla_set_dimension( varray = ME.IGEcolor2->names, size = num_names);
      
      if (! (sts & 1))
      {
#ifdef DEBUG_CL
         om$report_error(sts = sts);
#endif
         goto wrapup;
      }

      ME.IGEcolor2->num_names = num_names;

      for ( i = 0; i < num_names; i++)
      {
         ME.IGEcolor2->names[i]  = names[i];
      }
   }
   else
   {
      for (i = 0; i < num_names; i++)
      {
         found = FALSE;
         for (j=0; (j < ME.IGEcolor2->num_names) && !found; j++)
         {
            if (names[i].index == ME.IGEcolor2->names[j].index)
            {
               ME.IGEcolor2->names[j] = names[i];
               found = TRUE;
            }
         }
   
         if (!found)
         {
            ME.IGEcolor2->num_names++;

            sts = om$vla_set_dimension( varray = ME.IGEcolor2->names,
                   size = ME.IGEcolor2->num_names);

            ME.IGEcolor2->names[ME.IGEcolor2->num_names - 1] = names[i];
         }
      }
   }
       
wrapup:

   return(sts);
}


method delete_clr_nam(   IGRshort num_names; IGRint *name_indexes)
{
/*
NAME
   IGEcolor2.delete_clr_nam
DESCRIPTION
   this method deletes color names
PARAMETERS
   num_names (IN) - number of names to delete
   name_indexes (IN) - the indexes of the names to delete
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   sts = TRUE;
   IGRint   i,j;
   IGRint   found;
   IGRint   found_index = 0;
   IGRint   tot_names;

   
   
   tot_names = ME.IGEcolor2->num_names;

   for (i = 0; i < num_names; i++)
   {
      found = FALSE;
      for (j=0; (j < ME.IGEcolor2->num_names) && !found; j++)
      {
         if (name_indexes[i] == ME.IGEcolor2->names[j].index)
         {
            found = TRUE;
            found_index = j;
         }
      }
         
      if (found)
      {
         tot_names--;
         for (j = found_index; j< tot_names; j++)
         {
            ME.IGEcolor2->names[j] = ME.IGEcolor2->names[j+1];
         }
      }
   }

   ME.IGEcolor2->num_names = tot_names;
   sts = om$vla_set_dimension( varray = ME.IGEcolor2->names,
                               size = ME.IGEcolor2->num_names);

   return(sts);
}

                                                       

method read_clr_nam(   IGRshort *num_names;  struct IGEcol_names *names)
{
/*
NAME
   IGEcolor2.read_clr_nam
DESCRIPTION
   this method reads in the color names
PARAMETERS
   num_names (in) - the number of names allocated and wanted to read
   names (out) - the names when read out
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   sts = TRUE;
   IGRint   i;

   if (*num_names < ME.IGEcolor2->num_names)
   {
      /* this may be on purpose to see how many
         names to allocate next call */
      *num_names = ME.IGEcolor2->num_names;
      sts = FALSE;
      goto wrapup;
   }

   /* actual number of names returned */
   *num_names  = ME.IGEcolor2->num_names;

   for ( i = 0; i < ME.IGEcolor2->num_names; i++)
   {
      names[i] = ME.IGEcolor2->names[i];
   }

wrapup:

   return(sts);
}

method get_name_from_color(IGRshort color; IGRchar *name)
{
/*
NAME
   IGEcolor2.get_name_from_color
DESCRIPTION
   this method gets the name if logical color has a name
PARAMETERS
   color (in) - the logical color to get name
   name (out) - the name of the color
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint       i;
   IGRint       sts = TRUE;
   IGRboolean   not_found = TRUE;

   if (color == 0)
   {
      /* logical 0 is background */
      ex$message( msgnumb = EX_M_BACKGROUND, buff = name );
      goto wrapup;
   }
   else
   {
      if (color == ME.IGEcolor2->num_bg_log_hl_colors - 1)
      {
         /* highest logical color is highlight */
         ex$message( msgnumb = EX_M_HIGHLIGHT, buff = name );
         goto wrapup;
      }
   }
   
   /* the color stored is logical color -1 */
   color--;
      
   if (color < ME.IGEcolor2->num_bg_log_hl_colors - 1)
   {
      for (i = 0 ; i < ME.IGEcolor2->num_names && not_found ; i++)
      {
         if (ME.IGEcolor2->names[i].index == color)
         {
            strcpy(name,ME.IGEcolor2->names[i].name);
            not_found = FALSE;
         }
      }
      if (not_found)
      {
         name = "";
         sts = FALSE;
      }
   }
   else
   {
      name = "";
      sts = FALSE;
   }   

wrapup:

   return(sts);
}


method get_color_from_name(IGRchar *name; IGRshort *color)
{
/*
NAME
   IGEcolor2.get_color_from_name
DESCRIPTION
   this method gets a color given a name
PARAMETERS
   name (IN) - the name of the color looking for
   color (OUT) - the logical color index with the name
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   i;
   IGRint    sts = TRUE;
   IGRboolean   not_found = TRUE;
   IGRchar      temp_name[40];


   ex$message( msgnumb = EX_M_BACKGROUND, buff = temp_name );
   if (!strcmp(temp_name,name))
   {
      *color = 0;
      sts = TRUE;
      goto wrapup;
   }

   ex$message( msgnumb = EX_M_HIGHLIGHT, buff = temp_name );
   if (!strcmp(temp_name,name))
   {
      *color = ME.IGEcolor2->num_bg_log_hl_colors - 1;
      sts = TRUE;
      goto wrapup;
   }

   for (i = 0 ; i < ME.IGEcolor2->num_names & not_found ; i++)
   {
      if (! strcmp(ME.IGEcolor2->names[i].name, name))
      {
         /* the color saved is logical color -1 */
         *color = ME.IGEcolor2->names[i].index + 1;
         not_found = FALSE;
      }
   }

   if (not_found)
   {
      *color = -1;
      sts = FALSE;
   }
   
wrapup:
   return(sts);
}

method get_rgb_value(IGRushort color; void *rgb_value; IGRint flags)
{
/*
NAME
   IGEcolor2.get_rgb_value
DESCRIPTION
   this method gets the (uncompensated) rgb value of a logical color
PARAMETERS
   color (in) - the logical color to get rgb
   rgb_value (out) - the struct or int to return rgb values in
   flag (in) - flag to tell whether struct or int
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint sts = TRUE;
   IGRint  rgb_color;
   struct IGEvlt   *unpacked_color;
   IGRint      *packed_color;

   if (color == IGE_LOGICAL_BACKGROUND)
   {
      color = 0;
   }

   if (color == IGE_LOGICAL_HILITE)
   {
      color = ME.IGEcolor2->num_bg_log_hl_colors - 1;
   }

   if (color >= ME.IGEcolor2->num_bg_log_hl_colors)
   {
#ifdef DEBUG_CL
      printf("IGEcolor2_get_rgb_value: color>num bg_log_hl_colors\n");
#endif
      sts=FALSE;
      goto wrapup;
   }
      
   rgb_color = ME.IGEcolor2->bg_log_hl_colors[color];

   if (flags & PACKED_COLORS)
   {
      packed_color = (IGRint *) rgb_value;
      *packed_color = rgb_color;
   }
   else
   {
      unpacked_color = (struct IGEvlt *) rgb_value;
      CLunpack_colors(rgb_color,&unpacked_color->red,&unpacked_color->green,
         &unpacked_color->blue);
   }

wrapup:
   return(sts);
}

#endif //BASE_EMS
method read_clr_tbl( IGRshort *num_bg_log_hl_colors; void *bg_log_hl_colors; IGRint flags )
{
/*
NAME
   IGEcolor2.read_clr_tbl
DESCRIPTION
   this method is used to read the logical color table
PARAMETERS
   num_bg_log_hl_colors (IN) - this is the number of colors pre-allocated and wished to be read
   bg_log_hl_colors (IN) - this is the array of structs or int to had the colors to be put into
   flags (IN) - whether to use packed or unpacked colors.  Also whether to read bg and hl at ends.
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint      sts = TRUE;
   IGRint      i;
   struct IGEvlt   *unpacked_colors;   
   IGRint      *packed_colors;
   IGRshort      color_index = 0;
   IGRint       num_colors_to_be_read;
   IGRint      start_index;

   if ( ( *num_bg_log_hl_colors == 1 ) && (flags&(IGE_READ_BACKGROUND|IGE_READ_HIGHLIGHT)) )
   {
      /* only reading one value */
      if ( flags&IGE_READ_BACKGROUND )
      {
         color_index = 0;
      }
      if ( flags&IGE_READ_HIGHLIGHT )
      {
         color_index = ME.IGEcolor2->num_bg_log_hl_colors - 1;
      }

      if (flags & PACKED_COLORS)
      {
         packed_colors = (IGRint *) bg_log_hl_colors;
         packed_colors[0] = ME.IGEcolor2->bg_log_hl_colors[color_index];
      }
      else
      {
         unpacked_colors = (struct IGEvlt *) bg_log_hl_colors;
         CLunpack_colors(ME.IGEcolor2->bg_log_hl_colors[color_index],&unpacked_colors[0].red,
                &unpacked_colors[0].green,&unpacked_colors[0].blue);
      }
      goto wrapup;
   }

   /* determine where to start reading and how many color to read */
   num_colors_to_be_read=ME.IGEcolor2->num_bg_log_hl_colors;
   if ( !( flags&IGE_READ_BACKGROUND ) )
   {
      start_index=1;
      num_colors_to_be_read--;
   }
   else
   {
      start_index=0;
   }
   
   if ( !( flags&IGE_READ_HIGHLIGHT ) )
   {
      num_colors_to_be_read--;
   }
   
   if (*num_bg_log_hl_colors < num_colors_to_be_read)
   {
      /* not enough memory allocated.  This may be on
         purpose to see how much to allocate on next
         call */
      *num_bg_log_hl_colors = num_colors_to_be_read;
      sts = FALSE;
      goto wrapup;
   }

   *num_bg_log_hl_colors  = num_colors_to_be_read;

   if (flags & PACKED_COLORS)
   {
      packed_colors = (IGRint *) bg_log_hl_colors;
      for ( i = 0; i < num_colors_to_be_read; i++)
      {
         packed_colors[i] = ME.IGEcolor2->bg_log_hl_colors[i+start_index];
      }
   }
   else
   {
      unpacked_colors = (struct IGEvlt *) bg_log_hl_colors;
      for ( i = 0; i < num_colors_to_be_read; i++)
      {
         CLunpack_colors(ME.IGEcolor2->bg_log_hl_colors[i+start_index],&unpacked_colors[i].red,
             &unpacked_colors[i].green,&unpacked_colors[i].blue);
      }
   }

wrapup:
   return(sts);
}

end  implementation  IGEcolor2;
