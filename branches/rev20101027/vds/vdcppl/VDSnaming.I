/* $Id: VDSnaming.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDSnaming.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSnaming.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include	"DImacros.h"

from	GRvg		import	GRchgname;

/* ******************************************************************** */
/* This function generate an automatic naming of a macro's occurence.	*/
/* ******************************************************************** */

IGRlong generate_occ_name ( mac_name, mac_id, mod_env, msg)

	IGRchar				*mac_name;	/* macro name     (I) */
	struct		GRid		mac_id;		/* macro ID	  (I) */
	struct		GRmd_env	*mod_env;	/* module env	  (I) */
	IGRlong				*msg;	  	/* error message  (O) */

{
	IGRint				status;
	IGRchar				occ_zero[256];
	IGRchar				occ_name[256];
	struct		GRid		objet_id;
	IGRchar				*c;
	IGRchar				*c1;
	IGRint				i;

	sprintf ( occ_zero, "%s_00", mac_name);
	strcpy ( occ_name, occ_zero);

	/* Search identic name */
	*msg = di$translate ( objname = occ_zero,
			      p_objid = &objet_id.objid,
			      p_osnum = &objet_id.osnum );

	if (*msg == DIR_S_SUCCESS) {

		/* If objname like name_## find pointer on suffix */
		c = (IGRchar *) strrchr ( occ_name, '_');
		if (c != NULL) {
			i = strtol ( c+1, &c1, 10);
			if (*c1 != '\0') c = NULL;
		}
		if (c == NULL) c = occ_name + strlen(occ_name);

		/* Find correct suffix */
		for (i=0; i<1000; i++) {
			if (i<100) sprintf ( c, "_%02d", i);
			else	   sprintf ( c, "_%03d", i);
			*msg = di$translate ( objname = occ_name,
                             		      p_objid = &objet_id.objid,
                             		      p_osnum = &objet_id.osnum );
			if (*msg != DIR_S_SUCCESS) break;
		}

		/* Generate name + suffix */
		if (i >= 1000) occ_name[0] = '\0';
		else {
			c = (IGRchar *) strrchr ( occ_name, ':');
			if (c == NULL) c = occ_name;
			else	       c = c +1;
			strcpy ( occ_name, c);
		}
	}

	status = om$send ( msg      = message  GRvg.GRchgname ( msg,
							        mod_env,
							        occ_name),
                           senderid = NULL_OBJID,
                           targetid = mac_id.objid,
                           targetos = mac_id.osnum );
	if (!(status&1&(*msg)))
        	printf ( "GRvg.GRchgname status=%d, msg=%d\n", status, *msg );
	
	return (status);
} 

end implementation Root;
