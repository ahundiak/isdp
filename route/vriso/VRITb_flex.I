/* $Id: VRITb_flex.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / VRITb_flex.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRITb_flex.I,v $
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
# Revision 1.2  1996/05/30  16:32:58  pinnacle
# Replaced: vriso/VRITb_flex.I for:  by hverstee for route240
#
# Revision 1.1  1996/05/23  21:59:58  pinnacle
# Created: vriso/VRITb_flex.I by hverstee for route240
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
 *  TRIfill_big (triflex):
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

int
TRIfill_big (long      *msg,          /* complection code (O)                 */
      struct ISOcriter *criteria,     /* selection criteria                   */
             short     *node_number,  /* start (end) node number (I/O)        */
             int       *nb_big,       /* number of elements of big (I/O)      */
             int       *size_big,     /* size of big (I/O)                    */
             short    **big,          /* BIG array (I/O)                      */
             char      *file,         /* iso file name                        */
             char      *def,          /* default file name                    */
     struct  GRid      *cmp_err)      /* component to hilite to show error    */

{
 int           i,index_cmp,status;
 int           triflex_flag;
 int           frm,frm2;
 int           nb_cmp, occ, cur_occ,occ3000;
 int           nb_dash,con_flag; 
 int           red_cp;
 IGRboolean    yes;
 short         tmp[2], one;
 char          seed[PATH_MAX];
 char         *units_pt;  /* units of design */
 char          t_n[15], def_units[120];
 short         flag,num_def;
 short         units_set;
 int           prj_units_set;

 struct GRid       *cmp,dash_cmp[MAX_DASH];
 struct buff_attr   buff_attr;

 strcpy(seed,"");    
                                    
/*|TRIfill_big entry\n\n*/

 *msg           = MSFAIL;
  yes           = FALSE;
  nb_cmp        = 0; 
  one           = 1;
  nb_dash       = 0;
  con_flag      = 0;
  frm           = *nb_big;
  triflex_flag  = 1; 
  occ3000       = 30001;
  cmp           = NULL;

  if(VdsRisAttach() != OM_S_SUCCESS) 
  {
    *msg = VR_E_RisInitFailed;
    return(0);
  }

  status = VdsGetProjectUnits ( &prj_units_set );
  if(!status)
     return(0);
  units_set = (short)(prj_units_set);

  UI_status("Processing...");

  /*"default: %s\n",def*/

#ifdef MY_DEBUG
  for (i=0;i<criteria->nb_page;i++)
     {
      /*"fluid  : %s\n",criteria[i].fluid_text*/
      /*"seq    : %s\n",criteria[i].line_seq_number*/
      /*"block  : %s\n",criteria[i].block_number*/
      /*"class  : %s\n\n",criteria[i].pds_class*/
     }
#endif

/* research of the components of the line to extract */

  status = ISget_cc(msg, criteria, LINE_ATTRIBUTES, &nb_cmp, &cmp);
  if (!status)
  {
     printf("error in ISget_cc\n");
     *msg = 4;
     return 0;
  }
  if (nb_cmp == 0) 
  {
     *msg = 3; /* No component selected by criteria */
     return 0;
  }

  /*recuperation des default units \n*/

  strcpy(t_n,"UOM_DISTANCE");
  flag = 1;
  co$get_default_units( msg      = (int*)msg,
                   table_name    = t_n,
                   osnum         = 2,       /* working os */
                   flag          = &flag,
                   num_defaults  = &num_def,
                   default_units = def_units );

  /*"num_def: %d\n",num_def*/
  units_pt = def_units;
  for(i=0;i<num_def;i=i+1)
  {
    /*" default unit = %s\n", units_pt*/
  }
  /*"units_pt: %s\n",units_pt*/

  for(index_cmp=0,occ=*nb_big+1;index_cmp<nb_cmp;index_cmp++)
  {
     /*"index: %d, cmp: %d, %d\n",
          index_cmp,cmp[index_cmp].objid,cmp[index_cmp].osnum*/

     status = ISfill_or_not(msg, cmp[index_cmp], &yes, cmp_err);
     if (!status)
     {
        printf("error in ISfill_or_not\n");
        return 0;
     }

     if (yes)
     {
       /* creates lines in big to store the component */

       status = ISfill_big_cmp(msg, cmp[index_cmp], occ++,
                               &occ3000,nb_big, size_big, big,cmp_err);
       if (!status)
       {
         printf("error in ISfill_big_cmp\n");
         return 0;
       }
     }
     else 
     { 
       /*"component : %d, %d not filled in big\n",cmp[index_cmp].objid,
                                                       cmp[index_cmp].osnum*/
     }
  }

  UI_status("Processing...");
  /* free the cmp array\n */

  if(nb_cmp>0)
  {
    /*|dealloaction of cmp\n*/
    _FREE (cmp);
  }

  /*|get the connectic attributes\n*/
  status = ISfill_big_con(msg, frm, *nb_big, node_number, nb_big,
                     *big,dash_cmp,&nb_dash,&con_flag,triflex_flag,cmp_err);
  if (!status)
  {
     printf("error in ISfill_big_con\n");
     return 0;
  }
  frm2 = *nb_big;

  /*^print_big(0, *nb_big, *big );*/

  /* fills for all the components in big the other attributes */

