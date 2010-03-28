class implementation COparapm;

#include "msmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "coparadef.h"
#include "expression.h"
#include "expmacros.h"
#include "AS_status.h"
#include "OMmacros.h"
#include "nddef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 

 
#define AS_DEBUG 1


from GRgraphics import GRconstruct,GRlnproject,GRchgprops;

from NDnode    import NDplace,NDchg_state,NDgive_structure;

from IGEgragad import DPinrot;

from FIdirform  import  update;


#define ANGL_PM 1
#define DIST_PM 2
#define RADI_PM 4
#define ANGL_PM_ARC  11
#define ANGL_PM_LINE 21
#define ANGL_PM_3PTS 31

#define NUM_STATES 4
#define NUM_ACTIONS 8
#define NUM_TOKENS 4

enum possible_entry {
		     PARENT,
		     POINT,
		     NOENT
		    };


enum possible_states { 	INITIAL,
			HAV_1,
			HAV_2,
			HAV_3
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_1,
			STO_1,
			LOC_2,
			STO_2,
			LOC_3,
			STO_3,
			GET_NAME,
			CREAT_PM
		       };


extern GRclassid OPP_angl_pm_class_id,
		 OPP_dist_pm_class_id,
		 OPP_radius_pm_class_id,
		 OPP_ASindexpt_class_id;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{


/* what to do after construction of the element */

 me->restart_state  = INITIAL;
 me->restart_action = LOC_1;
 me->reput_locate   = -1; /* located element are not reputed and locate list */

 /*"me->mytype d %d h %x\n",me->mytype,me->mytype */

 switch(me->mytype)
  {
   default :
   printf("COparapm unknown case x-> %x d-> %d\n",me->mytype,me->mytype);
   me->num_locate = -1;
   return(OM_W_ABORT);

   case ANGL_PM :
   me->as_classid = OPP_angl_pm_class_id;
   me->mytype = ANGL_PM_ARC;

   case ANGL_PM_ARC  :
   ex$message( msgnumb = AC_M_PlaAngPara);
   me->num_locate = 1;

   me->loc[0] = AS_P_IdPntLinArc;
   me->acc[0] = AS_P_AccOtherRej;
   me->req_type[0] = point_generic | conic_generic | line_generic;
   me->reput[0] = 0;
   break;

   case ANGL_PM_LINE :
   ex$message( msgnumb = AC_M_PlaAngPara);
   me->num_locate = 2;

   me->loc[0] = AS_P_IdPntLinArc;
   me->acc[0] = AS_P_AccOtherRej;
   me->req_type[0] = point_generic | conic_generic | line_generic;
   me->reput[0] = 1;
   me->loc[1] = GR_P_Id2ndLn;
   me->acc[1] = AS_P_AccRej;
   me->req_type[1] = line_generic;
   me->reput[1] = 0;
   break;

   case ANGL_PM_3PTS :
   ex$message( msgnumb = AC_M_PlaAngPara);
   me->num_locate = 3;

   me->loc[0] = AS_P_IdPntLinArc;
   me->acc[0] = AS_P_AccOtherRej;
   me->req_type[0] = point_generic | conic_generic | line_generic;
   me->reput[0] = 1;
   me->loc[1] = AS_P_IdPnt2;
   me->acc[1] = AS_P_AccLastPnt;
   me->req_type[1] = point_generic;
   me->reput[1] = 1;

   me->loc[2] = AS_P_IdLastPnt;
   me->acc[2] = AS_P_AccRej;
   me->req_type[2] = point_generic;
   me->reput[2] = 0;
   break;

   case DIST_PM :
   ex$message( msgnumb = AC_M_PlaDisPara);
   me->as_classid = OPP_dist_pm_class_id;
   me->num_locate = 2;

   me->loc[0] = AS_P_IdLinPnt;
   me->acc[0] = AS_P_Acc2ele;
   me->req_type[0] = point_generic | line_generic;
   me->reput[0] = 1;

   me->loc[1] = AS_P_IdLinPnt2;
   me->acc[1] = AS_P_AccRej;
   me->req_type[1] = point_generic | line_generic;
   me->reput[1] = 0;
   break;

   case RADI_PM :
   ex$message( msgnumb = AC_M_PlaRadPara);
   me->as_classid = OPP_radius_pm_class_id;
   me->num_locate = 1;

   me->loc[0] = AS_P_IdCurve;
   me->acc[0] = AS_P_AccCent;
   me->req_type[0] = curve_generic | conic_generic ;
   me->reput[0] = 0;
   break;
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
 		      { RESET,
			STRING,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT 
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            **************** TOKENS ****************
   Old State  *   RESET   , STRING   , UNKNOWN   , PARENT     */

/* INITIAL    */ {INITIAL , INITIAL  , INITIAL   , HAV_1      },
/* HAV_1      */ {INITIAL , HAV_1    , HAV_1     , HAV_2      },
/* HAV_2      */ {HAV_1   , HAV_2    , HAV_2     , HAV_3      },
/* HAV_3      */ {HAV_2   , HAV_3    , HAV_3     , HAV_3      }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            **************** TOKENS ****************
   Old State  *   RESET     , STRING   , UNKNOWN   , PARENT     */

/* INITIAL    */ {NIL       , ERR      , LOC_1     , STO_1     },
/* HAV_1      */ {LOC_1     , CREAT_PM , LOC_2     , STO_2     },
/* HAV_2      */ {LOC_2     , CREAT_PM , LOC_3     , STO_3     },
/* HAV_3      */ {LOC_3     , CREAT_PM , GET_NAME  , ERR       }};


    struct GRas asso_lis;

                                                                            
    IGRint      status;         /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */
    IGRlong     msg;            /* function return code */

    struct  GRevent  grevent;     /* event returned by GRgetevent */

    IGRint resp;
    struct GRid PmGrid;
    IGRint token = 0;
    IGRmatrix view_rot;
    struct ret_struct ret_struct;
    struct
     {
      IGRchar name[EXP_MAX_LEN];
      IGRvector vz;
     } pipo_attr;
    IGRint iloc = 0,      
	   first_type,
	   new_type = 0,
	   entry_requested = 0;




    *response = TERMINATE;
    status = OM_S_SUCCESS;
    if(me->num_locate < 0) return(OM_W_ABORT);


    /*
     *  Initialization for locate
     */
    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET;
    display_flag = ELEM_HILIGHT | ALL_WINDOWS;

    /*
     *  loop until exit condition occurs
     */

   /*"num_locate %d\n",me->num_locate */

   do
    {
        switch (me->action)
        {       
	 case NIL:
		 break;

	 case ERR  :
		 ex$message( msgnumb = AS_E_InvDefRest);
		 me->state = INITIAL;
		 me->action= LOC_1;

         case LOC_1:         /*| LOC_1 */

		iloc = 0;
		entry_requested = PARENT;
                break;


         case STO_1:         /*| STO_1 */

		/* for angle parameter do the selection between 
                   angle by arc, by 2 lines or by 3 points      */
		if(me->mytype & ANGL_PM)
 		  {
		   first_type = me->obt_type[0];
		        if(first_type & conic_generic) new_type = ANGL_PM_ARC;
		   else if(first_type & line_generic ) new_type = ANGL_PM_LINE;
		   else if(first_type & point_generic) new_type = ANGL_PM_3PTS;

		   if(new_type != me->mytype)
		    {
		     me->mytype = new_type;
		     status = om$send(msg = message COparapm.wakeup(0),
				      targetid = my_id);
		     as$status();
		    }
		  }

		/*  Put the accept event in the input queue if required */

                if((me->grevent1.response != SPECIFIED_OBJ) && me->reput[0])
                   status = EXputq_front
				   (&msg, &resp, &size, &(me->grevent2.event));

				 


         case LOC_2:         /*| LOC_2 */
                if(me->num_locate == 1)
                 {
                  me->action = GET_NAME;
                  entry_requested = NOENT;
                 }
                else
                 {
                  iloc = 1;
                  entry_requested = PARENT;
                 }
                break;


         case STO_2:         /*| STO_2 */

               /*  Put the accept event in the input queue if required */

                if((me->grevent1.response != SPECIFIED_OBJ) && me->reput[1])
                   status = EXputq_front
				    (&msg, &resp, &size, &(me->grevent2.event));


         case LOC_3:         /*| LOC_3 */
                if(me->num_locate == 2)
                 {
                  me->action = GET_NAME;
                  entry_requested = NOENT;
                 }
                else
                 {
                  iloc = 2;
                  entry_requested = PARENT;
                 }
                break;


         case STO_3:         /*| LOC_3 */
                if((me->grevent1.response != SPECIFIED_OBJ) && me->reput[2])
                   status = EXputq_front
				    (&msg, &resp, &size, &(me->grevent2.event));


	 case GET_NAME:         /*| GET_NAME */
		entry_requested = POINT;
		ex$message( msgnumb = AS_P_Paraname);
		break;


	case CREAT_PM :         /*| CREAT_PM */

	/* Does the parameter already exist ? */

	   status = exp$translate(exp_name = response_data,
			          p_exp_id = &PmGrid.objid);

	   if( (status&1) && (response_data[0] != '\0') )
	       {
	        ex$message( msgnumb = AS_E_ParaExists);
	 	me->action = GET_NAME;
		entry_requested = NOENT;
		break;
	       }

	/* construction list initialization */
            asso_lis.parents = me->list_id;
	    asso_lis.num_parents = me->num_locate;
            asso_lis.as_attr = (IGRchar *) &pipo_attr;
            asso_lis.context = me->context;
 	    strcpy(pipo_attr.name,grevent.event.keyin);

	/* get view vector if necessary */

          status = om$send (msg  = message IGEgragad.DPinrot(&msg,view_rot),
                    targetid = me->grevent2.event.button.objid,
                    targetos = me->grevent2.event.button.osnum);
	  as$status(action = RET_STATUS);

	 /* what is specific for this kind of parameter */

	  if(me->mytype & ANGL_PM)
	    {
             pipo_attr.vz[0] = view_rot[8];
             pipo_attr.vz[1] = view_rot[9];
             pipo_attr.vz[2] = view_rot[10];
	    }
	  else if(me->mytype == RADI_PM)
	    {
	     if(!(me->obt_type[0]&conic_generic))
	       {
		
		IGRlong     	  cnst_lis_msg; /* return msg from cnst      */
		struct GRas        go_asso_lis; /* associative information   */
		struct GRvg_construct cnst_lis; /* construction list         */
		IGRdouble snap_point[4];
		
		

    		if(ASget_active_symb(&me->Active_level,&me->Active_display)
                                        != OM_S_SUCCESS) return (OM_W_ABORT);

		
		cnst_lis.msg = &cnst_lis_msg;
		cnst_lis.env_info = &me->ModuleInfo;
		cnst_lis.display = &me->Active_display;
		cnst_lis.geometry = 0;
		cnst_lis.newflag = FALSE;
		cnst_lis.level = me->Active_level;
		cnst_lis.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
		cnst_lis.class_attr = (IGRchar *) &go_asso_lis;
		cnst_lis.name = NULL;
		
		go_asso_lis.num_parents = 1;
		go_asso_lis.parents = me->list_id;
		go_asso_lis.context = me->context;
		
		go_asso_lis.go_attr = NULL;
		go_asso_lis.as_attr = (IGRchar *) snap_point;

	        /*| construct index point on the curve */
                snap_point[0] = 2.e+10;
                v_equal(&me->grevent2.event.button.x,&snap_point[1]);
		/*^ pr_point("snap",&snap_point[1]); */

                cnst_lis.properties =  0; /* no display nor locate */
                asso_lis.num_parents = 1;

                status = om$construct
                         (osnum   = me->ModuleInfo.md_id.osnum,
                          classid = OPP_ASindexpt_class_id,
                          p_objid = &me->list_id[1].objid,
                          msg     = message GRgraphics.GRconstruct(&cnst_lis));
                as$status(action = RET_STATUS);
                me->list_id[1].osnum = me->ModuleInfo.md_id.osnum;

                status = om$send(msg = message NDnode.NDchg_state
                                              (ND_SUP_ONLY , ND_SUP_ONLY),
                         targetid = me->list_id[1].objid,
                         targetos = me->list_id[1].osnum);
                as$status(action = RET_STATUS);

                me->context[1].objid = NULL_OBJID;
                asso_lis.num_parents = 2;
               }
	      else
               {
                asso_lis.num_parents = 1;
               }
	     }


	/* construction of the object */
           PmGrid.osnum = me->ModuleInfo.md_id.osnum;
    	   status = om$construct(osnum = PmGrid.osnum,
			         classid =  me->as_classid,
                        	 p_objid = &PmGrid.objid,
                        	 msg = message NDnode.NDplace
					      (&asso_lis,&me->ModuleInfo,NULL));
    	   as$status(action = RET_STATUS);

       /* add momo 17_01_89 */
       /* add momo 04_07_89 UPDATE DIR_FORM */
       {
	 struct ret_struct value;

         status = om$send( msg      = message NDnode.NDgive_structure
						(&msg,&value,&me->ModuleInfo ),
                           targetid = PmGrid.objid,
                           targetos = PmGrid.osnum);
         as$status(action = RET_STATUS);
	 if(value.type != double_type) return OM_W_ABORT;

         if( response_data[0] != '\0' )
         {
          ex$message(msgnumb = AS_S_PmValue,type="%s%6.3lf",
                     var=`response_data,value.var.root_pm_st.value`);
          status = di$send( msg        = message FIdirform.update(),
                             targetname = "IGENOD:DirCmds",
                             targetos   = OM_Gw_current_OS );
         }
       }
       /* end of add */

       /* prepare restart of the command */

       me->state =  me->restart_state;
       me->action = me->restart_action;
       entry_requested = NOENT;
       if(me->reput_locate > -1)
         { me->list_id[0] = me->list_id[me->reput_locate];
           me->context[0] = me->context[me->reput_locate];
           me->env_info[0] = me->env_info[me->reput_locate];
         }
       break;


        }   /* end switch (me->action) */


/*      definition of the parents */

      switch (entry_requested)
      {
        case PARENT:    	/*| PARENT */

        ex$message( buff =  me->loc_prompt, msgnumb = me->loc[iloc]);
        ex$message( buff =  me->acc_prompt, msgnumb = me->acc[iloc]);
        ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);
 
	token = ASget_parent (&msg,TokenList, &me->grevent1, &me->grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
		       me->acc_prompt,me->reloc_prompt,
		       &me->attr, &me->locate_stack,
                       me->req_type[iloc],&me->list_id[iloc],&me->context[iloc],
                       &ret_struct);
       if(TokenList[token] == LOC_PARENT)
                {me->obt_type[iloc] = ret_struct.type;}

	break;

	case POINT:   		/*| POINT */
	token = GRget_token(&msg,TokenList,&input_mask,&grevent,&size,
			    &resp,response_data);
        break;
	
	case NOENT:		/*| NOENT */
	break;
      }


/* new action and new state */

	
     if(entry_requested != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
     /*" token %d new_action %d new_state %d\n",token,me->action,me->state */

    }  while(entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);



    *response = resp;
    return( OM_S_SUCCESS);

}   /*  end execute method */

end implementation COparapm;
