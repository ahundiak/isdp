/* $Id: VDWLmacros.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDWLmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDWLmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1998/09/07  15:26:06  pinnacle
 * tr179801424
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/10/18  21:15:16  pinnacle
 * Replaced: include/VDWLmacros.h for:  by yzhu for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/07/98  ah      TR179801424 Default font is greek under Solaris 2.6
 * -------------------------------------------------------------------*/

#ifndef vdwlmacros_include
#define vdwlmacros_include

/* VDWLmacros.h --------------------------------------------------------------
 *	Macros to use WLdraw_text function
 *
 *	WL* functions used by EMS 3.0 to replace direct ENV 5 calls 
 *		A seperate function is now used to set active font for window.
 *		But no WL* function is defined to return the active font.
 *
 *	Work around (also used by EMS)
 *          The VDS default label fonts were chosen to coincide with the default
 *	    font loaded by WL.  Therefore, the call to WLload_font really just
 *          retrieves the font id of the already-loaded font.  There seems to be
 *          no other way of retrieving that default font id.  The WL default 
 *	    font is defined in exec/wl/wl_internal.h as WLI_TEXT_FONT.
 *
 * 	This file depends on the following files :
 *		wl.h
 *
 *-----------------------------------------------------------------------*/

/* Default font definitions 
 * adapted from $EXNUC/src/exec/wl/wl_internal.h
 * tr179801424 added adobe-courier
 */
#if defined( ENV5 )
#	define VD_TEXT_FONT "/usr/ip32/resrc/rfont/drake.10"
#elif defined( X11 )
#if 0
#	define VD_TEXT_FONT "-*-*-medium-*-normal-*-15-*-*-*-*-*-*-*"
#endif
#	define VD_TEXT_FONT "-adobe-courier-medium-*-normal-*-15-*-*-*-*-*-*-*"
#endif

/*----------------------------------------------------------------------------
/*---------------------------------------------------------------------------
MACRO
	vd$WLdraw_text ( win_no,
			font = VD_TEXT_FONT,
			x,
			y,
			text,
			len,
			sts  )
ABSTRACT
	This macro draws a text string at the given X,Y position
        in the window. 

REMARKS
	This macro also sets the active font for a window.
	Subsequent calls can be made using WLdraw_text directly.

ARGUMENTS
	data type	argument 	I/O description

        WLuint32	lwin_no 	I : logical window number
	char *		font		I : file name of font 
        int		x 		I : the x position of the text
        int		y 		I : the y position of the text
        char *		text 		I : the text string to draw
        int		len 		I : the length of the text string
	int *		sts		O : status

RETURN VALUES
        WL_SUCCESS 			Success
        WL_BAD_WINDOW_NUMBER 		The logical window number is invalid
        WL_BAD_PARAMETER 		The 'text_string' parameter is NULL 
						or 'length' <= 0.
-----------------------------------------------------------------------------*/

#omdef vd$WLdraw_text ( win_no,
			font = VD_TEXT_FONT,
			x,
			y,
			text,
			len, 
			sts	)
	{
	vd$WLset_active_font ( win_no = (win_no) , font = (font) , sts = (sts));
        if (*sts == WL_SUCCESS ){
        	*sts = WLdraw_text( (win_no), (x), (y) , (text), (len) );
		}
	else { 
            #ifdef DEBUG1
		printf ("WLdraw_text: unable to set active font\n");
            #endif
        } 
     }
#endomdef
/*----------------------------------------------------------------------------
/*---------------------------------------------------------------------------
MACRO
	vd$WLset_active_font ( win_no,
			       font = VD_TEXT_FONT,
			       sts  )
ABSTRACT
	This macro sets the active font for a given window.  This is the default	font which will be used by WLdraw_text.

REMARKS
	This macro must be used before invoking WLdraw_text.

ARGUMENTS
	data type	argument 	I/O description

        WLuint32	lwin_no 	I : logical window number
	char *		font		I : file name of font 
	int *		sts		O : status

RETURN VALUES
        WL_SUCCESS 			Success
        WL_BAD_WINDOW_NUMBER 		The logical window number is invalid

-----------------------------------------------------------------------------*/
#omdef vd$WLset_active_font ( win_no,
			      font = VD_TEXT_FONT,
			      sts  )
	{
        WLuint16 	lscreen_no;	/* logical window number */
	WLfont 		font_id;	

        if (WL_SUCCESS == (*sts = WLget_window_screen( (win_no), &lscreen_no))){
              	if (WL_SUCCESS == (*sts = WLload_font( lscreen_no, (font), 
								&font_id))) {
        		*sts = WLset_active_font( (win_no), font_id); 
			}
		
		else {
			printf ("WLset_active_font: unable to load font\n");
			printf ("font_id = %d\tfont = %s\n", font_id, (font) );
			}
		}
	else
		printf ("WLset_active_font: unable to get window screen\n");
        }
#endomdef
#endif vdwlmacros_include
