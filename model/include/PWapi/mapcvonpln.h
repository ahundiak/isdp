#ifndef _mapcvonpln_proto_h 
#define _mapcvonpln_proto_h

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

extern PWboolean pwIsLinearMapOkOnPlane _PW_((
  struct IGRbsp_surface *p_sfgeom,
  double lentol
));

extern PWresult pwLinearMapXyzCvToUvOfPlane _PW_((
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,
  
  struct PWcvdata *p_uvcv
));

extern PWresult pwLinearMapXyzCvToUvOfInfPlane _PW_((
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_uvcv
));

extern PWresult pwLinearMapUvCvToXyzOfPlane _PW_((
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_xyzcv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
