#ifndef _ptpargm_proto_h 
#define _ptpargm_proto_h

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

extern PWresult pwPtAtParPy2d _PW_((
  int               numpts,
  PWpoint2d         *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
));

extern PWresult pwPtAtParPy _PW_((
  int               numpts,
  PWpoint           *p_pts,
  struct PWcvparam  *p_par,
  PWpoint2d         pt 
));

extern PWresult pwPtAtParCv _PW_((
  struct IGRbsp_curve  *p_bspcv,
  double               par,
  double               *p_pt
));

extern PWresult pwPtAtParCvdata _PW_((
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_par,
  double            *p_pt
));

extern PWresult pwGetTangentPy2d _PW_((
  struct PWpoly2d  *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector2d       tangent
));

extern PWresult pwGetTangentPy _PW_((
  struct PWpoly    *p_py,
  int              spaninx,
  PWboolean        reverse,
  PWvector         tangent
));

extern PWresult pwGetTangentCv _PW_((
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse,
  PWvector             tangent
));

extern PWresult pwGetTangentCvdata  _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar,
  PWboolean        reverse,
  double           *p_tangent
));

extern PWresult pwParAtPtCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  double           tol,         /* The input must be lying on the input geom
                                   with in this tolerance */
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_cvpar
));

extern void pwGetEndPtCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean	  stop_end,
  double          *p_pt
));

extern void pwGetEndPtsCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double          *p_startpt,
  double          *p_endpt
));

extern void pwGetEndCvparCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean reversed,
  PWboolean stop_end,
  struct PWcvparam *p_cvpar
));

extern void pwGetEndCvptCvdata _PW_((
  struct PWcvdata *p_cvdata,
  PWboolean       reversed,
  PWboolean       stop_end,
  struct PWcvpt   *p_cvpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
