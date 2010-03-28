class implementation COparaparm;

#include "msmacros.h"
#include "grdpbmacros.h"
#include "ASmessages.h"
#include "coparadef.h"
#include "AS_status.h"
#include "bserr.h"
#include "asbox.h"
#include "nddef.h"
#include "madef.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "ASmatrix.h"
#include "OMmacros.h"

#define AS_DEBUG             1

from IGEgragad  import DPinrot;

from GRgraphics import GRdisplay, GRconstruct, GRptproject, GRchgprops;

from GRvg import GRgenabsg;

from NDnode import NDgive_structure,NDchg_state;

from GRcurve import GRarclength;


extern GRclassid OPP_ASlinepara_class_id,
		 OPP_ASlineangl_class_id,
		 OPP_ASpointon_class_id,
		 OPP_AScircnt_class_id,
		 OPP_AScirpar_class_id,
		 OPP_ASarccntrd_class_id;


#define LINE_GEN    0x01        /* command creates a line            */
#define POINT_GEN   0x02        /* command creates a point           */
#define CIRC_GEN    0x04        /* command creates a circle          */
#define ARC_GEN     0x08        /* command creates an arc	     */


#define LINE_PARA   0x121       /* dec 289 */
#define LINE_ANGL   0x221       /* dec 545 */
#define POINT_ON    0x122       /* dec 290 */
#define CIRC_PARA   0x124       /* dec 292 */
#define ARC_PARA    0x128       /* dec 296 */

#define NUM_STATES   6
#define NUM_ACTIONS 15
#define NUM_TOKENS   6

enum possible_states { 	INITIAL,
			HAV_1,
			HAV_2,
			HAV_3,
			HAV_PAR,
			HAV_PT
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_1,
			STO_1,
			LOC_2,
			STO_2,
			LOC_3,
			BACK_GO,
			STO_3,
			LOC_PAR,
			STO_PAR,
			GET_PT,
			STO_PT,
			GET_NAM,
			CREATE
		       };

enum possible_entry {
		     PARENT,
		     PARAM,
		     POINT,
		     NAME,
		     NOENT
		    };

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos )

