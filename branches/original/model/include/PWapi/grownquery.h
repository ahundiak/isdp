#ifndef _grownquery_proto_h 
#define _grownquery_proto_h

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

extern PWobjid pwNumCompsOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os
));

extern int pwCompsOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os,
  PWobjid *p_comps
));

extern PWobjid pwCompAtInxOfOwner _PW_((
  PWobjid ownobj,
  PWosnum os,
  int index
));

extern int pwCompInxOnOwner _PW_((
  PWobjid compobj,
  PWosnum os
));

extern PWobjid pwOwnerOfComp _PW_((
  PWobjid compobj,
  PWosnum os
));

extern int pwMaxTreeDepth  _PW_((
  PWobjid ownobj,
  PWosnum os
));

extern int pwCompTreeDepth _PW_((
  PWobjid compobj,
  PWosnum os
));

extern PWobjid pwTopOwner _PW_((
  PWobjid grcomp,
  PWosnum os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
