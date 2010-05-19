/* $Id: VDCmdsetop.sl,v 1.1.1.1 2001/01/04 21:08:48 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/cmd / VDCmdsetop.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdsetop.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:48  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/01/15  16:29:24  pinnacle
# TR_179802566
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.22  1996/05/31  15:30:38  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by yzhu for vds.240
#
# Revision 1.21  1996/02/29  12:47:44  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by rgade for vds.240
#
# Revision 1.19  1996/02/05  05:31:32  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by rgade for vds.240
#
# Revision 1.18  1995/12/29  20:38:16  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by yzhu for vds.240
#
# Revision 1.17  1995/12/08  19:15:22  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by yzhu for vds.240
#
# Revision 1.15  1995/08/28  13:14:26  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by azuurhou for vds.240
#
# Revision 1.14  1995/07/29  17:05:28  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by azuurhou for vds.240
#
# Revision 1.13  1995/06/19  13:28:18  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl for:  by azuurhou for vds.240
#
# Revision 1.12  1995/03/19  22:26:10  pinnacle
# Replaced: vdgraphics/cmd/VDCmdsetop.sl by azuurhou r#
#
# Revision 1.9  1995/01/05  21:27:46  pinnacle
# Replaced:  vdgraphics/cmd/VDCmdsetop.sl r#
#
# Revision 1.7  1994/12/22  20:00:28  pinnacle
# Replaced:  vdgraphics/cmd/VDCmdsetop.sl r#
#
# Revision 1.4  1994/12/01  22:21:34  pinnacle
# Replaced:  vdgraphics/cmd r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/20/94        cvr             fixed a bug with event queue
 *      12/07/95        yzhu            modify VDput_setqueue for TR179528357
 *      02/05/96        Ravi            Changed the form notification to 
 *				        carry same set names in active and
 *					reference files.	
 *      02/29/96        Ravi		Modified the delete and display.
 *	01/13/99	ejm	TR_179802566: Added om$make_chanselect before
 *				message VDgrset.VDName_to_id under
 *				"case SET_C_FIELD:".  Also, added (unsigned
 *				char *) in FIfld_set_list_text to satisfy
 *				compiler warnings.
 * --------------------------------------------------------------------*/

/*
 * I/VDS
 * 
 */
command_string	        VDC_M_ElSetPerf,0,VDPrStOp
class		        VDCmdsetop
super_class	        VDS_LOCATE 
product_name	   	"$VDS"
options                 "SITC"
command_table		"vds.cmd"


start_state	        start	

/* Doc: VDgrset

	1) Perform Set Operations

	   Abstract: This command object performs binary set operations for 
	     	     element sets. ( referred fem sets ).

	2) Review Drawing Set

	   Abstract: Review mechanisme to highlight the set of drawing set.

   
*/

/*--------------------------------------------------------------------------*/
/*                    class  specification                                  */
/*--------------------------------------------------------------------------*/

specification

#include "FI.h"
#include "FEI.h"

instance 
{
	Form		my_form;
        long		elem_set_num;
        long		del_set_num;
        char		**elem_set_name;
        char		**del_set_name;
        char		set_a_name[32],
			set_b_name[32],
			set_c_name[32];
        struct GRid	set_a_grid,
			set_b_grid,
			set_c_grid;
        short		operator; /* == 1, difference,
				     == 2, union,
				     == 3, intersection */
	struct GRid	gs_id;
	IGRboolean      delete_flag;
        long		totsets;
	int		setFlag ;
	variable struct GRobj_env  sets[1];
}

/*----------------------------------------------------------------------------*/
/*                    class implementation                                    */
/*----------------------------------------------------------------------------*/

implementation

#include	<stdio.h>
#include	<string.h>

#include	"OMprimitives.h"
#include	"OMmacros.h"
#include	"VDmem.h"
#include	"grgs.h"
#include	"nddef.h"
#include	"grgsmacros.h"
#include 	"FI.h"
#include        "grdpbmacros.h"
#include	"dpmacros.h"
#include	"grmacros.h"
#include	"exmacros.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include 	"AS_status.h"
#include        "vdrefmacros.h"
#include        "vdsetmacros.h"
#include	"v_miscmacros.h"
#include	"v_dbgmacros.h"

%safe
#include	"VX_FIproto.h"
%endsafe

#define	SETOP_FORM	0	/* Form Labels		*/

/* gadgets */

#define	ACTIVE_BUTTON	13
#define	DELETE_SET	14
#define	DISPLAY_SET	25
#define	SET_LIST_FIELD	16
#define	SET_A_FIELD     18
#define	DIFFGADGET	20
#define	UNIONGADGET	21
#define	INTERGADGET	22
#define	SET_B_FIELD	24
#define SET_C_FIELD	27
#define REFGADGET       29 
#define MESG_FIELD      10

#define DIFFERENCE	1
#define UNION		2
#define INTERSECTION	3

#define MESS		2001
#define DONE		2002
/* #define vdsDEBUG        1 */

%safe
static int      VDdisplay_flag;

%endsafe


extern	struct GRid	VDsetmgr_grid;

extern long   VDget_filename_from_os();
extern long   VDStrip_filename_from_setname();

from  	GRcontext  	import 	GRgetinstance;
from 	GRgraphics 	import 	GRdelete, GRconstruct;
from	GRowner		import	GRget_number_components, GRget_components,
				GRdelete_owner;
from	GRgrgrp		import	GRunion, GRintersection, GRdifference;
from	GRconnector	import	GRflexconn;
from	VDgrset		import	VDSet_name, VDName_to_id, 
                                VDGet_flag, VDGet_name, VDSet_flag;
from	VDsetmgr	import	VDclean_up;
from    NDnode          import  NDget_objects, ASreturn_go;
from    GRgrset         import  GSobject_add;
from    GRcontext       import  GRgetmodule_env;

/*--------------------------------------------------------------------------*/
/* 			 State Table                                        */
/*--------------------------------------------------------------------------*/

state_table

#include	"VDSFilter.h"
#include 	"VDmsg.h"

#define	SETOP_FORM	0	/* Form Labels		*/

