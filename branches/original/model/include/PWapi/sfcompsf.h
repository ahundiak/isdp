#ifndef _sfcompsf_proto_h 
#define _sfcompsf_proto_h

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

extern int pwNumSfsOfCompSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os
));

extern int pwGetSfsOfCompSf  _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_sfs
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
