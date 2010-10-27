/* $Id: SMxtglbldf.c,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/*************************************************************************
 * I/VDS>
 *
 * File:        smutil/func/SMxtglbldf.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMxtglbldf.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/03/20  18:29:44  pinnacle
 * Replaced: smutil/func/SMxtglbldf.c for:  by jwfrosch for vds.240
 *
 *
 * History:
 *      MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/21/96	  HF		Creation date
 *
 *************************************************************************/

/*
 * The only reason for the existence of this file is its convenience during debugging.
 *
 * Files containing definitions of global variables can be loaded dynamically only ONCE.
 *
 * Since this file does nothing but defining & initializing of some global variables,
 * it needs to be loaded only ONCE, thus removing the failure of dynamic loading,
 * caused by: "Illegal redefinition of variable ...", if these variables would have
 * been defined in either of the following files where they are used:
 *
 * 	 files:	smspace / func / SMSolUtil.I
 *		smutil  / func / SMextentSrf.I
 */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				GLOBAL VARIABLES				*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	SMExtSrf_OLD_CODE;	/*
				 * Controls execution of OLD or NEW [=default] code
				 * NEW code = execute BSxgmsfdst() in SMextentSrfRg()
				 * OLD code = execute BSsfxttpt () in SMextentSrfRg()
				 *
				 * Obsolete:
				 * ci=toggle_old : toggles SMExtSrf_OLD_CODE
				 */

int	SMExtSrf_Fil_Nm;	/*
				 * To control the extension of the names of the
				 * "extent.srf_<nn>" files which are created
				 * when VD_DEBUG == TRUE
				 */

int	SMExtSrf_Ext_Opt;	/*
				 * To control "ext_option" for BSxgmsfdst()
				 * in SMextentSrfRg() from within SMBndS1BySfs()
				 */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDExtentSrf_Glbl_Inits()
{
  SMExtSrf_OLD_CODE = 0;	/* NEW code = execute BSxgmsfdst() in SMextentSrfRg()	*/
  SMExtSrf_Fil_Nm   = 0;
  SMExtSrf_Ext_Opt  = 1;	/* Polynomial Extend	*/
}
