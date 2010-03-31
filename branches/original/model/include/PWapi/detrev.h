#ifndef _detrev_proto_h 
#define _detrev_proto_h

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

extern PWboolean  pwDetIntReversal _PW_((
  PWobjid             coinc_ed,
  struct EMSintobj    *intobj,
  double              uvtol
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
