#ifndef _dotp_proto_h 
#define _dotp_proto_h

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

extern enum PWrelvectype pwDotLenTol2d  _PW_((
  PWvector2d v1,
  PWvector2d v2,
  double tol,
  double *val
));

extern enum PWrelvectype pwDotLenTol  _PW_((
  PWvector v1,
  PWvector v2,
  double tol,
  double *val
));

extern double pwDot2d _PW_((
  PWvector2d v1,
  PWvector2d v2
));

extern double pwDot _PW_((
  PWvector v1,
  PWvector v2
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
