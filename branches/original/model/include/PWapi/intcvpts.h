#ifndef _intcvpts_proto_h 
#define _intcvpts_proto_h

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

extern PWresult pwGetInternalCvPts _PW_((
  struct PWcvdata     *p_cv,
  int                 numpts,
  enum PWtopopostype  topopos,
  struct PWcvpt       *p_internalpts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
