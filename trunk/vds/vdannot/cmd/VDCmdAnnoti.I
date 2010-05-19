/* $Id: VDCmdAnnoti.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdAnnoti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdAnnoti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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
# Revision 1.3  1996/02/16  23:54:12  pinnacle
# Replaced: ./vdannot/cmd/VDCmdAnnoti.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/25  22:49:18  pinnacle
# Replaced: vdannot/cmd/* for:  by jwfrosch for vds.240
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

class implementation VDCmdAnnot;

#define	AS_DEBUG 1

#include "form_env.h"
#include "dimformdef.h"
#include "dimform.h"
#include "dimgraph.h"
#include "griodef.h"
#include "AS_status.h"
#include "string.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "exmacros.h"
#include "v_dbgmacros.h"
#include "ciexecmacros.h"

#include "VDmsg.h"

from	ci	import	exec_fun;
from	DMroot	import	DMreturn_roots;
from	NDnode	import	NDdelete;
from	ACcpx	import	find_macro;
from	ACcpx_defn import ACgive_name;
from	GRgraphics import GRdelete;

extern GRclassid 	OPP_GRbspline_class_id;
extern GRclassid	OPP_nci_macro_class_id;


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

method init_type()
{
int	status = OM_S_SUCCESS;

 me->an_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
 me->an_attr.dim_type  = me->mytype;
 me->count = NO_TEXT_LEADER_ROOTS;
 me->arrow_index = AN_ROOT_ELEM1;

/* delete the form created by anplace.init */

 if(me->form)
   {
    FIf_delete(me->form);
    me->form = NULL;
   }

 me->action = PRT_LD;
 me->state = INITIAL;
 me->rel_key = DM_E_EltNotFound;

 /*
  * KLUDGE for drawing_macro objectsin reference files.
  *  status = VDreadDrawingMacro( &me->md_env );
  */

 return OM_S_SUCCESS;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
IGRlong	status = OM_S_SUCCESS;

  *msg = 0;
  if(me->state == WAIT_LEA)
    *msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);

  return(status);
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
 return OM_S_SUCCESS;
}

method LC_postproc()
{
 return OM_S_SUCCESS;
}

method get_keybrd_input(char *string)
{
IGRint  status, rc;
struct DMkeyboard dm_keyboard;
struct DMkeyboard *p_dm_keyboard;
OM_S_OBJID objid;
OMuword osnum;
CIpushlist argv[1];

	/*"string=%s\n", string*/

	strncpy(dm_keyboard.response, string, 80);
	dm_keyboard.response[79] = '\0';
	dm_keyboard.status[0] = '\0';

	status =
	om$os_name_to_number(osname = "OM_TransOS_0", p_osnum = &osnum);
	as$status(action =  RET_STATUS);

	/*"osnum=%d\n", osnum*/

	status =
	ci$load(file_name = "forms_annot",
		sender_id = NULL_OBJID,
		load =  LOAD,
		file_id = &objid);
	as$status(action =  RET_STATUS);

	/*"objid=%d, osnum=%d\n", objid, osnum*/

	p_dm_keyboard = &dm_keyboard;
	argv[0].addr = &p_dm_keyboard;
	argv[0].size = sizeof(struct DMkeyboard *);

	ci$push(argc = 1, argv = argv);

	status =
	om$send(msg = message ci.exec_fun(
				&rc,
				"keyboard_input",
				NULL,
				NULL,
				0,
				NULL,
				0),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
	as$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method delete_dimension()
{
IGRint	status = OM_S_SUCCESS;
struct	GRid	list[10], parId, macro;
IGRint	index, count, j,
        s_count, s_count1;
IGRlong msg;
IGRchar c_name[80],*c;
OM_S_OBJECT_LINKAGE slist1[10],
                    slist[10];

  if( me->an_grid.objid == NULL_OBJID )
  {
    /*| No such dimension exists */
    return(OM_S_SUCCESS);
  }

  parId.objid = NULL_OBJID;
  macro.objid = NULL_OBJID;

  /*
   * disconnect the ci_macro "src_obj" if it exists,
   * and delete it before deleting of the annotation itself 
   */

   status =
   om$send(msg       = message DMroot.DMreturn_roots( &count, list ),
           targetid  = me->an_grid.objid,
	   targetos  = me->an_grid.osnum,
	   senderid  = NULL_OBJID );
   as$status( action = RET_STATUS );

   for( index=0 ; index<count ; index++ )
   {
       status =
       om$get_classname(objid     = list[index].objid,
                        osnum     = list[index].osnum,
                        classname = c_name );
       as$status();
       if( om$is_ancestry_valid(
                              subclassname = c_name,
                              superclassname = "DMsrc" ) == OM_S_SUCCESS )
       {

                 parId.objid = list[index].objid ;
                 parId.osnum = list[index].osnum ;
                 break;
       }
   }

  if( parId.objid != NULL_OBJID )
  {
        /*
         * get ACpretend
         */
        status =
        om$get_channel_count(osnum   = parId.osnum,
                             objid   = parId.objid,
                             p_chanselect = &ND_father,
                             count   = (OMuint *)&s_count );

        status =
        om$get_channel_objects( osnum   = parId.osnum,
                                objid   = parId.objid,
                                p_chanselect = &ND_father,
                                size    = 10,
                                list    = slist,
                                count   = (OMuint *) &s_count );
       /*
        * Get the nci_macro "src_obj"
        */

        for (j=0; j < s_count; j++ )
        {
                om$get_channel_count(   osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        count   = (OMuint *)&s_count1 );
                status =
                om$get_channel_objects( osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        size    = 10,
                                        list    = slist1,
                                        count   = (OMuint *) &s_count1 );

                /*
                 * test on objects for macro src_obj.
                 */

                om$send(msg = message ACcpx.find_macro(&macro),
                        targetid = slist1[j].S_objid,
                        targetos = slist1[j].osnum);

                if( macro.objid == NULL_OBJID ) continue;

                status =
                om$send(msg = message ACcpx_defn.ACgive_name( &c ),
                        targetid = macro.objid,
                        targetos = macro.osnum);
                as$status();

                if( strcmp( c, "src_obj" ) == 0 )
                {
                        break;
                }
         }
         if( macro.objid != NULL_OBJID )
         {
              status =
               om$send(msg = message GRgraphics.GRdelete( &msg, &me->md_env ),
                       targetid = slist1[j].S_objid,
                       targetos = slist1[j].osnum);
	    CheckRC( msg, status );
         }
  } 

  status =
  om$send(msg = message COanplace.delete_dimension (),
          mode = OM_e_wrt_message,
          targetid = my_id);
  __CheckRC( 1, status, "COanplace.delete_dimension", wrapup );

wrapup:
  return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
end implementation VDCmdAnnot;
