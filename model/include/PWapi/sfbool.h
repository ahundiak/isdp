#ifndef _sfbool_proto_h 
#define _sfbool_proto_h

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

extern PWresult pwSfBooleanUnion _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *union_sf
));

extern PWresult pwSfBooleanDifference _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *difference_sf
));

extern PWresult pwSfBooleanIntersection _PW_((
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *intersection_sf
));

extern PWresult pwSfCutWithPlane _PW_((
  PWobjid sf,
  struct PWplane *plane,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *cut_sf
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
