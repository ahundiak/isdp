#ifndef _uvfaces_proto_h 
#define _uvfaces_proto_h

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

extern PWresult pwGetSfFaceLoopsUv _PW_((
  PWobjid sfobj,
  PWosnum os,

  double xyztol,

  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
