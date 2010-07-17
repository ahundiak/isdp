/* $Id: VRiniti.I,v 1.10 2002/04/02 20:19:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinit/VRiniti.I
 *
 * Description:
 *	ROUTE startup command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRiniti.I,v $
 *	Revision 1.10  2002/04/02 20:19:27  anand
 *	Replaced #ifndef ISDP_MAKE_SP with #if !ISDP_MAKE_SP
 *	
 *	Revision 1.9  2002/04/02 17:22:19  anand
 *	SP -> Pload changes.
 *	
 *	Revision 1.8  2001/09/21 22:09:17  anand
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/09/21 20:42:32  anand
 *	Check if cache objs are present, if so delete them. Do this
 *	before constructing the cache objects!
 *	
 *	Revision 1.6  2001/09/21 17:26:09  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/09/19 16:25:49  anand
 *	Commented out MY_DEBG
 *	
 *	Revision 1.4  2001/09/19 15:28:15  anand
 *	TR 5586 - Recreate Cache objects at start up.
 *	
 *	Revision 1.3  2001/09/18 19:10:38  anand
 *	JTS TR MP5586 - Caching of hvac_material_list table to
 *	include caching of cage, mino and descr fields as well.
 *	
 *	Revision 1.2  2001/02/20 01:14:26  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/08/26  14:36:56  pinnacle
# Replaced: vrinit/VRiniti.I for:  by lawaddel for route
#
# Revision 1.3  1999/04/30  18:36:12  pinnacle
# Replaced: vrinit/VRiniti.I for:  by apazhani for route
#
# Revision 1.2  1998/11/08  14:48:14  pinnacle
# ah
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/01/12  16:57:22  pinnacle
# Replaced: vrinit/VRiniti.I for:  by apazhani for route
#
# Revision 1.4  1997/11/03  21:41:54  pinnacle
# Replaced: vrinit/VRiniti.I for:  by impd for route
#
# Revision 1.3  1997/10/31  21:25:56  pinnacle
# Replaced: vrinit/VRiniti.I for:  by impd for route
#
# Revision 1.2  1997/08/15  20:10:10  pinnacle
# Replaced: vrinit/VRiniti.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/24  15:29:48  pinnacle
# Replaced: vrinit/VRiniti.I for:  by hverstee for route240
#
# Revision 1.5  1996/04/16  18:58:24  pinnacle
# Replaced: vrinit/VRiniti.I for:  by ashankar for route240
#
# Revision 1.4  1996/04/01  19:40:00  pinnacle
# Replaced: vrinit/VRiniti.I for:  by msmanem for route240
#
# Revision 1.3  1996/01/17  00:06:44  pinnacle
# Replaced: vrinit/VRiniti.I for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:32:16  pinnacle
# Replaced: vrinit/VRiniti.I for:  by r240_int for route240
#
# Revision 1.1  1995/12/06  23:25:52  pinnacle
# Created: vrinit/VRiniti.I by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb 	created to replace VRinit.sl
 *				method Routeexecute renamed execute
 *	12/07/95	tlb	Add missing TERMINATE response
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      11/08/98        ah      Add call to ppl
 *      04/30/99        Alwin   Cleaning up the TagManager object.
 *      08/26/99        law     TR179900813-Restructured special processing
 *				for inputting new object space file.
 *      09/18/01	Anand	Construct Cache objects after dynloading SP.
 *************************************************************************/

class implementation VRinit;

#include "ex.h"
#include "exproto.h"
#include "expression.h"
#include "expmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdp.h"
#include "VRcompdef.h"
#include "VRDbParamDef.h"
#include "VRdef.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepmacros.h"
#include "VRPid.h"
#include "vdprdmacros.h"
#include "vrinit_pto.h"
#include "vrdbgmacros.h"

#include "VDtypedef.h"
#include "VDppl1.h"

#if !ISDP_MAKE_SP
#define  VRPDB_EXTERN_DEF
#define  VRHDB_EXTERN_DEF
#define  VRRDB_EXTERN_DEF
#endif

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"

#undef   VRPDB_EXTERN_DEF
#undef   VRHDB_EXTERN_DEF
#undef   VRRDB_EXTERN_DEF