{

/* what to do after construction of the element */

 me->restart_state  = INITIAL;
 me->restart_action = LOC_1;
 
 /*" mytype = %d\n", me->mytype */

 switch(me->mytype)
  {
   case LINE_PARA :	ex$message( msgnumb = AC_M_PlaParLin);
			me->as_classid = OPP_ASlinepara_class_id;
			me->num_locate = 1;

			me->loc[0] = AS_P_IdLin;
			me->acc[0] = AS_P_AccRej;
			me->req_type[0] = line_generic;
			me->reput[0] = 0;
 			me->restart_state  = HAV_1;
 			me->restart_action = LOC_2;
			break;


   case LINE_ANGL : 	ex$message( msgnumb = AC_M_PlaLinAng);
			me->as_classid = OPP_ASlineangl_class_id;
			me->num_locate = 2;

			me->loc[0] = AS_P_IdCurve;
			me->acc[0] = AS_P_AccFixPnt;
			me->req_type[0] = line_generic | conic_generic 
                                                       | curve_generic 
                                                       | ref_generic;
			me->reput[0] = 1;

			me->loc[1]      = AS_P_LocFix; 
			me->acc[1]      = AS_P_AccRej;
			me->req_type[1] = point_generic;
			me->reput[1]    = 0;
			break;


   case POINT_ON :	ex$message( msgnumb = AC_M_PlaPntOn);
			me->as_classid = OPP_ASpointon_class_id;
			me->num_locate = 2;

			me->loc[0] = AS_P_IdCurve;
			me->acc[0] = AS_P_AccRefPnt;
			me->req_type[0] = line_generic | conic_generic 
						       | curve_generic;
			me->reput[0] = 1;
 
			me->loc[1] = AS_P_IdRefPnt; 
			me->acc[1] = AS_P_AccRej;
			me->req_type[1] = point_generic;
			me->reput[1] = 0;
			break;

   case CIRC_PARA :	ex$message( msgnumb = AC_M_PlaCir);
			me->num_locate = 1;
   
			me->loc[0]      = AS_P_IdCirPnt;
			me->acc[0]      = AS_P_AccRej;
			me->req_type[0] = point_generic | conic_generic;
			me->reput[0]    = 0;
                        break;

   case ARC_PARA :	ex$message( msgnumb = AC_M_PlaArcC);
			me->as_classid = OPP_ASarccntrd_class_id;
			me->num_locate = 3;
   
			me->loc[0]      = AS_P_IdCenPnt;
			me->acc[0]      = AS_P_AccStart;
			me->req_type[0] = point_generic;
			me->reput[0]    = 1;

			me->loc[1]      = AS_P_IdStart;
			me->acc[1]      = AS_P_AccSweep;
			me->req_type[1] = point_generic;
			me->reput[1]    = 1;
   
			me->loc[2]      = AS_P_IdSweep;
			me->acc[2]      = AS_P_AccRej;
			me->req_type[2] = point_generic;
			me->reput[2]    = 0;
			break;

   default :		me->num_locate = -1;
			return(OM_W_ABORT);
  }

 return( OM_S_SUCCESS);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{


static IGRint TokenList[] =
 		      { 
                        RESET,
                        D_RESET,
			DATA ,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT ,
			LOC_PARAM
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ************************** TOKENS ******************************
   Old State  *   RESET  , D_RESET, DATA   , UNKNOWN, PARENT , PARAM        */

/* INITIAL    */ {INITIAL, INITIAL, INITIAL, INITIAL, HAV_1  , INITIAL     },
/* HAV_1      */ {INITIAL, INITIAL, HAV_1  , HAV_1  , HAV_2  , HAV_PAR     },
/* HAV_2      */ {INITIAL, HAV_1  , HAV_2  , HAV_2  , HAV_3  , HAV_PAR     },
/* HAV_3      */ {INITIAL, HAV_3  , HAV_PT , HAV_3  , HAV_3  , HAV_PAR     },
/* HAV_PAR    */ {INITIAL, HAV_3  , HAV_PT , HAV_3  , HAV_PAR, HAV_PAR     },
/* HAV_PT     */ {INITIAL, HAV_3  , INITIAL, HAV_PT , INITIAL, INITIAL     }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*            ************************** TOKENS ******************************
   Old State  *   RESET  , D_RESET, DATA     , UNKNOWN, PARENT , PARAM       */

/* INITIAL    */ {NIL    , NIL    , LOC_1    , LOC_1  , STO_1  , STO_PAR  },
/* HAV_1      */ {LOC_1  , LOC_1  , LOC_2    , LOC_2  , STO_2  , STO_PAR  },
/* HAV_2      */ {LOC_1  , LOC_2  , LOC_3    , LOC_3  , STO_3  , STO_PAR  },
/* HAV_3      */ {LOC_1  , BACK_GO, STO_PT   , LOC_PAR, ERR    , STO_PAR  },
/* HAV_PAR    */ {LOC_1  , LOC_PAR, STO_PT   , GET_PT , ERR    , ERR      },
/* HAV_PT     */ {LOC_1  , GET_PT , ERR      , GET_NAM, ERR    , CREATE   }};



IGRint 			resp, token = 0, iloc = 0;
IGRint			size;         /* size of GRevent buffer             */
IGRlong 		cnst_lis_msg; /* return message from cnst           */
IGRlong			display_flag; /* display flag for locate filter     */
IGRlong		     	input_mask;   /* mask for GRgetevent                */
IGRlong     		locate_mask;  /* mask for GRgetevent                */
IGRlong     		msg,status;   /* function return code               */
IGRlong      		buffsize;     /* number of bytes asked              */
IGRlong      		bytes_ret;    /* number of bytes returned           */
IGRboolean		cntr_clk;     /* flag: counter-(0) or clockwise(1)  */
struct GRid		DisplayGrid;  /* GRid of the object to disp         */
struct GRid             ConstructGrid;          /* grid for line segment    */
struct GRas        	asso_lis;     /* associative information            */
enum   GRdpmode		DisplayMode;  /* disp mode for disp msg send        */
struct GRevent 		grevent2;     /* event ret. by GRgetevent */
enum   possible_entry 	entry_requested = NOENT;
struct GRvg_construct	cnst_lis;     /* construction list                  */
IGRmatrix view_rot;
struct ret_struct str;

/* function declaration */
IGRdouble 		fabs();

    *response = TERMINATE;
    if(me->num_locate < 0) return(OM_W_ABORT);

    /*
     *   Initialize construction list
     */

    cnst_lis.msg = &cnst_lis_msg;         /* message returned from construct*/
    cnst_lis.env_info = &me->ModuleInfo;  /* context returned          */
    cnst_lis.display = &me->Active_display; /* constr display params*/
    cnst_lis.geometry = 0;                            /* bspline geometry     */
    cnst_lis.newflag = FALSE;           
    cnst_lis.level = me->Active_level;           
    cnst_lis.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    cnst_lis.class_attr = (IGRchar *) &asso_lis;
    cnst_lis.name = NULL;

    asso_lis.parents = me->list_id;
    asso_lis.context = me->context;

    asso_lis.go_attr = NULL;
    asso_lis.as_attr = (IGRchar *) me->snap;

    DisplayMode = GRbd; /* how to display element   */

    /* get module id and space number. */
    status = GRfindmod(&DisplayGrid);
    if( COERROR(status))
    {
        printf(" COparaparm: err: GRfindmod status = %d\n", status);
        om$report_error(sts = status);
    }

    /* Initialization for locate */

    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_STRING ;
    input_mask =
	  GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_STRING | GRm_SPECIFIED_OBJ;

    if( me->mytype == ARC_PARA )
    {
      buffsize = sizeof(IGRboolean);
      gr$get_arc_direction( msg    = &msg,      sizbuf = &buffsize,
     		            buffer = &cntr_clk, nret   = &bytes_ret );
    }

    /* loop until exit condition occurs */

    do
    {
        switch (me->action)
        {       
	 case NIL:        	  /*| NILL */
	      break;
		 

	 case ERR  :			  /*| ERR */
              ex$message( msgnumb = AS_E_InvDefRest);
	      me->state = INITIAL;
	      me->action= LOC_1;


         case LOC_1:                      /*| LOC_1 */
	      iloc = 0;
	      entry_requested = PARENT;
              break;


         case STO_1:                      /*| STO_1 */

              /* store the view vector of the first locate */

	      status = om$send (msg = message IGEgragad.DPinrot(&msg,view_rot),
                    targetid = grevent2.event.button.objid,
                    targetos = grevent2.event.button.osnum);
	      v_equal(&view_rot[8],me->first_view_vect);

	      /* For associative circle the created class depend upon the 
		 geometry of the first element */

              if(me->mytype == CIRC_PARA)
                {if(me->ret_struct[0].type & point_generic)
		      me->as_classid = OPP_AScircnt_class_id;
		 else me->as_classid = OPP_AScirpar_class_id;
	        }

              /*  Put the accept event in the input queue if required */

	      if((me->grevent.response != SPECIFIED_OBJ) && me->reput[0])
		 status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));

         case LOC_2:                      /*| LOC_2 */
	      if(me->num_locate == 1)
	      {
		me->action = LOC_PAR;
		entry_requested = NOENT;
	      }
	      else
	      {
	        iloc = 1;
	        entry_requested = PARENT;
              }
              break;


	 case STO_2 :                      /*| STO_2 */
              /* Put the accept event in the input queue if required */

	      if((me->grevent.response != SPECIFIED_OBJ) && me->reput[1])
		 status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));

         case LOC_3 :                      /*| LOC_3 */
	      if(me->num_locate == 2)
	      {                  
		me->action = LOC_PAR;
		entry_requested = NOENT;
	      }
	      else
              {
	        iloc = 2;
 		entry_requested = PARENT;
	      }
              break;
 

         case BACK_GO :                             /*| BACK_GO */
              /* Where to go on backup when having all geom can not be defined
                 by the state table. It depends upon the number of g. o.
                 located */
	      switch (me->num_locate)
		{
		 case 1 :
		    me->state = INITIAL;
		    me->action = LOC_1;
		    break;
		 case 2 :
		    me->state =  HAV_1;
		    me->action = LOC_2;
		    break;
		 case 3 :
		    me->state =  HAV_2;
		    me->action = LOC_3;
		    break;
		}
	      entry_requested = NOENT;
	      break;



	 case STO_3 :                      /*| STO_3 */


              /* Put the accept event in the input queue if required */
	      if((me->grevent.response != SPECIFIED_OBJ) && me->reput[2])
		 status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));

	 case LOC_PAR:                      /*| LOC_PAR */
	      /* set my state to have all geom */
	      me->state = HAV_3;

              /* call ASget_param */ 

	      me->list_id[0].objid = NULL_OBJID;
	      me->context[0].objid = NULL_OBJID;
	      ex$message(msgnumb = AS_P_PlPtOrPm);
	      entry_requested = PARAM;
	      break;
