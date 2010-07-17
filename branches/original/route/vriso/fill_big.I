/* $Id: fill_big.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / fill_big.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: fill_big.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:58  cvs
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
# Revision 1.11  1996/05/23  22:01:48  pinnacle
# Replaced: vriso/fill_big.I for:  by hverstee for route240
#
# Revision 1.6  1996/04/04  23:00:28  pinnacle
# Replaced: vriso/fill_big.I for:  by hverstee for route240
#
# Revision 1.5  1996/03/22  17:54:02  pinnacle
# Replaced: vriso/fill_big.I for:  by hverstee for route240
#
# Revision 1.4  1996/03/21  23:24:08  pinnacle
# Replaced: vriso/fill_big.I for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  06:42:36  pinnacle
# Replaced: vriso/fill_big.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  00:08:38  pinnacle
# Replaced: vriso/fill_big.I for:  by r240_int for route240
#
 *
 * History:
 *  Oct-31-91  Bruno  1.4.3.7  
 *    - I modified the call to kick_iso by specifying
 *      as the first argument the predefined shell file
 *      name instead of "isogen.sh" or "triflex.sh".
 *  01/16/96  tlb  Add prototypes, comment out errors
 *
 *      03/22/96        hv      Get it to run again
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

extern int VdsGetProjectUnits();


/***********************************************************************
 *
 *   ISfill_noz :
 *
 *   Changes in BIG for existing row the cp_number for the 
 *   nozzles and for cut pipes. For a nozzle, modify the cp0 to cp0 + orient.
 *   
 *
 ************************************************************************/

IGRint
ISfill_noz(long     *msg,          /* complection code (O)                 */
           int       frm,
           int       to,           /* start and end index                  */
           int       nb_big,       /* number of cp (I/O)                   */
           short    *big)          /* cmp array (I/O)                      */

{
  int      i,occ,ant_occ,bseg,zero,b18,nb_hangers;
  short    one,node,bit6_flag,cp,newcp,cp1,cp2;
  char     name[5];
  short    bit6; 
  long     status;

  struct   GRid    big_id,hangers[MAX_HANGERS];

  *msg = 0;
  cp1  = 1;
  cp2  = 2;
  one  = 1;
  zero = 0;
  bit6 = ISshift(1,5);
  bit6_flag=0;

  if(frm < 0 || frm > nb_big || frm > to || to > nb_big )
  {
    printf("et les arguments alors, ca va pas du tout (from & to index) !!!\n");
    return 0;
  }

  for(i=frm;i<to;i++)
  {
    get_big(big,ROW,i,B_SEG ,2,(short *)&bseg);
    get_big(big,ROW,i,B_CP,1,(short *)&cp);
    get_big(big,ROW,i,B_NODE,1,(short *)&node);
    get_big(big,ROW,i,B_NAME,2,(short *)name);
    get_big(big,ROW,i,B_OCC ,2,(short *)&occ);
    get_big(big,ROW,i,B_OBJID ,2,(short *)&big_id.objid);
    get_big(big,ROW,i,B_OSNUM ,1,(short *)&big_id.osnum);
    if(i!=frm) get_big(big,ROW,i-1,B_OCC ,2,(short *)&ant_occ);

    /*"cp_number: %d\n",cp*/
    /*"name: %s\n",name*/
    /*"occ: %d\n",occ*/
    /*"ant_occ: %d\n",ant_occ*/
    /*"node:%d\n",node*/
    /*"bit6_flag: %d\n",bit6_flag*/
    /*"comp pipe: %d\n",strncmp(name,"PIPE",4)*/
    /*"b_seg: %d\n",bseg*/
    /*|test occ>30000............\n*/

    set_big(big,ROW,i,B_18,1,(short *)&zero);

    get_big(big,ROW,i,B_18 ,1,(short *)&b18);
    /*"b18 init : %d\n",b18 */

    if ((!strncmp(name,"NOZ",4))||(!strncmp(name,"SUPP",4)))
    {
      /* switch the cp0 from cp2 */
      get_big(big,ROW,i,B_CP,1,(short *)&cp);
      /*"cp noz: %d\n",cp*/
      if (cp == 0) set_big(big,ROW,i,B_CP,1,&cp1); 
      if (cp == 1) set_big(big,ROW,i,B_CP,1,&cp2); 
      get_big(big,ROW,i,B_CP,1,(short *)&cp);
      /*"cp noz or support after switch: %d\n",cp*/
    }

    get_big(big,ROW,i,B_CP,1,(short *)&newcp);
    /*"newcp: %d\n",newcp*/
    if((newcp==0) && (node!=0))
    {
      /*|get_hangers\n*/
      status =
      om$send(msg = message VRGeneric.VRGetHangers 
                         (msg, MAX_HANGERS, hangers, &nb_hangers, NULL, NULL),
         senderid = NULL_OBJID,
         targetid = big_id.objid,
         targetos = big_id.osnum);
      as$status(action = RET_STATUS);

      /*"nb_hangers: %d\n",nb_hangers*/
      if (nb_hangers!=0)
      {
         /*"obj avec support: %d, %d\n",big_id.objid,big_id.osnum*/
         bit6_flag=0;
      }
      else
      {
         /*"set bit6 : index: %d\n",i*/
         set_big_mask(big,ROW,i,B_INFO14,&bit6,IS_BIT6);
         bit6_flag=1;
      }
    }

    /* pb a faire pour tous les cp*/
    else if((occ==ant_occ) && bit6_flag)
    {
      set_big_mask(big,ROW,i,B_INFO14,&bit6,IS_BIT6);
      bit6_flag=1;
    }
    else bit6_flag=0;

    if (occ>30000)
    {
        /*"one............: %d\n",one*/
        set_big(big,ROW,i,B_18,1,(short *)&bseg);
        /*"occ: %d\n",occ*/
        get_big(big,ROW,i,B_18 ,1,(short *)&bseg);
        /*"B_18 occ: %d\n",bseg*/
        if (one)    {set_big(big,ROW,i,B_CP ,1,&cp1);one=0;}
        else     {set_big(big,ROW,i,B_CP ,1,&cp2);one=1;}
    }
  }

  return 1;
}                




