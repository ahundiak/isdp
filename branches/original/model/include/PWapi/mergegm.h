#ifndef _mergegm_proto_h 
#define _mergegm_proto_h

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

extern PWresult pwMergeCvdata _PW_((
  struct PWcvdata *p_cv1,
  struct PWcvdata *p_cv2,
  double lentol,
  
  struct PWcvdata *p_outcv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
