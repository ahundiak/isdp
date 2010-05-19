/* $Id: SMModNotif.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/cmd / SMModNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMModNotif.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
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
# Revision 1.4  1996/05/16  09:38:36  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.3  1996/04/17  14:25:02  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/22  14:22:56  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
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

/*    File          SMModNotif.I
      Description   Form notification for Modify frame section
      Auteur        Jean Jasinczuk (ISDC) 
      Date          April-92
*/

class implementation SMCmdModSct;

#include "VDmem.h"

from SMframe    import SMgive_rel_position,SMfind_frame_num;


%safe
static int save_mod_frame();
static void select_depandance_field();
static void select_newlist_field();
static int compute_frame_pos();
static void  reset_mod_form();
static int near_dist_dep();
static void no_default_dep();
%endsafe

method form_notification (int form_label; int gadget_label ; double value ;
                           char * form_ptr)
{
  int status = OM_S_SUCCESS;
  char text_value[40];

  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
   {
   case FI_ACCEPT :
     
     if(!save_mod_frame(me->forms[0].form_ptr,me->old_nb_frame,me->depandance,
			me->old_dep_grid,me->new_dep_number))
      { 
	FIg_set_state_off(me->forms[MAIN].form_ptr,FI_ACCEPT);
	goto quit;
      }   
     _put_response(resp = MOD_SECT);
     goto quit;
     
   case FI_CANCEL : 
     _put_response(resp = TERMINATE);
     break;
     
   case FI_RESET :
     reset_mod_form(me->forms[0].form_ptr,me->old_nb_frame); 
     FIg_set_state_off(me->forms[MAIN].form_ptr,FI_RESET);
     break;

   case DEPANDANCE_FIELD :
     /* Find selected row in the depandance field */
     select_depandance_field(me->forms[0].form_ptr,me->depandance);
     break;
     
   case NEWLIST_FIELD:
     select_newlist_field(me->forms[0].form_ptr,me->depandance);
     break;

   case DEFAULT_FIELD:
     FIg_get_text(me->forms[0].form_ptr,DEFAULT_FIELD,text_value);
     if(strcmp(text_value,NEAR_DIST_STRING) == 0)
       near_dist_dep(me->forms[0].form_ptr,me->depandance,me->old_dep_grid,
		      me->old_nb_frame,me->nb_new_spacing+1,me->fr_number1);
     else
       if(strcmp(text_value,NO_DEFAULT_SRING) == 0)
	 no_default_dep(me->forms[0].form_ptr,me->old_nb_frame);
     break;
   }
 quit:
  return OM_S_SUCCESS;
}	

