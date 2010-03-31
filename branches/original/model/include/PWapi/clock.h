#ifndef _clock_proto_h 
#define _clock_proto_h

#if defined(__STDC__) || defined(__cplusplus) 
#ifndef _PW_ 
#define _PW_(args) args 
#endif 
#else 
#ifndef _PW_ 
#define _PW_(args) () 
#endif 
#endif 

#define MAX_CLOCKS 20

#if defined(__cplusplus) 
extern "C" 
{ 
#endif

extern void pwInitClocks _PW_((
));

extern void pwInitClock _PW_((
  int clock_number
));

extern void pwStartClock _PW_((
  int clock_number
));

extern void pwStopClock _PW_((
  int clock_number
));

extern void pwPrintClock _PW_((
  FILE *file,
  int clock_number
));

extern int pwGetRealTime _PW_((
  int clock_number
));

extern int pwGetUserTime _PW_((
  int clock_number
));

extern int pwGetSysTime _PW_((
  int clock_number
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
