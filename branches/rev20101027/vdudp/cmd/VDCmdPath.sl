/* $Id: VDCmdPath.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPath.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPath.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/17  09:45:28  pinnacle
# Replaced: vdudp/cmd/VDCmdPath.sl for:  by vgnair for vds
#
# Revision 1.2  1997/12/05  22:52:56  pinnacle
# Replaced: vdudp/cmd/VDCmdPath.sl for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/03/22  14:16:42  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/13  23:10:02  pinnacle
# Replaced: vdudp/cmd/VDCmdPath.sl for:  by yzhu for vds.240
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
 *	04/17/98	vini		TR179800084
 * -------------------------------------------------------------------*/

command_string       VDC_M_DfMdDrPt, 0, VDDfMdDrPt
command_table        "vds.cmd"
class                VDCmdPath
super_class          VDS_LOCATE
product_name         "$VDS"

/**
form "VDDirPath" ,MAIN,2,"-1","-1",1
form "VDSymb" ,SUB,0,"-1","-1",1
**/

specification

#include <stdio.h>
#include "igrtypedef.h"
#include "FI.h"
#include "VDSpathdef.h"
#include "VDSpath_form.h"

/* instance variables for form control */

instance
{
   int				del_row;
   int				delete_flag;
   struct constr_path  		located_path;
   struct constr_path		select_act_path;
   int				select_flag;
   int				symbology_flag;
   int				main_flag;
   int				search_flag;
   int				main_nb;
   int				search_nb;
   struct current_path		current;
   int  			main_name_index;
   int  			search_name_index;
   struct constr_path  		select_path;
   variable struct constr_path  main[5];
   variable struct constr_path  search[5];
   variable struct constr_path	intermediate[5];
   int				select_index;
   int				nb_intermediate;
   int  			int_name_index[2];
   long				select_attr;
   /* Form control */

   char *		form_name[3];
   int			form_label[3];
   Form  		form_ptr[3];

   
}


implementation

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "parametric.h"
#include "expression.h"
#include "exdef.h"
#include "ex.h"
#include "griomacros.h"
#include "lcmacros.h"
#include "adpdef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "AS_status.h"

#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "vddirmacros.h"

#include "VDSudpco.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from GRvg 	import GRgetsymb,GRgetname;

%safe
static int 	x_memo = -1,
       		y_memo = -1;

%endsafe

extern void COB_FI_form_notification(), COB_FI_initial_form_notification();

/*----------------------- state_table ------------------------*/

state_table

#include "VDmsg.h"
#include "VDSudpco.h"

state start

  on CMD_TYPE = 0						state terminate


/*----------------------- add_path ---------------------------*/
action add_path(long *msg; 
                int nb_main; 
                int nb_search;
		struct constr_path *main; 
		struct constr_path *search;
		int		   option;)

