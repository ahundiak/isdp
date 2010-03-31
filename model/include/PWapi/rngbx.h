#ifndef _rngbx_proto_h 
#define _rngbx_proto_h

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

extern void pwGetRange2d  _PW_((
  int num_points,
  PWpoint2d *pts,
  PWrange2d range
));

extern void pwGetRange  _PW_((
  int num_points,
  PWpoint *pts,
  PWrange range
));

extern void pwExpandRange2d  _PW_((
  PWrange2d rng,
  double k
));

extern void pwExpandRange  _PW_((
  PWrange rng,
  double k
));

extern PWboolean pwIsOverlapRngRng2d  _PW_((
  PWrange2d rng1,
  PWrange2d rng2
));

extern PWboolean pwIsOverlapRngRng  _PW_((
  PWrange rng1,
  PWrange rng2
));

extern PWboolean pwIsOutsideSegRng2d  _PW_((
  PWpoint2d seg[2],
  PWrange2d rng
));

extern PWboolean pwIsOutsideSegRng _PW_((
  PWpoint seg[2],
  PWrange rng
));

extern void pwGetCvRange _PW_((
  struct IGRbsp_curve *p_cv,
  PWrange             range
));

extern void pwGetRangeCvdata _PW_((
  struct PWcvdata *p_cvdata,
  double *range
));

extern void pwGetMaxParCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
));

extern void pwGetMinParCvdata _PW_((
  struct PWcvdata  *p_cvdata,
  struct PWcvparam *p_cvpar
));

extern void pwGetRngPts _PW_((
  PWrange  rngbx,
  PWpoint  rngpts[8]
));

extern PWresult  pwMinMaxPtsAlongVec  _PW_((
  int       numpts, 
  PWpoint   *ppoints, 
  PWvector  dirvec,
  PWpoint   maxpt, 
  PWpoint   minpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
