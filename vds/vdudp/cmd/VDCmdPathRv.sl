/* $Id: VDCmdPathRv.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathRv.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathRv.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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
# Revision 1.2  1995/11/29  13:53:44  pinnacle
# Replaced: ./vdudp/cmd/VDCmdPathRv.sl for:  by ksundar for vds.240
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

command_string       VDC_M_StDrPt, 0, VDStDrPt
command_table        "vds.cmd"
class                VDCmdPathRv
super_class          VDCmdPath
product_name         "$VDS"

/**
form "VDDirPath" ,MAIN,2,"-1","-1",1
form "VDSymb" ,SUB,0,"-1","-1",1
**/

specification

/* instance variables for form control */

instance
{
   /* Form control */
   int				revdel_flag;
   char *			Revform_name;
   int				Revform_label;
   Form  			Revform_ptr;
   int				revmain_nb;
   int				revsearch_nb;
   struct current_path		revcurrent;
   variable struct constr_path  revmain[5];
   variable struct constr_path  revsearch[5];
}


implementation

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "expression.h"
#include "dp.h"
#include "dpmacros.h"
#include "vddirmacros.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"

#include "AS_status.h"
#define AS_DEBUG 1

extern void COB_FI_form_notification(), COB_FI_initial_form_notification();


%safe
static int 	x_memo = -1,
       		y_memo = -1;

%endsafe

/***********************************************************/
state_table

#include "VDmsg.h"
#include "VDSudpco.h"

state start

  on CMD_TYPE = 0						state terminate

/***********************************************************/
action init
/*.init*/
{
  char			path_name[DI_PATH_MAX+25],str_ptr[MY_MAX];
  int			sts;
  long			stat,msg;
  struct GRid		VDCmdPathRv_id;
  extern int		(*AStranslate)(), VDStranslate();


  /* delete by default */
   me->revdel_flag 	 = 1;
   me->Revform_ptr	 = NULL;
   me->ret 		 = MSSUCC;

   dp$erase_hilite(msg=&sts);
  AStranslate = VDStranslate; 
  status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

  if ( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
   }

  strcat( path_name, COMMAND_REV_NAME );


  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VDCmdPathRv_id.objid,
			  p_osnum = &VDCmdPathRv_id.osnum );
  if ( status != DIR_S_SUCCESS ) 
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {

     /* printf( " Couldn't find it, so trying to create my entry\n\n" ); */

 
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

	/*| before name assign */
  	me->Revform_name = MAIN_FORM_REV_NAME ;
  	status = 0; 

	status = FIf_new ( MAIN,
                     	   me->Revform_name,
                     	   COB_FI_form_notification,
                     	   &me->Revform_ptr );

  	if ( status )
 	 {
    	  me->Revform_ptr = NULL;
    	  me->state = _terminate;
	  me->revdel_flag = 1;
	  return ( OM_I_STOP_SENDING );
   	 } 
	else
	 {
     	  /*** tell the form which cmd it's talking to ***/
     	  status = FIf_set_cmd_oid_os (  me->Revform_ptr,
                                	 my_id, OM_Gw_current_OS );
	  if ( status )
      	   {
    	    me->state = _terminate;
	    me->revdel_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
     	  status = FIf_set_initial_notification_routine ( me->Revform_ptr,
                                COB_FI_initial_form_notification );
     	  if ( status )
	   {
    	    me->state = _terminate;
	    me->revdel_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
	 }
   
	 /* fill form with expressions */

         stat = om$send (  msg = message VDCmdPathRv.VDSupdate_list(&msg),
                     	targetid = my_id);

         if ( (! (stat & 1)) || msg == OM_E_ABORT)
   		    {
      			printf("VDSRevpath:failure sending VDSupdate_list\n");
	 		me->ret = MSFAIL;
			as$status(sts = stat, action = RET_STATUS);
         		return OM_S_SUCCESS;
   		     }
         stat = om$send (  msg = message VDCmdPathRv.VDSupdate_act(&msg),
                     	targetid = my_id);

         if ( (! (stat & 1)) || msg == OM_E_ABORT)
   		    {
      			printf("VDSRevpath:failure sending VDSupdate_act\n");
	 		me->ret = MSFAIL;
			as$status(sts = stat, action = RET_STATUS);
         		return OM_S_SUCCESS;
   		     }


  	 me->revdel_flag = 0;
 	 if(x_memo != -1 || y_memo != -1) 
		FIf_set_location(me->Revform_ptr,x_memo,y_memo);
	 
	 
	 FIf_display( me->Revform_ptr );
	}
     }
    else
    {
         di$report_error( sts     = status,
                          comment = "  Unable to find my entry\n" );
    }

  }
 else if ( VDCmdPathRv_id.objid != my_id )
  {
    me->revdel_flag = 1;
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

} 
/**********************************************************/

