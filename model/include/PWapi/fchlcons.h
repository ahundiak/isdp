#ifndef _fchlcons_proto_h 
#define _fchlcons_proto_h

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

extern PWobjid pwCreateFaceFromEdges _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
));

extern PWobjid pwCreateHoleFromEdges _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