method init_form_dep(int *sts)
{
  IGRlong status,msg;
  IGRint fr_num;
  IGRdouble *fr_pos,*new_fr_pos;
  int row;
  long mask;
  char text_value[40];
  short exist_dep;
  IGRdouble value;
  int r_pos,sel_flag;

  fr_pos = NULL;
  new_fr_pos = NULL;
  
  exist_dep = FALSE;
  /* If no frame has depandance, then no form to display */
  for(row=0;row<me->old_nb_frame;row++)
    if(me->depandance[row] == TRUE)
     { exist_dep = TRUE; break;}

  if(!exist_dep)
   {
     for(row=0;row<me->old_nb_frame;row++)
       me->old_dep_grid[row].objid = NULL_OBJID;
     *sts = NO_DEPANDANCE; goto quit;
   }

  FImcf_get_attr(me->forms[0].form_ptr,DEPANDANCE_FIELD,&mask);
  FImcf_set_attr(me->forms[0].form_ptr,DEPANDANCE_FIELD,mask | FI_ROW_SELECT);
  FImcf_get_attr(me->forms[0].form_ptr,NEWLIST_FIELD,&mask);
  FImcf_set_attr(me->forms[0].form_ptr,NEWLIST_FIELD,mask | FI_ROW_SELECT);

  FIfld_set_num_rows(me->forms[0].form_ptr,DEPANDANCE_FIELD,me->old_nb_frame);
  /* Place all the number and position of the old frame */
  for(row=0;row<me->old_nb_frame;row++)
   {
     status = om$send(msg = message SMframe.SMfind_frame_num
		      (&msg,&fr_num),
		      targetid = me->old_dep_grid[row].objid,
		      targetos = me->old_dep_grid[row].osnum );
     if(!(status & msg &1))
      { *sts = OM_E_ABORT; goto quit;}
     FIfld_set_value(me->forms[0].form_ptr,DEPANDANCE_FIELD,
		     row,DEP_OLD_N,(double)fr_num,0);

     sprintf(text_value,"%d",fr_num);
     FIfld_set_default_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,
			    row,DEP_OLD_N,text_value,0); 
     FIfld_set_default_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,DEP_DEP,
			    me->depandance[row] ? "y" : "n",0);
     FIfld_set_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,DEP_DEP,
		    me->depandance[row] ? "y" : "n",0);
   }

  /* Compute the position of old frame and display them */
  /* in the DEPANDANCE_FIELD gadget */
  if(!compute_frame_pos(me->old_dep_grid,me->old_nb_frame,me->nb_new_spacing+1,
			me->fr_number1,&fr_pos,&new_fr_pos))
   { *sts = OM_E_ABORT; goto quit; }

  for(row=0;row<me->old_nb_frame;row++)
   {
     FIfld_set_value(me->forms[0].form_ptr,DEPANDANCE_FIELD,
		     row,DEP_OLD_X,fr_pos[row],0);
     sprintf(text_value,"%g",fr_pos[row]);
     FIfld_set_default_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,
			    row,DEP_OLD_X,text_value,0);
   }


  /* Fill the list of new frame */
  FIfld_set_num_rows(me->forms[0].form_ptr,NEWLIST_FIELD,me->nb_new_spacing+1);
  fr_num = me->fr_number1 >= 0 ? me->fr_number1  : me->fr_number2 - me->nb_new_spacing ;
  for(row=0;row<=me->nb_new_spacing; row++)
   {
     FIfld_set_value(me->forms[0].form_ptr,NEWLIST_FIELD,
		     row,NEWFR_NEW_N,(double)fr_num,0);
     sprintf(text_value,"%d",fr_num);
     FIfld_set_default_text(me->forms[0].form_ptr,NEWLIST_FIELD,
			    row,NEWFR_NEW_N,text_value,0);
     FIfld_set_value(me->forms[0].form_ptr,NEWLIST_FIELD,
		     row,NEWFR_NEW_X,new_fr_pos[row],0);
     sprintf(text_value,"%g",new_fr_pos[row]);
     FIfld_set_default_text(me->forms[0].form_ptr,NEWLIST_FIELD,
			    row,NEWFR_NEW_X,text_value,0);
     fr_num++;
   }

  /* Proposed the nearest distance dependency  */
  near_dist_dep(me->forms[0].form_ptr,me->depandance,me->old_dep_grid,
		me->old_nb_frame,me->nb_new_spacing+1,me->fr_number1);
  /* Set default dependency to nearest distance */
  for(row=0;row< me->old_nb_frame; row++)
   {
	/* Changed this block for Fix: 179601804	*/

	text_value[0] = '\0';
        FIfld_get_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,DEP_NEW_N,
                    39,(unsigned char*)text_value,&sel_flag,&r_pos);
        FIfld_set_default_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,
                               DEP_NEW_N,text_value,0);
        FIfld_get_value(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,DEP_NEW_X,
                        &value,&sel_flag,&r_pos);
        if ( value )
                sprintf(text_value,"%g",value);
        else
                text_value[0] = '\0';
        FIfld_set_default_text(me->forms[0].form_ptr,DEPANDANCE_FIELD,row,
                               DEP_NEW_X,text_value,0);
   }

  _FREE(fr_pos);
  _FREE(new_fr_pos);
  
  *sts = OM_S_SUCCESS;
 quit:
  return OM_S_SUCCESS;
}

/* Call when reset the form */

