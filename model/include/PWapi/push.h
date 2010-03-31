#ifndef _push_proto_h 
#define _push_proto_h

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

extern PWresult   pwPushCoincEdges _PW_((
  struct EMSinters **pp_inters,
  struct EMSintobj *p_intcv,
  double           xyztol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
