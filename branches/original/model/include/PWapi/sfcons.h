#ifndef _sfcons_proto_h 
#define _sfcons_proto_h

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

extern PWobjid pwCreateSfObj _PW_(( 
 struct IGRbsp_surface *pSurfGeom,
 int sftype,
 PWosnum osnum
));

extern PWresult pwCreatePlaneBsp _PW_((
  PWpoint basept1,
  PWpoint basept2,
  PWpoint heightpt,
  struct IGRbsp_surface *p_plane
));

extern PWresult pwCreateCylinderBsp _PW_((
  PWpoint base_center,
  PWpoint top_center,
  double  radius,
  struct IGRbsp_surface *p_cylinder
));

extern PWresult pwCreateConeBsp _PW_((
  PWpoint base_center,
  PWpoint top_center,
  double  base_radius,
  double  top_radius,
  struct IGRbsp_surface *p_cone
));

extern PWresult pwCreateElpCylinderBsp _PW_((
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt, 
  struct IGRbsp_surface *p_elpcylinder
));

extern PWresult pwCreateElpConeBsp _PW_((
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt,
  double   scale,
  struct IGRbsp_surface *p_elpcone
));

extern PWresult pwCreateSphereBsp _PW_((
  PWpoint center,
  double  radius,
  struct IGRbsp_surface *p_sphere
));

extern PWresult pwCreateTorusBsp _PW_((
  PWpoint base_center, 
  double  base_radius,
  PWpoint tor_axispt1,
  PWpoint tor_axispt2,
  struct IGRbsp_surface *p_torus
));

extern PWresult pwCreateProjSfBsp _PW_((
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  struct IGRbsp_surface *p_sfproj
));

extern PWresult pwCreateRevSfBsp _PW_((
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  PWboolean full,
  double stang,
  double swang,
  struct IGRbsp_surface *p_sfrev
));

extern PWresult pwCreateTorusBsp1 _PW_((
  PWpoint tor_center,
  PWvector tor_axis,
  double tor_radius,
  double base_radius,

  struct IGRbsp_surface *p_torus
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
