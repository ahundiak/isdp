#ifndef _cnstrgeom_proto_h 
#define _cnstrgeom_proto_h

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

extern PWresult pwGetGroundGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetHorizVertGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetCoincidentGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetTangencyGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetPointOnElementGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out,
  struct PWcvpt *cvpt
));

extern PWresult pwGetParallelGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
));

extern PWresult pwGetCollinearGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetEqualityGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
));

extern PWresult pwGetNormalGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern PWresult pwGetSinglparlGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
));

extern PWresult pwGetRadialGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
));

extern PWresult pwGetStackedGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetAxisStackedGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetAbsangleGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
));

extern PWresult pwGetRelangleGeom  _PW_((
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
));

extern PWresult pwGetDimConstraintProps _PW_((
  PWobjid cnstr_id,
  PWosnum os,
  PWboolean *is_clockwise,
  PWboolean *is_negative_axis,
  PWboolean *is_supplement
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
