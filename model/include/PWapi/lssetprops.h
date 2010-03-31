#ifndef _lssetprops_proto_h 
#define _lssetprops_proto_h

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

extern void pwSetLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwUnsetLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwSetLsSplit _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern void pwSetLsXyz _PW_((
  PWobjid lsobj,
  PWosnum lsos
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
