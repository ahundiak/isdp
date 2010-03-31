#ifndef _actrefos_proto_h 
#define _actrefos_proto_h

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

extern PWresult pwActivateOS _PW_((
   PWosnum osn
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
