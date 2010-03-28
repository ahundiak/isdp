/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRmake_entry
 
     Abstract:
                This routine downloads a specified font.  If the specified 
                font is found and successfully downloaded, an entry is made
                in the font manager table with the name of the font file
                and the virtual font name of the downloaded font. The 
                virtual font number will be returned if it was not specified
                on entry (it must be set to -1 on entry if not specified).
-----
%SC%

    VALUE = GRmake_entry(IGRlong *msg; IGRuchar *fontfile;
                         IGRuchar *vfont_name; IGRint font_flags;
                         IGRshort *vfont_num)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *fontfile     IGRuchar  font file specification
    *vfont_name   IGRuchar  virtual font name
    font_flags    IGRint            flag telling what type of font
    *vfont_num    IGRshort          virtual font number (should be set
                                    to -1 if not specified)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     -------------- -------------------------------------------
     *msg           IGRlong        completion code

     VALUE (IGRlong) =    MSSUCC         - if successful
                          MSFAIL         - if failure
                          GR_E_MxNoFtLdd - if local list is full
-----
%MD%

     MODULES AND METHODS INVOKED:

     methods: FEadd_font

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  10/28/87 : Design date.
        DEK  10/28/87 : Creation date.
        DEK  03/10/88 : Capability for different type of fonts added.
        DEK  04/15/88 : Changed to use locale.
        WBC  09/06/89 : Added code to support the EX_Demand_Font flag.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This method downloads a specified font.  The virtual font name 
must be a unique virtual font name. A message is sent to the font 
executive to see if the font has been downloaded for another font 
manager.  If it has, the typeface of the font is returned and an
entry will be made in the virtual font table.  If the font has not 
previously been downloaded, the font will be downloaded.  An entry 
will be made in the virtual font table reflecting which font has 
been downloaded and where to find it.  If the virtual font number is
not specified on entry, it must be set to -1.  The virtual number
used will be returned on exit.  A message will be sent to notify the
font executive that another font has been downloaded.

----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "gr.h"
#include  "OMmacros.h"
#include  "OMerrordef.h"
#include  "FS.h"
#include  "FSOutl.h"
#include  "codef.h"
#include  "grmessage.h"
#include  "exmacros.h"
#include  "femacros.h"
#include  "exlocaledef.h"
#include  "exlocale.h"
#include  "string.h"

from GRmodule  import GRadd_fnt;

