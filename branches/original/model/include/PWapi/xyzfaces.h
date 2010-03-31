#ifndef _xyzfaces_proto_h 
#define _xyzfaces_proto_h

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

extern PWresult pwGetSfFaceLoopsXyz _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_xyz
));

extern PWresult pwGetUvCvsOfSfFaceLoopsXyz _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_uv
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
