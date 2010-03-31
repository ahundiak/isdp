#ifndef _objdel_proto_h 
#define _objdel_proto_h

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

extern PWresult omDeleteObject _PW_((
  PWobjid object,
  PWosnum os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
