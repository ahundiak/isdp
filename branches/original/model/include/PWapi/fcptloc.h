#ifndef _fcptloc_proto_h 
#define _fcptloc_proto_h

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

extern PWresult   pwFcPtLocate _PW_((
           struct PWid      *p_lpid,
           PWpoint          xyzpt,
           PWpoint2d        uvpt,
           struct PWsfdata  *p_sfdata, 
           double           xyztol, 
           enum PWptloctype *p_ptloc, 
           PWobjid          *p_bdryid, 
           struct PWcvpt    *p_edpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
