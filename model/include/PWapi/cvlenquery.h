#ifndef _cvlenquery_proto_h 
#define _cvlenquery_proto_h

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

extern double pwCvdataLen _PW_((
  struct PWcvdata *cvdata
));

extern void pwParAtCvdataLen _PW_((
  struct PWcvdata *cvdata,
  double length_along,
  struct PWcvparam *cvpar
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
