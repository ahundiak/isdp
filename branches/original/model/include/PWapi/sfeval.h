#ifndef _sfeval_proto_h 
#define _sfeval_proto_h

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

extern PWresult pwGetSfPts _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts
));

extern PWresult pwGetSfArrayPts _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts
));

extern PWresult pwGetSfTangents _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  double *u_derivative,
  PWvector *unit_vtans,
  double *v_derivative
));

extern PWresult pwGetSfArrayTangents _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  PWvector *unit_vtans
));

extern PWresult pwGetSfNormals _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix mat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_norms
));

extern PWresult pwGetSfArrayNormals _PW_((
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_norms
));

extern PWresult pwGetSfPtsInBdry _PW_((
  PWobjid sfobj,
  PWosnum os,
  int num_pts,
  PWpoint2d *uv_pts,

  PWboolean *is_inbdry
));

extern PWresult pwGetSfArrayPtsInBdry _PW_((
  PWobjid sfobj,
  PWosnum os,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWboolean *is_inbdry
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
