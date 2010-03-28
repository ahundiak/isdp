        /*
         *
         *  This set of macros contains text related functions. 
         *  This include file is dependent on the following 
         *  include files:
         *
         */


#ifndef cotxmacros_include
#define cotxmacros_include

#include "grdpbdef.h"
#include "grdpb.h"


/*--------------------------- co$place_text  ---------------------------------

Abstract: This macro will either construct and display a text object or just
display a text string. The buffer argument determines whether to construct
or just display. The default is display only. This macro will pick up the
active DPB parameters and use them in constructing and/or displaying the text
unless the parameter is passed to the macro, in which case the passed in 
parameter will be used. Empty text objects may be placed by setting the
appropriate bit in the flags argument. A cross is displayed at the origin of
the empty text object (the size of the cross is determined by text height and
width). If a text string is passed in, it will also be displayed and it will
be the "name" of the empty text object (i.e. the text string and objid of the
empty text object will be stored in the directory subsystem).

Arguments:

*msg            IGRlong                  return code
                                         - MSSUCC      if successful
                                         - MSFAIL      if failure

*text_string    IGRuchar         array of characters making up the text
                                         string; this includes any escape
                                         sequences

*text_length    IGRshort                 number of bytes in the text string

origin          IGRpoint                 placement point of the text string

rot_matrix      IGRmatrix                view rotation matrix of view text is
                                         to be placed in 
                                         NOTE:  this should be an identity
                                         matrix if placing view rotation
                                         independent text

lbs_matrix      IGRmatrix                local bounded system matrix; this can
                                         be specified instead of the rot_matrix
                                         if you want to place text at the same
                                         orientation as that of an existing
                                         text element (you can send the message
                                         GRvg.GRgetgeom to get an IGRlbsys
                                         structure from a text element)
                                         NOTE:  if this argument is specified,
                                         the ActiveAngle argument will be
                                         ignored

*DatabaseType   IGRchar                  type of database; defaults to active
                                         database

*ActiveDisplay  struct IGRdisplay        color and weight to display the text
                                         string (line style is always solid
                                         for text); defaults to the active
                                         display parameters

ActiveLevel     IGRshort                 level to place text on; defaults to
                                         the active level

*Properties     IGRushort        the object's graphic properties
                                         (e.g. displayable, locatable, etc.);
                                         defaults to the active properties;
                                         #defines for these properties can be
                                         found in godef.h
                                         NOTE:  setting the GRFILLED_DISPLAY
                                         bit will NOT result in the text being
                                         filled - the appropriate bit in the
                                         TextSymb structure below must be set

*ModuleInfo     struct GRmd_env          module environment; defaults to the
                                         active text parameters

*TextSymb       struct GRdpb_text_symb   font, justification, height, width,
                                         character spacing, line spacing;
                                         defaults to the active text parameters
                                         NOTE:  to place filled text, the
                                         GRTX_FILLED bit must be set in the
                                         Active_flags member of this structure
                                         (#defines for flags in gotextdef.h)

ActiveAngle     IGRdouble                angle to place text (in radians);
                                         defaults to the active angle

mode            GRdpmode                 display mode; defaults to draw in
                                         background

objid           GRobjid                  object id of window to display text
                                         in; defaults to all windows

flags           IGRint                   miscellaneous flags
                                         (defined in gotextdef.h):
                                         bit 0: 1 - display constructed object,
                                                0 - do not display object
                                         bit 1: 1 - place an empty text object,
                                                0 - place a non-empty text
                                                    object
                                                    (this bit is only relevant
                                                    if constructing a text
                                                    object)
                                         bit 2 - 31: reserved

*buffer         struct GRid              object id and os number of text
                                         object; must be specified if text 
                                         string is to be constructed; defaults
                                         to display only

*classname      IGRchar                  type of class to create; must be a
                                         subclass of text; defaults to GR3dtext

-----------------------------------------------------------------------------*/

#omdef  co$place_text
                (  msg,
                   text_string,
                   text_length,
                   origin,
                   rot_matrix = NULL ^
                   lbs_matrix = NULL,
                   DatabaseType = NULL,
                   ActiveDisplay = NULL,
                   ActiveLevel = -1,
                   Properties = NULL,
                   ModuleInfo = NULL,
                   TextSymb = NULL,
                   ActiveAngle = 0.0,
                   mode = GRbd,
                   objid = NULL_OBJID,
                   flags = 1,
                   buffer = NULL,
                   classname = NULL)

#if !om$specified(ActiveAngle) && om$specified(rot_matrix)

  GRang_place_text(msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                   DatabaseType,classname,ActiveDisplay,ActiveLevel,
                   Properties,ModuleInfo,TextSymb,mode,objid,flags,buffer)

#else
  GRplace_text(msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
               DatabaseType,classname,ActiveDisplay,ActiveLevel,Properties,
               ModuleInfo,TextSymb,ActiveAngle,mode,objid,flags,buffer)
  
#endif

#endomdef


/*--------------------------- co$rm_esc_seqs ----------------------------------

Abstract:  This macro removes all escape sequences from a text string.  When a
text object is placed, justification escape sequences may be inserted into the
text string.  It is also possible to place text strings with other types of
escape sequences (e.g. change size, color, etc.).  When the message GRgettxattr
is sent to a text object to get its text string, the text string may contain
escape sequences.  This macro will remove those escape sequences.

Arguments:

*msg            IGRlong                  return code
                                         - MSSUCC      if successful
                                         - MSFAIL      if failure

font_num        IGRshort                 font the text string was placed with

font_flags      IGRint                   information about the text_font; this
                                         is the "flags" member of the font_info
                                         structure returned by the macro
                                         font$get_info (in fontmacros.h)

*text_string    IGRuchar         array of characters making up the text
                                         string; this includes any escape
                                         sequences; the escape sequences will
                                         be removed from this string

*text_length    IGRshort                 number of bytes in the text string;
                                         the text length of the string with
                                         the escape sequences removed will
                                         be returned

-----------------------------------------------------------------------------*/

#omdef  co$rm_esc_seqs
                  (msg,
                   font_num,
                   font_flags,
                   text_string,
                   text_length)

  GRstrip_esc_sequences((msg),(-1),(font_num),(font_flags),
                        (text_string),(text_length))

#endomdef

#endif
