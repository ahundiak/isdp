#ifndef _cvdisp_proto_h 
#define _cvdisp_proto_h

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

extern PWresult pwDisplayCv _PW_((
  struct IGRbsp_curve *cv,
  enum PWdisplaymode dpmode
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
