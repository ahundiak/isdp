class implementation ECtpanaly;
/*
** ECtpanaly - Analyze Adjacency between Surfaces
**
** 
**  4/17/94 G. Werner Created
**  6/20/94 B. Burkhardt Update for Redesigned options form
**  8/20/94 B. Burkhardt Update for Investigate Edge Match
**  9/09/94 B. Burkhardt Corrected file name and header line handling
**
*/

# include <stdio.h>
# include <alloca.h>
# include <stdlib.h>
# include "EMSmsgdef.h"
# include "griomacros.h"
# include "exdef.h"
# include "igr.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "grmsg.h"
# include "emserr.h"
# include "dpmacros.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "ECmsg.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "EC_M.h"       /* Command strings */
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"
#include "EMSdpb.h"
#include "exmacros.h"           /* ex$putqueue() */
#include "grmacros.h"           /* gr$display_object() */

#include "TOinclude.h"
#include "TOdsl.h"
#include "TOtopology.h"
#include "TOproto_ds.h"
#include "TOproto_ta.h"
#include "igecolor.h"
#include "igecolmacros.h"

from EMSsubbs		import EMgetedges;

/*
There is the following connection between
   me->state
and the form states:

   form_state = FORM_STATE_AA then:
       me->state - STATE_ADD_SURFACES or STATE_DELETE_SURFACES
   form_state = FORM_STATE_IE then:
       me->state - STATE_IDENTIFY_EDGE

*/

extern char *strdup(char *);

static int version0;
#define CLEAR_DEPENDEND_VERSION if(version0){ \
        FIg_erase(fp,GROUP_RAMIF);  /* Ramification curves */ \
        /*FIfld_set_list_num_rows(fp,FIELD1,NULL,2);multiple defined surfaces,\
                                                    small surfaces,\
                                                    allign surface normal */\
        }

/*
** form1_process_form - 
**   send message form1_do_form
*/
static IGRint form1_process_form ( int form_label, int gadget_label, 
    double value, Form form_ptr)
{

  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


#ifdef DBG
  printf("in process form1\n"); 
#endif

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECtpanaly.form1_do_form (&msg_loc,
                                                       form_label,
                                                       gadget_label, 
                                                       value,form_ptr),
                     senderid = NULL_OBJID, 
                     targetid = cmdobj,
                     targetos = cmdos);
  if(! (stat_OM & 1))
    return (OM_E_ABORT); 

  return (stat_OM); 

}

%safe
   /* storage for the allocated text from gadgets */
   static char *text;
   static int text_size = 0;
%endsafe

static int Get_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char ** text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

    status = FIg_get_type ( fp, g_label, &field_type );

    if ( field_type == FI_MULTI_COL )
    {
        /* Get the col for the MCF */

        FImcf_get_active_col ( fp, g_label, &col, &pos );

    }

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( * text_size < text_len )
    {
        if ( * text_size > 0 )
        {
           /* Realloc space for larger string */
           * text = realloc ( * text, text_len );
        }
        else
        {
           /* Calloc space for string */
           * text = calloc ( 1, text_len );
        }
        * text_size = text_len;
    }

    if ( ! * text )
    {
      * text_size = 0;
      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, col, * text_size,
                            * text, &select_flag, &pos );
    return ( status );
}

static int Get_Unit(
       Form    fp,            /* Pointer to the form     */
       int     g_label,       /* The label of the gadget */
       double  inv,           /* value used, when invalid */
       double  *val)	      /* the value given */
{
    IGRlong EMmsg, status;

    status = Get_text ( fp , g_label, & text, & text_size );

    if ( status != FI_SUCCESS )
    {
#ifdef DBG
	printf("Invalid getting text\n");
#endif
	*val = inv;
	return status;
    }

    status = co$expreval(
         msg = &EMmsg,
         scale_flag = GRIO_NO_SCALE, /* Scaling on ACS not supported for tol */
         expression = text,
         unit_type = g_label == FIELD_A3_TO || g_label == FIELD_I2_TO ? 
                          "UOM_ANGLE" : "UOM_DISTANCE",
         /*               Angle       :  distance */
         result = val);
    if (!(1&EMmsg&status))
    {
#ifdef DBG
	printf("Invalid unit string: %s, reset to %f\n",
			text,inv);
#endif
	*val = inv;
    }

    return FI_SUCCESS;
}

static int Set_Unit(
       Form    fp,            /* Pointer to the form     */
       int     g_label,       /* The label of the gadget */
       double  value)	      /* the value given */
{
    char *al;
    char alpha[80];
    IGRlong status, EMmsg;

    alpha[0] = '\0';

    if(g_label == FIELD_A3_TO || g_label == FIELD_I2_TO)
    {
	/* angle */
	struct GRid           module_grid;


        IGRshort num_alias = 3;
        IGRshort field_size = 25;

        status = ex$get_cur_mod( id    = &module_grid.objid,
                          osnum = &module_grid.osnum );

        status = co$cvt_imp_to_alias(msg = &EMmsg,
                                     unit_type = "UOM_ANGLE",
				     osnum = module_grid.osnum,
                                     working_units = &value,
                                     num_alias = &num_alias,
                                     field_size = &field_size,
                                     cvt_list = alpha);

    }
    else
    {
       status = EFconvert_to_user_units(
		value,
		TRUE,
		alpha,
		&EMmsg);
    }
    if( !(1&status&EMmsg) )
    {
#ifdef DBG
	printf("Cannot convert to user units %s\n",alpha);
#endif
	sprintf(alpha,"%lG", value);
    }
    al = alpha;
    while(*al == ' ')++al;
    FIg_set_text(fp,g_label,al);
    return FI_SUCCESS;
}

/*
Name

    put_line_to_queue

Abstract

    put something into input queue, so that execute message
    can switch state

Synopsis

    static int put_line_to_queue()

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    15 Feb 94   GWW     Creation
*/
static int put_line_to_queue()
{
    IGRchar buffer[2];
    long n;
    int resp;
    IGRlong msg_loc;

    buffer[0] = '\n';
    buffer[1] = '\0';
    n = 1;
    resp = EX_CHAR;
    ex$putque(msg = &msg_loc,
              response = &resp,
              byte = &n,
              buffer = buffer);

    return OM_S_SUCCESS;
}

/*
Name

    toggle_add_delete_surface

Abstract

    switch state for add or delete surface

Synopsis

    static int toggle_add_delete_surface(int state,Form fp)

    state           - TRUE - add delete surface
                      FALSE - delete surfaces

    fp              - form

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    15 Feb 94   GWW     Creation
*/
static int toggle_add_delete_surface(int add_surface,Form fp,
	short *status)
{
         if(add_surface)
         {
            FIg_set_state_off(fp,BUTTON2);
            FIg_set_state_on(fp,BUTTON1);
            if(*status != STATE_ADD_SURFACES)
            {
               /* set something onto the queue */
	       put_line_to_queue();
               *status = STATE_ADD_SURFACES;
            }
         }
         else 
         {
            FIg_set_state_on(fp,BUTTON2);
            FIg_set_state_off(fp,BUTTON1);
            if(*status != STATE_DELETE_SURFACES)
            {
               /* set something onto the queue */
	       put_line_to_queue();
               *status = STATE_DELETE_SURFACES;
            }
         }
         return OM_S_SUCCESS;
}

