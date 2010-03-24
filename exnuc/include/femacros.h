




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

        /*
         *
         *  This set of macros contains Font Executive related
         *  functions. This include file is dependent on the 
         *  following include files:
         *
         */


#ifndef fontexecmac_include
#define fontexecmac_include

/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRboolean FEadd_font __((IGRlong *msg, char *typeface, Real64 bodysize,
			Real64 aspect, Real64 rotation, Real64 slant,
			char *charmap, Int32 flags, IGRshort rangecount,
			RangeSpec *rangespec, FontId *font_id));
extern IGRboolean FEmap_add_font __((IGRlong *msg, char *typeface,
			Real64 bodysize, Real64 aspect, Real64 rotation,
			Real64 slant, Int32 flags, IGRshort rangecount,
			int rangespec, FontId *font_id));
extern IGRboolean FEread_font __((IGRlong *msg, char *fontfile,
			FontId *font_id));
extern IGRboolean FErm_font __((IGRlong *msg, FontId font_id));

#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

/*--------------------------- fe$add_font  ---------------------------------

Abstract: This macro will retrieve a font from the given typeface file. If
          the font parameters are not passed in defaults will be used. If
          the font does not already exist, it will be created and put into
          memory. Its font id will be returned. If the font already exists,
          its font id will simply be returned.

Arguments:

*msg            IGRlong                  return code
                                         - MSSUCC      if successful
                                         - MSFAIL      if failure

*typeface       IGRchar                  typeface file to use in creating font

bodysize        IGRdouble                bodysize; lines per em square
                                         (defaults to 24)

aspect          IGRdouble                aspect ratio (defaults to 1)

rotation        IGRdouble                ccw rotation angle of characters
                                         (defaults to 0)

slant           IGRdouble                ccw slant or obliquing angle
                                         (defaults to 0)

*charmap        IGRchar                  character mapping file including
                                         full path name (defaults to old
                                         IGDS character mapping)

flags           IGRint                   font specification flags
                                         (defaults to 3d outline fonts)

rangecount      IGRshort                 number of ranges in the range
                                         specification; must be defined
                                         if rangespec is to be used

*rangespec      RangeSpec                specific range of characters to
                                         generate (defaults to all
                                         characters in mapping)

*font_id        FontId                   font identifier

----------------------------- fe$rm_font  ---------------------------------

Abstract: This macro will remove a font from memory. If the font is being 
          used by others it will not be deleted; the times used counter will
          simply be decremented. 

Arguments:

*msg            IGRlong                  return code
                                         - MSSUCC      if successful
                                         - MSFAIL      if failure

*font_id        FontId                   font identifier

/*--------------------------- fe$read_font  ---------------------------------

Abstract: This macro will read a font from the given font file. Its font id
          will be returned.

Arguments:

*msg            IGRlong                  return code
                                         - MSSUCC      if successful
                                         - MSFAIL      if failure

*fontfile       IGRchar                  file to use when reading font

*font_id        FontId                   font identifier
-----------------------------------------------------------------------------*/

#omdef  fe$add_font
                (  msg,
                   typeface,
                   bodysize = 24.0,
                   aspect = 1.0,
                   rotation = 0.0,
                   slant = 0.0,
                   charmap = NULL,
                   flags = FS_OUTLINE | FS_3D | FS_DEMAND,
                   rangecount = 0,
                   rangespec = NULL,
                   font_id)


#if !om$specified(charmap)

  FEmap_add_font(msg,typeface,bodysize,aspect,rotation,slant,flags,
                 rangecount,rangespec,font_id)

#else    

  FEadd_font(msg,typeface,bodysize,aspect,rotation,slant,charmap,flags,
             rangecount,rangespec,font_id)
  
#endif

#endomdef

#omdef  fe$rm_font
               (  msg,
                  font_id)

  FErm_font(msg,font_id)
  
#endomdef

#omdef  fe$read_font
               (
                  msg,
                  fontfile,
                  font_id)

  FEread_font(msg,fontfile,font_id)

#endomdef

#endif
