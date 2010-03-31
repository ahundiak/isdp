#ifndef _addraft_proto_h 
#define _addraft_proto_h

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

PWresult pwAddDraft
(
  PWobjid solid,
  PWosnum os,
  PWobjid datum_plane,
  int num_draft_sfs,
  PWobjid *draft_sfs,
  struct PWvalueinfo draft_angle,
  PWboolean draft_into_volume,
  PWobjid *drafted_solid
);

#if defined(__cplusplus) 
} 
#endif 

#endif 
