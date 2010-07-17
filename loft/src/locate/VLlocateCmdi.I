class implementation VLlocateCmd;

/* -----------------------------------------------------------------------------
     CLASS NAME : VLlocateCmd

     ABSTRACT   : I/LOFT locate superclass

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This defines the surclass VLlocateCmd of the classes created
		  by the COB command objects of I/LOFT.
		  The instance data and methods defined in this file are shared
		  by all the COB command objects of I/LOFT.


     CHANGE HISTORY : file created 	15-SEP-1992	Marc Fournier
		      file modified	01-DEC-1992	Marc Fournier
		      file modified	25-FEB-1993	Marc Fournier
		      file modified	17-MAR-1993	Marc Fournier
		      file modified	08-JUN-1993	Marc Fournier
		      file upgraded	14-APR-1994	Marc Fournier
		      file modified	09-JUN-1994	Marc Fournier
		      file modified	20-JUN-1994	Marc Fournier
		      file modified	14-SEP-1994	Marc Fournier
----------------------------------------------------------------------------- */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"madef.h"
#include	"AS_status.h"
#include 	"exmacros.h"
#include 	"msmacros.h"
#include 	"msdef.h"
#include 	"asmacros.h"
#include 	"dpmacros.h"
#include 	"lcmacros.h"
#include 	"grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "ACattrib.h"

#include	"vsmiscmacros.h"
#include	"vscmddef.h"
#include	"vscmd.h"
#include	"vsioproto.h"
#include	"vsdef.h"

#include	"vlmsg.h"
#include	"vlglobals.h"

extern	IGRint	ems_do_print_error_messages;
extern	void	GRstatus_display_button();

%safe
static	IGRchar	curPATH[MAXPATHLEN + 1]	= ".",
		curNAME[FILENAME_MAX+1]	= "",
		curRGXP[VS_K_MAX_RGXP]	= "*";
%endsafe

from	ACrg_collect	import	AClist_attribute, ACset_list_attribute;

/*	#define	TRACE	*/

