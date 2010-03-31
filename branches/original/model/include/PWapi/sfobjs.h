#ifndef _sfobjs_proto_h 
#define _sfobjs_proto_h

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

extern PWresult pwGetSolidsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_solids,
  PWobjid **solids
));

extern PWresult pwGetCompSfsOfOS _PW_((
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compsfs,
  PWobjid **compsfs
));

extern PWresult pwGetSingleSfsOfOS _PW_((
  PWosnum  os,
  PWboolean sfs_in_rtree,
  int *num_surfs,
  PWobjid **surfs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
