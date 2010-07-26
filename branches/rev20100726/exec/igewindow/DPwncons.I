
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEwindow
        METHOD NAME:    window_cons

        Abstract:
-----
%SC%

        VALUE =

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%RL%

        RELATIONS REFERENCED:
                                GRwswn
                                GRwnvw

-----
%NB%


        
-----
%CH%

        CHANGE HISTORY

        MP    09/12/85  : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEwindow;

#include "exnucimport.h"
#include "igewindef.h"
#include "OMmacros.h"

method window_cons(IGRlong *msg; GRobjid mod_id; IGRchar *name;
                    enum window_type win_type; enum screen_type screen;
                    IGRboolean dep_indep;IGRdouble min_x, min_y, max_x, max_y;
		    IGRint win_level; IGRshort right_space, left_space,
		    top_space, bottom_space; IGRboolean draw_border;
		    IGRint icon_flags; IGRchar *symbol_name; 
		    IGRshort symbol_number)

        {

        IGRint          x_extent;
        IGRint          y_extent;
        IGRint          stat;
	IGRint		sym_length;
        IGRdouble       temp;
        OM_S_CHANSELECT chandef1;
        OM_S_CHANSELECT chandef2;       
        

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
        
        
        strcpy(ME.IGEwindow->name, name);
        
        
        if (screen == LEFT_SCREEN || screen == RIGHT_SCREEN)
        {
           ME.IGEwindow->screen_no = screen;
        }
        else
        {
           ME.IGEwindow->screen_no = RIGHT_SCREEN;
        }
        
        
        if (win_type == BORDER || win_type == NO_BORDER || 
				 win_type == SAVE_RESTORE)
        {
           ME.IGEwindow->win_type = win_type;
        }
        else
        {
           ME.IGEwindow->win_type = BORDER;
        }

        
        /* call martha's routine for extents and ws type  */
                
        /* for now just initialize the variables   */
                
        x_extent = 1184;
        y_extent = 884;
        
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

	ME.IGEwindow->draw_border = draw_border;

	ME.IGEwindow->icon_flags = icon_flags;

	ME.IGEwindow->symbol_number = -1;

	if ( win_type == BORDER || win_type == NO_BORDER)
	{
	  if (symbol_name)
	  {
	     sym_length = strlen(symbol_name) + 1;

	     stat = om$vla_set_dimension( varray = ME.IGEwindow->symbol_name,
				    size = sym_length);

	
	     if (! (stat & 1))
	     {
		om$report_error(sts = stat);
		goto fini;
	     }
	
	     strcpy(ME.IGEwindow->symbol_name,symbol_name);
	
	     ME.IGEwindow->symbol_number = symbol_number;
	  }
	}

	     

        /* Connecting the window to the workstation */


        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "module";

                
        chandef2.type = OM_e_name;
        chandef2.u_sel.name = "windows";

                
        stat = om$send  (msg = message Root.connect(chandef2, NULL, 
                                        my_id,OM_Gw_current_OS, 
                                        chandef1, NULL ), 
                           senderid = my_id, 
                           targetid = mod_id);
                                                

        if (!(stat & 1))
         {
            om$report_error(sts = stat);
            goto fini;
        }

fini:
        return (stat);
        }
    end implementation IGEwindow;
                               
