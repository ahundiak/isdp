class implementation SMCmdSect;



#define AS_DEBUG	1

#include "UOMdef.h"
#include "UOMmacros.h"
#include "AS_status.h"

from NDnode import NDdisplay;
from GRgraphics import GRdisplay;

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/********************************************************************/

#define _start 0
#define _locate_sect 1
#define _locate_comp 2
#define _locate_fr_frm 3
#define _locate_to_frm 4
#define _form_modify 5
#define _form_sect 6

method erase_hilite ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = dp$erase_hilite (msg = &me->ret,
			    objid = me->ModuleInfo.md_id.objid,
			    osnum = me->ModuleInfo.md_id.osnum);
quit:
  return OM_S_SUCCESS;
}

method hilite_half ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  int 			i;
  enum GRdpmode		mode;
  IGRlong		msg;
  struct GRid		go_cs;
  struct GRmd_env	cs_env;


  mode = GRhhd;

  status = SMGetDefCs(TRUE,                   /* take EMS cs */
		      (struct GRid *)NULL,     /* Connected with Db not needed */
		      (IGRshort *)NULL,        /* State not used */ 
		      &go_cs,     
		      (struct GRid *) NULL,    /* Associative cs not needed */
		      &cs_env, /* No mod env */
		      (IGRboolean *)NULL);     /* No flag needed */
 
  status = om$send(msg     = message GRgraphics.GRdisplay(
                                &msg,
                                &cs_env.md_env.matrix_type,
                                cs_env.md_env.matrix,
                                &mode,
                                &me->ModuleInfo.md_id ),
                targetid= go_cs.objid,
                targetos= go_cs.osnum ) ;
       
  as$status();

  

  if(me->work_info.mode == SM_SECT_USER)
    for(i = 0 ; i < me->work_nb_frame; i++)
     {
       status =  om$send(msg = message NDnode.NDdisplay
			 (0, GRhhd, &me->ModuleInfo),
			 targetid = me->work_frame[i].objid,
			 targetos = me->work_frame[i].osnum);
       as$status(action = CONTINUE,
		 msg = "Warning cannot hilight located frame"); 
     }
quit:
  return OM_S_SUCCESS;
}

method chg_state_button ( int *sts ; IGRboolean enable)
{
  int		  status = OM_S_SUCCESS;

  if(enable)
   {
     SMVA_enable(me->forms[0].form_ptr,10,
		 G_MODE_LIST,G_COMP,G_END_OFFSET,G_NB_SECT,
		 G_SECT_LIST,G_LOCATE_FR,
		 FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[0].form_ptr,G_COMP);
     FIg_set_state_off(me->forms[0].form_ptr,G_LOCATE_FR);
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,10,
		  G_MODE_LIST,G_COMP,G_END_OFFSET,G_NB_SECT,
		  G_SECT_LIST,G_LOCATE_FR,
		  FI_ACCEPT,FI_EXECUTE,FI_RESET);
   }
quit:
  return OM_S_SUCCESS;
}

method toggle_mode ( long *sts ; int mode )
{
  int		  status = OM_S_SUCCESS;

  switch(mode)
   {
   case SM_SECT_SGL:
     SMVA_erase(me->forms[0].form_ptr,7,
		G_FROM_FRAME,G_FR_DX,G_TO_FRAME,G_TO_DX,G_NB_SECT_LAB,
		G_SECT_LIST,G_LOCATE_FR);
     SMVA_display(me->forms[0].form_ptr,2,
		  G_NB_SECT_TEXT,G_NB_SECT);
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Single Part");
     break;
   case SM_SECT_USER:
     SMVA_erase(me->forms[0].form_ptr,2,
		G_NB_SECT_TEXT,G_NB_SECT);
     SMVA_display(me->forms[0].form_ptr,7,
		G_FROM_FRAME,G_FR_DX,G_TO_FRAME,G_TO_DX,G_NB_SECT_LAB,
		G_SECT_LIST,G_LOCATE_FR);
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Multi. Parts");
     break;
   case SM_SECT_AUTO:
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Automatic");
     printf("Not yet implemented auto mode\n");
     break;
   }
quit:
  return OM_S_SUCCESS;
}

method control_unit ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  int     i,row,num_rows,col; 
  IGRlong msg;
  char    tmp[80];
  double  val_db,coef;
  char    cur_unit[40];
  short   flag = 1, num_defaults = 1;
  GRIOalias_name  alias_name[UOM_K_MAX_DEFS];

  /* Get default unit for distance */
  status = uom$get_default_units(msg           = &msg,
				 table_name    = GRIO_DISTANCE,
				 flag          = &flag,
				 num_defaults  = &num_defaults,
				 default_units = alias_name,
                                 osnum         = me->ModuleInfo.md_id.osnum);
  if(status & 1) strcpy( cur_unit, alias_name[0] );
  else uom$report_error(msg = status);

  if(me->save_unit[0] == '\0')
   {
     strcpy(me->save_unit,cur_unit);
     goto quit;
   }

  /* If unit change during wakeup, change current unit and recompute value */
  if(strcmp(me->save_unit,cur_unit))
   {
     coef = 1.0;
     status =
       uom$cvt_value_to_value
	 (msg               = &msg,
	  unit_type         = GRIO_DISTANCE,
	  osnum             = me->ModuleInfo.md_id.osnum,
	  alias_to_cvt_from = me->save_unit,
	  alias_to_cvt_to   = cur_unit,
	  num_vals          = 1,
	  values_in         = &coef,
	  values_out        = &coef);
     if(!(status & 1)) uom$report_error( msg = status);
     
     if(SMget_double(me->forms[0].form_ptr,G_END_OFFSET,0,0,&val_db))
      {
	val_db = val_db * coef;
	FIg_set_value(me->forms[0].form_ptr,G_END_OFFSET,val_db);
      }

     /* If multi part, convert all other offset */
     FIg_get_text(me->forms[0].form_ptr,G_MODE_LIST,tmp);
     if(strncmp(tmp,"Multi",5) == 0)
      {
	FIfld_get_num_rows(me->forms[0].form_ptr,G_SECT_LIST,&num_rows);
	for(row = 0; row < num_rows / 2 ; row++)
	  for(col = 1 ; col <= 3; col += 2)
	    if(SMget_double(me->forms[0].form_ptr,G_SECT_LIST,row,col,&val_db))
	       {
		 val_db = val_db * coef;
		 FIfld_set_value(me->forms[0].form_ptr,G_SECT_LIST,row,col,
				 val_db,0);
	       }
	  
      }
     strcpy(me->save_unit,cur_unit);
   }

  *sts = OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method form_position ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  if(x_pos != -1 || y_pos != -1)
    FIf_set_location(me->forms[0].form_ptr,x_pos,y_pos);

  switch(me->mytype)
    {
    case  PLACE:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Place Calc. Sections");
      break;
    case MODIFY:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Modify Calc. Sections");
      FIg_disable(me->forms[0].form_ptr,G_COMP);
      break;
    }

  /* KLUDGE : TEMPORARY NO AXIS */
  SMVA_disable(me->forms[0].form_ptr,3,G_X_AXIS,G_Y_AXIS,G_Z_AXIS);
  me->save_unit[0] = '\0';
quit:
  return OM_S_SUCCESS;
}

method locate_sect ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  me->sect_id = me->event1.located_object[0].located_obj;
  status = om$send(msg = message SMCmdSect.control_sect(sts),
		   targetid = my_id);
  return status;
quit:
  return OM_S_SUCCESS;
}

method delete_all ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
quit:
  return OM_S_SUCCESS;
}

end implementation SMCmdSect;
