/* $Id: VRITb_fatt.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / VRITb_fatt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRITb_fatt.I,v $
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
# Revision 1.1  1996/05/23  21:37:54  pinnacle
# Created: vriso/VRITb_fatt.I by hverstee for route240
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

#define AS_DEBUG 1

#define MAX_HANGERS   100

#define  DB_ACCES /* */

from VRGeneric   import VRGetTopo, VRGetCompDesc, VRGetHangers, VRGetSysType;
from OMObjSpace  import pass;
from GRgraphics  import GRfunction, GRdisplay;
from VRGeneric   import ACgive_structure;

extern int VdsGetProjectUnits();


/************************************************************************
 *
 *   ISfill_big_attr :
 *
 *   Fill in BIG for existing row the name, the tag (occurrence number), 
 *   the flot, the orientation operator, the dash mode, the type.
 *
 *
 ************************************************************************/

int
ISfill_big_attr(long     *msg,     /* complection code (O)                 */
                int       frm,     /* start and end index                  */
                int       to,      /* start and end index                  */
                int       nb_big,  /* number of cp (I/O)                   */
                short    *big,     /* cmp array (I/O)                      */
        struct  GRid     *cmp_err) /* cmp to hilite because error          */

{
  int        i,j,status,end_flag,mode_flag,b1213;
  short      orientation[3], type, branch, ilks, flot, dp_mode;
  short      b3032[3],b1518[4],bit6;
  short      end_pt, tap, cp1, comp, tapnb,init;
  short      info22,info14,bit6_flag;
  int        AC_index;
  IGRlong    NumberOfBytes, BytesReceived,rt;
  int        comp_type, comp_topo;
  IGRshort   nSysType;

  struct GRid        big_id;
  struct ACrg_coll   rg_coll;
  struct ret_struct  orient;
  struct GRmd_env    local_env;

  char      *strchr();

  b1213=0;
  b1518[0]=b1518[1]=b1518[2]=0;
  b3032[0]=b3032[1]=b3032[2]=0;
 
  *msg = 0;

  if(frm < 0 || frm > nb_big || frm > to || to > nb_big )
   {
     printf("et les arguments alors, ca va pas du tout (from & to index) \n");
     return 0;
   }

  /*|give_any_struc provides md_env */
  NumberOfBytes = sizeof( local_env );

  gr$get_module_env(  msg    = &rt,
                      sizbuf = &NumberOfBytes,
                      buffer = &local_env,
                      nret   = &BytesReceived );
  /*^ printf("env id: %d, os: %d\n",
              local_env.md_id.objid,local_env.md_id.osnum);*/

  for(i=frm;i<to;i++)
  {
    init      = 0;
    end_flag  = 0;
    mode_flag = 0;
    bit6_flag = 0;
    /**************************************/
    /*  RETRIEVE NAME:8 NOV               */
    /**************************************/
    get_big(big,ROW,i,B_OBJID ,2,(short *)&big_id.objid);
    get_big(big,ROW,i,B_OSNUM ,1,(short *)&big_id.osnum);
    get_big(big,ROW,i,B_INFO22,1,(short *)&info22);
    get_big(big,ROW,i,B_INFO14,1,(short *)&info14);
    /*"info22: %x\n",info22*/
    /*"info14: %x\n",info14*/
    /*****************************************/
    /*  MODIF 20 NOV : ATTRIBUTES ALREADY SET*/
    /*                 IN FILL_CON      */
    /*****************************************/
    if (info22 & IS_DPMODE) mode_flag=1; /* display mode already set */
    if (info22 & IS_END)    end_flag=1;  /* end point already set */
    if (info14 & IS_BIT6)   bit6_flag=1;
                        
    /* Get the flot and the orientation vector \n*/
    orientation[0] = 0; orientation[1] = 0; orientation[2] = 0;
    set_big(big,ROW,i,B_INFO22,1,&init);
    set_big(big,ROW,i,B_INFO14,1,&init);

    /*" Get the component type: %d, %d\n", big_id.objid,big_id.osnum */
    rg_coll.desc.value.att_exp = -1;
    strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
    status =
    om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, NULL),
       senderid = NULL_OBJID,
       targetid = big_id.objid,
       targetos = big_id.osnum);
    if (!(status&1))
    {
      as$status();
      *cmp_err= big_id;
      *msg = 6;
      return(0); 
    } 

    comp_type = rg_coll.desc.value.att_exp;

    rg_coll.desc.value.att_exp = -1;
    strcpy(rg_coll.name, VR_N_COMP_TOPO_IN);
    status =
    om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, NULL),
       senderid = NULL_OBJID,
       targetid = big_id.objid,
       targetos = big_id.osnum);
    if (!(status&1))
    {
      as$status();
      *cmp_err= big_id;
      *msg = 6;
      return(0); 
    } 

    comp_topo = rg_coll.desc.value.att_exp;

