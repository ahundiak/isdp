/* $Id: VREquipLst.c,v 1.2 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VREquipLst.c
 *
 * Description:
 * Functions accessing database to get equipments informations
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREquipLst.c,v $
 *	Revision 1.2  2002/04/15 20:01:45  anand
 *	Removed version.h and associated dependencies. version.h is
 *	an include file in $EXNUC.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.5  1996/05/07  19:14:40  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by hverstee for route240
 *
 * Revision 1.4  1996/04/22  13:57:36  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by hverstee for route240
 *
 * Revision 1.3  1996/04/04  21:43:20  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  17:31:02  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRdef.h"
#include "dberror.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbParamDef.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"
#include "VDmem.h"


#if 0

IGRint VRdbGetEqOccList (

   IGRlong	 		*msg,		/* Message		(O)*/
   IGRchar             		*catalog,	/* Catalog name		(I)*/
   IGRchar			*select_crit,	/* find with a criteria	(I)*/
   IGRchar			**EqNumber, 	/* EqNumber list	(O)*/
   IGRint			*NbOcc,		/* Nb return occurrences(O)*/
   struct  VRdbEquipDesc	*occlst,	/* List of catalog occur(O)*/
   IGRchar			*err_ptr)	/* Error Message Buffer	(O)*/
/*.VRdbGetEqOccList*/
{
    int			sts,i;
    static
    struct VRrisdat	outdata[300];
    int			rows;
    int			cols;
    char		*select=NULL;
    char		ris_str[MAX_RIS_STR_SIZE];
    char		disp_err[100];
 

  if( !select_crit )
  {
  	*NbOcc		= 0;
  	*EqNumber	= (IGRchar *) NULL;
  }

  if( select_crit )
  {
	select = "eqp_descr, eqp_location";
  	sprintf( ris_str,"SELECT %s FROM %s WHERE eqp_number = '%s'", 
						select, catalog,select_crit );
  }
  else
  {
	select = "eqp_number";
  	sprintf( ris_str,"SELECT %s FROM %s", select, catalog);
  }

  sts = RISexecute_query( ris_str, outdata, &rows, &cols, NbOcc);

  if (sts != 1 || rows == 0)
  {
	printf("Failed accessing %s for occ list.\n",catalog);
	printf("SELECT <%s>\nFROM <%s>\n", select, catalog);
	strcpy(disp_err, select);
	VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,catalog,"Column",disp_err);
	*msg = VR_E_DbShortErrMsg;
        return(OM_E_ABORT);
  }

  if( select_crit )
  {
	if(outdata[0].data.val.attr_c[0]!= 0)
		strcpy (occlst->Desc, outdata[0].data.val.attr_c);
	if(outdata[1].data.val.attr_c[0]!= 0)
		strcpy (occlst->Location, outdata[1].data.val.attr_c);
  }
  else
  {
	if( *NbOcc )
	{
   		*EqNumber = (IGRchar *) _MALLOC ( *NbOcc, IGRchar *);

  		for ( i=0; i<*NbOcc ;i++)
		{
 			if(outdata[i].data.val.attr_c[0]!= 0)
				EqNumber[i] = outdata[i].data.val.attr_c;
		}
	}
  }

   *msg = OM_S_SUCCESS;
   return OM_S_SUCCESS;
}

/*************************************************************************/

IGRint VRdbGetEqOccur (
  
   IGRlong	 		*msg,		/* Message		(O)*/
   IGRchar             		*catalog,	/* Catalog name		(I)*/
   IGRchar			*select_crit,	/* find with a criteria	(I)*/
   IGRchar			*MacroName,	/* PID macro name is returned*/
   struct  VRdbEquipPart	*occlst,	/* List of catalog occur(O)*/
   IGRchar			*err_ptr)	/* Error Message Buffer	(O)*/
/*.VRdbGetEqOccur*/
{
    int			sts;
    struct VRrisdat	outdata[300];
    int			rows;
    int			cols;
    int			NbOcc;
    char		ris_str[MAX_RIS_STR_SIZE];
    char		disp_err[100];
 
  if( MacroName )
  {  
  	sprintf( ris_str,"SELECT %s FROM %s WHERE eqp_number = '%s'", 
					"macro_name", catalog, select_crit );
  }
  else
  {
  	sprintf( ris_str,"SELECT %s FROM %s WHERE eqp_number = '%s'", 
		"eqp_family, eqp_partno, eqp_partrev", catalog, select_crit );
	
  }
  sts = RISexecute_query( ris_str, outdata, &rows, &cols, &NbOcc);
  if (sts != 1 || rows == 0)
  {
	printf("Failed accessing %s for occ list.\n",catalog);
	printf("SELECT eqp_number FROM <%s>\n", catalog);
	strcpy(disp_err, "eqp_number");
	VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,catalog,"Column",disp_err);
	*msg = VR_E_DbShortErrMsg;
        return(OM_E_ABORT);
  }

  if( MacroName )
  {
	if(outdata[0].data.val.attr_c[0]!= 0)
	  	strcpy ( MacroName, outdata[0].data.val.attr_c);
  }
  else
  {
  	if(outdata[0].data.val.attr_c[0]!= 0)
		strcpy (occlst->Familly, outdata[0].data.val.attr_c);

	if(outdata[1].data.val.attr_c[0]!= 0)
		strcpy (occlst->PartNb, outdata[1].data.val.attr_c);

	if(outdata[2].data.val.attr_c[0]!= 0)
		strcpy (occlst->PartRev, outdata[2].data.val.attr_c);
  }

   *msg = OM_S_SUCCESS;
   return OM_S_SUCCESS;
}

#endif
