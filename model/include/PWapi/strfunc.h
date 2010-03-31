#ifndef _strfunc_proto_h 
#define _strfunc_proto_h

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

#define STRING_MATCH 0

extern PWboolean pwFuzzyMatch _PW_((
  char *str,
  char *match
));

extern int pwNumFields _PW_((
  char *str
));

extern int pwGetInxOfField _PW_((
  int n,
  char *str
));

extern PWboolean pwFieldInStr _PW_((
  int n,
  char *str,
  char *field
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
