#ifndef _isopts_proto_h 
#define _isopts_proto_h

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

extern PWboolean pwIsUvPtsIso _PW_((
  int num_uvpts,
  PWpoint2d *p_uvpts,
  double uvtol,
  int *isodir
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
