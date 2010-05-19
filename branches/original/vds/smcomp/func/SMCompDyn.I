/* $Id: SMCompDyn.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	SMcomp/func/SMCompDyn.I
 *
 * Description:	
 *
 *	This file contains methods and functions for the SMCmdComp command
 *	object.
 *
 * Dependencies:
 *	SMCmdComp
 *
 * Revision History:
 *	$Log: SMCompDyn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/03/18  10:54:38  pinnacle
# Replaced: SMCmdSurf.S for:  by ksundar for vds.240
#
# Revision 1.1  1995/07/24  20:41:56  pinnacle
# Created: smcomp/func/SMCompDyn.I by hverstee for vds.240
#
 *
 * History:
 *      07/24/95        HV  split off from smcomp/cmd/SMCompNotif.I
 * -------------------------------------------------------------------------
 */


class implementation SMCmdComp;

#include <stdlib.h>
#define AS_DEBUG       1

#include "AS_status.h"

from SMgroup    import SMGetSbGrp,SMGetSgrpId;
from SMcoll     import SMSetDbInfo;            
from ACdb_info  import ACset_db_info;            
from NDmacro    import ACreturn_foot;            
from NDnode     import NDchange_connect,NDget_objects,NDdisplay;
from GRgraphics import GRputname;
from SMcomp     import ACmplace,SMSetDwSymb,SMGetGrp,SMSetAtt,
                       SMResetAtt,SMGetDw,SMGetVolInfo,SMDiscRoots,
                       SMAddRoots,SMModPtTxt,SMListAtt;
from SMcoll     import ACadd_list_attribute,AClist_attribute,
                       ACmod_list_attribute,ACset_list_attribute;
from SMmgr      import SMGetShortName,SMGetAttDbl,SMGetAttTxt,
                       SMChgState,SMSetState;


extern GRclassid        OPP_SMcomp_class_id;
extern GRclassid        OPP_EMSsolid_class_id;


/*+fi
 -------------------------------------------------------------------------
  Internal Function is_define_attr

  Abstract
	This function look for the given attribute name in the list
	of attributes.

  Returns
	1 if the attribute is found in the list.
	0 otherwise.

 -------------------------------------------------------------------------
*/

static int is_define_attr(att_name,att,nb_att)
char att_name[];              /* [I] name of the attribute to find      */
struct	ACrg_coll  att[];     /* [I] list of attributes where to search */
int nb_att;                   /* [I] nb of attributes in the att list   */
/*
-fi */
{
  int i;

  for(i=0;i<nb_att;i++)
    if(strcmp(att_name,att[i].name) == 0) return 1;
  return 0;
}
	      

/*+fi
 -------------------------------------------------------------------------
  Internal Function parse_att

  Abstract
	That function parses the list of attributes (static or dynamic given
	by type_fam) into an ACrg_coll.
	It also output the type of the attribute:
		. type_fam | SM_SYST_ATT if the attribute is in NeedAtt .
		. type_fam | SM_USER_ATT otherwise.

  Returns
        nothing, it is a void function.


 -------------------------------------------------------------------------
*/

static void parse_att(NeedAtt,att_fam,nb_to_parse,type_fam,
		      att,att_type,nb_attr)