static void  reset_mod_form(form,old_nb_frame)
Form form;          /* [I] Pointer to form */             
int old_nb_frame;   /* [I] Number of spacing in the old frame section */ 
{
  long mask;

  FIfld_set_num_rows(form,DEPANDANCE_FIELD,old_nb_frame);
  FImcf_get_attr(form,DEPANDANCE_FIELD,&mask);
  FImcf_set_attr(form,DEPANDANCE_FIELD,mask | FI_ROW_SELECT);
  FImcf_get_attr(form,NEWLIST_FIELD,&mask);
  FImcf_set_attr(form,NEWLIST_FIELD,mask | FI_ROW_SELECT);
}


/* Compute the position of the old and the new frame */
/* The old frame are supposed in increasing order */
/* Alloc fr_pos and new_fr_pos which must be deallocated by user */

static int compute_frame_pos(old_dep_grid,old_nb_frame,nb_new_frame,
			     fr_number1,fr_pos,new_fr_pos)
struct GRid old_dep_grid[];    /* [I] Array of the old frame */
IGRint old_nb_frame;           /* [I] Number of element in old_dep_grid */
IGRint nb_new_frame;           /* [I] New number of frame */
IGRint fr_number1;             /* [I] Number of first frame in the section */
IGRdouble **fr_pos;            /* [O] Position of the old frame */
IGRdouble **new_fr_pos;        /* [O] Position of the new frame */
{
  int i;
  IGRlong status,msg;
  IGRdouble new_spacing;
  IGRdouble *tmp_fr_pos=NULL ,*new_tmp_fr_pos=NULL ;

  tmp_fr_pos =  _MALLOC(old_nb_frame,IGRdouble);     
  new_tmp_fr_pos = _MALLOC(nb_new_frame,IGRdouble);
  
  if(tmp_fr_pos == NULL || new_tmp_fr_pos == NULL)
   {printf("Not enough memory\n"); return 0;}

  for(i=0;i<old_nb_frame;i++)
   {		      
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&msg,&(tmp_fr_pos)[i]),
		      senderid = NULL_OBJID,
		      targetid = old_dep_grid[i].objid,
		      targetos = old_dep_grid[i].osnum );
     if(!(status & msg &1)){ 
		printf ("Error in SMframe.SMgive_rel_position\n");
		_FREE(tmp_fr_pos); 
		_FREE(new_tmp_fr_pos);
       		return 0;
     }

     /* Convert eventually in external unit */
     SMConvDistIntExt(tmp_fr_pos[i],&tmp_fr_pos[i],2); 
   }

  new_spacing = (tmp_fr_pos[old_nb_frame -1] - tmp_fr_pos[0]) / (double)(nb_new_frame -1);
  
  if(fr_number1 >= 0)
   {
     new_tmp_fr_pos[0] = tmp_fr_pos[0];
     for(i=1; i<nb_new_frame; i++)
       new_tmp_fr_pos[i] = new_tmp_fr_pos[i-1] + new_spacing; 
   }
  else
   {
     new_tmp_fr_pos[nb_new_frame -1] = tmp_fr_pos[old_nb_frame -1];
     for(i = nb_new_frame - 2; i >= 0; i--)
       new_tmp_fr_pos[i] = new_tmp_fr_pos[i+1] - new_spacing;
   }

  *new_fr_pos = new_tmp_fr_pos;
  *fr_pos = tmp_fr_pos;

  return 1;
}

/* Set the depandance by nearest distance  */

static int near_dist_dep(form,depandance,old_dep_grid,
			 old_nb_frame,nb_new_frame,fr_number1)
