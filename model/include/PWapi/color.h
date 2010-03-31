#ifndef _color_h 
#define _color_h

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

extern PWresult pwGetColorMapSize _PW_((
  short *size,
  PWosnum osnum
));


extern PWresult pwGetColorMap _PW_((
  struct IGEvlt *rgb_val, 
  short *num_colors,
  PWosnum osnum
));

#if defined(__cplusplus) 
} 
#endif 

#endif 
