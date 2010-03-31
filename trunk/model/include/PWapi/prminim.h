#ifndef _prminim_proto_h 
#define _prminim_proto_h

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

extern int pwPoint2d _PW_((
  PWpoint2d pt
));

extern void pwPrintPt2d _PW_((
  FILE *file,
  int num_indent,
  PWpoint2d pt
));

extern int pwPoint  _PW_((
  PWpoint pt
));

extern void pwPrintPt  _PW_((
  FILE *file,
  int num_indent,
  PWpoint pt
));

extern void pwPrintId _PW_((
  FILE *file,
  int num_indent,
  PWobjid objid,
  PWosnum os
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
