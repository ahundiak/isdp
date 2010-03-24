




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 



#ifndef igewindef_include

#define igewindef_include

#define IP32 0
#define IA32 1
#define IP32C 2
#define IA32C 3

#define BORDER 0
#define NO_BORDER 1
#define SAVE_RESTORE 2

#define LEFT_SCREEN 0
#define RIGHT_SCREEN 1
#define CURRENT_SCREEN 2


#define	WIN_IS_ACTIVE		0x00000001 /* Window active flag  */
#define	WIN_IS_ON		0x00000002 /* is window on	*/
#define WIN_IS_COLLAPSED	0x00000004 /* Window is collapsed flag */
#define COLLAPSE_POS_VALID	0x00000008 /* set if collapse pos should be used */
#ifdef X11
#define WIN_IS_NOTMAPPED        0x00000010 /* window created but did not get map notify yet */
#endif
#define IGE_INDEPENDENT		0
#define IGE_DEPENDENT		1

#define END_PARAM    -1

#define HW_WIN_NO	    37  /* hardware window number	*/
#define WINDOW_FLAGS	    38  /* window flags 		*/
#define WINDOW_NAME	    39  /* window name	 		*/
#define WINDOW_DEP	    40  /* window dependent area	*/
#define WINDOW_INDEP	    41  /* window independent area	*/
#define SCREEN_NO	    42  /* screen no the window is on 	*/
#define WS_TYPE		    43  /* workstation type		*/
#define WIN_TYPE	    44  /* window type (borderless or ..*/
#define WIN_LEVEL	    45	/* window level(low,normal,high)*/
#define RIGHT_SPACE	    46	/* spacing on the right of the
				   borderless window		*/
#define LEFT_SPACE	    47	/* spacing on the left of the
				   borderless window		*/
#define TOP_SPACE	    48	/* spacing on the top of the
				   borderless window		*/
#define BOTTOM_SPACE	    49	/* spacing on the bottom of the
				   borderless window		*/
#define DRAW_BORDER	    50	/* TRUE if the border is to be 
				   drawn			*/
#define ICON_FLAGS	    51  /* tells which icons are enabled*/

#define SYMBOL_NUMBER	    52  /* a number indicating which symbol
				   is to be used instead of the 
				   ordinary collapsed window symbol*/

#define SYMBOL_NAME	    53  /* the name of a file containing the symbol
				   to be used instead of the ordinary 
				   collapsed window symbol*/

#define COLLAPSE_POS	    54 	/* the position at which the window will
				   collapse.  This is stored as indepenent 
				   values between 0.0 and 1.0  */
				   
#define CURSOR_ENABLE_PATTERN 55 /* This is the enable pattern of the cursor
				    */

#define CURSOR_DATA_PATTERN 56	/*  This is the cursor data pattern   */

#define CURSOR_HOT_SPOT	    57	/*  This is the cursor hot spot  */


/* these are for the window level  */

#define IGE_LOW		0
#define IGE_NORMAL	1
#define IGE_HIGH	2
 
/* These are for the icon flags */

#define	IGE_WIN_DELETE_ICON 	0x00000001
#define	IGE_WIN_TOP_ICON	0x00000002
#define	IGE_WIN_BOTTOM_ICON	0x00000004
#define	IGE_WIN_COLLAPSE_ICON	0x00000008
#define	IGE_WIN_MODIFY_ICON	0x00000010
#define IGE_WIN_REPAINT_ICON	0x00000020


#define IGE_POP_TO_TOP		1
#define IGE_POP_TO_BOTTOM	2

#define	IGE_COLLAPSE_WIN	1
#define IGE_UNCOLLAPSE_WIN	2


#define	IGE_RIGHT_SCREEN	0
#define	IGE_LEFT_SCREEN		1
#define IGE_SWAP_SCREEN		2

#define OVERRIDE_CURSOR_DEF	0
#define REPLACE_CURSOR_DEF	1

#endif
