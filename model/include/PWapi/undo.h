#ifndef _undo_proto_h 
#define _undo_proto_h

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

extern PWresult pwUndoFeatureTree _PW_((
  PWobjid feature_id,
  PWosnum os,
  int levels_to_undo,
  int *num_top_owners,
  PWobjid **top_owners
));

extern PWresult pwUndoFeatTreeUntilObjid _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid target_id,
  int *num_top_owners,
  PWobjid **top_owners
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
