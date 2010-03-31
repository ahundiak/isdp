#ifndef _cvtype_proto_h 
#define _cvtype_proto_h

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

extern PWboolean pwIsCurve _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern PWboolean pwIsCompCv _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern PWboolean pwIsSimpleCv _PW_((
  PWobjid  cvobj,
  PWosnum  cvos
));

extern char pwEMSCvType _PW_((
  short bstype
));

extern PWclassid pwCvClassid _PW_((
  short cvtype
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
