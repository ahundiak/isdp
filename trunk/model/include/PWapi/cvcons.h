#ifndef _cvcons_proto_h 
#define _cvcons_proto_h

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

extern PWobjid  pwCreateCvObj _PW_((
  struct PWcvdata  *p_cvdata,
  PWosnum  os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
