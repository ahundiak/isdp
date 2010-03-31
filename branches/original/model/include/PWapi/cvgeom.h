#ifndef _cvgeom_proto_h 
#define _cvgeom_proto_h

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

extern PWresult pwGetCvAsBspline _PW_((
  PWobjid                 cvobj, 
  PWosnum                 os,
  short                   mattyp,
  PWmatrix                matrix,
  struct IGRbsp_curve     *p_cvgeom
));

extern int  pwGetCvSize  _PW_((
  PWobjid  cvobj,
  PWosnum  os
));

extern PWresult pwGetCvAsCvdata _PW_((
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  struct PWcvdata  *p_cvdata
));

extern enum PWcvdatatype pwGetCvType _PW_((
  PWobjid cvobj, 
  PWosnum os
));

extern int pwGetCvAsCvdataSize _PW_((
  PWobjid cvobj,
  PWosnum os
));

extern PWresult pwGetCvEndPts  _PW_((
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  PWpoint          Start,
  PWpoint          End
));


/*
 * Macros that are used to perform the very common functions dealing with
 * curve geometry. The "Stack" macro should be used whenever curve
 * geometry is being requested for within-the-function computations.
 * NOTES: These macros should be used with the same syntax as PW-API
 * functions that return a PWresult. This result must then be tested to
 * make sure the op was successful. A single-pointer is the argument to hold
 * the curve geometry as opposed to the more conventional double-pointer
 * used when invoking a function of similar behaviour.
 */

#define PW_GetCvBspcvStack(cvobj, os, mattyp, matrix, p_bspcv) \
  ( \
    pwGetCvAsBspline ((cvobj), (os), (mattyp), (matrix), \
     (p_bspcv) = (struct IGRbsp_curve *) \
                  alloca (pwGetCvSize ((cvobj), (os)))) \
  )

#define PW_GetCvBspcvHeap(cvobj, os, mattyp, matrix, p_bspcv) \
  ( \
    pwGetCvAsBspline ((cvobj), (os), (mattyp), (matrix), \
     (p_bspcv) = (struct IGRbsp_curve *) \
                  malloc (pwGetCvSize ((cvobj), (os)))) \
  )

#define PW_AllocBspCvStack(npoles, order, rational, curve) \
  ( \
    (((curve).poles = (double *) alloca ((npoles) * sizeof (PWpoint))) && \
    ((curve).knots = (double *) alloca (((npoles)+(order)) * \
                                        sizeof (double))) && \
    (rational ? (int) ((curve).weights = (double *) alloca ((npoles) * \
                                        sizeof (double)))   : TRUE)) ? \
    (PW_K_Success) : SetError (PW_K_Pathway, PW_K_DynamicMemory) \
  )

#define PW_AllocBspCvHeap(npoles, order, rational, curve) \
  ( \
    (((curve).poles = (double *) malloc ((npoles) * sizeof (PWpoint))) && \
     ((curve).knots = (double *) malloc (((npoles)+(order)) * \
                                        sizeof (double))) && \
     (rational ?  (int) ((curve).weights = (double *) malloc ((npoles) * \
                                        sizeof (double)))   : TRUE)) ? \
     (PW_K_Success) : SetError (PW_K_Pathway, PW_K_DynamicMemory) \
  )

#define PW_GetCvCvdataStack(cvobj, os, mattyp, matrix, cvdata) \
  ( \
    ((pwGetCvType ((cvobj), (os)) == PWcvdata_py) ? \
      (int) ((cvdata).data.py.p_pts = (PWpoint *) alloca \
                                   (pwGetCvAsCvdataSize ((cvobj), (os)))) : \
      (int) ((pwGetCvType ((cvobj), (os)) == PWcvdata_bspcv) ? \
        (int) ((cvdata).data.p_bspcv = (struct IGRbsp_curve *) alloca \
                          (pwGetCvAsCvdataSize ((cvobj), (os)))) : TRUE)) ? \
    (pwGetCvAsCvdata ((cvobj), (os), (mattyp), (matrix), &(cvdata))) : \
    (SetError (PW_K_Pathway, PW_K_InvalidArg)) \
  )

#define PW_GetCvCvdataHeap(cvobj, os, mattyp, matrix, cvdata) \
  ( \
    ((pwGetCvType ((cvobj), (os)) == PWcvdata_py) ? \
      (int) ((cvdata).data.py.p_pts = (PWpoint *) malloc \
                                   (pwGetCvAsCvdataSize ((cvobj), (os)))) : \
      (int) ((pwGetCvType ((cvobj), (os)) == PWcvdata_bspcv) ? \
        (int) ((cvdata).data.p_bspcv = (struct IGRbsp_curve *) malloc \
                          (pwGetCvAsCvdataSize ((cvobj), (os)))) : TRUE)) ? \
    (pwGetCvAsCvdata ((cvobj), (os), (mattyp), (matrix), &(cvdata))) : \
    (SetError (PW_K_Pathway, PW_K_InvalidArg)) \
  )

#if defined(__cplusplus) 
} 
#endif 

#endif 
