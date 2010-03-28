/*----
%GP% CODE CLASSIFICATION
----
%HD%

     MODULE NAME	DPdrawcross , DPerascross

-----
%SC%

	value = DPdrawcross ( &msg, &t_point );
	value = DPerascross ( &msg )
-----
%EN%

     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     *t_point	struct EX_button	pointer to the data point
					event structure


-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     *msg	IGRlong		- MSSUCC: success
				- MSFAIL: error

     value = TRUE if operation succeeded
	     FALSE otherwise

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:


-----
%CH%
     CHANGE HISTORY:
	
	HT  05/22/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   DPdrawcross will erase existing tentative point cross if there is any
   and draw a tentative point cross at the point indicated in EX_button.

   DPerasecross will erase the tentative point cross.

----*/
/*EH*/

class implementation IGEgragad;

#include <stdio.h>
#include <stdlib.h>

#include "grimport.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dpmacros.h"
#include "wl.h"

/* prototype files */
%safe
#include "DPcross.h"
#include "DPsetinq.h"
#include "DPgetggid.h"
%endsafe

#define         LEN               40    

%safe
static   IGRshort    point_exists = FALSE ;
static   IGRshort    *t_xdit =NULL;
static   IGRshort    *t_ydit = NULL;
static   IGRint      *t_win_no = NULL;
static   struct GRid *win_obj = NULL;
static   IGRint      max_space = 0;
static   IGRint      num_of_win = 0;
%endsafe

int DPdrawcross ( msg, t_point )

IGRlong		 *msg;
struct EX_button *t_point;

{
    IGRlong   byte, error;
    IGRint    ii, total, total1;
    IGRint    status;
    IGRdouble tx, ty, tz;  /* dits in double */
    IGRshort  xdit, ydit;
    struct var_list var_arr[3];
    IGRlong    mesg;
    struct WLpoint points[2];

    dp$get_gragad_id(msg = &mesg,
                     name = "*",
                     array_size = max_space,
                     total_num = &total,
                     numberofids = &num_of_win,
                     found_GRids = win_obj,
	             type_gragad = (ALL_GG_CLASSES | GG_WIN_ON) );

    if (max_space < total)
    {
        if (win_obj )
            free( win_obj );
        if (t_win_no)
            free( t_win_no );
        if (t_xdit )
            free( t_xdit );
        if (t_ydit )
            free( t_ydit );

        win_obj = (struct GRid *) malloc( total * sizeof(struct GRid) );
        t_win_no = (IGRint *) malloc( total * sizeof(IGRint) );
        t_xdit = (IGRshort *) malloc( total * sizeof(IGRshort) );
        t_ydit = (IGRshort *) malloc( total * sizeof(IGRshort) );
        max_space = total;

        dp$get_gragad_id(msg = &mesg,
                         name = "*",
                         array_size = total,
                         total_num = &total1,
                         numberofids = &num_of_win,
                         found_GRids = win_obj,
                         type_gragad = (ALL_GG_CLASSES | GG_WIN_ON) );
    }

    for ( ii = 0; ii < num_of_win; ii++ )
    {
        var_arr[0].var = WIN_NO;
        var_arr[0].var_ptr = (char *) &t_win_no[ii];
        var_arr[0].num_bytes = sizeof (int);
        var_arr[0].bytes_returned = &byte;
        var_arr[1].var = END_PARAM;

        dp$inq_set_gragad(msg = &mesg,
                          osnum = win_obj[ii].osnum,
                          gragad_objid = win_obj[ii].objid,
                          which_error = &error,
                          var_list = var_arr);
    }

    for ( ii = 0; ii < num_of_win; ii++ )
    {
        /* convert  uor to dits */
        status = om$send(mode = OM_e_wrt_object,
                         msg = message IGEgragad.DPuor2dit( msg, &t_point->x,
                                    &t_point->y, &t_point->z, &tx, &ty, &tz ),
                         senderid = NULL_OBJID,
                         targetid = win_obj[ii].objid,
                         targetos = win_obj[ii].osnum );

        if (! (1 & status))
        {
#ifdef DEBUG
            printf ( "\nDPdrawcross> error converting point." );
            om$report_error(sts = status );
#endif
            goto finish;
        }

        xdit = (short)tx;
        ydit = (short)ty;

        /* erase previous tentative point */
        if ( point_exists )
        {
            DPerasecross( msg );
        }


        WLenter_dynamics( t_win_no[ii] );
        WLhide_cursor( t_win_no[ii], TRUE );

	WLset_dynamics_drawing_mode( t_win_no[ii], WL_DYN_DRAW_MODE );

	WLset_active_symbology( t_win_no[ii], 0, DP_SOLID_LINE_STYLE, 0xFFFF, 0,
	                        WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

        points[0].x = xdit - LEN / 2;
        points[0].y = ydit;
        points[1].x = xdit + LEN / 2;
        points[1].y = ydit;
        WLdraw_2D_line_string( t_win_no[ii], 2, points );

        points[0].x = xdit;
        points[0].y = ydit - LEN / 2;
        points[1].x = xdit;
        points[1].y = ydit + LEN / 2;
        WLdraw_2D_line_string( t_win_no[ii], 2, points );

        t_xdit[ii] = xdit;
        t_ydit[ii] = ydit;

	*msg = MSSUCC;
    }

    point_exists = TRUE;

finish:
    for ( ii = 0; ii < num_of_win; ii++ )
    {
        WLshow_cursor( t_win_no[ii] );
        WLflush( t_win_no[ii] );
	WLexit_dynamics( t_win_no[ii] );
    }

    return ( 1 );

}  /* DPdrawcross */


int DPerasecross ( msg )

IGRlong *msg;

{
    int ii;
    struct WLpoint points[2];

    *msg = MSSUCC;

    if ( point_exists )
    {
        for ( ii = 0; ii < num_of_win; ii++ )
        {
            WLenter_dynamics( t_win_no[ii] );
            WLhide_cursor( t_win_no[ii], TRUE );
	    WLset_dynamics_drawing_mode( t_win_no[ii], WL_DYN_ERASE_MODE );

	    WLset_active_symbology( t_win_no[ii], 0, DP_SOLID_LINE_STYLE, 0xFFFF, 0,
	                            WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

            points[0].x = t_xdit[ii] - LEN / 2;
            points[0].y = t_ydit[ii];
            points[1].x = t_xdit[ii] + LEN / 2;
            points[1].y = t_ydit[ii];
            WLdraw_2D_line_string( t_win_no[ii], 2, points );

            points[0].x = t_xdit[ii];
            points[0].y = t_ydit[ii] - LEN / 2;
            points[1].x = t_xdit[ii];
            points[1].y = t_ydit[ii] + LEN / 2;
            WLdraw_2D_line_string( t_win_no[ii], 2, points );
        }

        point_exists = FALSE;

        for ( ii = 0; ii < num_of_win; ii++ )
        {
            WLshow_cursor( t_win_no[ii] );
            WLflush( t_win_no[ii] );
            WLexit_dynamics( t_win_no[ii] );
        }
  }

  return( 1 );

}  /* DPerasecross */

end implementation IGEgragad;
