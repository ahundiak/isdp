    /*
     *  This set of macros defines the user interface to the 
     *  font subsystem.  This include file is dependent on 
     *  the following include file:
     */


#ifndef fontmacros_include
#define fontmacros_include

#include "fontdef.h"
#include "font.h"


/*--------------------------- font$retrieve ---------------------------------

Abstract:    This macro will load a specified font.  The index of the font's
             position in the font manager will be returned.

Arguments:

    *msg             IGRlong      return code
                                    - MSSUCC           if successful
                                    - MSFAIL (severe)  if failure
                                    - GR_E_MxNoFtLdd   if maximum number of
                                                       fonts have been loaded
                                    - GR_E_FtNotFnd    font not found
                                    - GR_E_FtNmeLdd    font name isn't unique
                                    - GR_E_FtLdd       font already loaded

    *font            IGRuchar name of font to load

    *local_font_name IGRuchar local font name for the loaded font

    font_flags       IGRshort     flag identifying what type of font
                                  (see flags member of vfont_entry structure
                                   in font.h and #defines in fontdef.h --
                                   TEXT or FRACTION / SEVEN or SIXTEEN)

    *fontmgr         struct GRid  font manager's objid and osnum; if a NULL
                                  pointer is sent in the font manager in the
                                  current module is used; if retrieving a
                                  font into a different font manager, specify
                                  the osnum and if the object id is not know,
                                  set objid to NULL_OBJID and it will be
                                  returned so it can be used in subsequent
                                  calls, and the font will be added to the
                                  desired font manager

    *font_position   IGRshort     position (index) into which the font
                                  was loaded into the font manager
-----------------------------------------------------------------------------*/

#omdef  font$retrieve(msg,
                      font,
                      local_font_name,
                      font_flags = 0x01,   /* 7 bit text font (nonfillable) */
                      fontmgr = NULL,
                      font_position)

  GRretrieve_font(msg,
                  font,
                  local_font_name,
                  font_flags,
                  fontmgr,
                  font_position)

#endomdef

/*--------------------------- font$get_info ---------------------------------

Abstract:    This macro will return information about the specified font.
             If the font manager's id is known, it should be passed in.

Arguments:

    *msg          IGRlong            return code
                                       - MSSUCC          if successful
                                       - MSINARG         if invalid font number
                                       - MSFAIL (severe) if failure

    *font_num     IGRshort           font number of the font for which
                                     information is being requested

    *fontmgr      struct GRid        font manager's objid and osnum; if a NULL
                                     pointer is sent in the font manager in the
                                     current module is used; if inquiring
                                     information about a font in a different
                                     font manager, specify the osnum and if
                                     the object id is not know, set objid to
                                     NULL_OBJID and it will be returned so it
                                     can be used in subsequent calls

    *font_info    struct vfont_entry font information

-----------------------------------------------------------------------------*/

#omdef  font$get_info(msg,
                      font_num,
                      fontmgr = NULL,
                      font_info)

  GRget_font_info(msg,
                  font_num,
                  fontmgr,
                  font_info)

#endomdef

#endif
