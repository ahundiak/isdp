#ifndef _reqfile_proto_h 
#define _reqfile_proto_h


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

extern FILE *pwRequestInFile _PW_((
));

extern FILE *pwRequestOutFile _PW_((
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
