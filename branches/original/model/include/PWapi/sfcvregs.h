#ifndef _sfcvregs_proto_h 
#define _sfcvregs_proto_h

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

extern PWresult  pwCreateSfCvRegion _PW_((
  struct PWgeomid        *p_sfgmid,    
  struct PWcvdata        *p_cvdata,
  double                 xyztol,
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvregion_list **p_cvregs
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