  status = ISfill_big_attr(msg, frm, *nb_big, *nb_big,*big, cmp_err);
  if (!status)
  {
     printf("error in ISfill_big_attr\n");
     return 0;
  }

  /* changes in big for special components (nozzles, supports..) */

  UI_status("Processing...");
  status = ISfill_noz(msg, frm, *nb_big, *nb_big, *big);
  if (!status)
  {
     printf("error in ISfill_noz\n");
     return 0;
  }

  /*^print_big1( 0, *nb_big, *big );*/
 
  /* clear objid and osnum and fill a buffer with the needed attributes */

  if(buff_attr_init( &buff_attr, occ-1) != 1)
  {
    printf("Error in buff_attr_init\n");
    return 0;
  }

  tmp[0]  = 0;
  tmp[1]  = 0;
  cur_occ = 0;
  red_cp  = 0;

  for(i=0;i<*nb_big;i++)
  {
     short       nb_cp,init=0;
     char        comp_code[16];

     struct GRid        obj;
     struct ACrg_coll   rg_coll;

     get_big(*big,ROW,i,B_OCC ,2,(short *)&occ);
     if(occ != cur_occ) 
     {
       /* index: %d, occ: %d, nb_buff: %d\n",i,occ,buff_attr.nb_buff*/
       /*"index: %d, occ: %d\n",i,occ*/
       cur_occ = occ;
       get_big(*big,ROW,i,B_OBJID,2,(short *)&obj.objid);          
       get_big(*big,ROW,i,B_OSNUM,1,(short *)&obj.osnum);

#ifdef DB_ACCES
       if(genentp(msg, obj, &buff_attr, cur_occ, comp_code, cmp_err) != 1)
       {
           printf("Error fill_big, genentp() returns bad status\n");
           *msg = 0;

/* garbage, move into unallocated space or so ... TR # 179602055

           *cmp = obj;
*/
           cmp_err->objid = obj.objid;
           cmp_err->osnum = obj.osnum;

           return 0;
       }
#endif

       /* retrive red cp */
       rg_coll.desc.value.att_exp = -1;
       strcpy(rg_coll.name, VR_N_COMP_2ND_CP_IN);
       status =
       om$send(msg = message VRGeneric.VRGetCompDesc(msg, &rg_coll, NULL),
          senderid = NULL_OBJID,
          targetid = obj.objid,
          targetos = obj.osnum);
       as$status(action = RET_STATUS);
       red_cp = (int) rg_coll.desc.value.att_exp;

       get_big(*big,ROW,i,B_NBCP  ,1, (short *)&nb_cp);
       /*"nb_cp: %d, red_cp: %d\n", nb_cp, red_cp */
      
       /* fills the word 26 of big with connect point properties */
       /* red_cp:   0001 => cp 1 = red cp, 0011 => cp 1 and 2 = red cp, ... */ 
     }

     set_big(*big,ROW,i,B_NBCP,1,&init);
     set_big_mask(*big,ROW,i,B_NBCP,&nb_cp,IS_CP26);

     if(red_cp & 0x0001)
     {
         /*| cp 1 is a red cp */
         one = 0x0020;
         set_big_mask(*big,ROW,i,B_NBCP,&one,IS_MTO1);
     }  
     if(red_cp & 0x0002)
     {
         /*| cp 2 is a red cp */
         one = 0x0080;
         set_big_mask(*big,ROW,i,B_NBCP,&one,IS_MTO2);
     }
     if(red_cp & 0x0004)
     {
         /*| cp 3 is a red cp */
         one = 0x0200;
         set_big_mask(*big,ROW,i,B_NBCP,&one,IS_MTO3);
     }
     if(red_cp & 0x0008)
     {
         /*| cp 4 is a red cp */
         one = 0x800;
         set_big_mask(*big,ROW,i,B_NBCP,&one,IS_MTO4);
     }
     if(red_cp == 0 && nb_cp == 1)
     {
         /*| One cp */
     }
     else if(!(red_cp & 0x000F))
     {
         printf("Error comp: %d, %d, red cp: %d\n",obj.objid, obj.osnum,red_cp);
         *cmp_err = obj;
         return 0;
     }

#ifdef MY_DEBUG
    { IGRshort  mto;
    get_big(*big,ROW,i,B_NBCP  ,1,(short *)&mto);
    printf("mto: %x\n",mto);
    }
#endif
    
     /*| clear objid and osnum */
     set_big(*big,ROW,i,B_OBJID,2,tmp);          
     set_big(*big,ROW,i,B_OSNUM,1,tmp);
  }

  /* print the buffer buff_attr in an ascii output file */

#ifdef DB_ACCES
  print_buff_attr("att_file",&buff_attr);
#endif

  /* print the big array in an ascii output file */

  print_big_file(msg,big,nb_big,"big_file");

/* runs the TRIFLEX shell script */

#ifdef DB_ACCES
   status = kick_iso( VR_TRI_KSH_NAME, *nb_big, file,
                       units_set,triflex_flag,seed,def);
     
   if (!status)
   {
      printf("error in kick_iso\n");
      return 0;
   }
#endif

  if(buff_attr_dealloc(&buff_attr) != 1) return 0;

  *msg = MSSUCC;
  return 1;
}

end implementation Root;

