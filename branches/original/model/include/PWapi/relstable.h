#ifndef _relstable_proto_h 
#define _relstable_proto_h

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


extern PWresult  pwInitializeRelsTable _PW_((
   struct PWrelstable *p_intable
));

extern void  pwUninitializeRelsTable _PW_((
));

extern void   pwGetBooleanRelsTable _PW_((
   int                  optyp, 
   struct PWrelstable   *p_table 
));

extern void    pwValidateIntRels _PW_((
   struct EMSintobj     *p_intcv 
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
