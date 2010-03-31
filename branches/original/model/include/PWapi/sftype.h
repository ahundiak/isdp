#ifndef _sftype_proto_h 
#define _sftype_proto_h

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

extern PWboolean pwIsSurface _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsCompSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsSolid _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern PWboolean pwIsSimpleSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern short pwSfType  _PW_((
  PWobjid sfobj,
  PWosnum sfos
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
