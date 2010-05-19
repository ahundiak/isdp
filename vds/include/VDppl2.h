/* $Id: VDppl2.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDppl2.h
 *
 * Description: To support struct detail macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDppl2.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/05/07  15:28:22  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/07/99  ah      Creation
 ***************************************************************************/

#ifndef VDppl2_include
#define VDppl2_include 1

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------------
 * All we really need from expression.h
 * Too much other garbage to include
 */
#ifndef expression_include
#define	EXP_DOUBLE	0
#define EXP_TEXT	4
#endif

/* --------------------------------------------
 * Utility for verifying an objects class
 */
extern IGRstat VDpplVerifyClass __((TGRid *objID, IGRchar *className));

/* --------------------------------------------
 * Utility for extracting obj_env from source
 */
extern IGRstat VDpplGetObjectEnv __((TGRid *objID, TGRobj_env *objOE));

/* --------------------------------------------
 * Gets the parent of a macro
 */
extern IGRstat VDpplGetParent __((TGRid       *macroID,
				  IGRint      index,
				  TGRobj_env *parentOE));
  
/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
extern IGRstat VDpplGetStructure __((TGRobj_env  *objOE,
				     IGRchar     *footName,
				     Tret_struct *data));

/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
extern IGRstat VDpplGetFootText __((TGRobj_env  *objOE,
				    IGRchar     *footName,
				    IGRchar     *data));

/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
extern IGRstat VDpplGetFootDouble __((TGRobj_env  *objOE,
				      IGRchar     *footName,
				      IGRdouble   *data));

/* -------------------------------------------------------------------------
 * This is a function that uses the template index and returns a text string
 * The parent is an expression
 */
extern IGRstat VDpplGetTextParent __((TGRid   *macroID, 
				      IGRint   index, 
				      IGRchar *data));

/* --------------------------------------------------------------------------
 * This is a function that uses the template index and returns a double
 * The parent is an expression
 */
extern IGRstat VDpplGetDoubleParent __((TGRid     *macroID, 
					IGRint     index, 
					IGRdouble *data));

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif

