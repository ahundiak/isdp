/* $Id: VRITb_fcon.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / VRITb_fcon.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRITb_fcon.I,v $
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
# Revision 1.1  1996/05/23  21:59:06  pinnacle
# Created: vriso/VRITb_fcon.I by hverstee for route240
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
 *   ISfill_big_con:
 *
 *   Fills the connectivity of big (node number, coordinate of each cp).
 *   A from and to index are specified.
 *
 ************************************************************************/

int
ISfill_big_con(long   *msg,          /* complection code (O)                 */
               int     frm,          /* part to solve (I)                    */
               int     to,           /* part to solve (I)                    */
               short  *node_number,  /* start node number (I/O)              */
               int    *nb_big,       /* number of components of big (I)      */
               short  *big,          /* BIG array (I)                        */
       struct GRid    *dash_cmp,     /* identifier of dash components (O)    */
               int    *nb_dash,      /* number of dash components (O)        */
               int    *con_flag,     /* flag=1: already pass in fill_big_con */
               int     triflex_flag, /* flag=1 for stress analysis           */
       struct  GRid   *cmp_err)      /* cmp to hilite because error          */

{
  int          index,index_cp,index_big,i,nb_cp;
  long         status;
  short        end_pt;
  short        cp_number[MAX_CP], ncp_number[MAX_CP];
  int          occ, cur_occ,occ_next,coef,one_cp,epsilon;
  char        *inch[1];
  IGRdouble    coord[MAX_CP*3];
  short        node,cp,cp_next, node_ext, act_node, cent_node;
  short        init,dp_mode,one_node,node_sup,cut_node;
  short        cut_flag;
  char         name[5];
  int          comp_type, comp_topo, nb_comp_type;
  IGRlong      NumberOfBytes, BytesReceived,rt;
  int          prj_units_set;
  IGRshort     nSysType;

  struct GRid        neighbors[MAX_CP];
  struct GRid        cmp;
  struct GRid        big_id;
  struct ACrg_coll   rg_coll;
  struct GRmd_env    mod_env;

  inch[0]   = "inch";
  dp_mode   =  ISshift(1,6); 
  end_pt    =  ISshift(1,9);

  *msg      =  0;

  cut_node  =  0;
  cent_node =  0;   /* center node */
  node_ext  = -1;   /* external node */
  one_node  = -2;   /* node for one cp component */
  node_sup  = -3;   /* external node for support */
  act_node  = *node_number ;

  cur_occ   = -1;
  *nb_dash  =  0;
  epsilon   =  2;
  occ_next  =  0;

  /*| Get project units set         */

  status = VdsGetProjectUnits( &prj_units_set );
  if(!status)
     return 0;
  /*|give_any_struc provides md_env */
  NumberOfBytes = sizeof( mod_env );

  gr$get_module_env(msg = &rt,
                 sizbuf = &NumberOfBytes,
                 buffer = &mod_env,
                 nret   = &BytesReceived );

  /*"from: %d\, to: %d, nb_big: %d\n", frm, to, *nb_big*/

  /*recuperation des default units \n*/

  if(prj_units_set <= 9) {coef = 2032; /*|unit = inch,coeff 2032\n */}
  else                       {coef = 80;
                            /*"inch[0]: %s\n",inch[0]*/
                           }
  /*"coef: %d\n",coef */
  if(frm < 0 || frm > *nb_big || frm > to || to > *nb_big )
  {
    printf("et les arguments, ca va pas du tout (from & to index)\n");
    if (!triflex_flag) *con_flag = 1;
    return 0;
  }

  for(index=frm;index<to;index++)
  {
     init = 0;
     set_big(big,ROW,index,B_INFO22,1,&init);
     set_big(big,ROW,index,B_INFO14,1,&init);
  }      