#define MESS		2001
#define DONE		2002

state start

      execute       VDdisplay_form
      on ELSE        
                     do erase_form 0                      
                     state terminate

/*---------------------------------------------------------------------------*/
/*                       init                                                */
/*---------------------------------------------------------------------------*/

action init
{
struct GRid     VDCmdsetop_id;
char            path_name[DI_PATH_MAX];
IGRlong         msg;

#define		COMMAND_NAME	":IGENOD:VDCmdsetop_comm_id"

   SetProc( init ); Begin
   me->totsets = 0;
   me->elem_set_num  = 0;
   me->del_set_num  = 0;

   me->my_form	= NULL;

   me->setFlag = 0 ;		/* Select flag for public sets. */

   type = 0;
   str_ptr[0] = '\0';
   status =
   _VD_SEND_WRT_M(	my_id,
			VDS_LOCATE.init( type, str_ptr ));
   as$status( action = RET_STATUS );

   /*
    * -- Try to find an already active command 
    */
   status =
   di$give_pathname(	osnum		= OM_Gw_TransOSnum_0,
			pathname	= path_name );

   if( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );
     return ( OM_I_STOP_SENDING );
   }

   strcat( path_name, COMMAND_NAME );
   __DBGpr_str( " path_name ", path_name);

   status = di$translate ( objname = path_name,
                          osnum   = OM_Gw_TransOSnum_0,
                          p_objid = &VDCmdsetop_id.objid,
                          p_osnum = &VDCmdsetop_id.osnum );

   if ( status != DIR_S_SUCCESS )
   {
     if ( status == DIR_W_NAME_NOT_FOUND )
     {
	/*
	 * fprintf(" Couldn't find it, so trying to create my entry\n\n" );
	 */
	status =
	di$add_name(objname = path_name,
		    objid   = my_id,
		    osnum   = OM_Gw_TransOSnum_0 );

	if( status != DIR_S_SUCCESS ){
		di$report_error(sts     = status,
				comment = "Error : di$add_name" );
	}
    }
    else{

       /*
        * fprintf(" Couldn't create my entry\n\n" );
        */
    }
  }
  else if ( VDCmdsetop_id.objid != my_id )
  {
        __DBGpr_int( " VDCmdsetop_id ", VDCmdsetop_id.objid);
        __DBGpr_int( " my_id ", my_id);

        /*|CO id and my id not the same\n */
        status =
	_VD_SEND_MY( VDCmdsetop.delete ( 0 ));
        return OM_S_SUCCESS ;

  }
  /* Initialise the form pointer */
  status = _VD_SEND_MY( VDCmdsetop.VDInitForm(&msg));
  as$status( action = RET_STATUS );

  End
  goto quit ;
}

/*---------------------------------------------------------------------------*/
/*              VDInitForm                                                   */
/*---------------------------------------------------------------------------*/

action VDInitForm
{

extern void     COB_FI_form_notification();
extern void     COB_FI_initial_form_notification ();

GRname          form_name ;
int             form_label;

   SetProc( VDInitForm ); Begin
   if( me->mytype == 0 ){
	strcpy( form_name, "VDPerfSetOp" );
   }

   if( !me->my_form )
   {
         
        /* Initialize form */
		form_label = 0;
		status = 0; 
		status =
		FIf_new ( form_label,
                     	  form_name,
                     	  (int (*)())COB_FI_form_notification,
                     	  &me->my_form );
		if( status ){
			me->my_form	= NULL;
			return( OM_E_ABORT );
		} 
		/*
		 * tell the form which cmd it's talking to 
		 */
		status =
		FIf_set_cmd_oid_os(	me->my_form,
                               	 	my_id,
					OM_Gw_current_OS );
		if( status ){
			return OM_E_ABORT ;
		}
  }
   if( !me->my_form ) 
         __DBGpr_com( " me->my_form = NULL " ); 

  End
  goto quit ;
}
/*---------------------------------------------------------------------------*/
/*      VDdisplay_form                                                       */
/*---------------------------------------------------------------------------*/

action VDdisplay_form
{
long            msg;
extern void     COB_FI_initial_form_notification ();

    SetProc( VDdisplay_form ); Begin
    if ( me->delete_flag ) return OM_S_SUCCESS;

    __DBGpr_int(" VDdisplay_flag ", VDdisplay_flag);
    if ( !me->my_form )
          __DBGpr_com(" me->my_form = NULL");
    if( VDdisplay_flag != 1 && me->my_form )  { /* yzhu TR179528491 */ 
        VDdisplay_flag = TRUE;

/*    FIf_is_displayed ( me->my_form, &val ); it does not work */
        FIf_display( me->my_form );
 
    	status =
    	FIf_set_initial_notification_routine(
				me->my_form,
				(int (*)())COB_FI_initial_form_notification );
    	if( status ){
      	return( OM_E_ABORT );
    	}
    	status =
    	_VD_SEND_MY( VDCmdsetop.VDsetup_data( &msg ));
    	as$status( );
    }
    End
    goto quit;
}
   
/*---------------------------------------------------------------------------*/
/* 			 VDsetup_data                                        */
/*---------------------------------------------------------------------------*/