/* Include Cable stuff */
#if !ISDP_MAKE_SP
#define VC_DEFINE_AN_GLOBALS
#endif

#include "VCdefine.h"
#include "VCparameters.h"
#include "VCDBpar.h"
#include "VCstructs.h"
#include "VCdbstructs.h"
#include "VCdbaccess.h"
#include "VCproto.h"
#include "VCchansel.h"
#include "VCMacLib.h"
#include "VCsys.h"

#undef VC_DEFINE_AN_GLOBALS


#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG	1
 */

/* Import Cable stuff */
from NDnode             import  NDchg_state;

from ACrg_collect       import  ACcreate;
from ACrg_collect       import  ACset_list_attribute;
from ACrg_collect       import  GRchgname;

extern  GRclassid       OPP_ACrg_collect_class_id;

extern GRclassid   OPP_VRPDB_class_id;
extern GRclassid   OPP_VRHDB_class_id;
extern GRclassid   OPP_VRRDB_class_id;

/**********************************************************/

method init( int type ; char *s ) {

        me->mytype = type ;
        return OM_S_SUCCESS ;

} /* method init */

/*----------------------------------------------------------------------------*/

int VRCnstrctCacheObj( IGRlong *retmsg )
{
    IGRint     status;
    IGRlong    msg;
    GRclassid  ClassId;
    extern GRclassid	OPP_VRPDB_class_id,
    			OPP_VRHDB_class_id,
			OPP_VRRDB_class_id;

    SetProc( VRCnstrctCacheObj ); Begin


    /* Destroy (if already present), construct, and initialise Piping Cache */
    status = om$get_classid( objid = VRPDB_id.objid,
			     osnum = VRPDB_id.osnum,
			     p_classid = &ClassId );

    if( status == OM_S_SUCCESS &&
	om$is_ancestry_valid( subclassid = ClassId,
			      superclassid = OPP_VRPDB_class_id )
				== OM_S_SUCCESS )
    {
	VR$PDB_INIT (p_msg = &msg);
	status = om$send(msg      = message Root.delete(0),
			senderid = NULL_OBJID,
                        targetid = VRPDB_id.objid,
                        targetos = VRPDB_id.osnum );
    }

    VRPDB_id.objid = NULL_OBJID;
    VRPDB_id.osnum = OM_Gw_TransOSnum_0;

    status =
    om$construct ( classid = OPP_VRPDB_class_id,
		   p_objid = &(VRPDB_id.objid),
		   osnum   = VRPDB_id.osnum,
		   msg     = message VRPDB.PDB_init (retmsg));



    /* Destroy (if already present), construct, and initialise HVAC Cache */
    status = om$get_classid( objid = VRHDB_id.objid,
			     osnum = VRHDB_id.osnum,
			     p_classid = &ClassId );

    if( status == OM_S_SUCCESS &&
	om$is_ancestry_valid( subclassid = ClassId,
			      superclassid = OPP_VRHDB_class_id )
				== OM_S_SUCCESS )
    {
	VR$HDB_INIT (p_msg = &msg);
	status = om$send(msg      = message Root.delete(0),
			senderid = NULL_OBJID,
                        targetid = VRHDB_id.objid,
                        targetos = VRHDB_id.osnum );
    }

    VRHDB_id.objid = NULL_OBJID;
    VRHDB_id.osnum = OM_Gw_TransOSnum_0;

    status =
    om$construct ( classid = OPP_VRHDB_class_id,
		   p_objid = &(VRHDB_id.objid),
		   osnum   = VRHDB_id.osnum,
		   msg     = message VRHDB.HDB_init (retmsg));


    /* Destroy (if already present), construct, and initialise Raceway Cache */
    status = om$get_classid( objid = VRRDB_id.objid,
			     osnum = VRRDB_id.osnum,
			     p_classid = &ClassId );

    if( status == OM_S_SUCCESS &&
	om$is_ancestry_valid( subclassid = ClassId,
			      superclassid = OPP_VRRDB_class_id )
				== OM_S_SUCCESS )
    {
	VR$RDB_INIT (p_msg = &msg);
	status = om$send(msg      = message Root.delete(0),
			senderid = NULL_OBJID,
                        targetid = VRRDB_id.objid,
                        targetos = VRRDB_id.osnum );
    }

    VRRDB_id.objid = NULL_OBJID;
    VRRDB_id.osnum = OM_Gw_TransOSnum_0;

    status =
    om$construct ( classid = OPP_VRRDB_class_id,
		   p_objid = &(VRRDB_id.objid),
		   osnum   = VRRDB_id.osnum,
		   msg     = message VRRDB.RDB_init (retmsg));

#ifdef MY_DEBUG
    printf ("CREATED VRPDB <%d %d>\n",VRPDB_id.objid, VRPDB_id.osnum);
    printf ("CREATED VRHDB <%d %d>\n",VRHDB_id.objid, VRHDB_id.osnum);
    printf ("CREATED VRRDB <%d %d>\n",VRRDB_id.objid, VRRDB_id.osnum);
#endif

    End
    return status;
}

