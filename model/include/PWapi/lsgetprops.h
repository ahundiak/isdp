#ifndef _lsgetprops_proto_h 
#define _lsgetprops_proto_h

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

extern PWboolean pwIsLsNatural  _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern PWboolean pwIsLsSplit _PW_((
  PWobjid lsobj,
  PWosnum lsos
));

extern PWboolean pwIsLsXyz _PW_((
  PWobjid lsobj,
  PWosnum lsos
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