/*	      ex$message(buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
/*	      if(G_active_para_type == PARAM_SHARE) 
/* 	      {
/*                /*| share param */
/*	        ex$message(buff= me->loc_prompt ,msgnumb = AS_P_IdKeyPara);
/*	        entry_requested = PARAM;
/*	      }
/*	      else
/* 	      {
/*                /*| not share param */
/*                ex$message( msgnumb = AS_P_Placepnt);
/*	        entry_requested = POINT;
/*	      }
/*              break;
/*****/
	     


 	 case STO_PAR :                     /*| STO_PAR */
              /* store the information in the instance */

              if( me->as_classid == OPP_AScircnt_class_id ||
                  me->as_classid == OPP_ASarccntrd_class_id )
              {                
                me->state = HAV_PAR;
                me->action = CREATE;
                entry_requested = NOENT;
                break;
              }

         case GET_PT:                         /*| GET_PT */
              ex$message( msgnumb = AS_P_Placepnt);
	      entry_requested = POINT;
	      break;

	 case STO_PT :			     /*| STO_PT */
	      status = om$send (msg = message IGEgragad.DPinrot(&msg,view_rot),
                    targetid = me->grevent.event.button.objid,
                    targetos = me->grevent.event.button.osnum);

              switch(me->mytype)
   	      {
	        case LINE_PARA :
                   status = ASline_para_param(&me->ret_struct[0],
                                              &me->grevent.event.button.x,
					      &view_rot[8],
					      me->snap,&me->value );
                   break;

                case LINE_ANGL :
                   status=ASline_angl_param(&me->ret_struct[0],
                                            &me->list_id[1],&me->env_info[0],
					    &me->ret_struct[1],
                                            &me->grevent.event.button.x,
					    &view_rot[8],
					    me->snap,&me->value);
                   break;

                case POINT_ON :
                   status=ASpointon_param(&me->ret_struct[0],
                                          &me->list_id[1],&me->env_info[0],
                                          &me->ret_struct[1],
                                          &me->grevent.event.button.x,
					  &view_rot[8],
					  me->snap,&me->value);
                     break;

                case CIRC_PARA :
                     status=AScircle_param(&me->ret_struct[0],
                                           &me->grevent.event.button.x,
					   &view_rot[8],
					   me->first_view_vect,
                                           me->snap,&me->value);
                     break;
              
                case ARC_PARA :
                     status=ASarc_para_param(&me->ret_struct[0],
					     &me->ret_struct[1],
					     &me->ret_struct[2],
					     cntr_clk,
                                             &me->grevent.event.button.x,
					     &view_rot[8],
					     me->first_view_vect,
                                             me->snap,&me->value);
                     break;
              }
              me->value = fabs(me->value);

              if(!(status&1))
	      {
		entry_requested = NOENT;
		me->action = ERR;
		break;
	      }

	      if(!IF_NULL_OBJID(me->list_id[0].objid))
               {
		entry_requested = NOENT;
		me->action = CREATE;
		break;
	       }


	 case GET_NAM :

		entry_requested = NAME;
		break;

 	 case CREATE :         /*| CREATE */

              asso_lis.num_parents = me->num_locate + 1;

              /*" nb parents = %d\n",asso_lis.num_parents */
 
	      /* Add track point when necessary */

	      if(( me->as_classid != OPP_AScircnt_class_id) &&
   	          !IF_NULL_OBJID(G_active_trackpoint.objid) && 
                 (1 & om$is_objid_valid(objid=G_active_trackpoint.objid, 
	                               osnum=G_active_trackpoint.osnum )))
                    {
                      /*| there is a track point */
	              asso_lis.num_parents++;
	              me->list_id[me->num_locate+1]       = G_active_trackpoint;
                      me->context[me->num_locate+1].objid = NULL_OBJID;
	            }
	            else
                    {
                      /*| there isn't a track point */
                      G_active_trackpoint.objid = NULL_OBJID;
                    }

	       /* Control that parents are distincts */

               cmp_parent(&msg,&me->num_locate,asso_lis.parents+1,
                            asso_lis.context+1);
                if( msg != OM_S_SUCCESS )
                {
      	         ex$message(msgnumb = AS_S_RtDif);
                 entry_requested = NOENT;
                 me->state  = INITIAL;
                 me->action = LOC_1;
                 break;
                }

	      /* Add specific information for placement if not already added */

	      if(me->as_classid == OPP_AScircnt_class_id)
		{
		 v_equal(me->first_view_vect,me->snap);
 		}
	      else if(me->as_classid == OPP_ASarccntrd_class_id)
		{
		 if(cntr_clk) v_equal(me->first_view_vect,me->snap);
		 else	        v_neg(me->first_view_vect,me->snap);
 		}


              /* construct object by classid */


              if(ASget_active_symb(&me->Active_level,&me->Active_display) 
       	 				!= OM_S_SUCCESS) return (OM_W_ABORT);
              cnst_lis.level = me->Active_level;           

              if(me->mytype&POINT_GEN) me->Active_display.weight += 3;
 
              ConstructGrid.osnum = me->ModuleInfo.md_id.osnum;
              status = om$construct(osnum   = ConstructGrid.osnum,
                                    classid = me->as_classid,
                                    p_objid = &ConstructGrid.objid,
                                    msg     = message GRgraphics.GRconstruct
                                                     (&cnst_lis));
              as$status(action = RET_STATUS);

              /* Display object */
  
              status = om$send(msg      = message GRgraphics.GRdisplay
                                          (&msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                           me->ModuleInfo.md_env.matrix,
                                           &DisplayMode, &DisplayGrid),
                               targetid = ConstructGrid.objid,
	  	               targetos = ConstructGrid.osnum);
              as$status(action = RET_STATUS);

              /* reinitialize to initial state */
              entry_requested = NOENT;
              me->state  = me->restart_state;
              me->action = me->restart_action;
 
              break;

        } /* end of switch on me->action */


        /* the different possible input are respectively
          - definition of the original line
          - definition of the parameter (if share parameter)
          - definition of the placement point
        */


	 /*"entry_requested %d\n", entry_requested */
        switch (entry_requested)
	{
          case PARENT :
	       ex$message( buff = me->loc_prompt,   msgnumb = me->loc[iloc]);
	       ex$message( buff = me->acc_prompt,   msgnumb = me->acc[iloc]);
	       ex$message( buff = me->reloc_prompt, msgnumb = AS_E_EleNotFound);
               if(me->reput[iloc] > 0)
                   display_flag = ELEM_HILIGHT | ALL_WINDOWS | LC_ACCEPT_CURSOR;
               else
                   display_flag = ELEM_HILIGHT | ALL_WINDOWS;


               token = ASget_parent(&msg,TokenList,&me->grevent,&grevent2,
                                    &locate_mask,&input_mask,&size, 
                                    &display_flag, &resp, response_data,
                                    me->loc_prompt,me->acc_prompt,
                                    me->reloc_prompt,&me->attr,
                                    &me->locate_stack,me->req_type[iloc],
                                    &me->list_id[iloc+1],&me->context[iloc+1],
                                    &me->ret_struct[iloc]);

	       if(TokenList[token] == LOC_PARENT)
          	 me->env_info[iloc]=me->grevent.located_object[0].module_info;
	       break;

/*
/*               display_flag = ELEM_HILIGHT | ALL_WINDOWS;
/*	       token = ASget_param (&msg,TokenList,&me->grevent,&grevent2,
/*                                    &locate_mask,&input_mask,&size,
/*                                    &display_flag,&resp,response_data,
/*                                    me->loc_prompt,me->acc_prompt,
/*                                    me->reloc_prompt,&me->attr,
/*                                  &me->locate_stack,&me->list_id[0],&me->value);
/*	       break;
/************/

          case PARAM :
          case POINT :

               /* get active symbology and level */

               if(ASget_active_symb(&me->Active_level,&me->Active_display) 
                                 != OM_S_SUCCESS) return (OM_W_ABORT);

               switch( me->mytype )
               {

                case LINE_PARA :
	             DYrblinepara(&me->list_id[0],       /* parameter        */
				  &me->ret_struct[0],    /* original line    */
			          &me->Active_display,   /* display info     */
				  &me->ModuleInfo);
		     break;

                case LINE_ANGL :
                     DYrblineangl(&me->list_id[0],       /* parameter        */
				  &me->ret_struct[0],    /* original curve   */
			 	  &me->list_id[1],&me->env_info[0],
				  &me->ret_struct[1],    /* fix point        */
                                  &me->Active_display);  /* display info     */
                     break;

                case POINT_ON :
                     me->Active_display.weight += 4;
   	             DYrbonlnpt(&me->list_id[0],         /* parameter        */
				&me->ret_struct[0],      /* support          */
				&me->list_id[1],&me->env_info[0],    
                                &me->ret_struct[1],      /* fix point        */
                                &me->Active_display,    /* display info     */
				&me->ModuleInfo);
                     break;

                case CIRC_PARA :
                     DYcircnt_p(&me->list_id[0],
                     		&me->ret_struct[0],me->first_view_vect,
                                &me->Active_display,
				&me->ModuleInfo);
                     break;

                case ARC_PARA :
                     DYrbarc_p(&me->ret_struct[0],&me->ret_struct[1],
			       &me->ret_struct[2],
                               cntr_clk,me->first_view_vect,
			       &me->Active_display);
                     break;
               }

	       token = GRget_token(&msg,TokenList,&input_mask,&me->grevent,
				   &size, &resp,response_data);


	       if(entry_requested == POINT)
                {/*| param value already defined */ break;} 

	       else if (resp == SPECIFIED_OBJ)
		{
      		 status = om$send(msg = message NDnode.NDgive_structure
                                        	    (&msg,&str,&me->ModuleInfo),
                      targetid=me->grevent.located_object[0].located_obj.objid,
                      targetos=me->grevent.located_object[0].located_obj.osnum);
      		 if((status&1) && (str.type == double_type ))
      		  {
		    me->value = str.var.root_pm_st.value;
		    for( token=0 ; TokenList[token]!=LOC_PARAM ; token++);
                    me->list_id[0]=me->grevent.located_object[0].located_obj;
		  }
		
		}
 	       else if (resp == STRING)
		{
		 status = ASget_param_from_string (response_data,double_type,
				      me->list_id,&me->value,&me->ModuleInfo);
		 if(status&1)
		   {
		    for( token=0 ; TokenList[token]!=LOC_PARAM ; token++);
		   }
		}
	       break;

	  case NAME :
                token = AScreate_pm (TokenList,&input_mask,&me->grevent,
				     me->value,&me->list_id[0].objid,
 		                     me->ModuleInfo.md_id.osnum,
		                     &resp, response_data);
                me->list_id[0].osnum = me->ModuleInfo.md_id.osnum;
	       break; 

          case NOENT :
	       break; 
     
	}  /* end switch entry_requested  */

        /* new action and new state */

        if(entry_requested != NOENT)
        {
         me->action = (IGRint) Action[   me->state ][ token ];
         me->state =  (IGRint) NewState[ me->state ][ token ];
        }

     /*"token %d new_action %d new_state %d\n",token,me->action,me->state */

    }
    while(entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);


    *response = resp;

    return( status);

}   /*  end execute method */

end implementation COparaparm;
