#ifndef _sortgmint_proto_h 
#define _sortgmint_proto_h

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

extern PWresult pwSortCvintptList _PW_((
  struct PWcvintpt_list  **p_cvintpts,    /*  I/O  */
  double                 tol               /*   I   */
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