  for(index=frm;index<to;index++)
  {
     one_cp =  0;
     if (*con_flag) 
     {
       set_big_mask(big,ROW,index,B_INFO22,&dp_mode,IS_DPMODE);
     }

     /* get the connection */

     get_big(big,ROW,index,B_OCC ,2,(short *)&occ);
     /*"\n\n.................................index: %d, occ: %d\n",index,occ*/
     if(occ == cur_occ) continue;

     cur_occ = occ;

     /*| Get the topology */

     get_big(big,ROW,index,B_OBJID,2,(short *)&big_id.objid);
     get_big(big,ROW,index,B_OSNUM,1,(short *)&big_id.osnum);

     /* if it is not a pipe, we must add the cp 0 */
     rg_coll.desc.value.att_exp = -1;
     strcpy(rg_coll.name, VR_N_COMP_TOPO_IN);
     status =
     om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
        senderid = NULL_OBJID,
        targetid = big_id.objid,
        targetos = big_id.osnum);
     as$status(action = RET_STATUS)

     /*"comp topo: %lf\n", rg_coll.desc.value.att_exp */
     comp_topo = rg_coll.desc.value.att_exp;

     /* if it is not a pipe, we must add the cp 0 */
     rg_coll.desc.value.att_exp = -1;
     strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
     status =
     om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, &mod_env),
        senderid = NULL_OBJID,
        targetid = big_id.objid,
        targetos = big_id.osnum);
     as$status(action = RET_STATUS)
     /*"comp type: %lf\n", rg_coll.desc.value.att_exp */
     comp_type = rg_coll.desc.value.att_exp;

     /* Madhukar -                       
              
              Check if component is a nozzle and set the comp_type.
      */
      nSysType = 0;
      status =
      om$send(msg = message VRGeneric.VRGetSysType(msg, &nSysType),
         senderid = NULL_OBJID,
         targetid = big_id.objid,
         targetos = big_id.osnum);
      as$status(action = RET_STATUS);

      if(nSysType == VR_NOZZLE )
         comp_type = VRP_V_NOZZLE_TYPE;

      if(comp_type == VRP_V_PIPE_TYPE)
      {     
        status =
        om$send(msg = message VRGeneric.VRGetTopo(msg, MAX_CP, &nb_cp,
                        NULL, &coord[3], neighbors, ncp_number, &mod_env),
           senderid = NULL_OBJID,
           targetid = big_id.objid,
           targetos = big_id.osnum);
        as$status(action = RET_STATUS);
        for(i=0;i<nb_cp;i=i+1)
           cp_number[i] = i + 1;
      }
      else
      {
        /*| take into account the cp 0 */
       
        status =
        om$send(msg = message VRGeneric.VRGetTopo(msg, MAX_CP-1, &nb_cp,
                                         coord, &coord[3], &neighbors[1],
                                         &ncp_number[1], &mod_env),
           senderid = NULL_OBJID,
           targetid = big_id.objid,
           targetos = big_id.osnum);
        as$status(action = RET_STATUS);
        neighbors[0].objid = NULL_OBJID;
        ncp_number[0]      = -2;
        nb_cp       = nb_cp + 1;
        for(i=0;i<nb_cp;i=i+1)
           cp_number[i] = i;
      }

      if(*msg == MSFAIL || nb_cp >MAX_CP)
      {
         printf("fill_big Error, bad number of cp: %d, max cp: %d\n",
                                nb_cp, MAX_CP);
         return 0;
      }

      /* We must add 1 to the ncp_number to take into acccount the cp 0 */
      for(i=0;i<nb_cp;i=i+1)
        ncp_number[i] += 1;

#ifdef MY_DEBUG
      for(i=0;i<nb_cp;i=i+1) 
      {
        printf("--> obj: %d, cp: %d, neib: %d, neib_cp: %d\n\n",big_id.objid, 
                  cp_number[i], neighbors[i].objid, ncp_number[i]);
      }  
#endif

      /* look for the good cp */

      get_big(big,ROW,index,B_NAME,2,(short *)name);
#ifdef MY_DEBUG
      if(strncmp(name,"SUPP",4)==0)
      {
        /*| Support */
        for (i=0;i<nb_cp;i++)
        {
           /*"i           : %d\n",i*/
           /*"cp_number[i]: %d\n",cp_number[i]*/ 
           /*"x_coord     : %lf\n",coord[3*cp_number[i]+0]*/  
           /*"y_coord     : %lf\n",coord[3*cp_number[i]+1]*/  
           /*"z_coord     : %lf\n",coord[3*cp_number[i]+2]*/
           /*"neigh       : %d, %d\n",neighbors[i].objid,
                                                neighbors[i].osnum */

            printf("Add a delta for the cp 0\n");

         }
      }
