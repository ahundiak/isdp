/* $Id: VCCONdb.I,v 1.2 2001/02/20 01:10:07 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:	vccmdconn / VCCONdb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCCONdb.I,v $
 *	Revision 1.2  2001/02/20 01:10:07  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/10/20  15:22:40  pinnacle
# Replaced: vccmdconn/VCCONdb.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/11/30  15:40:02  pinnacle
# Created: vccmdconn/VCCONdb.I by r250_int for route
#
# Revision 1.1  1997/11/17  23:23:06  pinnacle
# Created: vccmdconn/VCCONdb.I by kddinov for cabling
#
 *
 * History:
 *	MM/DD/YY   	AUTHOR		DESCRIPTION
 *	11-97		KDD		creation 
 *      10/06/98        Alwin           Modified the VCGetNumOfDatabaseConn
 *                                      to return the proper max_limit for
 *                                      fiber-optic terminals.
 *
 *************************************************************************/
class implementation VCCmdCON;

#include "vdreporterr.h"
#include "vc_structs.h"
#include "vrdbgmacros.h"

from VCDB	import	VCGetAttr;

/*------------------------------------------------------------------------------
*  This methos gets the DB defined max number of cable lead connections per
*  terminal position and module. 
*-----------------------------
*
* Parameters:
*
* O!:   IGRlong  *msg          - return status.
* I:   struct VCTpos   *PinId - position definition (vc_structs.h) 
*				PinId.szModId (module Id)
*				PinId.szPosId (position id)
*
* I/O: int      *index  - index  for this Pin (ModId, PosId) in the structure
*                         me->PinConnect.  Used as input if PinId == NULL
*
* O:   int	*limit	- number of DB predefinerd connections for this PinId
*				may be NULL.
------------------------------------------------------------------------------*/
method VCGetNumOfDatabaseConn ( IGRlong 	*msg;	
				struct VCTpos	*PinId;
                                int     	*index;
				int		*limit)
{
	IGRlong			retmsg;
	char			text[256];
	int			i, status = 1;
	struct VCpos		PinPos;
	struct ret_struct	res;

   SetProc( Md VCGetNumOfDatabaseConn ); Begin

   if ( !PinId && !index ) goto wrapup;

   if ( me->Product != VC_PROD_ELEC )   {

      /* added by alwin for TR179801275 */
      /* Setting the "max_connect=1" for the Fiber-Optic Terminals pins */
      /* In future in case if Clark comes with some specification to modify
      then we need to change accordingly. Alwin */

      if ( limit ) *limit = 1;
      goto wrapup;

      /**** Commenting this, as this will disturb the user. Alwin

      sprintf( text, "max_connect is defined for Electrical Terminals only");
      vd$report_error(error = text, mode = 1 );
      status = 0;

      ****/
   }

   PinPos.nType = VC_TERM_TYPE;

/* for (me->Product == VC_PROD_FO) you might use VC_N_BANDWIDTH_DB */

/*---- Get the DB Pin connect limit ----*/

   if ( PinId ) { 
	PinPos.Conn.Term = *PinId; 

        /*--- Get the index for this PinId , If requested--*/

        for ( i = 0; (i < me->DBNumPins) && (index) ; i++ ) { 

        if (!strcmp(PinPos.Conn.Term.szModId, me->PinConnect[i].PinId.szModId)&&
            !strcmp(PinPos.Conn.Term.szPosId, me->PinConnect[i].PinId.szPosId)){
       
          	*index = i;
          	break;
          }
        }
   }
   else  	{ 
	PinPos.Conn.Term = me->PinConnect[ *index ].PinId; 
   }

   status = om$send (msg     = message VCDB.VCGetAttr (&retmsg,
                                  	&PinPos, VC_N_MAX_CONNECT_DB, &res),
                    targetid = me->ModelId.objid,
                    targetos = me->ModelId.osnum);

   if ( limit) *limit = (int) res.var.root_pm_st.value;


wrapup:
*msg = status;
End
return (status);
}

/*------------------------------------------------------------------------------
*  This methos gets the number of currently connected cable leads to 
*  a given terminal Pin (position and module). 
*-----------------------------
*
* Parameters:
*
* O:   IGRlong	*msg	      - return status.
* I:   struct VCTpos   *PinId - position definition (vc_structs.h)
*                               PinId.szModId (module Id)
*                               PinId.szPosId (position id)
* I/O: int	*index 	      - Pin index in the structure me->PinConnect.
*			  	Used as input if PinId == NULL
*
* O:   int	*NumConn      - number of connections. 
------------------------------------------------------------------------------*/
method VCGetNumOfConnections( 	IGRlong		*msg;
                                struct VCTpos   *PinId;
				int		*index;
				int		*NumConn)
{
	int		i, count=0, status = 1;

   SetProc( Md VCGetNumOfConnections ); Begin 

   if ( !PinId && !index ) goto wrapup;

/*---- Get the number of connections for that pin ----*/
 
   if ( PinId ) {
	__DBGpr_int( " Nb. of Pins in the Terminal ", me->DBNumPins );
        for ( i = 0; i < me->DBNumPins ; i++ ) {

	    __DBGpr_str( " Selected Pin ModId ", PinId->szModId );
	    __DBGpr_str( " Selected Pin PosId ", PinId->szPosId );

	    __DBGpr_str( " DB Pin ModId ", me->PinConnect[i].PinId.szModId );
	    __DBGpr_str( " DB Pin PosId ", me->PinConnect[i].PinId.szPosId );

            if (!strcmp(PinId->szModId, me->PinConnect[i].PinId.szModId)&&
                !strcmp(PinId->szPosId, me->PinConnect[i].PinId.szPosId)){
 
                if (index)   *index = i;
                count = me->PinConnect[i].NumConnect;

                break;
            }
        }
   }
   else {
	count = me->PinConnect[ *index ].NumConnect;
   }

   __DBGpr_int( " Nb. of Connections in pin ", count );
 
wrapup:
   if ( NumConn ) *NumConn = count;
*msg = status;
End
return (status); 
}

end implementation VCCmdCON;

