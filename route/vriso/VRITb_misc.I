/* $Id: VRITb_misc.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / VRITb_misc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRITb_misc.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.1  1996/05/23  22:00:34  pinnacle
# Created: vriso/VRITb_misc.I by hverstee for route240
#
 *
 * History:
 *
 *************************************************************************/
 
/***************************************************************************
 *
 *  ISOGEN AND TRIFLEX INTERFACE
 *
 ***************************************************************************/

/*
 *  ISfill_big (isogen) and TRIfill_big (triflex):
 *
 *  function:
 *
 *  Determines all the components belonging to the line we 
 *  want to extract (by the select criteria *criteria) and  
 *  fills the array big and a structure buff_attr with the informations 
 *  required for isogen and triflex extraction.
 *
 *  This function needs to be called after that the design file has been 
 *  opened. 
 *
 *  History:  CH  Apr 16 1991
 *
 *  Modified to take into account the new ROUTE, VDS, ASSOC system.
 */

class implementation Root;

#include <stdio.h>

#include "OMerrordef.h" 
#include "OMminimum.h"
#include "OMmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "msdef.h"
#include "gomacros.h"
#include "exmacros.h"

#include "VDmem.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "VRmsg.h"
#include "ACrg_collect.h"

#include "big.h"
#include "dbs.h"

#include "AS_status.h"
#include "vriso_pto.h"

from VRGeneric   import VRGetCompDesc;
from VRGeneric   import VRGetSysType;
from OMObjSpace  import pass;
from GRgraphics  import GRfunction;
from VRGeneric   import ACgive_structure;


/************************************************************************
 *
 *   ISfill_or_not:
 *
 *   Function to choice, if a given component should be stored in 
 *   the big array or not.
 *
 ************************************************************************/

int
ISfill_or_not( long        *msg,      /* complection code (O)                */
        struct GRid         cmp,      /* identifier of the component         */
               IGRboolean  *yes,      /* output response                     */
        struct GRid        *cmp_err)  /* cmp to hilite because error         */

{
  long      status;
  int       comp_type;
  IGRshort  nSysType;

  struct ACrg_coll   rg_coll;
 
  /*| Test if dangling or error component */
 
  *msg = 6;

  rg_coll.desc.value.att_exp = -1;
  strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
  status =
  om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, NULL),
     senderid = NULL_OBJID,
     targetid = cmp.objid,
     targetos = cmp.osnum);
  as$status(action = RET_STATUS);

  comp_type = rg_coll.desc.value.att_exp;

/* Madhukar -                       
              
              Check if component is a nozzle and set the comp_type.
*/
  nSysType = 0;
  status =
  om$send(msg = message VRGeneric.VRGetSysType(msg, &nSysType),
     senderid = NULL_OBJID,
     targetid = cmp.objid,
     targetos = cmp.osnum);
  as$status(action = RET_STATUS);

  if(nSysType == VR_NOZZLE )
       comp_type = VRP_V_NOZZLE_TYPE;
 
  if(comp_type == VR_V_DANGLING_TYPE)
  {
    *yes = FALSE;
    *msg = 0;
    /*"component %d, %d is a DANGLING\n",cmp.objid,cmp.osnum*/
    return 1;
  }  
  else
  if(comp_type == VR_V_ERROR_TYPE)
  {
    *msg     = 2;
    *cmp_err = cmp;
    *yes     = FALSE;
    /*"component %d, %d is an ERROR COMPONENT\n",cmp.objid,cmp.osnum*/
    return 0;
  }

  *yes = TRUE; 
  *msg = 0;
  return 1;
}



/************************************************************************
 *                  *
 *  ISget_cc:               *
 *          Given some select criteria, return an allocated array  *
 *          of control components.          *
 *                  *
 *                  *
 *                  *
 *                  *
 ************************************************************************/

int
ISget_cc (long       *msg,
   struct ISOcriter  *crit,
          int         type,
          int        *nb_cc,    /* number of c.c. found (O)  */
   struct GRid      **cc)      /* array of c.c. allocated here */

{
  long              status;
  struct ISsel      sel;   
  OM_S_CLASSLIST    clist;
  extern GRclassid  OPP_VRPiping_class_id;
  extern GRclassid  OPP_VRHanger_class_id;
  OMuword           classes[2];
  OM_S_OBJID        mod_id;

  struct GRfunction_info  f_info;
  struct GRid             attr_grid;

  sel.crit   = crit;
  sel.type   = type;
  sel.nb_cc  = 0;
  sel.size   = 0;
  sel.cc     = *cc;

  go$build_user_function_buffer(buffer    = &f_info,
                                your_info = &sel );
  classes[0]      = OPP_VRPiping_class_id;
  classes[1]      = OPP_VRHanger_class_id;

  clist.w_count   = 2;
  clist.w_flags   = OM_CLST_subclass;
  clist.p_classes = classes;
  ex$get_cur_mod( id = &mod_id, osnum = &attr_grid.osnum );

  /* !!! recuperer tous les osnums si reference file */