static int change_execute_state(Form fp, struct TOPO_param *param,
	short *state)
{
  int state1;

   switch(param->form_state)
   {
      case FORM_STATE_NO:
         param->form_state = FORM_STATE_AA;
      case FORM_STATE_AA:
              /* Analyse Adjacency */
         FIg_get_state(fp,BUTTON1,&state1);
         if(state1) /* add surface */
         {
            if(*state != STATE_ADD_SURFACES )
            {
               *state = STATE_ADD_SURFACES;
               put_line_to_queue();
            }
         }
         else
         {
            if(*state != STATE_DELETE_SURFACES)
            {
               *state = STATE_DELETE_SURFACES;
               put_line_to_queue();
            }
         }
      break;
   case FORM_STATE_IE:
               /* investigate edge match */
      if(*state != STATE_IDENTIFY_EDGE)
      {
         *state = STATE_IDENTIFY_EDGE;
         put_line_to_queue();
      }
   break;
   case FORM_STATE_MM:
                 /* multi defined surfaces  */
      FIg_get_state(fp,BUTTON1,&state1);
      if(state1) /* add surface */
      {
         if(*state != STATE_ADD_SURFACES )
         {
            *state = STATE_ADD_SURFACES;
            put_line_to_queue();
         }
      }
      else
      {
         if(*state != STATE_DELETE_SURFACES)
         {
            *state = STATE_DELETE_SURFACES;
            put_line_to_queue();
         }
      }
   break;
   case FORM_STATE_DT:
                 /* Drop Set */
   break;
   default:
#ifdef DBG
      fprintf(stderr,"Invalid form status 0x%x\n",param->form_state);
#endif
      return OM_E_ABORT;
   }
   return OM_S_SUCCESS;
}

/*
Name

    display_form

Abstract

    change form displayed according to current command

Synopsis

    static int display_form(Form fp, struct TOPO_param *param,
	int erase, short *state)

    fp              - form
    param           - structure containing current parameter set
    erase           - if true, erase color displayed
    state           - state of execute method

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    15 Feb 94   GWW     Creation
    20 Jun 94   B.Burkhardt         rework options form
*/
static int display_form(Form fp, struct TOPO_param *param,
	int erase, short *state)
{
  int status;
  char text[64];
  int  length;
  int  sel_flag;
  erase = erase;

  FIg_erase(fp,GROUP_ANALYZE);
  FIg_erase(fp,GROUP_INVEST);
  FIg_erase(fp,GROUP_RAMIF);

  FIg_set_state(fp,CHLIST_A1,param->option & TOPO_DO_OUTER_BOUNDARY);
  FIg_set_state(fp,CHLIST_A2,param->option & TOPO_DO_VIOLATED_CONTI);
  FIg_set_state(fp,CHLIST_A3,param->option & TOPO_DO_VIOLATED_NORMA);
  FIg_set_state(fp,CHLIST_A4,param->option & TOPO_DO_VIOLATED_RADIU);

  FIg_set_state(fp,CHLIST_I1,param->option & TOPO_MO_DISTANCE);
  FIg_set_state(fp,CHLIST_I2,param->option & TOPO_MO_NORMAL);
  FIg_set_state(fp,CHLIST_I3,param->option & TOPO_MO_RADIUS);

  FIg_set_state(fp,TOGGLE_I1,param->option & TOPO_MO_UV);

  /*indicate_all_colors(fp, param,TRUE, FALSE);*/

  Set_Unit(fp,FIELD_A1_TO , param->topology_tolerance);
  FIg_set_value(fp,FIELD_A1_LY , (double) param->layer[0]);
  FIg_set_value(fp,FIELD_A1_CO , (double) param->color[0]);
  FIg_set_value(fp,FIELD_A1_WT , (double) param->weight[0]);
  FIg_set_value(fp,FIELD_A1_ST , (double) param->style[0]);
  Set_Unit(fp,FIELD_A2_TO , param->diagnosis_distance_tolerance);
  FIg_set_value(fp,FIELD_A2_LY , (double) param->layer[1]);
  FIg_set_value(fp,FIELD_A2_CO , (double) param->color[1]);
  FIg_set_value(fp,FIELD_A2_WT , (double) param->weight[1]);
  FIg_set_value(fp,FIELD_A2_ST , (double) param->style[1]);
  Set_Unit(fp,FIELD_A3_TO , param->diagnosis_angle_tolerance);
  FIg_set_value(fp,FIELD_A3_LY , (double) param->layer[2]);
  FIg_set_value(fp,FIELD_A3_CO , (double) param->color[2]);
  FIg_set_value(fp,FIELD_A3_WT , (double) param->weight[2]);
  FIg_set_value(fp,FIELD_A3_ST , (double) param->style[2]);
  FIg_set_value(fp,FIELD_A4_TO , (double) param->diagnosis_radius_tolerance);
  FIg_set_value(fp,FIELD_A4_LY , (double) param->layer[3]);
  FIg_set_value(fp,FIELD_A4_CO , (double) param->color[3]);
  FIg_set_value(fp,FIELD_A4_WT , (double) param->weight[3]);
  FIg_set_value(fp,FIELD_A4_ST , (double) param->style[3]);
  FIg_set_value(fp,FIELD_A_NOP , (double) param->number_of_diagnosis_points);
  FIg_set_state(fp,TOGGLE_A1,param->option & TOPO_DO_CURVATURE_DIAG);
  FIg_set_state(fp,TOGGLE_A2,param->option & TOPO_DO_INTERIOR_OF_CO);

  Set_Unit(fp,FIELD_I1_TO , param->distance);
  FIg_set_value(fp,FIELD_I1_LY , (double) param->edge_layer[0]);
  FIg_set_value(fp,FIELD_I1_CO , (double) param->edge_color[0]);
  FIg_set_value(fp,FIELD_I1_WT , (double) param->edge_weight[0]);
  Set_Unit(fp,FIELD_I2_TO , param->normal);
  FIg_set_value(fp,FIELD_I2_LY , (double) param->edge_layer[1]);
  FIg_set_value(fp,FIELD_I2_CO , (double) param->edge_color[1]);
  FIg_set_value(fp,FIELD_I2_WT , (double) param->edge_weight[1]);
  FIg_set_value(fp,FIELD_I3_TO , (double)param->radius);
  FIg_set_value(fp,FIELD_I3_LY , (double) param->edge_layer[2]);
  FIg_set_value(fp,FIELD_I3_CO , (double) param->edge_color[2]);
  FIg_set_value(fp,FIELD_I3_WT , (double) param->edge_weight[2]);

  FIg_set_value(fp,FIELD_I_NOP , (double) param->number_of_edge_match_points);

  FIg_set_text(fp,FIELD_I_FILE ,
               param->file_name == NULL ? "" : param->file_name);
  FIg_set_text(fp,FIELD_I_HEAD ,
               param->header_line == NULL ? "" : param->header_line);

  switch(param->form_state)
  {
      case FORM_STATE_NO:
      case FORM_STATE_AA:
      /* analyse topology */
         status = FIfld_get_list_text_length(fp,FIELD1,0,
                                             NULL,&length);
         status = FIfld_get_list_text(fp,FIELD1,0,NULL,length,
                                      text,&sel_flag);
         status = FIfld_set_list_default_text(fp,FIELD1,0,
                                              NULL,text,1);
       
         status = FIg_enable(fp,GROUP_ANALYZE); 
         status = FIg_display(fp,GROUP_ANALYZE); 
	 CLEAR_DEPENDEND_VERSION
         
         status = FIg_set_state_off(fp,BUTTON3);
         status = FIg_set_state_off(fp,BUTTON4);
         status = FIg_enable(fp,FIELD1);
         status = FIg_display(fp,FIELD1);
         status = FIg_enable(fp,TOGGLE1);
         status = FIg_enable(fp,BUTTON3);
         status = FIg_enable(fp,BUTTON4);
         status = FIg_enable(fp,GROUP_ADD_DEL);
      break;
      case FORM_STATE_IE:
      /* investigate edge match*/
            status = FIfld_get_list_text_length(fp,FIELD1,1,
                                                NULL,&length);
            status = FIfld_get_list_text(fp,FIELD1,1,NULL,length,
                                         text,&sel_flag);
            status = FIfld_set_list_default_text(fp,FIELD1,1,
                                                 NULL,text,1);
       
            status = FIg_enable(fp,FIELD1);
            status = FIg_display(fp,FIELD1);
            status = FIg_enable(fp,GROUP_INVEST); 
            status = FIg_display(fp,GROUP_INVEST); 
            status = FIg_disable(fp,BUTTON3);
            status = FIg_enable(fp,BUTTON4);
            status = FIg_set_state_off(fp,BUTTON3);
            status = FIg_set_state_off(fp,BUTTON4);
            status = FIg_disable(fp,GROUP_ADD_DEL);
      break;
      case FORM_STATE_MM:
                 /* multi defined surfaces */
            status = FIg_enable(fp,FIELD1);
         FIg_erase(fp,GROUP_ANALYZE);
         FIg_erase(fp,GROUP_INVEST);
         status = FIg_enable(fp,BUTTON3);
         status = FIg_set_state_off(fp,BUTTON3);
         status = FIg_enable(fp,BUTTON4);
         status = FIg_set_state_off(fp,BUTTON4);
         status = FIg_enable(fp,GROUP_ADD_DEL);
      break;
      case FORM_STATE_DT:
                 /* Drop Set */
         status = FIg_disable(fp,FIELD1);
         status = FIg_enable(fp,TOGGLE1);
         status = FIg_disable(fp,BUTTON3);
         status = FIg_disable(fp,GROUP_ADD_DEL);
         status = FIg_disable(fp,GROUP_ANALYZE);
         /*status = FIg_display(fp,GROUP_ANALYZE);
         status = FIg_erase(fp,GROUP_INVEST);*/
         status = FIg_disable(fp,GROUP_INVEST);
         status = FIg_enable(fp,BUTTON4);
         status = FIg_set_state_off(fp,BUTTON3);
      break;

      default:
#ifdef DBG
         fprintf(stderr,"Invalid form status 0x%x\n",param->form_state);
#endif
         return OM_E_ABORT;
  }
  change_execute_state(fp,param,state);
  return OM_S_SUCCESS;
}

