#ifndef _conicbnds_proto_h 
#define _conicbnds_proto_h

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

extern PWresult pwGetBoundsOfCylinder _PW_((
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  PWpoint base_center,
  PWpoint height_center
));

extern PWresult pwGetBoundsOfCone _PW_((
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  double  halfangle,
  PWpoint   genpt,
  PWvector  majoraxis,
  PWboolean same,
  PWpoint base_center,
  double  *base_radius,
  PWpoint top_center,
  double  *top_radius
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
