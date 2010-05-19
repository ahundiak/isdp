/* $Id: VDbatData.S,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatData.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDbatData.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.1  1995/07/25  21:03:54  pinnacle
# Created: vdbatch/imp/VDbatData.S by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *
 ***************************************************************************/

class specification VDbatData (1:0) of GRcmpowner;

/*----------------------------------------------------------------------------
Desc :   Object which holds control data for batch extraction of drawings.
	 There will be maxinum of one object of this class in a design file.

  Raju   7/12/1995    Creation
------------------------------------------------------------------------------*/

#include "growner.h"
#include "vdbatdrw.h"

instance  VDbatData
{
  IGRint			     nbDv;	   /* no. of dwg views in file
						    */
  variable VDdrwBatchInfo	     batchInfo[0]; /* info. of each dwg view */
  IGRchar			     queue[15];     /* queue on which batch is
						    * submitted
						    */
  IGRchar			     login[10];	   /* login on local system */
  IGRchar			     passwd[10];    /* passwd on local system */
  IGRboolean			     procType;
				     /* VD_BATCH_PROC : batch processing
				      * VD_INTER_PROC : Interactive proc.
				      */
  struct GRid			     locateWin;
				     /* window that is to be used for locating
				      * objects inside and ovelapping.
				      */
};


/*----------------------------------------------------------------------------
 Message:  VDretrieveData

 Desc:   Method to retrieve the control data from this object
------------------------------------------------------------------------------*/
message VDretrieveData (
  IGRlong		*msg;		/* O - return status */
  IGRlong		*nbDV;		/* O - no. of dwg views */
  VDdrwBatchInfo	**batchInfo;	/* O - batch info of each dwg view
					 *     = NULL, if not required
					 *     != NULL, memory is allocated
					 *		by method. Should
					 *		be freed by caller.
					 */  
  IGRchar		*queue;		/* O - queue name */
  IGRchar		*login;		/* O - login on local system */
  IGRchar		*passwd;	/* O - passwd for login      */
  IGRboolean		*procType;	/* VD_BATCH_PROC : batch processing
					 * VD_INTER_PROC : Interactive proc.
					 * = NULL, if not needed.
					 */
 struct GRid		*locateWin;	/* O - locate window.
					 * = NULL, if not needed.
					 */
);

/*----------------------------------------------------------------------------
 Message:  VDpostData

 Desc:   Method to post the control data to this object.
------------------------------------------------------------------------------*/
message VDpostData (
  IGRlong		*msg;		/* O - return status  */
  IGRlong		nbDV;		/* I - no. of drawing views */
  VDdrwBatchInfo	*batchInfo;	/* I - batch info of dwg views */
  IGRchar		*queue;		/* I - queue name, =NULL if not
					 *     required to post
					 */
  IGRchar		*login;		/* I - login on local system
					 *     = NULL, if not needed to
					 *	post.
					 */
  IGRchar		*passwd;	/* I - passwd on local system
					 *     = NULL, if not needed to
					 *	post.
					 */
  IGRboolean		*procType;	/* VD_BATCH_PROC : batch processing
					 * VD_INTER_PROC : Interactive proc.
					 *     = NULL, if not needed to
					 *	post.
					 */
  struct GRid		*locateWin;	/* I - locate window.
					 *     = NULL, if not needed to
					 *	post.
					 */
);


/*---------------------------------------------------------------------------
 Message:  wakeup

 Desc :  Method to initialize the instance data. Called when this object is
	 created.
-----------------------------------------------------------------------------*/
message wakeup(
  long		*msg;		/* O - return status */
);

end specification VDbatData;