/*
Name

    execute_current_action

Abstract

    do the "action" (e.g. analyze adjacency) requested
    by the form

Synopsis

    method execute_current_action()

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    17 Feb 94   GWW     Creation
*/
method execute_current_action()
{
  IGRint stat_OM;
  int  state;
  int  ret;

  /* in case, that we currently in accept state, end 
  ** this state 
  */
  put_line_to_queue();

  /*printf("me->top.pa.form_state %s \n",me->top.pa.form_state);*/
  switch(me->top.pa.form_state)
  {
    case FORM_STATE_NO: /* nothing to do, as long as there are
                        ** no surfaces selected
		        */
#ifdef DBG
	 printf("FORM_STATE_NO\n");
#endif
         /* check if surface selected */
         if(me->n_surface_list <= 0) break;

         /* continue with analyze adjacency */

    case FORM_STATE_AA: /* analyze adjacency */
    {
         int tmp_option; 
         int n_out_bdr; 
         int n_poi_con;
         int n_nor_con;
         int n_rad_con;
         int n_ramific;
         struct elist *out_bdr_head = NULL;
         struct elist *out_bdr_tail = NULL;
         struct telist *poi_con_head = NULL;
         struct telist *poi_con_tail = NULL;
         struct telist *nor_con_head = NULL;
         struct telist *nor_con_tail = NULL;
         struct telist *rad_con_head = NULL;
         struct telist *rad_con_tail = NULL;
         struct telist *ramific_head = NULL;
         struct telist *ramific_tail = NULL;
         int          n_poi_p_con = NULL;
         struct point *p_con_head = NULL;
         struct point *p_con_tail = NULL;
         int          n_poi_n_con = NULL;
         struct point *n_con_head = NULL;
         struct point *n_con_tail = NULL;
         int          n_poi_r_con = NULL;
         struct point *r_con_head = NULL;
         struct point *r_con_tail = NULL;

         /* remove results of Investigate Edge Match */
         if( me->top.pa.temporary_points->displayed_object.objid != NULL)
         {
            /* remove the temporary popints when it is temporary
            */
	    TOdelete_points( &me->top, TRUE);
         }
         /* delete edge buffer*/
         me->n_ed_list = NULL;
         if(me->edge_list != NULL)
         {
            free(me->edge_list);
            me->edge_list = NULL;
         }
         if(me->ed_list != NULL)
         {
            free(me->ed_list);
            me->ed_list = NULL;
         }
         me->n_edge = NULL;
         me->ed[0]  = NULL;
         me->ed[1]  = NULL;

         if(me->recalculate)
	 {
	    /* preliminary: delete basis topology and recalculate
            ** everything
            */
            struct GRid *list = 
		alloca(sizeof(struct GRid ) * me->n_surface_list);
            int i;

            for(i=0;i<me->n_surface_list;++i)
                list[i] = me->surface_list[i].located_obj;

            tmp_option = me->top.pa.option;
            me->top.pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
	    TOdelete_topology( &me->top);
            me->top.pa.option = tmp_option;
            TOinit( &me->top);
	    ret = TOadd_surfaces( &me->top, me->n_surface_list, list);
            if (ret)
            {
#ifdef DBG
              fprintf(stderr,"Error TOadd_surfaces\n");
#endif
              me->recalculate = FALSE;
              break;
            }
	 }

         /* highlight surfaces */
         stat_OM = om$send(
	        msg = message ECtpanaly.highlight_surfaces( HIGHLIGHT_MODE,
				FALSE ),
	              senderid = NULL_OBJID,
	              targetid = my_id
	              );

	 /* printf("FORM_STATE_AA analyze adjacency\n"); */
         TOanalyze_top( &me->top ,
		&n_out_bdr, &out_bdr_head, &out_bdr_tail,
		&n_poi_con, &poi_con_head, &poi_con_tail,
		&n_nor_con, &nor_con_head, &nor_con_tail,
		&n_rad_con, &rad_con_head, &rad_con_tail,
		&n_ramific, &ramific_head, &ramific_tail,
                &n_poi_p_con, &p_con_head, &p_con_tail,
                &n_poi_n_con, &n_con_head, &n_con_tail,
                &n_poi_r_con, &r_con_head, &r_con_tail);

         if( me->top.pa.temporary_objects->displayed_object.objid != NULL)
         {
               /* remove the temporary object, because it is
               ** redrawn immediatly
               */
               tmp_option = me->top.pa.option;
               me->top.pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
	       TOdelete_temp( &me->top, FALSE);
               me->top.pa.option = tmp_option;
         }

         /* display the information */
         TOdisplay( &me->top ,
		n_out_bdr, out_bdr_head, out_bdr_tail,
		n_poi_con, poi_con_head, poi_con_tail,
		n_nor_con, nor_con_head, nor_con_tail,
		n_rad_con, rad_con_head, rad_con_tail,
		n_ramific, ramific_head, ramific_tail,
                n_poi_p_con, p_con_head, p_con_tail,
                n_poi_n_con, n_con_head, n_con_tail,
                n_poi_r_con, r_con_head, r_con_tail);

         if(out_bdr_head != NULL) 
		TOfree_list_elist( &me->top , out_bdr_head, out_bdr_tail);
         if(poi_con_head != NULL) 
		TOfree_list_telist( &me->top , poi_con_head, poi_con_tail);
         if(nor_con_head != NULL) 
		TOfree_list_telist( &me->top , nor_con_head, nor_con_tail);
         if(rad_con_head != NULL) 
		TOfree_list_telist( &me->top , rad_con_head, rad_con_tail);
         if(ramific_head != NULL)
		TOfree_list_telist( &me->top , ramific_head, ramific_tail);
         if(p_con_head != NULL)
		TOfree_list_point( &me->top , p_con_head, p_con_tail);
         if(n_con_head != NULL)
		TOfree_list_point( &me->top , n_con_head, n_con_tail);
         if(r_con_head != NULL)
		TOfree_list_point( &me->top , r_con_head, r_con_tail);

         me->recalculate = FALSE;
    }
    break;

    case FORM_STATE_IE: /* investigate edge match */
    {
       int tmp_option; 
       int n_poi_p_con; 
       int n_poi_n_con; 
       int n_poi_r_con; 
       struct point *p_con_head = NULL;
       struct point *p_con_tail = NULL;
       struct point *n_con_head = NULL;
       struct point *n_con_tail = NULL;
       struct point *r_con_head = NULL;
       struct point *r_con_tail = NULL;

#ifdef DBG
       printf("FORM_STATE_IE investigate edge match\n");
#endif
       /* EC_investigate_edge_match(...) */
       /* ... */
       TOinvest_edge_match(&me->top, me->ed[0],me->ed[1],
	                   &n_poi_p_con, &p_con_head, &p_con_tail,
	                   &n_poi_n_con, &n_con_head, &n_con_tail,
	                   &n_poi_r_con, &r_con_head, &r_con_tail);
       me->recalculate = FALSE;
       me->state = STATE_IDENTIFY_EDGE;
       if( me->top.pa.temporary_points->displayed_object.objid != NULL)
       {
               /* remove the temporary object, because it is
               ** redrawn immediatly
               */
               tmp_option = me->top.pa.option;
               me->top.pa.option &= ~TOPO_DO_POINTS;
	       TOdelete_points( &me->top, TRUE);
               me->top.pa.option = tmp_option;
         }

         /* display the information */
         TOdisplay_points( &me->top ,
	                    n_poi_p_con, p_con_head, p_con_tail,
	                    n_poi_n_con, n_con_head, n_con_tail,
	                    n_poi_r_con, r_con_head, r_con_tail);

         if(p_con_head != NULL) 
		TOfree_list_point( &me->top , p_con_head, p_con_tail);
         if(n_con_head != NULL) 
		TOfree_list_point( &me->top , n_con_head, n_con_tail);
         if(r_con_head != NULL) 
		TOfree_list_point( &me->top , r_con_head, r_con_tail);
    }
    break;

    case FORM_STATE_MM: /* Multi defined Surfaces  */
#ifdef DBG
	 printf("FORM_STATE_MM Multi defined Surfaces\n");
#endif
    {
         int tmp_option; 
         int n_out_bdr = NULL; 
         int n_poi_con = NULL;
         int n_nor_con = NULL;
         int n_rad_con = NULL;
         int n_ramific = NULL;
         struct elist *out_bdr_head = NULL;
         struct elist *out_bdr_tail = NULL;
         struct telist *poi_con_head = NULL;
         struct telist *poi_con_tail = NULL;
         struct telist *nor_con_head = NULL;
         struct telist *nor_con_tail = NULL;
         struct telist *rad_con_head = NULL;
         struct telist *rad_con_tail = NULL;
         struct telist *ramific_head = NULL;
         struct telist *ramific_tail = NULL;
         int           n_poi_p_con = NULL;
         struct point  *p_con_head = NULL;
         struct point  *p_con_tail = NULL;
         int           n_poi_n_con = NULL;
         struct point  *n_con_head = NULL;
         struct point  *n_con_tail = NULL;
         int           n_poi_r_con = NULL;
         struct point  *r_con_head = NULL;
         struct point  *r_con_tail = NULL;


         if(me->recalculate)
	 {
	    /* preliminary: delete basis topology and recalculate
            ** everything
            */
            struct GRid *list = 
		alloca(sizeof(struct GRid ) * me->n_surface_list);
            int i;

            for(i=0;i<me->n_surface_list;++i)
                list[i] = me->surface_list[i].located_obj;

            tmp_option = me->top.pa.option;
            me->top.pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
	    TOdelete_topology( &me->top);
            me->top.pa.option = tmp_option;
            TOinit( &me->top);
	    ret = TOadd_surfaces( &me->top, me->n_surface_list, list);
            if (ret)
            {
#ifdef DBG
              fprintf(stderr,"Error TOadd_surfaces\n");
#endif
              me->recalculate = FALSE;
              break;
            }
	 }

         /* highlight surfaces */
         stat_OM = om$send(
	        msg = message ECtpanaly.highlight_surfaces( HIGHLIGHT_MODE,
				FALSE ),
	              senderid = NULL_OBJID,
	              targetid = my_id
	              );

#ifdef DBG
	 printf("FORM_STATE_MM multi defined surfaces\n");
#endif
         TOmulti_surfaces( &me->top ,
                           &n_out_bdr, &out_bdr_head, &out_bdr_tail);

         if( me->top.pa.temporary_objects->displayed_object.objid != NULL)
         {
               /* remove the temporary object, because it is
               ** redrawn immediatly
               */
               tmp_option = me->top.pa.option;
               me->top.pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
	       TOdelete_temp( &me->top, FALSE);
               me->top.pa.option = tmp_option;
         }
         /* display the information */
         TOdisplay( &me->top ,
		n_out_bdr, out_bdr_head, out_bdr_tail,
		n_poi_con, poi_con_head, poi_con_tail,
		n_nor_con, nor_con_head, nor_con_tail,
		n_rad_con, rad_con_head, rad_con_tail,
		n_ramific, ramific_head, ramific_tail,
                n_poi_p_con, p_con_head, p_con_tail,
                n_poi_n_con, n_con_head, n_con_tail,
                n_poi_r_con, r_con_head, r_con_tail);

         if(out_bdr_head != NULL) 
		TOfree_list_elist( &me->top , out_bdr_head, out_bdr_tail);

         me->recalculate = FALSE;
    }
    break;
    case FORM_STATE_DT: /* Drop Set  */
    {
       /* printf("FORM_STATE_DT Drop Set\n"); */
         FIg_get_state(me->form1_form,BUTTON4,&state);
	 if(state)
	 {
            me->recalculate = TRUE;
            TOdelete_topology(&me->top);
            TOinit( &me->top);
            /* unhighlight surfaces */
            stat_OM = om$send(
	        msg = message ECtpanaly.highlight_surfaces( GRhe, FALSE ),
	              senderid = NULL_OBJID,
	              targetid = my_id
	              );
            me->n_surface_list = 0;
            me->n_ed_list = 0;
            me->state = STATE_INVOKE;
         }
         else
	 {
	    /* printf(".. do not delete\n"); */
	 }
         /*Get_text ( me->form1_form, FIELD1, & text, & text_size );
         me->top.pa.form_state = text[0];*/
         me->top.pa.form_state = FORM_STATE_AA;
    }
    break;

    default:
	 fprintf(stderr,"Invalid action form_state %d\n",
		me->top.pa.form_state);
  }
  return OM_S_SUCCESS;
}


