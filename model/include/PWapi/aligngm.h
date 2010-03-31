#ifndef _aligngm_proto_h 
#define _aligngm_proto_h

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

extern int pwAlignCvSize  _PW_((
  int num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries
));

extern int pwAlignSfSize _PW_((
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries,
  int *points_per_bnd
));

extern void pwAlignCvGeom _PW_((
  long num_poles, 
  short order, 
  PWboolean rational, 
  int num_boundaries, 
  struct IGRbsp_curve  *p_curve
));

extern void pwAlignSfGeom _PW_((
  long u_num_poles, 
  long v_num_poles, 
  short u_order, 
  short v_order, 
  PWboolean rational, 
  int num_boundaries, 
  int *points_per_bnd, 
  struct IGRbsp_surface *p_surface
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