method execute( int *response ; char *response_data ; int pos )
{
    IGRint	status = OM_S_SUCCESS;
    char 	ErrBuf[100];
    IGRlong	retmsg;

    SetProc(VRinit_execute); Begin 

    if ( me->mytype == 1 )
    {
	IGRlong			size_of_env,num_ret;
	struct GRmd_env		md_env;

	TGRid   pplID;
	IGRint  pplRET;
	IGRchar pplProduct[16];

	// Inform the ppl about to start
	strcpy(pplProduct,"route");
	vdppl$Load(pplID = &pplID, name = "VDstartup.u");
	vdppl$SetData(pplID = &pplID, 
		      name  = "PRODUCT", 
		      size  = 16, 
		      data  = pplProduct);

	vdppl$Run(pplID = &pplID, name = "startup1", ret = &pplRET);

	/*| Initialize associativity */

	ASsuper_construct() ;
/* Cable library is now included into VRfeatures.mc */

	/*| mount the object space containing the components macros definition */

	if( !( 	ac$construct_path(	mode	= AC_ADD_PATH | AC_INQ,
					name	= "VRfeatures.mc") & 1 ) ) 
	{
		int msglng;
		sprintf(	ErrBuf,
				"Cannot retrieve macro library: %s",
				"VRfeatures.mc" ) ;
		/* Error_box( 0, ErrBuf, 2 ) ; */
		msglng = strlen(ErrBuf) ;
 
                FI_message_box (    FI_CURRENT_SCREEN, -1, -1, "Error", FI_BLACK , "swiss742b", 25.0, ErrBuf, FI_BLACK, "swiss742b", 18.0, FI_FITTED, msglng );
	}

	/*| Create directories for the components' cache storage */

	size_of_env = sizeof(struct  GRmd_env);
	status = 
	gr$get_module_env( 	msg 	= &retmsg,
				sizbuf	= &size_of_env,
				buffer	= &md_env,
				nret 	= &num_ret);
	as$status(action = RET_STATUS);

	status =
	di$mkdir(	dirname = VR_MISC_DIR,
			osnum   = md_env.md_id.osnum ) ;
	if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
		printf ("UNABLE TO BUILD %s directory !!!\n",VR_MISC_DIR);

	status =
	di$mkdir(	dirname = VR_EQUIP_DIR,
			osnum   = md_env.md_id.osnum ) ;
	if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
		printf ("UNABLE TO BUILD %s directory !!!\n",VR_MISC_DIR);

	status =
	di$mkdir(	dirname = VR_PIPING_DIR,
			osnum   = md_env.md_id.osnum ) ;
	if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
		printf ("UNABLE TO BUILD %s directory !!!\n",VR_PIPING_DIR);

	status =
	di$mkdir(	dirname = VR_HVAC_DIR,
			osnum   = md_env.md_id.osnum ) ;
	if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
		printf ("UNABLE TO BUILD %s directory !!!\n",VR_HVAC_DIR);

	status =
	di$mkdir(	dirname = VR_RWAY_DIR,
			osnum   = md_env.md_id.osnum ) ;
	if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
		printf ("UNABLE TO BUILD %s directory !!!\n",VR_RWAY_DIR);

	/* -- Add representation to VDS -- */

	ac$add_representation ( name  = VR_N_PID_REP,
				value = VR_V_PID_REP );

	/* -- Add Trace to pocket menu -- */
	if ( !ex$is_batch() )
	{
	    VRAddToPocketMenu();
	}

/* Initialize Cable stuff */
  {
    IGRlong            retmsg;
    IGRlong            size_of_env;
    IGRlong            num_ret;
    IGRchar            szPathName[DI_PATH_MAX];
    IGRchar            szPathColl[DI_PATH_MAX];
    IGRchar            szBasePath[DI_PATH_MAX];

    struct GRid        dirobj;
    struct GRid        collobj;

    /*  Initialize channel selectors     */

    status =
    om$make_chanselect (channame     = VC_CHAN_FATHER,
                        p_chanselect = &VC_GLB_father);

    status =
    om$make_chanselect (channame     = VC_CHAN_CHILDREN,
                        p_chanselect = &VC_GLB_children);

    status =
    om$make_chanselect (channame     = VC_CHAN_OWNER,
                        p_chanselect = &VC_GLB_to_owner);

    status =
    om$make_chanselect (channame     = VC_CHAN_COMPS,
                        p_chanselect = &VC_GLB_to_comp);

    status =
    om$make_chanselect (channame     = VC_CHAN_LISTEN,
                        p_chanselect = &VC_GLB_listeners);

    status =
    om$make_chanselect (channame     = VC_CHAN_NOTIF,
                        p_chanselect = &VC_GLB_notification);

    /*   initialize analysis globals     */

    VC_INITSTR (VCANGLB_filenam);
    VC_INITSTR (VCANGLB_result);

    VCANGLB_select     = 0;
    VCANGLB_ntrace     = 0;
    VCANGLB_trac       = NULL;

    /*   initialize system globals       */

    VCSYSGLB_preserve = TRUE;
    VCSYSGLB_dyncpt   = TRUE;
    VCSYSGLB_offset   = TRUE;
    VC_INITSTR (VCSYSGLB_brkchr);

    /*| Create directories for the components' cache storage */

    size_of_env = sizeof(struct  GRmd_env);

    status = 
    gr$get_module_env(   msg   = &retmsg,
                       sizbuf  = &size_of_env,
                       buffer  = &VCANGLB_mdenv,
                       nret    = &num_ret);
    as$status(action = RET_STATUS);

    VC_GLB_writable_os = VCANGLB_mdenv.md_id.osnum;

    /*    add cabling directories    */
    /*    (NOTE)   DB cache directories are added when needed    */

    /*    just add default attribute collections                 */

    status =
    di$give_pathname (osnum = VC_GLB_writable_os, pathname = szPathName );
    as$status();

    strcpy (szBasePath, szPathName);

    strcat (szPathName, ":" );
    strcat (szPathName, VC_DIR_ATT);

    status = di$translate ( objname = szPathName,
                            osnum   = VC_GLB_writable_os,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
      status = di$mkdir (dirname = szPathName,
                         osnum   = VC_GLB_writable_os,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );

      if ( status != DIR_S_SUCCESS && status != DIR_E_DIR_DUP )
            printf ("UNABLE TO BUILD %s directory !!!\n",VC_DIR_ATT);
      as$status();
    }

    status = di$cd (dirname = szPathName,
                    osnum   = VC_GLB_writable_os);

    /*        create default collections                 */

    strcpy (szPathColl, szPathName);
    strcat (szPathColl, ":" );
    strcat (szPathColl, VC_DIR_SYS );
    
    status = di$translate ( objname = szPathColl,
                            osnum   = VC_GLB_writable_os,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   create default syscoll    */

      collobj.objid = NULL_OBJID;
      collobj.osnum = VC_GLB_writable_os;

      status =
      VC_setdefpar (&retmsg, VC_SYSATT, szPathColl, &collobj, &VCANGLB_mdenv);
      as$status();
    }

    strcpy (szPathColl, szPathName);
    strcat (szPathColl, ":" );
    strcat (szPathColl, VC_DIR_USER );

    status = di$translate ( objname = szPathColl,
                            osnum   = VC_GLB_writable_os,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   create default usrcoll    */

      collobj.objid = NULL_OBJID;
      collobj.osnum = VC_GLB_writable_os;

      status =
      VC_setdefpar (&retmsg, VC_USRATT, szPathColl, &collobj, &VCANGLB_mdenv);
      as$status();
    }

    /* The home directory of the ROUTE design file is ":filename:usr". Alwin */
    strcat( szBasePath, ":usr" );
    __DBGpr_str( " Home Directory ", szBasePath );
    status = di$cd (dirname = szBasePath,
                    osnum   = VC_GLB_writable_os);

    /*A Dyn load files (if any) in config/dload/ROUTE_DLOAD_DIR */

     /* vd$prd_load_corrections( run_name = VC_PROD_NAME );
*/

    /*  Initialize/close Database Cache    */

    status = VCDB_close (&retmsg);
  
  }/* end Active Init for Cable */

	/*A Dyn load files (if any) in config/dload/ROUTE_DLOAD_DIR */

	vd$prd_load_corrections( run_name = VD_PROD_NAME_ROUTE );
	
	/* Reset the Solver object */
	VRreset_solver();

	/* Clear the route DB cache   */
	VR_DbC_Clear();

	vdppl$Run(pplID = &pplID, name = "startup2", ret = &pplRET);

	vdppl$Delete(pplID = &pplID);
	
	/* To Delete the Tag Manager object. Earlier the tag number size was
	increased from 13 - 55. The old Tag Manager needs to be deleted and
	new one should be constructed with 55. This would be executed only once
	for a design file. Alwin */
	{
	   IGRboolean bModifiedComp = FALSE;
	   GRspacenum cur_os;
	   IGRchar file_name[DI_PATH_MAX], exp_name[DI_PATH_MAX]; 
	   IGRchar cur_dir[DI_PATH_MAX];
	   struct GRid tmp_obj;

	   cur_dir[0] = '\0';
	   status = di$pwd(dirname = cur_dir);

	   if( status != DIR_S_SUCCESS )
	   {
		 goto wrapup;
	   }

	   ex$get_cur_mod( id = &tmp_obj.objid, osnum = &cur_os );
	   status = di$give_pathname( osnum = cur_os, pathname = file_name );
	   if( status != DIR_S_SUCCESS )
	   {
		 goto wrapup;
	   }

	   strcat( file_name, ":IGENOD" );
	   sprintf( exp_name, "%s:DelOldTagManager", file_name );

	   status = di$cd(dirname = file_name);
	   if( status != DIR_S_SUCCESS ){
		 goto wrapup;
	   }

	   status = di$translate(        objname = exp_name,
					 osnum   = cur_os,
					 p_objid = &tmp_obj.objid);

	   if( status != DIR_S_SUCCESS )
	   {
		IGRlong size, ret_size;
		struct GRid TagId, ModId;

		ModId.osnum = md_env.md_id.osnum;
		__DBGpr_int( " Osnum ", ModId.osnum );

		TagId.osnum    = ModId.osnum;
		TagId.objid    = NULL_OBJID;

		status = ex$get_super (mod_id           = ModId.objid,
					mod_osnum       = ModId.osnum,
					super_name      = "TagManager",
					create          = FALSE,
					wakeup_flag     = FALSE,
					super_class     = "VCTagMgr",
					super_id        = &TagId.objid,
					super_osnum     = &TagId.osnum );
		__DBGpr_obj( " Tag Manager Object Id ", TagId );

		if( ( status & 1 ) && ( TagId.objid != NULL_OBJID ) )
		{
		    __DBGpr_com( " Deleting the Tag Manager object ... " );
		    status =
		    om$send(msg      = message Root.delete(0),
			    targetid = TagId.objid,
			    targetos = TagId.osnum );
		}

		/* After deleting the Old Tag Manager we need make sure that it 
		doesn't delete the New Tag Manager again. So we leave an 
		expression, to say that this particular file is alreay 
		processed */
		status =  exp$create(exp_name  = "DelOldTagManager",
				     osnum     = cur_os,
				     exp_value = 1.0,
				     p_exp_id  = &tmp_obj);
		if(!(status & 1))
		   printf("Can't create expression DelOldTagManager\n");

	   }
	   di$cd( dirname = cur_dir );
	}
	/* Deleting Tag Manager ends */
    }/* end Active Init ( mytype == 1 ) */

    /* Cache objects now implemented as separate function to enable override in
     * a service pack cycle. Also, been put AFTER the .so files have been
     * dyn-loaded.  - Anand for JTS TR MP5586 */

    if ( me->mytype == 1 || me->mytype == 0 ) 
    {
	status = VRCnstrctCacheObj( &retmsg );

    }

wrapup :

*response = TERMINATE;

End
return ( OM_S_SUCCESS );
}

