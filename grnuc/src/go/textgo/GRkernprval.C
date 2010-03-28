 /* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRkern_pair_value
 
     Abstract:
                This routine returns the kerning pair value of two
                characters for a specific font.
-----
%SC%

  VALUE = GRkern_pair_value_chars(msg,text_string,fontid,sixteen_bit,kern_value)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          pointer to the two characters to find
                                    the kerning value of; order is
                                    important; the bytes of 16bit chars
                                    SHOULD NOT be swapped
    fontid        FontId            font id
    sixteen_bit   IGRint            TRUE if font is 16 bit, FALSE otherwise
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   -----------    --------------- -----------------------------------------
   *kern_value    IGRdouble       kerning pair value for the two characters

   VALUE (IGRlong) =    MSSUCC    - if successful
                        MSINARG   - if the font's kerning mode is off
                        MSFAIL    - if failure
-----
%MD%

     MODULES INVOKED:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES: 
-----

%CH%
     CHANGE HISTORY:
        
        WBC  10/10/89 : Design date.
        WBC  10/10/89 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This routine returns the kerning pair value of two characters for a
specific font.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "FS.h"

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif

IGRint GRkern_pair_value(msg,text_string,fontid,sixteen_bit,kern_value)

IGRlong             *msg;          /* completion code                     */
IGRuchar            *text_string;  /* pointer to two characters           */
FontId              fontid;        /* font identifier                     */
IGRint              sixteen_bit;   /* TRUE if font is 16 bit              */
IGRdouble           *kern_value;   /* kerning pair value of the two chars */

{
    extern int  FSGetKernMode();
    extern int  FSGetTextVect();

    int                kernmode;
    IGRint             i;
    IGRint             status;
    IGRuchar           kern_chars[4];
    IGRdouble          width_nokerning;
    IGRdouble          width_kerning;

    *msg = MSSUCC;
    status = TRUE;
    *kern_value = 0.0;

    /*
     * is this font's kerning pair mode on?
     */

    if (FSGetKernMode(fontid,&kernmode))
    {
        status = FALSE;   /* invalid fontid */
        *msg = MSFAIL;
    }
    else
    {
        if (kernmode)
        {
            /*
             * if this is a 16 bit font, must swap the two bytes of each char
             */

            if (sixteen_bit)
            {
                GRswap_bytes(msg,text_string,4,kern_chars);
            }
            else
            {
                kern_chars[0] = text_string[0];
                kern_chars[1] = text_string[1];
            }

            /*
             * find the cumulative width of the characters by adding their
             * individual widths (kerning pairs not used)
             */

            width_nokerning = 0.0;
            sixteen_bit = sixteen_bit ? 2 : 1;

            for (i = 0; i < 2; ++i)
            {
#ifdef	NEVER_DEF
		Display 	*display;
		int		window;
		GC		gc;

                FSXGetTextVect(display,window,gc,fontid,&kern_chars[i * sixteen_bit],
                              1,width_nokerning,0.0,&width_nokerning,NULL);
#else
                FSGetTextVect(fontid,&kern_chars[i * sixteen_bit],
                              1,width_nokerning,0.0,&width_nokerning,NULL);
#endif
            }

            /*
             * find the cumulative width of the characters by getting their
             * width as a single string (kerning pairs used)
             *
             */
#ifdef	NEVER_DEF
	{
		Display 	*display;
		int		window;
		GC		gc;

            FSXGetTextVect(display,window,gc,fontid,kern_chars,2,0.0,0.0,
                          &width_kerning,NULL);
	}
#else
            FSGetTextVect(fontid,kern_chars,2,0.0,0.0,
                          &width_kerning,NULL);
#endif
            /*
             * find the two characters kerning pair value by subtracting the
             * width with kerning from the width without the kerning
             */

            *kern_value = width_kerning - width_nokerning;
        }
        else  /* the specified font's kerning pair mode is off */
        {
            *msg = MSINARG;
        }
    }

    return(status);
}
