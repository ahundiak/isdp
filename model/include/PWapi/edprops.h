#ifndef _edprops_proto_h 
#define _edprops_proto_h

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

extern PWboolean pwIsEdOpen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdRevConn _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdDegen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdClosedXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdNatural _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern int pwGetEdCvType _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdOpen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdRevConn _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdDegen _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdIso _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdClosedXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdXYZ _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdNatural _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdCvType _PW_((
  PWobjid  edobj,
  PWosnum  edos,
  int      cvtype
));

extern void pwSetEdTangent _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwSetEdCompatible _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwEdRev _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern PWboolean pwIsEdDegenTol _PW_((
  PWobjid  edobj,
  PWosnum  edos,
  double   tol
));

extern void pwUnsetEdSubordinate _PW_((
  PWobjid  edobj,
  PWosnum  edos
));

extern void pwUnsetEdSeam _PW_((
  PWobjid  edobj,
  PWosnum  edos
));
   
#if defined(__cplusplus) 
} 
#endif 

#endif 