action VDsetup_data
{
long			msg;
OMuint			i,j,
			num_sets = 0;
OMuint			set_count = 0;
struct GRid		set_grid;
OM_S_OBJECT_LINKAGE	*sets = NULL;
long			elem_set_num;
char			**elem_set_name = NULL;
long			maxlen = 32;
IGRint			size = sizeof ( struct GRobj_env );
struct GRmd_env         locEnv;
OM_S_CHANSELECT	        GRcmpowner_to_connector_CS;
int                     k, num, public_sets,
                        ind, set_flag;

        SetProc( VDsetup_data ); Begin
	/* initialize */
	me->operator = 0;
	FIfld_get_num_rows( me->my_form, SET_LIST_FIELD, &num);
	for( k=0; k<num; k++ ){
             FIfld_set_text( me->my_form, SET_LIST_FIELD, k,0, "",FALSE);
	}
	FIfld_get_list_num_rows( me->my_form, SET_A_FIELD,0, &num);
	for( k=0; k<num; k++ ){
             FIfld_set_list_text( me->my_form, SET_A_FIELD, k,0, (unsigned char *)"",FALSE);
             FIfld_set_list_text( me->my_form, SET_B_FIELD, k,0, (unsigned char *)"",FALSE);
	}
	FIfld_set_num_rows( me->my_form, SET_LIST_FIELD, 0);

        __DBGpr_obj (" VDsetmgr_grid ", VDsetmgr_grid);
/*
 *delete any empty sets?????
 */
	status =
	_VD_SEND_OBJ(	VDsetmgr_grid,
			VDsetmgr.VDclean_up( &msg, &me->ModuleInfo ));

        UI_status( "List of ACTIVE Sets" ); 
/*
 * get a list of element sets
 */
        status =
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &GRcmpowner_to_connector_CS );
        as$status();

	status =
	om$get_channel_count(	objid = VDsetmgr_grid.objid,
				osnum = VDsetmgr_grid.osnum,
				p_chanselect = &GRcmpowner_to_connector_CS,
				count = &num_sets );

	if( ! num_sets ) goto quit;

	sets = _MALLOC( num_sets, OM_S_OBJECT_LINKAGE );
	if( ! sets ) goto quit;

	status =
	om$get_channel_objects( objid = VDsetmgr_grid.objid,
				osnum = VDsetmgr_grid.osnum,
				p_chanselect = &GRcmpowner_to_connector_CS,
				list = sets,
				size = num_sets,
				count = &set_count );

/*
 * separate the sets into public sets and display only those
 */

        public_sets  = 0;
        for( ind=0; ind<set_count; ind++ )
        {
             status =
             om$send( msg = message VDgrset.VDGet_flag( &msg, &set_flag ),
                      targetid = sets[ind].S_objid,
                      targetos = sets[ind].osnum );
             as$status();
             if( set_flag == me->setFlag ){
                 public_sets++;
             }
        }

	elem_set_num = 0;

	if( public_sets ){

	  elem_set_name = _MALLOC( public_sets, char * );
	  for( i=0 ; i<num_sets ; i++ )
	  {
                status =
                om$send( msg = message VDgrset.VDGet_flag( &msg, &set_flag ),
                         targetid = sets[i].S_objid,
                         targetos = sets[i].osnum );
                as$status();

                if( set_flag == me->setFlag ){

		  /* add to elem set list */
		  elem_set_name[elem_set_num] = _MALLOC( maxlen, char );

		  set_grid.objid = sets[i].S_objid;
		  set_grid.osnum = sets[i].osnum;
 		  /* get the module env. */
                  status =
                  gr$get_module_env(     msg     = & status,
                                         sizbuf  = & size,
                                         buffer  = & locEnv,
                                         nret    = & size );

                  size = om$dimension_of( varray = me->sets );
                  if( (elem_set_num + 1) > size )
                  {
                        /* must resize the vla */

                        size += 10;
                        status = om$vla_set_dimension(  varray  = me->sets,
                                                         size    = size );
                        as$status( action = GOTO_VALUE, value = quit );
                  }
                  me->sets[elem_set_num].obj_id = set_grid;
                  me->sets[elem_set_num].mod_env = locEnv;
		  status =
		  vd$setgrid_toname( set_grid  = &set_grid,
		      	             maxchar   = maxlen,
			             set_name  = elem_set_name[elem_set_num] );
	          elem_set_num ++;
                }
	  }
	}

	_FREE( sets );

/*
 * store the set names in instance data
 */
	me->elem_set_num = elem_set_num;
	me->elem_set_name = elem_set_name;

        me->totsets	= elem_set_num;
        
        /*
	 * clear the SET_LIST_FIELD gadget to display reference file sets
	 */


/*
 * put the set names in the form,excluding selected sets for deletion
 */
	num_sets = me->elem_set_num;
         
        k=0; 
	for( i=0 ; i<elem_set_num ; i++ ){
	    for( j=0; j<me->del_set_num; j++ ) {
                if ( !strcmp ( me->del_set_name[j],elem_set_name[i] ) )
		     break;
	    }
            if ( j < me->del_set_num ) continue; 
	    FIfld_set_text(	me->my_form, SET_LIST_FIELD, k, 0,
				elem_set_name[i], 0);
	    FIfld_set_list_text(me->my_form, SET_A_FIELD, k, 0,
				(unsigned char *)elem_set_name[i], 0);
	    FIfld_set_list_text(me->my_form, SET_B_FIELD, k, 0,
				(unsigned char *)elem_set_name[i], 0);
            k++;
        }

	/*
	 * do not the activities for the global set management.
	 */
	if( me->mytype != 0 )	goto quit ;

/*
 * clear the set operation fields.
 */

	FIfld_set_text( me->my_form, SET_A_FIELD, 0, 0, "", 0 );
	FIfld_set_text( me->my_form, SET_B_FIELD, 0, 0, "", 0 );
	FIfld_set_text( me->my_form, SET_C_FIELD, 0, 0, "", 0 );


	FIg_set_state_off( me->my_form,  DIFFGADGET );
	FIg_set_state_off( me->my_form, UNIONGADGET );
	FIg_set_state_off( me->my_form, INTERGADGET );

	*sts = DONE;
        End
        goto quit;
}

/*---------------------------------------------------------------------------*/
/*      VDshow_ref_sets                                                      */
/*---------------------------------------------------------------------------*/