/* Madhukar -                       
              
              Check if component is a nozzle and set the comp_type.
*/
    nSysType = 0;
    status =
    om$send(msg = message VRGeneric.VRGetSysType(msg, &nSysType),
       senderid = NULL_OBJID,
       targetid = big_id.objid,
       targetos = big_id.osnum);
    if (!(status&1))
    {
      as$status();
      *cmp_err= big_id;
      *msg = 6;
      return(0); 
    } 
    if(nSysType == VR_NOZZLE )
       comp_type = VRP_V_NOZZLE_TYPE;

    /*"comp type: %d, comp_topo: %d\n", comp_type, comp_topo*/

    switch (comp_type)
    {
      case VR_V_ERROR_TYPE:
        *msg =2;
        *cmp_err= big_id;
        return 0;

      case VRP_V_PIPE_TYPE:
        type = ISshift(5,8);
        comp = ISshift(1,2);
        break;

      case VRP_V_REDUCER_TYPE:
      case VRP_V_VALVE_TYPE:
      case VRP_V_ELBOW_TYPE:
      case VRP_V_FLANGE_TYPE:
      case VRP_V_BEND_TYPE:
      case VRP_V_BRANCH_TYPE:
      case VRP_V_PIPE_END_TYPE:
      case VRP_V_MISCELLANEOUS_TYPE:
      case VRP_V_ECCRED_TYPE:
        type = ISshift(3,8);
        comp = ISshift(0,2);
        break;

      case VRP_V_INSTRUMENT_TYPE:
      case VRP_V_SPECIALITY_TYPE:
        type = ISshift(6,8);
        comp = ISshift(0,2);
        break;

      case VRP_V_SUPPORT_TYPE:
        type = ISshift(8,8);
        comp = ISshift(0,2);
        break;

      case VRP_V_NOZZLE_TYPE:
        type = ISshift(22,8);
        comp = ISshift(1,2);
        break;

      default:
        printf("error in cache\n");
        printf("obj: %d, %d, comp type: %d\n",
                big_id.objid,big_id.osnum,comp_type);
        *msg = 6;
        *cmp_err = big_id;
        return 0;
    }

    /* orientation for support, excentric reducer, valve */
    AC_index=0;
    if(comp_type == VRP_V_SUPPORT_TYPE || comp_type == VRP_V_VALVE_TYPE ||
      (comp_type == VRP_V_REDUCER_TYPE && comp_topo == VRP_V_ECCENTRIC_TOPO) ||
       comp_type == VRP_V_ECCRED_TYPE)
     {
      /*| SET ORIENTATION\n */
      /*"object: %d, %d\n",big_id.objid,big_id.osnum*/
      AC_index=0;

      status =
      om$send(msg = message VRGeneric.ACgive_structure((int *) msg,&AC_index,
                                             VR_N_REF_CS,&orient,&local_env),
         senderid = NULL_OBJID,
         targetid = big_id.objid,
         targetos = big_id.osnum);
      if (!(status&1))
      {
        as$status();
        *msg = 9;
        *cmp_err= big_id;
        return(0);
      } 
      orientation[0]= (short)(orient.var.ref_st.t[1]*10000);
      orientation[1]= (short)(orient.var.ref_st.t[5]*10000);
      orientation[2]= (short)(orient.var.ref_st.t[9]*10000);

      if((comp_type==VRP_V_REDUCER_TYPE && comp_topo==VRP_V_ECCENTRIC_TOPO) ||
          comp_type==VRP_V_ECCRED_TYPE)
      {
       /*| Kluddge to invert the orientation for an eccentric reducer */
       for(j=0;j<3;j++) orientation[j] *= -1;
      }

      /*"orientation: %d, %d, %d\n",
         orientation[0],orientation[1],orientation[2]*/
    }

    /* word 14 */
    tapnb          = ISshift(0,3);
    if (bit6_flag) bit6 = ISshift(1,5);     /* one cp component */
    else           bit6 = ISshift(0,5);

    /*word 22*/
    branch = 0;
    ilks           = ISshift(0,3);
    if (mode_flag) dp_mode = ISshift(1,6);  /* dash mode */
    else           dp_mode = ISshift(0,6);

    flot           = ISshift(0,7);         /* bidirection */
    if (end_flag)  end_pt  = ISshift(1,9);  /* end point with connections*/
    else           end_pt  = ISshift(0,9);  

    tap            = ISshift(0,10);    /* not a tap */
    cp1            = ISshift(0,13);  
  
    set_big_mask(big,ROW,i,B_INFO22,&branch,IS_BRANCH);
    status = ISfill_ilks(msg,big,i,&ilks, cmp_err);
    if (!status) 
    {
       printf("error in ISfill_ilks\n");
       return 0;
    }

    /*"ilks: %d\n",ilks*/
    set_big_mask(big,ROW,i,B_INFO22,&ilks,IS_ILKS);

    /*"ilks: %d\n",ilks*/
    get_big(big,ROW,i,B_INFO22,1,(short *)&info22);

    /*"info22 apres ilks: %4x\n",info22*/  

    set_big_mask(big,ROW,i,B_INFO22,&dp_mode,IS_DPMODE);
    set_big_mask(big,ROW,i,B_INFO22,&flot,IS_FLOT);
    set_big_mask(big,ROW,i,B_INFO22,&end_pt,IS_END);
    set_big_mask(big,ROW,i,B_INFO22,&tap,IS_TAP);
    set_big_mask(big,ROW,i,B_INFO22,&cp1,IS_CP1);
 
    set_big_mask(big,ROW,i,B_INFO14,&comp,IS_COMP);
    set_big_mask(big,ROW,i,B_INFO14,&tapnb,IS_TAPNB);
    set_big_mask(big,ROW,i,B_INFO14,&type,IS_TYPE);

    /*
    /* to fill after having cap,blind flange,
    /* or plug.
    /*****************************************/
    set_big_mask(big,ROW,i,B_INFO14,&bit6,IS_BIT6);
    set_big(big,ROW,i,B_ORIENT,3,orientation);
    set_big(big,ROW,i,B_1213,2,(short *)&b1213);
    set_big(big,ROW,i,B_1518,3,b1518);
    set_big(big,ROW,i,B_3032,3,b3032);
  }   

  *msg = 1;
  return 1;
}

end implementation Root;

