#ifndef _lpprops_proto_h 
#define _lpprops_proto_h

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

extern void pwGetLpRange  _PW_((
  PWobjid   loopobj,
  PWosnum   loopos,
  PWrange2d range 
));

extern PWboolean pwIsLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpSplit  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpOpen  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpFace  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpOuter  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpNew  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpActive  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern PWboolean pwIsLpRev _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwUnsetLpNatural  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpSplit  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpOpen  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpFace  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpOuter  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpNew  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpActive  _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpRev _PW_((
  PWobjid loopobj,
  PWosnum loopos
));

extern void pwSetLpRange _PW_((
  PWobjid   loopobj,
  PWosnum   loopos
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