action VDshow_ref_sets
{
long                  retmsg, rc, msg;
int                   nbos, num, k,
                      len, tot_count, 
                      index, ii, i;
OMuint                numref_set;
int                   totref_set = 0;
GRspacenum            *oslist;
struct GRmd_env       *modenvlist;
OM_S_CHANSELECT       GRcmpowner_to_connector_CS;
OM_S_OBJID            super_id;
struct GRid           mgr_id;
OM_S_OBJECT_LINKAGE   *ref_sets = NULL;
char                  **ref_set_name = NULL ;
int                   ind, set_flag, public_sets = 0;
char		      file_name[20],set_text[60];
IGRint		      size;

       SetProc(VDshow_ref_sets); Begin
       oslist     = NULL;
       modenvlist = NULL;
       nbos       = 0;
       mgr_id.objid = NULL_OBJID;

       /* clear the SET_LIST_FIELD gadget to display reference file sets */

       FIfld_get_num_rows( me->my_form, SET_LIST_FIELD, &num);
       for( k=0; k<num; k++ ){
          
            FIfld_set_text( me->my_form, SET_LIST_FIELD, k,0, "",FALSE);
       }
       FIfld_set_num_rows( me->my_form, SET_LIST_FIELD, 0);
       
       /* display active file sets */
       status =
       _VD_SEND_MY( VDCmdsetop.VDsetup_data( &msg ));
       as$status( );
       UI_status( "List of ACTIVE+REFERENCE file Sets" );

       i = me->elem_set_num - me->del_set_num;

       retmsg     =  vd$get_ref_os_list( msg     =  &rc,
                                         main_os = &me->ModuleInfo.md_id.osnum,
                                         num_ref_os   = &nbos,
                                         ref_os_list  = &oslist,
                                         ref_env_list =  &modenvlist );

       if( nbos  ==  0 ) {

              UI_status( " No attached reference files found " );         
              goto wrapup; 
       }

       for( ii = 0; ii < nbos; ii++ ){ 
              status = ex$get_objid_from_NOD (
                                                NODname   = "IGENOD",   
                                                objname   = "VDsuperset",
                                                pobjid    = &super_id,
                                                mod_osnum = oslist[ii]  );
              as$status();
   
              mgr_id.objid = super_id;
              mgr_id.osnum = oslist[ii];
   
              status =
              om$make_chanselect( channame      = "GRcmpowner.to_components",
                                  p_chanselect  = &GRcmpowner_to_connector_CS
                                );
              as$status();
   
	      if ( ref_sets )
	         _FREE( ref_sets );
              ref_sets=NULL;
                  

	      numref_set = 0;

              status =
              om$get_channel_count(  objid = mgr_id.objid,
                                     osnum = mgr_id.osnum,
                                     p_chanselect = &GRcmpowner_to_connector_CS,
                                     count = &numref_set );

              if( ! numref_set ) continue;
              
              ref_sets = _MALLOC( numref_set, OM_S_OBJECT_LINKAGE );
              if( ! ref_sets ) goto wrapup;
                  
              status =
              om$get_channel_objects(objid = mgr_id.objid,
                                     osnum = mgr_id.osnum,
                                     p_chanselect = &GRcmpowner_to_connector_CS,
                                     list = ref_sets,
                                     size = numref_set,
                                     count = &numref_set );
              public_sets = 0;
              for( ind=0; ind<numref_set; ind++ )
              {
                   status =
                   om$send( msg = message VDgrset.VDGet_flag( &msg, &set_flag ),
                            targetid = ref_sets[ind].S_objid,
                            targetos = ref_sets[ind].osnum );
                   as$status();
                   if( set_flag == me->setFlag ){
                        public_sets++;
                   }
              }

	      if( public_sets ){
                ref_set_name = _MALLOC( public_sets, char * );
                len  = 32;
                for( index=0; index<numref_set ; index++ ){
                 
                   status =
                   om$send( msg = message VDgrset.VDGet_flag( &msg, &set_flag ),
                            targetid = ref_sets[index].S_objid,
                            targetos = ref_sets[index].osnum );
                   as$status();

                  if( set_flag == me->setFlag ){

                     /* add to elem set list */ 
                     ref_set_name[index] = _MALLOC( len, char );
                     om$send( msg = message VDgrset.VDGet_name( 
                                                       &retmsg,
                                                       len,
                                                       ref_set_name[index]),
                              targetid = ref_sets[index].S_objid,
                              targetos = ref_sets[index].osnum );
                     as$status();
                     msg= VDget_filename_from_os( ref_sets[index].osnum,
								file_name );
		     sprintf(set_text, "%s[%s]",ref_set_name[index],file_name );

                     FIfld_set_text(me->my_form, SET_LIST_FIELD,
					i, 0, set_text, 0);
                     FIfld_set_list_text(me->my_form, SET_A_FIELD,
					i, 0, (unsigned char *)set_text, 0);
                     FIfld_set_list_text(me->my_form, SET_B_FIELD,
					i, 0, (unsigned char *)set_text, 0);

                     size = om$dimension_of( varray = me->sets );
                     if( (i+me->del_set_num + 1) > size )
                     {
                        /* must resize the vla */

                        size += 10;
                        status = om$vla_set_dimension(  varray  = me->sets,
                                                         size    = size );
                        as$status( action = GOTO_VALUE, value = quit );
                     }
                     me->sets[i+me->del_set_num].obj_id.objid =
						 ref_sets[index].S_objid;
                     me->sets[i+me->del_set_num].obj_id.osnum =
						  ref_sets[index].osnum;
                     me->sets[i+me->del_set_num].mod_env = modenvlist[ii];
                 
                     totref_set++;
                     i++;
                   } 
                }/* for( index = */
	         _LOOPFREE( ref_set_name, public_sets );
                 public_sets = 0;
	      } /* if public_sets */
         }/* for(ii =  */
        
         tot_count = me->elem_set_num + totref_set;
         me->totsets = tot_count;
     
	wrapup:
		_FREE( oslist );
		_FREE( modenvlist );
		_FREE( ref_sets );
		_LOOPFREE( ref_set_name, public_sets );
                End
		goto quit;
}

/*---------------------------------------------------------------------------*/
/*      VDcheck_set_in_ref_file                                              */
/*---------------------------------------------------------------------------*/

action VDcheck_set_in_ref_file( long *sts; IGRchar *selected_set )

