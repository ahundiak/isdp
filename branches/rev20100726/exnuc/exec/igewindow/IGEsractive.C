
#include "exmacros.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#ifdef ENV5
#include <tools.h>
#include <FIproto_pub.h>
#endif

#ifdef X11
extern int SaveRestoreFormsDisplayed;
#include <XFIproto_pub.h>
#endif
#ifdef ENV5
static struct IGEsrstate  active_sr[2];
#endif
#argsused
IGRint IGEcreate_sr(objid,osnum,screen_no,min_x,min_y,max_x,max_y,win_no)


   IGRint		objid;
   unsigned short	osnum;
   int 	        screen_no;
   IGRint		min_x;
   IGRint		min_y;
   IGRint		max_x;
   IGRint		max_y;
   IGRint		*win_no;

{
#ifdef ENV5
   IGRint	num_of_screens;
   IGRint	vs_no;
   IGRint	right_vs;
   IGRint	left_vs;
   IGRint	num_of_planes;
   IGRint	right_num_of_planes;
   IGRint	left_num_of_planes;
   IGRint	active_screen;
   IGRint	count;
#endif
   IGRint	status = TRUE;
#ifdef ENV5
   struct  scr_info  dep_scr_info[MAX_SCREENS];


	ige$get_num_screens( num_of_screens = &num_of_screens);

	Inq_displayed_vs(&vs_no);

	ige$inq_term_info(	vs_no = &right_vs,
				num_of_planes = &right_num_of_planes);

	if (num_of_screens > 1)
	{
	   ige$inq_term_info(	screen_no = IGE_LEFT_SCREEN,
				vs_no = &left_vs,
				num_of_planes = &left_num_of_planes);
	}	      
	
	if (vs_no == right_vs)
	{
	   active_screen = IGE_RIGHT_SCREEN;
	}
	else
	{
	   active_screen = IGE_LEFT_SCREEN;
	}

	Inq_screen_info(dep_scr_info);

	num_of_planes = dep_scr_info[vs_no].vsi_SR_max_planes;
	count = active_sr[active_screen].count;

/*  no more than five nested save/restore window */

	if (count > 4)
	{
	   status = FALSE;
	   goto wrapup;
	}

	active_sr[active_screen].osnum[count] = osnum;
	active_sr[active_screen].objid[count] = objid;

	if (count == 0)
	{
	   if (Enter_SR(vs_no,num_of_planes,win_no))
	   {
	      status = FALSE;
	      goto wrapup;
	   }
	   active_sr[active_screen].win_no = *win_no;
	}
	else
	{
	   EX_del_win(active_sr[active_screen].objid[count - 1],
		      active_sr[active_screen].osnum[count - 1]);

	   *win_no = active_sr[active_screen].win_no;
	}

	if (Create_SR_area(active_sr[active_screen].win_no,min_x,min_y,
			   max_x,max_y))
	{
	   status = FALSE;
	   goto wrapup;
	}

	active_sr[active_screen].count++;

wrapup:
#endif
   return(status);

}
#argsused
IGRint IGEdelete_sr(screen_no,win_no)
   int screen_no;
   IGRint	win_no;

{

#ifdef ENV5
   IGRint vs_no;
   IGRint right_vs;
   IGRint left_vs;
   IGRint num_of_screens;
   IGRint active_screen;
   IGRint count;
#endif
   IGRint status = TRUE;

#ifdef ENV5
	ige$get_num_screens( num_of_screens = &num_of_screens);

	Inq_displayed_vs(&vs_no);

	ige$inq_term_info(	vs_no = &right_vs);

	if (num_of_screens > 1)
	{
	   ige$inq_term_info(	screen_no = IGE_LEFT_SCREEN,
				vs_no = &left_vs);
	}	      
	
	if (vs_no == right_vs)
	{
	   active_screen = IGE_RIGHT_SCREEN;
	}
	else
	{
	   active_screen = IGE_LEFT_SCREEN;
	}

	count = active_sr[active_screen].count;

	if (count < 1)
	{
	   status = FALSE;
	   goto wrapup;
	}

	if (Delete_SR_area(win_no))
	{
	   status = FALSE;
	   goto wrapup;
	}

	EX_del_win(active_sr[active_screen].objid[count - 1],
	           active_sr[active_screen].osnum[count - 1]);

	if (count > 1)
	{
	   ex$add_win_to_exec(win_num = win_no, 
				    objid = active_sr[active_screen].objid[count - 2], 
				    osnum = active_sr[active_screen].osnum[count - 2]);
	}
				
	

	if (!--active_sr[active_screen].count)
	{
	   if (Exit_SR(win_no))
	   {
	      status = FALSE;
	      goto wrapup;
	   }
	}
wrapup:
#endif
	return(status);
}

	
IGRint IGEsractive()

{
#ifdef ENV5
   IGRint	ret_code;

	if ((active_sr[IGE_RIGHT_SCREEN].count > 0) || 
	    (active_sr[IGE_LEFT_SCREEN].count > 0) ||
	    FI_is_SR_active())
	{
	    ret_code = TRUE;
	}
	else
	{
	   ret_code = FALSE;
	}
 	return(ret_code);
#endif
#ifdef X11
    return ( SaveRestoreFormsDisplayed );/*in xforms*/
#endif


}
