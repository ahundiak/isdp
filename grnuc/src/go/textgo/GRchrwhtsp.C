/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRchar_white_space
 
     Abstract:  This routine returns the white space to the right and/or
                left of a specified character in a specified font.
-----
%SC%

     VALUE =  GRchar_white_space(msg,character,font_info,
                                 left_space,right_space)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     character    CharId           character
     *font_info   struct vfont_entry font information
     *left_space  IGRdouble        NULL pointer if this value is not
                                   desired
     *right_space IGRdouble        NULL pointer if this value is not
                                   desired
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if font is invalid
				    - MSINARG if specified char is undefined;
				      white space is set to 0.0
     *left_space  IGRdouble       white space to the left of the
                                  specified character
     *right_space IGRdouble       white space to the right of the
                                  specified character

     VALUE (IGRboolean) = TRUE            - always successful
-----
%MD%

     MODULES INVOKED: 
                      FSGetOutlCharInfo
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  12/16/87 : Design date.
        DEK  12/16/87 : Creation date.
        SCW  07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine returns the white space to the right and/or left
of a specified character in a specified font.
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "FS.h"
#include "FSOutl.h"
#include "grimport.h"

#define  WHITE_SPACE_SCALE_FACT   0.25

IGRboolean GRchar_white_space(msg,character,font_info,left_space,right_space)

IGRlong              *msg;         /* completion code                      */
CharId               character;
struct vfont_entry   *font_info;   /* font information                     */
IGRdouble            *left_space;  /* white space to the left of the char. */
IGRdouble            *right_space; /* white space to the right of the char.*/

{
    extern IGRint    FSGetOutlCharInfo();

    OutlCharInfo     char_info;    /* outline character information        */
    IGRint           rc;

    *msg = MSSUCC;

    if (right_space || left_space)
    {
        rc = FSGetOutlCharInfo(font_info->fontid,character,&char_info);

        if (rc != FS_INVALID_FONT)
        {
            if (rc != FS_INVALID_CHAR)
	    {
		if (right_space)
		{
		    if ((char_info.xMax) ||
			(char_info.yMax) ||
			(char_info.yMin))
		    {
			*right_space = char_info.setWid - char_info.xMax;
		    }
		    else  /* no character to display (a blank) */
		    {
			/*
			 * set right white space equal to a percentage of the set width
			 */

			*right_space = WHITE_SPACE_SCALE_FACT * char_info.setWid;
		    }
         
		}

		if (left_space)
		{
		    *left_space = char_info.xMin;
		}
	    }
	    else
	    {
		if (left_space) *left_space = 0.0;
		if (right_space) *right_space = 0,0;
		*msg = MSINARG;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	}
    }
    return(TRUE);
}
