#ifndef _memfunc_proto_h 
#define _memfunc_proto_h

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

extern void pwSwapDouble  _PW_((
  double *d1,
  double *d2
));

extern void pwSwapInt  _PW_((
  int *i1,
  int *i2
));

extern void pwSwapPt2d _PW_((
  PWpoint2d pt1,
  PWpoint2d pt2
));

extern void pwSwapPt _PW_((
  PWpoint pt1,
  PWpoint pt2
));

extern void pwCnvt3dTo2d  _PW_((
  int numpts,
  PWpoint *pts,
  PWpoint2d *pts2d
));

extern void pwCnvt2dTo3d  _PW_((
  int numpts,
  PWpoint2d *pts2d,
  PWpoint *pts
));

extern PWresult pwMemInChunks _PW_((
  int num_objs,
  void **p_objs,
  int obj_size,
  int chunk_size
));

extern void pwFree _PW_((
  void *ptr
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
