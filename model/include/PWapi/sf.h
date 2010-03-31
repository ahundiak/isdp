#ifndef _sf_proto_h 
#define _sf_proto_h

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

extern PWboolean pwIsCompSf _PW_((
  PWobjid  sfobj,
  PWosnum  sfos
));

extern void pwGetNatSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));

extern void pwGetSfUvRng _PW_((
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
));

extern PWresult pwGetSubbsRtreeRange _PW_((
  PWobjid               sfid,
  PWosnum               sfos,
  short                 mat_typ,
  PWmatrix              mat,
  double                *sfrange
));

extern PWresult pwGetSubbsRtreeRangeFromGRrtree _PW_((
  PWobjid               sfid,
  PWosnum               sfos,
  PWobjid               rtreeObjid,
  short                 mat_typ,
  PWmatrix              mat,
  double             *sfrange
));

extern PWresult pwIsSurfaceActive _PW_((
  PWobjid sfobj, 
  PWosnum os,
  short *isActive
));

extern PWresult pwIsSurfaceDisplayable _PW_((
  PWobjid sfobj,
  PWosnum os, 
  short   *isDisplayable
));

#if defined(__cplusplus)
}
#endif

#endif
















