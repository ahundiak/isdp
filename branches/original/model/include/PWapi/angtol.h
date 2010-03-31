#ifndef _angtol_proto_h 
#define _angtol_proto_h

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

extern double pwGetZeroAngTolDeg _PW_((
));

extern double pwGetZeroAngTolRad _PW_((
));

extern void pwSetZeroAngTolDeg  _PW_((
  double angtol
));

extern void pwSetZeroAngTolRad  _PW_((
  double angtol
));

extern double pwGetCosZeroAngTol _PW_((
));

extern double pwGetSinZeroAngTol _PW_((
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