{
long                  retmsg,rc;
int                   nbos,
                      ii ;
GRspacenum            *oslist;
struct GRmd_env       *modenvlist;
OM_S_CHANSELECT       GRcmpowner_to_connector_CS;
struct GRid           ref_grid, mgr_id;
OM_S_OBJID            super_id;
char                  my_set[32];
char		      set_text[60];

       SetProc(  VDcheck_set_in_ref_file ); Begin  
       oslist     = NULL;
       modenvlist = NULL;
       nbos       = 0;
       mgr_id.objid = NULL_OBJID;

       strcpy( my_set, selected_set );
   
       retmsg     =  vd$get_ref_os_list( msg     =  &rc,
                                         main_os = &me->ModuleInfo.md_id.osnum,
                                         num_ref_os   = &nbos,
                                         ref_os_list  = &oslist,
                                         ref_env_list =  &modenvlist );

       if( nbos  ==  0 ) {

              UI_status( " No attached reference files found " );
              goto wrapup;
       }

       for( ii = 0; ii < nbos; ii++ ){

              status = ex$get_objid_from_NOD (
                                                NODname   = "IGENOD",
                                                objname   = "VDsuperset",
                                                pobjid    = &super_id,
                                                mod_osnum = oslist[ii]  );
              as$status();

              mgr_id.objid = super_id;
              mgr_id.osnum = oslist[ii];

              status =
              om$make_chanselect( channame      = "GRcmpowner.to_components",
                                  p_chanselect  = &GRcmpowner_to_connector_CS
                                );
              as$status();
              status= VDStrip_filename_from_setname(my_set, set_text,
								mgr_id.osnum );
               
              status =
              om$send(msg = message VDgrset.VDName_to_id(    &retmsg,
                                                             set_text,
                                                             &ref_grid),
                      senderid = mgr_id.objid,
                      targetos = mgr_id.osnum,
                      p_chanselect = &GRcmpowner_to_connector_CS );
              as$status();

              if(status == OM_I_STOP_SENDING){

                     gr$display_object(  object_id =   &ref_grid,
                                         mode      =   GRhd );
                     break;
              }

         }/* for(ii =  */

wrapup:

	_FREE( oslist );
	_FREE( modenvlist );
        End
	goto quit ;
}

/*---------------------------------------------------------------------------*/
/*            free data after form dismissed                                 */
/*---------------------------------------------------------------------------*/

action VDfree_data
{

        SetProc( VDfree_data ); Begin
	status = OM_S_SUCCESS ;
	_LOOPFREE( me->elem_set_name, me->elem_set_num );
	_LOOPFREE( me->del_set_name, me->del_set_num ); 
        End
	goto quit;
}
/*---------------------------------------------------------------------------*/
/*            action  delete                                                 */
/*---------------------------------------------------------------------------*/

action	delete
{
long    sts, msg;

        SetProc ( delete ); Begin
        if ( !me->delete_flag ) {
             __DBGpr_com( " me->delete_flag = 0"); 
             End
             return OM_S_SUCCESS;
        }
	if( me->my_form ){
        	FIf_delete( me->my_form );
                __DBGpr_com( " me->my_form != NULL"); 
        }
              

	status =
	_VD_SEND_MY( VDCmdsetop.VDfree_data( &msg ));
	as$status( );

	status =
	_VD_SEND_WRT_M(	my_id,
			CEO.delete( 0 ));

	dp$erase_hilite( msg = &sts );

        VDdisplay_flag = FALSE;
        End
	goto quit;
}

/*-------------------------------------------------------------------------*/
/*                            set operations                               */ 
/*-------------------------------------------------------------------------*/

action VDset_operations
{
long			msg;
int			inq_count;
long			flag, index;
struct GRid		set_a_grid,
			set_b_grid,
                        set_c_grid, dup_set_c_grid;
struct GRvg_construct	cnst_list;
OM_S_CHANSELECT         GRcmpowner_to_connector_CS;

        SetProc( VDset_operations ); Begin
	*sts = MSSUCC;
	msg = MSSUCC;

/*
 * return if operator not specified
 */
	if(me->operator == 0) return( OM_S_SUCCESS );

/*
 * get grid for set_a, set_b
 */
	if( strlen( me->set_a_name ) == 0 ||
	    strlen( me->set_b_name ) == 0 ||
	    strlen( me->set_c_name ) == 0 ) return( OM_S_SUCCESS );

	status = vd$setname_togrid( set_name = me->set_a_name,
                                    set_grid = &set_a_grid 
                                  );
	status = vd$setname_togrid( set_name = me->set_b_name,
                                    set_grid = &set_b_grid
                                  );

/*
 * construct set_c
 */
        cnst_list.env_info = &me->ModuleInfo;
        cnst_list.properties = GRIS_NEW ;
        cnst_list.msg = &msg;
        cnst_list.newflag = FALSE;
        cnst_list.name = NULL;
        cnst_list.geometry = NULL;
        cnst_list.display = NULL;
        cnst_list.class_attr = NULL;

	set_c_grid.osnum = VDsetmgr_grid.osnum;

	status =
	om$construct(
		classid = OPP_VDgrset_class_id,
		msg = message GRgraphics.GRconstruct( &cnst_list ),
		p_objid = &set_c_grid.objid,
		osnum = set_c_grid.osnum );

        status =
	_VD_SEND_OBJ(	set_c_grid,
			VDgrset.VDSet_flag( &msg, 0 ));
        as$status();

/*
 * fill set c according to operator
 */
	if(me->operator == DIFFERENCE)
	{
		status =
		_VD_SEND_OBJ(	set_a_grid,
				GRgrgrp.GRdifference( &msg,	&set_b_grid,
								&set_c_grid ));
		as$status();
	}
	else if(me->operator == UNION)
	{
		status =
		_VD_SEND_OBJ(	set_a_grid,
				GRgrgrp.GRunion( &msg,	&set_b_grid,
							&set_c_grid ));
		as$status();	
        }
	else /*me->operator == INTERSECTION*/
	{
		status =
		_VD_SEND_OBJ(	set_a_grid,
				GRgrgrp.GRintersection(	&msg,	&set_b_grid,
								&set_c_grid ));
		as$status();	
	}

/*
 * Get the number of graphic objects comprising the group
 */
	status =
	_VD_SEND_OBJ(	set_c_grid,
			GRowner.GRget_number_components( &msg, &inq_count ));
        as$status();

  	if( inq_count > 0 ){

		status =
		om$make_chanselect(
			channame      = "GRcmpowner.to_components",
                        p_chanselect  = &GRcmpowner_to_connector_CS );
		as$status();

		/*
		 * check if set_c already exists
		 */
		status =
		om$send(msg = message VDgrset.VDName_to_id(
							&msg, 
                                                        me->set_c_name,
		                                        &dup_set_c_grid),
			senderid = VDsetmgr_grid.objid,
			targetos = VDsetmgr_grid.osnum,
			p_chanselect = &GRcmpowner_to_connector_CS );

		if( status == OM_I_STOP_SENDING ){

			/*
			 * we want to override set_c which already exists
			 */
			UI_status( "Overriding set C" );
			status =
			_VD_SEND_OBJ(	dup_set_c_grid,
					GRowner.GRdelete_owner( &msg,
							&me->ModuleInfo ));
			as$status();
		}

		/*
		 * assign name to set_c
		 */
		status =
		om$send(msg = message VDgrset.VDSet_name(&msg, me->set_c_name ),
			targetid = set_c_grid.objid,
			targetos = VDsetmgr_grid.osnum);
		as$status();

		UI_status( "Set Created" );

/*
 * connect the VDgrset to the VDsetmgr
 */
		flag = 1;
		index = OM_K_MAXINT;
		status =
		_VD_SEND_OBJ(	set_c_grid,
				GRconnector.GRflexconn( &msg,
							&flag,
							&VDsetmgr_grid,
							&index,
							&index ));
		as$status();
  	}
  	else{
		UI_status( "No objects in set C, set deleted" );

		status =
		_VD_SEND_OBJ(	set_c_grid,
				GRgraphics.GRdelete(&msg,&me->ModuleInfo));
		as$status();
  	}

	*sts = DONE;
        End 
	goto quit;
}

