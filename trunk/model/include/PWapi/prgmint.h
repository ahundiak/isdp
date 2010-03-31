#ifndef _prgmint_proto_h 
#define _prgmint_proto_h

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

extern void pwStringContain  _PW_((
  enum PWcontaintype cont,
  char *str
));

extern int pwCvintpt  _PW_((
  struct PWcvintpt *cvintpt
));

extern void pwPrintCvintpt  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvintpt *cvintpt
));

extern int pwCvintpt_list  _PW_((
  struct PWcvintpt_list *cvintpt_list
));

extern void pwPrintCvintptList  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvintpt_list *cvintpts
));

extern int pwCvregion _PW_(( 
  struct PWcvregion *cvregion
));

extern void pwPrintCvregion _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvregion *cvregion
));

extern int pwCvregion_list  _PW_((
  struct PWcvregion_list *cvregion_list
));

extern void pwPrintCvregionList  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvregion_list *cvregions
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
