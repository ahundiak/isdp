#ifndef _mapisocv_proto_h 
#define _mapisocv_proto_h

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

extern PWresult pwSplitAndMapXyzCvIsoInUvOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_isocvs,
  PWpoint2d isocv_pts[6],

  int *num_non_isocvs,
  struct PWcvdata p_non_isocvs[3]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