#endif

      if ((nb_cp == 2)&&(strncmp(name,"NOZ",3))&&(strncmp(name,"SUPP",4))
           &&(strncmp(name,"PIPE",4)))     one_cp = 1;

      for (index_cp=0,index_big=index;index_cp<nb_cp;index_cp++)
      {
         /*"----------------boucle sur les cp index_big: %d\n",index_big*/
          name[4]='\0';
         /*"name: %s\n",name*/
         /*"one_cp: %d\n",one_cp*/

         get_big(big,ROW,index_big,B_NAME,2,(short *)name);
         if (!strncmp(name,"NOZ",3))
         {
            /*|name=noz\n*/
            /* nozzle should be in dash mode */
            set_big_mask(big,ROW,index_big,B_INFO22,&dp_mode,IS_DPMODE);
         }
         get_big(big,ROW,index_big,B_CP,1,(short *)&cp);
         /*"index cp: %d, ligne big: %d: cp: %d cp_big: %d\n",
                         index_cp,index_big,cp,cp_number[index_cp]*/
         /*| Look if this cp is inside big \n*/

         if(cp_number[index_cp] == cp) 
         {
           int   index_cmp;
           int   cp_con_number;
           int   x_coord, y_coord, z_coord;

           get_big(big,ROW,index_big,B_NODE,1,(short *)&node);
           /*"index_big: %d, node before set: %d\n",index_big,node*/
           if (index_big!=0) 
           {
             get_big(big,ROW,index_big-1,B_CP,1,(short *)&cp_next);
             get_big(big,ROW,index_big-1,B_OCC ,2,(short *)&occ_next);
           }
           else 
           {
             cp_next  = -2;
             occ_next = -2;
           }

           /*"cp[i]: %d, cp[i+1]: %d,occ_next: %d\n",
                      cp_number[index_cp],cp_next,occ_next*/ 

           cut_flag=0;
           /*"cur_occ: %d\n",cur_occ*/
           if(node != 0)  
           {
             /*"index: %d, node: %d already solved\n",index_big,node*/
             index_big++;
             continue;
           }
           else if((cp_next == cp ) && (cur_occ>30000))
           {
             /*| duplicated cp of a cut pipe\n*/
             get_big(big,ROW,index_big-1,B_NODE,1,(short *)&cut_node);
             /*"cut_node: %d\n",cut_node*/
             cut_flag=1;
             /*"////////set same node than the duplicated cp: %d\n",cut_node*/
             set_big(big,ROW,index_big,B_NODE,1,&cut_node);
           }
           else
           {
             /*"Got the good cp: %d active node: %d\n",cp,act_node*/
             /*" ////////1 set node ,index: %d, node: %d\n",index_big,act_node*/
             set_big(big,ROW,index_big,B_NODE,1,&act_node);
             /*"obj :%d\n",big_id.objid*/
           }
             
           /*"coord: %lf\n"  ,coord[3*cp_number[index_cp]+0]*/
           /*"coord: %lf\n"  ,coord[3*cp_number[index_cp]+1]*/
           /*"coord: %lf\n\n",coord[3*cp_number[index_cp]+2]*/
            

           if((strncmp(name,"SUPP",4)==0)&&(cp_number[index_cp]==1))
           {
             struct ret_struct   orient;
             int    AC_index;

             /*|support et cp[1]\n\n*/
             /*"coord i-1: %lf\n",  coord[3*cp_number[index_cp-1]+0]*/
             /*"coord i-1: %lf\n",  coord[3*cp_number[index_cp-1]+1]*/
             /*"coord i-1: %lf\n\n",coord[3*cp_number[index_cp-1]+2]*/
             /*| get the matrix xxxx */
             status =
             om$send(msg = message VRGeneric.ACgive_structure
                                              ((int *) msg,&AC_index,
                                                VR_N_REF_CS,&orient,&mod_env),
                senderid = NULL_OBJID,
                targetid = big_id.objid,
                targetos = big_id.osnum);
             if (!(status&1))
             {
               as$status();
               *msg = 9;
               *cmp_err = big_id;
               return(0);
             } 

             coord[3*cp_number[index_cp]+0] =
                                          coord[3*cp_number[index_cp-1]+0] +
                                          orient.var.ref_st.t[1];

             coord[3*cp_number[index_cp]+1] =
                                          coord[3*cp_number[index_cp-1]+1] +
                                          orient.var.ref_st.t[5];

             coord[3*cp_number[index_cp]+2] =
                                          coord[3*cp_number[index_cp-1]+2] +
                                          orient.var.ref_st.t[9];
            
             /*"coord sup 1: %lf\n",  coord[3*cp_number[index_cp]+0]*/
             /*"coord sup 1: %lf\n",  coord[3*cp_number[index_cp]+1]*/
             /*"coord sup 1: %lf\n\n",coord[3*cp_number[index_cp]+2]*/
           } 

           if((strncmp(name,"NOZ",3)==0)&&(cp_number[index_cp]==1))
           {
             struct ret_struct   orient;
             int    AC_index;

             /*| Nozzle, modify the coord of cp 0 \n\n*/
             /*"coord i-1: %lf\n",  coord[0]*coef */
             /*"coord i-1: %lf\n",  coord[1]*coef */
             /*"coord i-1: %lf\n\n",coord[2]*coef */
             /*| get the matrix xxxx */
             status =
             om$send(msg = message VRGeneric.ACgive_structure
                                                   ((int *) msg,&AC_index,
                                                 VR_N_REF_CS,&orient,&mod_env),
                senderid = NULL_OBJID,
                targetid = big_id.objid,
                targetos = big_id.osnum);
             if (!(status&1))
             {
               as$status();
               *msg = 9;
               *cmp_err = big_id;
               return(0);
             } 

             coord[0] = coord[3+0] + orient.var.ref_st.t[1];
             coord[1] = coord[3+1] + orient.var.ref_st.t[5];
             coord[2] = coord[3+2] + orient.var.ref_st.t[9];
            
             /*"coord noz 0: %lf\n",  coord[0]*coef */
             /*"coord noz 0: %lf\n",  coord[1]*coef */
             /*"coord noz 0: %lf\n\n",coord[2]*coef */

             x_coord = (coord[0]*coef);
             y_coord = (coord[1]*coef);
             z_coord = (coord[2]*coef);

             set_big(big,ROW,index_big-1,B_X,2,(short *)&x_coord);
             set_big(big,ROW,index_big-1,B_Y,2,(short *)&y_coord);
             set_big(big,ROW,index_big-1,B_Z,2,(short *)&z_coord);
           } 

           x_coord = (coord[3*cp_number[index_cp]+0]*coef);
           y_coord = (coord[3*cp_number[index_cp]+1]*coef);
           z_coord = (coord[3*cp_number[index_cp]+2]*coef);

           /*"x_coord: %ld\n",x_coord*/
           /*"y_coord: %ld\n",y_coord*/
           /*"z_coord: %ld\n",z_coord*/

           set_big(big,ROW,index_big,B_X,2,(short *)&x_coord);
           set_big(big,ROW,index_big,B_Y,2,(short *)&y_coord);
           set_big(big,ROW,index_big,B_Z,2,(short *)&z_coord);

           /* retrieve the other connected cp */

           cmp.objid = big_id.objid;
           cmp.osnum = big_id.osnum;
             
           /*"cp_number avant set node: %d\n",cp_number[index_cp]*/
           if((strncmp(name,"SUPP",4)==0)&&(cp_number[index_cp]==1))
           {
             /*|////////support cp1 set node -3\n*/
             /*"cp: %d\n",cp*/
             /*"support set index: %d, au node: %d\n",index_big,node_sup*/
             set_big(big,ROW,index_big,B_NODE,1,&node_sup);
             get_big(big,ROW,index_big,B_NODE,1,(short *)&node);
             /*"node: %d\n",node*/ 
             index_big++;
             continue;
           }

           if(IF_NULL_OBJID(neighbors[index_cp].objid))
           {
             /*|neighbors NULL_OBJID\n*/
             if ((one_cp)&&(cp_number[index_cp]==0))
             {
               /*"cp_number[]:%d\n",cp_number[index_cp]*/
               /*"////////one_cp->node=-2 on sort index: %d\n",index_big*/ 
               set_big(big,ROW,index_big,B_NODE,1,&one_node);
               index_big++;
               continue;
             }
             else
             if((cp_number[index_cp] == 0)&&(strncmp(name,"NOZ",3)))
             {
               /*"////////2 set node ,index: %d, node: %d\n",
                                           index_big,cent_node*/
               set_big(big,ROW,index_big,B_NODE,1,&cent_node);
             }
             else 
             {
               /*"No object connected to:%d, %d, cp: %d\n",cmp.objid,
                       cmp.osnum,cp_number[index_cp]*/
               /*| It is an end point */
        
               if(strncmp(name,"SUPP",4)==0)
               {
                 /*"cp: %d\n",cp*/
                 /*"////////support set node -3,index: %d, au node: %d\n",
                                               index_big,node_sup*/
                 set_big(big,ROW,index_big,B_NODE,1,&node_sup);
               }
               else
               {
                 /*"////////set index: %d, a node_ext: %d\n",
                                                 index_big,node_ext*/ 
                 set_big(big,ROW,index_big,B_NODE,1,&node_ext);
               }
             }

             index_big++;
             continue;
           }

           /*|type du composant voisin\n*/
           /*"index_cp: %d\n",index_cp*/
           /*"neighbor: %d, %d\n",
                 neighbors[index_cp].objid,neighbors[index_cp].osnum*/

           rg_coll.desc.value.att_exp = -1;
           strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
           status =
           om$send(msg = message VRGeneric.VRGetCompDesc(msg,&rg_coll,&mod_env),
              senderid = NULL_OBJID,
              targetid = neighbors[index_cp].objid,
              targetos = neighbors[index_cp].osnum);
           as$status(action = RET_STATUS);

           nb_comp_type = rg_coll.desc.value.att_exp;
           /*"neighbors: %d, %d comp type: %d\n", 
           neighbors[index_cp].objid, neighbors[index_cp].osnum, nb_comp_type */

           if((strncmp(name,"SUPP",4)==0)&&(nb_comp_type == VRP_V_PIPE_TYPE))
           {
             /*"le support: %d, %d\n",big_id.objid,big_id.osnum*/
             /*" ////////est place sur le pipe: %d, %d\n",
                     neighbors[index_cp].objid,neighbors[index_cp].osnum*/
             set_big(big,ROW,index_big,B_NODE,1,&cent_node);
             index_big++; 
             continue;    
           }  

           status = ISget_cp_con(msg, cmp,
                            &cp_con_number, ncp_number[index_cp]);

           if (!status)
           {
              printf("error in ISget_cp_con\n");
              return 0;
           }

           if(*msg != 1)
           {
              printf(" !!!!!!!Error of connection\n\n\n");
              *cmp_err = big_id;
              *msg = 5;
              /*"Object: %d, %d, cp: %d\n",cmp.objid,cmp.osnum,
                       cp_number[index_cp]*/
              /*"Connected object ?: %d, %d\n",neighbors[index_cp].objid,
                       neighbors[index_cp].osnum*/
              return 0;
            }

            status = ISget_cmp_cp_index(msg, neighbors[index_cp], 
                                          cp_con_number, *nb_big, big, 0, 
                                          to, &index_cmp);
            if (!status)
            {
              printf("error in ISget_cmp_cp_index\n");
              return 0;
            }

            if(*msg != 1) 
            {
              /*"l'objet a l'index: %d a un voisin qui n'est pas dans big\n",
                                  index_big*/
              if(!cut_flag) 
              {
                 set_big(big,ROW,index_big,B_NODE,1,&node_ext);
                 /*"////////node_ext: %d\n",node_ext*/
              } 
      
         /********************************************/
         /* 22 NOV 89:
         /* ADD THE NEIGHBOR IN DASH MODE IN BIG     */
         /* AND SET END POINT            */
         /********************************************/
         /****************************************************
         /*  22 NOV 89 : test if the neighbor is a dangling. 
         /*              If it is the case the component is
         /*              considered as an end point.
         /*              (not with a connecting to)
         /***************************************************/

              if(nb_comp_type == VR_V_DANGLING_TYPE)
              {
                /*"index big of end pt with connect to :%d\n",index_big*/
                set_big_mask(big,ROW,index_big,B_INFO22,&end_pt,IS_END);
                if (cut_flag) 
                {
                  /*|node already set to previous cp\n*/
                  index_big++;
                  continue;
                }
                else
                if (triflex_flag)
                {
                  /*|////////end point but triflex set node -1\n*/
                  set_big(big,ROW,index_big,B_NODE,1,&node_ext);
                }

                /*"con_flag: %d\n",*con_flag*/
                /*"obj geometry: %d\n",comp_topo*/
                if((nb_comp_type != VR_V_DANGLING_TYPE) && 
                    ((!*con_flag) && (!triflex_flag)) || ((*con_flag)&&
                     (comp_topo == VRP_V_OLET_TOPO)))
                {
                  set_big(big,ROW,index_big,B_NODE,1,&act_node);
                  /*"////////5 set node ,index: %d, node: %d\n",
                                                   index_big,act_node*/
                  act_node++;
                  /*"type (need dash): %d\n", comp_topo*/
                  *dash_cmp = neighbors[index_cp];
                  dash_cmp++;
                  *nb_dash=*nb_dash+1;
                }
              }

              index_big++;
              continue;
            }
            
            /* Neighbor: %d, %d, index_cmp: %d, cp_con_number: %d\n", 
                  neighbors[index_cp].objid,neighbors[index_cp].osnum,
                                               index_cmp,cp_con_number */
            get_big(big,ROW,index_cmp,B_NODE,1,(short *)&node);
            /*"index du voisin: %d, node du voisin: %d\n",index_cmp,node*/

#ifdef OUWE_ROTZOOI

            if ((node!=0) && (strncmp(name,"SUPP",4))) 
            {
              /*"////////set node index: %d,au node du voisin: %d\n",
                                                    index_big,node*/
              set_big(big,ROW,index_big,B_NODE,1,&node);
            }
            else
            if ((node ==0)&& (strncmp(name,"SUPP",4)==0)) 
            {
              /*|////////mise a jour du node du cp0 du comp et du support\n*/
              /*get_big(big,ROW,index_cmp+1,B_NODE,1,&node);*/
              set_big(big,ROW,index_big,B_NODE,1,&act_node);
              set_big(big,ROW,index_cmp,B_NODE,1,&act_node);
              act_node++;
            }
            else  
            {
              /*"////////met le node du voisin a index: %d,node courant: %d\n",
                                                  index_cmp,act_node */
              set_big(big,ROW,index_cmp,B_NODE,1,&act_node);  
              act_node++;
            }
#else

            if (strncmp(name,"SUPP",4)==0)                  /* support  */
            {
              if (node == 0)
              {
                set_big(big,ROW,index_big,B_NODE,1,&act_node);
                set_big(big,ROW,index_cmp,B_NODE,1,&act_node);
                act_node++;
              }
            }
            else
            { /*   regular components   */
              if ((node == 0) || (node == -1))
              {
                set_big(big,ROW,index_big,B_NODE,1,&act_node);
                set_big(big,ROW,index_cmp,B_NODE,1,&act_node);
                act_node++;
              }
              else
              {
                set_big(big,ROW,index_big,B_NODE,1,&node);
              }
            }

#endif

            /*|set coord du voisin au meme qu'objet\n*/
            set_big(big,ROW,index_cmp,B_X,2,(short *)&x_coord);
            set_big(big,ROW,index_cmp,B_Y,2,(short *)&y_coord);
            set_big(big,ROW,index_cmp,B_Z,2,(short *)&z_coord);
            index_big++;
          } /* end if(cp_number[index_cp] == cp) \n*/

        } /*end for (index_cp=0,index_big=index;index_cp<nb_cp;
                                      index_cp++,index_big++) */
    }/* end  for(index=frm;index<to;index++) */

 *node_number = act_node;
 if (!triflex_flag) *con_flag = 1;

 *msg = 1;
 return 1;
}

end implementation Root;