{

long			sts;
int			list_index, found, i;

	SetProc( add_path ); Begin

*msg = OM_S_SUCCESS;
list_index   = -1;
found 	      = 0;


for(i= 0; i< nb_main;i++)
 {
    sts =vds$name_in_list( in_name   = main[i].name, 
			   out_index = &list_index, 
			   list      = &me->main[0], 
			   nb_elts   = me->main_nb,
			   found     = &found);
    if (! (sts & 1))
	             {
		        printf("error vds$name_in_list\n");
                        goto wrapup;
	             }
    if (found == 1)
     { 
      /*|name found in list  */

       if(option == 1) 
        { 
         /*|option = 1 modify exp and verify if current must also be modified */
         me->main[list_index] = main[i];
         if(strcmp(me->current.main_cst_path.name,main[i].name)==0)
             me->current.main_cst_path = main[i]; 
        }
       else continue;
     }
    else 
     {
      /*|name not found add path */ 

       me->main_nb = me->main_nb + 1;
       if(om$dimension_of(varray = me->main) <= me->main_nb)
          {
	    if(!(om$vla_set_dimension(varray = me->main,
					size = me->main_nb + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
          }
       me->main[me->main_nb - 1] = main[i];
     }

 }
for (i= 0;i< nb_search ;i=i+1)
 {

    sts =vds$name_in_list( in_name   = search[i].name, 
			   out_index = &list_index, 
			   list      = &me->search[0], 
			   nb_elts   = me->search_nb,
			   found     = &found);
    if (! (sts & 1))
	             {
		        printf("error vds$name_in_list\n");
                        goto wrapup;
	              }
    if (found == 1)
     { 
      /*|name found in list  */

       if(option == 1) 
        { 
         /*|option = 1 modify exp and verify if current must also be modified */
         me->search[list_index] = search[i];
         if(strcmp(me->current.search_cst_path.name,search[i].name)==0)
             me->current.search_cst_path = search[i]; 
        }
       else continue;
     }
    else 
     {

      /*|name not found add path */ 
       me->search_nb = me->search_nb + 1;
       if(om$dimension_of(varray = me->search) <= me->search_nb)
          {

	    if(!(om$vla_set_dimension(varray = me->search,
					size = me->search_nb + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
          }
       me->search[me->search_nb - 1] = search[i];
     }

 }

 sts = vds$update_path(	form_ptr = me->form_ptr[MAIN],
			current = &me->current,
		  	main = &me->main[0],
		  	search = &me->search[0],
		  	nb_main = me->main_nb ,
		  	nb_search = me->search_nb );

 if (! (sts & 1))
   {
     printf("VDSpath:failure vds$update_path\n");
     goto wrapup;
   }


return OM_S_SUCCESS;
wrapup:
        *msg = OM_E_ABORT;
        End
    	return OM_E_ABORT;


}

/*----------------------- store_path ---------------------------*/
action store_path(struct GRid loc_obj;)
/*.store_path*/
{

 char			dirname[DI_PATH_MAX], text[DI_PATH_MAX],
			name[DI_PATH_MAX],auto_name[NAME_MAX],
			color[SYMB_CHAR];
 long			msg;
 struct GRsymbology	symbology;
 int	       		num_char = DI_PATH_MAX, const_flag, num_rows, sts,i,exist,  
			list_index,r_pos, sel_flag, index,named_flag,len;

	SetProc( store_path ); Begin
 
dp$erase_hilite(msg=&sts);

 if(me->search_flag)	const_flag = SEARCH_PATH;
 else			const_flag = MAIN_PATH;

#if 0
 status = di$untranslate(	objname = name,
				objid = loc_obj.objid,
				osnum = loc_obj.osnum);
#endif

 status = om$send(msg      = message GRvg.GRgetname(&msg,name),
                  targetid = loc_obj.objid,
		  targetos = loc_obj.osnum);

 if(!(status & msg & 1))
   {
        if ( me->form_ptr[LIST] != NULL )
   	 {
          FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
                         "ERROR: not a named object",FALSE);
         }
	return OM_S_SUCCESS;
   }
 else
  {
    len = strlen(name);

    status = di$split(pathname = name, dirname =dirname);
    if(status != DIR_S_SUCCESS)
     {
	printf("error in split path\n");
        return OM_E_ABORT;
     }

    EXP_strip(dirname);

    len = strlen(dirname);
    if(len >= MY_PATH_MAX)
      {        
        if ( me->form_ptr[LIST] != NULL )
   	 {
          FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
                         "ERROR: path too long, cannot store it",FALSE);
         }
	return OM_E_ABORT;
      }
    strcpy(me->located_path.path,dirname);

    status = om$send ( msg = message GRvg.GRgetsymb(&msg,&symbology),
                              senderid = NULL_OBJID,
                              targetid = loc_obj.objid,
		              targetos = loc_obj.osnum);
    if (! (status & 1))
      {
        printf("failure sending GRvg.GRgetsymb\n");
        as$status(action = RET_STATUS);
        return OM_E_ABORT;
      }

    if( !(ige$get_name_from_color(name = color,
				  color = (short)symbology.display_attr.color)))
          sprintf(me->located_path.symbology.color, "%d",symbology.display_attr.color);
    else strcpy(me->located_path.symbology.color, color);

    sprintf(me->located_path.symbology.style, "%d",symbology.display_attr.style);
    sprintf(me->located_path.symbology.layer, "%d",symbology.level);
    sprintf(me->located_path.symbology.weight,"%d",symbology.display_attr.weight);
    me->located_path.symbology.layer_name[0] = '\0';
    

    if ( me->form_ptr[LIST] == NULL ) 
      {
        printf("ERROR: form Path list not active\n");
        return OM_E_ABORT;
      }
    status = FIfld_get_num_rows(me->form_ptr[LIST],LIST_FIELD, &num_rows);
    if (status != FI_SUCCESS)
     {printf("FIfld_get_num_rows fail \n"); return OM_E_ABORT;}


    status = FIfld_get_text(me->form_ptr[LIST],LIST_FIELD,num_rows - 1, 0,
                            num_char, text, &sel_flag, &r_pos );
    if (status != FI_SUCCESS)
     {printf("FIfld_get_text fail \n"); return OM_E_ABORT;}

    if(text[0] == '\0'){/*|no text in previous line*/ num_rows = num_rows - 1;}

    if(om$dimension_of(varray = me->intermediate) <= num_rows)
      {

	  if(!(om$vla_set_dimension(varray = me->intermediate,
			              size = me->nb_intermediate + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");return OM_E_ABORT;}
	  for(i=me->nb_intermediate;i<me->nb_intermediate+ALLOC_INCR;i++)
		     VDSinit_symb(&me->intermediate[i]);
      }

    strcpy(me->intermediate[num_rows].path, me->located_path.path);
    me->intermediate[num_rows].name[0] = '\0';
    if(me->main_flag) me->intermediate[num_rows].symbology = me->located_path.symbology;
    me->nb_intermediate = me->nb_intermediate + 1;
    if(me->search_flag) index = me->int_name_index[1];
    else index = me->int_name_index[0];

      

    exist = 1;
    while(exist)
     {
	
    	status = vds$auto_name(	index = index,
			   	to_name = &me->intermediate[num_rows],
			   	const_flag = const_flag,
			   	name = auto_name,
			   	named_flag = &named_flag);
    	if (! (status & 1))
      	 {
		printf("error vds$auto_name\n");
		me->ret = MSFAIL;
    		return OM_S_SUCCESS;
      	 }
        exist = 0;
	list_index = -1;

        me->intermediate[num_rows].name[0] = '\0'; 

	status =vds$name_in_list( in_name   = auto_name, 
			        out_index = &list_index, 
				list      = &me->intermediate[0], 
				nb_elts   = me->nb_intermediate - 1,
				found     = &exist);
     	if (! (status & 1))
	             {
		        printf("error vds$name_in_list\n");
		        me->ret = MSFAIL;
    		        return OM_S_SUCCESS;
	              }

         if(exist ) me->intermediate[num_rows].name[0] = '\0';
         index = index + 1;
                    
     }/* while exist */

    if(named_flag)
      { 
         strcpy(me->intermediate[num_rows].name,auto_name);
      }

    status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, num_rows, 1, 
                   me->intermediate[num_rows].path,FALSE);
    if (status != FI_SUCCESS)
     {printf("FIfld_set_text fail \n"); return OM_E_ABORT;}

    status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, num_rows, 0, 
		   me->intermediate[num_rows].name,FALSE);
    if (status != FI_SUCCESS)
     {printf("FIfld_set_text fail \n"); return OM_E_ABORT;}

    
  }

FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
               "path of the named object loaded",FALSE);
  End
return OM_S_SUCCESS;
}

/***********************************************************/
action init
/*.init*/
{
  char			path_name[DI_PATH_MAX+25],str_ptr[MY_MAX];
  int			i,sts;
  long			stat,msg;
  struct GRid		VDSpath_id;
  extern int		(*AStranslate)(), VDStranslate();

	  SetProc(VDCmdPath.init ); Begin


  /* delete by default */
   me->delete_flag 	 = 1;
   me->symbology_flag 	 = 0;
   me->main_flag 	 = 0;
   me->search_flag 	 = 0;
   me->form_ptr[MAIN]	 = NULL;
   me->form_ptr[SUB]	 = NULL;
   me->form_ptr[LIST]	 = NULL;
   me->main_name_index 	 = 1;
   me->search_name_index = 1;
   me->select_flag 	 = 0;
   me->del_row           = 0;
   me->ret 		 = MSSUCC;
   
   for(i=0;i<5;i++){
   	VDSinit_symb(&me->main[i]);
   	VDSinit_symb(&me->search[i]);
   	VDSinit_symb(&me->intermediate[i]);
   	me->main[i].path[0] = '\0';
   	me->main[i].name[0] = '\0';
   	me->search[i].path[0] = '\0';
   	me->search[i].name[0] = '\0';
   	me->intermediate[i].path[0] = '\0';
   	me->intermediate[i].name[0] = '\0';
   }
  me->select_path.path[0] = '\0';
  me->select_path.name[0] = '\0';
  VDSinit_symb(&me->select_path);
  
  VDSinit_symb(&me->current.main_cst_path);
  VDSinit_symb(&me->current.search_cst_path);
  
  me->current.main_cst_path.path[0] = '\0';
  me->current.main_cst_path.name[0] = '\0';

  me->current.search_cst_path.path[0] = '\0';
  me->current.search_cst_path.name[0] = '\0';

   dp$erase_hilite(msg=&sts);
  AStranslate = VDStranslate; 
  status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

  if ( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
   }

  strcat( path_name, COMMAND_NAME );


  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VDSpath_id.objid,
			  p_osnum = &VDSpath_id.osnum );
  if ( status != DIR_S_SUCCESS ) 
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {
      status = di$add_name( objname = path_name,
			    objid   = my_id,
			    osnum   = OM_Gw_TransOSnum_0 );

      if ( status != DIR_S_SUCCESS )
  	{
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
	}
      else
       {
        /*| name added starting initialisation */

	type = 0;
	str_ptr[0] = '\0';
        status     = om$send( targetid = my_id,
				mode   = OM_e_wrt_message,
				msg    = message CEO_LOCATE.init( type, 
                                                                  str_ptr ) );
	as$status( action = RET_STATUS );

  	me->form_name[MAIN] = MAIN_FORM_NAME ;
  	status = 0; 
	status = FIf_new ( MAIN,
                     	   me->form_name[MAIN],
                     	   COB_FI_form_notification,
                     	   &me->form_ptr[MAIN] );

  	if ( status )
 	 {
    	  me->form_ptr[MAIN] = NULL;
    	  me->state = _terminate;
	  me->delete_flag = 1;
	  return ( OM_I_STOP_SENDING );
   	 } 
	else
	 {
     	  /*** tell the form which cmd it's talking to ***/
     	  status = FIf_set_cmd_oid_os (  me->form_ptr[MAIN],
                                	 my_id, OM_Gw_current_OS );
	  if ( status )
      	   {
    	    me->state = _terminate;
	    me->delete_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
     	  status = FIf_set_initial_notification_routine ( me->form_ptr[MAIN],
                                COB_FI_initial_form_notification );
     	  if ( status )
	   {
    	    me->state = _terminate;
	    me->delete_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
	 }
   
	 /* init les instances avec les expressions */

	 FIfld_set_mode(me->form_ptr[MAIN],MAIN_PATH_FIELD, 0, FI_REVIEW);
	 FIfld_set_mode(me->form_ptr[MAIN],SEARCH_PATH_FIELD, 0, FI_REVIEW);

         stat = om$send (  msg = message VDCmdPath.exp_to_instances(&msg),
                     	targetid = my_id);

         if ( (! (stat & 1)) || msg == OM_E_ABORT)
   		    {
      			printf("VDCmdPath:failure sending exp_to_instances\n");
	 		me->ret = MSFAIL;
			as$status(sts = stat, action = RET_STATUS);
         		return OM_S_SUCCESS;
   		     }

  	 me->delete_flag = 0;
 	 if(x_memo != -1 || y_memo != -1) 
		FIf_set_location(me->form_ptr[MAIN],x_memo,y_memo);
	 
         FIbtn_set_auto_pop_up_on( me->form_ptr[MAIN], READ_BUTTON );
         FIbtn_set_auto_pop_up_on( me->form_ptr[MAIN], WRITE_BUTTON );
	 FIg_set_state_off(me->form_ptr[MAIN], EXIT);
         FIg_set_state_off(me->form_ptr[MAIN], SAVE);
	 FIf_display( me->form_ptr[MAIN] );
	}
     }
    else
    {
         di$report_error( sts     = status,
                          comment = "  Unable to find my entry\n" );
    }

  }
 else if ( VDSpath_id.objid != my_id )
  {
    /*| CO id and my id not the same */
    me->delete_flag = 1;
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

  End
  /*|  end my_init */

} 
/**********************************************************/

action delete
{
  SetProc(VDCmdPath.delete ); Begin
  if ( me->form_ptr[MAIN] != NULL )
     FIf_get_location(me->form_ptr[MAIN],&x_memo,&y_memo);

  if ( me->delete_flag  )
   {
/*	HF: 12/05/97 Replaced FIf_delete with FIf_erase : TR # 179701894

    if ( me->form_ptr[MAIN] != NULL ) FIf_delete( me->form_ptr[MAIN] );
    if ( me->form_ptr[LIST] != NULL ) FIf_delete( me->form_ptr[LIST] );
    if ( me->form_ptr[SUB ] != NULL ) FIf_delete( me->form_ptr[SUB ] );
*/
    if ( me->form_ptr[MAIN] != NULL ) FIf_erase( me->form_ptr[MAIN] );
    if ( me->form_ptr[LIST] != NULL ) FIf_erase( me->form_ptr[LIST] );
    if ( me->form_ptr[SUB ] != NULL ) FIf_erase( me->form_ptr[SUB ] );

    status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.delete ( 0 ));

    End
    return ( OM_S_SUCCESS );

   }
  else
   {
     End
     return ( OM_S_SUCCESS );
    }

}




/*----------------------- form_init  ---------------------------*/
/*  method which update the instances and init the main form 
/*  if sub forms has been deleted
 */

action form_init()

/*.form_init*/
{
        SetProc(VDCmdPath.form_init ); Begin
        me->select_flag    = 0;
	me->symbology_flag = 0;
        me->del_row        = 0;
      	me->main_flag      = 0; 
      	me->search_flag    = 0; 

	/*| Enable & Set button to off */

        FIg_set_state_off( me->form_ptr[MAIN], MAIN_BUTTON);
        FIg_set_notify_on( me->form_ptr[MAIN], MAIN_BUTTON);
        FIg_set_state_off( me->form_ptr[MAIN], SEARCH_BUTTON);
        FIg_set_notify_on( me->form_ptr[MAIN], SEARCH_BUTTON);

        FIg_enable( me->form_ptr[MAIN],MAIN_BUTTON);
        FIg_enable( me->form_ptr[MAIN],SEARCH_BUTTON);
	FIg_enable( me->form_ptr[MAIN],READ_BUTTON);
	FIg_enable( me->form_ptr[MAIN],WRITE_BUTTON);
	FIg_enable( me->form_ptr[MAIN],SAVE);
	FIg_enable( me->form_ptr[MAIN],STORE);
	FIg_enable( me->form_ptr[MAIN],ABORT);
        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,"",FALSE);
        End

}


/*----------------------- exp_to_instances ---------------------------*/
/*  method which update the instances with the expressions 
 */

action exp_to_instances(long *msg;)

/*.exp_to_instances*/
{
char			us_path[DI_PATH_MAX+30],**lines;
long			sts;
struct GRid		dir_obj;
struct GRmd_env		md_env;
int			nb_lines,len;

	SetProc(VDCmdPath.exp_to_instances); Begin

me->main_nb   = 0;
me->search_nb = 0;
lines = NULL;
nb_lines = 0;


sts = vds$init_path(user_path = us_path, dir_obj = &dir_obj,md_env = &md_env); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}

len = strlen(us_path);
strcpy(&us_path[len],":*");

sts = di$ls( regexp = us_path,
	     lines  = &lines,
	     ptr    = &nb_lines);
if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}


sts = vds$give_exp( nb_main   = &me->main_nb, 
		    nb_search = &me->search_nb,
		    current   = &me->current,
		    nb_lines  = nb_lines,
		    lines     = lines);
if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}

 if(om$dimension_of(varray = me->search) <= me->search_nb)
    {
	 if(!(om$vla_set_dimension( 	varray = me->search,
					size = me->search_nb + ALLOC_INCR) & 1))
	    {printf("Bad dynamic allocation\n");goto wrapup;}
    }
 if(om$dimension_of(varray = me->main) <= me->main_nb)
    {
	 if(!(om$vla_set_dimension( 	varray = me->main,
					size = me->main_nb + ALLOC_INCR) & 1))
	    {printf("Bad dynamic allocation\n");goto wrapup;}
    }

sts = vds$give_exp( main_alloc   = me->main_nb, 
		    search_alloc = me->search_nb,
		    main   	 = me->main,
		    search 	 = me->search,
		    nb_lines     = nb_lines,
		    lines        = lines);
if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}


 sts = vds$update_path(	form_ptr = me->form_ptr[MAIN],
			current = &me->current,
		  	main = &me->main[0],
		  	search = &me->search[0],
		  	nb_main = me->main_nb ,
		  	nb_search = me->search_nb );

 if (! (sts & 1))
   {
     printf("VDSpath:failure vds$update_path\n");
     goto wrapup;
   }


if(nb_lines != 0 && lines != NULL) 
 {
    di$free(lines = lines,
            count = nb_lines);
    lines    = NULL;
    nb_lines = 0;
 }
*msg = OM_S_SUCCESS;

End
return OM_S_SUCCESS;

wrapup:

	if(nb_lines != 0 && lines != NULL) 
 	 {
    	    di$free(lines = lines,
            	    count = nb_lines);
    	            lines = NULL;
    	            nb_lines = 0;
 	 }
	*msg = OM_E_ABORT;
        me->ret = MSFAIL;
        End
    	return OM_S_SUCCESS;

}



/*----------------------- instances_to_exp ---------------------------*/
/*  method which create or modify the expressions depending 
 *  on the instances
 */

