#ifndef _sfbnds_proto_h 
#define _sfbnds_proto_h

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

extern PWresult pwGetDegenNatBdrysOfSf _PW_((
  struct IGRbsp_surface *p_sf,
  double lentol,

  PWboolean *degen_u0,
  PWboolean *degen_u1,
  PWboolean *degen_v0,
  PWboolean *degen_v1
));

extern PWresult pwGetSfEds _PW_((
  PWobjid sfobj,
  PWosnum os,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_edges,
  PWobjid **edges
));

extern PWresult pwGetSfEdCvs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_cvs,
  struct IGRbsp_curve ***cvs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
