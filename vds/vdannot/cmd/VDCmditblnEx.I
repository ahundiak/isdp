/*
 * ADZ	20/11/1992
 * 
 * In case the object is an occurence of a ACheader object,
 * the returned object (leaf_id) to attach to is found from
 * ACmodel object.
 * In this case the leaf_id will be refused.
 * 
 * Chaya V. Rao 08/30/94
 * 
 * modified the file to make item associative to the object
 * without identifying leaf. ci_macro "midpnts " makes item 
 * associative.
 * changed the interface to achieve this. 
 */
/*===========================================================================*/

class implementation VDCmditbln;

#include "griodef.h"
#include "AS_status.h"
#include "coparadef.h"
#include "coparamac.h"
#include "VDmsg.h"
#include "dpdef.h"
#include "dimdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "dimmacros.h"
#include "grmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "vdandef.h"
#include "vdanmacros.h"

from     NDnode     import  NDchg_state;
from     DMannot    import  ANadd_delete_vertex,set_dim_state;
from     DMsrc      import  DMgive_structure,DMmodify;
from     GRgraphics import  GRlnproject;
from     DMsrc      import  DMdisplay_source;
from     GRowner    import  GRget_number_components, GRget_components;
from     GRgraphics import  GRgetrang;
from     ci_macro   import  init;
from     IGEgragad  import  DPinrot;
from     NDmacro    import  ACreturn_foot;
from     GR3dpoint  import  GRgetpolyline;

#define set_generic 0x10000000

extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_ACheader_class_id;
extern GRclassid OPP_VDitbln_class_id;
extern GRclassid OPP_nci_macro_class_id;

int auto_increment;
extern int VDcurrent_item_number;
extern int VDquantity;

/*===========================================================================*/

method execute(int *response; char *response_data; int pos)

