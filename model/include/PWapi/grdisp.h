#ifndef _grdisp_proto_h 
#define _grdisp_proto_h

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

extern void pwDisplayObj _PW_((
  PWobjid grobj,
  PWosnum os,
  PWboolean erase,
  PWboolean highlight
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
