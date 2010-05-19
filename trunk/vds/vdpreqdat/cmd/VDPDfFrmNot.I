/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdpdefault/cmd/VDPDfFrmNot.I
 *
 * Description:
 *      Implementation of the following method for VDPCmdPMDef :
 *              form_notification
 *
 * Dependencies:
 *
 * History:
 *
 *      09/26/95 	MSM		Creation
 *	09/23/96	MRA		Added code to clear ship dependent
 *					form gadgets,  on new ship selection.
 *	09/23/96	MRA		Added code to create PlCtx-File relship.
 *
 */

class implementation VDPCmdPMDef;

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "PDUstr.h"

extern struct PDUrefresh        *refresh;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the required PME data form.

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input

  Algorithm
  


 -------------------------------------------------------------------------
-mo*/

method form_notification( int      form_label;
                          int      gadget_label;
                          double   value;
                          char     *form_ptr )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRlong		msg;
    IGRint		i, sel, pos, row,
			resp;
    IGRchar		BwcName[VDPNAME_LEN],
			ESWBS[VDPESWBS_LEN],
			ESWBS_Desc[VDPDESC_LEN],
			CtxType,
			CtxSubTypeDesc[VDPDESC_LEN],
			CtxName[VDPNAME_LEN],
			ShipName[VDPDESC_LEN];
    IGRchar		CtxTypeName[VDPNAME_LEN],
			ClassName[VDPCLASS_NAME_LEN];

    IGRint		CtxSubType,
			NbBdgWtCtx, NbESWBS,
			NbPlCxTST, NbCtxNames,
			nbCtx, nbShips;
    struct VDPNameDesc          *Contexts=NULL;

    IGRchar             FileId[VDPOBID_LEN];

    SetProc( VDCmdPMdef.form_notification ); Begin
    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );

    switch (gadget_label)
    {
	case FI_ACCEPT :

	  /* Validate Inputs */
	  status = _VD_SEND_MY ( VDPCmdPMDef.VDPValidateInput ( &msg ));
	  CheckRC( status, msg );

	  if( !(status & msg & 1) )
	  {
	     UI_status("Invalid Inputs" );
	     goto wrapup;
	  }

	  /* Get the OBID of the associated PmFile object */
          status = VDPqueryFileId ( &msg, refresh->act_catalog,
				    refresh->act_partid, refresh->act_revision,
                                    FileId );
	  CheckRC( status, msg );

	  if( !(status & msg & 1) )
	  {
	     UI_status("Error getting File Id\n" );
	     goto wrapup;
	  }

	  /* Create relationship between file and placement list.*/
	  status = VDPCrePlFileRel( &msg, me->ReqDat.PlacementCtx.CtxId,
				    FileId );

	  if( status != OM_S_SUCCESS )
	  {
	     UI_status(
		 "Failed to create relation between file & placement list" );
	     goto wrapup;
	  }

	  status = _VD_SEND_MY ( VDPCmdPMDef.VDPSaveDefaults ( &msg ));
	  CheckRC( status, msg );

	  if( !(status & msg & 1) )
	  {
	     UI_status("Error saving default data" );
	     goto wrapup;
	  }

	  resp = VD_FORM_ACCEPT;
	  ex$putque( msg             = &msg,
		     response        = &resp );
          break;

	case FI_CANCEL :
	  resp = VD_FORM_CANCEL;
	  ex$putque( msg             = &msg,
		     response        = &resp );
	  break;

	case G_SHIPNAME_E :
	  FIfld_get_text( VD_FP, G_SHIPNAME_E, 0, 0, VDPDESC_LEN, ShipName, &sel, &pos );
	  if (strcmp(ShipName,me->ReqDat.Ship.ShipName ))
	  {
	    nbShips = om$dimension_of(varray = me->Ships);
	    __DBGpr_int (" Number of Ships ", nbShips );

	    for (i=0; i < nbShips; i++ )
	    {
	  	if(!strcmp(ShipName,me->Ships[i].ShipName))
		{
		   strcpy(me->ReqDat.Ship.ShipName, ShipName);
		   strcpy(me->ReqDat.Ship.ShipDesc, me->Ships[i].ShipDesc);
		   strcpy(me->ReqDat.Ship.ShipId,me->Ships[i].ShipId);

		   FIfld_set_text( VD_FP, G_SHIP_DESC_E, 0, 0, me->ReqDat.Ship.ShipDesc, FALSE );
		   break;
		}
	    }

	    /* Clear the Bdg Weight Context Name list.
	    TR#:179602833 */
	    FIfld_set_list_num_rows( VD_FP, G_BWTCTX_E, 0, 0);

	    /* Clear the Bdg Weight Context Name field.*/
	    FIfld_set_text( VD_FP, G_BWTCTX_E, 0, 0, "", FALSE );

	    /* Clear the Bdg Weight Context Description field.*/
	    FIfld_set_text( VD_FP, G_BWTCTX_DESC, 0, 0, "", FALSE );

	    /* Clear the active BdgWt Context Name in the instance data.*/
	    strcpy( me->ReqDat.BdgWtCtx.Name, "" );

	    __DBGpr_str ( "ShipName ", me->ReqDat.Ship.ShipName );

	    status = VDPgetBWTContexts( &msg, me->ReqDat.Ship.ShipName, &nbCtx, &Contexts );
	    __CheckRC ( status, msg, "VDPgetBWTContexts", wrapup );

	    __DBGpr_int("Number of Budget Wt contexts :", nbCtx );

	    /* Store the Budget Wt Context in the Instance */

	    status = om$vla_set_dimension( varray = me->BwcNameDesc,
					size   = nbCtx );
	    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

	    memcpy ( me->BwcNameDesc, Contexts,
			 nbCtx*sizeof(struct VDPNameDesc) );

	    for ( i = 0; i < nbCtx; i++ )
	     FIfld_set_list_text( VD_FP, G_BWTCTX_E, i, 0,
				  me->BwcNameDesc[i].CtxName, FALSE );

	    /* Clear the Placement Context Name list.
	    TR#:179602833 */
	    FIfld_set_list_num_rows( VD_FP, G_CTX_NAME_E, 0, 0);

	    /* Clear the Placement Context Name field.*/
	    FIfld_set_text( VD_FP, G_CTX_NAME_E, 0, 0, "", FALSE );

	    /* Clear the Placement Context Type in the instance data.*/
	    me->ReqDat.PlacementCtx.Type = -1;

	    /* Clear the Placement Context Description field.*/
	    FIfld_set_text( VD_FP, G_CTX_DESC, 0, 0, "", FALSE );

	    /* Clear the Placement Context Type field.*/
	    FIfld_set_text( VD_FP, G_CTX_TYPE_E, 0, 0, "", FALSE );

	    /* Clear the Placement Context Subtype List, since this
	    is dependent on the Placement Context Type that is
	    selected by the user.*/
	    FIfld_set_list_num_rows( VD_FP, G_CTX_SUBTYPE_E, 0, 0);

	    /* Clear the Pl Context Subtype field.*/
	    FIfld_set_text( VD_FP, G_CTX_SUBTYPE_E, 0, 0, "", FALSE );

	    /* Clear the Placement Context Subtype in the instance data.*/
	    me->ReqDat.PlacementCtx.SubType = -1;
	  }
	  break;

	case G_BWTCTX_E :

	  if (me->ReqDat.Ship.ShipName[0] == '\0' )
	  {
    		FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "Ship Not Selected", FALSE );
		break;
	  }

	  FIfld_get_text( VD_FP, G_BWTCTX_E, 0, 0, VDPNAME_LEN, BwcName, &sel, &pos);
	  if(strcmp(BwcName,me->ReqDat.BdgWtCtx.Name ))
	  {
	     /* Different from the Old Bdg Wt Ctx */
	   
	     NbBdgWtCtx = om$dimension_of(varray = me->BwcNameDesc );

	     __DBGpr_int("Number of Budget Wt Contexts", NbBdgWtCtx );

	     for ( i=0; i < NbBdgWtCtx; i++ )
	     {
	  	if(!strcmp(BwcName,me->BwcNameDesc[i].CtxName))
		{
	          /* Get the BdgWtCtx Description */
		   strcpy(me->ReqDat.BdgWtCtx.Name, BwcName);
		   strcpy(me->ReqDat.BdgWtCtx.CtxDesc, me->BwcNameDesc[i].CtxDesc);
		   strcpy(me->ReqDat.BdgWtCtx.CtxId,me->BwcNameDesc[i].CtxId);
	  	   /* Set the description of Budget Context */
		   FIfld_set_text( VD_FP, G_BWTCTX_DESC, 0, 0, me->ReqDat.BdgWtCtx.CtxDesc, FALSE );
		   break;
		}
	     }
	  }

	  {
	    /* Budget Weight Types and Subtypes are hardcoded to B and 1 */

	    me->ReqDat.BdgWtCtx.Type = VDPTBUDGET_CODE;
	    me->ReqDat.BdgWtCtx.SubType = VDPSTBWT_CODE;
	    strcpy(me->ReqDat.BdgWtCtx.SubTypeDesc, "Budget Weight" );
	  }

	  break;

	case G_CTX_TYPE_E :
	  if (me->ReqDat.Ship.ShipName[0] == '\0' )
	  {
    		FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "Ship Not Selected", FALSE );
		break;
	  }


	  FIfld_get_text( VD_FP, G_CTX_TYPE_E,0,0,VDPNAME_LEN, CtxTypeName,&sel,&pos);
	  VDPGetContextTypeCode ( CtxTypeName, &CtxType );

	  /* If the Context Type is different from the previous one */ 

	  if ( CtxType != me->ReqDat.PlacementCtx.Type )
	  {
	     me->ReqDat.PlacementCtx.Type = CtxType;

	     /* Clear subtype, Name & description */

	     me->ReqDat.PlacementCtx.SubType = -1; 
	     FIfld_set_text( VD_FP, G_CTX_SUBTYPE_E, 0,0,"",FALSE);
	     FIfld_set_text( VD_FP, G_CTX_NAME_E, 0,0,"",FALSE);
	     FIfld_set_text( VD_FP, G_CTX_DESC, 0,0,"",FALSE);

	     /* clear from Instance data */

	     strcpy(me->ReqDat.PlacementCtx.SubTypeDesc,"");
	     strcpy(me->ReqDat.PlacementCtx.Name,"");
	     strcpy(me->ReqDat.PlacementCtx.CtxDesc,"");

	    /* Clear the associated subtype list */

	     FIfld_set_list_num_rows( VD_FP, G_CTX_SUBTYPE_E, 0, 0);
	     FIfld_set_list_num_rows( VD_FP, G_CTX_NAME_E, 0, 0);

	    /* Set the Sub type field with the appropriate associated list */

	     NbPlCxTST = om$dimension_of( varray = me->PLCtxTST );
	     row = 0;
	     for( i = 0; i < NbPlCxTST; i++ )
	        if( me->PLCtxTST[i].Type == CtxType )
		    FIfld_set_list_text( VD_FP, G_CTX_SUBTYPE_E, row++,0,
					me->PLCtxTST[i].SubTypeDesc, FALSE );

	  }
	  break;

	case G_CTX_SUBTYPE_E :

	  FIfld_get_text( VD_FP, G_CTX_SUBTYPE_E,0,0,VDPDESC_LEN,CtxSubTypeDesc,&sel,&pos);
	  if(CtxSubTypeDesc[0] == '\0' ) break;

	  NbPlCxTST = om$dimension_of( varray = me->PLCtxTST );
	  VDPGetContextSubTypeCode( me->ReqDat.PlacementCtx.Type,
				    CtxSubTypeDesc, 
				    me->PLCtxTST,
				    NbPlCxTST,
				    &CtxSubType);

	  /* If the Sub type is different from the previous one then clear
	     the Name and description */

	  if(CtxSubType != me->ReqDat.PlacementCtx.SubType )
	  {
	    me->ReqDat.PlacementCtx.SubType = CtxSubType;
	    strcpy(me->ReqDat.PlacementCtx.SubTypeDesc, CtxSubTypeDesc);
 
	    /* Clear Name & Description */
	    FIfld_set_text( VD_FP, G_CTX_NAME_E, 0,0,"",FALSE);
	    FIfld_set_text( VD_FP, G_CTX_DESC, 0,0,"",FALSE);

	    /* Clear Name & Desc from Instance Data */
	    strcpy(me->ReqDat.PlacementCtx.Name,"");
	    strcpy(me->ReqDat.PlacementCtx.CtxDesc,"");

	    /* Clear the associated Name list */

	    FIfld_set_list_num_rows( VD_FP, G_CTX_NAME_E, 0, 0);

	    /* Get the class name */

	    ClassName[0] = '\0';
	    status =
	    VDPGetClassNameGivenTST( me->ReqDat.PlacementCtx.Type,
				      me->ReqDat.PlacementCtx.SubType,
				      me->PLCtxTST,
				      NbPlCxTST,
				      ClassName );
	    __DBGpr_str ( "Class Name", ClassName );
	    __CheckRC( status, 1, "VDPGetClassNameGivenTST", wrapup );

	    /* query the database for context names, descriptions & ids */

	    status =
	    _VD_SEND_MY( VDPCmdPMDef.VDPqueryClass( &msg, ClassName ) );
	    CheckRC( status, msg );

	    /* Fill the associated list */
	    NbCtxNames = om$dimension_of( varray = me->PlcNameDesc );
	    __DBGpr_int("Number of Contexts", NbCtxNames );
	    row = 0;
	    for( i = 0; i < NbCtxNames; i++ )
		    FIfld_set_list_text( VD_FP, G_CTX_NAME_E, row++,0,
					me->PlcNameDesc[i].CtxName, FALSE );

	  }
	  break;

	case G_CTX_NAME_E :

	  FIfld_get_text(VD_FP, G_CTX_NAME_E, 0, 0, VDPNAME_LEN, CtxName, &sel, &pos );
	/* If the Name is different from the previous one then set the description */
	  if(strcmp(CtxName, me->ReqDat.PlacementCtx.Name ))
	  {
	     NbCtxNames = om$dimension_of( varray = me->PlcNameDesc );
	     __DBGpr_int("Number of Contexts", NbCtxNames );

	     for ( i=0; i < NbCtxNames; i++ )
	     {
	  	if(!strcmp(CtxName,me->PlcNameDesc[i].CtxName))
		{
		  /* Set the ContextId in the instance data */
		   strcpy(me->ReqDat.PlacementCtx.Name, CtxName );
		   strcpy(me->ReqDat.PlacementCtx.CtxDesc, 
				me->PlcNameDesc[i].CtxDesc);
		   strcpy(me->ReqDat.PlacementCtx.CtxId, 
				me->PlcNameDesc[i].CtxId);
	           FIfld_set_text( VD_FP, G_CTX_DESC, 0, 0, me->ReqDat.PlacementCtx.CtxDesc, FALSE );
		   break;
		}
	     }
	  }

	  break;

	case G_ESWBS_E :

	  FIfld_get_text(VD_FP, G_ESWBS_E, 0, 0, VDPESWBS_LEN, ESWBS, &sel, &pos );
	/* If the ESWBS number is different from the previous one then set 
	   the new description */
	  if(strcmp(ESWBS, me->ReqDat.ESWBS ))
	  {
	     NbESWBS = om$dimension_of(varray = me->ESWBSList );

	     __DBGpr_int("Number of ESWBS", NbESWBS );

	     for ( i=0; i < NbESWBS; i++ )
	     {
	  	if(!strcmp(ESWBS,me->ESWBSList[i].ESWBS))
		{
		   strcpy(me->ReqDat.ESWBS, ESWBS);
		   strcpy(me->ReqDat.ESWBS_Desc, me->ESWBSList[i].ESWBS_Desc);
	           FIfld_set_text( VD_FP, G_ESWBS_DESC_E, 0, 0, me->ReqDat.ESWBS_Desc, FALSE );
		   break;
		}
	     }
	  }

	  break;

	case G_ESWBS_DESC_E :

	  FIfld_get_text(VD_FP, G_ESWBS_DESC_E, 0, 0, VDPDESC_LEN, ESWBS_Desc, &sel, &pos );
	  __DBGpr_str("ESWBS Description ", ESWBS_Desc );

	/* If the ESWBS Desc is different from the previous one then set 
	   the new ESWBS */

	  if(strcmp(ESWBS_Desc, me->ReqDat.ESWBS_Desc ))
	  {
	     NbESWBS = om$dimension_of(varray = me->ESWBSList );

	     __DBGpr_int("Number of ESWBS", NbESWBS );

	     for ( i=0; i < NbESWBS; i++ )
	     {
	     __DBGpr_str("ESWBS Descriptions", me->sortedESWBSList[i].ESWBS_Desc );
	  	if(!strcmp(ESWBS_Desc,me->sortedESWBSList[i].ESWBS_Desc))
		{
		   strcpy(me->ReqDat.ESWBS, me->sortedESWBSList[i].ESWBS);
		   strcpy(me->ReqDat.ESWBS_Desc, me->sortedESWBSList[i].ESWBS_Desc);
	           FIfld_set_text( VD_FP, G_ESWBS_E, 0, 0, me->ReqDat.ESWBS, FALSE );
		   break;
		}
	     }
	   }
	   break;

	default :
		break;

    }

wrapup :

   if( Contexts )	/* Rishad. 13 Sep 96 */
    _FREE( Contexts );
    End
    return OM_S_SUCCESS;
}

end implementation VDPCmdPMDef;