/*       create default collections            */

IGRint  VC_setdefpar (IGRlong        *msg,
                      IGRint          itype,
                      IGRchar        *szName,
               struct GRid           *CollId,
               struct GRmd_env       *md_env)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       NbAttr;
  IGRint       i;

  struct ACrg_coll   TmpAttr[10];

  *msg = MSSUCC;

  status =
  om$construct ( classid = OPP_ACrg_collect_class_id,
                 p_objid = &(CollId->objid),
                 osnum   = CollId->osnum,
                 msg     = message ACrg_collect.ACcreate
                                              (&retmsg,szName ) ) ;

  if (itype == VC_SYSATT)
  {
    NbAttr = 7;

    /*     attribute names     */

    strcpy ( TmpAttr[0].name, VC_N_UNIT_AN);
    strcpy ( TmpAttr[1].name, VC_N_SYST_NAME_AN);
    strcpy ( TmpAttr[2].name, VC_N_APPRV_STAT_AN);
    strcpy ( TmpAttr[3].name, VC_N_CONSTR_STAT_AN);
    strcpy ( TmpAttr[4].name, VC_N_CHG_REQ_NUM_AN);
    strcpy ( TmpAttr[5].name, VC_N_COMP_NOTE_AN);
    strcpy ( TmpAttr[6].name, VC_N_ADD_LABEL_AN);

    for (i=0; i<NbAttr; i++)
      TmpAttr[i].desc.type = AC_ATTRIB_TEXT;

    /*      default values      */

    strcpy(TmpAttr[0].desc.value.att_txt,"Unit1");
    strcpy(TmpAttr[1].desc.value.att_txt,"Sys1");
    strcpy(TmpAttr[2].desc.value.att_txt,"N");
    strcpy(TmpAttr[3].desc.value.att_txt,"N");
    strcpy(TmpAttr[4].desc.value.att_txt,"Chg1");
    strcpy(TmpAttr[5].desc.value.att_txt,"Note:");
    strcpy(TmpAttr[6].desc.value.att_txt,"Additional");
  }
  else
  {
    NbAttr = 4;

    /*     attribute names     */

    strcpy ( TmpAttr[0].name, VC_N_CATEGORY_AN);
    strcpy ( TmpAttr[1].name, VC_N_GROUP_AN);
    strcpy ( TmpAttr[2].name, VC_N_COMPART_X_AN);
    strcpy ( TmpAttr[3].name, VC_N_DECK_X_AN);

    for (i=0; i<NbAttr; i++)
      TmpAttr[i].desc.type = AC_ATTRIB_TEXT;

    /*      default values      */

    strcpy(TmpAttr[0].desc.value.att_txt,"");
    strcpy(TmpAttr[1].desc.value.att_txt,"");
    strcpy(TmpAttr[2].desc.value.att_txt,"");
    strcpy(TmpAttr[3].desc.value.att_txt,"");
  }

  status =
  om$send( msg = message NDnode.NDchg_state(
                             ( (IGRchar)  ND_DEL_NO_CH ),
                             ( (IGRchar) ~ND_DEL_NO_CH ) ),
      senderid = NULL_OBJID,
      targetid = CollId->objid,
      targetos = CollId->osnum ) ;
  as$status ();

  status =
  om$send( msg = message ACrg_collect.GRchgname
                                       (&retmsg, md_env, szName),
      senderid = CollId->objid,
      targetid = CollId->objid,
      targetos = CollId->osnum ) ;

  status =
  om$send( msg = message ACrg_collect.ACset_list_attribute
                                       (&retmsg, NbAttr, TmpAttr),
      senderid = CollId->objid,
      targetid = CollId->objid,
      targetos = CollId->osnum ) ;

  return OM_S_SUCCESS;
}


end implementation VRinit;
