#ifndef _mkvec_proto_h 
#define _mkvec_proto_h

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

extern void pwMakeVec  _PW_((
  PWpoint   frompt,
  PWpoint   topt,
  PWvector  vec
));

extern void pwMakeVec2d _PW_((
  PWpoint2d   frompt,
  PWpoint2d   topt,
  PWvector2d  vec
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
