class implementation DPvd;
#include <alloca.h>

#include "griomacros.h"
#include "OMerrordef.h"

#include "DPvd.h"
#include "dp.h"
#include "dpmacros.h"
#include "ex.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "igewinchan.h"
#include "exdef.h"
#include "msdef.h"
#include "msmacros.h"
 
%safe
static OM_S_CHANSELECT IGE_to_gragad_chan;
static IGRboolean IGE_to_gragad_chan_defined = FALSE;
%endsafe

/*--- DPvd_get_active_window ----------------------------------------*/

int DPvd_get_active_window(struct DPvd_actwin *awin)

/*
NAME
        DPvd_get_active_window

DESCRIPTION
	This function determines the active window which will be used
	for view dynamics.

SYNOPSIS
        extern int DPvd_get_active_window(struct DPvd_actwin *awin)

PARAMETERS
        none

GLOBALS USED
	none

RETURN VALUES
	status (OM_s_SUCCESS | 0)

NOTES

HISTORY
	06/05/93    G.Werner
	    Creation Date
	06/29/93    T.Wang
	    To get active window from current mouse position.
          
*/


{
    IGRlong    msg;
    IGRint     status;
    GRobjid    default_oid;
    struct     EX_button buffer;
    struct     GRid gragad_id;
    struct     GRid windows[EX_MAX_WINDOW];
    int        screen_type;
    WLuint16   lscreen_act;
    WLuint16   lscreen_cur;
    IGRint     num_wins;
    IGRint     test;
    IGRlong    cur_area;
    IGRlong    max_area;
    IGRint     error_var;
    IGRint     gragad_flags;
    IGRint     gnomen_size;
    IGRlong    nbytes_ret;
    struct     var_list inq_array[3];
    struct     DPvd_actwin test_win;
    struct     WLbounds area_bounds;
    int        i;
    OM_S_OBJID mod_id;
    OMuword    mod_os;


    /* If mouse is in a EMS window, then take this window, since some
     button (such as make a window active) is not remembered by "last_point" */
    {
	WLuint32 lwin_no,base_context_no;
	WLhwin_no hwwin;
	int x,y,in_window;
	struct WLnative_info native_info;

	WLmouse_win_position(&lwin_no,&x,&y,&in_window);
	if((int)lwin_no != (int)WL_UNDEFINED_WINDOW && in_window)
	{
	    WLget_window_base_context(lwin_no,&base_context_no);
	    WLget_native_info(lwin_no,base_context_no,&native_info);
	    hwwin = native_info.base_win;
	    if(DPvd_get_active_window_id(hwwin,awin))
	      return(OM_S_SUCCESS);
	}	    
    }


    /* get the gnomen_size */
    gnomen_size = 3 * DPvd_get_GN_size ();
    
    /* which screen is active */
    WLget_active_screen( &lscreen_act, &screen_type );
    
    /* get the osnum of the masterfile */
    ex$get_cur_mod( id = &mod_id, osnum = &mod_os );
    
    /* last data point entered - struct EX_button  */
    gr$get_last_point(msg = &msg,
		      sizbuf = NULL,
		      buffer = (IGRchar *)&buffer,
		      nret = NULL);
    
    /* if last data point in default view, window was deleted */
    dp$find_defaultvw (msg = &msg,flag = DPCONST_VW,
		       osnum = mod_os,
		       objid = &default_oid);
    
    /* if last data point in collapsed window or in window which is off, 
       ignore it */
    /* we also test, if last data point is on active screen */
    inq_array[0].var = GRAGAD_FLAGS;
    inq_array[0].var_ptr = (IGRchar *)&gragad_flags;
    inq_array[0].num_bytes = sizeof(IGRint);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = WIN_NO;
    inq_array[1].var_ptr = (IGRchar *)&(test_win.win_no);
    inq_array[1].num_bytes = sizeof(WLuint32);
    inq_array[1].bytes_returned = &nbytes_ret;
    inq_array[2].var = END_PARAM;
    
    status = dp$inq_set_gragad(msg = &msg,
			       gragad_objid = buffer.objid,
                               osnum = buffer.osnum,
			       which_error = &error_var,
			       var_list = inq_array);
    
    WLget_window_screen( test_win.win_no, &lscreen_cur );
    
    /* window not on active screen or window deleted or window collapsed 
       or off ? */
    if( (lscreen_cur != lscreen_act) || (buffer.objid == default_oid) ||
       (!(gragad_flags & IS_WIN_ON && gragad_flags & IS_ACTIVE)))
    {
	test = NULL;
	/* no last data point, find any uncollapsed window */
	/* get all window id's */
	
	status = dp$get_gragad_id( msg = &msg,
				  name = "*",
				  type_gragad = ALL_GG_CLASSES | GG_WIN_ON | ACTIVE_GG | NO_DELAY_GG ,
				  array_size = EX_MAX_WINDOW,
				  numberofids = &num_wins,
				  found_GRids = windows);
	
	/*  find out the biggest uncollapsed, not off window on active screen */
	/*  test all windows, if on active screen and get window bounds */
	max_area=-1.00;
	for(i=0;i<num_wins;i++)
	{
	    /* get the window number */
	    inq_array[0].var = WIN_NO;
	    inq_array[0].var_ptr = (IGRchar *)&(test_win.win_no);
	    inq_array[0].num_bytes = sizeof(WLuint32);
	    inq_array[0].bytes_returned = &nbytes_ret;
	    inq_array[1].var = END_PARAM;
	    
	    status = dp$inq_set_gragad(msg = &msg,
				       gragad_objid = windows[i].objid,
				       osnum = windows[i].osnum,
				       which_error = &error_var,
				       var_list = inq_array);
	    
	    if (!(status &1))
	    {
#ifdef DEBUG
		printf("Cannot get window information \n");
#endif
		return 0;
	    }
	    
	    /* window on active screen ? */
	    WLget_window_screen( test_win.win_no, &lscreen_cur );
	    if (lscreen_cur == lscreen_act)
	    {
		WLget_window_bounds( test_win.win_no, NULL, &area_bounds );
		
		/* check the window area against the gnomensize */
		if (area_bounds.height < gnomen_size || area_bounds.width < gnomen_size)
		  continue; 
		cur_area = area_bounds.height * area_bounds.width;
		if ( cur_area > max_area )
		{
		    if (test == NULL)
		    {
                        test = 1;
		    }
		    max_area = cur_area;
		    gragad_id.osnum = windows[i].osnum;
		    gragad_id.objid = windows[i].objid;
		}
	    }
	}
	/* no uncollapsed window on active screen */
	if (test == NULL)
	{
	    
	    ex$message( field = ERROR_FIELD,
		       justification = CENTER_JUS, 
		       in_buff = "no uncollapsed window on active screen");
	    
	    return 0;
	}
    }
    else
    {
	gragad_id.osnum = buffer.osnum;
	gragad_id.objid = buffer.objid;
    }
    DPvd_activate_window(&gragad_id,awin);
    
    return OM_S_SUCCESS;
    
} /* DPvd_get_active_window */


