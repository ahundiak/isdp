#ifndef _actreffl_proto_h 
#define _actreffl_proto_h

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

extern PWresult pwActivateReferenceFile _PW_((
   char *filename ,
   PWosnum *osn
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
