/* $Id: IGEwncons.I,v 1.2 2001/01/13 00:41:59 hans Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	emsfixes/exnuc/IGEwncons.I
 *
 * Description:
 *		Creattion of a IGEwindow objects fails in certain reference
 *		files when name DUPLICATION occurs. TR# 179527193
 *
 * Dependencies:
 *		Correction of the file $EXNUC/exec/igewindow/IGEwncons.I
 *
 * Revision History:
 *	$Log: IGEwncons.I,v $
 *	Revision 1.2  2001/01/13 00:41:59  hans
 *	SP16 modifications
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *	Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/08/28  13:12:52  pinnacle
# Created: emsfixes/exnuc/IGEwncons.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/26/95	adz		creation date
 *
 ***************************************************************************/

class implementation IGEwindow;

#include "igewindef.h"
#include "OMmacros.h"
#include "igewinmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"
#include "wl.h"


method window_cons (IGRlong *msg; GRobjid mod_id; IGRchar *name;
                    int win_type; int screen;
                    IGRboolean dep_indep;
                    IGRdouble min_x, min_y, max_x, max_y;
		    IGRint win_level;
                    IGRshort right_space, left_space, top_space, bottom_space;
                    IGRboolean draw_border; IGRint icon_flags;
                    IGRchar *symbol_name; IGRshort symbol_number;
                    IGRint collapse; IGRdouble *collapse_pos;
		    IGRlong *cursor_enable_pattern;
                    IGRlong *cursor_data_pattern;
		    IGRlong *cursor_hot_spot)
{
   IGRint          x_extent;
   IGRint          y_extent;
   IGRint          stat, wl_stat;
   IGRint          sym_length;
   IGRdouble       temp;
   IGRint          num_screens;
   IGRint          cur_def_length = 66; /* number of long needed to define
                                           cursor  */

   IGRchar         old_cur_dir[DI_PATH_MAX];
   IGRchar         path[DI_PATH_MAX];

   WLuint16        lscreen;
   int             lscreen_type;

   stat = OM_S_SUCCESS;
   ME.IGEwindow->flags |= WIN_IS_ON;

   if (min_x > max_x)
   {
      temp = min_x;
      min_x = max_x;
      max_x = temp;
   }

   if (min_y > max_y)
   {
      temp = min_y;
      min_y = max_y;
      max_y = temp;
   }

   if (name)
   {
      di$pwd(dirname = old_cur_dir);
      stat = di$give_pathname ( osnum = OM_Gw_current_OS,
                                pathname = path);
      if (!(1 & stat))
      {
#ifdef DEBUG
         di$report_error ( sts = stat,
                           comment = "in window construct, give pathname");
#endif
         goto wrapup;
      }

      di$cd( dirname = path);
      DIstrcat(path,"windows");
      stat = di$mkdir (dirname = path);
      if ((!(1& stat)) && (stat != DIR_E_DIR_DUP))
      {
#ifdef DEBUG
         di$report_error ( sts = stat,
                           comment = "in window construct, mkdir ");
#endif
         di$cd(dirname = old_cur_dir);
         goto wrapup;
      }

/* START CORRECTION */
      stat = OM_S_SUCCESS;
/* END CORRECTION */

      DIstrcat(path,name);
      stat = di$add_name ( objname = path, objid = my_id);
      if ((!(1& stat)) && (stat != DIR_E_NAME_DUP))
      {
#ifdef DEBUG
         di$report_error ( sts = stat,
                           comment = "in window construct, addname ");
#endif
         di$cd(dirname = old_cur_dir);
         goto wrapup;
      }
/* START CORRECTION */
      stat = OM_S_SUCCESS;
/* END CORRECTION */
      di$cd(dirname = old_cur_dir);
   }

   if (screen == LEFT_SCREEN || screen == RIGHT_SCREEN)
   {
      ME.IGEwindow->screen_no = screen;
   }
   else
   {
      if (screen == CURRENT_SCREEN &&  ex$is_interactive() )
      {
         wl_stat = WLget_number_of_screens ( &num_screens, 0 );
         if (num_screens == 1)
         {
            ME.IGEwindow->screen_no = RIGHT_SCREEN;
         }
         else
         {
            wl_stat = WLget_active_screen ( &lscreen, &lscreen_type );
            if (lscreen_type == WL_SCREEN_PRIMARY)
               ME.IGEwindow->screen_no = RIGHT_SCREEN;
            else
               ME.IGEwindow->screen_no = LEFT_SCREEN;
         }
      }
      else
      {
         ME.IGEwindow->screen_no = RIGHT_SCREEN;
      }
   }

   if (win_type == BORDER || win_type == NO_BORDER || win_type == SAVE_RESTORE)
   {
      ME.IGEwindow->win_type = win_type;
   }
   else
   {
      ME.IGEwindow->win_type = BORDER;
   }

   ige$inq_term_info ( x_extent = &x_extent,
                       y_extent = &y_extent);

   /*=================================================================*/
   /* subtract 1 from the extent because the screen values start at 0 */
   /*=================================================================*/

   x_extent--;
   y_extent--;

   ME.IGEwindow->ws_type = IP32;

   if (dep_indep == IGE_INDEPENDENT)
   {
      ME.IGEgadget->min_x_indep = min_x;
      ME.IGEgadget->min_y_indep = min_y;
      ME.IGEgadget->max_x_indep = max_x;
      ME.IGEgadget->max_y_indep = max_y;

      ME.IGEgadget->min_x_dep = (IGRint)(min_x * x_extent + 0.5);
      ME.IGEgadget->min_y_dep = (IGRint)(min_y * y_extent + 0.5);
      ME.IGEgadget->max_x_dep = (IGRint)(max_x * x_extent + 0.5);
      ME.IGEgadget->max_y_dep = (IGRint)(max_y * y_extent + 0.5);
   }
   else
   {
      ME.IGEgadget->min_x_indep = min_x /x_extent;
      ME.IGEgadget->min_y_indep = min_y /y_extent;
      ME.IGEgadget->max_x_indep = max_x /x_extent;
      ME.IGEgadget->max_y_indep = max_y /y_extent;

      ME.IGEgadget->min_x_dep = (IGRint) min_x ;
      ME.IGEgadget->min_y_dep = (IGRint) min_y ;
      ME.IGEgadget->max_x_dep = (IGRint) max_x ;
      ME.IGEgadget->max_y_dep = (IGRint) max_y ;
   }

   ME.IGEwindow->level = win_level;

   if (right_space > 0)
   {
      ME.IGEwindow->right_space = right_space;
   }
   else
   {
      ME.IGEwindow->right_space = 0;
   }

   if (left_space > 0)
   {
      ME.IGEwindow->left_space = left_space;
   }
   else
   {
      ME.IGEwindow->left_space = 0;
   }

   if (top_space > 0)
   {
      ME.IGEwindow->top_space = top_space;
   }
   else
   {
      ME.IGEwindow->top_space = 0;
   }

   if (bottom_space > 0)
   {
      ME.IGEwindow->bottom_space = bottom_space;
   }
   else
   {
      ME.IGEwindow->bottom_space = 0;
   }

   ME.IGEwindow->draw_border   = draw_border;
   ME.IGEwindow->icon_flags    = icon_flags;
   ME.IGEwindow->symbol_number = -1;

   if ( win_type == BORDER || win_type == NO_BORDER)
   {
      if (symbol_name)
      {
         sym_length = strlen(symbol_name) + 1;

         stat = om$vla_set_dimension ( varray = ME.IGEwindow->symbol_name,
                                       size = sym_length);
         if (! (stat & 1))
         {
#ifdef DEBUG
            om$report_error(sts = stat);
#endif
            goto wrapup;
         }

         strcpy(ME.IGEwindow->symbol_name,symbol_name);
         ME.IGEwindow->symbol_number = symbol_number;
      }
   }

   if (collapse_pos)
   {
      if (dep_indep == IGE_INDEPENDENT)
      {
         ME.IGEwindow->collapse_pos[0] = collapse_pos[0];
         ME.IGEwindow->collapse_pos[1] = collapse_pos[1];
      }
      else
      {
         ME.IGEwindow->collapse_pos[0] = collapse_pos[0]/(double) x_extent;
         ME.IGEwindow->collapse_pos[1] = collapse_pos[1]/(double) y_extent;
      }
      ME.IGEwindow->flags |= COLLAPSE_POS_VALID;
   }

   if (collapse)
   {
      ME.IGEwindow->flags |= WIN_IS_COLLAPSED;
      if (!collapse_pos)
      {
         ME.IGEwindow->collapse_pos[0] = ME.IGEgadget->max_x_indep;
         ME.IGEwindow->collapse_pos[1] = ME.IGEgadget->min_y_indep;
      }
   }

   if ((cursor_enable_pattern) && (cursor_data_pattern) && (cursor_hot_spot))
   {
      stat = om$vla_set_dimension ( varray = ME.IGEwindow->cursor_def,
                                    size = cur_def_length);
      if (! (stat & 1))
      {
#ifdef DEBUG
         om$report_error(sts = stat);
#endif
         goto wrapup;
      }

      OM_BLOCK_MOVE ((char *)cursor_enable_pattern,
                     (char *)ME.IGEwindow->cursor_def,
                     sizeof(IGRlong) * 32);

      OM_BLOCK_MOVE ((char *)cursor_data_pattern,
                     (char *)&ME.IGEwindow->cursor_def[32],
                     sizeof(IGRlong) * 32);

      OM_BLOCK_MOVE ((char *)cursor_hot_spot,
                     (char *)&ME.IGEwindow->cursor_def[64],
                     sizeof(IGRlong) * 2);
   }

wrapup:
   return (stat);
}

end implementation IGEwindow;