action delete
/*.delete*/
{
  if ( me->Revform_ptr != NULL )
     FIf_get_location(me->Revform_ptr,&x_memo,&y_memo);

  if ( me->revdel_flag  )
   {
    if ( me->Revform_ptr != NULL )
     {
      FIf_delete( me->Revform_ptr );
     }
    status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.delete ( 0 ));
    return ( OM_S_SUCCESS );

   }
  else
   {
     return ( OM_S_SUCCESS );
    }

}


/*----------------------- VDSupdate_form  ---------------------------*/
/*  method which update the form with instances
 *  
 */

action VDSupdate_form(long *msg;)

/*.VDSupdate_form*/
{
long	sts;

sts = FIfld_set_text(me->Revform_ptr,MAIN_NAME_FIELD , 0 ,0,
                        me->revcurrent.main_cst_path.name,FALSE);
if (sts != FI_SUCCESS){
			printf("FIfld_set_text fail \n"); 
			goto wrapup;
}
FIfld_set_active_char(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0, 0);

sts = FIfld_set_text(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 
                        me->revcurrent.search_cst_path.name, FALSE);
if (sts != FI_SUCCESS){
			printf("FIfld_set_text fail \n"); 
			goto wrapup;
}
FIfld_set_active_char(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 0);

*msg = OM_S_SUCCESS;
return OM_S_SUCCESS;

wrapup:
	*msg = OM_E_ABORT;
        me->ret = MSFAIL;
    	return OM_S_SUCCESS;


}

/*----------------------- VDSupdate_act  ---------------------------*/
/*  method which update the form with expressions of current path
 *  include ref_path
 */

action VDSupdate_act(long *msg;)

/*.VDSupdate_act*/
{
char			us_path[DI_PATH_MAX+30];
long			sts;
struct GRid		dir_obj;
struct GRmd_env		md_env;


sts = vds$init_path(user_path = us_path, dir_obj = &dir_obj,md_env = &md_env); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}

sts = vds$give_exp( current   = &me->revcurrent);

if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}

sts = FIfld_set_text(me->Revform_ptr,MAIN_NAME_FIELD , 0 ,0,
                        me->revcurrent.main_cst_path.name,FALSE);
if (sts != FI_SUCCESS){
			printf("FIfld_set_text fail \n"); 
			goto wrapup;
}
FIfld_set_active_char(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0, 0);

sts = FIfld_set_text(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 
                        me->revcurrent.search_cst_path.name, FALSE);
if (sts != FI_SUCCESS){
			printf("FIfld_set_text fail \n"); 
			goto wrapup;
}
FIfld_set_active_char(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 0);


*msg = OM_S_SUCCESS;
return OM_S_SUCCESS;

wrapup:
	*msg = OM_E_ABORT;
        me->ret = MSFAIL;
    	return OM_S_SUCCESS;

}

/*----------------------- VDSupdate_list  ---------------------------*/
/*  method which update the form with expressions (list paths and not 
/*  current)
 */