Form form;                     /* [I] Pointer to the form */
IGRshort depandance[];         /* [I] Array contaning depandance */
struct GRid old_dep_grid[];    /* [I] Array of the old frame */
IGRint old_nb_frame;           /* [I] Number of element in old_dep_grid */
IGRint nb_new_frame;           /* [I] New number of frame */
IGRint fr_number1;             /* [I] Number of first frame in the section */
{
  int report_ind,report_number;
  int row,j;
  IGRdouble dist,min_dist;
  IGRdouble *fr_pos=NULL,*new_fr_pos=NULL;
  double fabs();

  if(!compute_frame_pos(old_dep_grid,old_nb_frame,nb_new_frame,
			fr_number1,&fr_pos,&new_fr_pos))
    return 0;
  
  for(row = 0; row < old_nb_frame; row++)
   {
     if(!depandance[row])
       {
	 FIfld_set_text(form,DEPANDANCE_FIELD,row,DEP_NEW_N,"",0);
	 FIfld_set_text(form,DEPANDANCE_FIELD,row,DEP_NEW_X,"",0);
	 continue;
       }

     min_dist = fabs(fr_pos[row] - new_fr_pos[0]);
     report_ind = 0;

   /* The assumption is that frame are sort by increasing number, */
   /* So distance first decrease and when increasing, minimum is reach  */
      
     for(j=1;j< nb_new_frame; j++)
      {
	dist = fabs(fr_pos[row] - new_fr_pos[j]);
	if(dist > min_dist)
	  break;
	else
	 {
	   min_dist = dist;
	   report_ind = j;
	 }
      }

     report_number = fr_number1 + report_ind ;
     FIfld_set_value(form,DEPANDANCE_FIELD,
		     row,DEP_NEW_N,(double)report_number,0);

     FIfld_set_value(form,DEPANDANCE_FIELD,
		     row,DEP_NEW_X,new_fr_pos[report_ind],0);
   }

  _FREE(fr_pos);
  _FREE(new_fr_pos);
  return 1;
}

/* Clear all depandance selected in the form */

static void no_default_dep(form,old_nb_frame)
Form form;            /* [I] Pointer to form */
IGRint old_nb_frame;  /* [I] Number of frame in old section */
{
  int row;

  for(row=0; row < old_nb_frame; row++)
   {
     FIfld_set_text(form,DEPANDANCE_FIELD,row,DEP_NEW_N,"",0);

     FIfld_set_text(form,DEPANDANCE_FIELD,row,DEP_NEW_X,"",0);
   }
}

/* Save what have been enter in the form for depandance */

