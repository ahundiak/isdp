#ifndef _cluvcvfc_proto_h 
#define _cluvcvfc_proto_h

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

extern PWresult pwCloseUvCompCvWithFaceBounds _PW_((
  int num_cvs,
  struct PWcvdata *p_uvcvs,  

  PWobjid fcobj,
  PWosnum os,

  PWboolean reverse, /* reverse the bdry curves */

  PWvector startextvec,
  PWvector stopextvec,
  PWboolean ignoremidcvs,

  double lentol,

  PWboolean *start_extended,
  PWboolean *stop_extended,

  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
));

extern void pwCopyCvdata _PW_((
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
));

extern void pwGetMidCvpar _PW_((
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  double dist_factor,
  
  struct PWcvparam *p_par
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
