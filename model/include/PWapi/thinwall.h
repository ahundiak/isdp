#ifndef _thin1_proto_h 
#define _thin1_proto_h

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

extern PWresult pwThinWall _PW_((
 PWobjid surface_entity,
 PWosnum os,
 struct PWvalueinfo *common_thickness,
 PWboolean is_offset_symmetric,
 PWboolean offset_inside,
 int       num_open_sfs,
 PWobjid   *opensfs,
 int       num_spel_sfs_groups,
 struct PWspecialsfs *special_sfs,
 PWobjid *mod_solid
));

extern PWresult pwQueryThinWall _PW_((
  PWobjid feature_id,
  PWosnum os,
  struct PWvalueinfo *common_thickness,
  PWboolean *is_offset_symmetric,
  PWboolean *is_offset_inside,
  int *num_open_sfs,
  PWobjid **opensfs,
  int *num_spel_sfs_groups,
  struct PWspecialsfs **special_sfs,
  PWobjid *base_sf_entity
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
