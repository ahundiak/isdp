/* $Id: VCCmdCL.S,v 1.1 2002/05/08 15:48:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdCL.S
 *
 * Description:
 *
 *  Specification file for SubCable Lead Configuration command 
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCL.S,v $
 *     Revision 1.1  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      04/12/02        Jayadev	      Creation
 *
 * -------------------------------------------------------------------*/

class specification VCCmdCL (0:0) of VCCmdCAT;

#include "vc_define.h"
#include "VCstructs2.h"
#include "VCCmdPC.h"
#include "VCstructs.h"
#include "VCLead.h"

instance VCCmdCL
{
    IGRchar	*form_ptr;
    IGRboolean  checkTransfer;   // if TRUE, we need to perform 
                                 // the check so that the subcable
				 // is not ripped of all its leads
    struct GRid subCable;
    struct GRid parCable;
    
    variable struct VCConfigLead parLeads[0];
    variable struct VCConfigLead subLeads[0];
};

override init;
override wakeup;
override sleep;
override form_notification;

message VCFstart();

message VCCleanup( IGRlong *sts );

/* This method stores the object id obtained from the "me->event1" structure
 * and retrieves all the required data to populate the form.
 */
message VCGetObject( IGRlong *sts );

/* This method is just for displaying the data in the form */
message VCDispForm( IGRlong *sts );

/* This method is to make sure that the subcable has atlVC_MAX_LEAD_IDeast
 * one lead in it
 */
message VCcheckTransfer( IGRlong *sts );

/*
 * Lead manipulation methods for the subcable
 */
message VCSubCabGrabLead( IGRlong *sts );

message VCSubCabDropLead( IGRlong *sts );
/*
 * When a row is selected on the form, it may be an empty 
 * one; this function takes the row-text , and returns 1
 * if that matches any of the parent/subcable leadnames, 
 * denoting an appropriate selection; the flag is set to
 * TRUE if the leadname str belong to the subcable
 */
message VCisAppropSelect( 
			 IGRlong         *sts; 
			 GRname          str;
			 IGRboolean      *flag;
			 struct VCLdInfo *matchInfo
		       );

/* This method returns the lead information from the form for 
 * the subcable
 */
message VCGetSubCableLdInfo(
			    IGRlong              *sts;
			    struct VCcab_connect *ldInfo;
			    IGRint               *nLeads
			   );

/* This method sets the lead information from the form on the 
 * subcable
 */
message VCSetSubCableLdInfo(IGRlong *sts);

end specification VCCmdCL;
