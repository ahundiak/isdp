#ifndef _bits_proto_h 
#define _bits_proto_h

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

extern unsigned pwGetBits _PW_(( 
  unsigned word, 
  int pos, 
  int nbits 
));

extern void pwSetBits _PW_(( 
  unsigned *word, 
  int pos, 
  int nbits, 
  int mask 
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
