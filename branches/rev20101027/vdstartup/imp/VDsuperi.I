/* $Id: VDsuperi.I,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDsuperi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsuperi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  19:47:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/08/17  22:54:18  pinnacle
# Replaced: vdstartup/imp/VDsuperi.I for:  by azuurhou for vds.240
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
 *	08/10/1995	Ravi		Addded wake_up method 
 *					( fix for TR#179423040 )
 *	10/31/97	ah		warning messages
 * -------------------------------------------------------------------*/

class implementation VDsuper;

#include <stdio.h>
#include "OMminimum.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdprdmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "madef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "acdef.h"
#include "acmacros.h"
#include "grmessage.h"

#include "OMversion.h"
#include "expression.h"
#include "expmacros.h"
#include "v_dbgmacros.h"

/* to avoid multiple untranslate of VDsuper and font mgr */

%safe 
struct GRid VDsuper_grid = { (GRspacenum)-1, (GRobjid)-1 };
%endsafe

extern void GRregister_switch_prod_callback();
extern char EX_runname[];

/*
struct GRid VDsuper_grid = { -1, -1 };
extern struct GRid VDsuper_grid ;
*/

/********************************************************************
  Construct if necessary a VDsuper object in the current directory
*********************************************************************/

void
VDsuper_construct()
{
OM_S_OBJID	super_id;
struct	GRid	mod;

	/*
	 * get the module environment 
	 */

	SetProc( VDsuper_construct ); Begin

	ex$get_cur_mod(	id	= &mod.objid,
			osnum	= &mod.osnum);

	if( mod.osnum != VDsuper_grid.osnum ){

		/*
		 * call get super
		 */
		ex$get_super(	mod_id		= mod.objid,
	       			mod_osnum	= mod.osnum,
				super_name	= "VDsuper",
				create		= TRUE,
				super_class	= "VDsuper",
				super_id	= &super_id );

		VDsuper_grid.objid = super_id;
		VDsuper_grid.osnum = mod.osnum;
	}

	End ;
}


method sleep(IGRint pos)
{
	int		status,
			msg;
	struct GRmd_env mod_env;
	OM_S_OBJID	md_id;
	int		write_mode;
	GRspacenum	master_os;
	struct GRid	tmp_obj;

	SetProc( VDsuper_sleep ); Begin

	VDsuper_grid.objid = NULL_OBJID;
	VDsuper_grid.osnum = (GRspacenum) -1;

	/*
	 * Retrieve current module OS and ask if
	 * the sleeped OS goes to file
	 */
	status =
	ex$get_cur_mod(	osnum		= &master_os );

	status = 
	ex$get_modid(	mod_osnum	= OM_Gw_current_OS,
			mod_id		= &md_id);

	status =
	ex$file_status(	modid		= md_id,
			modos		= OM_Gw_current_OS,
			mode		= &write_mode);

	if ( write_mode == 0 || pos != 0) {

		/* 
		 * Store also the GRNUC stamp number.
		 * This stamp is also stored in the file of the
		 * object space but there
		 *
		 * There is no way to access it .... 
		 */
	}

	/*
	 * Sleep is only necessary if the sleeped module goes to file
	 */

	if( write_mode == 0 ){

		/*
		 * construct module env
		 */

		mod_env.md_id.objid = md_id;
		mod_env.md_id.osnum = OM_Gw_current_OS;
		mod_env.md_env.matrix_type = MAIDMX;
		MAidmx( &msg, mod_env.md_env.matrix );

		if( pos == 0 && master_os == OM_Gw_current_OS ){

			/*
			 * Close Ris schema (if open)
			 */ 

			/*
			 * DON'T DETACH THE RIS SCHEMA, WAITING TO KNOW 
			 * MORE ABOUT THE INTERACTION RIS AND PDM/PDU
			 */

		/*** 
			VdsRisDetach();
		 ***/

		}
	}

	/*
	 * See if Expression VDSproject_num in transient OS exists 
	 * Need to delete it while trying to retrieve another file
	 */

	status =
	di$translate(	objname	=":transient:VDSproject_number", 
  			p_objid = &tmp_obj.objid,
			p_osnum = &tmp_obj.osnum);
	if( status == DIR_S_SUCCESS ){

		status = 
		exp$delete(	exp_id = tmp_obj.objid,
				osnum  = tmp_obj.osnum,
				p_md_env = NULL );
		if(!(status & 1))
			printf("WARNING: Can not remove project number\n");
  	}

	End ;
	return(OM_S_SUCCESS);
}

/*----------------------------------------------------------------------------
* method : wake_up
*
* Desc   : This overrides the global class wake_up method and adds the pocket
*	   menu buttons to EMS pocket menu for VDS, STRUCT,ROUTE,LOFT.
*	   It register the VDaddToPcktMenu function as call back for  switch
*	   proding.( Fix for TR#179423040 )  
*           
*
----------------------------------------------------------------------------*/
method wake_up()
{
	long		sts;
	char		*prod = NULL;
	GRspacenum	osnum ;

	extern		void VDaddToPcktMenu();

	SetProc( VDsuper_wake_up ); Begin

        sts = om$send ( msg = message global_class.wake_up ( ),
                        mode = OM_e_wrt_message,
                        targetid = my_id  );
        if ( !(sts&1) )
	{
	   printf("%s[%d] : global_class.wake_up ERROR\n", __FILE__, __LINE__);
	   return OM_W_ABORT;
	}

	/*
	 * The object space and only process in "active" object space.
	 */
	ex$get_cur_mod(	osnum = &osnum );
	if( osnum != OM_Gw_current_OS )	return OM_S_SUCCESS ;

	prod = EX_runname;
	if( ! ( ex$is_batch() )){
	  GRregister_switch_prod_callback( VDaddToPcktMenu );
	  if ( ! (    strcmp ( prod, VD_PROD_NAME_VDS )
                     && strcmp ( prod, VD_PROD_NAME_ROUTE )
                     && strcmp ( prod, VD_PROD_NAME_STRUCT )
                     && strcmp ( prod, VD_PROD_NAME_LOFT )   ) )
        	{  	
		   sts = SMAddToPocketMenu();
		   if ( !(sts&1) )
		   {
		     printf("%s[%d] : SMAddToPocketMenu ERROR\n",
							__FILE__, __LINE__);
		     return OM_W_ABORT;
		   }
		}
        }

	VDdrw_load_Structure( &sts );

	End ;
	return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/

end implementation VDsuper;
