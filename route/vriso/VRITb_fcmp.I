/* $Id: VRITb_fcmp.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vriso / VRITb_fcmp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRITb_fcmp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
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
# Revision 1.1  1996/05/23  21:38:12  pinnacle
# Created: vriso/VRITb_fcmp.I by hverstee for route240
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
 *	Modified to take into account the new ROUTE, VDS, ASSOC system.
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

#define MAX_HANGERS 	100

#define  DB_ACCES /* */

from VRGeneric 	import VRGetTopo, VRGetCompDesc, VRGetHangers, VRGetSysType;
from OMObjSpace	import pass;
from GRgraphics	import GRfunction, GRdisplay;
from VRGeneric 	import ACgive_structure;

extern int VdsGetProjectUnits();


/************************************************************************
 *
 *   ISfill_big_cmp:
 *
 *   Given an componant, fills big with the cp_number, the name,
 *   the segment number (occ), initialize the node to null and fill for 
 *   temporary use the objid and osnum of the component. Also fills the 
 *   number of cp (not include the origine).
 *
 *   The big array is dynamically allocated or reallocated by this function 
 *   if the array is not enough big. The caller should do the deallocation.
 *
 *   Also change the cp_number and the number of cp
 *   for pipe with olets or weld. This kind of pipe will be cut and
 *   treated  as different pipes with 2 cp (1 & 2).
 ************************************************************************/

int
ISfill_big_cmp(long     *msg,       /* complection code (O)                 */
        struct GRid      cmp,       /* identifier of the component          */
               int       occ,       /* available occurence number (I)       */
               int      *occ3000,   /* occurence number for cut pipe(I/O)   */
               int      *nb_big,    /* number of cp (I/O)                   */
               int      *size_big,  /* size of big (I/O)                    */
               short   **big,       /* cmp array (I/O)                      */
       struct  GRid     *cmp_err)   /* cmp to hilite because error          */

{
 int 			status,frm;
 int 			j,index,new_occ,nb_cp;
 short    		i,cp2;
 short			cp_number[MAX_CP];
 short			newcp_number[MAX_CP];
 short			comp,nb_olet;
 int                    no_cp;
 char   		name[5];
 short          	zero, type,number_cp;
 int			comp_type, comp_topo;
 struct	GRmd_env	mod_env;
 IGRlong  		NumberOfBytes, BytesReceived,rt;
 IGRshort               nSysType;
 struct ACrg_coll 	rg_coll;

 frm    =  0;
 index  =  0;
 zero   =  0;
 *msg   =  0;
 no_cp  = -1;
 cp2    =  2;

/*^ printf("\n\n.......................................component: %d, %d\n",
                                                        cmp.objid,cmp.osnum);*/

 /*|give_any_struc provides md_env */
 NumberOfBytes = sizeof( mod_env );

 gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &mod_env,
                nret   = &BytesReceived );

  status = ISget_cmp_cp_index(msg,cmp,no_cp, *nb_big, *big, frm, 
			      *nb_big, &index);

  if (!status)
    {
      printf("error in big_index\n");
      return 0;
    }
  if (index != -1) 
     {
      *msg = 1;
      /*"obj: %d, %d already in big at index: %d\n",cmp.objid,cmp.osnum,index*/
      return 1;
     }

   /*" Get the component type and topo obj: %d, %d\n", cmp.objid, cmp.osnum */
   rg_coll.desc.value.att_exp = -1;
   strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
   status = om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
		    senderid = NULL_OBJID,
                    targetid = cmp.objid,
                    targetos = cmp.osnum);
  if (!(status&1)){ as$status() ; *cmp_err= cmp;
 		   *msg = 6; return(0); 
		 } 
  comp_type = (int) rg_coll.desc.value.att_exp;

   /* Get the component topo */
   rg_coll.desc.value.att_exp = -1;
   strcpy(rg_coll.name, VR_N_COMP_TOPO_IN);
   status = om$send(msg      = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
		    senderid = NULL_OBJID,
                    targetid = cmp.objid,
                    targetos = cmp.osnum);
  if (!(status&1)){ as$status(); *cmp_err= cmp;
 		   *msg = 6; return(0); 
		 } 
  comp_topo = (int) rg_coll.desc.value.att_exp;


