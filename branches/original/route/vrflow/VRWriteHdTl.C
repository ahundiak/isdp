/* $Id: VRWriteHdTl.C,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / VRWriteHdTl.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRWriteHdTl.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/16  23:55:36  pinnacle
 * Replaced: vrflow/VRWriteHdTl.C for:  by r240_int for route240
 *
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *
 *************************************************************************/
#include	<stdio.h>
#include	<time.h>
#include 	<math.h>
#include	"OMminimum.h"
#include 	"OMerrordef.h"
#include	"OMlimits.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"gr.h"
#include	"VRDbStruct.h"
#include 	"OMprimitives.h"
#include	"exmacros.h"
#include	"AS_status.h"
#include	"vrpdu_pto.h"

extern	FILE		*DbgFilePtr;

/*D
	Function : VRWriteNozResInfoHdr()

	Author	: Manyam

	Date	: 19th July 1994

	Abstract : Writes the header for the file ( in to which the 
	information about the nozzles will be written during resizing ).

	Future Scope : Make a macro with a flag which indicates the
	analysis under consideration, which writes the headers for
	diff types of out put files required.
*/ 

IGRint	VRWriteNozResInfoHdr()
{

	IGRint		status;

	if (!DbgFilePtr )
		return	OM_E_ABORT;

	fprintf( DbgFilePtr, "\n" );
	fprintf( DbgFilePtr, 
	"\t\tSuggested  Modifications to the Nozzles in the Network\n");
	fprintf( DbgFilePtr, 
	"\t\t--------   ------------- -- --- ------- -- --- -------\n");

	/*A get the Design File name */
	{
		struct	GRid	ModId;
		IGRchar		cOsName[OM_K_MAXOSNAME_LEN];
		IGRchar		*cPtr, *cDelimiter, *cTime;
		time_t		Time;

		status =
		ex$get_cur_mod(	id	= &ModId.objid,
				osnum	= &ModId.osnum	);
		as$status();

		status =
		om$os_number_to_name(	osnum	= ModId.osnum,
					osname	= cOsName	);
		as$status( action = RET_STATUS );

		cDelimiter = "/";
		cPtr = (char *)strrchr( cOsName, (int)*cDelimiter );
		cPtr=cPtr+1;

		fprintf(DbgFilePtr, "\n" );
		fprintf( DbgFilePtr, "\tDesign File Name : %-14s", cPtr );

		/*A write the time also	*/
		fprintf( DbgFilePtr, "\t Time : ");

		/*A put the time stamp	*/
		Time = time( &Time );
		cTime = (char * ) asctime( localtime( &Time ) );

		fprintf( DbgFilePtr, "%s\n", cTime );

	}

	fprintf( DbgFilePtr, "\n" );
        fprintf( DbgFilePtr,
	"--------------------------------------------------------------------------------\n");

	fprintf( DbgFilePtr,
	" %-15s %-10s %-10s %-10s %-40s\n",
	"  TAG-NUMBER", "FLOW-RATE", "VELOCITY", 
	"EQUIVALENT", "       SECTION-PARAMETERS" );

	fprintf( DbgFilePtr,
	" %-37s %-10s %-40s\n",
	"", " DIAMETER", "     Before	      After" );

	fprintf( DbgFilePtr,
	" %-48s %-40s\n",
	"", "    Resizing	     Resizng" );

	fprintf( DbgFilePtr,
	" %-48s %-40s\n",
	"", " Width   Depth  Width   Depth" );

        switch( VRenq_proj_units() )
        {
          case VR_IMPERIAL_UNITS:
                fprintf( DbgFilePtr,
                "%-15s %-10s %-10s %-10s %-40s\n",
                ""," ( cfm )"," (ft/sec)", "   ( in )",
			"   (in)    (in)   (in)    (in )" );

                break;

          case VR_METRIC_UNITS:
          case VR_MIXED_UNITS:
                fprintf( DbgFilePtr,
                "%-15s %-10s %-10s %-10s %-40s\n",
                "","( m3/min )"," ( m/sec)", "   ( mm )",
			"   (mm)    (mm)   (mm)    (mm )" );

               break;
        }
        fprintf( DbgFilePtr, 
	"--------------------------------------------------------------------------------\n");

	return	OM_S_SUCCESS;
}

/*D
	Function : VRWriteNozResInfoTail()

	Author	: Manyam

	Date	: 19th July 1994

	Abstract : Writes the Tail info for the file ( in to which the 
	information about the nozzles will be written during resizing ).
	
*/ 

IGRint	VRWriteNozResInfoTail()
{

	if ( !DbgFilePtr )
		return	OM_E_ABORT;

	fprintf( DbgFilePtr, "\n" );
        fprintf( DbgFilePtr,
	"--------------------------------------------------------------------------------\n");

	return	OM_S_SUCCESS;
}

