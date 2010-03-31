#ifndef _ptnesting_proto_h 
#define _ptnesting_proto_h

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

extern PWresult   pwPtNesting _PW_((
   struct PWid  *p_lpid,
   PWpoint2d    uvpt,
   double       xyztol,
   int          *p_lpcount,
   PWobjid      *p_outlpids
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
