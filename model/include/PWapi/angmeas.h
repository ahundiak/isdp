#ifndef _angmeas_proto_h 
#define _angmeas_proto_h

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

extern double pwAngmeas2d  _PW_((
  PWvector2d nvec1, 
  PWvector2d nvec2
));

extern double pwAngmeas  _PW_((
  PWvector nvec1, 
  PWvector nvec2,
  double *dirvec
));

extern double pwGetAngFromAngmeas  _PW_((
  double angmeas
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
