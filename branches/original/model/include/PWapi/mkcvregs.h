#ifndef _mkcvregs_proto_h 
#define _mkcvregs_proto_h

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

extern PWresult pwMakeCvRegions _PW_((
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvdata        *p_cvdata,
  PWosnum                os,
  double                 tol,
  struct PWcvregion_list **p_cvregions 
));


#if defined(__cplusplus) 
} 
#endif 

#endif 
