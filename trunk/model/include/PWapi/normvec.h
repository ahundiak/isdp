#ifndef _normvec_proto_h 
#define _normvec_proto_h

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

extern PWresult pwNormVec2d  _PW_((
  PWvector2d vec,
  PWvector2d nvec
));

extern PWresult pwNormVec  _PW_((
  PWvector vec,
  PWvector nvec
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
