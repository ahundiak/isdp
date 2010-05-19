/* $Id: VDcrexp.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp.S
 *
 * Description:
 *
 * Specification file for expression table manager
 *   abstract class declaring all messages for expression objects
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  08:19:20  pinnacle
# Replaced: vdtbl/mgr/VDcrexp.S for:  by ksundar for vds
#
# Revision 1.1  1997/10/21  03:57:46  pinnacle
# Created: vdtbl/mgr/VDcrexp.S by ksundar for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	10/03/97	Sundar		Creation Date      
 *
 * -------------------------------------------------------------------*/

class specification VDcrexp (0:1) of VDSroot;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vds.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"

instance  VDcrexp
{
  struct  VDdrwexp_tab    Expid_tab;

  variable struct VDdrwexp_data      Ldatarec[0];

};

/* -----------------         PUBLIC MESSAGES          --------------------- */

message  DBdelete  (IGRlong         *msg;
                    FILE            *OutFil);

/*    Deletes underlying database expression tables if userid matches

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
OutFile        I      yes        file to print message to

   ------------------------------------------------------------------------ */

message  VDcrexp_gtab  (IGRlong		*msg;
               struct VDdrwexp_tab   	*Tabrec;
	       IGRint			*NbExpData;	
	       struct VDdrwexp_data  	**ExpData);

/*    returns general criteria ID parameters

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         O      yes        Returned id record
NbExpData      O                 #of Expression data records
ExpData	       O                 Data records
   ------------------------------------------------------------------------ */

message  VDcrexp_init   (IGRlong	*msg;
                struct VDdrwexp_tab     *Tabrec;
		IGRint			NbExpDat;
		struct VDdrwexp_data    *Expdat);

/*     initializes in memory table criteria object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         I                 Table id record for object
NbExpDat       I		 #of Expression data records
ExpData        I                 Data records
   ------------------------------------------------------------------------ */

message  VDcrexp_fill   (IGRlong         *msg);

/*     Fill the expression object from the database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */
message  VDcrexp_gdata (IGRlong          *msg;
                         IGRint         *nCount;
                  struct VDdrwexp_data   **Data);
 
/*     get the data records
 
parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         O                 Number of records out
Data           O      yes        Data records

   ------------------------------------------------------------------------ */

override   VDPostYourselfToDb;

end specification VDcrexp;

