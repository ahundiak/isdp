#ifndef _mdstptgm_proto_h 
#define _mdstptgm_proto_h

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

extern double pwDistPtPt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern double pwDistPtPt  _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern double pwDistSqPtPt2d  _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern double pwDistSqPtPt  _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern PWresult pwProjPtLn2d _PW_((
  PWpoint2d pt, 
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
));

extern PWresult pwProjPtLn _PW_((
  PWpoint pt, 
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
));

extern double pwMinDistSqPtSeg2d _PW_((
  PWpoint2d pt,
  PWpoint2d segpt1,
  PWpoint2d segpt2,
  PWpoint2d minpt,
  double *minpar
));

extern double pwMinDistSqPtSeg _PW_((
  PWpoint pt,
  PWpoint segpt1,
  PWpoint segpt2,
  PWpoint minpt,
  double *minpar
));

extern double pwMinDistSqPtPy2d _PW_((
  PWpoint2d pt,
  int numpypts,
  PWpoint2d *pypts,
  PWpoint2d minpt,
  struct PWcvparam *minpar
));

extern double pwMinDistSqPtPy _PW_((
  PWpoint pt,
  int numpypts,
  PWpoint *pypts,
  PWpoint minpt,
  struct PWcvparam *minpar
));

extern PWresult pwProjPtRngPy2d _PW_((
  PWpoint2d pt,
  int numpts,
  PWpoint2d *pts,
  double rngdist,
  PWpoint2d minpt,
  struct PWcvparam *minpar
));

extern PWresult pwProjPtRngPy _PW_((
  PWpoint pt,
  int numpts,
  PWpoint *pts,
  double rngdist,
  PWpoint minpt,
  struct PWcvparam *minpar
));

extern double pwMinDistSqPtCvdata _PW_((
  double           *p_pt,       /* could be 2d or 3d depending on data type */
  struct PWcvdata  *p_cvdata,
  double           *p_minpt,    /* could be 2d or 3d depending on data type */
  struct PWcvparam *p_minpar
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
