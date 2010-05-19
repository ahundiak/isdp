/* $Id: VDdraw.h,v 1.1 2001/08/02 15:29:08 ahundiak Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDdraw.h
 *
 * Description: Some simple drawing routines
 *
 *
 * Dependencies:
 *
 * Revision History:
 *    $Log: VDdraw.h,v $
 *    Revision 1.1  2001/08/02 15:29:08  ahundiak
 *    ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION 
 * 08/02/01  ah      Created
 * -------------------------------------------------------------------*/
#ifndef VDdraw_include
#define VDdraw_include

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * vds/vdah/om/VDdraw.I
 * env == NULL implies use active env
 */
extern IGRstat VDdrawCurve     __((TGRbsp_curve *crv, 
				   TGRmd_env    *env, 
				   TGRid        *newID));

extern IGRstat VDdrawLinear    __((IGRint     numPts, 
				   IGRdouble *pts, 
				   TGRmd_env *env, 
				   TGRid     *newID));

extern IGRstat VDdrawCopyCurve __((TGRobj_env *objOE, 
				   TGRmd_env  *env, 
				   TGRid      *newID));

extern IGRstat VDdrawSurface   __((TGRbsp_surface *srf,
				   TGRmd_env    *a_env, 
				   TGRid        *a_newID));


extern IGRstat VDdrawCS        __((IGRdouble *matrix,
				   TGRmd_env *a_env, 
				   TGRid     *a_newID));


//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