{

long    	    status, msg, retn,stat,retmsg,arrow_index;
int     	    msg_key, rc, token, control, k, p, ret_val,ret_back;
IGRlong	size   =    sizeof(struct GRevent);
struct GRid         *obj;
GRrange             range;
IGRboolean          world, no_ldrline,no_wireframe;
IGRboolean          put_intoque = FALSE,
                    created_annot;
IGRpoint            input_pt, center_pt, offset;
struct GRid         new_midpt,TEMP[5];
IGRdouble           default_value,points[3],out_pt[3];
IGRchar             *exp_name = NULL;
unsigned short      mask;
struct IGRpolyline  polyline;
struct IGRline      view_line;
IGRpoint            norpt, dummy_pt;
IGRdouble           dummy_par,bln_size;
IGRdouble           *local_attr;
struct DMobj_info   obj_info;
struct GRmd_env     lc_env;
IGRmatrix           matrix;
struct DMsenv_param par_senv;
struct GRobj_env    connect_pt;
IGRint              action,bln_sides,bln_type;


static int TokenList[] = {  RESET          ,
                            D_RESET        ,
                            DATA           ,
                            GR_UNKNOWN_TYPE,
                            STATUS_DISP    ,
                            LOC_PARENT      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *    RESET    , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */  {WAIT_MAC,  INITIAL,  WAIT_MAC,  INITIAL,  INITIAL,    INITIAL  },
/*WAIT_MAC*/  {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_LEA  },
/*WAIT_LEA*/  {WAIT_LEA,  WAIT_MAC, WAIT_LEA,  WAIT_LEA, WAIT_LEA,  WAIT_BK1  },
/*WAIT_POSN*/ {WAIT_LEA,  WAIT_MAC, WAIT_POSN, WAIT_POSN,WAIT_POSN, WAIT_BK1  },
/*WAIT_BK1*/  {WAIT_LEA,  WAIT_MAC, WAIT_BRK,  WAIT_BK1, WAIT_BK1,  WAIT_BK1  },
/*WAIT_BRK*/  {WAIT_MAC,  WAIT_MAC, WAIT_BRK,  WAIT_BRK, WAIT_BRK,  WAIT_BRK  },
/*WAIT_POS*/  {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_POS, WAIT_POS,  WAIT_POS} };


static enum possible_actions NewAction[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *   RESET   , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */{ STO_NOLD ,PRT_LD   ,STO_LD   ,PRT_LD   ,DIS_FOR  ,PRT_LD   },
/*WAIT_MAC*/{ LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
/*WAIT_LEA*/{ NO_LEAF  ,LOC_MAC  ,LOC_LEAF ,LOC_LEAF ,DIS_FOR  ,STO_LEAF },
/*WAIT_POSN*/{LOC_LEAF ,LOC_MAC  ,STO_LEAF ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_BK1*/{ LOC_LEAF ,LOC_MAC  ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_BRK*/{ PLACE    ,DELETE   ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_POS*/{ DELETE   ,DELETE   ,PLACE    ,GET_BRK  ,DIS_FOR  ,GET_BRK  } };


   ex$message(msgnumb = me->rel_key, buff = me->relocate_prompt);

   /* init */

   token = control = 0;

   no_ldrline =  FALSE;
   no_wireframe = FALSE;
   created_annot = FALSE;

   msg_key = VD_P_EntBrPt;

  do
  {
   switch( me->action)
   {
    case NIL :
      break;

    case ERR :
      me->state  = INITIAL;
      me->action = PRT_LD ;

    case PRT_LD :		/* ask if leader line or not */

     /*
      * startup option to choose for formatted text with or without
      * leader line.
      */

      me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

      me->an_grid.objid        = NULL_OBJID;

      me->hdr_set.obj_id.objid = NULL_OBJID;

      me->input_required = POINT;

      ex$message(msgnumb = VD_P_IdElNoLead);

      break;

   case STO_LD :		/* place with leader line */

     ex$putque( msg      = &msg,
                response = response,
                byte     = &size,
                buffer   = (IGRchar *) &(me->event1.event));
    me->global_leader = TRUE;
   
   case STO_NOLD :	/* place without leader line */

     if(me->action == STO_LD) me->global_leader = TRUE;
     else{
         me->global_leader = FALSE;
         no_ldrline        = TRUE;
     }
   case LOC_MAC :	/* locate macro to hook leader line */

     /*
      * set masks for the macro and the wireframe object
      */
     me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

     me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

     me->an_grid.objid        = NULL_OBJID;

     me->hdr_set.obj_id.objid = NULL_OBJID;

     me->input_required = PARENT;   

     ex$message(msgnumb = me->loc_key, buff = me->locate_prompt); 

     ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt);

     break;

   case STO_MAC :

     UI_prompt(" ");

     as$start_fence(	set	= &me->loc_event.located_object[0].located_obj,
			nb_obj	= &me->count_macro,
			p_obj	= &obj,
			response = response,
			response_data = response_data );

     ASend_fence();

     if( me->count_macro < 1 ){
      /*
       * fence rejected
       */

      me->action = LOC_MAC;
      
      me->state  = WAIT_MAC;

      me->input_required = NOENT;

      break;
    }

    /*
     * save the macro object
     */

     me->hdr_set.obj_id  = me->loc_event.located_object[0].located_obj;

     me->hdr_set.mod_env = me->loc_event.located_object[0].module_info;
   
    if( no_ldrline ){ 
          me->input_required = POINT;

          msg_key = VD_P_EntPlPt;

          ex$message(msgnumb = msg_key);

          me->state = WAIT_POS;
   }
   else {
     me->input_required = POINT;
     me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
     UI_prompt( "Identify wireframe/Move-on no wireframe");
     
   }
   break;
  
  case LOC_LEAF :

    /*
     * set masks and prompts for accept reject of the wireframe object.
     */
 
      if( !no_ldrline ){

           if( me->action == LOC_LEAF ){
                if( !put_intoque ){
                   ex$putque( msg      = &msg,
                              response = response,
                              byte     = &size,
                              buffer   = (IGRchar *) &(me->event1.event));

                   put_intoque  =  TRUE;
                }
       me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP| GRm_SPECIFIED_OBJ ;

       ex$message(msgnumb = VD_P_AccRej, buff = me->locate_prompt );
      }
   }

   me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

   ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt );

   /* locate filter */

   if( !no_ldrline )
      me->input_required = PARENT;

   break;

  case NO_LEAF  :

    no_wireframe = TRUE;

    me->state    = WAIT_POSN;

    me->input_required = POINT;
   
    msg_key = VD_P_EntPlPt;

    ex$message(msgnumb = msg_key);
 
    break;

  case STO_LEAF :

  case CNST_DIM :

    /*
     * Construct the text with balloon
     */

    me->leader = (me->global_leader && me->count_macro ==1) ? 1 : 0;

    if( !no_ldrline ){

     if( me->leader ){
       
        if( no_wireframe ){

          input_pt[0] = me->event1.event.button.x;
          input_pt[1] = me->event1.event.button.y;
          input_pt[2] = me->event1.event.button.z;

          world = 1;

          status =
          om$send( msg = message GRgraphics.GRgetrang(&retn,
                                       &me->hdr_set.mod_env.md_env.matrix_type,
                                       me->hdr_set.mod_env.md_env.matrix,
                                       &world,
                                       range ),
                 targetid = me->hdr_set.obj_id.objid,
                 targetos = me->hdr_set.obj_id.osnum );


         for( k=0 ; k<3 ; k=k+1 ){
            center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
         }

        for( k=0 ; k<3 ; k=k+1 ){
            offset[k] =  input_pt[k] - center_pt[k] ;
        }
   
        for( p=0 ; p<5 ; p++ ){
            TEMP[p].objid   = NULL_OBJID;
            TEMP[p].osnum   = me->md_env.md_id.osnum;
        }

        as$make_source(go_grid  = me->hdr_set.obj_id,
                 mod_env        = &me->hdr_set.mod_env,
                 as_grid        = &TEMP[0] );

        new_midpt.osnum = me->md_env.md_id.osnum;

        status =
        om$construct( classid       = OPP_nci_macro_class_id,
                      p_objid       = &new_midpt.objid,
                      osnum         = me->md_env.md_id.osnum 
                    );
         as$status();

       for( p=1 ; p<5 ; p++ ){
          if( p == 1 ) default_value = VD_ANNOT_CENTER_CENTER;
          if( p == 2 ) default_value = offset[0];
          if( p == 3 ) default_value = offset[1];
          if( p == 4 ) default_value = offset[2];
          if(p == 5 ) default_value = 0.0;
     
          status = exp$create( exp_name = exp_name,
                               exp_value  = (IGRdouble) default_value,
                               osnum      = me->md_env.md_id.osnum,
                               p_exp_id   = &(TEMP[p].objid),
                               p_osnum    = &(TEMP[p].osnum) );

          status = om$send(msg = message NDnode.NDchg_state((char)16,(char)16 ),
                           targetid = TEMP[p].objid,
                           targetos = TEMP[p].osnum );

          }

         status =
         om$send(msg = message ci_macro.init(&ret_back,
                                             0,
                                             "midpnts",
                                             5,
                                             TEMP,
                                             NULL,
                                             &me->md_env ),
                targetid = new_midpt.objid,
                targetos = new_midpt.osnum);
        as$status();
 
        UI_prompt( " " );

        /* create_arrow */

        /* return the graphic object (foot) from the nci_macro */

        status =
        om$send(msg = message NDmacro.ACreturn_foot(
                                       &stat,
                                       "pnt",
                                       &connect_pt.obj_id,
                                       &connect_pt.mod_env.md_env.matrix_type,
                                       connect_pt.mod_env.md_env.matrix ),
           targetid = new_midpt.objid,
           targetos = new_midpt.osnum );

        as$status();
        
        mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

        gr$put_properties(object_id = &connect_pt.obj_id,
                          action = 0,
                          properties_mask = mask);

        gr$display_object( object_id = &connect_pt.obj_id, mode = GRbeheo );
       
       action = 1;

       polyline.points = points;
 
       status =
       om$send( msg = message GR3dpoint.GRgetpolyline(
                      &retmsg,
                      &connect_pt.mod_env.md_env.matrix_type,
                      connect_pt.mod_env.md_env.matrix,
                      &action,
                      &polyline),
       targetid = connect_pt.obj_id.objid,
       targetos = connect_pt.obj_id.osnum );

       as$status();

       lc_env = me->md_env; 
       obj_info.grid = connect_pt.obj_id;

       status =
       om$send(msg = message IGEgragad.DPinrot((IGRlong *) &rc, matrix),
                targetid = me->event1.event.button.objid,
                targetos = me->event1.event.button.osnum);
       as$status();

       view_line.point1 = &polyline.points[0];

       norpt[0] = view_line.point1[0] + matrix[8];
       norpt[1] = view_line.point1[1] + matrix[9];
       norpt[2] = view_line.point1[2] + matrix[10];

       view_line.point2 = norpt;

       status =
       om$send(msg = message GRgraphics.GRlnproject(
                                     (IGRlong *) &rc,
                                     &lc_env.md_env.matrix_type,
                                     lc_env.md_env.matrix,
                                     &view_line,
                                     dummy_pt,
                                     obj_info.lnproj,
                                     &dummy_par,
                                     &obj_info.par),
              targetid = obj_info.grid.objid,
              targetos = obj_info.grid.osnum);
      as$status();

      status =
      GRfindcontext(
                   &rc,
                   &connect_pt.mod_env.md_env.matrix_type,
                   connect_pt.mod_env.md_env.matrix,
                   &obj_info.grid.osnum,
                   &obj_info.context);

      if (status != OM_S_SUCCESS || rc != MSSUCC )
        {
                obj_info.context.objid = NULL_OBJID;
       }

     arrow_index  = AN_ROOT_ELEM1;
    
     /* replace method get_dim_plane */
     {
        IGRint status;
        struct GRid win_grid;

        win_grid.objid = me->event1.event.button.objid;
        win_grid.osnum = me->event1.event.button.osnum;

        status =
        dm$get_dim_plane(win_grid = win_grid,
                        md_env = &me->md_env,
                        p_grid = &me->list[DIM_ROOT_PLAN]);
        as$status();

        status =
        dm$get_plan_info(
                plan_objid = me->list[DIM_ROOT_PLAN].objid,
                osnum = me->list[DIM_ROOT_PLAN].osnum,
                md_env = &me->md_env,
                plan_info = &me->plan_info);
        as$status();

      } 
     status =
     BSproj1(&rc,
             &me->event1.event.button.x,
             &me->plan_info.win_plan.matrix[8],
             obj_info.lnproj,
             out_pt);

     as$status(action = RET_STATUS);

     local_attr = &out_pt[0];

     status=
     dm$create_root(
           type     = DMptdist,
           count    = 1,
           list     = &obj_info.grid,
           context  = &obj_info.context,
           attr     = local_attr,
           md_env   = &lc_env,
           p_root   = &me->list[arrow_index]);
    as$status(); 

    } /* no_wireframe */

    else{
       status = om$send(msg = message VDCmdAnnot.create_arrow(),
                            targetid = my_id);
       as$status( action = RET_STATUS );
    }

    status = om$send(msg = message VDCmdAnnot.place_dimension(),
       	         targetid = my_id);
    as$status( action = RET_STATUS );

    if(me->an_grid.objid == NULL_OBJID){
           /*
            * The balloon or the text has not been created
            */

              me->state  = WAIT_MAC;

              me->action = LOC_MAC;

              me->input_required = NOENT;

              break;
       }
     else{
       created_annot = TRUE;
     }

     status = om$send(msg = message DMannot.set_dim_state(BIT_SET,
                                     DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
                     targetid = me->an_grid.objid,
	             targetos = me->an_grid.osnum);
     as$status(action = RET_STATUS);
   }

  } 
  case GET_BRK :

    me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;

    me->input_required = POINT;

    control = me->leader ? MOVE_BREAK_PT : 0;

    if( !no_ldrline ){
        if(me->leader) msg_key = VD_P_EntBrPt;

        ex$message(msgnumb = msg_key);
        status = om$send(msg = message VDCmdAnnot.position_dim( msg_key,
                                                    TRUE, NULL, NULL,
                                                  control, NULL, NULL),
                         targetid = my_id);
        if( created_annot ){
            me->state  = WAIT_BK1;
            me->action = ADD_BRK;
            created_annot  = FALSE;
        }
   }
   break;

  case ADD_BRK :

    status = om$send(msg = message COanplace.position_dim( msg_key,
                                                FALSE, NULL, NULL,
                                                control, NULL, NULL),
                     targetid = my_id);

    status = om$send(msg = message DMannot.ANadd_delete_vertex( &rc,
                                                                ADD_VERTEX,
                                                                NULL,
                                                                &me->dyn_env),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum);
    as$status(action= RET_STATUS);

    status = om$send(msg = message DMannot.set_dim_state(BIT_SET,
                                        DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum);
    as$status(action = RET_STATUS);

    me->action = GET_BRK;

    me->input_required = NOENT;

    break;

  case PLACE :

    if( no_ldrline ){

      input_pt[0] = me->event1.event.button.x;
      input_pt[1] = me->event1.event.button.y;
      input_pt[2] = me->event1.event.button.z;

      world = 1;
     
      status = 
      om$send( msg = message GRgraphics.GRgetrang(&retn,
                                       &me->hdr_set.mod_env.md_env.matrix_type,
                                       me->hdr_set.mod_env.md_env.matrix,  
                                       &world,
                                       range ),
                 targetid = me->hdr_set.obj_id.objid,
                 targetos = me->hdr_set.obj_id.osnum );

      
     for( k=0 ; k<3 ; k=k+1 ){
         center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
     }

     for( k=0 ; k<3 ; k=k+1 ){
         offset[k] = input_pt[k] - center_pt[k]; 
     }
     if( me->an_classid == OPP_VDitbln_class_id ){

            dm$get_dim_param(   type = DM_SENV_PARAM,
                        p_data = (char *)&par_senv );

            bln_type	= par_senv.bln_type ;
            bln_size	= par_senv.bln_size ;
            bln_sides	= par_senv.num_sides;
       
            ret_val =  vd$place_item( 
				      object   =   &me->hdr_set,
                                      item_num =   VDcurrent_item_number,
                                      bln_type =   &bln_type,
                                      bln_sides=   &bln_sides,
                                      bln_size =   &bln_size,
                                      quantity =   VDquantity,
                                      position =   (int) VD_ANNOT_CENTER_CENTER,
                                      offset   =   offset,
                                      window   =   &me->event1.event.button,
                                      tbl_name =   " ",
                                      pfx      =   " ",
                                      pfx_flag =   1  );
     
    }  

    }/* no_ldrline == TRUE */ 
    if( !no_ldrline ){ 
     if(me->leader){

      status = om$send(msg = message VDCmdAnnot.delete_vertex( &rc ),
                       targetid = my_id );
      as$status( action=RET_STATUS );

      status = om$send(msg = message VDCmdAnnot.compute_dimension(),
                       targetid = my_id );
      as$status( action = RET_STATUS );
     

     status = om$send(msg = message VDCmdAnnot.display_dimension( ROOT,
                                                DISPLAY | ADDWRNG),
                                        targetid = my_id);
     as$status(action = RET_STATUS);

     }
    }
     me->state = WAIT_MAC;
     me->action = LOC_MAC;
     me->input_required = NOENT;

     break;

    /* in case of no leader delete item number on move on */ 

  case DELETE :

     status = om$send(msg = message VDCmdAnnot.delete_dimension (),
                      targetid = my_id);
     as$status(action = RET_STATUS);

     me->state = WAIT_MAC;
     me->action = LOC_MAC;
     me->input_required = NOENT;

     break;

   case DIS_FOR :

     status =
     om$send(msg = message VDCmdAnnot.display_form(),
             targetid = my_id);
     as$status(action = RET_STATUS);

     if     ( me->state == INITIAL  )   me->action = PRT_LD;
     else if( me->state == WAIT_MAC )   me->action = LOC_MAC;
     else if( me->state == WAIT_LEA )   me->action = LOC_LEAF;
     else if( me->state == WAIT_POSN)   me->action = NO_LEAF; 
     else if( me->state == WAIT_POS ||
	      me->state == WAIT_BK1 ||
	      me->state == WAIT_BRK )   me->action = GET_BRK;
     else return OM_W_ABORT;
     me->input_required = NOENT;
     break;

 } /*end loop on actions */

 switch ( me->input_required  ){

   case PARENT :

        status = DMlocate(
                &me->locate_rc,
                &me->loc_event,
                &me->event1,
                me->mask1,
                me->mask2,
                me->display_flag,
                response,
                response_data,
                me->locate_prompt,
                me->acc_prompt,
                me->relocate_prompt,
                &me->attr,
                &me->act_parms,
                &me->lc_dyn);
        as$status(action = RET_STATUS);

	if(me->locate_rc == LC_OBJ_LOCATED)
	 for(token=0;TokenList[token] != LOC_PARENT; token++);
        else if(*response == STATUS_DISP) 
	 for(token=0;TokenList[token] != STATUS_DISP; token++);
	else
  	 for (token=0; TokenList[token] != *response &&
           TokenList[token] != GR_UNKNOWN_TYPE; token++);

     break;
   
   case POINT:

     token = GRget_token(&msg,TokenList,&me->mask1,&me->event1,
                                   &size, response,response_data);

     if(*response == STATUS_DISP) 
	 for(token=0;TokenList[token] != STATUS_DISP; token++);

     break;

   case NOENT :
     break;

   default : 
	printf(" input_required : %d (invalid)\n", me->input_required );
	break;
 }


 if(me->input_required != NOENT){
     me->action = (IGRint) NewAction[me->state ][ token ];
     me->state  = (IGRint) NewState[ me->state ][ token ];
 }

 /*"token %d new_action %d new_state %d\n",token,me->action,me->state*/

 } while(me->input_required == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);


 if( *response == TERMINATE && me->an_grid.objid != NULL_OBJID){

   status = om$send(msg = message COanplace.delete_dimension(),
                    targetid = my_id);
   as$status(action = RET_STATUS);
 }

 return OM_S_SUCCESS;
}

/*============================================================================*/

end implementation VDCmditbln;