action instances_to_exp(long *msg;)
/*.instances_to_exp*/
{
struct GRmd_env 	md_env;
char			list_index[3], exp_symb[MY_MAX],us_path[DI_PATH_MAX+30],
			act_dir[DI_PATH_MAX],return_path[DI_PATH_MAX], 
			warn_mess[MY_MAX + 30],out[DI_PATH_MAX],
			expression[MY_MAX];
long			sts;
struct GRid		exp;
int			len,i;
struct GRsymbology	symb;

	SetProc(VDCmdPath.instances_to_exp); Begin
*msg = OM_S_SUCCESS;

/* look for the directory user_path */


sts = vds$init_path(user_path = us_path, md_env = &md_env); 
if ( !(sts&1)) 
 {
	printf("error vds$init_path\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
 }


len = strlen(us_path);

/*| remove all in user_path dir */

sts = vds$remove_user_path();
if(!(sts&1))
   {
	printf("error vds$remove_user_path\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
   }

/*| fill user_path dir with instances */

sts = di$pwd(dirname = act_dir);  
if(sts != DIR_S_SUCCESS)
 {
	printf("error pwd\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
 } 

sts = di$cd(dirname = us_path);  
if(sts != DIR_S_SUCCESS)
  {
        di$report_error( sts = sts);
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }

sts = write_exp(&me->current.main_cst_path, expression);
if(!(sts&1)) {printf("error write_exp\n");*msg =OM_E_ABORT;return OM_S_SUCCESS;}
sts = EXP_text_exp_build( "act_main" ,expression,  
			   md_env.md_id.osnum, &exp.objid);
if(sts != EXP_S_SUCCESS) 
 {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }


sts =write_exp(&me->current.search_cst_path, expression);
if(!(sts&1)) {printf("error write_exp\n");*msg =OM_E_ABORT;return OM_S_SUCCESS;}
sts = EXP_text_exp_build("act_search", expression, 
		          md_env.md_id.osnum, &exp.objid);
if(sts != EXP_S_SUCCESS)
 {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }


sts = EXP_text_exp_build("ref_path",me->current.reference_path, 
 			md_env.md_id.osnum,&exp.objid);
if(!(sts&1))
  {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }


sts = vds$text_to_symb(txt_symb = &me->current.main_cst_path.symbology, 
                       exp_symb = exp_symb);
if(!(sts&1))
  {
	printf("error vds$text_to_symb\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }

sts = EXP_text_exp_build("act_symbol_main",exp_symb,  md_env.md_id.osnum,&exp.objid);
if(!(sts&1))
  {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }

for (i=0;i< me->search_nb ;i=i+1)
 {
   sprintf(list_index,"%d",i);
   strcpy(return_path, "search");  
   strcat(return_path,list_index);
   sts =write_exp(&me->search[i], expression);
   if(!(sts&1)) {
		printf("error write_exp\n");
		*msg =OM_E_ABORT;
        End
		return OM_S_SUCCESS;
   }
   sts = EXP_text_exp_build(return_path, expression, md_env.md_id.osnum,
 			    &exp.objid);
   if(!(sts&1))
    {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
    }

 }
for (i=0;i< me->main_nb ;i=i+1)
 {
   strcpy(return_path,"main");
   sprintf(list_index,"%d",i);
   strcat(return_path,list_index);
   sts = write_exp(&me->main[i], expression);
   if(!(sts&1)) {
		printf("error write_exp\n");
		*msg =OM_E_ABORT;
        End
		return OM_S_SUCCESS;
   }

   sts = EXP_text_exp_build(return_path, expression, md_env.md_id.osnum,
 			    &exp.objid);
   if(!(sts&1))
    {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
    }
   sts = vds$text_to_symb(txt_symb = &me->main[i].symbology, 
			 exp_symb = exp_symb);
   if(!(sts&1))
    {
	printf("error vds$text_to_symb\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
    }

   strcpy(return_path,"symbol_main");
   sprintf(list_index,"%d",i);
   strcat(return_path,list_index);
   sts = EXP_text_exp_build(return_path, exp_symb, md_env.md_id.osnum,&exp.objid);
   if(!(sts&1))
    {
	printf("error EXP_text_exp_build\n");
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
    }

 }
sts = di$cd(dirname = act_dir);  
if(sts != DIR_S_SUCCESS)
  {
        di$report_error( sts = sts);
	*msg =OM_E_ABORT;
        End
    	return OM_S_SUCCESS;
  }

/*|******* cd main_path and set active symb ******/

sts = vds$get_path(     const_flag = MAIN_PATH,
			symbology = &symb);
if (! (sts & 1))
 { 
   printf("error get path\n");
   *msg =OM_E_ABORT;
        End
   return OM_S_SUCCESS;
 }

sts = vds$set_current(current_dir = me->current.main_cst_path.path,
		      path	  = me->current.reference_path,
		      out_path	  = out,
		      symbology   = &symb);
if (! (sts & 1))
 { 
   if(sts == OM_W_WARNING)
    {
        strcpy(warn_mess, "WARNING: can't change current directory");
        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
                       warn_mess,FALSE);
	*msg =OM_W_WARNING;
        End
    	return OM_S_SUCCESS;
      
    }
   else
    {
      printf("error vds$set_current\n");
      *msg = OM_E_ABORT;
        End
      return OM_S_SUCCESS;
    }
 }
sts = di$pwd(dirname = act_dir);
if(sts!= DIR_S_SUCCESS){printf("error pwd\n");*msg = OM_E_ABORT;return OM_S_SUCCESS;}
sts = FIfld_set_text(me->form_ptr[MAIN],ACT_DIR , 0 ,0,act_dir,FALSE);
if (sts != FI_SUCCESS)
     {printf("FIfld_set_text fail \n"); *msg = OM_E_ABORT;return OM_S_SUCCESS;}


/*|update dir form */
vd$dir_update_form();
        End
return OM_S_SUCCESS;

}

/**********************************************************************/
/* form_notification -						      */
/*   Override of CEO method for handling input from new C-based	forms.*/
/**********************************************************************/
action form_notification  

/*.fm_notification*/
{
  IGRchar	                user_in[DI_PATH_MAX],text[DI_PATH_MAX],
  				act_dir[DI_PATH_MAX],symb_name[SYMB_CHAR],
  				file_name[DI_PATH_MAX],
				**search_path,
				out[DI_PATH_MAX],msg_text[DI_PATH_MAX+50],
				auto_name[NAME_MAX];
				
  int 				const_flag,len, named_flag, 
				num_char = DI_PATH_MAX,mode, 
				num_path = MY_PATH_MAX, num_name = NAME_MAX,
				nb_returned, r_pos,
				i,j,sts,type, act_row, act_pos, act_col,
				row=0,col=0,sel_flag=0, list_index, 
				name_index, exist = 0,xpos,ypos,layer,color,
				weight,style,num_rows, state_create,
				state_layer,state_color,state_weight,
				state_style;
  short				short_color;
  long				stat,msg=0;
  double			val;
  struct GRid		        dir;
  struct GRsymbology		symbology;
  struct txt_symb		wrk_symb;

SetProc(VDCmdPath.form_notification ); Begin

  if ( form_ptr == NULL )
   {
     /*| no form_ptr set */
     return( OM_E_INVARG ); 
    }

  status = di$pwd(dirname = act_dir);
  if(status!= DIR_S_SUCCESS){
	printf("error pwd\n");
	me->ret = MSFAIL;
	return OM_S_SUCCESS;
  }

  status = FIfld_set_text(me->form_ptr[MAIN],ACT_DIR , 0 ,0,act_dir,FALSE);
  if (status != FI_SUCCESS)
     {printf("FIfld_set_text fail \n"); me->ret = MSFAIL;return OM_S_SUCCESS;}

 
  status = FIfld_set_text(me->form_ptr[MAIN],ACT_DIR , 0 ,0,act_dir,FALSE);
  if (status != FI_SUCCESS)
     {printf("FIfld_set_text fail \n"); me->ret = MSFAIL;return OM_S_SUCCESS;}


  search_path = NULL;
  dp$erase_hilite(msg=&sts);


  sts = FIfld_get_type( form_ptr, gadget_label, col, &type );
  if(sts == FI_SUCCESS)
    { 
      if ( type == FI_DOUBLE || type == FI_INT )
        {

         sts = FIfld_get_value( form_ptr, gadget_label, row, col, &val, 
				&sel_flag, &r_pos );
         if(sts != FI_SUCCESS)
           {
            printf("error FIfld_get_value\n");
            return OM_S_SUCCESS;
           } 
         }

      else if ( type == FI_ALPHA )	
         {
          sts =FIfld_get_text( form_ptr, gadget_label,  row,   col,
		       	    num_char, text, &sel_flag, &r_pos );
          if(sts != FI_SUCCESS)
           {
            printf("error FIfld_get_text\n");
            return OM_S_SUCCESS;
           }  
          strcpy(user_in,text);
          EXP_strip(text);
          if(strcmp(user_in,text)){
           if(form_ptr == me->form_ptr[MAIN])
                FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
           		"Warning: text is stripped of space char(s)",FALSE);
           else FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
           		"Warning: text is stripped of space char(s)",FALSE);
           FIfld_set_text(form_ptr, gadget_label, row, col,text,FALSE);
          }
         }
       else
         {
           /*|type not defined*/
         }
    }


 if ( form_ptr == me->form_ptr[MAIN])
  {
   switch ( gadget_label )
    {
      case EXIT:

        dp$erase_hilite(msg=&sts);
        me->delete_flag = 1;			
        me->state = _terminate;

                       status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdPath.delete ( 0 ));

	break;

       case ABORT:

        FIbtn_set_auto_pop_up_on( form_ptr, ABORT );

	stat = om$send (msg = message VDCmdPath.exp_to_instances(&msg),
                     	targetid = my_id);
   	if (! (stat & 1) || msg == OM_E_ABORT)
   		    {
      			printf("VDCmdPath:failure sending exp_to_instances\n");
        		FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
				       "fail to restore previous paths",FALSE);
			me->ret = MSFAIL;
                 	as$status(sts = stat, action = RET_STATUS);
    			return OM_S_SUCCESS;
   		     }
        break;


      	case STORE :

		
  	FIbtn_set_auto_pop_up_on( form_ptr, STORE );
	/*|update form */
	
 	stat = vds$update_path(	form_ptr = me->form_ptr[MAIN],
			current = &me->current,
		  	main = &me->main[0],
		  	search = &me->search[0],
		  	nb_main = me->main_nb ,
		  	nb_search = me->search_nb );

 	if (! (stat & 1))
   	{
     		printf("VDCmdPath:failure vds$update_path\n");
		me->ret = MSFAIL;
    		return OM_S_SUCCESS;
   	}
	
	stat = om$send (msg = message VDCmdPath.instances_to_exp(&msg),
                     	targetid = my_id);
   	if (! (stat & 1)|| msg == OM_E_ABORT)
   		    {
      			printf("VDCmdPath:failure sending instances_to_exp\n");
        		FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
				       "fail to store given paths",FALSE);
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
   		     }
   	if ( msg == OM_W_WARNING)
   		    {
      			printf("WARNING: path directories are not created, cannot change the current directory\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
   		     }

  	status = di$pwd(dirname = act_dir);
  	if(status!= DIR_S_SUCCESS)
		{printf("error pwd\n");me->ret = MSFAIL;return OM_S_SUCCESS;}
        strcpy(msg_text,"current dir is now : ");
        strcat(msg_text,act_dir);

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			msg_text,FALSE);
        break;
      	 


      	case SAVE :

	stat = om$send (msg = message VDCmdPath.instances_to_exp(&msg),
                     	targetid = my_id);
   	if (! (stat & 1) || msg == OM_E_ABORT)
   		    {
      			printf("VDCmdPath:failure sending instances_to_exp\n");
        		FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
				       "fail to store given paths",FALSE);
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
   		     }
   	if ( msg == OM_W_WARNING)
   		    {
      			printf("WARNING: path directories are not created\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
   		     }
        me->delete_flag = 1;			
        status = om$send( targetid = my_id,
			  mode   = OM_e_wrt_message,
			  msg    = message VDCmdPath.delete ( 0 ));
        me->state = _terminate;
        return( OM_I_STOP_SENDING );
      	 

       case SET_CURRENT:

        FIg_set_state_on(form_ptr,SET_CURRENT);
        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
		       "change active dir and symbology",FALSE);
        sts = vds$give_symb(txt_symb = &me->current.main_cst_path.symbology,
			    symbology = &symbology);

	sts = vds$set_current(current_dir = me->current.main_cst_path.path,
		      	      path	  = me->current.reference_path,
		      	      out_path	  = out,
		      	      symbology   = &symbology);
        if (! (sts & 1))
         { 
          FIg_set_state_off(form_ptr,SET_CURRENT);
           if(sts == OM_W_WARNING)
            {
                FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
                               "WARNING: can't change current directory",FALSE);
		break;      
            }
           else
            {
              FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
                               "ERROR: can't change current directory",FALSE);
              printf("error vds$set_current\n");
	      me->ret = MSFAIL;
              return OM_S_SUCCESS;
            }
         }
  	status = di$pwd(dirname = act_dir);
  	if(status!= DIR_S_SUCCESS)
		{printf("error pwd\n");me->ret = MSFAIL;return OM_S_SUCCESS;}
        FIg_set_state_off(form_ptr,SET_CURRENT);
        sts = FIfld_set_text(me->form_ptr[MAIN],ACT_DIR , 0 ,0,act_dir,FALSE);
        if (sts != FI_SUCCESS)
          {
           printf("FIfld_set_text fail \n"); 
           me->ret = MSFAIL;
           return OM_S_SUCCESS;
          }

        sts = vds$set_act_path(path_name  = me->current.main_cst_path.name, 
                               const_flag = MAIN_PATH);
        if(!(sts&1))
         {
           FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
                               "ERROR: can't set active path",FALSE);
    	   printf("error vds$set_act_path\n");
	   me->ret = MSFAIL;
	   return OM_S_SUCCESS;
         }
        sts = vds$set_act_path(path_name  = me->current.search_cst_path.name, 
                               const_flag = SEARCH_PATH,
                               ret_path   = out);
        if(!(sts&1))
         {
           FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
                               "ERROR: can't set active search path",FALSE);
    	   printf("error vds$set_act_path\n");
	   me->ret = MSFAIL;
	   return OM_S_SUCCESS;
         }
        strcpy(msg_text,"current dir is now : ");
        strcat(msg_text,act_dir);

	/*|update dir form */
	vd$dir_update_form();

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			msg_text,FALSE);
        strcpy(msg_text,"current search path is now : ");
        strcat(msg_text,out);

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			msg_text,FALSE);
        break;


       case REFERENCE:
	
        if(!(VDSverify_ref(text, file_name) & 1 ))
           {
	    FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			"WARNING: reference path was not valid",FALSE);
	    if(strcmp(file_name,"NOT_FOUND") == 0) strcpy(file_name,act_dir);
            strcpy(text,file_name);
	    FIfld_set_text(form_ptr, REFERENCE, 0, 0,text,FALSE);
    	    FIfld_set_active_char(form_ptr,REFERENCE , 0, 0, 0);
           }
	strcpy(me->current.reference_path,text);

	break;
       
       case MAIN_PATH_FIELD:


        FIfld_set_text(me->form_ptr[MAIN], MAIN_PATH_FIELD, 0, 0,
                         me->current.main_cst_path.path ,FALSE);
        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "disable field, select path by name",FALSE);
	break;

       case MAIN_NAME_FIELD:


        len = strlen(text);
 	if(len >=NAME_MAX)
          {
            strcpy(msg_text,"name too long");
	    FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			   msg_text,FALSE);
	    FIfld_set_text(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0,
			   me->current.main_cst_path.name,FALSE);
	    FIfld_set_active_char(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0, 0);
	    FIfld_set_text(me->form_ptr[MAIN], MAIN_PATH_FIELD, 0, 0,
			   me->current.main_cst_path.path,FALSE);
            break;
          }
	if(text[0] != '\0')
         {
	   stat =vds$name_in_list( in_name   = text, 
				   out_index = &list_index, 
				   list      = &me->main[0], 
				   nb_elts   = me->main_nb,
				   found     = &exist);

     	   if (! (stat & 1))
	    {
	      printf("error vds$name_in_list\n");
	      me->ret = MSFAIL;
    	      return OM_S_SUCCESS;
	    }
           if(exist)
            {
             status = FIfld_set_text(me->form_ptr[MAIN], MAIN_PATH_FIELD, 0, 0,
                         me->main[list_index].path ,FALSE);
	     if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
             me->current.main_cst_path = me->main[list_index];
            }
           else
            {
             status = FIfld_set_text(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0,
                         me->current.main_cst_path.name ,FALSE);
    	     FIfld_set_active_char(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0, 0);
             status = FIfld_set_text(me->form_ptr[MAIN], MAIN_PATH_FIELD, 0, 0,
                         me->current.main_cst_path.path ,FALSE);
             status = FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "name must be defined in list",FALSE);
	     if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
            }
          }
	else 
         {
             status = FIfld_set_text(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0,
                         me->current.main_cst_path.name ,FALSE);
    	     FIfld_set_active_char(me->form_ptr[MAIN], MAIN_NAME_FIELD, 0, 0, 0);
             status = FIfld_set_text(me->form_ptr[MAIN], MAIN_PATH_FIELD, 0, 0,
                         me->current.main_cst_path.path ,FALSE);
             status = FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "the name must be already defined",FALSE);
	     if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
	  
         }
	break;

       
       case SEARCH_PATH_FIELD:


        FIfld_set_text(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0,
                         me->current.search_cst_path.path ,FALSE);
        status = FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "disable field, select path by name",FALSE);
	if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
	break;

       case SEARCH_NAME_FIELD:


        len = strlen(text);
 	if(len >=NAME_MAX)
          {
            strcpy(msg_text,"name too long");
	    FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			   msg_text,FALSE);
	    FIfld_set_text(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0,
			   me->current.search_cst_path.name,FALSE);
	    FIfld_set_active_char(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0, 0);
	    FIfld_set_text(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0,
			   me->current.search_cst_path.path,FALSE);
            break;
          }
	if(text[0] != '\0')
         {
	  stat =vds$name_in_list(	in_name   = text, 
					out_index = &list_index, 
					list      = &me->search[0], 
					nb_elts   = me->search_nb,
					found     = &exist);

     	  if (! (stat & 1))
	   {
	     printf("error vds$name_in_list\n");
	     me->ret = MSFAIL;
    	     return OM_S_SUCCESS;
	   }
          if(exist)
           {
            status = FIfld_set_text(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0,
                         me->search[list_index].path ,FALSE);
	    if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
    	    FIfld_set_active_char(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0, 0);
            me->current.search_cst_path = me->search[list_index];
           }
          else
           {
            status = FIfld_set_text(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0,
                         me->current.search_cst_path.name ,FALSE);
    	    FIfld_set_active_char(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0, 0);
            status = FIfld_set_text(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0,
                         me->current.search_cst_path.path ,FALSE);
            status = FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "name must be defined in list",FALSE);
	    if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
           }
         }
	else 
         {
            status = FIfld_set_text(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0,
                         me->current.search_cst_path.name ,FALSE);
    	    FIfld_set_active_char(me->form_ptr[MAIN], SEARCH_NAME_FIELD, 0, 0, 0);
            status = FIfld_set_text(me->form_ptr[MAIN], SEARCH_PATH_FIELD, 0, 0,
                         me->current.search_cst_path.path ,FALSE);
            status = FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, 
                         "the name must be already defined",FALSE);
	    if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
         }
	break;

       case MAIN_BUTTON:

        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIg_disable(form_ptr,SEARCH_BUTTON);
	FIg_disable(form_ptr,READ_BUTTON);
	FIg_disable(form_ptr,WRITE_BUTTON);
	FIg_disable(form_ptr,SAVE);
	FIg_disable(form_ptr,STORE);
	FIg_disable(form_ptr,ABORT);
        FIg_set_state_on(form_ptr,MAIN_BUTTON);
	me->main_flag = 1;

	/* added for TR17980084 */
	if ( me->form_ptr[LIST] != NULL ) _FREE( me->form_ptr[LIST] );
	me->form_ptr[LIST] = NULL;

