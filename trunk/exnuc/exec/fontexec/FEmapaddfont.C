/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             FEmap_add_font
 
     Abstract:  This routine creates a default ascii character
                mapping that is to be used when creating a font.
                After the mapping is created, FEadd_font is called
                to actually construct the font.
-----
%SC%

  VALUE = FEmap_add_font(msg,typeface,bodysize,aspect,rotation,slant,
                         flags,rangecount,rangespec,font_id)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *typeface     char              typeface file used to create font
    bodysize      real64            bodysize; lines per em square
    aspect        real64            aspect ratio
    rotation      real64            ccw rotation angle
    slant         real64            ccw slant
    flags         int32             font specification flags 
    rangecount    IGRshort          number of ranges of characters
    *rangespec    RangeSpec         range of characters to generate
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
    ----------     --------------- -----------------------------------------
    *msg           IGRlong         completion code
    *font_id       FontId          identifies which font has been created
-----
%MD%

     MODULES INVOKED:   FEadd_font

-----
%RL%

      RELATIONS REFERENCED:  none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  04/01/88 : Design date.
        DEK  04/01/88 : Creation date.
        DEK  04/19/88 : Added rangespec capability.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
FEmap_add_font
 
  This routine creates a default ascii character mapping that is to
be used when creating a font.  After the mapping is created, 
FEadd_font is called to actually construct the font.

----*/
/*EH*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "FS.h"
#include "fedef.h"
#include "OMprimitives.h"

IGRboolean FEmap_add_font(msg,typeface,bodysize,aspect,rotation,slant,
                          flags,rangecount,rangespec,font_id)

IGRlong             *msg;            /* completion code                 */
char                *typeface;       /* typeface used to create font    */
Real64              bodysize;        /* bodysize; lines per em square   */
Real64              aspect;          /* aspect ratio                    */
Real64              rotation;        /* ccw rotation of characters      */
Real64              slant;           /* ccw slant                       */
Int32               flags;           /* misc font specification flags   */
IGRshort            rangecount;      /* number of ranges of characters  *?
RangeSpec           *rangespec;      /* range of characters to generate */
FontId              *font_id;        /* identifies font                 */
{
   extern IGRboolean FEadd_font();

   IGRchar          charmap[PATH_LENGTH]; /* character mapping            */
   IGRboolean       value;

   value = FALSE;
   *msg = MSSUCC;

   strcpy (charmap,"/usr/ip32/FS/charmap/defmap.cm");

   if (FEadd_font(msg,typeface,bodysize,aspect,rotation,slant,charmap,
                  flags,rangecount,rangespec,font_id))
   {
      value = TRUE;
   }

   return(value);
}
