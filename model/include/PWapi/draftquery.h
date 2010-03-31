#ifndef _draftquery_proto_h 
#define _draftquery_proto_h

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


void pwQueryAddDraft
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid *datum_plane, 
  int *num_draft_sfs,
  PWobjid **draft_sfs, 
  double *draft_angle,
  PWboolean *draft_into_volume,
  PWobjid *base_solid
);



#if defined(__cplusplus) 
} 
#endif 

#endif 
