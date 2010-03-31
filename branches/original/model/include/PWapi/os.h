#ifndef _os_proto_h 
#define _os_proto_h

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

extern PWresult omRuntimeInit _PW_((
));

extern PWresult omConstructOS  _PW_((
  char *filename,
  PWobjid *osobjid,
  PWosnum *osnum,
  int *numobjs_in_space
));

extern PWresult omFileNameToOS  _PW_((
  char *filename,
  PWosnum *osnum
));

extern PWresult omDeleteOS _PW_((
  PWosnum osnum
));

extern PWresult omWriteOS  _PW_(( 
  PWosnum osnum,
  PWobjid osobjid
));

extern PWresult omCloseOS  _PW_((
  PWosnum osnum
));

extern PWresult omGetFileName  _PW_((
  PWosnum os,
  char *filename
));

extern PWresult omGetProdVersion _PW_((
  PWosnum os,
  char *prodname,
  int ver[4]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 