/*----------------------------------------------------------------------------*//*                             form_notification                              *//*----------------------------------------------------------------------------*/  
action form_notification
{
IGRlong		        num_sets,
			msg, retval;
IGRint		        sel_flg,
			i,j, putq, 
                        s_count,
			r_pos,  
			num_char=32,
			state, ref_state;
IGRchar			text[32], 
			temp_str[32];
OM_S_CHANSELECT         GRcmpowner_to_connector_CS;
struct  GRid		dup_set_c_grid ;
struct GRobj_env        *buffer;
long			*index_list=NULL;
char			**del_set = NULL;
long			maxlen = 32,ind=0;
int			rows;
IGRboolean		found = FALSE;


  SetProc( form_notification ); Begin
  
  buffer   = NULL;
  putq     = FALSE;
  s_count = 0;
  FIg_set_text( me->my_form, 10, "" );

  dp$erase_hilite( msg = &msg );

  switch ( gadget_label )
  {

  case SET_LIST_FIELD:

       break;

  case ACTIVE_BUTTON:


        if( me->gs_id.objid != NULL_OBJID ){
                status =
                gr$gsempty(
                        msg = &retval,
                        p_chanselect = &me->located_chansel);
                if( !status ){
                    return( OM_S_SUCCESS );
                }
        }

        me->gs_id.objid = NULL_OBJID;
        me->gs_id.osnum = me->ModuleInfo.md_id.osnum;
        status =
        gr$gsinit(      msg = &retval,
                        flag = 2,
                        p_objid = &me->gs_id.objid,
                        osnum = me->gs_id.osnum,
                        p_chanselect = &me->located_chansel);   /* CEO_LOCATE */
        if( !status ){
             return( OM_S_SUCCESS );
        }

        /* graphic set post_processing */
        status = gr$gspost_processing(msg = &retval,
                                p_chanselect = &me->located_chansel );
        if( !( status & 1  )){
              return( OM_S_SUCCESS );
        }

	num_sets = me->elem_set_num;

        for(i=0; i<me->totsets; i++)
	{
	      FIfld_get_text(me->my_form,SET_LIST_FIELD,i,0,num_char, 
				     (unsigned char * )text, &sel_flg,&r_pos);
	      if (sel_flg)
	      {
                  putq = TRUE;
                  _VD_SEND_MY( VDCmdsetop.VDput_setqueue( &msg, text ));
              }
        }

        if ( putq ){ _VD_SEND_MY( VDCmdsetop.VDput_intoq(&msg)); }

	break;

  case DELETE_SET:
	FIg_get_state(me->my_form, DELETE_SET, &state);
        FIfld_get_num_rows(me->my_form,SET_LIST_FIELD,&rows );

	if (state)
	{
	  /* validate the users selection */
	  sel_flg = 0;
          for(i=0; i<rows; i++ ) {
	    FIfld_get_select ( me->my_form,SET_LIST_FIELD,i,0,&sel_flg );
            if(sel_flg ) break;
	  }
          if ( !sel_flg ) { 
              FIg_set_text( me->my_form, MESG_FIELD, "Not selected the set" );
	      FIg_set_state_off(me->my_form, DELETE_SET);
              break;
	  } else if( !me->elem_set_num )
              	         FIg_set_text( me->my_form, MESG_FIELD,
                               		   "Reference sets can't be deleted" );

          num_sets = 0;
          if ( me->elem_set_num )  
          {
            index_list=_MALLOC( me->elem_set_num, long );
            if ( ! index_list ) goto quit;
	    del_set = me->del_set_name;
            for(i=0; i<rows; i++)
	    {
	      FIfld_get_text(me->my_form,SET_LIST_FIELD,i,0,num_char,
				    ( unsigned char * )text, &sel_flg,&r_pos);
	      if (sel_flg)
	      {
		/* Delete only active file sets  */
 		if( (strrchr( text, (int)'[' ) && strrchr( text, (int)']' )) )
                {
			UI_status("Reference sets can't be deleted" );
                        FIg_set_text( me->my_form, MESG_FIELD,
                                "Reference sets can't be deleted" );
                        continue;
		} 
		/* store the index of set in index list */
                for (j=0;j<me->elem_set_num; j++ )
                   if ( !strcmp(me->elem_set_name[j],text ) )
		   {
                      index_list[num_sets]=j;
                      num_sets++;
		   }  
	           
              }

	    }
            if( num_sets ) {
                if ( !del_set  ) {
            		del_set = _MALLOC( num_sets, char* );
                        if ( ! del_set ) goto quit;
                }
 		else
		{
			del_set=_REALLOC(del_set,
					 num_sets+me->del_set_num, char* );
                        if ( ! del_set ) goto quit;
		}
                
            	for( i=0; i<num_sets; i++ ) {
			maxlen = 32;
                	del_set[me->del_set_num+i] = 
						_MALLOC( maxlen, char );
			del_set[me->del_set_num+i]= 
					me->elem_set_name[ index_list[i] ];
            	}
            	me->del_set_num += num_sets;
            	me->del_set_name = del_set;
	    }
             
            _FREE( index_list );
            FIg_get_state(me->my_form, REFGADGET, &ref_state);
               
            if (ref_state)
                {
                  status =
		  _VD_SEND_MY( VDCmdsetop.VDshow_ref_sets( &msg ));
                  as$status( );
                }
                else{
                  status =
		  _VD_SEND_MY(	VDCmdsetop.VDsetup_data( &msg ));
                  as$status( );
                }
	  }   
	}
	FIg_set_state_off(me->my_form, DELETE_SET);
	break;

  case DISPLAY_SET:
        
	FIg_get_state(me->my_form, DISPLAY_SET, &state);
        FIfld_get_num_rows(me->my_form,SET_LIST_FIELD,&rows );

	if (state) {
	    num_sets = me->elem_set_num;
            
	    for(i=0; i<rows; i++) {

	      FIfld_get_text(me->my_form,SET_LIST_FIELD,i,0,num_char,
				    ( unsigned char * )text, &sel_flg,&r_pos);
	      if (sel_flg) { 
		   found = FALSE;
		   for(j=0; j<me->elem_set_num; j++ )
			if( ! strcmp( me->elem_set_name[j],text ) ) {
			   found = TRUE;
                           ind = j;
			   break;
		        }	
                   if( ! found )  ind = me->del_set_num + i;

                   vd$give_setobjs(	set_name = text,
					numcomps = &s_count );
 
                    if( ! s_count ) continue;

		    __DBGpr_int("Object Found", s_count );

                    buffer = _MALLOC( s_count, struct GRobj_env);
                    if( ! buffer ) continue;

                    vd$give_setobjs(	set_grid = &me->sets[ind].obj_id,	
					set_name = text,
					set_env  = &me->sets[ind].mod_env,
                                    	setobj_envs = buffer );

#ifdef	vdsDEBUG
		   for( j=0 ; j<s_count ; j++ ){
		     __DBGpr_obj( " ObJECT ", buffer[j].obj_id );
		   }
#endif

/*TR 179601796		    ACset_disthruref();  */ 

		    vd_$bulk_display(	dpmode	= GRhd,
					count	= s_count,
					objenvs	= buffer );
        /*TR 179601796	    ACreset_disthruref ();  */
		}
	    }
	}
        FIg_set_state_off( me->my_form, DISPLAY_SET );

        _FREE( buffer );

	break;

  case SET_A_FIELD:

	FIfld_get_text(	me->my_form,SET_A_FIELD,0,0,
			num_char,( unsigned char * )text,&sel_flg,&r_pos);
	strcpy(me->set_a_name,text);
	break;

  case SET_B_FIELD:

	FIfld_get_text(	me->my_form,SET_B_FIELD,0,0,
			num_char,( unsigned char * )text,&sel_flg,&r_pos);
	strcpy(me->set_b_name, text);
	break;

  case SET_C_FIELD:

	FIfld_get_text(	me->my_form,SET_C_FIELD,0,0,
			num_char,( unsigned char * )text,&sel_flg,&r_pos);

	if( strlen( text ) == 0 ){
		strcpy( me->set_c_name, "" );
		break;
	}


        __DBGpr_obj (" VDsetmgr_grid ", VDsetmgr_grid);

        status =
        om$make_chanselect(
                channame      = "GRcmpowner.to_components",
                p_chanselect  = &GRcmpowner_to_connector_CS );
        as$status();

	/*
	 * check if set_c already exists
	 */
	status =
	om$send(msg = message VDgrset.VDName_to_id(	&msg,
							text,
							&dup_set_c_grid ),
		senderid = VDsetmgr_grid.objid,
		targetos = VDsetmgr_grid.osnum,
		p_chanselect = &GRcmpowner_to_connector_CS );

	if( status == OM_I_STOP_SENDING ){ /* set_exists */
		sprintf(temp_str,"Set %s Exists", text);
		UI_status( temp_str );
		strcpy( me->set_c_name, "" );
		FIfld_set_text(	me->my_form, SET_C_FIELD, 0, 0,
				me->set_c_name, 0);
	}
	else { strcpy(me->set_c_name, text); }

	break;

  case FI_CVT_TO_PERM_WIN:

	FIf_cvrt_to_perm_win( me->my_form );
	break;

  case FI_CANCEL:
       
        me->delete_flag = 1;
        status =
        _VD_SEND_MY(	VDCmdsetop.delete( 0 ));
	break;

  case FI_ACCEPT:
  case FI_EXECUTE:

        /* delete the selected sets */

        for ( i = 0;i< me->del_set_num; i++ ) {
			status =
                              vd$delete_set( set_name = me->del_set_name[i] );
                        me->elem_set_num = me->elem_set_num-1;
        }
           
	status =
	_VD_SEND_MY(	VDCmdsetop.VDset_operations( & msg ));
	as$status();

	num_sets = me->elem_set_num;

	if( gadget_label == FI_ACCEPT ){
		me->delete_flag = 1;
		status = _VD_SEND_MY( VDCmdsetop.delete( 0 ));
	}
	else{
		status = _VD_SEND_MY( VDCmdsetop.VDfree_data( &msg ));
		as$status( );
                me->del_set_num = 0;
              
                FIg_set_state_off( me->my_form, REFGADGET );
 
		status = _VD_SEND_MY( VDCmdsetop.VDsetup_data( &msg ));
		as$status( );
	}

	break;

  case DIFFGADGET:

	me->operator = DIFFERENCE;
	break;

  case UNIONGADGET:

	me->operator = UNION;
	break;

  case INTERGADGET:

	me->operator = INTERSECTION;
	break;

  case REFGADGET:

        FIg_get_state(me->my_form, REFGADGET, &ref_state);
        if (ref_state)
        {
		status = _VD_SEND_MY( VDCmdsetop.VDshow_ref_sets( &msg ));
                as$status( );
        }
        else{
                status = _VD_SEND_MY( VDCmdsetop.VDsetup_data( &msg ));
                as$status( );

        }
        break;  
  }

  End
  goto quit;
}

