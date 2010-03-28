#ifndef  font_include
#define  font_include

/*
 * this include file is dependent on fontdef.h, igrtypedef.h 
 * and igetypedef.h
 */

enum   GRfntdef   {defined,undefined,reserved};

struct vfont_entry {
   IGRuchar	       fontfile[PATH_LEN];
   IGRuchar 	       vfontname[FONT_NAME];
   IGRint              fontid;
   IGRdouble           bodysize;
   IGRdouble           descent;
   IGRint              flags;               /* bit 0 - set if character font;
                                               bit 1 - set if fraction font;
                                               bit 2 - set if symbol font;
                                               bit 3 - clear if 7 bit font
                                                       set if 16 bit font    */
   enum GRfntdef   def_flag;
   };

struct fm_entry {
   IGRuchar     	     filespec[PATH_LEN];
   IGRuchar	             vfontname[FONT_NAME];
   };

struct FM_construct {
   IGRlong           msg;
   IGRboolean        newflag;
   IGRuchar	     name[32];
   GRobjid           mod_id;
   };

#endif