action VDSupdate_list(long *msg;)

/*.VDSupdate_list*/
{
char			us_path[DI_PATH_MAX+30],**lines;
long			sts;
struct GRid		dir_obj;
struct GRmd_env		md_env;
int			num_row,nb_lines,len,i;

me->revmain_nb   = 0;
me->revsearch_nb = 0;
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


sts = vds$give_exp( nb_main   = &me->revmain_nb, 
		    nb_search = &me->revsearch_nb,
		    nb_lines  = nb_lines,
		    lines     = lines);
if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}


 /* realloc des tableaux si necessaire */

 if(om$dimension_of(varray = me->revsearch) <= me->revsearch_nb)
    {
	 if(!(om$vla_set_dimension( 	varray = me->revsearch,
					size = me->revsearch_nb + ALLOC_INCR) & 1))
	    {printf("Bad dynamic allocation\n");goto wrapup;}
    }
 if(om$dimension_of(varray = me->revmain) <= me->revmain_nb)
    {
	 if(!(om$vla_set_dimension( 	varray = me->revmain,
					size = me->revmain_nb + ALLOC_INCR) & 1))
	    {printf("Bad dynamic allocation\n");goto wrapup;}
    }

sts = vds$give_exp( main_alloc   = me->revmain_nb, 
		    search_alloc = me->revsearch_nb,
		    main   	 = me->revmain,
		    search 	 = me->revsearch,
		    nb_lines     = nb_lines,
		    lines        = lines);
if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); goto wrapup;}




if ( me->Revform_ptr == NULL ){
     printf("ERROR: no me->Revform_ptr set \n");
     goto wrapup; 
}

          
/* -- main_list -- */

num_row = 0;

sts = FIfld_set_list_num_rows(me->Revform_ptr, MAIN_NAME_FIELD, 0, num_row);
/*"me->revmain_nb: %d\n",me->revmain_nb */
for (i=0;i < me->revmain_nb;i++)
 {
   if(me->revmain[i].name[0] != '\0')
    {
      sts = FIfld_get_list_num_rows(me->Revform_ptr, MAIN_NAME_FIELD, 0, 
      				    &num_row);
      sts = VDfld_set_list_text(me->Revform_ptr, MAIN_NAME_FIELD, num_row,0,
    				me->revmain[i].name,FALSE);
      if (sts != FI_SUCCESS)
          {printf("VDfld_set_list_text fail\n"); goto wrapup;}
    }
 }
 
/* -- search_list -- */

num_row = 0;
sts = FIfld_set_list_num_rows(me->Revform_ptr, SEARCH_NAME_FIELD, 0, num_row);


for (i=0;i< me->revsearch_nb;i++)
 {
   if(me->revsearch[i].name[0] != '\0')
    {
      sts = FIfld_get_list_num_rows(me->Revform_ptr, SEARCH_NAME_FIELD, 0, &num_row);
      sts = VDfld_set_list_text(me->Revform_ptr,SEARCH_NAME_FIELD , num_row,0,
       me->revsearch[i].name,FALSE);
      if (sts != FI_SUCCESS)
          {printf("VDfld_set_list_text fail\n"); goto wrapup;}
    }
 }

if(nb_lines != 0 && lines != NULL) 
 {
    di$free(lines = lines,
            count = nb_lines);
    lines    = NULL;
    nb_lines = 0;
 }
*msg = OM_S_SUCCESS;
return OM_S_SUCCESS;

