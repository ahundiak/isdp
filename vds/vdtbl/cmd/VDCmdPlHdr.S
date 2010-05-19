/* $Id: VDCmdPlHdr.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdPlHdr.S
 *
 * Description:
 *	Command for placing table header
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/25/95        R. Manem        Added instances for handling
 *					"Show" button 
 *
 * -------------------------------------------------------------------*/


class specification VDCmdPlHdr (1:0) of VDS_LOCATE;

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDCmdPlHdr

  Superclass
      VDS_LOCATE

  Abstract
        The Command Object provides a form interface for placing
	the table header
        
  Methods

      my_init                	Public     Initialization

      init_form              	Public     Initialization of the form

      wrap_up                	Public     Wraps up the CO.

      store_cs               	Public     Stores the located coordinate system

      placeTblHdr            	Public     Places the table header

      VDsetDefaultTblName 	Public     Sets the default table name in the
					   form

      VDdelPreviewWindow       	Public     Deletes the preview window and
					   temporary graphics

  Overridden Methods

     form_notification  	Notification routine for the VDplaceTblHdr form

  Forms

     Place Table Header    	VDplaceTblHdr     User interface for the CO


 -------------------------------------------------------------------------

-cmd*/

#include "VDdrwlo.h"

/*+v
 -------------------------------------------------------------------------
  Abstract

  Notes/Remarks

*/

instance VDCmdPlHdr
{
    struct GRobj_env   	csId; 		/* Coordinate system : 
					   origin of the table header */
    IGRchar		tblLayoutName[VD_DRWLO_CHR_IDFLD];	 
					/* name of the table layout */
    IGRchar		tblName[DI_PATH_MAX];	/* name of the table */
    IGRshort		csLocation;	/* location of the coordinate system : 
					   VD_DRW_CS_LOC_LEFT,
					   VD_DRW_CS_LOC_RIGHT */
    struct GRmd_env	mod_env;	/* active module environment */
    struct GRid		windowId;	/* temporary window */
    struct GRid		showOwnerId;	/* temporary owner of "show" graphics */
};

/*
 -------------------------------------------------------------------------
-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

message my_init ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message init_form

  Abstract
        This method initializes the form 

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS   
 ---------------------------------------------------------------------------
-me*/

message init_form ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message wrap_up

  Abstract
        This method wraps up the command

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

message wrap_up ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message store_cs

  Abstract
        This method stores the located coordinate system

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

message store_cs ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message placeTblHdr

  Abstract
        This method generates the table header

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

message placeTblHdr ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetDefaultTblName

  Abstract
        This method sets the default name for the table in the form

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message VDsetDefaultTblName( long *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDdelPreviewWindow

  Abstract
        This method deletes the preview window and temporary graphics, if
	they exist

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message VDdelPreviewWindow( IGRlong *msg );

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

end specification VDCmdPlHdr;
