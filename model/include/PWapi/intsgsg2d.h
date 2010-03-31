#ifndef _intsgsg2d_proto_h 
#define _intsgsg2d_proto_h

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

extern PWboolean pwIntSgSg2d  _PW_((
  PWpoint2d bpt1, 
  PWpoint2d bpt2,
  double *bpt_next,
  PWpoint2d cpt1,
  PWpoint2d cpt2,
  double *cpt_next,

  double lentol,

  int *num_inters,
  PWpoint2d b_inter_pts[2],
  PWpoint2d c_inter_pts[2],
  double bpars[2],
  double cpars[2],
  enum PWtopopostype bposs[2], 
  enum PWtopopostype cposs[2],
  enum PWcontaintype lfrels[2], 
  enum PWcontaintype rtrels[2],
  PWboolean b_atstop_onc[2], 
  PWboolean c_atstop_onb[2]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
