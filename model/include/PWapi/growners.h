#ifndef _growners_proto_h 
#define _growners_proto_h

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

extern PWresult pwGetFileTopOwners  _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_top_objs,
  PWobjid **top_objs
));

extern PWresult pwGetRtreeTopOwners  _PW_((
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWclassid rtree_class,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
