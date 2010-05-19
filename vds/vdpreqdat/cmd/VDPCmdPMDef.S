/* I/VDS
 * 
 * File : vdpdefault/cmd/VDPCmdPMDef.S
 *
 * Description : Command class to set the default Budget weight context,
 *		 Placement context and ESWBS number etc.
 *
 * Dependencies :
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	9/25/95		MSM		Creation
 */

class specification VDPCmdPMDef (1:0) of VDS_LOCATE;

/*+cmd
  Command Object  Class	VDPCmdPMDef

  Super Class:
	VDS_LOCATE

  Abstract
	Class to set Default PME values in the design file.

  Methods
	VDPInitForm	Public			Initialises the Form

  Overridden Methods

	form_notification	Notification routine for VDPreqPMdat


-ca*/	/* abstract class */

#include	<stdio.h>
#include	"OMminimum.h"
#include	"FI.h"

#include	"VDPDatFrmDf.h"

instance	VDPCmdPMDef
{
  /* User Inputs from the form that get stored with the design file */
  struct VDPdefdata		ReqDat;

  /* store database info temporarily in the Command Object */
  variable struct VDPShipDesc	Ships[0];
  variable struct VDPEswbs	ESWBSList[0];
  variable struct VDPEswbs	sortedESWBSList[0];

  variable struct VDPPlCtxTST	PLCtxTST[0];
  variable struct VDPNameDesc	BwcNameDesc[0];
  variable struct VDPNameDesc	PlcNameDesc[0];

  IGRchar			DirName[DI_PATH_MAX];
  IGRchar			CollName[DI_PATH_MAX];
  struct GRid			CollId;

};

/*
-v*/

/*+me
  Public Message VDPInitForm

  Abstract
  At init this method initialises the form 

  Algorithm

  Arguments

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/

message VDPInitForm( long *sts);

/*+me
  Public Message VDPCheckDM2Conn

  Abstract

  This message verifies the database connection.

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPCheckDM2Conn( long *sts );

/*+me
  Public Message VDPValidateInput

  Abstract

  This message validates the user input on the form.

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPValidateInput( long *msg );

/*+me
  Public Message VDPSaveDefaults

  Abstract

  This message creates an ACrgcollector and stores the user inputs in the 
  collector.

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPSaveDefaults( long *msg );

/*+me
  Public Message VDPGetDefaults

  Abstract

  This message retrieves the default values from the RGcollector and fills the
  form.

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPGetDefaults( long *msg );

/*+me
  Public Message VDPqueryPMData

  Abstract

  This message queries the required data from the database and fills the
  command object's Instance data. It also fills the associated list for 
  various fields.

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPqueryPMData( long *msg );

/*+me
  Public Message VDPqueryClass

  Abstract

  This message queries the names and descriptions given the classname

  Status/Return Code

     status == OM_S_SUCCESS	if success;
     status == OM_E_ABORT       if error;
-me*/
message VDPqueryClass( 	IGRlong *msg;
			IGRchar	*ClassName );

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input

 -------------------------------------------------------------------------
-mo*/

override form_notification;


end specification VDPCmdPMDef;
