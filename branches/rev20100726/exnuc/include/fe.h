#ifndef  fontexec_include
#define  fontexec_include

/*
 * this include file is dependent on fontexecdef.h, igrtypedef.h 
 * igetypedef.h, FS.h
 */

struct fontexec_entry {
   IGRchar         typeface[PATH_LENGTH];
   Real64          bodysize;
   Real64          aspect;
   Real64          rotation;
   Real64          slant;
   IGRchar         charmap[PATH_LENGTH];
   Int32           flags;
   IGRshort        rangecount;
   RangeSpec       *rangespec;
   IGRshort        times_used;
   FontId          font_id;
   };

struct fontexec_file {
   IGRchar         fontfile[PATH_LENGTH];
   IGRshort        times_used;
   FontId          font_id;
   };

#endif
