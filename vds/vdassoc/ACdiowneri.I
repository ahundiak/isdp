/* $Id: ACdiowneri.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACdiowneri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACdiowneri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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

/*
 * Correction for the call ACgive_path for objects of class ACrg_collect.
 * Problem occurs in EMS 3.0
 * Ludo  Apr-21-1994
 */
 
class implementation ACdiowner;

#include "AS_status.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "expression.h"
#include "expmacros.h"
#include "ASmsg.h"
#include "grmsg.h"
#include "OMmacros.h"
#include "msmacros.h"

extern	GRclassid	OPP_ACrg_collect_class_id;

static get_componant_ch(componant) 
OM_S_CHANSELECT **componant;
{
 static int componant_def = 0;
 static OM_S_CHANSELECT componant_desc;
 IGRlong status;

 if(componant_def == 0)
   {
    status = om$get_channel_number( channame ="GRcmpowner.to_components",
                                   p_channum = &componant_desc.u_sel.number);
    as$status(action = RET_STATUS);
    componant_desc.type  = OM_e_num;

    componant_def = 1;
   }
 *componant = &componant_desc;

 return 1;
}

/* Return the name of a component */

method ACgive_path(IGRlong *msg; struct GRid *go_obj; char *name)
{
/*
 * The ACrg_collect has to override this message, but until we cannot modify
 * the spec file to declare this override we have to write the code a this
 * level and used a bad get_classid macro to select the real class of the 
 * object.		april 94 LLC.
 *
 * Kludge description :
 * An ACrg_collect object has ephemeral componants. The componants decription
 * are done after the regular list of attributs. For this reason we have to
 * move the index limite of the loop.  
 */

OMuint index;
int index_attr,status;
OM_S_CHANSELECT *componant;

/*
 * Variable used for the ACrg_collect Kludge
 */
GRclassid	cid;
int		startind, endind;

  /*" give_path for %d\n",go_obj->objid */

  get_componant_ch(&componant);
  status = om$get_index(object_c = me,
		       p_chanselect = componant,
		       objid = go_obj->objid,
		       osnum2 = go_obj->osnum,
		       indexaddr = &index);

  /*" at index %d\n",index */
  *msg = 0;

  /*
   * Kludge for ACrg_collect for 3.0
   * define the good index for the loop
   */
  om$get_classid(	objid	  = my_id, 
			p_classid = &cid );

  if( om$is_ancestry_valid(subclassid	= cid,
                         superclassid	= OPP_ACrg_collect_class_id )
					== OM_S_SUCCESS ){
	int nb_comp = 0;
	int total_size = 0;

   	om$get_channel_count(objid = my_id,
			    p_chanselect = componant,
			    count = (OMuint *) &nb_comp);

   	total_size = om$dimension_of(varray = me->attr_def);
	total_size = total_size < nb_comp+me->nb_attr ? 
			total_size : nb_comp+me->nb_attr ;

	startind = me->nb_attr;
	endind	 = total_size;
  }
  else{

	startind = 0;
	endind   = me->nb_attr;
  }

  if(status&1){
    for( index_attr=startind; index_attr< endind; index_attr++ ){
      if(me->attr_def[index_attr].index == index){

 	     strcpy(name,&me->attr_name[me->attr_def[index_attr].name]);
	     /*" return name %s\n",name */
	     *msg = 1;break;
      }
    }
  }
  return (OM_S_SUCCESS);
}

end implementation ACdiowner;


