#ifndef _edcons_proto_h 
#define _edcons_proto_h

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

extern PWobjid pwCreateEdge _PW_((
  PWosnum os,
  struct PWcvdata *p_edgeom,
  int edprops,
  int edxyz_type
));

extern PWobjid pwCreateDummyEdge _PW_((
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
));

extern PWobjid pwCreatePartEdge _PW_((
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
));

extern PWboolean pwGetNatLocation _PW_((
  PWpoint2d edpts[2],
  double u_min,
  double u_max, 
  double v_min,
  double v_max,

  int *natloc,
  PWboolean *natrev
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
