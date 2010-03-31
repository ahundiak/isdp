#ifndef _crossp_proto_h 
#define _crossp_proto_h

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

extern enum PWdirtype pwCrossProd2d  _PW_((
  PWvector2d vec1, 
  PWvector2d vec2,
  double tol, 
  double *val
));

extern enum PWdirtype pwCrossProd  _PW_((
  PWvector vec1,
  PWvector vec2,
  double tol,
  double *val
));

extern enum PWdirtype pwCrossProdAngTol2d  _PW_((
  PWvector2d vec1,
  PWvector2d vec2,
  double atol,
  double *val
));

extern enum PWdirtype pwCrossProdAngTol  _PW_((
  PWvector vec1,
  PWvector vec2,
  double atol,
  double *val
));

extern double pwCross2d _PW_((
  PWvector2d v1,
  PWvector2d v2
));

extern void pwCross _PW_((
  PWvector v1,
  PWvector v2,
  PWvector cv
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
