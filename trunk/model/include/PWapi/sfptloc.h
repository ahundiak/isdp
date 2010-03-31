#ifndef _sfptloc_proto_h 
#define _sfptloc_proto_h

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

extern PWresult   pwSfPtLocate _PW_((
           struct PWgeomid   *p_sfgeomid,
           PWpoint           xyzpt,
           PWpoint2d         uvpt,
           double            xyztol,
           enum PWptloctype  *p_ptloc,
           PWobjid           *p_bdryid,
           struct PWcvpt     *p_edpt
));

extern PWresult SfGeomPtLocate _PW_((
  struct IGRbsp_surface *sf,
  PWosnum os,
  PWpoint xyzpt,
  PWpoint2d uvpt,
  double xyztol,
  int numoutfcs,
  PWobjid *p_outfcs,
  int numloops,
  enum PWptloctype *p_ptloc,
  PWobjid *p_bdryid,
  struct PWcvpt *p_edpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
