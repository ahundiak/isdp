#ifndef _uvcvprops_proto_h 
#define _uvcvprops_proto_h

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

extern PWresult pwGetUvCvdataProps _PW_(( 
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,
  double uvtol,
  int    *props
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