wrapup:

	if(nb_lines != 0 && lines != NULL) 
 	 {
   	   /*|dealloc lines allocated in the function */
    	    di$free(lines = lines,
            	    count = nb_lines);
    	            lines = NULL;
    	            nb_lines = 0;
 	 }
	*msg = OM_E_ABORT;
        me->ret = MSFAIL;
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
  				act_dir[DI_PATH_MAX],
				out[DI_PATH_MAX],msg_text[DI_PATH_MAX+50];
				
  int 				len, num_char = DI_PATH_MAX,r_pos,
				sts,type, 
				list_index,
				row=0,col=0,sel_flag=0, exist = 0;

  long				stat,msg=0;
  double			val;
  struct GRsymbology		symbology;


  if ( form_ptr == NULL )
   {
     /*| no form_ptr set */
     return( OM_E_INVARG ); 
    }

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
          if(strcmp(user_in,text))
             FIfld_set_text(form_ptr, gadget_label, row, col,text,FALSE);

          
         }
       else
         {
           /*|type not defined*/
         }
    }

switch ( gadget_label )
    {
      case EXIT:

        FIbtn_set_auto_pop_up_on( form_ptr, EXIT );
        dp$erase_hilite(msg=&sts);
        me->revdel_flag = 1;			
        me->state = _terminate;

                       status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdPathRv.delete ( 0 ));

	break;

      case ABORT:
        
        FIbtn_set_auto_pop_up_on( form_ptr, ABORT );

	status = om$send (  msg = message VDCmdPathRv.VDSupdate_list(&msg),
                     	targetid = my_id);

	if ( (! (status & 1)) || msg == OM_E_ABORT)
   	{
      		printf("VDSRevpath:failure sending VDSupdate_list\n");
		me->ret = MSFAIL;
		as$status(action = RET_STATUS);
        	return OM_S_SUCCESS;
   	}

	status = om$send (  msg = message VDCmdPathRv.VDSupdate_act(&msg),
                     	targetid = my_id);

	if ( (! (status & 1)) || msg == OM_E_ABORT)
   	{
      		printf("VDSRevpath:failure sending VDSupdate_act\n");
		me->ret = MSFAIL;
		as$status(action = RET_STATUS);
        	return OM_S_SUCCESS;
   	}
        FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "Form updated ",FALSE);

	break;

       case STORE:
       case SAVE:
       
        FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "",FALSE);
 
        FIg_set_state_on(form_ptr,gadget_label);
		
	status = om$send (  msg = message VDCmdPathRv.VDSupdate_form(&msg),
                     	targetid = my_id);

	if ( (! (status & 1)) || msg == OM_E_ABORT)
   	{
      		printf("VDSRevpath:failure sending VDSupdate_form\n");
		me->ret = MSFAIL;
		as$status(action = RET_STATUS);
        	return OM_S_SUCCESS;
   	}
        sts = vds$give_symb(txt_symb = &me->revcurrent.main_cst_path.symbology,
			    symbology = &symbology);

	sts = vds$set_current(current_dir = me->revcurrent.main_cst_path.path,
		      	      path	  = me->revcurrent.reference_path,
		      	      out_path	  = out,
		      	      symbology   = &symbology);
        if (! (sts & 1))
         { 
           if(sts == OM_W_WARNING)
            {
	        /*" path [%s] doesn't exist\n",out*/
                FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "Can't change dir",FALSE);
		break;      
            }
           else
            {
              FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "Can't change dir",FALSE);
              printf("error vds$set_current\n");
	      me->ret = MSFAIL;
              return OM_S_SUCCESS;
            }
         }
        strcpy(msg_text,"Current dir is ");
        strcat(msg_text,out);
        UI_status(msg_text);

  	status = di$pwd(dirname = act_dir);
  	if(status!= DIR_S_SUCCESS)
		{printf("error pwd\n");me->ret = MSFAIL;return OM_S_SUCCESS;}

        sts = vds$set_act_path(path_name  = me->revcurrent.main_cst_path.name, 
                               const_flag = MAIN_PATH);
        if(!(sts&1))
         {
           FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "Can't change dir",FALSE);
    	   printf("error vds$set_act_path\n");
	   me->ret = MSFAIL;
	   return OM_S_SUCCESS;
         }
        sts = vds$set_act_path(path_name  = me->revcurrent.search_cst_path.name, 
                               const_flag = SEARCH_PATH,
                               ret_path   = out);
        if(!(sts&1))
         {
           FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "Can't set search",FALSE);
    	   printf("error vds$set_act_path\n");
	   me->ret = MSFAIL;
	   return OM_S_SUCCESS;
         }

	/*|update dir form */
	vd$dir_update_form();

	if(gadget_label == SAVE){
        	dp$erase_hilite(msg=&sts);
        	me->revdel_flag = 1;			
        	me->state = _terminate;

                status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdPathRv.delete ( 0 ));

	}
        break;

       

       case MAIN_NAME_FIELD:

        FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "",FALSE);

        len = strlen(text);
 	if(len >=NAME_MAX)
          {
            strcpy(msg_text,"Name too long");
	    FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
			   msg_text,FALSE);
	    FIfld_set_text(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0,
			   me->revcurrent.main_cst_path.name,FALSE);
	    FIfld_set_active_char(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0, 0);
            break;
          }
	if(text[0] != '\0')
         {
	   stat =vds$name_in_list( in_name   = text, 
				   out_index = &list_index, 
				   list      = &me->revmain[0], 
				   nb_elts   = me->revmain_nb,
				   found     = &exist);

     	   if (! (stat & 1))
	    {
	      printf("error vds$name_in_list\n");
	      me->ret = MSFAIL;
    	      return OM_S_SUCCESS;
	    }
           if(exist)
            {
             me->revcurrent.main_cst_path = me->revmain[list_index];
            }
           else
            {
             status = FIfld_set_text(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0,
                         me->revcurrent.main_cst_path.name ,FALSE);
	     FIfld_set_active_char(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0, 0);
             status = FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0, 
                         "ERROR:Name not defined",FALSE);
	     if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
            }
          }
	else 
         {
             status = FIfld_set_text(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0,
                         me->revcurrent.main_cst_path.name ,FALSE);
	     FIfld_set_active_char(me->Revform_ptr, MAIN_NAME_FIELD, 0, 0, 0);
             status = FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0, 
                         "ERROR:Name not defined",FALSE);
	     if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
	  
         }
	break;


       case SEARCH_NAME_FIELD:

        FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
                               "",FALSE);

        len = strlen(text);
 	if(len >=NAME_MAX)
          {
            strcpy(msg_text,"Name too long");
	    FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0,
			   msg_text,FALSE);
	    FIfld_set_text(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0,
			   me->revcurrent.search_cst_path.name,FALSE);
	    FIfld_set_active_char(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 0);
            break;
          }
	if(text[0] != '\0')
         {
	  stat =vds$name_in_list(	in_name   = text, 
					out_index = &list_index, 
					list      = &me->revsearch[0], 
					nb_elts   = me->revsearch_nb,
					found     = &exist);

     	  if (! (stat & 1))
	   {
	     printf("error vds$name_in_list\n");
	     me->ret = MSFAIL;
    	     return OM_S_SUCCESS;
	   }
           if(exist)
            {
             me->revcurrent.search_cst_path = me->revsearch[list_index];
            }
           else
           {
            status = FIfld_set_text(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0,
                         me->revcurrent.search_cst_path.name ,FALSE);
	    FIfld_set_active_char(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 0);
            status = FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0, 
                         "ERROR:Name not defined",FALSE);
	    if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
           }
         }
	else 
         {
            status = FIfld_set_text(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0,
                         me->revcurrent.search_cst_path.name ,FALSE);
	    FIfld_set_active_char(me->Revform_ptr, SEARCH_NAME_FIELD, 0, 0, 0);
            status = FIfld_set_text(me->Revform_ptr, MESSAGE_FIELD, 0, 0, 
                         "ERROR:Name not defined",FALSE);
	    if(status != FI_SUCCESS)
                   {printf("error FIfld_fld_set_text: %d\n",status);break;}
         }
	break;


 }       

}




