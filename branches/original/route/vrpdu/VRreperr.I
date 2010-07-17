/* $Id: VRreperr.I,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRreperr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRreperr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/22  13:49:58  pinnacle
# Replaced: vrpdu/VRreperr.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  17:30:32  pinnacle
# Replaced: vrpdu/VRreperr.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/
class implementation Root;

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "AS_status.h"
#include "VRparamdef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vrpdu_pto.h"

from NDmacro       import    ACgive_structure;

IGRint VRReportError (IGRlong    *msg,
               struct GRid       *CmpId,
                      IGRchar    *ErrMsgStr)
{

     int                 status;
     struct GRmd_env     mod_env;
     struct ret_struct   rst;
     IGRlong             ret, numbytes, bytesrec;
     int                 AC_index=-1;
    
     char                comp_code[20];
     char                line_seq_num[20];      
     char                tag_number[30];
     IGRdouble           coord[3];
     
     if (CmpId->objid != NULL_OBJID)
     {
     
          numbytes = sizeof(mod_env);
          /* Get module environment   */
          gr$get_module_env(msg = &ret,
                            sizbuf = &numbytes,
                            buffer = &mod_env,
                            nret   = &bytesrec); 

          /* Get the component code  */
         
          status = om$send(msg = message NDmacro.ACgive_structure((int *)msg,&AC_index,
                           VR_N_AABBCC_AN, &rst, &mod_env),
                           senderid = NULL_OBJID,
                           targetid = CmpId->objid,
                           targetos = CmpId->osnum);
          as$status( action = RET_STATUS);
          strcpy(comp_code,rst.var.text_st.text_string);
          
          /* Get the Line sequence number */
 
          status = om$send(msg = message NDmacro.ACgive_structure((int *)msg,&AC_index,
                           VR_N_SEQ_NUMBER_AN, &rst, &mod_env),
                           senderid = NULL_OBJID,
                           targetid = CmpId->objid,
                           targetos = CmpId->osnum);
          as$status( action = RET_STATUS);
          strcpy(line_seq_num,rst.var.text_st.text_string);

          /* Get the Tag number */

          status = om$send(msg = message NDmacro.ACgive_structure((int *)msg,&AC_index,
                           VR_N_TAG_NUMBER_AN, &rst, &mod_env),
                           senderid = NULL_OBJID,
                           targetid = CmpId->objid,
                           targetos = CmpId->osnum);
          as$status( action = RET_STATUS);
          strcpy(tag_number,rst.var.text_st.text_string);

          /* Get the Location */

          status = om$send(msg = message NDmacro.ACgive_structure((int *)msg,&AC_index,
                           VR_N_LOC_PT, &rst, &mod_env),
                           senderid = NULL_OBJID,
                           targetid = CmpId->objid,
                           targetos = CmpId->osnum);
          as$status( action = RET_STATUS);
          coord[0] = rst.var.point_st.pt[0];
          coord[1] = rst.var.point_st.pt[1];
          coord[2] = rst.var.point_st.pt[2];


         
          /* Print the error    */

          printf("\n********************ERROR   REPORT*********************\n\n");
          printf("COMPONENT                 id: %d, osnum: %d\n",CmpId->objid,CmpId->osnum);
          printf("LINE SEQUENCE NUMBER      %s\n", line_seq_num);
          printf("COMPONENT CODE            %s\n", comp_code);
          printf("TAG NUMBER                %s\n", tag_number);
          printf("LOCATION:\n");
          printf("                          X:%lf\n",coord[0]);
          printf("                          Y:%lf\n",coord[1]);
          printf("                          Z:%lf\n",coord[2]);
          printf("ERROR:\n");
          printf("%s\n",ErrMsgStr);

     }    
     *msg = OM_S_SUCCESS;
     return(OM_S_SUCCESS);

}

end implementation Root;
