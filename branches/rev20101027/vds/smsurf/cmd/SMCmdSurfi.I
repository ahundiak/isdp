/* $Id: SMCmdSurfi.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        smsurf/cmd/SMCmdSurfi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdSurfi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/03/12  21:04:24  pinnacle
# Replaced: smsurf/cmd/SMCmdSurfi.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1997/02/06  21:17:10  pinnacle
# Created: smsurf/cmd/SMCmdSurfi.I by jwfrosch for vds.241
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class implementation SMCmdSurf;

#include <math.h>

#define AS_DEBUG	1

from ACrg_collect	import	ACset_list_attribute;
from NDnode		import	ASreturn_go,
				NDchange_connect,
				NDget_objects;
from GRgraphics		import	GRdisplay;
from SMframe		import	SMfind_frm_syst;
from SMmgr		import	SMGetAttTxt;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method init_all ( long * sts )
{
  long		test;
  char		name[DI_PATH_MAX];

  *sts = OM_S_SUCCESS;

  om$send (	msg	 = message VDS_LOCATE.init_all(sts),
		targetid = my_id,
		mode	 = OM_e_wrt_message );

  /* get active ship cs */

  me->coord.objid = NULL_OBJID;
  me->go_cs.objid = NULL_OBJID;

  name[0] = '\0';

  if ( SMGetDefCs ( TRUE, (struct GRid *)NULL, (IGRshort *)NULL, &me->go_cs,
		    &me->coord, &me->cs_env, (IGRboolean *)NULL)
       && me->coord.objid != NULL_OBJID)
  {
    vd$get_name(name = name, obj = &(me->coord));
    if(name[0] == '\0')
    {
      vd$get_name(name = name, obj = &(me->go_cs) );
      if(name[0] == '\0') strcpy(name, "defined");
    }
  }
  FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);

  me->extension		= 0;
  me->ext_x1		= 0.;
  me->ext_x2		= 0.;
  me->ext_y1		= 0.;
  me->ext_y2		= 0.;
  me->ext_z1		= 0.;
  me->ext_z2		= 0.;
  me->frm_sys.objid	= NULL_OBJID;

  me->def_name[0]	= '\0';
  me->macro_id.objid	= NULL_OBJID;
  me->old_macro_id.objid= NULL_OBJID;
  me->reverse		= 0;

  me->old_extension	= 0;
  me->old_ext_x1	= 0.;
  me->old_ext_x2	= 0.;
  me->old_ext_y1	= 0.;
  me->old_ext_y2	= 0.;
  me->old_ext_z1	= 0.;
  me->old_ext_z2	= 0.;

  me->old_def_name[0]	= '\0';
  me->old_reverse	= 0;
  me->g_list		= DEF_FIELD;

