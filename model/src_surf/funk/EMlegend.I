/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
#include <stdio.h>
#include "wl.h"			/* include file for WL impact */
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "dpgraphics.h"
#include "mamulmx.h"

/*
Abstract
    This function displays the color legend for the color-coded radius of 
    curvature function (EMrltcoldsp.I)


Arguments
    IGRboolean EMlegend(msg, w_no, w_id, w_os, diag_pnt, num_colors, color,
                        range)

    IGRlong   *msg        return code.

    IGRint    w_no        window number of the window to display legend in.

    OM_S_OBJID   w_id     window objid of the window to display legend in.

    OMuword   w_os        window osnum of the window to display legend in.

    IGRpoint  diag_pnt    the uppper left-hand corner point of the legend.

    IGRint    num_colors  number of colors to display.

    IGRint    color[]     array of color index numbers.

    IGRdouble range[]     the low and high range value to display for each
                          color.  EX:  range[0] -- low value for color[0]
                                       range[1] -- high value for color[0]


Notes

Files
    EMlegend.I


History
    dhm    12/13/88    creation date.
    dhm    01/26/89    added code to get the absolute color index of
                       the logical colors passed in.
    BL	   08/14/89    added code to make the box's length depend on the 
		       range[] data.
    BD	   10/25/91    Converted code for X compilation.
    Kumar N 2/8/93     Converted code for WL impact
    Sudha  07/06/93    Modified for BSprototypes ansification
    07/12/93	H.S. Gandhi
       Converted code for WL impact
*/

IGRboolean EMlegend(msg, w_no, w_id, w_os, diag_pnt, num_colors, color,
                    range)
IGRlong   *msg;
IGRint    w_no;
OM_S_OBJID   w_id;
OMuword   w_os;
IGRpoint  diag_pnt;
IGRint    num_colors;
IGRint    color[];
IGRdouble range[];

