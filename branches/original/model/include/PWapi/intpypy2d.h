#ifndef _intpypy2d_proto_h 
#define _intpypy2d_proto_h

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

extern PWresult pwIntPyPy2d  _PW_((
  int b_numpts, 
  PWpoint2d *b_pts,
  struct PWadjseg *b_adjseg,
  PWrange2d b_range,
  PWboolean b_reverse, 
  PWboolean b_process_start,

  int i_numpts, 
  PWpoint2d *i_pts,
  struct PWadjseg *i_adjseg,
  PWrange2d i_range,
  PWboolean i_reverse, 
  PWboolean i_process_start,

  double lentol,

  int *num_inters,
  struct PWcvintpt_list **inter_pts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
