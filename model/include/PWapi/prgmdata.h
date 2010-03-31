#ifndef _prgmdata_proto_h 
#define _prgmdata_proto_h

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

extern void pwStringCvtype _PW_((
  enum PWcvdatatype cvtype,
  char *str
));

extern void pwStringSftype  _PW_((
  enum PWsfdatatype sftype,
  char *str
));

extern void pwStringTopopos  _PW_((
  enum PWtopopostype pos,
  char *str
));

extern char *pwStringFeattype _PW_((
  enum PWfeattype feattype,
  char *str
));

extern int pwCvdata  _PW_((
  struct PWcvdata *cvdata
));

extern void pwPrintCvdata  _PW_((
  FILE *file,
  int num_indent,
  struct PWcvdata *cvdata
));

extern int pwPoly2d  _PW_((
  struct PWpoly2d *py
));

extern void pwPrintPy2d  _PW_((
  FILE *file,
  int num_indent,
  struct PWpoly2d *py
));

extern int pwPoly _PW_(( 
  struct PWpoly *py
));

extern void pwPrintPy  _PW_((
  FILE *file,
  int num_indent,
  struct PWpoly *py
));

extern int pwBspcurve  _PW_((
  struct IGRbsp_curve *cv
));

extern void pwPrintBspCv  _PW_((
  FILE *file,
  int num_indent,
  struct IGRbsp_curve *bspcv
));

extern int pwSfdata  _PW_((
  struct PWsfdata *sfdata
));

extern void pwPrintSfdata _PW_((
  FILE *file,
  int num_indent,
  struct PWsfdata *sfdata
));

extern int pwBspsurface _PW_((
  struct IGRbsp_surface *bspsf
));

extern void pwPrintBspSf  _PW_((
  FILE *file,
  int num_indent,
  struct IGRbsp_surface *bspsf
));

extern int pwCvpt  _PW_((
  struct PWcvpt *cvpt
));

extern void pwPrintCvpt  _PW_((
  FILE *outfile,
  int num_indent,
  struct PWcvpt *cvpt
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