{
  IGRlong    msg_loc, bytes_ret, error;
  IGRint     i;
  WLcolorref col_ref;
  IGRchar    errmsg[EMMAXERRMSG_LEN], buffer[40], rangestr[20];
  extern  IGRboolean  MAmulmx();
  IGRboolean	sts;
  IGRshort  r1 = 4, c1 = 4, c2 = 1;
  IGRdouble  vw_port_mat[4][4], wld_pnt[4], vw_port_pnt[4], len;
  IGRint  x1, y1, x2, y2, xlo, ylo;
  struct var_list  list[2];

  /* 07/12/93;HSG: begin defines for WL impact */
  struct WLrect   rect;
  struct WLpoint  points[5];

  WLuint16      lscreen_no;
  WLfont	font_id;
  IGRint	screen_type;

#if defined( X11 )
  char		*fontname = "8x13bold";
#elif defined( ENV5 )
  char		*fontname = "/usr/ip32/resrc/rfont/drake.10";
#endif

  /* end defines for WL impact */

  sts = TRUE;
  *msg = MSSUCC;
  strcpy(errmsg, "EMlegend error\n");

  /*
   * Get the viewport matrix to multiply by the world points.
   */

  list[0].var = WLD_TO_VIEWPORT;
  list[0].var_ptr = (IGRchar *) vw_port_mat;
  list[0].num_bytes = sizeof(IGRdouble) * 16;
  list[0].bytes_returned = &bytes_ret;

  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;

  dp$inq_set_gragad(msg = &msg_loc, osnum = w_os, gragad_objid = w_id,
                    which_error = &error, var_list = list);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Multiply the diagonal points by the viewport matrix to get the
   * x and y coordinates in screen coordinate system.
   */

  wld_pnt[0] = diag_pnt[0];
  wld_pnt[1] = diag_pnt[1];
  wld_pnt[2] = diag_pnt[2];
  wld_pnt[3] = 1.0;

  sts = MAmulmx(&msg_loc, &r1, &c1, &c2, &vw_port_mat[0][0], wld_pnt,
                vw_port_pnt);
  EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  x1 = vw_port_pnt[0];
  y1 = vw_port_pnt[1];

  /* adjust the length of box */

/*
  if(range[1] < 1)
  {
     if(range[0] == 0 && range[1] == 0)  len = 140;
     else if(range[1] < 0.1)  len = 270;
     else  len = 230;
  }
  else  len = 210;
*/
  len = 170;
     
  x2 = x1 + len;
  y2 = y1 + 15 * (num_colors + 2);


   /* Disenable the cursor display. */
   WLhide_cursor((WLuint32)w_no, (WLuint32) 0);

   /* Draw the box around the legend */
   points[0].x = x1; points[0].y = y1;
   points[1].x = x1; points[1].y = y2;
   points[2].x = x2; points[2].y = y2;
   points[3].x = x2; points[3].y = y1;
   points[4].x = x1; points[4].y = y1;
   WLdraw_2D_line_string( (WLuint32) w_no, (int) 5,  points);

   /* get the screen no from the window w_no */
   sts =  WLget_logical_screen_from_window ( (WLhwin_no) w_no,
					     (WLuint16 *) &lscreen_no );
   if( sts != WL_SUCCESS)
   {     
#ifdef DEBUG
     fprintf(stderr, "Error getting screen no from window; Error %d\n", sts);
#endif
   }

   /* create the font to be used by WLdraw_text */
   sts = WLload_font(lscreen_no,fontname,&font_id);
   if (sts==WL_SUCCESS)
   {
      /* set the active font */
      sts =  WLset_active_font((WLuint16)w_no,font_id);
      if( sts != WL_SUCCESS)
      {     
#ifdef DEBUG
         fprintf(stderr, "Error setting active font; Error %d\n", sts);
#endif
      }
   }
   else
   {
#ifdef DEBUG
         fprintf(stderr, "Error creating the font; Error %d\n", sts);
#endif	
   }

  xlo = x1 + 10;
  ylo = y1 + 10;

  for (i = 0; i < num_colors; i++)
  {

    /* pack a logical color index into a color reference */
    sts = WLpack_index_colorref((WLuint32)color[i],(WLcolorref *)&col_ref,
				   (WLuint32) FALSE);
    if( sts != WL_SUCCESS)
    {     
#ifdef DEBUG
      fprintf(stderr, "Error packing index colorref; Error %d\n", sts);
#endif
    }

    /* set the active foreground color */
    sts = WLset_active_symbology(( WLuint32) w_no, (WLcolorref) col_ref,
                                 (WLuint32) 0, (WLuint16 ) 0xffff, (int) 0,
                                  WL_SYMB_CHANGE_COLOR);
    if( sts != WL_SUCCESS)
    {     
#ifdef DEBUG
      fprintf(stderr, "Error setting active symbology; Error %d\n", sts);
#endif
    }

    rect.x = xlo; rect.y = ylo; rect.width = 40; rect.height = 10;
    sts = WLdraw_rectangle(w_no, &rect,(WLuint32) 1) ;
    if( sts != WL_SUCCESS)
    {     
#ifdef DEBUG
      fprintf(stderr, "Error drawing a rectangle; Error %d\n", sts);
#endif
    }

    sprintf(rangestr, "%.5e", range[i*2]);
    strcpy(buffer, rangestr);

#if defined( ENV5 )
       sts = WLdraw_text( (WLuint32) w_no, (int) xlo+50, (int) ylo,
                          (char *)buffer, (int) strlen(buffer) );
       if( sts != WL_SUCCESS)
       {     
#ifdef DEBUG
          fprintf(stderr, "Error drawing text in ENV5; Error %d\n", sts);
#endif
       }
#elif defined( X11 )
       sts = WLdraw_text( (WLuint32)w_no, (int) xlo+50, (int) ylo+9,
                          (char *)buffer, (int) strlen(buffer) );
       if( sts != WL_SUCCESS)
       {     
#ifdef DEBUG
          fprintf(stderr, "Error drawing text in X11; Error %d\n", sts);
#endif
       }
#endif
    ylo += 15;
  }

  strcpy(buffer,"Max. ");
  sprintf(rangestr,"%.5e",range[(num_colors - 1)*2+1]);
  strcat(buffer,rangestr);

#if defined( ENV5 )
  sts = WLdraw_text( (WLuint32) w_no, (int) xlo+50, (int) ylo,
                    (char *)buffer, (int) strlen(buffer) );
  if( sts != WL_SUCCESS)
  {     
#ifdef DEBUG
     fprintf(stderr, "Error drawing text in ENV5; Error %d\n", sts);
#endif
  }
#elif defined( X11 )
  sts = WLdraw_text( (WLuint32) w_no, (int) xlo+50, (int) ylo+9, 
                    (char *)buffer, (int) strlen(buffer) );
  if( sts != WL_SUCCESS)
  {     
#ifdef DEBUG
     fprintf(stderr, "Error drawing text in X11; Error %d\n", sts);
#endif
  }
#endif

  sts = WLflush((WLuint32) w_no);
  if( sts != WL_SUCCESS)
  {     
#ifdef DEBUG
     fprintf(stderr, "Error flushing the graphics pipeline; Error %d\n", sts);
#endif
  }

  sts = WLshow_cursor((WLuint32) w_no);
  if( sts != WL_SUCCESS)
  {     
#ifdef DEBUG
     fprintf(stderr, "Error displaying the cursor; Error %d\n", sts);
#endif
  }

  ret_end:
    return(sts);
} /* end EMlegend */

end implementation Root;
