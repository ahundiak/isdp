#ifndef _sortvec_proto_h 
#define _sortvec_proto_h

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

extern PWresult pwSortVec2d  _PW_((
  int numvecs,
  PWvector2d *vecs,
  int *sort_indices
));

extern PWresult pwSortVec  _PW_((
  int numvecs,
  PWvector *vecs,
  PWvector dirvec,
  int *sort_indices
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
