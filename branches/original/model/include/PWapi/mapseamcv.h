#ifndef _mapseamcv_proto_h 
#define _mapseamcv_proto_h

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

extern PWresult pwSplitAndMapXyzCvSeamInUvOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  struct PWcvdata *p_xyzcv,
  double xyztol,
  
  int *num_seamcvs,
  PWpoint2d **p_seamcvpts,

  int *num_splitcvs,
  struct PWcvdata **p_splitcvs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
