/*
  DESCRIPTION

  This file contains the definitions of the macros exposed for general 
  consumption. 

  A good majority of them deal with the obtaining of geometry from objects.
  The main motivation behind writing macros instead of functions was to be
  able to use the stack-memory. Then, for the purpose of symmetry, similar
  macros that dealt with using the heap-memory were also written.

  Inclusion of the relevant Pathway structure and typedef defintion is 
  assumed. An easy way to include this file in your code is to include
  the file -- PWdef.h, followed by PWapi.h, followed by this file.
*/

#ifndef _PWmacros_include
#define _PWmacros_include

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


/*
 * Macros that are used to perform the very common functions dealing with
 * edge geometry. The "Stack" macro should be used whenever edge
 * geometry is being requested for within-the-function computations.
 * NOTES: These macros should be used with the same syntax as PW-API
 * functions that return a PWresult. This result must then be tested to
 * make sure the op was successful. A single-pointer is the argument to hold
 * the curve geometry as opposed to the more conventional double-pointer
 * used when invoking a function of similar behaviour.
 */

#define PW_GetEdGeomStack(edobj, os, eddata) \
( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetEdGeomHeap(edobj, os, eddata) \
( \
    (((eddata).data.py2d.p_pts = NULL) , \
     ((eddata).data.py.p_pts = NULL) , \
     ((eddata).data.p_bspcv = NULL) , \
     ((eddata).data.p_gmbspcv = NULL)) , \
    (pwGetEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetNatEdGeomStack(edobj, os, eddata) \
( \
 !((pwGetEdGeomType ((edobj), (os)) == PWcvdata_py2d) ? \
    (int) ((eddata).data.py2d.p_pts = (PWpoint2d *)  \
       alloca (pwGetEdGeomSize ((edobj), (os)))) : \
    (int) ((eddata).data.p_bspcv = (struct IGRbsp_curve *) \
       alloca (pwGetEdGeomSize ((edobj), (os))))) ? \
     (SetError (PW_K_Pathway, PW_K_DynamicMemory)) : \
     (pwGetNatEdGeom ((edobj), (os), &(eddata))) \
)

#define PW_GetNatEdGeomHeap(edobj, os, eddata) \
( \
    (((eddata).data.py2d.p_pts = NULL) , \
     ((eddata).data.py.p_pts = NULL) , \
     ((eddata).data.p_bspcv = NULL) , \
     ((eddata).data.p_gmbspcv = NULL)) , \
    (pwGetNatEdGeom ((edobj), (os), &(eddata))) \
)

/*
 * Macros that are used to perform the very common functions dealing with
 * surface geometry. The "Stack" macro should be used whenever surface
 * geometry is being requested for within-the-function computations. 
 * NOTES: These macros should be used with the same syntax as PW-API 
 * functions that return a PWresult. This result must then be tested to 
 * make sure the op was successful. A single-pointer is the argument to hold 
 * the surface geometry as opposed to the more conventional double-pointer 
 * used when invoking a function of similar behaviour.
 */

#define PW_GetSfBspsfStack(sfobj, os, mattyp, p_matrix, p_bspsf) \
  ( \
    pwGetSfAsBspline (sfobj, os, mattyp, p_matrix, \
     p_bspsf = (struct IGRbsp_surface *) \
                alloca (pwGetSfSize (sfobj, os))) \
  ) 

#define PW_GetSfBspsfHeap(sfobj, os, mattyp, p_matrix, p_bspsf) \
  ( \
    pwGetSfAsBspline (sfobj, os, mattyp, p_matrix, \
     p_bspsf = (struct IGRbsp_surface *) \
                malloc (pwGetSfSize (sfobj, os))) \
  ) 

#define PW_GetSfGmbspsfStack(sfobj, os, mattyp, p_matrix, p_gmbspsf) \
  ( \
    pwGetSfAsGeomBspline (sfobj, os, mattyp, p_matrix, \
     (struct IGRbsp_surface *) \
      alloca (pwGetSfSize (sfobj, os)), \
     p_gmbspsf = (struct BSgeom_bsp_surf *) \
      alloca (sizeof (struct BSgeom_bsp_surf))) \
  ) 

#define PW_GetSfGmbspsfHeap(sfobj, os, mattyp, p_matrix, p_gmbspsf) \
  ( \
    pwGetSfAsGeomBspline (sfobj, os, mattyp, p_matrix, \
     (struct IGRbsp_surface *) \
      malloc (pwGetSfSize (sfobj, os)), \
     p_gmbspsf = (struct BSgeom_bsp_surf *) \
      malloc (sizeof (struct BSgeom_bsp_surf))) \
  ) 

#endif