//        if ( me->form_ptr[LIST] == NULL )
//         {
          me->form_name[LIST] = LIST_FORM_NAME ;
          status = 0;
          status = FIf_new ( LIST,
                           me->form_name[LIST],
                           COB_FI_form_notification,
                           &me->form_ptr[LIST] );

          if ( status )
           {
            me->form_ptr[LIST] = NULL;
            me->state = _terminate;
            me->delete_flag = 1;
            return ( OM_I_STOP_SENDING );
           }
          else
           {
            /*** tell the form which cmd it's talking to ***/
            status = FIf_set_cmd_oid_os (  me->form_ptr[LIST],
                                         my_id, OM_Gw_current_OS );
            if ( status )
             {
              me->state = _terminate;
              me->delete_flag = 1;
              return ( OM_I_STOP_SENDING );
             }
            status = FIf_set_initial_notification_routine ( me->form_ptr[LIST],
                                COB_FI_initial_form_notification );
            if ( status )
             {
              me->state = _terminate;
              me->delete_flag = 1;
              return ( OM_I_STOP_SENDING );
             }
           }
//         } /* LIST is NULL */

	/* init de la liste des path et de la symbology */

	 if(om$dimension_of(varray = me->intermediate) <= me->main_nb)
            {
	      if(!(om$vla_set_dimension(varray = me->intermediate,
					size = me->main_nb + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
		 for(i=me->nb_intermediate;i<me->main_nb+ALLOC_INCR;i++)
		     VDSinit_symb(&me->intermediate[i]);
            }
        for(i=0; i<me->main_nb; i++) {
        	VDSinit_symb(&me->intermediate[i]);
        	me->intermediate[i] = me->main[i];
        }
        me->nb_intermediate = me->main_nb;
        me->int_name_index[0] = me->main_name_index;

        if ( me->form_ptr[LIST] != NULL )	
              {
                stat = vds$init_list_form(form_ptr = me->form_ptr[LIST]);
     		if (! (stat & 1))
		 {
			printf("error vds$init_list_form\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		 }

                FIg_set_state_off(me->form_ptr[LIST],DEL_BUTTON);
        	FIf_get_location(me->form_ptr[MAIN], &xpos, &ypos);

		xpos = 1;
		ypos = 210;
                FIf_set_rel_location(me->form_ptr[LIST], xpos, ypos,me->form_ptr[MAIN]);
                FIf_get_location(me->form_ptr[LIST], &xpos, &ypos);

		for(i=0;i<me->nb_intermediate; i++)
                 {
	           status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, i, 
					1, me->intermediate[i].path,FALSE);
	           status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, i, 
					0, me->intermediate[i].name,FALSE);
	  	   if(status != FI_SUCCESS)
                    {printf("error FIfld_fld_set_text: %d\n",status);break;}
                 }
		status = FImcf_get_attr(me->form_ptr[LIST], LIST_FIELD, 
				        &me->select_attr);
	  	if(status != FI_SUCCESS)
                    {printf("error FImcf_get_attr: %d\n",status);break;}

		me->select_attr = me->select_attr | FI_ROW_SELECT;
             	mode = FI_INSERT;
                status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 0,mode);
                status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 1,mode);
	  	if(status != FI_SUCCESS)
                    {printf("error FIfld_set_mode: %d\n",status);break;}

        	me->select_flag    = 0;
		me->symbology_flag = 0;
                me->del_row        = 0;

              	FIg_set_state_off(me->form_ptr[LIST],CREATE_TOG);
		strcpy(me->select_act_path.name,"nothing");
	        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			    "Warning: paths will not be created",FALSE);
	        FIg_set_state_off(me->form_ptr[LIST], EXIT);
                FIg_set_state_off(me->form_ptr[LIST], SAVE);
		FIf_display( me->form_ptr[LIST] );
	       }
        break;


       case SEARCH_BUTTON:

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIg_disable(form_ptr,MAIN_BUTTON);
	FIg_disable(form_ptr,READ_BUTTON);
	FIg_disable(form_ptr,WRITE_BUTTON);
	FIg_disable(form_ptr,SAVE);
	FIg_disable(form_ptr,STORE);
	FIg_disable(form_ptr,ABORT);
        FIg_set_state_on(me->form_ptr[MAIN],SEARCH_BUTTON);
        me->search_flag = 1;

        /* added for TR17980084 */
        if ( me->form_ptr[LIST] != NULL ) _FREE( me->form_ptr[LIST] );
        me->form_ptr[LIST] = NULL;
	
