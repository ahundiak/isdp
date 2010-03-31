#ifndef _objaccess_proto_h 
#define _objaccess_proto_h

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

extern PWobjid omObjOfClass _PW_((
  PWclassid objclass,
  PWosnum os
));

extern PWresult omGetObjsOfClass _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));

extern PWresult omEligObjs _PW_((
  int num_inobjs,
  PWobjid *inobjs,
  PWosnum os,
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  int *num_outobjs,
  PWobjid **outobjs
));

extern PWresult omGetRtreeObjsOfClass _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