static int save_mod_frame(form,nb_frame,depandance,old_dep_grid,num_frame)
Form form;                 /* [I] Pointer to form */
int nb_frame;              /* [I] Number of frame in the section */
IGRshort depandance[];     /* [I] Give if old frame has depandance */
struct GRid old_dep_grid[];/* [O] The grid of old frame */ 
IGRint num_frame[];        /* [O] The new num for depandance */
{
  int row;
  int val;
  char text_value[40];
  char my_msg[80];
  int r_pos,sel_flag;

  for(row=0; row <nb_frame; row++)
   {
     if(depandance[row] == FALSE)
       {
	 old_dep_grid[row].objid = NULL_OBJID;
	 continue;
       }
     text_value[0] = '\0';
     FIfld_get_text(form,DEPANDANCE_FIELD,row,DEP_NEW_N,
		    39,(unsigned char*)text_value,&sel_flag,&r_pos);
     if(text_value[0] == '\0' || (sscanf(text_value,"%d",&val) != 1))
      {
	ex$message( msgnumb = SM_E_FrDefDep, buff = my_msg,
		   type = "%d",var = `row`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     
     num_frame[row] = (IGRint)val;
   }
  return 1;
}

/* Function call when depandance field gadget is selected  */

static void select_depandance_field(form,depandance)
Form form;                /* [I] Pointer to form */
IGRshort depandance[];    /* [I] Give if old frame has depandance */
{
  char my_msg[80];
  int i;
  int r_pos,sel_flag = FALSE;
  int row_dep,row_new,num_row_dep,num_row_new;
  IGRdouble value;
  char text_value[40];

  FIfld_get_num_rows(form,DEPANDANCE_FIELD,&num_row_dep);
 /* Find if there is a seleted row in depandance frame list */
  for(row_dep = 0; row_dep < num_row_dep; row_dep++)
   {
     FIfld_get_select(form,DEPANDANCE_FIELD,row_dep,0,&sel_flag);
     if(sel_flag) break;
   }
  if(!sel_flag) return; /* No row selected */
  
  if(depandance[row_dep] == FALSE)  /* This frame have no depandance */
   {
     ex$message( msgnumb = SM_I_FrNoDep, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     /* Deselected the row */
     for(i=0; i<NB_DEP_COL; i++)
       FIfld_set_select(form,DEPANDANCE_FIELD,row_dep,i,FALSE);
     return;
   }

  FIfld_get_num_rows(form,NEWLIST_FIELD,&num_row_new);
  /* Find if there is a seleted row in new frame list */ 
  for(row_new = 0; row_new < num_row_new; row_new++)
   {
     FIfld_get_select(form,NEWLIST_FIELD,row_new,0,&sel_flag);
     if(sel_flag) break;
   } 
  if(!sel_flag)
    {
      ex$message( msgnumb = SM_I_FrWheTo, buff = my_msg);
      FIg_set_text(form,FI_MSG_FIELD,my_msg);
      return;
    }

  /* There is one selected row in new frame list, attach depandancy 
     between the old and new frame */
  FIfld_get_value(form,NEWLIST_FIELD,row_new,NEWFR_NEW_N,
		  &value,&sel_flag,&r_pos);
  sprintf(text_value,"%d",(int)value);
  FIfld_set_text(form,DEPANDANCE_FIELD,row_dep,DEP_NEW_N,text_value,0);
  FIfld_get_value(form,NEWLIST_FIELD,row_new,NEWFR_NEW_X,
		  &value,&sel_flag,&r_pos);
  FIfld_set_value(form,DEPANDANCE_FIELD,row_dep,DEP_NEW_X,value,0); 

  /* Deseleted the seleted row */
  for(i=0; i<NB_DEP_COL; i++)
    FIfld_set_select(form,DEPANDANCE_FIELD,row_dep,i,FALSE);
  for(i=0; i<NB_NEW_COL; i++)
    FIfld_set_select(form,NEWLIST_FIELD,row_new,i,FALSE);
}

/* Function call when newlist field gadget is selected  */

static void select_newlist_field(form,depandance)
Form form;                /* [I] Pointer to form */
IGRshort depandance[];     /* [I] Give if old frame has depandance */
{
  char my_msg[80];
  int i;
  int r_pos,sel_flag = FALSE;
  int row_dep,row_new,num_row_dep,num_row_new;
  IGRdouble value;
  char text_value[40];

  FIfld_get_num_rows(form,NEWLIST_FIELD,&num_row_new);
  /* Find if there is a seleted row in new frame list */ 
  for(row_new = 0; row_new < num_row_new ; row_new++)
   {
     FIfld_get_select(form,NEWLIST_FIELD,row_new,0,&sel_flag);
     if(sel_flag) break;
   }
  if(!sel_flag) return; /* No row selected */
 
  /* Find if there is a seleted row in depandance frame list */ 
  FIfld_get_num_rows(form,DEPANDANCE_FIELD,&num_row_dep);
  for(row_dep = 0; row_dep < num_row_dep; row_dep++)
   {
     FIfld_get_select(form,DEPANDANCE_FIELD,row_dep,0,&sel_flag);
     if(sel_flag) break;
   } 
  if(!sel_flag)
   {
     ex$message( msgnumb = SM_I_FrWheFrom, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return;
   }

  if(depandance[row_dep] == FALSE)  /* This frame have no depandance */
   {
     ex$message( msgnumb = SM_I_FrNoDep, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return;
   }

  /* There is one selected row in new frame list, attach depandancy 
     between the old and new frame */
  FIfld_get_value(form,NEWLIST_FIELD,row_new,NEWFR_NEW_N,
		  &value,&sel_flag,&r_pos);
  sprintf(text_value,"%d",(int)value);
  FIfld_set_text(form,DEPANDANCE_FIELD,row_dep,DEP_NEW_N,text_value,0);
  FIfld_get_value(form,NEWLIST_FIELD,row_new,NEWFR_NEW_X,
		  &value,&sel_flag,&r_pos);
  FIfld_set_value(form,DEPANDANCE_FIELD,row_dep,DEP_NEW_X,value,0); 

  /* Deselected the seleted row */
  for(i=0; i<NB_DEP_COL; i++)
    FIfld_set_select(form,DEPANDANCE_FIELD,row_dep,i,FALSE);
  for(i=0; i<NB_NEW_COL; i++)
    FIfld_set_select(form,NEWLIST_FIELD,row_new,i,FALSE);
}

end implementation SMCmdModSct;

