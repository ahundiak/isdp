#ifndef _rdgmdata_proto_h 
#define _rdgmdata_proto_h

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

extern enum PWcvdatatype pwCvtypeFromString  _PW_((
  char *str
));

extern enum PWsfdatatype pwSftypeFromString _PW_((
  char *str
));

extern PWboolean pwReadCvdata  _PW_((
  FILE *file,
  struct PWcvdata *cvdata
));

extern PWboolean pwReadPy2d _PW_((
  FILE *file,
  struct PWpoly2d *py
));

extern PWboolean pwReadPy  _PW_((
  FILE *file,
  struct PWpoly *py
));

extern PWboolean pwReadBspCv  _PW_((
  FILE *file,
  struct IGRbsp_curve *bspcv
));

extern PWboolean pwReadSfdata  _PW_((
  FILE *file,
  struct PWsfdata *sfdata
));

extern PWboolean pwReadBspSf _PW_((
  FILE *file,
  struct IGRbsp_surface *bspsf
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
