/* $Id: SMCompCol.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMcomp.S
 *
 * Description:
 *
 *      This file implements some functions to get info from the collections
 *	connected to the compartment.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCompCol.I,v $
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
# Revision 1.2  1996/04/29  08:50:36  pinnacle
# Replaced: smcomp/imp/SMCompCol.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      04/24/92        Ch. Heraud      Creation date.
 *      06/01/94        P. Lacroix      subclass under VDSroot.
 *
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "ACattrib.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "VDSutil.h"
#include "math.h"
#include "SMcomp_def.h"
#include "SMCompForm.h"
#include "VDmem.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from	ACdyn_col	import	ACset_att_prop;

extern	GRclassid	OPP_SMcoll_class_id;

#define AS_DEBUG

#define SM_MAX_VOL_ATT 5


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompInitCol

  Abstract

       	Create the collection for the compartment and for each volume.
 	 It also adds the minimum requested attributes inside. 
	 The CompDynRoots array must be allocated by the caller to
	 NbRoots.

	 ComDynCol can be NULL if the caller don't want to construct it.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/


SMCompInitCol(CompDynCol, NbRoots, CompDynRoots, mod_env)
struct GRid	 *CompDynCol;	    /* Dynamic collect for the compart   (O) */
int		  NbRoots;	    /* Number of roots collect to create (I) */
struct GRid	 *CompDynRoots;	    /* Array of roots Dynamic collect	 (O) */
struct GRmd_env	 *mod_env;	    /* Current module 	 		 (I) */
/*
-fi */
{
 int 			i, j, nb_attr;
 long			msg, sts;
 struct	ACrg_coll	att[SM_MAX_VOL_ATT];
 IGRshort		int_prop, user_prop;

 /* Creating of the collection objects  */
 
 if(CompDynCol != NULL)
  {

   CompDynCol->osnum = mod_env->md_id.osnum;
   sts = om$construct( classid = OPP_SMcoll_class_id,
                     osnum   = CompDynCol->osnum,
                     p_objid = &CompDynCol->objid );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

   sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),
			senderid = NULL_OBJID,
                        targetid = CompDynCol->objid,
                        targetos = CompDynCol->osnum );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
 }

 for(i=0;i<NbRoots;i++)
  {
   CompDynRoots[i].osnum = mod_env->md_id.osnum;
   sts = om$construct(classid = OPP_SMcoll_class_id,
                      osnum   = CompDynRoots[i].osnum,
                      p_objid = &CompDynRoots[i].objid );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

   sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),
			senderid = NULL_OBJID,
                        targetid = CompDynRoots[i].objid,
                        targetos = CompDynRoots[i].osnum );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

   /* Add the minimum attributes for the each roots dynamic collection */
   nb_attr = SM_MAX_VOL_ATT;
   if(SMCompVolColl(att, &nb_attr) != 1) goto wrapup;

   sts = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                nb_attr,
                                                att),
			senderid = NULL_OBJID,
                        targetid = CompDynRoots[i].objid,
                        targetos = CompDynRoots[i].osnum );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
   if(!(msg &1)) goto wrapup;

   /* Set to SYSTEM & DYNAMIC */
   int_prop  = 0;
   user_prop = SM_SYST_ATT;

   for(j=0;j<nb_attr;j++)
    {
     sts = om$send(msg = message ACdyn_col.ACset_att_prop(&msg, att[j].name, 
     						     int_prop, user_prop),
			senderid = NULL_OBJID,
                        targetid = CompDynRoots[i].objid,
                        targetos = CompDynRoots[i].osnum );
     as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
     if(!(msg &1)) goto wrapup;
    }
  }
 return 1;

wrapup:

 return 0;

}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompVolColl

  Abstract

  Fill a Acrg_coll structure with the minimum attribute names and    
  default values for a root volume or compartment.
  The argument att must be allocated by the user.                    
  The argument nb_att indicates the size of att (entry) and the      
  number of filled elements.                                         

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

SMCompVolColl(att, nb_attr)
struct	ACrg_coll	att[];      /* I/O Array of attributes      */
int 			*nb_attr;   /* I/O  Number of attributes    */
/*
-fi */
{ 
   int   nb_alloc;

   nb_alloc = *nb_attr;
   *nb_attr = 0;

   if(*nb_attr >= nb_alloc) return 0;
   strcpy(att[*nb_attr].name, "exclude");
   att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( att[*nb_attr].desc.value.att_txt, "no");
   (*nb_attr)++;

   return 1;
 }

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompDynColl

  Abstract

 Parse list of static and dynamic attributes to determines their types  
 Some attrbutes are needed . If they are not found in collection static 
 or dynamic, put them a default value                                   
 Output list of attributes                                              

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

