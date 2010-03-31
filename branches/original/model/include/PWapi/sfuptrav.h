#ifndef _sfuptrav_h 
#define _sfuptrav_h

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

extern PWobjid pwGetSfOfEd _PW_((
  PWobjid edobj,
  PWosnum os
));

extern PWobjid pwGetLpOfEd _PW_((
  PWobjid edobj,
  PWosnum os
));

extern PWobjid pwGetSfOfLp _PW_((
  PWobjid lpobj,
  PWosnum os
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
