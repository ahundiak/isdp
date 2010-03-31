#ifndef _lpintpt_proto_h 
#define _lpintpt_proto_h

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

extern PWresult  pwLpInternalPts _PW_((
  PWobjid          lpobj,
  PWosnum          os,
  struct PWsfdata  *p_sfdata, 
  double           xyztol,
  int              callinx,
  int              num_pts,
  PWpoint2d        *p_pts
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