/*----------------------------------------------------------------------------*/
/*                             VDput_setqueue                                 */
/*----------------------------------------------------------------------------*/

action VDput_setqueue( long *sts; IGRchar *set_chosen )
{

struct GRobj_env        set_grid;
IGRlong                 msg;
IGRchar                 set_name[35];
int                     s_count, 
                        refcount, index;
struct GRid             *buffer = NULL;
struct GRmd_env         *env_list = NULL;
/* struct GRmd_env         md_env; */
struct GRid             *exid = NULL;
struct GRid             context,
                        temp_buff;
int                     ii,
                        env_prop;

GRspacenum            *oslist;
struct GRmd_env       *modenvlist;
long                  retmsg,rc;


        SetProc( VDput_setqueue ); Begin
	*sts = MSSUCC;
	msg = MSSUCC;

        s_count = 0;
        refcount = 0;
        set_grid.obj_id.objid = NULL_OBJID;
        context.objid = NULL_OBJID;
        strcpy( set_name, set_chosen );
        status = vd$setname_tobjenv( set_name   = set_name, 
                                     VDset_grid = &set_grid
                                   );
        if( set_grid.obj_id.objid == NULL_OBJID )goto wrapup;

        vd$give_setobjs(set_name = set_name,
                        numcomps = &s_count );       

        if( ! s_count ){ return( OM_S_SUCCESS ); }

        buffer   = _MALLOC( s_count, struct GRid );
        env_list = _MALLOC( s_count, struct GRmd_env );

        if( !env_list ){
             printf( "bad allocation\n" );
             goto wrapup;
        } 

        if ( buffer ){
             vd$give_setobjs(set_name = set_name,
                             set_objs = buffer ); 
	}
        else return OM_S_SUCCESS ;
    
        env_prop = 0;

        /* yzhu for TR179528357 */     
        oslist     = NULL;
        modenvlist = NULL;

        retmsg    =  vd$get_ref_os_list( msg     =  &rc,
                                         main_os = &me->ModuleInfo.md_id.osnum,
                                         num_ref_os   = &refcount,
                                         ref_os_list  = &oslist,
                                         ref_env_list =  &modenvlist );
/* TR179528682
        if( refcount  ==  0 ) {

              UI_status( " No attached reference files found " );
              goto wrapup;
        }
*/
        for( index=0; index<s_count; index++ ){
          /*
          * Loop on contexts.
          */
          for(ii=0; ii<refcount; ii++){

                if( buffer[index].osnum == oslist[ii]){
                        __DBGpr_int( "Osnum  ",  oslist[ii] ) ;
                      env_list[index] = modenvlist[ii];
                      break;
                }

	  } /* for ii */
        
          /* test if it is in current space */
          if( buffer[index].osnum == me->ModuleInfo.md_id.osnum){
                    env_list[index] = me->ModuleInfo;
          }
          temp_buff.objid = buffer[index].objid;
          temp_buff.osnum = buffer[index].osnum;  
                   
          status =
	  _VD_SEND_OBJ(	me->gs_id,
			GRgrset.GSobject_add( &msg,
                                              &temp_buff,
                                              &env_list[index],
                                              &env_prop,
                                              NULL, NULL ));
          if( !( status & 1)){
            om$report_error(sts = status);
            printf(" ERROR: msg GRgrset.GSobject_add failed\n");
            *sts = MSFAIL ; goto wrapup;
          }
	}	

wrapup:

	_FREE( env_list );
	_FREE( buffer );
	_FREE( exid );
        _FREE( oslist );
        _FREE( modenvlist );
        End
        goto quit;

}

