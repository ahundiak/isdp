/* $Id: v_drwenv.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/v_drwenv.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_drwenv.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
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
 * Revision 1.1  1995/04/03  15:47:46  pinnacle
 * Created: ./include/v_drwenv.h by azuurhou r#
 * rno
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/29/95	adz		creation
 *
 * -------------------------------------------------------------------*/

#ifndef v_drwenv_include
#define v_drwenv_include

#ifndef	godef_include
#	include "godef.h"
#endif

#ifndef	gr_include
#	include "gr.h"
#endif

#ifndef	igr_include
#	include "igr.h"
#endif

#ifndef	igrdp_include
#	include "igrdp.h"
#endif

#ifndef	go_include
#	include	"go.h"
#endif

/*
 * This file contains the data structure for the envelope information
 * during an object process.
 */

/*
 * Maximum number of Representations.
 */

#define		VD_K_drwRepMax		30

#define		VD_K_drwNameMax		80	/* idem ACrg_collect */
#define		VD_K_drwMatchMax	256

struct	VD_s_drwEnvRef {

	char	name[VD_K_drwNameMax];		/* Representation name.	*/
	double	rep_val ;			/* Representation value */
	char	match[VD_K_drwMatchMax];	/* Matching string	*/
};

typedef	struct	VD_s_drwEnvRef	VD_drwEnvRef ;


struct	VD_s_drwEnvInfo {

	int		env1_obj0 ;	/* Get envelope1_main0 object	*/

	int		yes_no ;	/* If env process is active	*/

	int		count ;		/* number of active representations */
	VD_drwEnvRef	rep[VD_K_drwRepMax];			/* Info List */
};

typedef	struct	VD_s_drwEnvInfo	VD_drwEnvInfo ;


#endif	/* v_drwenv_include */