SMCompDynColl(nb_stat,stat_att,nb_dyn,dyn_att,att,att_type,nb_attr)
struct VDSatt_family stat_att[],dyn_att[]; /* [I] static and dynamic to parse */
int nb_stat,nb_dyn;                        /* [I] number of attributes */
struct	ACrg_coll  att[];                  /* [O]   Array of attributes */
IGRshort att_type[];                       /* [O]   type of attributes */ 
int     *nb_attr;                          /* [I/O] Number of attributes    */
/*
-fi */
{
  int   nb_alloc,val_int;

  static struct init_att NeedAtt[] = {
   {"name",AC_ATTRIB_TEXT,""},
  {"dead_weight",AC_ATTRIB_TEXT,""},
  {"grp",AC_ATTRIB_TEXT,""},
  {"sub_grp",AC_ATTRIB_TEXT,""},
  {"h_type",AC_ATTRIB_TEXT,""},
  {"short_desc",AC_ATTRIB_TEXT,""},
  {"descript",AC_ATTRIB_TEXT,""},
  {"location",AC_ATTRIB_TEXT,"inside"},
  {"struct_coef",AC_ATTRIB_DOUBLE,"0.95"},
  {"permeability",AC_ATTRIB_DOUBLE,"0.95"},
  {"zone",AC_ATTRIB_TEXT,""},
  {"overlap",AC_ATTRIB_DOUBLE,"0.0"},
  {"tightness",AC_ATTRIB_TEXT,"watertight"},
  {"expected_vol",AC_ATTRIB_DOUBLE,"0.0"},
  {"expected_area",AC_ATTRIB_DOUBLE,"0.0"},
  {"space_class",AC_ATTRIB_TEXT,""},
  {"pseudo",AC_ATTRIB_TEXT,"no"},
  {"x_offset",AC_ATTRIB_DOUBLE,"0.0"},
  {"y_offset",AC_ATTRIB_DOUBLE,"0.0"},
  {NULL,AC_ATTRIB_TEXT,NULL}};

  nb_alloc = *nb_attr;
  
    /* Parse list of static and dynamic attributes to determines their types */
  if(!SMParseDynColl(NeedAtt,nb_stat,stat_att,nb_dyn ,dyn_att,
		     att,att_type,nb_attr))
   { printf("Error copy attributes\n"); return 0; }

  if(*nb_attr + 5 >= nb_alloc)
    /* Add 5 because some compute attributes add latter */ 
   {printf("Too Much attributes\n");return 0;}
 
  val_int = SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME|
            SM_CMP_CAL_VOLS       | SM_CMP_VRF_OVER ;
  strcpy(att[*nb_attr].name, "cmp_props");
  att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
  att[*nb_attr].desc.value.att_exp = (double) val_int;
  (*nb_attr)++;

  return 1;
}


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompReadDbAtt

  Abstract

  Fill a Acrg_coll structure with the minimum attribute names and    
  default values for the dynamic collection of a compartment.        
  The attributes are retrieve from database                          
  The argument att must be allocated by the user.                    
  The argument nb_att indicates the size of att (entry) and the      
  number of filled elements                                          

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/


SMCompReadDbAtt(family,part_name,part_rev,att,att_type,nb_attr)
char    *family;                    /* [I]   family name */
char    *part_name;                 /* [I]   Part name */
char    *part_rev;                  /* [I]   Part revision */
struct	ACrg_coll  att[];           /* [O]   Array of attributes */
IGRshort att_type[];                /* [O]   Array of type of attributes */ 
int     *nb_attr;                   /* [I/O] Number of attributes    */
/*
-fi */
{
  struct VDSatt_family *stat_att = NULL,*dyn_att = NULL;
  int nb_stat,nb_dyn;

  if(!VDSget_attr(family,part_name,part_rev,"",
		  &nb_stat,&stat_att,&nb_dyn,&dyn_att))
    return 0;
  
  /* Parse list of static and dynamic attributes to determines their types */
  if(!SMCompDynColl(nb_stat,stat_att,nb_dyn,dyn_att,att,att_type, nb_attr))
    return 0;
 
  _FREE(stat_att) ;
  _FREE(dyn_att) ;
  return 1;
}

end implementation SMcomp;
 

