#ifndef _degenint_proto_h 
#define _degenint_proto_h

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

extern PWresult pwOrientDegenInt _PW_((
  struct EMSinters  **p_inters,
  double            xyztol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