/*
** reset_state
**
** reset state of form to state before start
** of last invocation
*/
static void reset_state(struct TOPO_param *param,
		        struct TOPO_param *save_param)
{
             char *text1;
             /* reset to state before */
	     if(param->file_name != save_param->file_name &&
		param->file_name != NULL)
             {
                if(save_param->file_name != NULL)
                {
                   text1 = (char *)strdup(save_param->file_name);
                   free(param->file_name);
                   save_param->file_name = (char *)strdup(text1);  
                }
                else
                   free(param->file_name);
             }

             /* reset to state before */
	     if(param->header_line != save_param->header_line &&
		param->header_line != NULL)
             {
                if(save_param->header_line != NULL)
                {
                   text1 = (char *)strdup(save_param->header_line);
                   free(param->header_line);
                   save_param->header_line = (char *)strdup(text1);
                }
                else 
                   free(param->header_line);
             }

             memcpy( param, save_param, sizeof(struct TOPO_param));
}

/*
Name

    method form1_do_form

Abstract

    process form input

Synopsis

    method form1_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value; Form fp)

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    17 Feb 94   GWW     Creation
    17 Jun 94   B.Burkhardt  Rework options form, include edge match function
*/
method form1_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value; Form fp)
{

   IGRint /* stat_func,*/ stat_OM;
   double fld_value;
   int  index;
   int  col;
   int  layer;
   int  style;
   int  weight;
   int  status;
   int  state1;
   int  state2;
   char *text1;
/*
  GRobjid cmdobj;
  GRspacenum cmdos;
*/



/*
  stat_func = FIf_get_cmd_oid_os (fp, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);
*/

   if(form_label == TOP_FORM1)
   {
      index = 0;
      switch(gadget_label)
      {

         case FI_ACCEPT        :

            status = FIg_set_state_off(fp,FI_ACCEPT);
    	    me->form1_visible = FORM1_INVISIBLE;
	    FIf_erase(me->form1_form);
            GRstatus_display_button(TRUE);

	    /* execute the current action */
            stat_OM = om$send (
	    msg = message ECtpanaly.execute_current_action(),
                  senderid = NULL_OBJID, 
                  targetid = my_id,
                  targetos = OM_Gw_current_OS);
            if(! (stat_OM & 1))
               return (OM_E_ABORT); 
            /* don't change the state */
         break;

         case FI_EXECUTE       :
#ifdef DBG
printf("calling execute\n");
#endif
           /* execute the current action */
            stat_OM = om$send (
            msg = message ECtpanaly.execute_current_action(),
                  senderid = NULL_OBJID, 
                  targetid = my_id,
                  targetos = OM_Gw_current_OS);
            if(! (stat_OM & 1))
               return (OM_E_ABORT); 
            /* don't change the state */
            status = FIg_set_state_off(fp,FI_EXECUTE);
            display_form(me->form1_form, &me->top.pa,FALSE, &me->state);
         break;

         case FI_RESET         :
#ifdef DBG
printf("calling reset\n");
#endif
            /* reset to state before */
            reset_state( &me->top.pa, &me->save_param);
            display_form(fp,&me->top.pa,TRUE, &me->state);
	 break;

	 case FI_CANCEL        :
#ifdef DBG
printf("calling cancel\n");
#endif

            /* reset to state before */
            reset_state( &me->top.pa, &me->save_param);

    	    me->form1_visible = FORM1_INVISIBLE;
	    FIf_erase(me->form1_form);
            GRstatus_display_button(TRUE);

            /* highlight surfaces */
            stat_OM = om$send(
	    msg = message ECtpanaly.highlight_surfaces( HIGHLIGHT_MODE,
			                                FALSE ),
                  senderid = NULL_OBJID,
	          targetid = my_id);
	    /* do not change the state */
            status = FIg_set_state_off(fp,FI_CANCEL);
	 break;

	 case FI_HELP          :
	    /* output help text */
            /* ... */
            /* status = FIg_set_state_off(fp,FI_HELP);*/
            /* break; */
            goto label_unknown;

         case FIELD1:     /* Select type of command, currently:
		             Analyze Adjacency or 
		             Investigate Edgematch
		          */

            /* Get the text string */

            status = Get_text ( fp, gadget_label, & text, & text_size );

            if ( status != FI_SUCCESS )
            {
               /* Code to handle error */
               return OM_E_ABORT;
            }

           /* Code to process text string "text" */
           /* printf("FIELD1 : %s \n",text); */
	   /* 
		A - analyze topology
		I - investigate edge match
		D - display identical surfaces
	   */
           if(strchr("AINM", text[0]) == NULL)
           {
#ifdef DBG
#endif
	      fprintf(stderr,"Impossible selection: %s\n",text);

	      return OM_E_ABORT;
           }

           me->top.pa.form_state = text[0];

           display_form(fp,&me->top.pa,FALSE, &me->state);
        break;

         case TOGGLE1:     /* Graphic Permanent/
                              Graphic Temporary

	    /* printf("toggle1\n"); */
            status = FIg_get_state(fp,TOGGLE1,&state2);
            /* change the appropriate execution flag */
            if(state2)
               me->top.pa.option |= TOPO_DO_GRAPHIC_PERMAN;
            else
               me->top.pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
                       
         break;
   
         case BUTTON2:  index++;   /* Delete Surface from Basis */
         case BUTTON1:             /* Add Surface to basis */

              /* printf("BUTTON%d\n",4 + index); */
              toggle_add_delete_surface(
		     me->n_surface_list == 0 || index == 0 ,
		     fp,&me->state);

         break;

         case BUTTON3:     /* recalculate  Topology */
              /* printf("BUTTON3 : \n"); */
            me->recalculate = TRUE;
         break;

         case BUTTON4:     /* Drop Set */

            /* printf("BUTTON4 : \n"); */
            status = FIg_get_state(fp,BUTTON4,&state2);
            /* change the appropriate execution flag */
            if(state2)
               me->top.pa.form_state = FORM_STATE_DT;
            else
            {
               Get_text ( me->form1_form, FIELD1, & text, & text_size );
               me->top.pa.form_state = text[0];
            } 
            display_form(fp,&me->top.pa,FALSE, &me->state);
         break;

         case TOGGLE_A1:   /* Radius Diagnosis:
                              normal / u/v */
                           /* Member of group GROUP_ANALYZE  */

	    /* printf("toggle_A1\n"); */
            status = FIg_get_state(fp,TOGGLE_A1,&state2);
            /* change the appropriate execution flag */
            if(state2)
               me->top.pa.option |= TOPO_DO_CURVATURE_DIAG;
            else
               me->top.pa.option &= ~TOPO_DO_CURVATURE_DIAG;
           
         break;

         case TOGGLE_A2:   /* Interior of Composite Surfaces
                              Yes /No */
                           /* Member of group GROUP_ANALYZE  */
                           /* Sequenced to    */

	    /* printf("toggle_A2\n"); */
            status = FIg_get_state(fp,TOGGLE_A2,&state2);
            /* change the appropriate execution flag */
            if(state2)
               me->top.pa.option |= TOPO_DO_INTERIOR_OF_CO;
            else
               me->top.pa.option &= ~TOPO_DO_INTERIOR_OF_CO;
           
         break;

         case FIELD_A_NOP:  /* Analyze Adjacency: # of Diag points */
                            /* Sequenced to    */
                            /* Field Type:    INTEGER    */

            /* Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

           /* Code to process the value */
           /* printf("FIELD_A_NOP %5f \n",fld_value); */

           me->top.pa.number_of_diagnosis_points = fld_value;

         break;

         case FIELD_A4_TO:    /* Analyze Adjacency: Radius Tolerance */
                              /* Sequenced to    */
                              /* Field Type:    DOUBLE    */

            /* Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);
            /* printf("FIELD_A4_TO %10.3f \n",fld_value); */

            me->top.pa.diagnosis_radius_tolerance = fld_value;

         break;

         case FIELD_A3_TO:     /* Analyze Adjacency: Angl Tolerance */
                               /* Sequenced to    */
                               /* Field Type:    DOUBLE    */

            /* Get the value of the current active row */

            status = Get_Unit ( fp, gadget_label, 
		     me->top.pa.diagnosis_angle_tolerance, &fld_value);

            /* Code to process the value */
            /* printf("FIELD_A3_TO %10.3f \n",fld_value); */

            Set_Unit(fp,gadget_label, 
                     me->top.pa.diagnosis_angle_tolerance = fld_value);

         break;

         case FIELD_A2_TO:     /* Diagnosis Parameter: Dist Tolerance */
                               /* Sequenced to    */
                               /* Field Type:    DOUBLE    */

            /* Get the value of the current active row */

             status = Get_Unit ( fp, gadget_label, 
		      me->top.pa.diagnosis_distance_tolerance , &fld_value);

             /* Code to process the value */
             /* printf("FIELD_A2_TO %10.3f \n",fld_value); */

             Set_Unit(fp,gadget_label, 
                      me->top.pa.diagnosis_distance_tolerance = fld_value);

         break;

         case FIELD_A1_TO:     /* Diagnosis Parameter: Top Tolerance */
                               /* Sequenced to    */
                               /* Field Type:    DOUBLE    */

            /* Get the value of the current active row */

            status = Get_Unit ( fp, gadget_label, 
	                        me->top.pa.topology_tolerance, &fld_value);

            /* Code to process the value */
            /* printf("FIELD_A1_TO %10.3f \n",fld_value); */

            /* if topology tolerance has changed, everything
             ** has to be recalculated
            */
            if( me->top.pa.topology_tolerance != fld_value)
		me->recalculate = TRUE;

            Set_Unit(fp,gadget_label,me->top.pa.topology_tolerance=fld_value);

         break;

         case CHLIST_A1:     /* Display option: outer boundary curves */
                             /* Member of group GROUP_ANALYZE  */
	    /* printf("CHLIST_A1\n"); */
            status = FIg_get_state(fp,CHLIST_A1,&state1);
            if(state1)
            {
	       me->top.pa.option |= TOPO_DO_OUTER_BOUNDARY;
            }   
	    else
	    {
	       me->top.pa.option &= ~TOPO_DO_OUTER_BOUNDARY ;
	    }
         break;

         case CHLIST_A2:     /* Display option: violated continuity   */
                             /* Member of group GROUP_ANALYZE  */
                             /* Sequenced to    */
            status = FIg_get_state(fp,CHLIST_A2,&state1);
            if(state1)
            {
	       /* printf("CHLIST_A2 now on\n");*/
	       me->top.pa.option |= TOPO_DO_VIOLATED_CONTI;
            }
            else
            {
	      /* printf("CHLIST_A2 now off\n"); */
	       me->top.pa.option &= ~(TOPO_DO_VIOLATED_CONTI
		| TOPO_DO_VIOLATED_RADIU | TOPO_DO_VIOLATED_NORMA);
               status = FIg_set_state_off(fp,CHLIST_A3);
               status = FIg_set_state_off(fp,CHLIST_A4);
            }
         break;

         case CHLIST_A3    : /* Display option: violated normal continuity   */
            status = FIg_get_state(fp,CHLIST_A3,&state1);
            if(state1)
            {
	       /* printf("CHLIST_A3 now on\n"); */
	       me->top.pa.option |= TOPO_DO_VIOLATED_CONTI |
		                    TOPO_DO_VIOLATED_NORMA;
               status = FIg_set_state_on(fp,CHLIST_A2);
            }
            else
            {
	       /* printf("CHLIST_A3 now off\n"); */
               status = FIg_set_state_off(fp,CHLIST_A4);
	       me->top.pa.option &= ~( TOPO_DO_VIOLATED_RADIU | 
				        TOPO_DO_VIOLATED_NORMA);
            }
         break;

         case CHLIST_A4    : /* Display option: violated radius continuity   */
            status = FIg_get_state(fp,CHLIST_A4,&state1);
            if(state1)
            {
	       /* printf("CHLIST_A4 now on\n"); */
	       me->top.pa.option |= TOPO_DO_VIOLATED_CONTI |
	                            TOPO_DO_VIOLATED_NORMA |
	                            TOPO_DO_VIOLATED_RADIU;
               status = FIg_set_state_on(fp,CHLIST_A2);
               status = FIg_set_state_on(fp,CHLIST_A3);
            }
            else
            {
	       /* printf("CHLIST_A4 now off\n"); */
	       me->top.pa.option &= ~TOPO_DO_VIOLATED_RADIU;
            }
         break;

         case CHLIST_A5    : /* Display option: ramification curves */
	    /* printf("CHLIST_A5\n"); */
            status = FIg_get_state(fp,CHLIST_A5,&state1);
            if(state1)
	       me->top.pa.option |= TOPO_DO_RAMIFICATION_C ;
	    else
	       me->top.pa.option &= ~TOPO_DO_RAMIFICATION_C;
         break;

         case FIELD_A5_LY:index++; /* Layer ramification Curves        */
         case FIELD_A4_LY:index++; /* Layer violated radius conti */
         case FIELD_A3_LY:index++; /* Layer violated normal conti */
         case FIELD_A2_LY:index++; /* Layer violated Continuity   */
         case FIELD_A1_LY:         /* Layer Outer Boundary Curves */
     
/*          Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

/*          Code to process the value */

/*          printf("change Layer for #%d Layer= %d (status=%d)\n",
                    index,layer,status); */

/*          store layer number */
            layer = fld_value;
            me->top.pa.layer[index] =layer ;
         break;

         case FIELD_A5_CO:index++; /* Color ramification Curves        */
         case FIELD_A4_CO:index++; /* Color violated radius conti */
         case FIELD_A3_CO:index++; /* Color violated normal conti */
         case FIELD_A2_CO:index++; /* Color violated Continuity   */
         case FIELD_A1_CO:         /* Color Outer Boundary Curves */

/*          Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

/*          Code to process the value */

            col = fld_value;

/*          printf("change color for #%d color= %d (status=%d)\n",
                    index,col,status); */

/*          store color number col for index index */
            me->top.pa.color[index] = col;
         break;

         case FIELD_A5_WT:index++; /* Weight ramification curves  */
         case FIELD_A4_WT:index++; /* Weight violated radius cont */
         case FIELD_A3_WT:index++; /* Weight violated normal cont */
         case FIELD_A2_WT:index++; /* Weight violated continuity  */
         case FIELD_A1_WT:         /* Weight outer boundary curve */

/*          Get the value of the current active row */
     
            status = FIg_get_value ( fp, gadget_label, &fld_value);
     
/*          Code to process the value */
            weight = fld_value;
/*          printf("change weigth for #%d weight= %d \n",index,weight); */
            me->top.pa.weight[index] = weight;
         break;

         case FIELD_A5_ST:index++; /* style ramification Curves        */
         case FIELD_A4_ST:index++; /* style violated radius conti */
         case FIELD_A3_ST:index++; /* style violated normal conti */
         case FIELD_A2_ST:index++; /* style violated Continuity   */
         case FIELD_A1_ST:         /* style Outer Boundary Curves */
               
/*          Get the value of the current active row */
               
            status = FIg_get_value ( fp, gadget_label, &fld_value);
               
/*          Code to process the value */
            style = fld_value;
/*          printf("change style for #%d style= %d (status=%d)\n",
                    index,style,status); */

/*          store layer number */
            me->top.pa.style[index] = style;
         break;

/***************************************************
         The gadgets for 'Investigate Edge Match'
***************************************************/

         case CHLIST_I3:     /* Investigate/ Radius */
                             /* Sequenced to    */

	    /* printf("CHLIST_I3\n"); */
            status = FIg_get_state(fp,CHLIST_I3,&state1);
            if(state1)
            {
	       me->top.pa.option |= TOPO_MO_NORMAL |
	                            TOPO_MO_DISTANCE | TOPO_MO_RADIUS;
               status = FIg_set_state_on(fp,CHLIST_I1);
               status = FIg_set_state_on(fp,CHLIST_I2);
            }
	    else
	       me->top.pa.option &= ~TOPO_MO_RADIUS;
         break;

         case CHLIST_I2:     /* Investigate/ Normal            */
                             /* Sequenced to    */
	    /* printf("CHLIST_I2\n"); */
            status = FIg_get_state(fp,CHLIST_I2,&state1);
            if(state1)
	    {
	       me->top.pa.option |= TOPO_MO_NORMAL |
	                            TOPO_MO_DISTANCE;
               status = FIg_set_state_on(fp,CHLIST_I1);
	    }
	    else
            {
               status = FIg_set_state_off(fp,CHLIST_I3);
	       me->top.pa.option &= ~(TOPO_MO_NORMAL |
	                             TOPO_MO_RADIUS);
               status = FIg_set_state_off(fp,CHLIST_I3);
            }   
         break;

         case CHLIST_I1:     /* Investigate/ Distance         */
	    /* printf("CHLIST_I1\n"); */
            status = FIg_get_state(fp,CHLIST_I1,&state1);
            if(state1)
	    {
	       me->top.pa.option |= TOPO_MO_DISTANCE;
	    }
	    else
            {
	       me->top.pa.option &= ~(TOPO_MO_NORMAL |
	                              TOPO_MO_DISTANCE | TOPO_MO_RADIUS);
               status = FIg_set_state_off(fp,CHLIST_I2);
               status = FIg_set_state_off(fp,CHLIST_I3);
            }   
         break;

         case FIELD_I1_TO:     /* Member of group GROUP_INVEST  */
                               /* Distance */
                               /* Sequenced to    */
                               /* Field Type:    INTEGER    */

            /* Get the value of the current active row */

            status = Get_Unit ( fp, gadget_label, 
			        me->top.pa.distance, &fld_value);

            /* Code to process the value */

	    /* printf("FIELD_I1_TO %f\n",fld_value); */

            Set_Unit(fp,gadget_label, me->top.pa.distance = fld_value);

         break;

         case FIELD_I2_TO:     /* Member of group GROUP_INVEST  */
                               /* Normal */
                               /* Sequenced to    */
                               /* Field Type:    DOUBLE    */

            /* Get the value of the current active row */

            status = Get_Unit ( fp, gadget_label, 
		               me->top.pa.normal , &fld_value);

            /* Code to process the value */
	    /* printf("FIELD_I2_TO %f\n",fld_value); */
     
            Set_Unit(fp,gadget_label, me->top.pa.normal = fld_value);

         break;

         case FIELD_I3_TO:     /* Member of group GROUP_INVEST  */
                               /* Radius */
                               /* Sequenced to    */
                               /* Field Type:    ASCII    */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

            if ( status != FI_SUCCESS )
            {
               /* Code to handle error */

               return OM_E_ABORT;
            }

	    /* store value for radius tolerance*/

            me->top.pa.radius = fld_value;
         break;

         case TOGGLE_I1       : /* Investigate Radius Diagnosis
                                   normal /  u/v */
            status = FIg_get_state(fp,TOGGLE_I1,&state2);
	    /* printf("Toggle_I1\n"); */
            if(state2)
               me->top.pa.option |= TOPO_MO_UV;
            else
               me->top.pa.option &= ~TOPO_MO_UV;
   
	 break;

         case FIELD_I_NOP:     /* Investigate, number of diagnosis points */
            status = FIg_get_value ( fp, gadget_label, &fld_value);
	    /* printf("FIELD_I_NOP %d\n",(int) fld_value); */
            me->top.pa.number_of_edge_match_points = fld_value;
	 break;

         case FIELD_I_FILE:     /* Investigate, file name */
            status = Get_text ( fp, gadget_label, & text, & text_size );

            if ( status != FI_SUCCESS )
            {
                /* Code to handle error */
                return OM_E_ABORT;
            }
            /* printf("FIELD_I_FILE = %s\n",text); */

            if(me->top.pa.file_name != NULL)
            {
               if(me->save_param.file_name != NULL)
               {
                  text1 = (char *)strdup(me->save_param.file_name);
                  free(me->top.pa.file_name);
                  me->save_param.file_name = (char *)strdup(text1);  
               }
               else
                  free(me->top.pa.file_name);
            }
            if(text[0] != '\0')  
               me->top.pa.file_name = strdup(text);
            else
               me->top.pa.file_name = NULL;
	 break;

         case FIELD_I_HEAD:     /* Investigate, header line */
            status = Get_text ( fp, gadget_label, & text, & text_size );

            if ( status != FI_SUCCESS )
            {
                /* Code to handle error */
                return OM_E_ABORT;
            }
            /* printf("FIELD_I_HEAD = %s\n",text); */

            if(me->top.pa.header_line != NULL)
            {
               if(me->save_param.header_line != NULL)
               {
                  text1 = strdup(me->save_param.header_line);
                  free(me->top.pa.header_line);
                  me->save_param.header_line = strdup(text1);  
               }
               else
                  free(me->top.pa.header_line);
            }
            if(text[0] != '\0')  
               me->top.pa.header_line = strdup(text);
            else
               me->top.pa.header_line = NULL;

	 break;

         case FIELD_I3_LY:index++; /* Layer Radius Violation */
         case FIELD_I2_LY:index++; /* Layer Normal Violation */
         case FIELD_I1_LY:         /* Layer Distance Violation   */

/*          Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

/*          Code to process the value */

/*          printf("change Layer for #%d Layer= %d (status=%d)\n",
                    index,layer,status); */

/*          store layer number */
            layer = fld_value;
            me->top.pa.edge_layer[index] =layer ;
         break;

         case FIELD_I3_CO:index++; /* Color Radius Violation */
         case FIELD_I2_CO:index++; /* Color Normal Violation */
         case FIELD_I1_CO:         /* Color Distance Violation   */

/*          Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

/*          Code to process the value */

/*          printf("change Color for #%d Color= %d (status=%d)\n",
                    index,col,status); */

/*          store Color number */
            col = fld_value;
            me->top.pa.edge_color[index] =col ;
         break;

         case FIELD_I3_WT:index++; /* Weight Radius Violation */
         case FIELD_I2_WT:index++; /* Weight Normal Violation */
         case FIELD_I1_WT:         /* Weight Distance Violation   */

/*          Get the value of the current active row */

            status = FIg_get_value ( fp, gadget_label, &fld_value);

/*          Code to process the value */

/*          printf("change Weight for #%d Weight= %d (status=%d)\n",
                    index,weight,status); */

/*          store weight number */
            weight = fld_value;
            me->top.pa.edge_weight[index] =weight ;
         break;

         default:
            printf("Unknown event %d for form\n",gadget_label);
      }
   }
   else
   {
/*      fprintf(stderr,"Invalid form: %d\n",form_label);*/
      return OM_E_ABORT;
   }
   return OM_S_SUCCESS;
label_unknown:
   printf("Unknown event %d.\n", gadget_label);

   return OM_S_SUCCESS;
}


