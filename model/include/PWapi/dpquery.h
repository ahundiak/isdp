#ifndef _dpquery_proto_h 
#define _dpquery_proto_h

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

extern PWresult pwGetDpbParam _PW_((
  PWosnum osnum,
  int param,
  char *buffer
)
);



#if defined(__cplusplus) 
} 
#endif 

#endif 
