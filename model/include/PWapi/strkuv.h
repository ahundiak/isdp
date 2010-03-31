#ifndef _strkuv_proto_h 
#define _strkuv_proto_h

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

extern PWresult pwStrokeUvdataIfNeeded _PW_((
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_uvpts,
  PWpoint *p_xyzpts,

  double xyztol,

  int *num_outpts,
  PWpoint2d **p_outuvpts,
  PWpoint **p_outxyzpts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