//  FIg_set_text ( me->forms[0].form_ptr, EXTENSION, "hull range +10%");
//
//  om$send (	msg	 = message SMCmdSurf.GadgOf(&test),
//		targetid = my_id);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method delete_all ( long * sts )
{
  IGRlong	msg;

  *sts = OM_S_SUCCESS;

  dp$erase_hilite(msg = &msg);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method store_cs ( long * sts )
{
  int		status = OM_S_SUCCESS;
  char		name[MAX_CHAR];

  *sts = OM_S_SUCCESS;

  if(me->coord.objid != NULL_OBJID)
  {
    om$send (	msg	 = message  SMCmdSurf.DispAll(GRhe),
		targetid = my_id);
  }
  me->go_cs = me->event1.located_object[0].located_obj;

  /* Retrieve the name of the coordinate system */

  status = as$make_source (	go_grid = me->go_cs,
				mod_env = &me->event1.located_object[0].module_info,
				as_os   = me->ModuleInfo.md_id.osnum,
				as_grid = &me->coord);
  as$status(action = RET_STATUS);
  me->cs_env = me->event1.located_object[0].module_info;

  name[0] = '\0';
  vd$get_name(name = name, obj = &(me->coord) );

  if(name[0] == '\0')
  {
    /*
     * try to get the name of the graphic object
     */
    vd$get_name(name = name, obj = &(me->go_cs) );
    if(name[0] == '\0') strcpy(name, "defined");
  }

  FIg_set_text(me->forms[0].form_ptr,CS_NAME,name);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method DispAll (enum GRdpmode mode)
{
  int		status = OM_S_SUCCESS;
  IGRlong	msg;
  struct GRid	currentModule ;

  ex$get_cur_mod( id      = &currentModule.objid,
		  osnum   = &currentModule.osnum ) ;

  if(me->go_cs.objid != NULL_OBJID)
  {

    status = om$send (	msg	 = message GRgraphics.GRdisplay(
							&msg,
							&me->cs_env.md_env.matrix_type,
							 me->cs_env.md_env.matrix,
							&mode,
							&currentModule ),
			targetid = me->go_cs.objid,
			targetos = me->go_cs.osnum ) ;
    as$status();
  }

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method pos_cursor ( long * sts )
{
  FIfld_pos_cursor(me->forms[1].form_ptr,DEF_FIELD,0,0,0,0,0,0);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method verif_frame (long *sts; struct GRobj_env *frame)
{
  int		status = OM_S_SUCCESS;
  char		axis[5];
  int		count;
  struct GRid	frm_cs;
  long		msg;
  IGRdouble	matrix[16];
  IGRshort	matrix_type, type;

  *sts = OM_S_SUCCESS;

  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  /* verify that the frame is defined on the given coord syst */

  status =  om$send (	msg	 = message NDnode.NDget_objects(
						    ND_ROOT, &frm_cs, 1, NULL, 0, 0, &count),
			senderid = NULL_OBJID,
			targetid = frame->obj_id.objid,
			targetos = frame->obj_id.osnum);
  as$status(action = RET_STATUS);

  status = om$send (	msg	 = message NDnode.ASreturn_go(&frm_cs,
						    &matrix_type,
						     matrix),
			senderid = NULL_OBJID,
			targetid = frm_cs.objid,
			targetos = frm_cs.osnum ) ;
  as$status(action = RET_STATUS);

  if(frm_cs.objid != me->go_cs.objid ||
     frm_cs.osnum != me->go_cs.osnum)
  {
    FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "Frame must be on the x axis of the cs");
    *sts = OM_E_ABORT;
    goto quit;
  }

  /* verify that the frame is defined on the x axis */

  status = om$send (	msg	 = message SMframe.SMfind_frm_syst(
							&msg,
							&me->frm_sys),
			senderid = NULL_OBJID,
			targetid = frame->obj_id.objid,
			targetos = frame->obj_id.osnum );
  as$status(action = RET_STATUS);
  if(!(status & msg &1 ) )
  {
    printf("Erreur retreiving frame_syst axis\n");
    *sts = OM_E_ABORT;
    goto quit;
  }
  status = om$send (	msg	 = message SMmgr.SMGetAttTxt
						   (&msg,"axis",axis,&type),
			senderid = NULL_OBJID,
			targetid = me->frm_sys.objid,
			targetos = me->frm_sys.osnum );
  as$status();
  if(!(status & msg & 1))
  {
    printf("Erreur SMmgr.SMGetAttTxt\n");
    *sts = OM_E_ABORT;
    goto quit;
  }

  if(axis[0] != 'x' )
  {
    FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "Frame must be on the x axis of the cs");
    *sts = OM_E_ABORT;
    goto quit;
  }

quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method verify_obj ( long * sts )
{
  *sts = OM_S_SUCCESS;

  if(me->go_cs.objid != NULL_OBJID &&
     ! ( om$is_objid_valid( osnum = me->go_cs.osnum,
			    objid = me->go_cs.objid)&1) )
  {
    ex$message(msgnumb = SM_S_ErCsDel);
    me->state = _terminate;
  }

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method GadgOn ( long * sts )
{
  *sts = OM_S_SUCCESS;

  (void) SMVA_display (	me->forms[0].form_ptr, 8,
			EXT_X1, EXT_NMX1,
			EXT_X2, EXT_NMX2,
			EXT_Y1,	EXT_NMY1,
			EXT_Y2, EXT_NMY2);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method GadgOf ( long * sts )
{
  *sts = OM_S_SUCCESS;

  (void) SMVA_erase (	me->forms[0].form_ptr, 8, 
			EXT_X1, EXT_NMX1,
			EXT_X2, EXT_NMX2,
			EXT_Y1,	EXT_NMY1,
			EXT_Y2, EXT_NMY2);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method stop_insert_mode ( long * sts )
{
  int		i ;
  long		mask;

  *sts = OM_S_SUCCESS;

  FImcf_get_attr(me->forms[1].form_ptr,DEF_FIELD,&mask);
  FImcf_set_attr(me->forms[1].form_ptr,DEF_FIELD,mask | FI_REVIEW);

  for(i=0;i<3;i++) FIfld_set_mode(me->forms[1].form_ptr,DEF_FIELD, i ,FI_REVIEW);

  FIg_display(me->forms[1].form_ptr,DEF_FIELD);

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method GetInfoFrmForm (	long *sts;
			IGRdouble *ext_x1;
			IGRdouble *ext_x2;
			IGRdouble *ext_y1;
			IGRdouble *ext_y2 )
{
  int			num_char = MAX_CHAR, sel_flag, r_pos, state;
  char			text[MAX_CHAR];
  struct GRmd_env	hull_env;
  struct GRid		hull, go_hull;

  *sts = OM_S_SUCCESS;

  if(ext_x1) *ext_x1 = 0.;
  if(ext_x2) *ext_x2 = 0.;
  if(ext_y1) *ext_y1 = 0.;
  if(ext_y2) *ext_y2 = 0.;

  if(me->coord.objid == NULL_OBJID)
  {
    FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"ERROR, coord syst not defined");
    ex$message(msgnumb = SM_S_ErCsNtDf);
    *sts =  OM_E_ABORT;
    goto quit;
  }

  /* verif macro name */

  FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0, num_char, text,&sel_flag,&r_pos);

  if(text[0] == '\0')
  {
    if(me->mytype == MODIFY) me->def_name[0] ='\0';
    else
    {
      ex$message(msgnumb = SM_S_ErNoMacNm);
      FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "ERROR, No macro name");
      *sts =  OM_E_ABORT;
      goto quit;
    }
  }
  else
  {
    strcpy(me->def_name, text);
    if(me->mytype == MODIFY)
    {
      if(!SMCanChgElemName(&me->macro_id, text))
      {
	ex$message(msgnumb = SM_S_ErInvMacNm);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "ERROR, Invalid macro name");
	*sts =  OM_E_ABORT;
	goto quit;
      }
    }
  }

  /* store value in instances */

  FIg_get_text(me->forms[0].form_ptr,EXTENSION, text);

  if(strcmp(text,"User Extend") == 0)
  {
    me->extension = 2;
    FIfld_get_value(me->forms[0].form_ptr, EXT_X1, 0, 0, &me->ext_x1, &sel_flag, &r_pos);
    if(ext_x1) SMConvDistExtInt(me->ext_x1, ext_x1, me->ModuleInfo.md_id.osnum);

    FIfld_get_value(me->forms[0].form_ptr, EXT_X2, 0, 0, &me->ext_x2, &sel_flag, &r_pos);
    if(ext_x2) SMConvDistExtInt(me->ext_x2, ext_x2, me->ModuleInfo.md_id.osnum);

    FIfld_get_value(me->forms[0].form_ptr, EXT_Y1, 0, 0, &me->ext_y1, &sel_flag, &r_pos);
    if(ext_y1) SMConvDistExtInt(me->ext_y1, ext_y1, me->ModuleInfo.md_id.osnum);

    FIfld_get_value(me->forms[0].form_ptr, EXT_Y2, 0, 0, &me->ext_y2, &sel_flag, &r_pos);
    if(ext_y2) SMConvDistExtInt(me->ext_y2, ext_y2, me->ModuleInfo.md_id.osnum);

    if( (fabs(me->ext_y1) + fabs(me->ext_y2)) < 1e-4 ||
	(fabs(me->ext_x1) + fabs(me->ext_x2)) < 1e-4 )
    {
      FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "Invalid extensions");
      ex$message(msgnumb = SM_S_ErInvExt);
      *sts =  OM_E_ABORT;
      goto quit;
    }
  }
  else if(!SMGetActHull(&hull,NULL, &hull_env,&go_hull))
  {
    FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, "No Active Hull defined");
    ex$message( msgnumb = SM_S_NoActHl);
    *sts =  OM_E_ABORT;
    goto quit;
  }
  else if(strcmp(text,"hull range +10%") == 0) me->extension = 0;
  else  me->extension = 1;

  FIg_get_state(me->forms[0].form_ptr, ORIENT, &state);

  if(state) me->reverse = 1;
  else me->reverse = 0;

quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method SMMdCsAtt (	struct GRid		*old_cs;
			struct GRid		*old_rg;
			int			 nb_att;
			struct ACrg_coll	*ACrg;
			int			 nb_new;
			struct GRid		*new;
			IGRboolean		*put_batch)
{
  int		status = OM_S_SUCCESS;
  long		msg;

  if(strcmp(me->def_name,me->old_def_name))
  {
    if(!SMChgElemName(&me->macro_id, me->def_name, &me->ModuleInfo))
    {
      printf("Warning: can't change macro name\n");
    }
  }
  *put_batch = TRUE;
  status = om$send (	msg	 = message ACrg_collect.ACset_list_attribute
								(&msg, nb_att, ACrg),
			senderid = NULL_OBJID,
			targetid = old_rg->objid,
			targetos = old_rg->osnum );
  as$status();
  if(!(status & msg & 1))
  {
    printf("Erreur ACrg_collect.ACset_list_attribute\n");
    return OM_E_ABORT;
  }

  if(me->coord.objid != me->old_coord.objid ||
     me->coord.osnum != me->old_coord.osnum)
  {
    status = om$send (	msg	 = message NDnode.NDchange_connect
							(1, old_cs, &new[0]),
			senderid = NULL_OBJID,
			targetid = me->macro_id.objid,
			targetos = me->macro_id.osnum );
    as$status();
    if(!(status & 1))
    {
      printf("Erreur NDnode.NDchange_connect of the coord sys\n");
      return OM_E_ABORT;
    }
    *put_batch = TRUE;
  }

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method SMmodif_mac (	int			 nb_att;
			struct ACrg_coll	*ACrg;
			int			 nb_new;
			struct GRid		*new)
{
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method verify_input_row ( long * sts ; char * form_ptr ; int label )
{
  int	del, sel,col,pos,row;
  char	text[MAX_CHAR];

  *sts = OM_S_SUCCESS;

  FImcf_get_active_col(form_ptr,label,&col,&pos);
  FIfld_get_active_row(form_ptr,label, &row,&pos);
  FIfld_get_text(form_ptr,label,row,col,MAX_CHAR,text, &sel, &pos);

  if(col == 1)
  {
    del = 0;
    FIfld_get_text(form_ptr, label, row, 0, MAX_CHAR,text, &sel, &pos);

    if(text[0] == '\0') del = 1;

    FIfld_get_text(form_ptr, label, row, 1, MAX_CHAR,text, &sel, &pos);

    if(text[0] == '\0') del = 1;

    if(row > 0 && del)
    {
      FIfld_pos_cursor(form_ptr,label,(row-1),0,0,0,0,0);
      FIfld_delete_rows(form_ptr,label,row,1);
    }
  }

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method form_notification (	int	 form_label;
				int	 gadget_label ;
				double	 value ;
				char	*form_ptr)
{
  int		status = OM_S_SUCCESS;
  long		test;
  char		text[MAX_CHAR];

  if ( form_ptr == NULL )
  {
    /*| no form_ptr set */
    return( OM_E_INVARG );
  }

  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
    case FI_EXECUTE:
    case FI_RESET:
    case FI_CANCEL:
    case DEL_ROW:
    case INSERT_ROW:
    case DEF_FIELD:
    case LOC_FRAME:
      {
	om$send (	msg	 = message VDS_LOCATE.form_notification(
							form_label,
							gadget_label,
							value,
							form_ptr),
			mode	 = OM_e_wrt_message,
			targetid = my_id);

	if(gadget_label == FI_EXECUTE)
	  _put_response(resp = RESTART);

	if(gadget_label == FI_RESET)
	  _put_response(resp = MODIF_FORM);
	break;
      }
    case LOAD:
      {
	_put_response(resp = LOAD_OCC);
	break;
      }
    case OCC_NAME:
      {
	FIg_get_text(form_ptr,OCC_NAME, text);
	(void)GetDefName(text,me->def_name);
	FIg_set_text(form_ptr,OCC_NAME,me->def_name);

	break;
      }
    case EXTENSION:
      {
	struct GRmd_env	hull_env;
	struct GRid	hull, go_hull;

	FIg_get_text ( form_ptr, EXTENSION, text);

	if ( strcmp ( text, "hull range +10%" ) == 0 )
	{
	  if ( ! SMGetActHull ( &hull, NULL, &hull_env, &go_hull ) )
	  {
	    FIg_set_text ( form_ptr, FI_MSG_FIELD, "No Active Hull defined");
	    ex$message( msgnumb = SM_S_NoActHl);
	    sleep (2);
	    strcpy ( text, "User Extend" );
	    FIg_set_text ( form_ptr, EXTENSION, text );
	  }
	}

	if(strcmp(text,"User Extend") == 0)
	{
	  me->extension = 2;
	  status = om$send (	msg	 = message SMCmdSurf.GadgOn(&test),
				targetid = my_id);

	  FIfld_pos_cursor(form_ptr,EXT_X1, 0,0,0,0,0,0);
	  FIg_set_text(form_ptr,FI_MSG_FIELD,"Fill the extend");
	}
	else
	  status = om$send (	msg	 = message SMCmdSurf.GadgOf(&test),
				targetid = my_id);
	break;
      }
    case COORDINATE:
      {
	_put_response(resp = LOAD_CS);

	break;
      }
  } /* END switch ( gadget_label ) */

quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation SMCmdSurf;
