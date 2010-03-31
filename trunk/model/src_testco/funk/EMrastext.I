class implementation Root;

#include "EMS.h"
#include <tools.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "ex.h"
#include "wl.h"			/* include for WL impact */
#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "dpgraphics.h"

IGRlong EMrastext(msg, buffer, button)
IGRlong *msg;
IGRchar *buffer;
struct EX_button *button;

/*
Abstract
	This function displays raster text at a certain point on the screen.

Arguments
	msg			Return code field. MSSUCC if successful, MSFAIL if failure.

	buffer		an array containing the text to be displayed

	button		a button event containing the x, y, z coordinates; hardware
				window number; and the objid, osnum of the window.

Notes

Files
	EMrastext.I

History
	dhm		12/04/87	creation date.
        Kumar N         02/11/93        Modified for WL impact

        07/12/93   H.S. Gandhi
	   Converted code for WL impact
*/

{
  IGRlong		msg_loc, bytes_ret, error;
  IGRint		hilite_mask;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  extern  IGRboolean  MAmulmx();
  IGRboolean	sts;
  IGRshort		r1 = 4, c1 = 4, c2 = 1;
  IGRdouble		vw_mat[4][4], wld_pnt[4], vw_pnt[4];
  struct var_list	list[2];

  /* begin defines for WL impact */
  WLfont	font_id;
  WLuint16      lscreen_no;
  WLcolorref	col_ref;
  IGRint        screen_type;

#if defined( X11 )
  char 		*fontname = "8x13bold";
#elif defined ( ENV5 )
  char 		*fontname = "/usr/ip32/resrc/rfont/drake.10";
#endif
  /* end defines for WL impact */

  *msg = MSSUCC;
  strcpy(errmsg, "EMrastext error");

  /*
   * Get the viewport matrix and multiply it by the world point.
   */

  list[0].var = WLD_TO_VIEWPORT;
  list[0].var_ptr = (IGRchar *) vw_mat;
  list[0].num_bytes = sizeof(IGRdouble) * 16;
  list[0].bytes_returned = &bytes_ret;

  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;

  dp$inq_set_gragad(msg = &msg_loc, osnum = button->osnum,
                    gragad_objid = button->objid, which_error = &error,
                    var_list = list);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  wld_pnt[0] = button->x;
  wld_pnt[1] = button->y;
  wld_pnt[2] = button->z;
  wld_pnt[3] = 1.0;

  sts = MAmulmx(&msg_loc, &r1, &c1, &c2, vw_mat, wld_pnt, vw_pnt);
  EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

   /* Set the foreground color, disenable the cursor display, */
   /* load the font descriptor, and enable the hilite plane   */
   /* in preparation for the drawsymbols.                     */

   sts = WLpack_index_colorref((WLuint32)0xffffffff,(WLcolorref *)&col_ref,
   			       (WLuint32) TRUE);
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
       fprintf(stderr, "Error packing index colorref; Error %d\n", sts);
#endif
   }

   sts = WLset_active_symbology( (WLuint32) button->window,
                        (WLcolorref) col_ref, (WLuint32) 0, (WLuint16 ) 0xffff,
                        (int) 0, WL_SYMB_CHANGE_COLOR);
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
       fprintf(stderr, "Error setting active symbology; Error %d\n", sts);
#endif
   }

   sts =  WLhide_cursor((WLuint32)button->window, (WLuint32) 0);
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
       fprintf(stderr, "Error hiding the cursor; Error %d\n", sts);
#endif
   }

   sts =  WLget_logical_screen_from_window ( (WLhwin_no) button->window,
					     (WLuint16 *) &lscreen_no );
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
      fprintf(stderr, "Error getting active screen; Error %d\n", sts);
#endif
   }

   sts = WLload_font(lscreen_no,fontname,&font_id);
   if (sts==WL_SUCCESS)
   {
      sts =  WLset_active_font((WLuint16)button->window,font_id);
      if( sts != WL_SUCCESS)
      {     
#ifdef DEBUG
        fprintf(stderr, "Error setting the active font; Error %d\n", sts);
#endif
      }
   }

   sts = WLset_drawing_mode((WLuint32)button->window,
	 		    (WL_BASE_NOOP | WL_HILITE_DRAW) );
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
     fprintf(stderr, "Error setting drawing mode; Error %d\n", sts);
#endif
   }

   sts = WLdraw_text((WLuint32) button->window, (int) vw_pnt[0], 
                     (int) vw_pnt[1], (char *)buffer, (int) strlen(buffer));
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
     fprintf(stderr, "Error drawing text; Error %d\n", sts);
#endif
   }

   sts = WLflush((WLuint32)button->window);
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
     fprintf(stderr, "Error flushing the graphics pipeline; Error %d\n", sts);
#endif
   }

   sts = WLshow_cursor((WLuint32)button->window);
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
     fprintf(stderr, "Error showing the cursor; Error %d\n", sts);
#endif
   }

ret_end:
  return(*msg);
}

end implementation Root;
