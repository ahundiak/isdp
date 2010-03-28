/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "fontdef.h"
#include "font.h"
#include "OMminimum.h"
 
from GRfm import GRfm_retdata;
extern IGRint GUget_changed_numeral();

IGRboolean GUgetfontnum ( fontinfo_ptr, font_num, fontid, 
			  fractionbit, md_env )

IGRchar 	*fontinfo_ptr;
IGRshort 	*font_num;
GRobjid		*fontid;
IGRchar 	*fractionbit;
struct GRmd_env	*md_env;

{

IGRboolean		retcode = TRUE;
IGRchar			fontpath[100];
IGRchar                 tmp_fontpath[100];
IGRchar                 tmp_fontfile[PATH_LEN];
IGRlong			msg;
IGRlong			status;
IGRint			len = 0;
IGRshort 		num = 0;
struct vfont_entry	*fontinfo;
IGRint                  stat;

extern IGRboolean	GUget_numeral();
extern IGRboolean 	GRisitfnt();


	fontinfo = (struct vfont_entry *) fontinfo_ptr;
	fontinfo->flags = 0;
    	status = om$send ( mode = OM_e_wrt_object, 
			   msg = message GRfm.GRfm_retdata ( &msg, 
					font_num, fontinfo ), 
			   senderid = md_env->md_id.objid, 
			   targetid = *fontid,
			   from = NULL, 
			   to = NULL );


    	if ( !(status & 1) )
    	{
	    retcode = FALSE;
	    goto wrapup;
    	}
	
	/*
	 *  Set the fraction font bit if necessary.
	 */

	*fractionbit = 0x00;
	if ( fontinfo->flags & FRACTION_FONT )
	{
	    *fractionbit = 0x61;
	}

        /*
 	 *  Set the IGDS fontlib physical font number using the 
	 *  fontpath.  This is only necessary for 7/8 bit fonts.  
	 *  With 16 bit fonts, the characters are contained in 
	 *  any number of fonts.  The font number and character
	 *  code for 16 bit fonts is determined in the 16 bit code.
	 *
         */

	len = strlen ( (char *)fontinfo->fontfile );

	if ( !GRisitfnt ( &msg, fontinfo->fontfile, &len, fontpath ) )
	{
	    retcode = FALSE;
	    goto wrapup;
	}

	if ( (fontinfo->flags & TEXT_FONT)  ||  (fontinfo->flags & FRACTION_FONT) )
	{
             /*
              * copy the fontfile name into a temporary buffer because the
              * function GUget_numeral may alter the input string
              */

             strcpy(tmp_fontfile, (char *)fontinfo->fontfile);

	     if ( GUget_numeral(tmp_fontfile, &num) )
	     {
	  	 *font_num = num;
	     }
	     else 
	     {
                /*
                 * copy the fontpath into a temporary buffer because the
                 * function GUget_numeral may alter the input string
                                                     -- subhasish
                 */

                 strcpy(tmp_fontpath, fontpath);
		 if ( GUget_numeral(tmp_fontpath, &num))
		 {
		    *font_num = num;
	         }
	    	 else
	         {
	    	    *font_num = 0;
	   	 }
	     }
	     if ( *font_num > 127 )
	     {
		*font_num = 0;
	     }
	     stat = GUget_changed_numeral(fontpath, &num);
	     if(stat)
	     {
		*font_num = num;
             }
	}


wrapup:
	return (retcode);


}


end implementation GRvg;
