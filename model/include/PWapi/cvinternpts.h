#ifndef _cvinternpts_proto_h 
#define _cvinternpts_proto_h

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

extern PWresult pwGetCvdataInternalPts _PW_((
  struct PWcvdata *cvdata,
  int num_internalpts,
  double lentol,
  struct PWcvpt *internalpts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