/* Madhukar -                       
              
              Check if component is a nozzle and set the comp_type.
*/
   nSysType = 0;
   status = om$send(msg      = message VRGeneric.VRGetSysType(msg, &nSysType),
		    senderid = NULL_OBJID,
                    targetid = cmp.objid,
                    targetos = cmp.osnum);
  if (!(status&1)){ as$status(); *cmp_err= cmp;
 		   *msg = 6; return(0); 
		 } 
  if(nSysType == VR_NOZZLE )
       comp_type = VRP_V_NOZZLE_TYPE;


  /*"comp type: %d, comp topo: %d\n", comp_type, comp_topo */
  if(comp_type == VRP_V_PIPE_TYPE) 
          {
           type = ISshift(5,8); 
           comp = ISshift(1,2); 
           strcpy(name,"PIPE");
          }
   else if(comp_type == VRP_V_REDUCER_TYPE  || comp_type == VRP_V_VALVE_TYPE   || 
           comp_type == VRP_V_ELBOW_TYPE    || comp_type == VRP_V_FLANGE_TYPE  ||
	   comp_type == VRP_V_BEND_TYPE     || comp_type == VRP_V_BRANCH_TYPE ||
	   comp_type == VRP_V_PIPE_END_TYPE || comp_type == VRP_V_MISCELLANEOUS_TYPE ||
	   comp_type == VRP_V_ECCRED_TYPE ) 
          {
           type = ISshift(3,8); 
           comp = ISshift(0,2);
           strcpy(name,"COMP");
          }
   else if(comp_type == VRP_V_INSTRUMENT_TYPE || comp_type == VRP_V_SPECIALITY_TYPE )
          {
           type = ISshift(6,8); 
           comp = ISshift(0,2);
           strcpy(name,"INST");
          }
   else if(comp_type == VRP_V_SUPPORT_TYPE)
         {
           type = ISshift(8,8);
           comp = ISshift(0,2);
           strcpy(name,"SUPP");
          }
   else if(comp_type == VRP_V_NOZZLE_TYPE)
          {
           type = ISshift(22,8); 
           comp = ISshift(1,2);
           strcpy(name,"NOZ");
          }
   else if(comp_type == VR_V_ERROR_TYPE)
          {
           /*|Error Component, no extraction done\n*/
           *msg = 2; 
           *cmp_err= cmp;
           return 0;
          }
   else
	  {
	   printf("error in cache\n");
	   printf("obj: %d, %d, comp type: %\n",cmp.objid,cmp.osnum,comp_type);
	   return 0;
          }
 /*"obj: %d,  type: %d\n",cmp.objid,comp_type*/
 /* get the cp */
 nb_cp = MAX_CP;
 status = om$send(msg = message VRGeneric.VRGetTopo(msg, MAX_CP, &nb_cp,
                                        NULL, NULL, NULL, NULL, &mod_env),
              senderid = NULL_OBJID,
              targetid = cmp.objid,
              targetos = cmp.osnum);
 as$status(action = RET_STATUS);

 if(*msg == MSFAIL)
   {
    printf("fill_big Error, Bad number of cp: d, max: %d\n", nb_cp, MAX_CP);
    return 0;
   }

 /* If it is not a pipe add the cp 0 */
 if(comp_type == VRP_V_PIPE_TYPE)
  {
   for (i=0;i<nb_cp;i++) cp_number[i] = i + 1;
  }
 else
  {
   nb_cp = nb_cp + 1;
   for (i=0;i<nb_cp;i++) cp_number[i] = i;
  }

 /*"nb_cp: %d\n",nb_cp*/
 if(type == ISshift(5,8) && nb_cp >= 3)
   {
    /*| treatment for component with olets or weldolet */

    if(nb_cp > 2)
           {
            nb_olet = nb_cp - 2;
            nb_cp   = nb_cp + nb_olet ; /* nb_cp with all the pipes created */
            for(j=1,i=1;j<nb_cp && i<(nb_cp-nb_olet);j=j+2,i++)
               {
                newcp_number[j] = newcp_number[j+1] = cp_number[i];
                /*"j : %d,cp_number[j]: %d\n",j  ,newcp_number[j] */
                /*"j : %d,cp_number[j]: %d\n",j+1,newcp_number[j+1] */
               }
            for (i=1;i<nb_cp;i++) cp_number[i]= newcp_number[i];
            /*^for (i=0;i<nb_cp;i++) printf("i: %d,cp_nb: %d\n",i,cp_number[i]); */
          }
    }   

 /*| Dynamique allocation if necessary \n*/

 /*"nb_cp: %d, nb_big: %d, size_big: %d\n",nb_cp,*nb_big,*size_big*/
 if(ISbig_alloc(msg, (short) nb_cp, *nb_big, size_big, big)!=1) return 0;

 /*******************************************/ 
 /* Get the flot and the orientation vector */
 /* TO IMPLEMENT                            */
 /*******************************************/
 if(type != ISshift(5,8) && type != ISshift(8,8)) number_cp = nb_cp-1; /* pipe or support*/
 else              				  number_cp = nb_cp;

 for(i=*nb_big,j=0;i<*nb_big+nb_cp;i++,j++)
     {
      /*" set nouveau cp index: %d,cp_number: %d\n",i,cp_number[j]*/

      set_big(*big,ROW,i,B_NAME ,2,(short *)name);
      set_big(*big,ROW,i,B_OCC  ,2,(short *)&occ);
      set_big(*big,ROW,i,B_CP   ,1,(short *)&cp_number[j]);          
      set_big(*big,ROW,i,B_SEG  ,2,(short *)&occ);
      set_big(*big,ROW,i,B_NODE ,1,(short *)&zero); 
      set_big(*big,ROW,i,B_NBCP ,1,(short *)&zero);
               

      if ((!strncmp(name,"PIPE",4)) && (nb_cp>2))
          { 
            set_big_mask(*big,ROW,i,B_NBCP, &cp2,IS_CP26);
          }
      else 
          {
	   set_big_mask(*big,ROW,i,B_NBCP,&number_cp,IS_CP26);
          }
      set_big(*big,ROW,i,B_OBJID,2,(short *)&cmp.objid);          
      set_big(*big,ROW,i,B_OSNUM,1,(short *)&cmp.osnum);
     }
new_occ=occ;

   

 if ((!strncmp(name,"PIPE",4)) && (nb_cp>2))
   {
    for(i=*nb_big,j=0;i<*nb_big+nb_cp-1;i=i+2,j++)
     {
          /*"i: %d,new_occ : %d\n",i,new_occ*/
          set_big(*big,ROW,i,B_OCC  ,2,(short *)&new_occ);
          set_big(*big,ROW,i+1,B_OCC  ,2,(short *)&new_occ);
          new_occ = *occ3000 +j;
     }
    *occ3000 = new_occ;
    
   }

/*"occ fin big_cmp    : %d\n",occ */ 
/*"occ300 fin big_cmp : %d\n",*occ3000*/ 
 *nb_big = *nb_big + nb_cp; 		/* nb of cp = nb of lines */

 return 1;
}

end implementation Root;

