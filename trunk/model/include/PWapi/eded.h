#ifndef _eded_proto_h 
#define _eded_proto_h

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

extern PWobjid pwGetPartEdOfEd _PW_((
  PWobjid           edobj,
  PWosnum           os,
  struct PWcvparam  *p_edpar
));

extern PWobjid pwGetCommonEd  _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetNextEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetPrevEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid pwGetNextEdNoDegen _PW_((
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
));

extern PWobjid pwGetPrevEdNoDegen _PW_((
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
));

extern PWobjid pwGetEdOfPartEd _PW_((
  PWobjid  edobj,
  PWosnum  os
));

extern PWobjid  pwGetInterveningEdge _PW_((
  PWosnum            os,
  PWobjid            ed1,
  enum PWtopopostype topo1,
  PWobjid            ed2,
  enum PWtopopostype topo2,
  PWpoint2d          midpt,
  double             uvtol
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