/* -------------------------------------------------------------------------- */
method init ( int type ; char * str_ptr )
{
	IGRint	status = OM_S_SUCCESS;
	IGRlong	sts, size, ret;

	status = om$send ( msg = message VLlocateCmd.init ( type, str_ptr),
                           mode = OM_e_wrt_parent,
                           targetid = my_id );
        as$status (sts = status);

	/* Retrieve current module info */
        size  = sizeof(struct GRmd_env);
        gr$get_module_env ( msg    = &sts,
                            sizbuf = &size,
                            buffer = &me->Current,
                            nret   = &ret );

	/* Initialize data arrays */
	me->Cnt1 =  0;		me->Lst1 = NULL;
	me->Cnt2 =  0;		me->Lst2 = NULL;
	me->Cnt3 =  0;		me->Lst3 = NULL;

	/* Retrieve ACrg_collection of globals */
	status = om$send ( msg = message VLlocateCmd.VLupdGlobals (&sts),
			   targetid = my_id );
        as$status (sts = status);

	/* Allow EFmsgReport() to work if VERBOSE_WARNING is set to 1 */
	ems_do_print_error_messages = 1;

	/* Set default file form mode to write */
	me->FileMode = 2;

	/* Fill file form I/STRUCT structure */
	me->Rfile.curPATH    = curPATH;
	me->Rfile.curNAME    = curNAME;
	me->Rfile.curRGXP    = curRGXP;
	me->Rfile.callBack   = NULL;
	me->Rfile.parentForm = NULL;
	strcpy ( me->Rfile.openMode, "r" );

	me->Wfile.curPATH    = curPATH;
	me->Wfile.curNAME    = curNAME;
	me->Wfile.curRGXP    = curRGXP;
	me->Wfile.callBack   = NULL;
	me->Wfile.parentForm = NULL;
	strcpy ( me->Wfile.openMode, "w" );

	me->Afile.curPATH    = curPATH;
	me->Afile.curNAME    = curNAME;
	me->Afile.curRGXP    = curRGXP;
	me->Afile.callBack   = NULL;
	me->Afile.parentForm = NULL;
	strcpy ( me->Afile.openMode, "a" );

	me->StatusDisplay = FALSE;

	me->VStype = 0;
	me->VLtype = 0;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method sleep ( int pos )
{
	IGRint	status = OM_S_SUCCESS;

	/* Execute method sleep of VLlocateCmd */
	status = om$send ( msg = message VLlocateCmd.sleep (pos),
			   mode = OM_e_wrt_parent,
			   targetid = my_id );
	as$status (sts = status);

	if( me->fileForm ) FIf_erase(me->fileForm );

	/* Management of stacked commands */
	me->Stacked = TRUE;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method wakeup ( int pos )
{
	IGRint	status = OM_S_SUCCESS;

	/* Execute method wakeup of VLlocateCmd */
	status = om$send ( msg = message VLlocateCmd.wakeup (pos),
                           mode = OM_e_wrt_parent,
                           targetid = my_id );
        as$status (sts = status);

	/* Set icone status off */
	GRstatus_display_button ((IGRint) me->StatusDisplay);

	if( me->fileForm ) FIf_display(me->fileForm );

	/* Management of stacked commands */
	me->Stacked = FALSE;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method delete ( int f_defer_flag )
{
	IGRint	status = OM_S_SUCCESS;
        IGRlong	sts;

        /* Execute method delete of VLlocateCmd */
        status = om$send ( msg = message VLlocateCmd.delete (f_defer_flag),
                           mode = OM_e_wrt_parent,
                           targetid = my_id );
        as$status (sts = status);

        /* Erase highlight plane */
        dp$erase_hilite (msg = &sts);

	/* Deallocate memory on wild exit */
	if (me->Lst1) {	om$dealloc(ptr = me->Lst1); me->Lst1=NULL; me->Cnt1=0; }
	if (me->Lst2) {	om$dealloc(ptr = me->Lst2); me->Lst2=NULL; me->Cnt2=0; }
	if (me->Lst3) {	om$dealloc(ptr = me->Lst3); me->Lst3=NULL; me->Cnt3=0; }
	
	if( me->fileForm ) 
	{
		FIf_delete(me->fileForm );
		me->fileForm = NULL;
	}

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLloadCst ( long * sts )
{

	/* Initialize construct list*/
	me->cst.msg		= sts;
	me->cst.env_info	= &me->Current;
	me->cst.newflag		= FALSE;
	me->cst.level		= me->ActiveLevel;
	me->cst.properties	= GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
	me->cst.display		= &me->ActiveDisplay;
	me->cst.class_attr	= NULL;
	me->cst.name		= NULL;

        *sts    = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLstoreResponse ( long * sts )
{

	me->Response = me->event1.response;
        *sts = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLstoreLocate ( long * sts )
{
        me->VLwindow.osnum    = me->event1.event.button.osnum;
        me->VLwindow.objid    = me->event1.event.button.objid;
        me->AcceptPoint[0]  = me->event1.event.button.x;
        me->AcceptPoint[1]  = me->event1.event.button.y;
        me->AcceptPoint[2]  = me->event1.event.button.z;
        me->Loc_env.obj_id  = me->event1.located_object[0].located_obj;
        me->Loc_env.mod_env = me->event1.located_object[0].module_info;
        *sts = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLfreeList ( IGRlong * sts ; IGRint flag )
{

        *sts = OM_S_SUCCESS;

#ifdef TRACE
printf( "\t>> VLfreeList (%d)\n", flag);
#endif

	switch (flag) {
		case 1:
			if (me->Lst1) {	om$dealloc (ptr = me->Lst1);
					me->Lst1 = NULL;	}
			me->Cnt1 = 0;
			break;
		case 2:
			if (me->Lst2) {	om$dealloc (ptr = me->Lst2);
					me->Lst2 = NULL;	}
			me->Cnt2 = 0;
			break;
		case 3:
			if (me->Lst3) { om$dealloc (ptr = me->Lst3);
					me->Lst3 = NULL;	}
			me->Cnt3 = 0;
			break;
		default:
			printf ("False value %d\n", flag);
			*sts = MSFAIL;
	}

#ifdef TRACE
printf( "\t<< VLfreeList (%d)\n", flag);
#endif

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLstoreList ( IGRlong * sts ; IGRint make_indx ; IGRint flag )
{

		IGRint		count, size=sizeof(struct GRobj_env);
	struct	GRobj_env	*list;
		IGRint		i;
	struct	GRid		Source;
		VSfenceArgs	args;

	/* Initialize */
        *sts    = OM_S_SUCCESS;
	list = NULL;

	/* Build located objects list */
	switch (me->Response) {

		case EX_DATA :
			count   = 1;
			list    = (struct GRobj_env *) om$malloc (size = size);
			list[0] = me->Loc_env;
			break;

		case EX_OBJID :
			if (me->VStype) {
				dp$erase_hilite (msg = sts);
				args.value = (IGRlong) me->VStype;
				vs$process_fence (
					   msg		 = sts,
			   		   fence	 = &me->Loc_env,
			   		   classList     = me->locate_eligible,
					   filter	 = VLfeaturePF,
					   args		 = &args,
			   		   p_count	 = &count,
			   		   p_content	 = &list,
			   		   response      = me->response,
			   		   response_data = me->response_data );
			}
			else if (me->VLtype == 1) {
				dp$erase_hilite (msg = sts);
				args.value = me->VLtype;
				vs$process_fence (
					   msg		 = sts,
			   		   fence	 = &me->Loc_env,
			   		   classList     = me->locate_eligible,
					   filter	 = VLisSurfacePlanarPF,
					   args		 = &args,
			   		   p_count	 = &count,
			   		   p_content	 = &list,
			   		   response      = me->response,
			   		   response_data = me->response_data );
			}
			else	vs$process_fence (
					   msg		 = sts,
			   		   fence	 = &me->Loc_env,
			   		   classList     = me->locate_eligible,
			   		   p_count	 = &count,
			   		   p_content	 = &list,
			   		   response      = me->response,
			   		   response_data = me->response_data );
			break;

		default :
			printf( "Unknown response <%d>\n", me->Response);
			goto quit;
	}

	/* Make objects sources (if wanted) */
	if (make_indx) {
		for ( i=0; i<count; i++) {
			as$make_source ( go_grid = list[i].obj_id,
					 mod_env = &list[i].mod_env,
					 as_os   = me->Current.md_id.osnum,
					 as_grid = &Source );
			list[i].obj_id  = Source;
			list[i].mod_env = me->Current;
		}
	}

	/* Allocate memory and load data in instance arrays */
	if (count > 0) {
		switch (flag) {
			case 1:
				me->Cnt1 = count;
				me->Lst1 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt1)*size);
				for (i=0;i<me->Cnt1;i++) me->Lst1[i] = list[i];
				break;
			case 2:
				me->Cnt2 = count;
				me->Lst2 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt2)*size);
				for (i=0;i<me->Cnt2;i++) me->Lst2[i] = list[i];
				break;
			case 3:
				me->Cnt3 = count;
				me->Lst3 = (struct GRobj_env *) om$malloc
					   (size = (me->Cnt3)*size);
				for (i=0;i<me->Cnt3;i++) me->Lst3[i] = list[i];
				break;
			default:
				printf ("False value %d\n", flag);
				*sts = MSFAIL;
		}
	}

quit:
	if (list)	{ om$dealloc (ptr = list); list = NULL; }

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLstoreCoorSyst ( long * sts )
{

        me->GrdCsys = me->Loc_env;
        *sts = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */
method fileFormDismissed( int dismissType ) {

        switch( dismissType ) {
                case VS_K_FILE_ACCEPTED : break ;
                case VS_K_FILE_CANCELED : 
        	   switch (me->FileMode) {
                	case 1: me->Rfile.pathName[0] = '\0' ;
                        	break;
                	case 2: me->Wfile.pathName[0] = '\0' ;
                        	break;
                	case 3: me->Afile.pathName[0] = '\0' ;
                        	break;
                	default:
                                printf( "Unknown file mode : <%d>\n",
                                        me->FileMode);
		   }
        }
        me->fileForm = NULL ;
        return OM_S_SUCCESS ;

} /* method fileFormDismissed */

/* -------------------------------------------------------------------------- */
method VLcreateFileForm ( long * sts )
{

	*sts = VL_S_SUCCESS;

	switch (me->FileMode) {
		case 1:	
			if( !me->fileForm ) {
				me->fileForm =
					VScreateFileForm ( 0, 100, &me->Rfile);
				*sts = me->fileForm ? MSSUCC : MSFAIL ;
				}
				break;
		case 2:	
                        if( !me->fileForm ) {
				me->fileForm =
                                	VScreateFileForm ( 0, 100, &me->Wfile);
				*sts = me->fileForm ? MSSUCC : MSFAIL ;
				}
                                break;
		case 3:	
                        if( !me->fileForm ) {
                                me->fileForm =
					VScreateFileForm ( 0, 100, &me->Afile);
				*sts = me->fileForm ? MSSUCC : MSFAIL ;
				}
                                break;

		default:	*sts = VL_E_FAILURE;
				printf( "Unknown file mode : <%d>\n",
					me->FileMode);
	}

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLtoggleCommand ( long * sts )
{

	/* I_STRUCT already do that */
	VStoggleCommand ( my_id, OM_Gw_current_OS);

  return OM_S_SUCCESS;
}

method VLwriteGlobalsInASCII ( long * sts )
{
		IGRint		status = OM_S_SUCCESS;
		IGRint		num, i;
	struct	ACrg_coll	glob[GLOBAL_G_NUMBER];
		FILE		*p_file;

	p_file = NULL;

	status = om$send ( msg = message ACrg_collect.AClist_attribute
                                        ( sts, GLOBAL_G_NUMBER, glob, &num),
                           targetid = me->Globals.objid,
                           targetos = me->Globals.osnum );
        as$status ( test   = (!(status & 1 & (*sts))),
                    msg    = "ACrg_collect.AClist_attribute",
                    action = GOTO_VALUE,
                    value  = quit );

        p_file = fopen ( me->Wfile.pathName, me->Wfile.openMode );
        if (!p_file) {
                printf( "Cannot open file <%s> in mode <%s>\n",
                         me->Wfile.pathName, me->Wfile.openMode );
                goto quit;
        }

        for ( i=0; i<num; i++) {
                if (glob[i].desc.type == AC_ATTRIB_DOUBLE)
                        fprintf( p_file, "%s\t%g\t%d\n",
                                 glob[i].name,
                                 glob[i].desc.value.att_exp,
                                 glob[i].desc.type );
                else    fprintf( p_file, "%s\t%s\t%d\n",
                                 glob[i].name,
                                 glob[i].desc.value.att_txt,
                                 glob[i].desc.type );
        }

        fflush (p_file);
        fclose (p_file);
quit:
  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLreadGlobalsFromASCII ( long * sts )
{
		IGRint		status = OM_S_SUCCESS;
		IGRint		i=0;
	struct	ACrg_coll	glob[GLOBAL_G_NUMBER];
		FILE		*p_file;
		IGRchar		str[81];

	p_file = NULL;

	p_file = fopen ( me->Rfile.pathName, me->Rfile.openMode );
        if (!p_file) {
                printf( "Cannot open file <%s> in mode <%s>\n",
                         me->Rfile.pathName, me->Rfile.openMode );
                goto quit;
        }

        while ( fgets ( str, 80, p_file) != NULL) {
                VLreadGlobals ( str, &glob[i]);
                i++;
        }

        fflush (p_file);
        fclose (p_file);

        status = om$send ( msg = message ACrg_collect.ACset_list_attribute
                                                ( sts, i, glob),
                           targetid = me->Globals.objid,
                           targetos = me->Globals.osnum );
        as$status ( test   = (!(status & 1 & (*sts))),
                    msg    = "ACrg_collect.ACset_list_attribute",
                    action = GOTO_VALUE,
                    value  = quit );
quit:
  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLplateActionHandlerOn ( long * sts )
{
	*sts = OM_S_SUCCESS;

	me->VStype         = VS_m_PLATE;
	me->action_args    = (IGRchar *) &me->VStype;
	me->action_handler = (IGRchar (*)()) VLfeatureAH;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLbeamActionHandlerOn ( long * sts )
{
	*sts = OM_S_SUCCESS;

	me->VStype         = VS_m_BEAM;
	me->action_args    = (IGRchar *) &me->VStype;
	me->action_handler = (IGRchar (*)()) VLfeatureAH;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLstructActionHandlerOff ( long * sts )
{
	*sts = OM_S_SUCCESS;

	me->VStype         = 0;
	me->action_args    = NULL;
	me->action_handler = NULL;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLisSurfacePlanarAHon ( long * sts )
{
	*sts = OM_S_SUCCESS;
	
	me->VLtype	   = 1;
	me->action_args    = (IGRchar *) &me->Current;
	me->action_handler = (IGRchar (*)()) VLisSurfacePlanarAH;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
method VLisSurfacePlanarAHof ( long * sts )
{
	*sts = OM_S_SUCCESS;
	
	me->VLtype	   = 0;
	me->action_args    = NULL;
	me->action_handler = NULL;

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

end implementation VLlocateCmd;
