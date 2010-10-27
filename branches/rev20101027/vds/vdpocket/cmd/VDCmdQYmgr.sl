/* <<############# file header template ###########>> */

/* $Id: VDCmdQYmgr.sl,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* I/VDS
 *
 * File:	vdpocket/com/VDCmdQYmgr.sl
 *
 * Description:
 *
 *	This command object controls the interface between the 
 *	existing queries and the user to manipulate.
 *
 * Dependencies:
 *
 *	The command "Create Query" to define queries.
 *
 * Revision History:
 *	$Log: VDCmdQYmgr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
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
# Revision 1.8  1996/03/05  23:43:18  pinnacle
# Replaced: ./vdpocket/cmd/VDCmdQYmgr.sl for:  by azuurhou for vds.240
#
# Revision 1.6  1995/08/30  15:41:42  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYmgr.sl for:  by yzhu for vds.240
#
# Revision 1.5  1995/07/13  18:38:02  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYmgr.sl for:  by yzhu for vds.240
#
# Revision 1.3  1995/03/03  21:23:12  pinnacle
# Replace: vdpocket/cmd/VDCmdQYmgr.sl by yzhu for OPE
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
 *	08/23/94	adz		Creation Date.
 *	03/03/94	yzhu		Something modified.
 *	03/05/96	adz		Save identical file allowed.
 */

/*---------------------
 * class specification area
 */
command_string	VDC_M_QryLoad,0,VDQryLoad
synonym		VDC_M_QrySave,1,VDQrySave
synonym		VDC_M_QryDelt,2,VDQryDel
product_name	"$VDS"
class		VDCmdQYmgr
super_class	VDS_LOCATE
command_table	"vds.cmd"

form            "VDquery2",0,0,"-1","-1"

start_state	start

/*---------------------
 * specification area
 */
specification

/*
 * adz
 */

#include "growner.h"
#include "VDQYdef.h"


/*+v
  Abstract
	The following instance are used to control the
	management of the queries.

  Notes/Remarks

*/
instance {

	variable struct GRid	queries[0];	/* list of queries */
	GRname			qry_dir;
	struct	GRid		qry_dirId;	/* directory id */

	GRname			qry_File;	/* query ASCII file */
	variable struct Qry_list qry_sortlist[0];	/* list of queries */
      }
/*
-v*/

/*---------------------
 * implementation area
 */

implementation

#include	"OMmacros.h"
#include        "OMprimitives.h"         /* om$vla_set_dimension */ 

#include        "DItypedef.h"
#include        "DIdef.h"
#include        "DIglob.h"
#include        "DIprims.h"              /* DIprims.h */
#include        "DIomac.h"

#include	"FI.h"

#include	"AS_status.h"
#include	"vdqrydef.h"
#include	"VDQYdef.h"
#include	"vdsmacros.h"
#include	"VDmem.h"

#include	"v_dbgmacros.h"
#include	"VDmsg.h"
#include	"SMmsg.h"

/* #define		DEBUG		1 */

from		ACrg_collect	import	ACgive_structure;
from            ACrg_collect    import  NDdelete;
from		GRgraphics	import	GRgetname;
from		VDquery		import	VDname_query, VDgive_query;
from		VDquery		import	VDsetPfxInfo, VDgetPfxInfo;

extern IGRint my_strcmp();
/*
 * static include functions
 */
/* <<############# internal function template ###########>> */


/*---------------------
 * state table area
 */

state_table

#include	"VDmsg.h"
#include	"VDQYdef.h"

state start

	on CMD_TYPE = QRY_COB_LOAD
		do display_form 0
		do message_key	VD_M_QryLoad			state form_info
		
	on CMD_TYPE = QRY_COB_SAVE
		do display_form 0
		do message_key	VD_M_QrySave			state form_info
		
	on CMD_TYPE = QRY_COB_DELETE
		do display_form 0
		do message_key	VD_M_QryDel			state form_info


state	form_info

	prompt_key	VD_P_DgEntPmFm

	dynamics	off
	filter		wfi

	on EX_FORM_FINISHED					state terminate

/*---------------------
 * message area
 */