/*----------------------------------------------------------------------------*/

action VDput_intoq
{
IGRlong               retmsg,size;
IGRint                givecount;
IGRint                response;
struct GRevent        event;

         SetProc ( VDput_intoq ); Begin
         *sts = MSSUCC;

         status =
         gr$gsinqcount(  msg       = &retmsg,
                         count     = &givecount,
                         object_id = &me->gs_id );

        if( !(status & 1 )){
                goto wrapup;
        }

        if( ! givecount ) goto wrapup ;

        status =
        gr$gsput_select_set(    msg           = &retmsg,
                                mod_env       = &me->ModuleInfo,
                                select_set_id = &me->gs_id );
        if( !(status & 1 )){
                goto wrapup;
        }

        event.num_id    = 1;
        event.num_val   = 0 ;
        event.subtype   = GRst_LOCATE ;
        event.response  = EX_DATA ;
        event.event.button.x                            = 0. ;
        event.event.button.y                            = 0. ;
        event.event.button.z                            = 0. ;
        event.located_object[0].located_obj             = me->gs_id;
        event.located_object[0].module_info             = me->ModuleInfo ;
        event.located_object[0].geom_parms.u            = 0. ;
        event.located_object[0].geom_parms.v            = 0. ;
        event.located_object[0].geom_parms.polygon_inx  = 0. ;

        size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

        /*
         * Put EX_OBJID event on front of software queue
         */
         response = EX_OBJID;

        /*
         *  send event
         */
        status =
        ex$putque(      msg      = &retmsg,
                        response = &response,
                        byte     = &size,
                        buffer   = (IGRchar *)&event.event.button );
        if( !( status & *sts & 1 )){
                goto wrapup;
        }

wrapup:
        End
	goto quit;
}

/*----------------------------------------------------------------------------*/