/***********************************************************************
 *
 *   AJOUT 20 NOV 89 
 *   ISfill_ilks: find the number of segments that are
 *                connected to the component.(must be called
 *                after having the branch type: olet or component)
 *          
 ***********************************************************************/

IGRint
ISfill_ilks(long    *msg,           /* complection code (O)  */
            short   *big,           /* addr of big  row, (I)                */
            int      line,           /* line to get (C), (I)                 */
            short   *ilks,          /* number of segment returned           */
    struct  GRid    *cmp_err)       /* cmp to hilite because error          */

{
  int        status, comp_topo, comp_type, nb_cp;
  IGRlong    NumberOfBytes, BytesReceived,rt;
  IGRshort   nSysType;

  struct   GRid     big_id;
  struct ACrg_coll  rg_coll;
  struct GRmd_env   mod_env;

  /*|give_any_struc provides md_env */
  NumberOfBytes = sizeof( mod_env );

  gr$get_module_env(msg = &rt,
                 sizbuf = &NumberOfBytes,
                 buffer = &mod_env,
                 nret   = &BytesReceived );

  get_big(big,ROW,line,B_OBJID ,2, (short *)&big_id.objid);
  get_big(big,ROW,line,B_OSNUM ,1,(short *)&big_id.osnum);
  nb_cp = MAX_CP;

  status =
  om$send(msg = message VRGeneric.VRGetTopo
                                     (msg, MAX_CP, &nb_cp,
                                      NULL, NULL, NULL, NULL, &mod_env),
     senderid = NULL_OBJID,
     targetid = big_id.objid,
     targetos = big_id.osnum);
  if (!(status&1)){ as$status();  return (0);}

  if ((*msg == MSFAIL)||(nb_cp >MAX_CP))
  {
    printf("Fill_big Error\n");
    return 0;
  }

  /*" Get the component topo & type: %d, %d\n",big_id.objid, big_id.osnum */
  rg_coll.desc.value.att_exp = -1;
  strcpy(rg_coll.name, VR_N_COMP_TOPO_IN);
  status =
  om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
     senderid = NULL_OBJID,
     targetid = big_id.objid,
     targetos = big_id.osnum);
  if (!(status&1))
  { as$status(); *cmp_err= big_id;
    *msg = 6; return(0); 
  } 
  comp_topo = rg_coll.desc.value.att_exp;

  rg_coll.desc.value.att_exp = -1;
  strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
  status =
  om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
     senderid = NULL_OBJID,
     targetid = big_id.objid,
     targetos = big_id.osnum);
  if (!(status&1))
  { as$status(); *cmp_err= big_id;
    *msg = 6; return(0); 
  } 
  comp_type = rg_coll.desc.value.att_exp;

/* Madhukar - 

   Get the comp_type for a nozzle 
*/
  nSysType = 0;
  status =
  om$send(msg = message VRGeneric.VRGetSysType(msg, &nSysType),
     senderid = NULL_OBJID,
     targetid = big_id.objid,
     targetos = big_id.osnum);
  if (!(status&1))
  { as$status(); *cmp_err= big_id;
    *msg = 6; return(0); 
  } 

  if(nSysType == VR_NOZZLE )
      comp_type =VRP_V_NOZZLE_TYPE;

  /*"comp type: %d, comp topo: %d\n", comp_type, comp_topo */

  /* Add the origin (exect for a pipe) */
  if(comp_type != VRP_V_PIPE_TYPE) nb_cp = nb_cp + 1;

  if(comp_topo == VRP_V_OLET_TOPO)   *ilks = 2;
  else if ( nb_cp>=3)                *ilks = nb_cp-2;
  else                               *ilks = 1;

  if(*ilks > 7) 
  {
    printf("Error, to many segments supporting\n");
    *ilks = 0;
    return 0;
  }

  /*"ilks: %d\n",*ilks*/
  *ilks = ISshift(*ilks,3);

  return 1;
}

end implementation Root;