method GRmake_entry(IGRlong *msg; IGRuchar *fontfile;
                    IGRuchar *vfont_name;
                    IGRint font_flags; IGRshort *vfont_num)
{
    FontId                font_id;                 /* identifies font        */
    OutlInfo              outlinfo;                /* font information       */
    IGRlong               temp_msg, OMmsg;         /* status messages        */
    struct GRid           mod_id;                  /* module id              */
    struct EX_fonts       font_parameters;         /* locale parameters      */
    struct EX_locale_var  var_list;                /* locale identifiers     */
    IGRint                FS_flags;                /* font server parameters */
    IGRboolean            font_read;               /* true if font file
                                                      successfully read      */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    temp_msg = MSSUCC;
    font_read = FALSE;

    /*
     *  If virtual font number is not specified, find an unused entry in the
     *  font manager table for the new font.
     */

    if (*vfont_num < 0)
    {
        *vfont_num = 0;
        while ((*vfont_num < me^^GRfm.num_entries) && 
               (me^^GRfm.vfont[*vfont_num].def_flag != undefined))
        {
            ++(*vfont_num);
        }

        /*
         * if a new entry needs to be added to the font manager table, make
         * sure the font manager has not already reached its maximum length
         */

        if ((*vfont_num == me^^GRfm.num_entries) &&
            (me^^GRfm.num_entries >= MAXFONT))
        {
            *msg = GR_E_MxNoFtLdd;
            goto FINISH;
        }
    }

    /*
     * call locale to get the font parameters of the specified font
     */

    var_list.var = EX_font_parameters;
    var_list.var_ptr = (IGRchar *)&font_parameters;

    ex$inq_locale (msg = &temp_msg,
                   var = &var_list,
                   flags = EX_Text | EX_Logical_Name,
                   identifier = (IGRchar *)fontfile);

    if (temp_msg & 1)
    {
        /*
         * set the font_flags according to the flags from the font_table;
         * this overrides the font_flags that is sent in
         */

        if (font_parameters.properties & EX_Text_Font)
        {
           font_flags = TEXT_FONT;
        }
        else if (font_parameters.properties & EX_Frac_Font)
        {
           font_flags = FRACTION_FONT;
        }
        else
        {
           font_flags = SYMBOL_FONT;
        }

        if (font_parameters.properties & EX_Sixteen_Bit)
        {
           font_flags |= SIXTEEN_BIT;
        }
        else if (font_parameters.properties & EX_Eight_Bit)
        {
           font_flags |= EIGHT_BIT;
        }

        /*
         * if a font file was provided, read the font in; otherwise
         * download the font
         */

        if (strlen(font_parameters.ff))
        {
           if (fe$read_font(msg = &temp_msg,
                            fontfile = font_parameters.ff,
                            font_id = &font_id))
           {
              font_read = TRUE;
           }
           else
           {
#ifdef DEBUG
              printf("error in GRfm.GRmake_entry: could not read %s\n Now trying to create font from typeface\n",font_parameters.ff);
#endif
           }
        }

        if (!font_read)
        {
           /*
            * either locale had no fontfile or error in reading fontfile;
            * set the font flags according to the flags from the font_table
            */

           if (font_parameters.properties & EX_Bitmap_Font)
           {
              FS_flags = 0;
           }
           else  /* outline font */
           {
              FS_flags = FS_OUTLINE | FS_3D;
           }

           if (font_parameters.properties & EX_Demand_Font)
           {
              FS_flags |= FS_DEMAND;
           }

           if (font_parameters.properties & EX_Sixteen_Bit)
           {
              FS_flags |= FS_SHARED;
           }

           if (font_parameters.body_size != 0)
           {
              /*
               *  Call the font executive (FE) to download this font.
               *  If it has already been downloaded, the font id
               *  will be returned.
               */

              if (!(fe$add_font(msg = &temp_msg,
                                typeface = font_parameters.tf,
                                bodysize = (IGRdouble) font_parameters.body_size,
                                charmap = font_parameters.cm,
                                flags = FS_flags,
                                font_id = &font_id)))
              {

		 if ((FS_flags & FS_SHARED)&&(font_parameters.properties & EX_Sixteen_Bit))
		 { 
		    /* If sixteen bit font, try to load again non-sharable */

		    if (0>=(fe$add_font(msg = &temp_msg,
				      typeface = font_parameters.tf,
				      bodysize = (IGRdouble) font_parameters.body_size,
				      charmap = font_parameters.cm,
				      flags = (FS_flags&~FS_SHARED),
				      font_id = &font_id)))
		     {
		        *msg = temp_msg;
#ifdef DEBUG
                 printf("error in GRfm.GRmake_entry: could not create %s\n",font_parameters.tf);
#endif
			goto FINISH;
		     }
		  }
		  else
		  {
		     *msg = temp_msg;
		     goto FINISH;
		  }
              }
           }
           else     /* no bodysize specified; use default bodysize */
           {
              /*
               *  Call the font executive (FE) to download this font.
               *  If it has already been downloaded, the font id
               *  will be returned.
               */

              if (!(fe$add_font(msg = &temp_msg,
                                typeface = font_parameters.tf,
                                charmap = font_parameters.cm,
                                flags = FS_flags,
                                font_id = &font_id)))
              {
                 *msg = temp_msg;
#ifdef DEBUG
                 printf("error in GRfm.GRmake_entry: could not create %s\n",font_parameters.tf);
#endif
                 goto FINISH;
              }
           }
        }

        /*
         * add an entry to the Font Manager if necessary
         */

        if (*vfont_num == me^^GRfm.num_entries)     /* no empty entries */
        {
            ++me^^GRfm.num_entries;
            OM_SET_DIMENSION(me^^GRfm.vfont,(IGRint)me^^GRfm.num_entries);
        }

        /*
         *  Initializing instance data for the new font. 
         */

        FSGetOutlInfo (font_id, &outlinfo);

        me^^GRfm.vfont[*vfont_num].fontid = font_id;
        me^^GRfm.vfont[*vfont_num].descent = outlinfo.descent;
        me^^GRfm.vfont[*vfont_num].bodysize = outlinfo.bodySize;
        strcpy((char *)(me^^GRfm.vfont[*vfont_num].fontfile),
               (char *)fontfile);
        strcpy((char *)(me^^GRfm.vfont[*vfont_num].vfontname),
               (char *)vfont_name);
        me^^GRfm.vfont[*vfont_num].def_flag = defined;
        me^^GRfm.vfont[*vfont_num].flags = font_flags;
     
        if (outlinfo.fontFlags & FS_FILLABLE_FONT)
        {
           me^^GRfm.vfont[*vfont_num].flags |= FILLABLE_FONT;
        }

        mod_id.osnum = OM_Gw_current_OS;
        ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mod_id.objid);


        OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRmodule.GRadd_fnt(&temp_msg,*vfont_num,
                                    font_id,outlinfo.bodySize,outlinfo.descent,
                                    (IGRint)me^^GRfm.vfont[*vfont_num].flags),
                        senderid = my_id,
                        targetid = mod_id.objid);

        if (COERROR(OMmsg))
        {
            *msg = MSFAIL;
            OMmsg = OM_E_ABORT;
        }
        else if (COERROR(temp_msg))
        {
            *msg = MSFAIL;
        }
    }
    else  /* ex$inq_locale failed; could not load font */
    {
        *msg = MSFAIL;
    }

FINISH:

    return(OMmsg);
}

end implementation GRfm;
