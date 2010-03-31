/*
  OVERVIEW
  Function prototypes and structures that are required for the use of
  Add/Remove material Feature APIs.

  NOTES

  HISTORY
  Aditya   03/19/96   Creation
*/

#ifndef _AddRmAPI_include
#define _AddRmAPI_include


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

extern PWresult pwAddMaterialProjected _PW_(( PWobjid solid,
  PWosnum os,
  PWobjid profile_cv,
  PWvector dir_vector,
  PWboolean proj_normal,
  PWboolean add_matl_on_right,
  enum PWaddremexttype ext_type,
  PWobjid from_sf,
  PWobjid to_sf,
  struct PWvalueinfo *distance,
  PWobjid *mod_solid
));


extern PWresult pwAddMaterialRevolved _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile_cv,
   PWpoint axis_point,
   PWvector axis_vector,
   PWboolean add_matl_on_right,
   enum PWaddremexttype ext_type,
   PWobjid from_sf,
   PWobjid to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *mod_solid
));


extern PWresult pwAddMatlBySkinning _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile_cv,
   PWobjid trace_curve,
   enum PWaddremexttype type,
   PWboolean along_trace_curve,
   PWobjid *mod_solid
));


extern PWresult pwRemMatProjected _PW_((
  PWobjid solid,
  PWosnum os,
  PWobjid profile,
  PWvector dir_vector,
  PWboolean proj_normal,
  PWboolean rem_matl_on_right,
  enum PWaddremexttype ext_type,
  PWobjid from_sf,
  PWobjid to_sf,
  struct PWvalueinfo *depth,
  PWobjid *mod_solid
));

extern PWresult pwRemMatRevolved _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile,
   PWpoint axis_point,
   PWvector axis_vector,
   PWboolean rem_matl_on_right,
   enum PWaddremexttype ext_type,
   PWobjid from_sf,
   PWobjid to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *mod_solid
));


extern PWresult pwRemMatBySkinning _PW_((
   PWobjid solid,
   PWosnum os,
   PWobjid profile,
   PWobjid trace_curve,
   enum PWaddremexttype type,
   PWboolean along_trace_curve,
   PWobjid *mod_solid
));


extern PWresult pwQueryAddMatProjected _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile,
  PWvector *dir_vector,
  PWboolean *proj_normal,
  PWboolean *add_matl_on_right,
  enum PWaddremexttype *ext_type,
  PWobjid *from_sf,
  PWobjid *to_sf,
  struct PWvalueinfo *distance,
  PWobjid *base_solid
));

extern PWresult pwQueryAddMatRevolved _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWpoint *axis_point,
   PWvector *axis_vector,
   PWboolean *add_matl_on_right,
   enum PWaddremexttype *ext_type,
   PWobjid *from_sf,
   PWobjid *to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *base_solid
));


extern PWresult pwQueryAddMatBySkinning _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWobjid *trace_curve,
   enum PWaddremexttype *ext_type,
   PWboolean *along_trace_curve,
   PWobjid *base_solid
));


extern PWresult pwQueryRemMatProjected _PW_((
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile,
  PWvector *dir_vector,
  PWboolean *proj_normal,
  PWboolean *rem_matl_on_right,
  enum PWaddremexttype *ext_type,
  PWobjid *from_sf,
  PWobjid *to_sf,
  struct PWvalueinfo *depth,
  PWobjid *mod_solid
));

extern PWresult pwQueryRemMatRevolved _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWpoint *axis_point,
   PWvector *axis_vector,
   PWboolean *rem_matl_on_right,
   enum PWaddremexttype *ext_type,
   PWobjid *from_sf,
   PWobjid *to_sf,
   struct PWvalueinfo *start_angle,
   struct PWvalueinfo *sweep_angle,
   PWobjid *base_solid
));


extern PWresult pwQueryRemMatBySkinning _PW_((
   PWobjid feature_id,
   PWosnum os,
   PWobjid *profile,
   PWobjid *trace_curve,
   enum PWaddremexttype *ext_type,
   PWboolean *along_trace_curve,
   PWobjid *mod_solid
));


#if defined(__cplusplus)
}
#endif

#endif
