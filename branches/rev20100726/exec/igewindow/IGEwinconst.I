
class implementation IGEwindow;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "exmacros.h"




IGEwin_const(win_objid,msg,win_class,mod_id,mod_osnum,name,win_type,screen,dep_indep,
	     min_x,min_y,max_x,max_y,win_level,right_space,left_space,
	     top_space,bottom_space,draw_border,icon_flags,symbol_name,
	     symbol_number,collapse,collapse_pos,cursor_enable_pattern,
	     cursor_data_pattern,cursor_hot_spot)


   GRobjid	*win_objid;
   IGRlong	*msg;
   IGRchar	*win_class;
   GRobjid	mod_id;
   GRspacenum	mod_osnum;
   IGRchar	*name;
   int 	win_type;
   int	screen;
   IGRboolean		dep_indep;
   IGRdouble		min_x;
   IGRdouble		min_y;
   IGRdouble		max_x;
   IGRdouble		max_y;
   IGRint		win_level;
   IGRshort		right_space;
   IGRshort		left_space;
   IGRshort		top_space;
   IGRshort		bottom_space;
   IGRboolean		draw_border;
   IGRint		icon_flags;
   IGRchar		*symbol_name;
   IGRint		symbol_number;
   IGRint		collapse;
   IGRdouble		*collapse_pos;
   IGRlong		*cursor_enable_pattern;
   IGRlong		*cursor_data_pattern;
   IGRlong		*cursor_hot_spot;

      {


	IGRchar os_name[OM_K_MAXOSNAME_LEN];
	IGRint	status;


	*msg = MSSUCC;

        if (mod_id == NULL_OBJID)
        {
	   ex$get_cur_mod(id = &mod_id,
			  osnum = &mod_osnum);
        }
	

	status = om$os_number_to_name(osnum = mod_osnum,
				      osname = os_name);

	if (!(1 & status))
	{
	   om$report_error(sts = status);
	   *msg = MSFAIL;
	   goto wrapup;
	}


	status = om$construct(osname = os_name,
                        classname = win_class,
                        p_objid = win_objid,
                        msg = message IGEwindow.window_cons( msg,mod_id, 
                             name, win_type, screen, dep_indep,
                        min_x, min_y, max_x, max_y, win_level, 
		        right_space, left_space, top_space, bottom_space,
			draw_border,icon_flags,symbol_name,symbol_number,
			collapse,collapse_pos,cursor_enable_pattern,
			cursor_data_pattern,cursor_hot_spot),
                        neighbor = OM_GS_NULL_NEIGHBOR);

	if (!(1 & status))
	{
	   om$report_error(sts = status);
	   *msg = MSFAIL;
	   goto wrapup;
	}

wrapup:

      return(status);

      }	

end implementation IGEwindow;
