#ifndef _revvec_proto_h 
#define _revvec_proto_h

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

extern void pwRevVec2d _PW_((
  PWvector2d vec,
  PWvector2d outvec
));

extern void pwRevVec _PW_((
  PWvector vec,
  PWvector outvec
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
