#ifndef _ptclass_proto_h 
#define _ptclass_proto_h

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

extern PWresult   pwLpPtClassify _PW_(( 
  struct PWid             *p_lpid,
  PWpoint2d               uvpt,
  double                  xyztol,
  struct PWsfdata         *p_sfdata,
  enum PWptloctype        *p_ptloc,
  PWobjid                 *p_edid,
  struct PWcvpt           *p_edpt
));

extern PWresult   LpPtClassify _PW_(( 
  struct PWid             *p_lpid,
  PWpoint2d               uvpt,
  double                  xyztol,
  struct PWsfdata         *p_sfdata,
  enum PWptloctype        *p_ptloc,
  PWobjid                 *p_edid,
  struct PWcvpt           *p_edpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
