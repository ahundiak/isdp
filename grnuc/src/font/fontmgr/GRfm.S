/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP%  CODE CLASSIFICATION                           
----
%HD%

      CLASS NAME:     GRfm
      SUBCLASS OF:    global_class

-----
%CD%

      CHANNELS DECLARED:  none
-----
%MD%

      MESSAGES DECLARED:  GRclean_up
                          GRfm_ret_id
                          GRmake_entry
                          GRvirt_search
                          GRphy_search
                          GRisitfnt

      METHODS OVERRIDDEN: delete
                          sleep
                          super_construct
                          wake_up
-----
%NB%

      NOTES:
-----
%CH%

      CHANGE HISTORY:
                       DEK  11/02/87:   Design date.
                       DEK  11/02/87:   Creation date.
                       DEK  04/13/88:   Added new instance data for fraction
                                        fonts and symbol fonts.
-----
%PD%
--------------------------------------------------------------------
                 C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

    The class GRfm is a subclass of global_class and is a collection
of the fonts for a module space.
----*/
/*EH*/

class specification GRfm (1:1) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"

instance GRfm
{
      IGRshort            fast_font;         /* seven/eight bit fast font  */
      IGRshort            frac_fast_font;    /* fraction fast font         */
      IGRshort            symb_fast_font;    /* symbol fast font           */
      IGRshort            sixteen_fast_font; /* sixteen bit char fast font */
      IGRshort            num_entries;       /* # of virtual font entries  */
      IGRshort            flags;
      variable struct vfont_entry  vfont[];  /* virtual font entries       */
};

/*
Abstract
     This routine downloads a specified font.  If the specified 
     font is found and successfully downloaded, an entry is made
     in the font manager table with the name of the font file
     and the virtual font name of the downloaded font. The 
     virtual font number will be returned if it was not specified
     on entry (it must be set to -1 on entry if not specified).


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *fontfile     IGRuchar  font file specification
    *vfont_name   IGRuchar  virtual font name
    font_flags    IGRint            flag telling what type of font
    *vfont_num    IGRshort          virtual font number (should be set
                                    to -1 if not specified)

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC         - if successful
                                      MSFAIL         - if failure
                                      GR_E_MxNoFtLdd - if local list is full
*/

message GRmake_entry     (IGRlong *msg; IGRuchar *fontfile; 
                          IGRuchar *vfont_name; IGRint font_flags;
                          IGRshort *vfont_num);

/*
Abstract
     This routine searches the virtual font library for a specified
     virtual font name or number and returns the name or position 
     of the virtual font.  If searching for the virtual font number,
     the virtual font number should be set to -1 on entry.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *vfont_name    IGRuchar  virtual font name
    *vfont_number  IGRshort          virtual font number

OUTPUT

    *msg           IGRlong           completion code
                                       MSSUCC  - if successful
                                       MSFAIL  - if failure (font not found)
                                       MSINARG - if invalid virtual font number
    *vfont_name    IGRuchar  virtual font name
    *vfont_number  IGRshort          virtual font number
*/

message GRvirt_search    (IGRlong *msg; IGRuchar *vfont_name;
                          IGRshort *position);

/*
Abstract
     This routine searches the virtual font library for a
     specified physical font. If the specified font is found,
     its virtual font name will be returned.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *fontfile     IGRuchar  font file name

OUTPUT

    *msg          IGRlong            completion code
                                       MSSUCC  - if successful
                                       MSFAIL  - if failure (font not found)
    *vfont_name   IGRuchar   virtual font name
*/

message GRphy_search     (IGRlong *msg; IGRuchar *fontfile;
                          IGRuchar *vfont_name);

/*
Abstract
     This routine restores the memory a font is using.  
     If only one font manager is using the font, the font
     is taken offline and deleted from the cache.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *position      IGRshort          virtual font number

OUTPUT

    *msg           IGRlong           completion code
                                       MSSUCC   - if successful
                                       MSFAIL   - if failure
*/

message GRclean_up       (IGRlong *msg; IGRshort *position);

/*
Abstract
     This routine deletes a specified font.  The fast character
     font and the fast fraction font will not be deleted. The 
     font entry's def_flag is set to undefined and the font file
     name and the virtual font name are set to NULL. If this is
     the only font manager using the font, the font is taken 
     offline and deleted from the cache.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *position     IGRshort          virtual font number

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC  - if successful
                                      MSFAIL  - if failure
                                      MSINARG - if attempting to delete
                                                the fast font
*/

message GRclear_entry    (IGRlong *msg; IGRshort *position);

/*
Abstract
     This routine returns the instance data contained
     in the virtual font entry of the requested font.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *vfont_num    IGRshort            virtual font number

OUTPUT

    *msg          IGRlong             completion code
                                        MSSUCC   - if successful
                                        MSFAIL   - if failure
    *vfont        struct vfont_entry  instance data of virtual font entry
*/

message GRfm_retdata     (IGRlong *msg; IGRshort *vfont_num;
                          struct vfont_entry *vfont);

/*
Abstract
     This routine sets either the fast character font to 
     the specified (virtual) font or the fast fraction font to
     the specified (virtual) font.  All the undefined fonts'
     font ids will point to the new fast font.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *vfont_num    IGRshort          virtual font number
    type          IGRchar           type of font - TEXT or FRACTION

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC   - if successful
                                      MSFAIL   - if failure
*/

message GRset_fast_fnt   (IGRlong *msg; IGRshort *vfont_num; IGRchar type);

/*
Abstract
     This method determines if the specified font is a fast font.
     If it is the character fast font a 1 is returned in type; if
     it is the fraction fast font a 2 is returned in type. Otherwise
     a 0 is returned in type. If a fast font is found, the return
     message is MSSUCC.  If not, it's MSFAIL.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *vfont_num    IGRshort          virtual font number

OUTPUT

    *type         IGRshort          type of fast font
    *msg          IGRlong           completion code
                                      MSSUCC   - if successful
                                      MSFAIL   - if failure
*/

message GRisitfstfnt     (IGRlong *msg; IGRshort *vfont_num; IGRshort *type);

/*
Abstract
     This routine searches the virtual font library for a
     specified physical font. If the specified font is found,
     its virtual font number will be returned.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    *fontfile     IGRuchar  font file name

OUTPUT

    *msg           IGRlong        completion code
                                    MSSUCC  - if successful
                                    MSFAIL  - if failure (font not found)
    *vfont_name    IGRshort       virtual font number
*/

message GRduplicate_font (IGRlong *msg; IGRuchar *fontfile;
                          IGRshort *vfontnum);

/*
Abstract
     This routine returns the number of defined font
     entries and a list of which ones they are.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

OUTPUT

     *msg           IGRlong          completion code
                                       MSSUCC   - if successful
                                       MSFAIL   - if failure
     *num_entries   IGRshort         number of defined entries in font mgr
     *entries       IGRshort         array of entries that are defined
*/

message GRfm_get_entries (IGRlong *msg; IGRshort *num_entries; 
                          IGRshort *entries);

/*
Abstract
     This routine updates the virtual font name of the
     specified entry.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

INPUT

    entry_number  IGRshort          virtual font number
    *new_name     IGRchar           new name for virtual font name

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC   - if successful
                                      MSFAIL   - if failure
*/

message GRupd_vfont_name (IGRlong *msg; IGRshort entry_number;
                          IGRchar *new_name);

override  wake_up,sleep,delete,super_construct;

end specification GRfm;
