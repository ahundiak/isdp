#ifndef _rdminim_proto_h 
#define _rdminim_proto_h

#if defined(__STDC__) || defined(__cplusplus) 
#ifndef _PW_ 
#define _PW_(args) args 
#endif 
#else 
#ifndef _PW_ 
#define _PW_(args) () 
#endif 
#endif 

#if defined(__cplusplus) 
extern "C" 
{ 
#endif

extern PWboolean pwReadPt2d  _PW_((
  FILE *file,
  PWpoint2d pt
));

extern PWboolean pwReadPt  _PW_((
  FILE *file,
  PWpoint pt
));

extern PWboolean pwReadId _PW_(( 
  FILE *file,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
));

extern PWboolean pwReadIdFromString _PW_((
  char *line,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
