#include "igrtypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#ifdef ENV5
#include <tools.h>
#endif
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>

extern Display *EXdisplay;
extern int      EXscreen;
#endif

IGRint	IGEinq_mouse_pos(screen,x,y)

   IGRint		*screen;   /* 0 - right screen, 1 - left screen */
   IGRint		*x;
   IGRint		*y;


{
#ifdef ENV5
    IGRint	num_of_screens;
    IGRint	num_phy_screens;
    IGRint	right_vs;
    IGRint	left_vs;
    IGRint	vs_no;
    IGRint	w_no; 
    IGRint	work_status;
    IGRint	status;


	ige$get_num_screens( num_of_screens = &num_of_screens);

	
	ige$inq_term_info( vs_no = &right_vs);

	if (num_of_screens > 1)
	{
	   ige$inq_term_info(screen_no = IGE_LEFT_SCREEN,vs_no = &left_vs);
	}

	ige$get_num_phy_screens( num_phy_screens = &num_phy_screens);

	if (num_phy_screens == 1)
	{
	    Inq_displayed_vs(&vs_no);

	    if (vs_no == right_vs)
	    {
		*screen = IGE_RIGHT_SCREEN;
	    }
	    else
	    {
		*screen = IGE_LEFT_SCREEN;
	    }

	    Create_levwin_no_border(vs_no,LEVEL_LOW_PRIORITY,10,10,20,20,&w_no);
	    Display_win(w_no);
	    status = Mouseposition(w_no, x, y,&work_status);
	    Delete_win(w_no);
	    *x += 10;
	    *y += 10;

	}
	else
	{
	    Create_levwin_no_border(right_vs,LEVEL_LOW_PRIORITY,10,10,20,20,&w_no);
	    Display_win(w_no);
	    status = Mouseposition(w_no, x, y,&work_status);
	    Delete_win(w_no);
	    *x += 10;
	    *y += 10;


	    if ((num_of_screens == 1) || (*x >= 0 ))
	    {
	       *screen = IGE_RIGHT_SCREEN;
	    }
	    else
	    {
	       Create_levwin_no_border(left_vs,LEVEL_LOW_PRIORITY,10,10,20,20,&w_no);
	       Display_win(w_no);
	       status = Mouseposition(w_no, x, y,&work_status);
	       Delete_win(w_no);
	       *x += 10;
	       *y += 10;

	       *screen = IGE_LEFT_SCREEN;
	    }
	}	    
#endif
#ifdef X11
  Window root, child;
  int win_x,win_y;
  int root_x,root_y;
  unsigned int keys_button;
  Bool sta;
   sta =   XQueryPointer( EXdisplay, RootWindow(EXdisplay,0), &root, &child,
	            &root_x, &root_y, &win_x, &win_y, &keys_button);    

   if ( !sta ) 
   {
     sta =   XQueryPointer( EXdisplay, RootWindow(EXdisplay,1), &root, &child,
	            &root_x, &root_y, &win_x, &win_y, &keys_button);    
     if ( sta )
     {
        *screen = 1;
        *x = root_x;
	*y = root_y;
     }
   }
   else   
   {
        *screen = 0;
        *x = root_x;
	*y = root_y;
   }
#endif
	return(1);
}


