/* $Id: SMExtToRng.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMExtToRng.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMExtToRng.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "bserr.h"

/*Prototypes */
#include "bslenvec.h";
#include "bsmkvec.h"

#include "AS_status.h"

#define AS_DEBUG

from GRgraphics		import	GRgetrang;

/* --------------------

	Function that compute the range (world cs) of the given object
	and extend it of an offset or of a rate
	if offset and rate are NULL, only return the range
	
-----------------------*/

SMExtToRng(obj, md_env, offset, rate, Range)
struct GRid	*obj;		/* (I) object to extend range */
struct GRmd_env	*md_env;	/* (I) md_env of the object */
IGRdouble	*offset;	/* (I) extend of offset */
IGRdouble	*rate;		/* (I) extend of range + rate*range */
IGRdouble 	*Range;		/* (O) output range */
{
 int			i, status;
 IGRboolean		world;
 IGRlong		msg;
 BSrc			rc;
 IGRdouble		vect[3];

 if( (offset != NULL && rate != NULL) || obj == NULL || md_env == NULL 
 	|| Range == NULL) return 0;
 
 world = TRUE;
 status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &md_env->md_env.matrix_type,
                                md_env->md_env.matrix,
                                &world, Range),
                        senderid = NULL_OBJID,
                        targetid = obj->objid,
                        targetos = obj->osnum);
 as$status();
 if(!(status & msg & 1)) return(0) ;

 if(offset == NULL && rate == NULL) return 1;

 if(offset != NULL)
 	if( ! SMExtRng(Range, *offset) ) return 0;
 if(rate != NULL){
 	BSmkvec(&rc, vect, &Range[0], &Range[3]);
 	if(rc != BSSUCC) return 0;

 
 	for(i=0;i<3;i++) 
  	{
   		Range[i+0] = Range[i+0] - (*rate) * vect[i];
   		Range[i+3] = Range[i+3] + (*rate) * vect[i];
  	} 
 }
 return 1;
}

end implementation Root;

