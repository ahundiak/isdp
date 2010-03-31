#ifndef _coincvec_proto_h 
#define _coincvec_proto_h

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

extern PWresult pwCoincVec2d  _PW_((
  int numvecs,
  PWvector2d *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
));

extern PWresult pwCoincVec _PW_((
  int numvecs,
  PWvector *vecs,
  int *num_coinc_sets,
  int *num_vecs_in_set,
  int *vecs_in_set
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
