#ifndef _uomunit_proto_h 
#define _uomunit_proto_h

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

extern PWboolean pwIsMetric _PW_((
  PWosnum osnum
));

extern PWresult uomGetUnits _PW_(( 
  PWosnum osnum,
  char units[]
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