/*
Name

    method setup_form()

Abstract

    display the form (if not yet visible)

Synopsis

    method setup_form()

Description


Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    17 Feb 94   GWW     Creation
*/
method setup_form()
{

  IGRlong 	status, EMmsg;
  /*OM_S_OBJID 	set_id = NULL_OBJID;*/
  int 		ret;
  IGRint 	opt_process_form();
  Form          fp;
  char          *text1;


#ifdef DBG
printf("in setup_form\n");
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;

  if (me->form1_visible == FORM1_DOES_NOT_EXISTS) 
  {
    ret = FIf_new (TOP_FORM1, 
                 "EMAnalyzSurf", 
                 form1_process_form, 
                 &me->form1_form);
    if (ret) {
#ifdef DBG
      fprintf(stderr,"Error (FIf_new): Cannot find FORM \"EMAnalyzSurf\".\n");
#endif
      status = FALSE;
      goto wrapup;
    }
    fp = me->form1_form;

    ret = FIf_set_cmd_oid_os(me->form1_form, 
                           my_id, 
                           OM_Gw_current_OS);
    if (ret) {
#ifdef DBG
      fprintf(stderr,"Error FIf_set_cmd_oid_os\n");
#endif
      status = FALSE;
      goto wrapup;
    } 
    me->form1_visible = FORM1_INVISIBLE;

    /* set the state for the execute message to "add surface" */
    me->state = STATE_ADD_SURFACES;
  

  }


  if (me->form1_visible == FORM1_INVISIBLE) 
  {

#ifdef NOT_USED
    ret = FIf_set_location (me->form1_form, opt_WLOX, opt_WLOY);
    if (ret) {
       fprintf(stderr,"Error FIf_set_location\n");
       status = FALSE;
      goto wrapup;
    }
#endif
  
    /* save current status */
    if(me->save_param.file_name != me->top.pa.file_name &&
       me->save_param.file_name != NULL)/* &&
        me->save_param.file_name[0] !='\0')*/
    {
       if(me->top.pa.file_name != NULL)
       {
          text1 = (char *)strdup(me->top.pa.file_name);
          free(me->save_param.file_name);
          me->top.pa.file_name = (char *)strdup(text1);
       }
       else
          free(me->save_param.file_name);
    }
    if(me->save_param.header_line != me->top.pa.header_line &&
       me->save_param.header_line != NULL)
    {
       if(me->top.pa.header_line != NULL)
       {
          text1 = (char *)strdup(me->top.pa.header_line);
          free(me->save_param.header_line);
          me->top.pa.header_line = (char *)strdup(text1);
       }
       else
          free(me->save_param.header_line);
    }

    memcpy( &me->save_param, &me->top.pa, sizeof(struct TOPO_param));

    /* set defaults for the form */
    display_form(me->form1_form, &me->top.pa,FALSE, &me->state);

    ret = FIf_display(me->form1_form);
    if (ret) {
#ifdef DBG
     fprintf(stderr,"Error FIf_display\n");
#endif
     status = FALSE;
     goto wrapup;
    }

    me->form1_visible = FORM1_VISIBLE;
    /* unhighlight status display button */
    GRstatus_display_button(FALSE);


  }
  else
  {
    change_execute_state(me->form1_form,  &me->top.pa, &me->state);
  }


wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

  return (status); 

}

end implementation ECtpanaly;