/* <<############# overridden message template ###########>> */
action	wakeup	
{
IGRlong			msg;
GRspacenum		cur_os;
struct	GRid		dirId;

        SetProc( VDCmdQYmgr.wakeup ); Begin
	status =
	om$send(msg = message VDS_LOCATE.wakeup(pos),
		targetid = my_id,
		mode = OM_e_wrt_message );
	as$status( action = RET_STATUS );
		
	status =
	ex$get_cur_mod(	osnum	= &cur_os );

	me->qry_dirId.objid = NULL_OBJID ;
	me->qry_dirId.osnum = cur_os ;
	
	me->qry_dir[0] = '\0';
	di$give_pathname( osnum = cur_os, pathname = me->qry_dir );

#ifdef	DEBUG
	printf(" pathname is %s\n", me->qry_dir );
#endif

	strcat( me->qry_dir, ":" );
	strcat( me->qry_dir, QRY_str_DIR_NAME );

	dirId.objid = NULL_OBJID;
	status = di$translate(	objname = me->qry_dir,
				p_objid = &dirId.objid,
				p_osnum = &dirId.osnum );
	if( !(status&1) || dirId.objid == NULL_OBJID ){
		dirId.objid = NULL_OBJID;
		status = di$mkdir(      dirname = me->qry_dir,
					p_dirid = &dirId.objid,
					p_osnum = &dirId.osnum );

		if( !(status&1 )||( dirId.objid == NULL_OBJID )){
			ex$message(	msgnumb = VD_S_CanCrea,
					type = "%s",
					var = `me->qry_dir` );
			return( OM_E_ABORT );
        	}
	}

	/*
	 * copy to instance.
	 */
	me->qry_dirId = dirId ;

	switch( me->mytype ){
	case	QRY_COB_LOAD:

		FIg_display( me->forms[0].form_ptr, QRY_SUB_FILE_TITLE );
		FIg_display( me->forms[0].form_ptr, QRY_SUB_FILE );

		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_DELETE_TITLE ); 
		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_SAVE_TITLE );
		FIg_display( me->forms[0].form_ptr, QRY_SUB_LOAD_TITLE ); 
		break;

	case	QRY_COB_SAVE:

		FIg_display( me->forms[0].form_ptr, QRY_SUB_FILE_TITLE );
		FIg_display( me->forms[0].form_ptr, QRY_SUB_FILE );

		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_DELETE_TITLE ); 
		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_LOAD_TITLE );
		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_PFX_TOGGLE );
		FIg_display( me->forms[0].form_ptr, QRY_SUB_SAVE_TITLE ); 
		break;

	case	QRY_COB_DELETE:

		FIg_erase( me->forms[0].form_ptr, QRY_SUB_FILE_TITLE );
		FIg_erase( me->forms[0].form_ptr, QRY_SUB_FILE );

		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_SAVE_TITLE ); 
		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_LOAD_TITLE );
		FIg_erase(   me->forms[0].form_ptr, QRY_SUB_PFX_TOGGLE );
		FIg_display( me->forms[0].form_ptr, QRY_SUB_DELETE_TITLE ); 
		break;

	default	:

		return( OM_E_ABORT );
	}

	me->qry_File[0] = '\0';

	if( me->mytype == QRY_COB_LOAD ){
		ex$message( msgnumb = VD_S_QryFlName );
	}
	else{
		ex$message( msgnumb = VD_S_QrySltLst );
	}

	status =
	om$send(msg = message VDCmdQYmgr.create_list( &msg ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	status =
	om$send(msg = message VDCmdQYmgr.display_list( &msg ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/*
	 * can not find the form.
	 */
	if ( ! me->forms[0].form_ptr ){
		ex$message(	msgnumb = SM_E_FrmNtFnd,
				type = "%s",
				var = `"VDquery2"` );
		return( OM_E_ABORT );
	}

        End
	goto quit ;
}

/* <<############# public message template ###########>> */

/* <<############# private message template ###########>> */

action	create_list
{
IGRint			i,
			ii,
			nb_queries;
GRname			classname,
			objname;
struct	GRid		*query_ids;

        SetProc( VDCmdQYmgr.create_list); Begin

	*sts = MSSUCC ;

	query_ids = NULL ;
	nb_queries = 0;

	status =
	om$vla_set_dimension(	varray	= me->queries,
				size	= 0 );

	if( me->qry_dirId.objid == NULL_OBJID ){
		goto wrapup;
	}

	sprintf( objname,"%s:*", me->qry_dir );

	status =
	di$dump(	regexp = objname,
			grids  = (DIgrid **)&query_ids,
			ptr    = &nb_queries );
	if( status != DIR_S_SUCCESS || nb_queries <= 0) goto wrapup;

	status =
	om$vla_set_dimension(	varray	= me->queries,
				size	= nb_queries );

	ii = 0;

	for( i=0 ; i<nb_queries ; i++ ){
		/*
		 * test object class .
		 */
		om$get_classname(	osnum	= query_ids[i].osnum,
					objid	= query_ids[i].objid,
	
			classname = classname );
		if( ! ( strcmp( classname, VD_QRY_Classname ) == 0 )){
			/*
			 * inproper class.
			 */
			continue;
		}

		me->queries[ii].objid = query_ids[i].objid ;
		me->queries[ii].osnum = query_ids[i].osnum ;
		ii++;
	}

	if( ii < nb_queries ){
		status =
		om$vla_set_dimension(	varray	= me->queries,
					size	= ii );
	}

wrapup:

	/*
	 * free allocated memory.
	 */
	_FREE( query_ids );

        End
	status = OM_S_SUCCESS;

	goto quit;
}  /* create_list */
/*------------------------------------------------------------------------*/
action	display_list
{

IGRint			nb_queries = 0;
GRname                  gvName,
			objName;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
IGRint                  rc,
			ii, i,
                        directIndex = 0;
IGRchar			*form_ptr;
IGRint                  num1,sortnum;
IGRchar                 **tmpqrylist;

        SetProc( VDCmdQYmgr.display_list); Begin

	if( ! me->forms[0].form_ptr ){
		goto wrapup;
	}

	form_ptr = me->forms[0].form_ptr ;

	/*
	 * display the filename that is available.
	 */
	gvName[0] = '\0';

	if( me->mytype == QRY_COB_LOAD ){

		/*
		 * read queries from the ASCII file.
		 */

			goto finish ;
	}

	/*
	 * clean up the existing list.
	 */
	VDqry_clr_display(	form_ptr, QRY_SUB_NAME );

	nb_queries = om$dimension_of(	varray	= me->queries );

        strcpy( gvName, VD_qry_nmName );

	if( nb_queries ){

                sortnum = 0;

		ii = 0;

		for( i=0 ; i<nb_queries ; i++ ){

			status = 
			om$send(msg = message ACrg_collect.ACgive_structure(
							&rc,          /* out */
                                                        &directIndex, /* int */ 
                                                        gvName,       /* in  */
                                                        &retStr,      /* out */
                                                        &mdEnv ),     /* out */
		                mode     = OM_e_wrt_message,
				targetid = me->queries[i].objid,
				targetos = me->queries[i].osnum );

		        if(! ( status & rc & 1 )){

				/*
				 * query does not have a name.
				 */

				objName[0] = '\0';
				status =
				om$send(msg = message GRgraphics.GRgetname(
							sts,
							objName ),
					targetid = me->queries[i].objid,
					targetos = me->queries[i].osnum );
				if( !( status & *sts & 1 )){
					/*
					 * do not treat object.
					 */
					continue;
				}
				status = 
				om$send(msg = message VDquery.VDname_query(
							sts,
							objName ),
					targetid = me->queries[i].objid,
					targetos = me->queries[i].osnum );
				if( !( status & *sts & 1 )){
					/*
					 * do not treat object.
					 */
					continue;
				}

				/*
				 * recall the object to get the name.Crg_collect
				 */
				status = 
				om$send(msg = message 
					ACrg_collect.ACgive_structure(
							&rc,
                                                        &directIndex,
                                                        gvName,
                                                        &retStr,
                                                        &mdEnv ),
			                mode     = OM_e_wrt_message,
					targetid = me->queries[i].objid,
					targetos = me->queries[i].osnum );
				if( !( status & rc & 1 )){
					/*
					 * do not treat object.
					 */
					goto wrapup;
				}

			} /* if  */

               	/* set up qry_sortlist as instance*/
                status =
                om$vla_set_dimension(   varray = me->qry_sortlist,
                                        size   = sortnum + 1 );
                as$status( action= RET_STATUS );

                me->qry_sortlist[sortnum].name[0] = '\0';
                strcpy( me->qry_sortlist[sortnum].name,
                        retStr.var.text_st.text_string);
                sortnum = sortnum + 1;
		
                } /* for */


       		/*
         	* put list into a tmp list in order to use qsort.
         	*/

        	num1 = 0;
        	num1 = om$dimension_of(   varray  = me->qry_sortlist );


        	tmpqrylist = NULL;
        	VDmalloc_str_list(&tmpqrylist, num1, Qrylistlen);

        	for( i=0 ; i<num1 ; i++ ){
           		tmpqrylist[i][0] = '\0';
           		strcpy(tmpqrylist[i], me->qry_sortlist[i].name);
        	}

        	qsort ( tmpqrylist, num1, sizeof ( char * ),
                	(int (*) ())my_strcmp);

                /*
         	* put shorted list into me->qry_sortlist
         	*/
        	for( i=0 ; i<num1 ; i++ ){
           		me->qry_sortlist[i].name[0] = '\0';
           		strcpy(me->qry_sortlist[i].name,tmpqrylist[i]);

#ifdef DEBUG
           printf(" me->qry_sortlist.name = %s\n",
                   me->qry_sortlist[sortnum].name);
#endif
        	}


		/*
		 * display the name in the form.
		 */
        	for( i=0 ; i<num1 ; i++ ){
#ifdef	DEBUG
			printf(" -- %s -- \n", 
				retStr.var.text_st.text_string );
#endif

			FIfld_set_default_text(
						form_ptr,
						QRY_SUB_NAME,
						i,
						0,
						me->qry_sortlist[i].name,
						FALSE);
		} /* for */

        	VDfree_str_list(tmpqrylist, num1);

	} /* if  */

finish:
	*sts = MSSUCC;
        End
	return OM_S_SUCCESS;

wrapup:
	*sts = MSFAIL;
	status = OM_E_ABORT ;
        End
	goto quit;
} /* display_list */
/*-------------------------------------------------------------------------*/

action	form_notification
{
IGRlong			msg;
IGRint			state,
			nbRows = 0,
			row = 0;
IGRchar			text[DI_PATH_MAX], my_msg[DI_PATH_MAX];
FILE			*filePtr;

        SetProc( VDCmdQYmgr.form_notification ); Begin
	my_msg[0] = '\0';

	filePtr = NULL;

#ifdef	DEBUG
	printf(" label %d, gadg %d\n", form_label, gadget_label );
#endif

	FIg_set_text( form_ptr, FI_MSG_FIELD, "" );

	switch ( gadget_label )
	{
	case FI_ACCEPT:

		status =
		om$send(msg = message VDCmdQYmgr.process( &msg ),
			targetid = my_id );
	        if( !(status & msg & 1 )){
			break;
		}
                FIf_erase( form_ptr );
                _put_response(  resp = EX_FORM_FINISHED );

                break;

	case FI_CANCEL:

		FIf_erase( form_ptr );
		_put_response(	resp = EX_FORM_FINISHED );

		break;

	case QRY_SUB_FILE:

		/*
		 * get the filename.
		 */
                text[0] = '\0';
		FIg_get_text(	form_ptr, gadget_label, text );

		filePtr = NULL;

		vd$openfile(	file_name       = text,
				product_name    = "Vds",
				sub_path        = "config/queries",
				cur_dir         = TRUE,
				p_file          = &filePtr );

		if( me->mytype == QRY_COB_LOAD ){

			if( filePtr == NULL ){
				sprintf(my_msg, 
					" File '%s' not found ", text );
				UI_status(my_msg );
                                FIg_set_text(form_ptr, 10, my_msg);    
                                break ;
       		 	}

			status =
			VDqry_load_names(	form_ptr,
						QRY_SUB_NAME,
						filePtr );

			if( status & 1 ) {
				strcpy( me->qry_File, text );
			}
		}
		else{
			/*
			 * looking for a new name for saving the 
			 * queries.
			 */
                        if(text[0] == '\0') {
                              	sprintf(my_msg,
                                " Please give file name" );
				UI_status(my_msg );
                               	FIg_set_text(form_ptr, 10, my_msg);
                        } 
		       else if( filePtr != NULL ){
				sprintf(my_msg, " File '%s' exist ", text );
				UI_status(my_msg );
                                FIg_set_text(form_ptr, 10, my_msg);    
      				strcpy( me->qry_File, text );
				/* TR179600852
                                 * FIg_set_text(form_ptr,  gadget_label, ""); 
				 */
			} 
                        else {  
      				strcpy( me->qry_File, text );
                        } 
		}

		if( filePtr ) fclose( filePtr );
		break;

	case QRY_SUB_NAME:

		/*
		 * let the interface acCept the select state of each
		 * row.
		 */
		break;

	case QRY_SUB_ALL_BUTTON:

	case QRY_SUB_CLR_BUTTON:

		nbRows = 0;
		FIfld_get_num_rows(	form_ptr,
					QRY_SUB_NAME,
					&nbRows );

		state = ( gadget_label == QRY_SUB_ALL_BUTTON ) ? TRUE : FALSE ;

		for( row=0 ; row<nbRows ; row++ ){
			FIfld_set_select(	form_ptr,
						QRY_SUB_NAME,
						row,
						0,
						state );
		}

		break;

        case QRY_SUB_PFX_TOGGLE:

                /*
                 * let the interface accept the select state of prefix ignor
                 * or load
                 */
                break;

	default:
		break;
	}
    End
} /* form_notification */
/*-------------------------------------------------------------------------*/

action	process
{
IGRint			state,
			selectFlag,
			i, j,
			found,
			rPos,
			nb_queries = 0,
			nbRows = 0;
IGRchar			*form_ptr;
IGRchar			*select = NULL,
			*where = NULL,
			*comment = NULL ;
GRname			text,
			my_msg;
FILE			*filePtr = NULL;
GRname                  gvName;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
IGRint                  rc,
                        directIndex = 0;
IGRint                  pfxIndex;
IGRchar                 pfxName[80];


        SetProc( VDCmdQYmgr.Process); Begin
	/*
	 * check of form information is proper.
	 */

	*sts = MSSUCC;
	
        form_ptr = me->forms[0].form_ptr ;

	FIfld_get_num_rows(	form_ptr,
				QRY_SUB_NAME,
				&nbRows );

	if( ! nbRows )	return OM_S_SUCCESS ;

	/*
	 * see of any query is selected.
	 */
	for( i=0 ; i<nbRows ; i++ ){

		state = FALSE ;
		FIfld_get_select(	form_ptr,
					QRY_SUB_NAME,
					i,
					0,
					&state );

		if( state ) break;
	}

	if( i >= nbRows ){
		/*
		 * Nothing selected.
		 */
		UI_status(" No queries selected " );
		*sts = MSFAIL ;
		return OM_S_SUCCESS;
	}

	/*
         * find out which objects need to be treated.
	 */
	switch( me->mytype ){

	case QRY_COB_DELETE:

		for( i=0 ; i<nbRows ; i++ ){

			state = FALSE ;
			FIfld_get_select(	form_ptr,
						QRY_SUB_NAME,
						i,
						0,
						&state );
			if( state ){
                        text[0] = '\0';
                        FIfld_get_text( form_ptr,
                                                QRY_SUB_NAME,
                                                i,
                                                0,
                                                DI_PATH_MAX,
                                                text,
                                                &selectFlag,
                                                &rPos );

        		strcpy( gvName, VD_qry_nmName );
                        for ( j = 0; j < nbRows; j ++) {
                          status =
                          om$send(msg = message ACrg_collect.ACgive_structure(
                                                        &rc,          /* out */
                                                        &directIndex, /* int */
                                                        gvName,       /* in  */
                                                        &retStr,      /* out */
                                                        &mdEnv ),     /* out */
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum );
                          if( !strcmp( text, retStr.var.text_st.text_string) ){
			   status =
			   om$send(msg = message ACrg_collect.NDdelete(&mdEnv),
				targetid = me->queries[j].objid,
				targetos = me->queries[j].osnum,
				senderid = NULL_OBJID );
                          }
			} /* for j */
		      } /*if */
	        }	
		break ;

	case QRY_COB_SAVE :
				
		/*
		 * open file file to write
		 */
		if( (filePtr = (FILE *) fopen( me->qry_File, "w" )) == NULL ){
			sprintf( my_msg,"Cannot open file: %s\n",me->qry_File );
			UI_status( my_msg );
			*sts = MSFAIL;
			break;

		}

		VDqry_write_header( filePtr );

		for( i=0 ; i<nbRows ; i++ ){

			state = FALSE ;
			FIfld_get_select(	form_ptr,
						QRY_SUB_NAME,
						i,
						0,
						&state );
			if( state ){

				FIfld_get_text(	form_ptr,
						QRY_SUB_NAME,
						i,
						0,
						DI_PATH_MAX,
						text,
						&selectFlag,
						&rPos );

                          strcpy( gvName, VD_qry_nmName );
                          for ( j = 0; j < nbRows; j ++) {
                          status =
                          om$send(msg = message ACrg_collect.ACgive_structure(
                                                        &rc,          /* out */
                                                        &directIndex, /* int */
                                                        gvName,       /* in  */
                                                        &retStr,      /* out */
                                                        &mdEnv ),     /* out */
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum );
                          if( !strcmp( text, retStr.var.text_st.text_string) ){
				status = 
				om$send(msg = message VDquery.VDgive_query(
								sts,
								&select,
								&where,
								&comment ),
					targetid = me->queries[j].objid,
					targetos = me->queries[j].osnum,
					senderid = NULL_OBJID );
				if( status & *sts & 1 ){
					VDqry_write_entry(	filePtr,
								text,
								select,
								where,
								comment );
				}

                                /* read pfxIndex and pfxName from collector */ 
                                pfxIndex = -1;
                                pfxName[0] = '\0';
                                status =
                                om$send(msg = message VDquery.VDgetPfxInfo(
                                                                sts,
                                                                &pfxIndex,
                                                                pfxName),
                                        targetid = me->queries[j].objid,
                                        targetos = me->queries[j].osnum,
                                        senderid = NULL_OBJID );
				if( status & *sts & 1 ){
                                   /* write prefix into ASCII file */
        			   VDpfx_write_entry(      filePtr,
                                                           text,
                                                           &pfxIndex,
                                                           pfxName);
                                } 
				_FREE(	 select );
				_FREE(	 where );
				_FREE(	 comment );

                            } /* if strcmp */
                          } /* for j */
			} /* if(state) */
		} /* for I */

		/*
		 * close the file.
		 */
		if( filePtr ){
			fflush( filePtr );
			fclose( filePtr );
			filePtr = NULL;
		}

		break;

	case	QRY_COB_LOAD :

		/* load query from ASCII file to query collecter
		 * open file to read
		 */
                filePtr = NULL;

                vd$openfile(    file_name       = me->qry_File,
                                product_name    = "Vds",
                                sub_path        = "config/queries",
                                cur_dir         = TRUE,
                                p_file          = &filePtr );
		if( filePtr == NULL ){
			sprintf( my_msg,"Cannot open file: %s\n",me->qry_File );
			UI_status( my_msg );
			*sts = MSFAIL;
			break;
		}

		nb_queries = om$dimension_of( varray  = me->queries );
		strcpy( gvName, VD_qry_nmName );

		for( i=0 ; i<nbRows ; i++ ){

			state = FALSE ;
			FIfld_get_select(form_ptr, QRY_SUB_NAME, i, 0, &state );
			if( ! state ) continue ;

			/*
			 * get text to check in ASCII file.
			 */
			FIfld_get_text(	form_ptr, QRY_SUB_NAME, i, 0,
					DI_PATH_MAX, text, &selectFlag, &rPos );

			found = FALSE;
						
                	for( j=0 ; j<nb_queries ; j++ ){

                        	status =
                        	om$send(msg = message ACrg_collect.
						ACgive_structure(
                                                        &rc,          /* out */
                                                        &directIndex, /* int */
                                                        gvName,       /* in  */
                                                        &retStr,      /* out */
                                                        &mdEnv ),     /* out */
                                	mode     = OM_e_wrt_message,
                                	targetid = me->queries[j].objid,
                                	targetos = me->queries[j].osnum );

				if( !(status&rc&1 )) continue;

				if( strcmp( text,
					retStr.var.text_st.text_string ) == 0 ){

					found = TRUE;
					break;
				}

			}
			/*
			 * get the query form the file.
			 */
			if( ! found )
                           {
                            /* get prefix toggle state */ 
                            FIg_get_state( form_ptr, QRY_SUB_PFX_TOGGLE,&state);
                            if(  !state ){ /* no read prefix */ 
                             if( VDqry_read_entry( filePtr, text )  == MSFAIL)
                                 {
                              	   sprintf(my_msg,
                                   "Input format is wrong" );
				   UI_status(my_msg );
                               	   FIg_set_text(form_ptr, 10, my_msg);
                                  }
                             }
                             else {
                             if( VDqrypfx_read_entry( filePtr, text ) == MSFAIL)
                                 {
                                   sprintf(my_msg,
                                   "Input format is wrong" );
                                   UI_status(my_msg );
                                   FIg_set_text(form_ptr, 10, my_msg);
                                 }
                             } 
                           } 
		} /* if */

		/*
		 * close the file.
		 */
		if( filePtr ){
			fflush( filePtr );
			fclose( filePtr );
			filePtr = NULL;
		}

		break;


	default:

#ifdef	DEBUG
		printf(" Something wrong here ...\n");
#endif
		*sts = MSFAIL ;
		break;
	}

        End
	goto quit;
}

