#ifndef _partol_proto_h 
#define _partol_proto_h

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

extern double pwGetParTolCv  _PW_((
  struct IGRbsp_curve *cv,
  double xyztol
));

extern double pwGetParTolSf  _PW_((
  struct IGRbsp_surface *sf,
  double xyztol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
