#ifndef _dbgobjs_proto_h 
#define _dbgobjs_proto_h

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

extern void pwInitDbgObject _PW_((
  PWosnum osnum
));

extern void pwDeleteDbgObject _PW_((
));

extern void pwAddObjDbgObject _PW_((
  PWobjid grobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat
));

extern void pwAddCvDbgObject _PW_((
  struct PWcvdata *cvdata
));

extern void pwAddSfDbgObject _PW_((
  struct PWsfdata *sfdata
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
