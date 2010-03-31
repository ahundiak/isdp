#ifndef _sfprops_h 
#define _sfprops_h

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

extern void pwGetNatSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
