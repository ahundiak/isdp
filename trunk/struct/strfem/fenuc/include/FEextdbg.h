#ifndef FEextdbg_defined
#define	FEextdbg_defined

/* *****************************H H H H H******************************* */
/* Doc: FEextdbg.h

   Abstract:  These set of externs have been extracted from FEsetdbg.C in
	order that they may be reviewed in the include directory.  It is
	necessary if you only have the stripped version of ISAS.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      11/19/91	raj	2.0.0	Creation
      02/03/93	raju	2.2.0	Added .._CB
      05/27/93	raj	2.2.1	Added .._FLW
*/
/* *****************************H H H H H******************************* */

char	FE_DBG_FEG,	/* Structure and mesh related methods	*/
	FE_DBG_SOL,	/* Solver */
	FE_DBG_DPB,	/* Global classes, FErsman */
	FE_DBG_FD,	/* Boundary conditions */
	FE_DBG_MP,	/* Material and properties */
	FE_DBG_SMB,	/* Symbols for FD */
	FE_DBG_RPT,	/* Forward and back translation */
	FE_DBG_PFM,	/* Post analysis */
	FE_DBG_VER,	/* Verification */
	FE_DBG_SOB,	/* If TRUE do not delete FEsoln after analysis */
	FE_DBG_OQD,	/* Optional quad formulation : Temporary key */
	FE_DBG_APP,	/* APP module */
	FE_DBG_KEY1,	/* Additional keys */
	FE_DBG_KEY2,	/* Additional keys */
	FE_DBG_KEY3,	/* Additional keys */
	FE_DBG_GAP,	/* Additional keys */
	FE_DBG_GAP_GAP,	/* Additional keys */
	FE_DBG_CB,	/* Contact Body */
	FE_DBG_FLW;	/* FLOW */

#endif