  status =
  om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                           message GRgraphics.GRfunction(msg, ISvalid_cc, 
                                                          (char *) &f_info)),
      senderid = NULL_OBJID,
      targetid = OM_GO_current_OS_objid,
      targetos = attr_grid.osnum);
  as$status(action = RET_STATUS);

  if(*msg == MSFAIL) 
  { 
    printf("GRfunction bad complection code\n");
    return OM_W_ABORT;
  }

  *cc    = sel.cc;
  *nb_cc = sel.nb_cc;
  return 1;
}


IGRint ISvalid_cc(long             *msg,
           struct GRid             *obj,
           struct GRfunction_info  *f_info)

{
  long                   status;
  struct ISsel          *info;
  IGRboolean             found;
  int                    nb_crit,i,index;
  IGRchar                line_seq_number[11], fluid_code[20], zone[7];
  IGRchar                pds_class[14];
  struct ret_struct      rst;

  *msg  = MSSUCC;
  found = TRUE;
  info  = (struct ISsel *) f_info->info;

  /* get the user attributes */
  status =
  om$send( msg = message VRGeneric.ACgive_structure((int *) msg, &index,
                                             VR_N_SEQ_NUMBER_AN, &rst, NULL),
      senderid = NULL_OBJID,
      targetid = obj->objid,
      targetos = obj->osnum);
  as$status(action = GOTO_VALUE, value = wrapup);
  strcpy(line_seq_number,rst.var.text_st.text_string);

  status =
  om$send( msg = message VRGeneric.ACgive_structure((int *) msg, &index,
                                             VR_N_FLUID_CODE_AN, &rst, NULL),
      senderid = NULL_OBJID,
      targetid = obj->objid,
      targetos = obj->osnum);
  as$status(action = GOTO_VALUE, value = wrapup);
  strcpy(fluid_code,rst.var.text_st.text_string);

  status =
  om$send( msg = message VRGeneric.ACgive_structure((int*) msg, &index,
                                             VR_N_ZONE_AN, &rst, NULL),
      senderid = NULL_OBJID,
      targetid = obj->objid,
      targetos = obj->osnum);
  as$status(action = GOTO_VALUE, value = wrapup);
  strcpy(zone,rst.var.text_st.text_string);

  status =
  om$send( msg = message VRGeneric.ACgive_structure((int*) msg, &index,
                                             VR_N_CLASS_AN, &rst, NULL),
      senderid = NULL_OBJID,
      targetid = obj->objid,
      targetos = obj->osnum);
  as$status(action = GOTO_VALUE, value = wrapup);
  strcpy(pds_class, rst.var.text_st.text_string);

  /*"line seq number: <%s>\n", line_seq_number */
  /* Check if the criteria are matched */
  /* start the check in */
  nb_crit = info->crit[0].nb_page;

  if(info->type == LINE_ATTRIBUTES)
  {
    /*| extraction by attributes */
    i=0;
    while (nb_crit!=0)
    {
       found = TRUE;
       if(info->crit[i].fluid_text[0] != '*' && 
          strcmp(fluid_code,info->crit[i].fluid_text) != 0) 
       { 
          /*|sortie fluid_code\n */ 
          found = FALSE;
       }

       if(found && info->crit[i].line_seq_number[0] != '*' && 
          strcmp(line_seq_number,info->crit[i].line_seq_number) != 0) 
       { 
          /*|sortie line seq number\n */ 
          found = FALSE;
       }

       if(found && info->crit[i].block_number[0] != '*' &&
          strcmp(zone,info->crit[i].block_number) != 0) 
       { 
         /*| sortie block number\n*/ 
          found = FALSE;
       }

       if(found && info->crit[i].pds_class[0] != '*' && 
          strcmp(pds_class, info->crit[i].pds_class) != 0) 
       { 
          found = FALSE;
         /*| sortie pds_class\n */
       }
     

       if(found)
       {
         /*| !!!!!!!!!!!!!!!!! found\n*/
         /*| The criterium are matched */
         /* store the object */
         if(info->nb_cc + 1 >= info->size)
         {
           int size;

           size = info->size + INCR;
           if(info->size == 0)
              info->cc = _MALLOC (size , struct GRid);
           else
              info->cc = _REALLOC (info->cc, size, struct GRid);

           if(info->cc == NULL)
           {
             printf("Error in ISvalid_cc, no memory space available\n");
             info->size  = 0;
             info->nb_cc = 0;
             *msg        = 10;
             return 0;
           }
           /*"allocated address: %u\n",info->cc */
           info->size = size;
          }

         /*"index in cc: %d\n",info->nb_cc */
         info->cc[info->nb_cc++] = *obj;
         nb_crit = 0;
       } /* end of if found = TRUE */
       else
       {
         /*| found = FALSE \n*/
         nb_crit = nb_crit - 1;
         i       = i + 1;
       }
     }/* end of while other!=0 */

    if (!found) 
    {
        /*| return OM_S_SUCCESS found = FALSE \n*/ 
       *msg  = MSSUCC;
       return OM_S_SUCCESS;
    }
  }/* end of if type = LINE_ATTR */
 
  *msg  = MSSUCC;
  return OM_S_SUCCESS;

  wrapup:
  *msg = 11; 
  return(0); 
}


end implementation Root;

