/* $Id: VDdrwObjnode.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwObjnode.I
 *
 * Description:
 *
 * Dependencies:
 *	VDdrwObj.S
 *
 * Revision History:
 *	$Log: VDdrwObjnode.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.1  1995/07/11  20:13:34  pinnacle
# Created: vddraw/imp/VDdrwObjnode.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/07/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwObj;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "grerr.h"

#include "asbox.h"
#include "grgsdef.h"
#include "nddef.h"
#include "ndmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "ACrg_collect.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

from	ACcpx_defn	import	ACintpt_foot, ACgive_feet_desc ;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDmove_to_root from NDnode

  Abstract
	The visualization objects need to protect there template collector
	to allow adding/modifying user attributes to the object. The
	graphical parent object will be deleted.

	Methods needs to be overriden to avoid deletion of the template
	collector.
	
 -------------------------------------------------------------------------
-mo*/


method NDmove_to_root(	IGRlong		*msg;
			struct GRid	*src_grid; 
			struct GRmd_env *md_env ){

	int		sts = OM_S_SUCCESS ,
			cnt ;
	struct GRid	myGRid,
			parObj;

	SetProc( VDdrwObj_NDmove_to_root ); Begin

	*msg	= MSSUCC ;

	/*
	 * test consumed/missing and recompute if necessary
	 */
	if( me->STATE & ncpx_missing ){

		sts = 
		_VD_SEND_MY( NDnode.NDs_compute_node(msg,ND_COMP,md_env));
		as$status( sts = sts );
		me->STATE &= (~ncpx_missing);
	}

	myGRid.osnum = OM_Gw_current_OS;
	myGRid.objid = my_id;

	if( me->state&ND_DONT_MVRT ){

		/*
		 * support only --> doesn't move to root 
		 */
		sts = 
		nd$wait_batch(	type	= GR_DELETED,
				nb_obj	= 1,
				l_object = &myGRid );
		sts = OM_S_SUCCESS;
	}
	else{
		/*
		 * instanciate parents and disconnect from them
		 */
		if( !( me->STATE & ncpx_root ))

			sts =
			_VD_SEND_MY( ACncpx.ACinstanciate_template_feet(
						msg,
						&myGRid,
						OM_K_MAXINT,
				    md_env->md_id.objid == NULL_OBJID ? 0 :1));

		/*
		 * Only delete the graphical parent object.
		 */
                sts =
                _VD_SEND_MY(    NDnode.NDget_objects(
                                                ND_ROOT, &parObj,
                                                1, NULL, 1, 1, &cnt ));
                CheckRC( sts, 1 ) ;

		sts =
		_VD_SEND_MY( NDnode.NDdisconnect( 1, &parObj ));
        	CheckRC( sts, 1 );
	}

	as$status( sts = sts );
	me->STATE = (me->STATE) | (ncpx_root);
	*src_grid = myGRid;

	End ;
	return( sts );
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACreturn_foot from NDnode

  Abstract
	The visualization objects need to protect there template collector
	to allow adding/modifying user attributes to the object. The
	graphical parent object will be deleted.

	Methods needs to be overriden to avoid deletion of the template
	collector.
	
 -------------------------------------------------------------------------
-mo*/

method ACreturn_foot(	IGRlong		*msg;
			char		*foot_name;     
			struct	GRid	*foot_GRid;
			IGRshort	*mat_type;
			IGRdouble	*matrix ){

	int		sts,
			pos, chan, type, 
			loc_msg, i,
			temp_foot_pos;
	struct GRid 	macro,obj,mygrid;
	char 		*chpos; 
	char		*strchr();

	SetProc( VDdrwObj_ACreturn_foot ); Begin

	*msg = MSFAIL;
	__DBGpr_str(" foot_name ", foot_name );

	foot_GRid->objid=NULL_OBJID;
	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
  
/***
	if(me->state & ND_DEGRADED){
		as$status(sts = 0,
		string = ("element %d degraded doesn't return foot %s \n",
			my_id,foot_name));
		*msg = MSFAIL;
		return(OM_W_ABORT);
	}
 ***/

	/*
	 * downscan is "." --> return for historic reason first graphic object
	 * connected on the component channel
	 */
	if('.'== foot_name[0]){

		sts =
		om$send(msg = message NDnodein.ACreturn_foot
		      (msg,foot_name,foot_GRid,mat_type,matrix ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );
		as$status( sts = sts );
		return( sts );
	}
	
	/*
	 * downscan is "" --> return myself
	 */ 

	else if( 0== foot_name[0] ){

		foot_GRid->osnum = OM_Gw_current_OS;
		foot_GRid->objid = my_id;
		*msg = MSSUCC;
		if( mat_type )	*mat_type = MAIDMX;
		if( matrix )	MAidmx(&loc_msg,matrix);
		return( OM_S_SUCCESS );
	}

	/*
	 * Find the foot corresponding to the downscan
	 */
	sts =
	_VD_SEND_MY( ACcpx.find_macro(&macro));
	as$status( sts = sts, action = RET_STATUS );

	/*
	 * If nesting find the nested collection obj and
	 * send it the return_foot message
	 */

	if( chpos = strchr(foot_name,':') ){
		*chpos = '\0';
		sts =
		_VD_SEND_MY( ACcpx.ACreturn_foot(msg,foot_name,&obj,NULL,NULL));
		*chpos = ':';
		if(!(sts&1)) *msg = MSFAIL;
		as$status(sts = sts, action = RET_STATUS );

		sts =
		_VD_SEND_OBJ(	obj,
				ACcpx.ACreturn_foot(msg,chpos+1,
						foot_GRid,mat_type,matrix));
		if( !(sts&1) ) *msg = MSFAIL ;
		return( sts );
	}

	/*
	 * There is no nesting, find the object
	 *  - on the owner channel, or
	 *  - on the template channel and copy to member 
	 */ 
	sts =
	_VD_SEND_OBJ(	macro,
			ACcpx_defn.ACintpt_foot((int *)msg,foot_name,
					&chan,&pos, &type));
	as$status( sts = sts, action = RET_STATUS );

	if(!(*msg)) return( OM_S_SUCCESS );

	if( chan == feet_in_graphic ){
	  /*
	   * Is it on owner channel
	    */
	  if( me->STATE & ncpx_missing ){

		struct GRmd_env		wk_env;
		IGRlong 		S1,S2;

		/*
		 * Recompute the consumed ACcpx
		 */
		S1 = sizeof (struct GRmd_env);
		sts =
		gr$get_module_env(	msg    = &loc_msg,
                	    		sizbuf = &S1,
                    			buffer = &wk_env,
                    			nret   = &S2 );
		as$status( sts = sts, action = RET_STATUS );
		sts =
		_VD_SEND_MY( NDnode.NDs_compute_node
				((IGRlong *)&loc_msg,ND_COMP,&wk_env));
		as$status( sts = sts );
		me->STATE &= (~ncpx_missing);
	  }

	  sts =
	  om$get_objid_at_index(objid		= my_id,
                                p_chanselect	= &AC_mto_graf_chns,
                                index		= pos,
                                objidaddr 	= &(foot_GRid->objid),
				osnumaddr 	= &(foot_GRid->osnum) );
	  if(!(sts&1) || pl_hold(*foot_GRid)){ *msg = MSFAIL; }
	  else{
		*msg = MSSUCC;
		if(mat_type) *mat_type = MAIDMX;
		if(matrix) MAidmx(&loc_msg,matrix);
	  }
	}
	else if(chan == feet_in_template ){

	  int		nb_feet;
	  struct myfeet *feet_desc;

	  /*
	   * If this template feet is already instanciated, returned it 
	   */
	  sts =
	  _VD_SEND_OBJ(	macro,
			ACcpx_defn.ACgive_feet_desc(&nb_feet,&feet_desc));
	  as$status( sts = sts, action = RET_STATUS );

	  pos = 0;
	  temp_foot_pos = -1;
	  for(i=0;i<nb_feet;i++){

	    if     ((feet_desc[i].chan & 3) == feet_in_graphic) pos++;
	    else if((feet_desc[i].chan & 3) == feet_in_template &&
					temp_foot_pos<0){

	      if(!strcmp(foot_name,feet_desc[i].name)) temp_foot_pos = nb_feet;
	      else pos++;
	    }
	  }
	  
	  sts =
	  om$get_objid_at_index(objid		= my_id,
                                p_chanselect	= &AC_mto_graf_chns,
                                index		= pos,
                                objidaddr 	= &(foot_GRid->objid),
				osnumaddr 	= &(foot_GRid->osnum) );
	  if( !(sts&1) ){

	    /*
	     * Need to instanciate template feet out of the rtree
	     */
	    sts =
	    _VD_SEND_MY( ACncpx.ACinstanciate_template_feet
					(msg,&mygrid,pos+1,0));
	    sts =
	    om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_GRid->objid),
				  osnumaddr 	= &(foot_GRid->osnum) );

	  }

	  if(!(sts&1) || pl_hold(*foot_GRid)){ *msg = MSFAIL; }
  	  else{
		*msg = MSSUCC ;
		if(mat_type) *mat_type = MAIDMX;
		if(matrix) MAidmx(&loc_msg,matrix);
	  }
	}

	/*
	 * virtual foot -> construct pretend
	 */
	else if( chan == feet_virtual ){

	  /*
	   *  construct virtual foot for pretend
	   */
	  sts =
	  _VD_SEND_MY( ACcpx.ACconnect_pretend((int *)msg,foot_name,foot_GRid));
	  as$status( sts = sts, action = RET_STATUS );
	  if(mat_type) *mat_type = MAIDMX;
	  if(matrix) MAidmx(&loc_msg,matrix);
	  *msg = MSSUCC;
	}

	End ;
	return( MSSUCC );
}

end implementation VDdrwObj;

