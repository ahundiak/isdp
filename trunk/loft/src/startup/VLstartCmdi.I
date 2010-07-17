/* $Id: VLstartCmdi.I,v 1.1.1.1 2001/01/04 21:11:38 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/startup/VLstartCmdi.I
 *
 * Description: Loft startup object
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLstartCmdi.I,v $
 * Revision 1.1.1.1  2001/01/04 21:11:38  cvs
 * Initial import to CVS
 *
# Revision 1.2  1998/11/08  14:47:40  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/08/98  ah      Call ppl upon dgnfile startup
 *************************************************************************/

class implementation VLstartCmd;

#include "vdprdmacros.h"

#include "VDtypedef.h"
#include "VDppl1.h"

#define  VL_SESSION_STARTUP   0
#define  VL_DGNFILE_STARTUP   1

/* ************************************************************************** */
method init ( int type ; char * str_ptr ) {

  	return OM_S_SUCCESS;
}
/* ************************************************************************** */
method execute( int *response ; char *response_data ; int pos ) {

  long msg;

  // printf("VLstart %d\n",me->mytype);
  
  switch(me->mytype) {

  case VL_SESSION_STARTUP: 

    msg = vd$prd_load_corrections( run_name = VD_PROD_NAME_LOFT );
    break;
	  
  case VL_DGNFILE_STARTUP: {

    TGRid   pplID;
    IGRint  pplRET;
    IGRchar pplProduct[16];

    // Inform the ppl about to start
    strcpy(pplProduct,"loft");
    vdppl$Load(pplID = &pplID, name = "VDstartup.u");
    vdppl$SetData(pplID = &pplID, 
		  name  = "PRODUCT", 
		  size  = 16, 
		  data  = pplProduct);

    vdppl$Run(pplID = &pplID, name = "startup1", ret = &pplRET);

    // Nothing else to do!
    vdppl$Run(pplID = &pplID, name = "startup2", ret = &pplRET);

    vdppl$Delete(pplID = &pplID);
          
    }
    break;
  }
  

  *response = TERMINATE;		    

  return OM_S_SUCCESS;
}
/* ************************************************************************** */

end implementation VLstartCmd;
