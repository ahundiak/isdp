#ifndef _cvprops_proto_h 
#define _cvprops_proto_h

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

extern PWboolean pwIsCvOpen  _PW_((
  PWobjid cvobj,
  PWosnum os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
