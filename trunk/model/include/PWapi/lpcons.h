#ifndef _lpcons_proto_h 
#define _lpcons_proto_h

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

extern PWresult pwCreateLoopFromEdgeGeoms _PW_((
  int num_eds,
  struct PWcvdata *p_eddata,
  int *p_edprops,
  int *p_edxyz_type,
  PWboolean *p_edrev,

  struct IGRbsp_surface *p_sfgeom,

  PWosnum os,
  double xyztol,

  int *num_loops,
  PWobjid **p_loops
));

extern PWobjid pwCreateLoopFromEdgeObjs _PW_((
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
));

extern PWresult pwConnectSeams _PW_((
  int num_loops,
  PWobjid *p_loops,
  PWosnum os,
  double uvtol
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
