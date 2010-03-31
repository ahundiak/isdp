#ifndef _mapcvonsf_proto_h 
#define _mapcvonsf_proto_h

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

extern PWresult pwMapXyzCvToUvOfSf _PW_((
  struct PWcvdata *p_xyzcv,
  struct PWsfdata *p_sfdata,
  double xyztol, 

  int *num_uvcv,
  struct PWcvdata **p_uvcv,
  int **p_uvcv_props,
  int **p_xyzcv_type
));

extern PWresult pwMapUvCvToXyzOfSf _PW_((
  struct PWcvdata *p_uvcv,
  struct PWsfdata *p_sfdata,
  double xyztol,
 
  struct PWcvdata *p_xyzcv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
