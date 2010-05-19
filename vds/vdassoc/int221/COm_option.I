/* $Id: COm_option.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / COm_option.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COm_option.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation COm_place;

#include "nddef.h"
#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ASmessages.h"
#include "madef.h"
#include "ACattrib.h"
#include "asbox.h"
#include "ACcondit.h"
#include "grerr.h"
#include "acmacros.h"


#define AS_DEBUG

from NDmacro import ACgive_structure,ACreturn_foot,ACcopy_to_Groot;
from ACdiowner import ACcreate,ACadd_component,ACadd_attribute_by_type,
		      ACadd_component_with_name;
from NDnode  import NDgive_structure, ASreturn_go, NDchg_state;
from ACmacro_defn       import ACgive_upscan,ACcreate_default;
from ACcond_def import ACgive_condit_desc;
from    ACrg_collect    import  ACset_list_attribute;
from    ACrg_collect    import  AClist_attribute;
from    ACdiowner       import  ACrem_attribute;
from    ACdiowner       import  ACmod_attribute;
from GRvg import GRgetname;

char *strrchr();

extern GRclassid OPP_ACcond_def_class_id, OPP_ASsource_class_id,
		 OPP_ACncpx_class_id,OPP_ACheader_class_id;

/* Get from the form the symbology to modify */
/* return options asociated to macro + options box ( we can have several
   optons box for the same macro */

COm_get_options_bis(macro,def_id,symb,hdr_scroll,hdr_type,hdr_def,search_path,
		post_placement,def_occ,md_env)
struct GRid *macro,*def_id;
int *symb;
enum ACm_poss_hdr *hdr_type;
enum ACm_poss_scroll *hdr_scroll;
enum ACm_poss_def_par *hdr_def;
char *search_path,*post_placement;
struct GRid *def_occ;
struct GRmd_env *md_env;
{
 IGRlong status,msg;
 struct ret_struct rst;
 GRclassid obj_class;

/* search path */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~search_path",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if((status&msg&1) && rst.type == text_type)
   {
    strcpy(search_path,rst.var.text_st.text_string);
    *hdr_def = USER_SPECIFIED;
    /*"search_path %s\n",search_path */
   }
  else
   {
    /*| in macro lib */
    *hdr_def = IN_MACRO_LIB;
    status = om$send(msg = message GRvg.GRgetname(&msg,search_path),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
   }

/* post placement ppl */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~post_placement",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if((status&msg&1) && rst.type == text_type)
   {
    strcpy(post_placement,rst.var.text_st.text_string);
    /*"post_placement %s\n",post_placement */
   }
  else
   {
    post_placement[0] = '\0';
   }

/* Symbology */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~symbology",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if(status&msg&1)
   {
    *symb = (int) rst.var.root_pm_st.value &
	    (CHG_LAYER | CHG_COLOR | CHG_WEIGHT | CHG_STYLE | INCR_LAYER |
	     CHG_DONT_MVRT | CHG_DEL_NO_CH);

    *hdr_scroll = (enum ACm_poss_scroll)
				((((int) rst.var.root_pm_st.value) >> 4) & 0x3);
    *hdr_type = (enum ACm_poss_hdr)
				((((int) rst.var.root_pm_st.value) >> 6) & 0x3);
   }

/* default occurence */

/*
   For conditional take the default occurence of the first macro in the
   condition
   modif jla feb 93, if not found directly in the condit option box
*/

  status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);

  if (!(msg&1))
  {
   status = om$get_classid(objid = macro->objid, osnum = macro->osnum,
			  p_classid = &obj_class);
   if(om$is_ancestry_valid(superclassid = OPP_ACcond_def_class_id,
			  subclassid = obj_class) == OM_S_SUCCESS)
   {
    int num_condit,i_condit,num_default;
    struct ACcond_descrip *condit_desc;
    struct ACcond_temp *temp_default;
    struct GRid macro1,def_id1;
    status = om$send(msg = message ACcond_def.ACgive_condit_desc(&num_condit,
				&condit_desc,&num_default,&temp_default),
		     senderid = NULL_OBJID,
                     targetid = macro->objid, targetos = macro->osnum);
    if(!(status&1)) num_condit = 0;
    for(i_condit=0 ; i_condit<num_condit ; i_condit++)
     {
      status = ac$find_macro_defn(action = ACfind_no_load,
			 macro_name = condit_desc[i_condit].konst,
                         p_macro_defn_id = &macro1);
      if(!(status&1)) continue;
      
      COm_get_option_grid(&macro1,&def_id1,(char *) NULL);

      if(def_id1.objid != NULL_OBJID)
       {
        status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id1.objid,
                   targetos = def_id1.osnum);
        if(msg&1) break;
       }
     }
   }
  }

/* remove jla jan 93 */
/* else
/*   {
/*   status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
/*                                      "~~occurence",def_occ,NULL,NULL),
/*		   senderid = NULL_OBJID,
/*                   targetid = def_id->objid,
/*                   targetos = def_id->osnum);
/*  }
/*******/

if(!(msg&1))
   {
    struct GRid def_id1;
    /* This could be an aternative option box without default occurence */
    COm_get_option_grid(macro,&def_id1,(char *) NULL);
    if(def_id1.objid != def_id->objid)
      status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id1.objid,
                   targetos = def_id1.osnum);
   }
 if(!(msg&1)) def_occ->objid = NULL_OBJID;

/*"default occurence %d %d\n",def_occ->objid,def_occ->osnum*/

 return(OM_S_SUCCESS);
}
end implementation COm_place;