/*--- DPvd_get_active_window_id ----------------------------------------*/

int DPvd_get_active_window_id(int hwwin, struct DPvd_actwin *awin)

/*
NAME
        DPvd_get_active_window_id

DESCRIPTION
        This function makes the given window number the active window number
        for view dynamics. (in case of changing the active window)

SYNOPSIS
        extern int DPvd_get_active_window_id(int hwwin, struct DPvd_actwin *awin)

PARAMETERS
        int hwwin (IN)                - hardware window number
        struct DPvd_actwin awin (OUT) - complete description of active window

GLOBALS USED
        none

RETURN VALUES
        status (1=OM_S_SUCCESS | 0)

NOTES

HISTORY
        06/05/93    G.Werner
           Creation Date
*/

{
   IGRint status;
   WLuint32 lwin;
   OMuword win_os;
   OM_S_OBJID win_oid;
   OMuint num_on_channel;
   OM_S_OBJECT_LINKAGE *linkage;
  
   /* win_no of IGEwindow */
   status = EX_trans_win( hwwin, &lwin, &win_os, &win_oid );
   if ( status != WL_SUCCESS )
   {
      return( FALSE );
   }

   if ( ! IGE_to_gragad_chan_defined )
   {
     om$make_chanselect( channame = "IGEgadget.to_children",
                         p_chanselect = &IGE_to_gragad_chan);

   }

   if ( awin )
   {
      status = om$get_channel_count( osnum = win_os,
                                     objid = win_oid,
                                     p_chanselect = &IGE_to_gragad_chan,
                                     count = &num_on_channel );

      if ( !( status & 1 ) )
      {
         return(FALSE);
      }

      linkage = (OM_S_OBJECT_LINKAGE *) alloca( num_on_channel * sizeof( OM_S_OBJECT_LINKAGE ) );

      status = om$get_channel_objects( osnum = win_os,
                                       objid = win_oid,
                                       p_chanselect = &IGE_to_gragad_chan,
                                       list = linkage,
                                       size = num_on_channel,
                                       count = &num_on_channel );
      if ( !( status & 1 ) )
      {
         return(FALSE);
      }

      awin->win_no     = lwin; 
      awin->grid.osnum = linkage[0].osnum;
      awin->grid.objid = linkage[0].S_objid;
   }
   
   return( TRUE );
} /* DPvd_get_active_window_id */


/*--- DPvd_activate_window ----------------------------------------*/

int DPvd_activate_window(struct GRid *winid, struct DPvd_actwin *awin)

/*
NAME
        DPvd_activate_window

DESCRIPTION
        This function makes a window (given by GRid winid) the
        active window for view dynamics.

SYNOPSIS
        extern int DPvd_activate_window(struct GRid *winid, struct DPvd_actwin *awin);

PARAMETERS
        struct GRid *winid (IN) - pointer to structure of 
                                  log. window (spacenumber and objid)

GLOBALS USED
        none

RETURN VALUES
        status (1=OM_S_SUCCESS | 0)

NOTES

HISTORY
        06/05/93    G.Werner
           Creation Date
*/



{
    IGRlong msg;
    IGRint error_var;
    IGRint status;
    IGRlong nbytes_ret;
    struct var_list var_list_array[2];
    
    /* first check, if the actual window is correct */
    if ( (awin->grid.objid == winid->objid) &&
         (awin->grid.osnum == winid->osnum) )
    {
       return( TRUE );
    }

    awin->grid.objid = winid->objid;
    awin->grid.osnum = winid->osnum;
    
    /* get the window number */
    var_list_array[0].var = WIN_NO;
    var_list_array[0].var_ptr = (char *)&awin->win_no;
    var_list_array[0].num_bytes = sizeof(IGRint);
    var_list_array[0].bytes_returned = &nbytes_ret;
    var_list_array[1].var = END_PARAM;
    
    status = dp$inq_set_gragad(
			       msg = &msg,
			       osnum =         awin->grid.osnum ,
			       gragad_objid =  awin->grid.objid ,
			       which_error  = &error_var,
			       var_list = var_list_array);
    
    if ( !(1 & status & msg) )
    {
	return( FALSE );
    }

    return( TRUE );

} /* DPvd_activate_window */


end implementation DPvd;
