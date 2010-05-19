/* $Id: VDCmdDVlist.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/cmd/VDCmdDVlist.I
 *
 * Description:
 *		This method gets list of drawing views and their names
 *		which exist in the design file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDVlist.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.2  1995/08/31  21:48:36  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdDVlist.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:01:56  pinnacle
# Created: vdbatch/cmd/VDCmdDVlist.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/13/95	raju		creation date
 *
 ***************************************************************************/
class implementation  VDCmdBatDrw;


#include "OMmacros.h"
#include "vderrmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "detaildef.h"
#include "v_miscmacros.h"

from GRgrset	  import   GSstart_transition, GSend_transition;
from GRvg         import   GRgetname;

from GRdrawview   import   GRget_model_matrix;

extern IGRint		   GRgs_locate_action();


method VDgetDVlist( long *msg )
{
    IGRlong			om_msg,
				ret_msg;
    IGRlong			count;
    IGRint			properties;
    GRclassid			classid;
    OM_S_CLASSLIST		locate_eligible;
    struct GRlc_locate		attributes;
    struct GRlc_classes		classinfo;
    struct EX_button		button;
    struct GRid			args[2];
    struct GRid			sv_id;
    struct GRid			temp_id;
    IGRint			array_size;
    struct GRobj_env		*objects = NULL;
    IGRchar			*processed = NULL;
    int				i;
    GRname			element_name;
    IGRchar			buffer[BUFSIZ];
    struct GRmd_env		modEnv;

    IGRmatrix			dvMatrix;

    om_msg = OM_S_SUCCESS;
    ret_msg = MSSUCC;

    /*
     * This method can result in termination of process.
     * The locateWin needs to be having a NULL_OBJID value to avoid errors.
     */
    me->locateWin.objid = NULL_OBJID ;

    /*
     *  Create a graphics set and connect it to the located
     *  graphics channel.
     */

    gr$get_module_env (	msg  	= &ret_msg,
			buffer	= &modEnv) ;

    temp_id.osnum = modEnv.md_id.osnum;
    om_msg = gr$gsinit ( msg		= &ret_msg, 
			 flag		= 2, 
			 p_objid	= &temp_id.objid,
			 osnum		= modEnv.md_id.osnum,  
			 p_chanselect	= &me->located_chansel);
        
    /*
     *  Start a transition for the graphics set. 
     */
    properties = 0;
    om_msg = om$send ( msg = message GRgrset.GSstart_transition 
						( &ret_msg, 
						  &modEnv, 
						  &properties, 
						  NULL, 
						  &sv_id ),
			targetid = temp_id.objid,
			targetos = temp_id.osnum);

    /*
     *  Build the attributes structure.
     */
    attributes.owner_action =	LC_FLEX_COMP;
    attributes.properties =	IGN_RW_BIT  |
				IGN_DP_BIT  |
				IGN_MOD_BIT |
				IGN_PLANAR_BIT;

    /*
     *  Build class list.
     */
    om_msg = om$get_classid (	classname = "GRdrawview",
				p_classid = &classid );

    locate_eligible.w_count = 1;
    locate_eligible.w_flags = 0;
    locate_eligible.p_classes = &classid;
    classinfo.rtree_classes = NULL;
    classinfo.eligible_classes = &locate_eligible;
    button.objid = NULL_OBJID;
    button.osnum = modEnv.md_id.osnum;

    /*
     *  Query all objects looking for drawing views.
     */
    args[0] = temp_id;
    args[1] = sv_id;
    om_msg = GRgsquery_all (	&ret_msg, 
				&modEnv, 
				&attributes, 
				&classinfo, 
				NULL, 
				&button, 
				GRgs_locate_action, 
				args );
    /*
     *  Send the GSend_transition message.
     */
    om_msg = om$send ( msg = message GRgrset.GSend_transition ( &ret_msg, 
								NULL ),
			targetid = temp_id.objid,
			targetos = temp_id.osnum);

    count = 0;
    om_msg = gr$gsinqcount (	msg		= &ret_msg, 
				count		= &count,
				p_chanselect	= &me->located_chansel );

    if ( !(om_msg & ret_msg & 1) || !count ) me->ret = MSFAIL;


    /*
     * Find out how many drawing views there are.
     */
    count = 0;
    om_msg = gr$gsinqcount (	msg = &ret_msg,
				count = &count,
				p_chanselect = &me->located_chansel );

    if ( !count )
    {
	UI_status ( "No Drawing Views Found" );
	*msg = MSFAIL;
	goto wrapup;
    }

    array_size = count * sizeof(struct GRobj_env);
    objects = _MALLOC( count, struct GRobj_env );

    om_msg = gr$gsget_objects (	msg = &ret_msg,
				array = objects,
				size = array_size, 
				count = &count, 
				p_chanselect = &me->located_chansel );

    om_msg = om$vla_set_dimension(	varray	=  me->dvlist,
					size	=  count  );
    om_msg = om$vla_set_dimension(	varray	=  me->dvnames,
					size	=  count  );
    me->nbDv = count;

    if((om_msg & 1) && count )
    {
	processed = _MALLOC( count, IGRchar );

	for (i=0; i < count; ++i) processed[i] = FALSE;

	/*
	 * For all drawing views.
	 */
	for (i=0; i < count; ++i)
	{
	  /*
	   * If the drawing view has not been processed 
	   * already get the info.
	   *
	   * NOTE: This drawing view may have been processed
	   * by being aligned with a previously processed dv.
	   */
		om$send ( msg = message GRvg.GRgetname
					(&ret_msg, element_name),
			  targetos = objects[i].obj_id.osnum,
			  targetid = objects[i].obj_id.objid );


		if (element_name[0] == '\0') 
		{
/*
				sprintf( element_name,
					" No Name " );
*/
		}
		else 
		{
			di$cvt_name_for_output ( s_path = element_name,
						 u_path = buffer );
			sprintf(element_name,"%s", buffer);
		}

		__DBGpr_str("element_name", element_name );

		me->dvlist[i] = objects[i].obj_id;

		__DBGpr_obj( "dv mod_id", objects[i].mod_env.md_id );

		om_msg = om$send ( msg = message GRdrawview.GRget_model_matrix
							( &ret_msg,
							  &me->ModuleInfo,
							  1,
							  dvMatrix ),
				   targetid = objects[i].obj_id.objid,
				   targetos = objects[i].obj_id.osnum  );

		__DBGpr_mat( "dv matrix", dvMatrix );

		di$split ( pathname	= element_name,
			   name	= me->dvnames[i] );
        } /* End of for looop for all dvs */
    }

    gr$gsempty ( msg = &ret_msg, 
		 p_chanselect = &me->located_chansel );

	wrapup:

	_FREE( processed );
	_FREE( objects );
	return (OM_S_SUCCESS);
}


end implementation  VDCmdBatDrw;

