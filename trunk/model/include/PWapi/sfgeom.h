#ifndef _sfgeom_h 
#define _sfgeom_h

#include <alloca.h>

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

extern PWresult pwGetSfAsBspline _PW_((
  PWobjid sfobj, 
  PWosnum os,
  short mattyp,
  PWmatrix matrix,
  struct IGRbsp_surface *p_sfgeom
));

extern int pwGetSfSize _PW_((
  PWobjid sfobj,
  PWosnum os
));

extern PWresult pwSfAsGeomBspline _PW_((
  PWobjid sfobj,
  PWosnum os,
  struct IGRbsp_surface *bspsf,
  struct BSgeom_bsp_surf *gmbspsf
));

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

#if defined(__cplusplus) 
} 
#endif 

#endif 
