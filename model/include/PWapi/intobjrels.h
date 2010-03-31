#ifndef _intobjrels_proto_h 
#define _intobjrels_proto_h

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

extern void    SetContainIntobj _PW_(( 
   struct EMSintobj       *p_intcv, 
   int                    side,
   enum  PWcontaintype    containment
));

extern enum PWcontaintype   GetContainIntobj _PW_((
   struct EMSintobj  *p_intcv,
   int               side
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
