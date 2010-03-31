#ifndef _cvobjs_proto_h 
#define _cvobjs_proto_h

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

extern PWresult pwGetProfilesOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_profiles,
  PWobjid **profiles
));

extern PWresult pwGetCompCvsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compcvs,
  PWobjid **compcvs
));

extern PWresult pwGetSingleCvsOfOS _PW_((
  PWosnum  os,
  PWboolean cvs_in_rtree,
  int *num_cvs,
  PWobjid **cvs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