struct init_att        *NeedAtt;    /* [I] Need Attributes for object */
struct  VDSatt_family  att_fam[];   /* [I] Family to parse */
int                    nb_to_parse; /* [I] Number of element of family */
IGRshort               type_fam;    /* [I] SM_STATIC_ATT or SM_DYNAMIC_ATT */
struct	ACrg_coll      att[];       /* [O] Array of attributes */
IGRshort               att_type[];  /* [O] Array of type of attributes */ 
int                    *nb_attr;    /* [I/O] Number of attributes    */
/*
-fi */
{     
  int i,j;

#ifdef JJ_DEBUG
  if(type_fam ==  SM_STATIC_ATT)
    printf("\n-------------- Static attributes -------------------\n");
  else
    printf("\n-------------- Dynamic attrinutes ------------------\n");
#endif


  for(i = 0; i < nb_to_parse; i++)
   {

#ifdef JJ_DEBUG
     printf("Attribut %s ",att_fam[i].attr.name);
     if(att_fam[i].attr.desc.type == AC_ATTRIB_TEXT)
       printf("Value %s \n",att_fam[i].attr.desc.value.att_txt);
     else
       printf("Value %g \n",att_fam[i].attr.desc.value.att_exp);
#endif

     strcpy(att[*nb_attr].name,att_fam[i].attr.name);
     j = 0;
     while(NeedAtt[j].name)
      {
	if(strcmp(att_fam[i].attr.name,NeedAtt[j].name) == 0)
	 {
	   att_type[*nb_attr] =  SM_SYST_ATT | type_fam;
	   break;
	 }
	j++;
      }
     if(!NeedAtt[j].name)
       att_type[*nb_attr] = SM_USER_ATT | type_fam;
     
     switch(att_fam[i].attr.desc.type)
      {
      case AC_ATTRIB_TEXT:
	att[*nb_attr].desc.type =  AC_ATTRIB_TEXT;
	strcpy(att[*nb_attr].desc.value.att_txt,
	       att_fam[i].attr.desc.value.att_txt);
	break;
      case AC_ATTRIB_DOUBLE:
	att[*nb_attr].desc.type =  AC_ATTRIB_DOUBLE;
	att[*nb_attr].desc.value.att_exp = att_fam[i].attr.desc.value.att_exp;
	break;
      default:
	printf("Unknown type of attributes\n");
      }
     (*nb_attr)++;
   }
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMParseDynColl

  Abstract

	That function parses the 2 lists of static and dynamic attributes 
	into a unique ACrg_coll.
	It also output the type of the attribute:
		. type_fam | SM_SYST_ATT if the attribute is in NeedAtt .
		. type_fam | SM_USER_ATT otherwise.

	If one needed attributes in list is not defined by database (neither
	in static or dynamic ), it is added in the returned ACrg_coll as an
	attribute with type_fam = SM_SYST_ATT | SM_DYNAMIC_ATT.

  Returns
	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/

int
SMParseDynColl(NeedAtt,nb_stat,stat_att,nb_dyn,dyn_att,att,att_type,nb_attr)
struct init_att      *NeedAtt;             /* [I] Need Attributes for object */
struct VDSatt_family stat_att[],dyn_att[]; /* [I] static and dynamic to parse */
int                  nb_stat   ,nb_dyn;    /* [I] number of attributes */
struct	ACrg_coll    att[];                /* [O]   Array of attributes */
IGRshort             att_type[];           /* [O]   Array of type of attrib */ 
int                  *nb_attr;             /* [I/O] Nb of att (I=alloc;O=found */
/*
-fi */
{
  int    nb_alloc,i;
  double val_db;
 
  nb_alloc = *nb_attr;
  *nb_attr = 0;

  /* Verify allocation  */
  if( nb_stat + nb_dyn >= nb_alloc)
    {printf("Too Much attributes\n");return 0;}

  parse_att(NeedAtt,stat_att,nb_stat,SM_STATIC_ATT,att,att_type,nb_attr);

  parse_att(NeedAtt,dyn_att,nb_dyn,SM_DYNAMIC_ATT,att,att_type,nb_attr);

  i = 0;

  /* If one needed attributes in list is not defined by database, set it now */

  while(NeedAtt[i].name) 
   {
     if(!is_define_attr(NeedAtt[i].name,att,*nb_attr))
      {
	if(*nb_attr + 1 >= nb_alloc)  
	 {printf("Too Much attributes\n");return 0;}

	strcpy(att[*nb_attr].name,NeedAtt[i].name);
	att_type[*nb_attr] =  SM_SYST_ATT | SM_DYNAMIC_ATT;

	switch(NeedAtt[i].type)
	 {
	 case AC_ATTRIB_TEXT:
	   att[*nb_attr].desc.type =  AC_ATTRIB_TEXT;
	   strcpy(att[*nb_attr].desc.value.att_txt,NeedAtt[i].value);
	   break;
	 case AC_ATTRIB_DOUBLE:
	   att[*nb_attr].desc.type =  AC_ATTRIB_DOUBLE;
	   val_db = atof(NeedAtt[i].value);
	   att[*nb_attr].desc.value.att_exp = val_db;
	   break;
	 }
	(*nb_attr)++;
      }
     i++;
   }

  return 1;
}

end implementation SMCmdComp;






