#ifndef _magvec_proto_h 
#define _magvec_proto_h

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

extern double pwLenVec2d  _PW_((
  PWvector2d vec
));

extern double pwLenVec _PW_((
  PWvector vec
));

extern double pwLenSqVec2d _PW_((
  PWvector2d vec
));

extern double pwLenSqVec _PW_((
  PWvector vec
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