//        if ( me->form_ptr[LIST] == NULL )
//         {

          me->form_name[LIST] = LIST_FORM_NAME ;
          status = 0;

          status = FIf_new ( LIST,
                           me->form_name[LIST],
                           COB_FI_form_notification,
                           &me->form_ptr[LIST] );

          if ( status )
           {

            me->form_ptr[LIST] = NULL;
            me->state = _terminate;
            me->delete_flag = 1;
            return ( OM_I_STOP_SENDING );
           }
          else
           {

            /*** tell the form which cmd it's talking to ***/
            status = FIf_set_cmd_oid_os (  me->form_ptr[LIST],
                                         my_id, OM_Gw_current_OS );
            if ( status )
             {

              me->state = _terminate;
              me->delete_flag = 1;
              return ( OM_I_STOP_SENDING );
             }
            status = FIf_set_initial_notification_routine ( me->form_ptr[LIST],
                                COB_FI_initial_form_notification );
            if ( status )
             {

              me->state = _terminate;
              me->delete_flag = 1;
              return ( OM_I_STOP_SENDING );
             }
           }
//         } /* LIST is NULL */

	/* init de la liste des search path */

	/*|alloc of the intermediate structure */
	 if(om$dimension_of(varray = me->intermediate) <= me->search_nb)
            {
	      if(!(om$vla_set_dimension(varray = me->intermediate,
					size = me->search_nb + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
		 for(i=me->nb_intermediate;i<me->search_nb+ALLOC_INCR;i++)
		     VDSinit_symb(&me->intermediate[i]);
            }
        for(i=0; i<me->search_nb; i++) {
        	VDSinit_symb(&me->intermediate[i]);
        	me->intermediate[i] = me->search[i];
        }
        me->nb_intermediate = me->search_nb;
        me->int_name_index[1] = me->search_name_index;

        if ( me->form_ptr[LIST] != NULL )	
              {
                stat = vds$init_list_form(form_ptr = me->form_ptr[LIST]);
     		if (! (stat & 1))
		 {
			printf("error vds$init_list_form\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		 }

                FIg_set_state_off(me->form_ptr[LIST],DEL_BUTTON);
		FIg_disable(me->form_ptr[LIST],SYMB_BUTTON);
        	FIf_get_location(me->form_ptr[MAIN], &xpos, &ypos);

		xpos = 1;
		ypos = 210;
                FIf_set_rel_location(me->form_ptr[LIST], xpos, ypos,me->form_ptr[MAIN]);
                FIf_get_location(me->form_ptr[LIST], &xpos, &ypos);

		for(i=0;i<me->nb_intermediate; i++)
                 {
	           status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, i,1, 
				  me->intermediate[i].path,FALSE);
	           status = FIfld_set_text(me->form_ptr[LIST], LIST_FIELD, i,0, 
				  me->intermediate[i].name,FALSE);
	  	   if(status != FI_SUCCESS)
                    {printf("error FIfld_set_text: %d\n",status);break;}
                 }

		status = FImcf_get_attr(me->form_ptr[LIST], LIST_FIELD, 
				  &me->select_attr);
	  	if(status != FI_SUCCESS)
                    {printf("error FImcf_get_attr: %d\n",status);break;}
		me->select_attr = me->select_attr | FI_ROW_SELECT;
             	mode = FI_INSERT;
                status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 0,mode);
                status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 1,mode);
	  	if(status != FI_SUCCESS)
                    {printf("error FIfld_set_mode: %d\n",status);break;}

        	me->select_flag    = 0;
		me->symbology_flag = 0;
                me->del_row        = 0;
	        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
			"separated char for search paths is ','",FALSE);
              	FIg_set_state_off(me->form_ptr[LIST],CREATE_TOG);
		strcpy(me->select_act_path.name,"nothing");
	        FIg_set_state_off(me->form_ptr[LIST], EXIT);
                FIg_set_state_off(me->form_ptr[LIST], SAVE);
			
		FIf_display( me->form_ptr[LIST] );
	       }
        break;

       }
  }
  else if ( form_ptr == me->form_ptr[SUB])
  {
     switch ( gadget_label )
      {

       case EXIT:

	    FIg_enable(me->form_ptr[LIST],EXIT);
	    FIg_enable(me->form_ptr[LIST],SAVE);
            FIg_enable(me->form_ptr[LIST],DEL_BUTTON);
	    FIg_enable(me->form_ptr[LIST],LOAD_BUTTON);
            FIg_enable(me->form_ptr[LIST],SELECT_BUTTON);
	    me->symbology_flag = 0;
            dp$erase_hilite(msg=&sts);

            /*|erase symb form */

            if ( me->form_ptr[SUB] != NULL )	
	    status = FIf_erase( me->form_ptr[SUB] );

	      if ( ! status )
	       {
	         /*| Enable & Set button to off */

                 FIg_set_state_off( me->form_ptr[LIST], SYMB_BUTTON);
                 FIg_set_notify_on( me->form_ptr[LIST], SYMB_BUTTON);

	       }
	      else
	       {
	         /*| got bad return from erase_form */
                 as$status( action = RET_STATUS );
	       }
             FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			    "",FALSE);

             mode = FI_INSERT;
             status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 0, mode);
             status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 1, mode);
	     if(status != FI_SUCCESS)
                    {printf("error FIfld_set_mode: %d\n",status);break;}
             FIg_set_state_off(me->form_ptr[LIST], EXIT);
             FIg_set_state_off(me->form_ptr[LIST], SAVE);
	     FIf_display( me->form_ptr[LIST] );
             break;
             
	case ABORT:
   	     stat = vds$set_symbology(symb_ptr = me->form_ptr[SUB],
				      text_symb= &me->intermediate[me->select_index].symbology);
     	     if (! (stat & 1))
	     {
		    printf("error vds$set_symbology\n");
		    me->ret = MSFAIL;
    		    return OM_S_SUCCESS;
	     }
	    break;

       case STORE:
       case SAVE:

	    FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, "",FALSE);
            FIg_get_state(form_ptr,LAYER_TOG,&state_layer);

            if(state_layer == 1)
                FIfld_get_text(form_ptr, LAYER_FIELD, row, col, SYMB_VAL,
				me->intermediate[me->select_index].symbology.layer  ,
                                &sel_flag, &r_pos);
            else
              strcpy(me->intermediate[me->select_index].symbology.layer, "act");
            FIfld_get_text(form_ptr, LAYER_NAME, row, col, LAYER_CHAR,
		    me->intermediate[me->select_index].symbology.layer_name ,
                                &sel_flag, &r_pos);
            EXP_strip(me->intermediate[me->select_index].symbology.layer_name);
            EXP_strip(me->intermediate[me->select_index].symbology.layer);

            FIg_get_state(form_ptr,COLOR_TOG,&state_color);

            if(state_color == 1)
	      {
                FIfld_get_text(form_ptr, COLOR_FIELD, row, col, SYMB_CHAR, symb_name,
                                &sel_flag, &r_pos);
                EXP_strip(symb_name);
	        if(isalpha(symb_name[0]))
		 {
		   if( !(ige$get_color_from_name(name = symb_name,color= &short_color)))
		    {
		      printf("ERROR:color name doesn't exist \n");
		      break;
		    }
                   strcpy(me->intermediate[me->select_index].symbology.color, 
			  symb_name);
		 }
	       else if(isdigit(symb_name[0]))
		{ 
		   sscanf(symb_name,"%d", &color);

		   short_color = (short)color;
		   if( !(ige$get_name_from_color(name = symb_name,color = short_color)))
		    {
		      /*|color has no name */
		      sprintf(me->intermediate[me->select_index].symbology.color,
			      "%d",color);
		    }
		   else 
		    {
		     strcpy(me->intermediate[me->select_index].symbology.color,
			    symb_name);         
		    }
                }

               }
            else
              strcpy(me->intermediate[me->select_index].symbology.color, "act");
              EXP_strip(me->intermediate[me->select_index].symbology.color);

            FIg_get_state(form_ptr,WEIGHT_TOG,&state_weight);
            if(state_weight == 1)
                FIfld_get_text(form_ptr, WEIGHT_FIELD, row, col,  SYMB_VAL,
				me->intermediate[me->select_index].symbology.weight,
                                &sel_flag, &r_pos);
	    else
              strcpy(me->intermediate[me->select_index].symbology.weight, "act");
            EXP_strip(me->intermediate[me->select_index].symbology.weight);

            FIg_get_state(form_ptr,STYLE_TOG,&state_style);
            if(state_style == 1)
                FIfld_get_text(form_ptr, STYLE_FIELD, row, col, SYMB_VAL,
				me->intermediate[me->select_index].symbology.style,
                                &sel_flag, &r_pos);
	    else
              strcpy(me->intermediate[me->select_index].symbology.style, "act");
            EXP_strip(me->intermediate[me->select_index].symbology.style);

	    if(gadget_label == SAVE){
	    		me->symbology_flag = 0;
	    		FIg_enable(me->form_ptr[LIST],EXIT);
            		FIg_enable(me->form_ptr[LIST],DEL_BUTTON);
	    		FIg_enable(me->form_ptr[LIST],SAVE);
	    		FIg_enable(me->form_ptr[LIST],LOAD_BUTTON);
            		FIg_enable(me->form_ptr[LIST],SELECT_BUTTON);
	   		dp$erase_hilite(msg=&sts);

            		/*|erase symb form */

            		if ( me->form_ptr[SUB] != NULL )	
	    			status = FIf_erase( me->form_ptr[SUB] );

	      		if ( ! status )
	       		{
	         		/*| Enable & Set button to off */
                 		FIg_set_state_off( me->form_ptr[LIST], SYMB_BUTTON);
                 		FIg_set_notify_on( me->form_ptr[LIST], SYMB_BUTTON);

	       		}
	      		else
	       		{
	         		/*| got bad return from erase_form */
                 		as$status( action = RET_STATUS );
	       		}
             		mode = FI_INSERT;
             		status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 0, mode);
             		status = FIfld_set_mode(me->form_ptr[LIST], LIST_FIELD, 1, mode);
	     		if(status != FI_SUCCESS)
                    		{printf("error FIfld_set_mode: %d\n",status);break;}
          	         FIg_set_state_off(me->form_ptr[LIST], EXIT);
          	         FIg_set_state_off(me->form_ptr[LIST], SAVE);
	    		 FIf_display( me->form_ptr[LIST] );
	     }
             break;

       case LAYER_FIELD:

	      if(isdigit(text[0])) sscanf(text,"%d",&layer);
	      else layer = GR_LO_LAYER - 1;

              FIg_set_state_on(form_ptr,LAYER_TOG);

              if(layer < GR_LO_LAYER || layer > GR_HI_LAYER) 
                  {
                    FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			           "Invalid Layer",FALSE);
		    stat = vds$get_active_symb(symbology = &symbology); 
     		    if (! (stat & 1))
		     { 
			printf("error get_active_symb\n");
		  	me->ret = MSFAIL;
    		  	return OM_S_SUCCESS;
		     }
                    layer = (int)symbology.level;
		    sprintf(text,"%d",layer);
                    FIfld_set_text(form_ptr, LAYER_FIELD, row, col,
				    text,FALSE);
	       	    FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	                           "Layer names must be separated by ':'",0);
		  }
               break;

       case LAYER_NAME:

	       FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       "Layer names must be separated by ':'",0);

               if(LAYER_CHAR < strlen(text) ){
	       		FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 
	       		0, "Warning: layer will be truncated (50 char)",0);
               		strncpy(text,text,SYMB_CHAR);
               		text[SYMB_CHAR] = '\0';
                        FIfld_set_text(form_ptr, LAYER_NAME, row, col,
				    text,FALSE);
    	    	        FIfld_set_active_char(form_ptr, LAYER_NAME, 0, 0, 0);
               }
                FIg_get_state(form_ptr,LAYER_TOG,&state_layer);

	        if(state_layer == 0)
                 {
	      	   FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names cannot be defined on active layer",0);
                   FIg_set_state_on(form_ptr,LAYER_TOG);
		 }	       
               break;
       case COLOR_FIELD:

	       FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
               FIg_set_state_on(form_ptr,COLOR_TOG);

               if(SYMB_CHAR < strlen(text) ){
	       		FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 
	       		0, "Warning: color will be truncated (30 char)",0);
               		strncpy(text,text,SYMB_CHAR);
               		text[SYMB_CHAR] = '\0';
               }
	       if(isalpha(text[0]))
		 {
		   /*|color by name */
		   if( !(ige$get_color_from_name(name = text,color = &short_color)))
		    {
		      /*|ERROR: not a valid color name */
		      short_color = -1;
		    }
		 }
	       else if(isdigit(text[0]))
		{ 
		   sscanf(text,"%d",&color);
		   short_color = (short)color;
		   if( !(ige$get_name_from_color(name = text,color = short_color)))
		    {
		      /*|color has no name */
		    }
		   else 
		    {
                        FIfld_set_text(form_ptr, COLOR_FIELD, row, col,
			                text,sel_flag);
    	    	        FIfld_set_active_char(form_ptr, COLOR_FIELD, 0, 0, 0);
       		    }
                }
	       else short_color = - 1;

		if(short_color >= 512 || short_color <= 0)
                   {
                        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			  "Invalid Color",FALSE);
		        stat = vds$get_active_symb(symbology = &symbology); 
     		        if (! (stat & 1))
			 { 
			   printf("error get_active_symb\n");
		  	   me->ret = MSFAIL;
    		  	   return OM_S_SUCCESS;
			 }
                        short_color = (short)symbology.display_attr.color;
		   	if( !(ige$get_name_from_color(name = text,color = short_color)))
		    	 {
		           /*|act color has no name */
		           sprintf(text,"%d",short_color);
		    	 }
                        FIfld_set_text(form_ptr, COLOR_FIELD, row, col,
			                text,sel_flag);
    	    	        FIfld_set_active_char(form_ptr, COLOR_FIELD, 0, 0, 0);
		   }
               break;

       case WEIGHT_FIELD:

	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
              FIg_set_state_on(form_ptr,WEIGHT_TOG);
	      if(isdigit(text[0])) sscanf(text,"%d",&weight);
	      else weight = GR_LO_WEIGHT - 1;


              /* verifier la valeur de val */
              if(weight < GR_LO_WEIGHT || weight > GR_HI_WEIGHT) 
                 {
                    FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			           "Invalid Weight",FALSE);
		    stat = vds$get_active_symb(symbology = &symbology); 
     		    if (! (stat & 1))
			 { 
			   printf("error get_active_symb\n");
		  	   me->ret = MSFAIL;
    		  	   return OM_S_SUCCESS;
			 }
	             weight = (int)symbology.display_attr.weight;
		    sprintf(text,"%d",weight);
                    FIfld_set_text(form_ptr, WEIGHT_FIELD, row, col,
			        text,sel_flag);
                  }
               break;

       case STYLE_FIELD:
	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
              FIg_set_state_on(form_ptr,STYLE_TOG);
	      if(isdigit(text[0])) sscanf(text,"%d",&style);
	      else style = GR_LO_STYLE - 1;


               /* verifier la valeur de val */
               if(style < GR_LO_STYLE || style > GR_HI_STYLE) 
                   {
                      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			             "Invalid Style",FALSE);
		      stat = vds$get_active_symb(symbology = &symbology); 
     		      if (! (stat & 1))
			 { 
			   printf("error get_active_symb\n");
		  	   me->ret = MSFAIL;
    		  	   return OM_S_SUCCESS;
			 }
	              style = (int)symbology.display_attr.style;
		      sprintf(text,"%d",style);
                      FIfld_set_text(form_ptr, STYLE_FIELD, row, col,
			          text,sel_flag);
                   }
               break;

       case COLOR_TOG:

	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
               FIg_get_state(form_ptr,COLOR_TOG,&state_color);

	       if(state_color == 0)
                {
	          stat = vds$get_active_symb(symbology = &symbology); 
     	          if (! (stat & 1))
			{ 
			  printf("error get_active_symb\n");
		  	  me->ret = MSFAIL;
    		  	  return OM_S_SUCCESS;
			}

		   sprintf(text,"%d",symbology.display_attr.color);
                   FIfld_set_text(form_ptr, COLOR_FIELD, row, col,
			         text,sel_flag);
    	    	   FIfld_set_active_char(form_ptr, COLOR_FIELD, 0, 0, 0);
                }

               break;

       case LAYER_TOG:

                FIg_get_state(form_ptr,LAYER_TOG,&state_layer);
	        if(state_layer == 0)
                {
		  stat = vds$get_active_symb(symbology = &symbology); 
     		  if (! (stat & 1))
			{ 
			  printf("error get_active_symb\n");
		  	  me->ret = MSFAIL;
    		  	  return OM_S_SUCCESS;
			}
		   sprintf(text,"%d",symbology.level);
                   FIfld_set_text(form_ptr, LAYER_FIELD, row, col,
			         text,sel_flag);
                   FIfld_set_text(form_ptr, LAYER_NAME, row, col,
			         "",sel_flag);
    	    	   FIfld_set_active_char(form_ptr, LAYER_NAME, 0, 0, 0);
	      	   FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names cannot be defined on active layer",0);
                }
              break;

       case WEIGHT_TOG:
	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
                FIg_get_state(form_ptr,WEIGHT_TOG,&state_weight);
	        if(state_weight == 0)
                {
		  stat = vds$get_active_symb(symbology = &symbology); 
     		  if (! (stat & 1))
			{ 
			  printf("error get_active_symb\n");
		  	  me->ret = MSFAIL;
    		  	  return OM_S_SUCCESS;
			}
		   sprintf(text,"%d",symbology.display_attr.weight);
                   FIfld_set_text(form_ptr, WEIGHT_FIELD, row, col,
			         text,sel_flag);

                }
              break;

       case STYLE_TOG:
	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);
                FIg_get_state(form_ptr,STYLE_TOG,&state_style);
	        if(state_style == 0)
                {
		  stat = vds$get_active_symb(symbology = &symbology); 
     		  if (! (stat & 1))
			{ printf("error get_active_symb\n");
		  	  me->ret = MSFAIL;
    		  	  return OM_S_SUCCESS;
			}
		   sprintf(text,"%d",symbology.display_attr.style);
                   FIfld_set_text(form_ptr, STYLE_FIELD, row, col,
			         text,sel_flag);
                }

              break;


       default:
            	break;


    }
      /*| symbology form */
  }
  else if ( form_ptr == me->form_ptr[LIST])
  {

   if(me->search_flag) const_flag = SEARCH_PATH;
   else		       const_flag = MAIN_PATH;

     switch ( gadget_label )
      {
      case EXIT:

        me->select_flag    = 0;
	me->symbology_flag = 0;
        me->del_row        = 0;
        FIg_enable( me->form_ptr[LIST],SYMB_BUTTON);
        FIg_enable( me->form_ptr[LIST],DEL_BUTTON);
        FIg_enable( me->form_ptr[MAIN],MAIN_BUTTON);
        FIg_enable( me->form_ptr[MAIN],SEARCH_BUTTON);
	FIg_enable( me->form_ptr[MAIN],READ_BUTTON);
	FIg_enable( me->form_ptr[MAIN],WRITE_BUTTON);
	FIg_enable( me->form_ptr[MAIN],SAVE);
	FIg_enable( me->form_ptr[MAIN],STORE);
	FIg_enable( me->form_ptr[MAIN],ABORT);
        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,"",FALSE);
        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,"",FALSE);
        if ( me->form_ptr[LIST] != NULL )	
	status = FIf_erase( me->form_ptr[LIST] );
	if ( ! status )
	  {
	    /*| Enable & Set button to off */
                FIg_set_state_off( me->form_ptr[MAIN], MAIN_BUTTON);
                FIg_set_notify_on( me->form_ptr[MAIN], MAIN_BUTTON);
                FIg_set_state_off( me->form_ptr[MAIN], SEARCH_BUTTON);
                FIg_set_notify_on( me->form_ptr[MAIN], SEARCH_BUTTON);
	   }
	 else
	   {
	     /*| got bad return from erase_form */
             as$status( action = RET_STATUS );
	   }
        /*|reinit flag */
      	me->main_flag = 0; 
      	me->search_flag = 0; 
        /*| end reinit flag */
	break;

      	case SAVE :

		
        me->select_flag    = 0;
	me->symbology_flag = 0;
        me->del_row        = 0;

	/*| write in instances and update paths form */

        FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,"",FALSE);
        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,"",FALSE);
        FIg_enable( me->form_ptr[LIST],DEL_BUTTON);
        FIg_enable( me->form_ptr[MAIN],MAIN_BUTTON);
        FIg_enable( me->form_ptr[MAIN],SEARCH_BUTTON);
        FIg_enable( me->form_ptr[LIST],SYMB_BUTTON);
	FIg_enable( me->form_ptr[MAIN],READ_BUTTON);
	FIg_enable( me->form_ptr[MAIN],WRITE_BUTTON);
	FIg_enable( me->form_ptr[MAIN],SAVE);
	FIg_enable( me->form_ptr[MAIN],STORE);
	FIg_enable( me->form_ptr[MAIN],ABORT);
        status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
        me->nb_intermediate = num_rows;
        if(me->nb_intermediate == 0 || me->intermediate[0].path[0] == '\0'||
                                         me->intermediate[0].name[0] == '\0')
         {
	   /*|no path in list, add the current path */
	   me->nb_intermediate = 1;
	   if(om$dimension_of(varray = me->intermediate) < 1)
            {
	      /*|realloc intermediate */
	      if(!(om$vla_set_dimension(varray = me->intermediate,
					size = me->nb_intermediate ) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
            }
	 VDSinit_symb(&me->intermediate[0]);
         if(me->main_flag) me->intermediate[0] = me->current.main_cst_path;
         else if(me->search_flag) me->intermediate[0] = me->current.search_cst_path;
                      
         }
         if(me->main_flag)
           {
	     if(om$dimension_of(varray = me->main) <= me->nb_intermediate)
              {
	      if(!(om$vla_set_dimension(varray = me->main,
					size = me->nb_intermediate + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
              }
             me->main_nb = 0;
             for(i=0;i<me->nb_intermediate;i++) 
	      {
                if(me->intermediate[i].name[0] == '\0' ||   
					me->intermediate[i].path[0] == '\0')
                  {
		    /*|no path given */
		    continue;
                  }
		me->main[me->main_nb] = me->intermediate[i];

		/* update active symbology if it changes */

		if(strcmp(me->main[me->main_nb].name,me->current.main_cst_path.name) == 0)
		   me->current.main_cst_path = me->main[me->main_nb];
		me->main_nb = me->main_nb + 1;		
               }

             if(strcmp(me->select_act_path.name,"nothing"))
		me->current.main_cst_path = me->select_act_path;
	
	     /*|get state of CREATE_TOG */

             FIg_get_state(form_ptr,CREATE_TOG,&state_create);
             if(state_create)
              {
               /*| creation of path */
  		for(i=0;i<me->main_nb;i=i+1)
    		 {
      			sts = vds$out_path(in_path  =  me->main[i].path,
			 		ref_path =  me->current.reference_path,
			 		out_path =  out);    
      			if ( !(sts&1)) 
 			 {
	  			printf("error vds$out_path\n");
	  			me->ret = MSFAIL;
    	  			return OM_S_SUCCESS;
 			 }
      			sts = di$translate(objname = out,
			 		p_objid = &dir.objid,
			 		p_osnum = &dir.osnum);
      			if(sts != DIR_S_SUCCESS)
       			 {
         			sts = VDScreate_path(out);
         			if(!(sts&1))
	  			 {
				   printf("ERROR in VDScreate_path\n");
				   me->ret = MSFAIL;
				   return OM_S_SUCCESS;
				 }
       			 }

    		}/*boucle on paths */

    		/*|update dir form */
    		vd$dir_update_form();
              }

	      /*|create buffer of layer names and add_name_to_lvldir */
	      status = VDSadd_layer_def(&msg, me->main_nb, me->main);
	      if(!(status&msg&1)){
			      printf("error VDSadd_layer_def\n");
			      me->ret = MSFAIL;
    			      return OM_S_SUCCESS;
	      }

           }
         else if(me->search_flag)
           {
	     if(om$dimension_of(varray = me->search) <= me->nb_intermediate)
              {
	      if(!(om$vla_set_dimension(varray = me->search,
					size = me->nb_intermediate + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
              }
             me->search_nb = 0;
             for(i=0;i<me->nb_intermediate;i++) 
	      {
                if(me->intermediate[i].name[0] == '\0' ||   
					me->intermediate[i].path[0] == '\0')
                  {
		    /*|no path given */
		    continue;
                  }
		me->search[me->search_nb] = me->intermediate[i];
		/* update active symbology if it changes */

		if(strcmp(me->search[me->search_nb].name,me->current.search_cst_path.name) == 0)
		   me->current.search_cst_path = me->search[me->search_nb];
	        me->search_nb = me->search_nb + 1;		
               }

             if(strcmp(me->select_act_path.name,"nothing"))
               me->current.search_cst_path = me->select_act_path;
           }

   	stat = vds$update_path(	form_ptr = me->form_ptr[MAIN],
				current = &me->current,
		  		main = &me->main[0],
		  		search = &me->search[0],
		  		nb_main = me->main_nb ,
		  		nb_search = me->search_nb );
     	if (! (stat & 1))
		{
			printf("error vds$update_path\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		}


        if ( me->form_ptr[LIST] != NULL )	
	status = FIf_erase( me->form_ptr[LIST] );
	if ( ! status )
	  {
	    /*| Enable & Set button to off */
                FIg_set_state_off( me->form_ptr[MAIN], MAIN_BUTTON);
                FIg_set_notify_on( me->form_ptr[MAIN], MAIN_BUTTON);
                FIg_set_state_off( me->form_ptr[MAIN], SEARCH_BUTTON);
                FIg_set_notify_on( me->form_ptr[MAIN], SEARCH_BUTTON);
	   }
	 else
	   {
	     /*| got bad return from erase_form */
             as$status( action = RET_STATUS );
	   }
      	me->main_flag = 0; 
      	me->search_flag = 0; 
	break;


      	case CREATE_TOG:

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);

        /* nothing is done, if save take toggle state to create or not path */

         FIg_get_state(form_ptr,CREATE_TOG,&state_create);
         if(me->search_flag)
	     FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			"Warning: search paths are not created",FALSE);
         else if(!state_create )
	     FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			"Warning: paths will not be created",FALSE);
         else if(state_create )
            {
             strcpy(msg_text,"paths will be created in ");
             if(me->current.reference_path[0] == '.') strcat(msg_text,act_dir);
             else  strcat(msg_text,me->current.reference_path);
	     FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			    msg_text,FALSE);
            }
        break;
      	case LIST_FIELD :


        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,"",FALSE);
        status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
	status = FIfld_get_active_row(form_ptr, LIST_FIELD, &act_row, &r_pos);
	if(status != FI_SUCCESS)
                    {printf("error FIfld_get_active_rows: %d\n",status);break;}

        if(me->del_row)
         {
	   FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
			   "valid selection with button delete",FALSE);
           break;
         }
        if(me->select_flag || me->symbology_flag)
         {
           /*|select mode */

	   status = FIfld_get_text(form_ptr, LIST_FIELD, act_row, 0,num_name, 
                          me->select_path.name, &sel_flag, &r_pos );
	   status = FIfld_get_text(form_ptr, LIST_FIELD, act_row, 1,num_path, 
                          me->select_path.path, &sel_flag, &r_pos );
	   if(status != FI_SUCCESS)
                    {printf("error FIfld_get_text: %d\n",status);break;}

           EXP_strip(me->select_path.name);
           EXP_strip(me->select_path.path);

	   me->select_index = -1;
           exist = 0;
           if(me->select_path.name[0] == '\0' && me->select_path.path[0] == '\0') 
	     {
        	FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
				"ERROR: no path select",FALSE);
		break;

             }
	        stat =vds$name_in_list(in_name   = me->select_path.name, 
				     out_index = &me->select_index, 
				     list      = &me->intermediate[0], 
				     nb_elts   = me->nb_intermediate,
				     symb      = &wrk_symb,
				     found     = &exist);
     	        if (! (stat & 1))
	         {
		    printf("error vds$name_in_list\n");
		    me->ret = MSFAIL;
    		    return OM_S_SUCCESS;
	         }
            if(!exist) 
	       {
		    printf("ERROR: path must be in the list\n");
		    me->ret = MSFAIL;
    		    return OM_S_SUCCESS;
	       }
            if(me->select_flag)
              {
                /*|select active path*/
                me->select_act_path = me->intermediate[me->select_index];
	        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
			       "valid selection with button SELECT",FALSE);
                break;
              }
            else if(me->symbology_flag)
             {
              if ( me->form_ptr[SUB] == NULL )
               {
                me->form_name[SUB] = SUB_FORM_NAME ;
                status = 0;
                status = FIf_new ( SUB,
                                 me->form_name[SUB],
                                 COB_FI_form_notification,
                                 &me->form_ptr[SUB] );

                if ( status )
                 {
                  me->form_ptr[SUB] = NULL;
                  me->state = _terminate;
                  me->delete_flag = 1;
                  return ( OM_I_STOP_SENDING );
                 }
                else
                 {
                  /*** tell the form which cmd it's talking to ***/
                  status = FIf_set_cmd_oid_os (  me->form_ptr[SUB],
                                         my_id, OM_Gw_current_OS );
                  if ( status )
                   {
                    me->state = _terminate;
                    me->delete_flag = 1;
                    return ( OM_I_STOP_SENDING );
                   }
                  status = FIf_set_initial_notification_routine ( me->form_ptr[SUB],
                                COB_FI_initial_form_notification );
                  if ( status )
                   {
                    me->state = _terminate;
                    me->delete_flag = 1;
                    return ( OM_I_STOP_SENDING );
                   }
                 }
               } /* SUB is NULL */
              if ( me->form_ptr[SUB] != NULL )	
                    {
        	      FIf_get_location(me->form_ptr[LIST], &xpos, &ypos);
		      xpos = 133;
		      ypos = 5;
                      FIf_set_rel_location(me->form_ptr[SUB], xpos, ypos,me->form_ptr[LIST]);
                      FIf_get_location(me->form_ptr[SUB], &xpos, &ypos);
	              
   		      stat = vds$set_symbology(symb_ptr = me->form_ptr[SUB],
				 	      text_symb= &wrk_symb);
     		      if (! (stat & 1))
		       {
		         printf("error vds$set_symbology\n");
		         me->ret = MSFAIL;
    		         return OM_S_SUCCESS;
		       }
		      stat = FIg_disable(me->form_ptr[LIST],EXIT);
		      stat = FIg_disable(me->form_ptr[LIST],SAVE);
	       	      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, 
	       			"Layer names must be separated by ':'",0);

          	      FIg_set_state_off(me->form_ptr[SUB], EXIT);
          	      FIg_set_state_off(me->form_ptr[SUB], SAVE);
		      FIf_display( me->form_ptr[SUB] );
	            }
             }

         }
        else
         {
	  /*| insert mode */
	  FImcf_get_active_col(form_ptr, LIST_FIELD, &act_col, &act_pos);
	  status = FIfld_get_text(form_ptr, LIST_FIELD, act_row, act_col,
				  num_char, text, &sel_flag, &r_pos );
	  if(status != FI_SUCCESS) break;
           strcpy(user_in,text);
           EXP_strip(text);
          if(strcmp(user_in,text)){
           FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
           		"Warning: text is stripped of space char(s)",FALSE);
           FIfld_set_text(form_ptr, LIST_FIELD, act_row, act_col,text,FALSE);
          }
           
	 if(om$dimension_of(varray = me->intermediate) <= num_rows)
            {
	      if(!(om$vla_set_dimension(varray = me->intermediate,
					size = me->nb_intermediate + ALLOC_INCR) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");break;}
		 for(i=me->nb_intermediate;i<me->nb_intermediate+ALLOC_INCR;i++)
		     VDSinit_symb(&me->intermediate[i]);
            }
	  if(act_col == 1)
           {
            len = strlen(text);
            if(len >= MY_PATH_MAX)
             {
               FIfld_set_text(form_ptr, MESSAGE_FIELD, 0, 0,
			      "Warning: path too long",FALSE);
               FIfld_set_text(form_ptr, LIST_FIELD, act_row, act_col,
				  "", FALSE);
               strcpy(me->intermediate[act_row].path, "\0");
               status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	       if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}

               me->nb_intermediate = num_rows;
	       text[0] = '\0';
             }
	    if(text[0] == '\0')
              { 

		if(act_row == 0 ){
			/* don't delete the first row, restore it */
			if(me->intermediate[0].path[0] != '\0') strcpy(text,me->intermediate[0].path);
			else strcpy(text,".");
	        	FIfld_set_text(form_ptr, LIST_FIELD, 0, 1, text,FALSE);
			
			FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
					"cannot delete the first row",FALSE);

			break;
		}

	        FIfld_set_text(form_ptr, LIST_FIELD, act_row, 0, "",FALSE);
            	strcpy(me->intermediate[act_row].name, "\0");

		/* correction PL May 94, we need to pos cursor on the precedent
		   line before deleting the current one otherwise it crashes
		 */

                FIfld_pos_cursor(form_ptr,LIST_FIELD,
                                        (act_row-1),0,0,0,0,0);

		status = FIfld_delete_rows(form_ptr,LIST_FIELD, act_row,1);
	  	if(status != FI_SUCCESS)
                    {printf("error FIfld_delete_rows: %d\n",status);break;}

                for (i= act_row ; i< me->nb_intermediate -1; i++)
		 {
		  me->intermediate[i] = me->intermediate[i+1];
                 }
               status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	       if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}

               me->nb_intermediate = num_rows;
                break;
              }
            strcpy(me->intermediate[act_row].path, text);

	    if( me->nb_intermediate == act_row || 
                      me->intermediate[act_row].symbology.color[0] =='\0')
                strcpy(me->intermediate[act_row].symbology.color,"act");
	    if( me->nb_intermediate == act_row || 
                      me->intermediate[act_row].symbology.style[0] =='\0')
                strcpy(me->intermediate[act_row].symbology.style,"act");
	    if( me->nb_intermediate == act_row || 
                      me->intermediate[act_row].symbology.weight[0] =='\0')
                strcpy(me->intermediate[act_row].symbology.weight,"act");
	    if( me->nb_intermediate == act_row || 
                      me->intermediate[act_row].symbology.layer[0] =='\0')
                strcpy(me->intermediate[act_row].symbology.layer,"act");
	    if( me->nb_intermediate == act_row || 
                      me->intermediate[act_row].symbology.layer_name[0] =='\0')
                me->intermediate[act_row].symbology.layer_name[0] = '\0';

	    /* verification of paths */

            if(me->search_flag)
            {
	      nb_returned = 0;
              len = strlen(text);
	      stat = vds$extract_all_part_exp( nb_part = &nb_returned,
     					      expression = text); 
     	      if (! (stat & 1))
		{ 
			printf("error vds$extract_all_part_exp\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		}
              search_path = NULL;
              search_path = (char **)om$malloc(size = nb_returned*
							sizeof(char*));
              if(search_path == NULL)
	        {
		 printf("bad allocation of search_path\n");
		 break;
  	        }
              for(i=0;i<nb_returned;i++)
               {
                 search_path[i] = (char *)om$malloc(size = (len+1)*
							sizeof(char));
                 if(search_path[i] == NULL)
		   {
			 printf("bad allocation of search_path\n");
			 break;
  		   }
                }

		 
	        stat = vds$extract_all_part_exp( expression  = text,
					  nb_returned = nb_returned,
					  part_exp    = search_path); 

                if (! (stat & 1))
		 { 
			printf("error vds$extract_all_part_exp\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		 }

                for(i=0;i<nb_returned;i++)
                  {
		    if(search_path[i][0] == '\0') continue;
	     	    stat = vds$out_path(in_path = search_path[i], 
				 ref_path = me->current.reference_path,
			         out_path = out);
     		    if (! (stat & 1))
		     { 
			printf("error vds$out_path\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		     }
                    stat = di$translate( objname = out,
					p_objid = &dir.objid,
					p_osnum = &dir.osnum);
                    if(stat != DIR_S_SUCCESS)
                     {
                      strcpy(msg_text,"WARNING: one path doesn't exist");
                      FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			  	     msg_text,0);
                     }
                  }
                
            }
            else if(me->main_flag)
            {
 	     stat = vds$out_path(in_path = text, 
				 ref_path = me->current.reference_path,
			         out_path = out);
     	     if (! (stat & 1))
		{ 
			printf("error vds$out_path\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		}

              stat = di$translate( 	objname = out,
					p_objid = &dir.objid,
					p_osnum = &dir.osnum);
              if(stat != DIR_S_SUCCESS)
                    {
                     strcpy(msg_text, "WARNING: ");
		     strcat(msg_text,out);
		     strcat(msg_text, " doesn't yet exist");
                     
	             FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
				    msg_text,0);
                    }
             }
            status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	    if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}

            me->nb_intermediate = num_rows;
	    status = FIfld_get_text(form_ptr, LIST_FIELD, act_row, 0,num_char, 
				text, &sel_flag, &r_pos );
	    if(status != FI_SUCCESS)
                    {printf("error FIfld_get_text: %d\n",status);break;}
            strcpy(user_in,text);
            EXP_strip(text);

            if(strcmp(user_in,text)){
              FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0,
           		"Warning: text is stripped of space char(s)",FALSE);
              FIfld_set_text(form_ptr, LIST_FIELD, act_row, 0,text,FALSE);
            }

	    if(text[0]=='\0')
              {
	        if(me->main_flag) name_index = me->int_name_index[0];
	        else name_index = me->int_name_index[1];

                /*|auto name */

		 exist = 1;
                 while(exist)
                 {
                   named_flag = 0;
                   stat = vds$auto_name(index = name_index,
				      to_name = &me->intermediate[act_row],
				      name = auto_name,
      				      const_flag = const_flag,
				      named_flag = &named_flag);
     	           if (! (stat & 1))
		     {
			printf("error vds$auto_name\n");
			me->ret = MSFAIL;
    			return OM_S_SUCCESS;
		     }
		   me->intermediate[act_row].name[0] = '\0';
                   exist = 0;
		   list_index = -1;
	           stat =vds$name_in_list(in_name   = auto_name, 
				          out_index = &list_index, 
				          list      = &me->intermediate[0], 
				          nb_elts   = me->nb_intermediate - 1,
				          found     = &exist);
     	            if (! (stat & 1))
	             {
		        printf("error vds$name_in_list\n");
		        me->ret = MSFAIL;
    		        return OM_S_SUCCESS;
	              }
    		   if(exist ) me->intermediate[act_row].name[0] = '\0';
                    name_index = name_index + 1;
                    
                  }/* while exist */
	         if(named_flag)
                   { 
	            status = FIfld_set_text(form_ptr, LIST_FIELD, act_row, 0, 
				   auto_name,FALSE);
	    	    if(status != FI_SUCCESS)
                     {printf("error FIfld_set_text: %d\n",status);break;}
            	    strcpy(me->intermediate[act_row].name, auto_name);
                   }
              }/* text = \0 */
            }/* act_col =1 */
	  else if(act_col == 0)
           {
            len = strlen(text);
 	    if(len >=NAME_MAX)
              {
                strcpy(msg_text,"name too long");
	        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
			   msg_text,FALSE);
	        FIfld_set_text(form_ptr, LIST_FIELD, act_row, 0, 
			   "",FALSE);
               me->intermediate[act_row].name[0] = '\0';
               status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	       if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
	       for(i=0;i<num_rows; i++)
    	     		FIfld_set_active_row(form_ptr, LIST_FIELD, i, 0);
	        
               me->nb_intermediate = num_rows;
               break;
              }
             if(text[0] != '\0')
              {
 	        stat =vds$name_in_list(in_name   = text, 
				     out_index = &list_index, 
				     list      = &me->intermediate[0], 
				     nb_elts   = me->nb_intermediate,
				     found     = &exist);
     	        if (! (stat & 1))
	         {
		   printf("error vds$name_in_list\n");
		   me->ret = MSFAIL;
    		   return OM_S_SUCCESS;
	         }
                if(act_row !=0 && exist && list_index != act_row) 
	         {
		   printf("ERROR: duplicate name\n");
		   me->intermediate[act_row].name[0]= '\0';
	           status = FIfld_set_text(form_ptr, LIST_FIELD, act_row, 0, 
					"",FALSE);
        	   status = FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
					"duplicate name",FALSE);
	    	   if(status != FI_SUCCESS)
                     {printf("error FIfld_set_text: %d\n",status);break;}
                   status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	           if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
                   me->nb_intermediate = num_rows;
   		   break;
	         }
              }
            strcpy(me->intermediate[act_row].name, text);
           }
         }

	break;

      	case LOAD_BUTTON :

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, "",FALSE);
        FIbtn_set_auto_pop_up_on( form_ptr, LOAD_BUTTON );
	break;

      	case DEL_BUTTON:

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, "",FALSE);
        if(me->del_row)
         {
           status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	   if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
           for(i=0;i< num_rows; i=i+1)
            {
	     status = FIfld_get_text(form_ptr, LIST_FIELD, i, 0,num_name, 
                          me->select_path.name, &sel_flag, &r_pos );
             if(sel_flag == 1)
              {
	        status = FIfld_delete_rows(form_ptr,LIST_FIELD, i,1);
	        if(status != FI_SUCCESS)
                    {printf("error FIfld_delete_rows: %d\n",status);break;}
                for (j= i ; j< me->nb_intermediate -1; j++)
		  me->intermediate[j] = me->intermediate[j+1];
                i = i-1;
              }
             status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	     if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
            }
           status = FIfld_get_num_rows(form_ptr,LIST_FIELD, &num_rows);
	   if(status != FI_SUCCESS)
                    {printf("error FIfld_get_num_rows: %d\n",status);break;}
           me->nb_intermediate = num_rows;
	   FIg_enable(me->form_ptr[LIST],SELECT_BUTTON);
	   FIg_enable(me->form_ptr[LIST],LOAD_BUTTON);
           if(!me->search_flag) FIg_enable(me->form_ptr[LIST],SYMB_BUTTON);
	   me->del_row = 0;
           FIg_set_state_off(form_ptr,DEL_BUTTON);
           mode = FI_INSERT;
           status = FIfld_set_mode(form_ptr, LIST_FIELD, 0, mode);
           status = FIfld_set_mode(form_ptr, LIST_FIELD, 1, mode);
	   if(status != FI_SUCCESS)
                     {printf("error FIfld_set_mode: %d\n",status);break;}
           FIg_set_state_off(me->form_ptr[LIST], EXIT);
           FIg_set_state_off(me->form_ptr[LIST], SAVE);
	   FIf_display( me->form_ptr[LIST] );
           break;
         }
        me->del_row = 1;
	FIg_disable(me->form_ptr[LIST],LOAD_BUTTON);
        FIg_disable(me->form_ptr[LIST],SYMB_BUTTON);
        FIg_disable(me->form_ptr[LIST],SELECT_BUTTON);
        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
                       "select paths to delete",FALSE);
        FIg_set_state_on(form_ptr,DEL_BUTTON);
        mode = FI_MULTI_SELECT;
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 0, mode);
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 1, mode);
	if(status != FI_SUCCESS)
                     {printf("error FIfld_set_mode: %d\n",status);break;}
	status = FImcf_set_attr(me->form_ptr[LIST], LIST_FIELD, me->select_attr);
	if(status != FI_SUCCESS)
                     {printf("error FImcf_set_attr: %d\n",status);break;}
        FIg_set_state_off(me->form_ptr[LIST], EXIT);
        FIg_set_state_off(me->form_ptr[LIST], SAVE);
	FIf_display( me->form_ptr[LIST] );
        break;


      	case SELECT_BUTTON :


	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, "",FALSE);
        if(me->select_flag)
         {
           FIg_enable(me->form_ptr[LIST],DEL_BUTTON);
	   FIg_enable(me->form_ptr[LIST],LOAD_BUTTON);
           if(!me->search_flag) FIg_enable(me->form_ptr[LIST],SYMB_BUTTON);
	   me->select_flag = 0;
           FIg_set_state_off(form_ptr,SELECT_BUTTON);
           mode = FI_INSERT;
           status = FIfld_set_mode(form_ptr, LIST_FIELD, 0, mode);
           status = FIfld_set_mode(form_ptr, LIST_FIELD, 1, mode);
	   if(status != FI_SUCCESS)
                     {printf("error FIfld_set_mode: %d\n",status);break;}
           FIg_set_state_off(me->form_ptr[LIST], EXIT);
           FIg_set_state_off(me->form_ptr[LIST], SAVE);
	   FIf_display( me->form_ptr[LIST] );
           break;
         }
        FIg_disable(me->form_ptr[LIST],DEL_BUTTON);
	FIg_disable(me->form_ptr[LIST],LOAD_BUTTON);
        FIg_disable(me->form_ptr[LIST],SYMB_BUTTON);
        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
                       "select path to become active",FALSE);
        FIg_set_state_on(form_ptr,SELECT_BUTTON);
        mode = FI_SINGLE_SELECT;
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 0, mode);
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 1, mode);
	if(status != FI_SUCCESS)
                     {printf("error FIfld_set_mode: %d\n",status);break;}
	status = FImcf_set_attr(me->form_ptr[LIST], LIST_FIELD, me->select_attr);
	if(status != FI_SUCCESS)
                     {printf("error FImcf_set_attr: %d\n",status);break;}
        FIg_set_state_off(me->form_ptr[LIST], EXIT);
        FIg_set_state_off(me->form_ptr[LIST], SAVE);
	FIf_display( me->form_ptr[LIST] );
        me->select_flag = 1;
	break;

       case SYMB_BUTTON:

	FIfld_set_text(me->form_ptr[MAIN], MESSAGE_FIELD, 0, 0, "",FALSE);
	FIg_disable(me->form_ptr[LIST],LOAD_BUTTON);
        FIg_disable(me->form_ptr[LIST],DEL_BUTTON);
        FIg_disable(me->form_ptr[LIST],SELECT_BUTTON);
	FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0, "",FALSE);
	me->symbology_flag = 1;
        FIg_set_state_on(form_ptr,SYMB_BUTTON);
	status = FImcf_set_attr(me->form_ptr[LIST], LIST_FIELD, me->select_attr);
	if(status != FI_SUCCESS)
                     {printf("error FImcf_set_attr: %d\n",status);break;}
        mode =  FI_SINGLE_SELECT;
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 0, mode);
        status = FIfld_set_mode(form_ptr, LIST_FIELD, 1, mode);
	if(status != FI_SUCCESS)
                     {printf("error FIfld_set_mode: %d\n",status);break;}
        FIg_set_state_off(me->form_ptr[LIST], EXIT);
        FIg_set_state_off(me->form_ptr[LIST], SAVE);
	FIf_display( me->form_ptr[LIST] );
        FIfld_set_text(me->form_ptr[LIST], MESSAGE_FIELD, 0, 0,
                       "select the path to edit symbology",FALSE);
        break;

      /*| symbology form */
      }
  }
  End
/*|end notification */
}




