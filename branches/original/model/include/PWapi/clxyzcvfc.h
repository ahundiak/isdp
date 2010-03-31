#ifndef _clxyzcvfc_proto_h 
#define _clxyzcvfc_proto_h

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

extern PWresult pwCloseXyzCompCvWithFaceBounds _PW_((
  int num_xyzcv,
  struct PWcvdata *p_xyzcvs,

  PWobjid fcobj,
  PWosnum os,
  PWboolean reverse,

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



#if defined(__cplusplus) 
} 
#endif 

#endif 
