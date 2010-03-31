#ifndef _ref_h 
#define _ref_h

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

extern int pwGetNumRefFiles _PW_((
  PWosnum osnum
));


extern PWresult pwGetRefFiles _PW_((
  PWosnum osnum,
  int *NumRefFiles,
  char **RefFileNames 
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
