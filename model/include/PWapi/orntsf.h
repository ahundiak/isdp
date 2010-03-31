#ifndef _orntsf_proto_h 
#define _orntsf_proto_h

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

extern void pwRevNormalSf _PW_((
  PWobjid  sfobj,
  PWosnum  os 
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
