class specification IGEwindow (1:0) of IGEwsys;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewinchan.h"
#include "igewindow.h"
#include "msdef.h"
#include "OMerrordef.h"

instance IGEwindow
{
   int       screen_no;

   int       ws_type;
   int       win_type;
   IGRint                       flags;
   IGRint			icon_flags;

   IGRshort			top_space;   
   IGRshort			bottom_space;   
   IGRshort			right_space;   
   IGRshort			left_space;   

   IGRdouble			collapse_pos[2];

   IGRboolean			draw_border;
   IGRshort 			level;



   IGRshort			symbol_number;
   variable IGRchar		symbol_name[];
   variable IGRint		cursor_def[];
};

override clear, activate, convert_pnt, movicon, covicon, clpicon, add_gadget;
override delete;

override change_process_from,change_process_to;

override change_gadget_size;



	message window_cons(IGRlong *msg; GRobjid mod_id; IGRchar *name;
                    int win_type; int screen;
                    IGRboolean dep_indep;IGRdouble min_x, min_y, max_x, max_y;
		    IGRint win_level; IGRshort right_space, left_space,
		    top_space, bottom_space; IGRboolean draw_border;
		    IGRint icon_flags; IGRchar *symbol_name; 
		    IGRshort symbol_number; IGRint collapse; IGRdouble *collapse_pos; 
		    IGRlong *cursor_enable_pattern; IGRlong *cursor_data_pattern;
		    IGRlong *cursor_hot_spot);
                

	message passon(OM_p_MESSAGE pass_msg; IGRchar *chan; IGRint strt_index;
                IGRint end_index);


         /* set entries in instance data                      */
        message DPset (IGRlong *msg;IGRlong *which_error; 
			struct win_var_list *var_list );
           
        /* inquire entries in instance data                      */
        message DPinquire (IGRlong *msg;IGRlong *which_error; 
			   struct win_var_list *var_list );
	
	message deactivate();

	message reactivate();

	message draw_border(IGRint color_index);


	message pop_window(IGRlong *msg; IGRint flag);

	message collapse_window(IGRlong *msg; IGRint flag);

	message set_collapse_pos(IGRlong *msg; IGRint dep_indep; 
				 IGRdouble *collapse_pos);
			
	message change_screen(IGRlong *msg; IGRint screen);

	message change_cusror_def(IGRlong *msg; IGRint flag; 
				  IGRlong *enable_pattern;
				  IGRlong *data_pattern;
				  IGRlong *hot_spot);

	message reset_cursor_def(IGRlong *msg);

	message display_name(IGRchar *name);

end specification IGEwindow;
