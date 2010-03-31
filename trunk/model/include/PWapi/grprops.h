#ifndef _grprops_proto_h 
#define _grprops_proto_h

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

extern PWboolean pwIsRigidComp _PW_((
  PWobjid grobj,
  PWosnum os
));

extern PWboolean pwIsRigidOwner _PW_((
  PWobjid grobj,
  PWosnum os
));

extern short GraphicsProps _PW_((
  PWobjid grobj,
  PWosnum os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
