/* #######################    APOGEE COMPILED   ######################## */





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

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             GRisitfnt
 
     Abstract:

               This routine determines whether a given logical font name
               corresponds to a typeface file recognized by the fontserver.
-----
%SC%

  VALUE = GRisitfnt(msg,font_file,num_chars,typeface)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *msg          IGRlong           completion code
    *font_file    IGRuchar          font file name (logical name in 
                                    font_table)
    *num_chars    IGRint            number of characters in font_file
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     --------------- -----------------------------------------
     *typeface      IGRchar         typeface file name corresponding to the
                                    given logical name (should have at least
                                    15 bytes allocated); a NULL pointer may
                                    be passed in if the typeface name is not
                                    wanted

     VALUE (IGRlong) =    MSSUCC    - if successful (file is a font)
                          MSFAIL    - if failure (file is not a font)
-----
%MD%

     MODULES INVOKED:

     modules:
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
        DEK  06/02/88 : Incorporate use of locale.
        WBC  07/12/89 : Incorporate use of FSGettypefaces.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine determines whether a given logical font name
corresponds to a typeface file recognized by the fontserver.
----*/
/*EH*/

#include  "grimport.h"
#include  "OMminimum.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "fontdef.h"
#include  "msdef.h"
#include  "exdef.h"
#include  "ex.h"
#include  "exmacros.h"
#include  "exlocaledef.h"
#include  "exlocale.h"
#include  <stdio.h>
#include  "fedef.h"
#include  "FS.h"
#include  "FSTypeface.h"

IGRboolean GRisitfnt(msg,font_file,num_chars,typeface)

IGRlong             *msg;
IGRuchar            *font_file;
IGRint              *num_chars;
IGRchar             *typeface;
{
    IGRint                i;               /* index counter              */
    IGRboolean            value;           /* functional return value    */
    struct EX_fonts       font_parameters; /* locale typeface parameters */
    struct EX_locale_var  var_list;        /* locale identifiers         */
    TFInfo                tf_info;         /* typeface information       */

    *msg = MSSUCC;
    value = TRUE;

    /*
     *  find position of first non-blank character in font_file
     */

    for (i = 0; i < *num_chars; ++i)
    {
        if (font_file[i] != BLANK)
        {
            break;
        }
    }

    if (i == *num_chars)  /* only a carriage return was entered */
    {
        value = FALSE;
    }
    else         /* user keyed in logical name */
    {
        var_list.var = EX_font_parameters;
        var_list.var_ptr = (char *)&font_parameters;

        ex$inq_locale(msg = msg,
                      var = &var_list,
                      flags = EX_Text | EX_Logical_Name,
                      identifier = (char *)font_file);

        if (*msg == EX_Font_Not_Found)
        {
            value = FALSE;
        }
        else
        {
            /*
             * check to see if the typeface exists
             */

            if (FSGetTFInfo(font_parameters.tf,&tf_info))
            {
                value = FALSE;
            }
            else  /* copy the typeface file name into the output variable */
            {
                if (typeface)
                {
                    strcpy(typeface,font_parameters.tf);
                }
            }
        }
    }
    return(value);
}
