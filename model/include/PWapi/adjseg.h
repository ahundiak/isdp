#ifndef _adjseg_proto_h 
#define _adjseg_proto_h

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

extern PWresult pwClassifyInteractionWithAdjseg _PW_((
  struct PWcvdata      *p_bdata,       /* Boundary data */
  PWboolean            b_reverse,     
  struct PWcvdata      *p_badjdata,
  PWboolean            badj_reverse,
  struct PWcvpt        *p_bpt,         /* Intersection point on Boundary 
                                          data */
 
  struct PWcvdata      *p_idata,       /* Intersection data */
  PWboolean            i_reverse,
  struct PWcvdata      *p_iadjdata, 
  PWboolean            iadj_reverse,
  struct PWcvpt        *p_ipt,         /* Intersection point on Intersection 
                                          data */

  PWvector             dirvec,
  double               lentol,

  enum PWcontaintype   intrels[2]      /* Intersection point classification */
));

extern PWresult pwGetFwBwTangentsCvdata _PW_((
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_cvpar,
  PWboolean         reversed,
  double            lentol,
  PWvector          tangents[2]
));

extern PWresult pwGetFwBwCurvatureBspcv _PW_((
  struct IGRbsp_curve *p_cv,
  PWboolean           reversed,
  double              par,
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp

));

extern enum PWcontaintype get_rel_from_angles1 _PW_((
  double  ang1, 
  double  ang2, 
  double  angtol
));

extern void pwClassifyPointWithCurvature _PW_((
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,


  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  enum PWcontaintype  intrels[2]
));

extern void pwClassifyPointWithCurvature1 _PW_((
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,

  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  PWboolean *is_ib_bwd_same,

  enum PWcontaintype  intrels[2]
));

extern PWresult pwGetFwBwCurvatureBspcv1 _PW_((
  struct IGRbsp_curve *p_cv,
  double              par, 
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp
  
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
