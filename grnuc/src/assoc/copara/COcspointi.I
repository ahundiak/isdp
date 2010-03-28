/*----
        Abstract: This command object places a parametric cs point
            given an cs and three coordinates parametres. 

     CHANGE HISTORY:


     momo 24 nov 1988 :  design date.
     jla  22 aug 1989 :  replace cartesian by rectangular.
        
-----*/

class implementation COcspoint;

#include "msmacros.h"
#include "ASmessages.h"
#include "coparadef.h"
#include "asbox.h"
#include "AS_status.h"
#include "OMmacros.h"
#include "madef.h"
#include "expression.h"
#include "expmacros.h"

#define AS_DEBUG 1

from GRgraphics import GRdisplay, GRconstruct;
from NDnode import NDgive_structure;

extern GRclassid OPP_AScspoint_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos )
{
 ex$message( msgnumb = AC_M_PlaPntCs);
 return( OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response; char *response_data; int pos)

{

#define NUM_TOKENS       6
#define NUM_ACTIONS     14
#define NUM_STATES       6

#define RECTANGULAR      0
#define CYLINDRICAL      1
#define SPHERICAL        2

#define UNKNOWN_TYPE 	 3


enum possible_states {
		 	INITIAL,
                        HAV_TYPE,
			HAV_CS,
			HAV_PAR1,
			HAV_PAR2,
			HAV_PAR3
		     };

enum possible_actions {	
			NIL,
			ERR,
                        LOC_TYPE,
                        STO_TYPE,
			LOC_CS,
			STO_CS,
			LOC_PAR1,
			STO_PAR1,
			LOC_PAR2,
			STO_PAR2,
			LOC_PAR3,
			STO_PAR3,
                        CRE_PAR,
			PLACE_PNT
		      };

enum possible_entry {
			POINT,
			PARENT,
			PARAM,
                        TYPE,
       			NO_ENTRIES
		    };


static IGRint TokenList[] = { 
			        RESET,
			        DATA,
			        STRING,
                                GR_UNKNOWN_TYPE,
				LOC_PARENT,
				LOC_PARAM
			    };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = { 

/*            ************************** TOKENS ******************************
   Old State  *   RESET   , DATA    , STRING  , UNK     , PARENT  , PARAM    */

/* INITIAL    */ {HAV_TYPE, HAV_TYPE, HAV_TYPE, INITIAL , INITIAL , INITIAL  },
/* HAV_TYPE   */ {INITIAL , HAV_TYPE, HAV_TYPE, HAV_TYPE, HAV_CS  , HAV_TYPE },
/* HAV_CS     */ {HAV_TYPE, HAV_CS  , HAV_CS  , HAV_CS  , HAV_CS  , HAV_PAR1 },
/* HAV_PAR1   */ {HAV_CS  , HAV_CS  , HAV_PAR1, HAV_PAR1, HAV_PAR1, HAV_PAR2 },
/* HAV_PAR2   */ {HAV_PAR1, HAV_CS  , HAV_PAR2, HAV_PAR2, HAV_PAR2, HAV_PAR3 },
/* HAV_PAR3   */ {HAV_PAR2, HAV_CS  , HAV_PAR3, HAV_PAR3, HAV_PAR3, HAV_PAR1 }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            ************************** TOKENS ******************************
   Old State  *   RESET   , DATA     , STRING  , UNKNOWN  , PARENT, PARAM    */

/* INITIAL    */ {STO_TYPE, STO_TYPE , STO_TYPE, LOC_TYPE , ERR   , ERR      },
/* HAV_TYPE   */ {LOC_TYPE, ERR      , ERR     , LOC_CS   , STO_CS, ERR      },
/* HAV_CS     */ {LOC_CS  , CRE_PAR  , ERR     , LOC_PAR1 , ERR   , STO_PAR1 },
/* HAV_PAR1   */ {LOC_PAR1, ERR      , ERR     , LOC_PAR2 , ERR   , STO_PAR2 },
/* HAV_PAR2   */ {LOC_PAR2, ERR      , ERR     , LOC_PAR3 , ERR   , STO_PAR3 },
/* HAV_PAR3   */ {LOC_PAR3, CRE_PAR, ERR     , NIL      , ERR   , STO_PAR1 }};


/* variables declaration */

    IGRchar			param_type = 0;
    IGRlong             	msg;       /* msg returned from methods   */
    IGRint              	status;    /* return status               */
    IGRlong			display_flag;
    IGRlong       	        EventSize;  
    IGRint              	token = 0;
    struct GRvg_construct       cnst_lis; /* construction list     */
    struct GRas                 asso_lis;
    struct GRid                 PointGrid;   /* grid for point            */
    IGRlong    			loc_mask;    /* mask for locate          */
    IGRlong    			input_mask;  /* getevent mask            */
    IGRlong     		ConstructMsg; /* return msg from cn       */
    enum GRdpmode   		DisplayMode;/* display mode, erase, hilited, etc.   */
    struct GRid     		DisplayGrid;/* GRid of the object we want to dip object */
    IGRint 			resp, parent_generic = 0;
    struct ret_struct           *struct_adr = NULL;
    struct GRevent		grevent1,grevent2;
    double			param0,param1,param2;
    IGRdouble 			val_param,origin[3],param[3];
    struct GRid  		located_obj,param_obj,context;
    IGRint 			create_param();
    IGRdouble                   atan2();
    IGRdouble                   sqrt();
    int i;
    struct ret_struct str;

    
/* begining of COobject's code */

    status    = OM_S_SUCCESS;
    *response = TERMINATE;

    EventSize = sizeof( struct GRevent);

    /*
     * set up md info since we do not have a dpb block.
     */
    cnst_lis.msg = &ConstructMsg;/* message returned from construct */
    cnst_lis.env_info = &me->ModuleInfo;/* context returned from ?? */
    cnst_lis.display =  &me->Active_display;  /* contruction
                                                    display parameter    */
    cnst_lis.geometry = 0; /* bspline geometry    */
    cnst_lis.newflag = FALSE;           
    cnst_lis.level = me->Active_level;           
    cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    cnst_lis.class_attr = (IGRchar *) &asso_lis;
    cnst_lis.name = 0;

    asso_lis.num_parents = 4;
    asso_lis.parents     = me->list_id;
    asso_lis.go_attr     = NULL;
    asso_lis.as_attr     = &me->param_type;
    asso_lis.context     = me->context;

    me->context[0] = NULL_GRID;
    me->context[1] = NULL_GRID;
    me->context[2] = NULL_GRID;

    DisplayMode = GRbd;              /* how to display element           */

    /*
     *  set upt the display grid for the display messages
     *  since we want the module to display the line string, call GRfindmod
     */
    GRfindmod( &DisplayGrid);

    /*
     *  set up mask for type of events wanted from gettoken and locate.
     */
     input_mask = GRm_DATA | GRm_RESET;

    /*   
     *    initialization for locate
     */
    loc_mask = GRm_DATA | GRm_RESET;

    display_flag = ELEM_HILIGHT | ALL_WINDOWS;


    do
    {
        /*
         *  Perform the appropriate action.
         */
        switch ( me->action)
        {
          case NIL :                  

              /* 
               *  do nothing - a nil action production.
               */
              break;

          default:
          case ERR : /*   error handling */

              ex$message( msgnumb = AS_E_InvDefRest );
              break;

          case LOC_TYPE : /*  get the parameters's type */

                ex$message( msgnumb = AS_P_KeyTypPar );
                me->input_requested = TYPE;
                break;

          case STO_TYPE : /*  store the parameters's type */

                me->param_type = param_type;

                 switch( (int)me->param_type )
                 {
                   case RECTANGULAR :
		      me->msg_numb[0] = AS_P_IdKeyCartXPara ;
		      me->msg_numb[1] = AS_P_IdKeyCartYPara ;
		      me->msg_numb[2] = AS_P_IdKeyCartZPara ;
                        break;

                   case CYLINDRICAL :                  
		      me->msg_numb[0] = AS_P_IdKeyCylTPara ;
		      me->msg_numb[1] = AS_P_IdKeyCylRPara ;
		      me->msg_numb[2] = AS_P_IdKeyCylZPara ;
                        break;

                   case SPHERICAL :
		      me->msg_numb[0] = AS_P_IdKeySphTPara ;
		      me->msg_numb[1] = AS_P_IdKeySphPPara ;
		      me->msg_numb[2] = AS_P_IdKeySphRPara ;
			break;

		   default :
		      return OM_W_ABORT;
		 }

          case LOC_CS  : /*   locate the coordinate system */

               ex$message( buff =me->loc_prompt,msgnumb = AS_P_IdCoordSys);
               ex$message( buff =me->acc_prompt,msgnumb = AS_P_AccRej);
               parent_generic = ref_generic;
               struct_adr = &(me->cs_struct);
               me->input_requested = PARENT;
               break;

          case STO_CS : /*   store point 1 in instance data */ 

               me->list_id[3] = located_obj;
               me->context[3] = context;
               /*" cs id : %d\n", me->list_id[3].objid */               

           case LOC_PAR1 : /*  Ask for the param 1 or for a data point.  */ 

               me->list_id[0].objid = NULL_OBJID;
               ex$message( msgnumb=me->msg_numb[0] );
               me->input_requested = POINT;
              break;

          case STO_PAR1 : /*  store the parameter 1 */
                me->list_id[0] = param_obj;


           case LOC_PAR2 : /*   Ask for the param 2  */ 

               me->list_id[1].objid = NULL_OBJID;
               ex$message( buff = me->loc_prompt,
                           msgnumb=me->msg_numb[1] );
               me->input_requested = PARAM;
               break;

          case STO_PAR2 : /*  store the parameter 2 */
                me->list_id[1] = param_obj;

           case LOC_PAR3 : /* Ask for the param 3 */

               me->list_id[2].objid = NULL_OBJID;
               ex$message( buff = me->loc_prompt,
                           msgnumb=me->msg_numb[2] );
               me->input_requested = PARAM;
              break;

          case STO_PAR3 : /*  store the parameter 1 */
                me->list_id[2] = param_obj;
                me->input_requested = NO_ENTRIES;
	        me->action =  PLACE_PNT;
                break;

          case CRE_PAR :  /*  creat parameter */

               origin[0]=grevent2.event.button.x-me->cs_struct.var.ref_st.t[3];
               origin[1]=grevent2.event.button.y-me->cs_struct.var.ref_st.t[7];
               origin[2]=grevent2.event.button.z-me->cs_struct.var.ref_st.t[11];
 
               param0 =  me->cs_struct.var.ref_st.t[0]*origin[0]
                       + me->cs_struct.var.ref_st.t[4]*origin[1]
                       + me->cs_struct.var.ref_st.t[8]*origin[2];

               param1 =  me->cs_struct.var.ref_st.t[1]*origin[0]
                       + me->cs_struct.var.ref_st.t[5]*origin[1]
                       + me->cs_struct.var.ref_st.t[9]*origin[2];

               param2 =   me->cs_struct.var.ref_st.t[2]*origin[0]
                        + me->cs_struct.var.ref_st.t[6]*origin[1]
                        + me->cs_struct.var.ref_st.t[10]*origin[2];
                       
               switch( (int)me->param_type )
               { 

                case RECTANGULAR :
                     param[0] = param0;
                     param[1] = param1;
                     param[2] = param2;
                     break;

                case CYLINDRICAL : 
                     param[0] = atan2( param1, param0 ) * 180.0 / PI;
                     param[1] =   sqrt( param0*param0 + param1*param1 );
                     param[2] = param2;
                     break;                          

                case SPHERICAL   :
                     param[0] = atan2( param1, param0 ) * 180.0 / PI;
                     param[1] = 
			      atan2( param2, sqrt(param0*param0+param1*param1))
                              * 180.0 / PI;
                     param[2] = sqrt( param0*param0 + param1*param1
                                                          + param2*param2 );
                     break;                          

                default          : return(OM_W_ABORT);

               }


	     for(i=0;i<3;i++)
	      {
               msg = create_param( param[i], &(me->list_id[i].objid),
                                   me->ModuleInfo.md_id.osnum,
                                   &resp, response_data );

               if(!(msg&1)) return OM_W_ABORT;
               me->list_id[i].osnum = me->ModuleInfo.md_id.osnum;
	      }
               
          case PLACE_PNT :           /*  create the cs on point  */

      	      if(ASget_active_symb(&me->Active_level,&me->Active_display) 
	            != OM_S_SUCCESS) return (OM_W_ABORT);
              me->Active_display.weight += 3;

              cnst_lis.level = me->Active_level;           
 
              /*| construct object by classid  */
              PointGrid.osnum = me->ModuleInfo.md_id.osnum;
              status = om$construct
                         (osnum   = PointGrid.osnum,
                          classid = OPP_AScspoint_class_id,
                          p_objid = &PointGrid.objid,
                          msg     = message GRgraphics.GRconstruct( &cnst_lis));
              as$status();

              /*  Display object */

              status = om$send(msg      = message GRgraphics.GRdisplay( &msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &DisplayMode, &DisplayGrid),
                               targetid = PointGrid.objid,
                               targetos = PointGrid.osnum);
              as$status();

	      me->action =  LOC_PAR1;
	      me->input_requested = NO_ENTRIES;
              break;

        }       /* end switch   */
        
        /* the different possible input are respectively :
               - definition of the coordinate system
               - definition of the three coordinates parameters in fonvtion of
                 the type of system's coordinate
        */


        switch( me->input_requested )
        {
         
          case POINT : 
       		if(ASget_active_symb(&me->Active_level,&me->Active_display) 
	         != OM_S_SUCCESS) return (OM_W_ABORT);
        	me->Active_display.weight += 4;

	        DYrbcspt( &me->Active_display, &me->ModuleInfo);

                token = GRget_token( &msg, TokenList, &input_mask, &grevent2,
                                     &EventSize, &resp, response_data);
                if (resp == SPECIFIED_OBJ)
                {
		 param_obj = grevent2.located_object[0].located_obj;
                 status = om$send(msg = message NDnode.NDgive_structure
                                                    (&msg,&str,&me->ModuleInfo),
                      targetid=param_obj.objid,
                      targetos=param_obj.osnum);
                 if((status&1) && (str.type == double_type ))
                  {
                    val_param = str.var.root_pm_st.value;
                    for( token=0 ; TokenList[token]!=LOC_PARAM ; token++);
                  }
                }
               else if (resp == STRING)
                {
                 status = ASget_param_from_string (response_data,double_type,
                                      &param_obj,&val_param,&me->ModuleInfo);
                 if(status&1)
                   {
                    for( token=0 ; TokenList[token]!=LOC_PARAM ; token++);
                   }
                }
                break;

          case PARENT :

               token = ASget_parent(&msg,TokenList,&grevent1,&grevent2,
                                    &loc_mask,&input_mask,&EventSize,
                                    &display_flag,&resp,response_data,
                                    me->loc_prompt,me->acc_prompt,
                                    me->reloc_prompt,&me->attr,
                                    &me->locate_stack,parent_generic,
                                    &located_obj,&context,struct_adr );

               break;

          case PARAM :

               token = ASget_param( &msg, TokenList, &grevent1, &grevent2, 
                       &loc_mask, &input_mask, &EventSize, &display_flag,
                       &resp, response_data, me->loc_prompt, me->acc_prompt,
                       me->reloc_prompt, &me->attr, &me->locate_stack,
                       &param_obj, &val_param);

               break;

          case TYPE :

               input_mask = GRm_DATA | GRm_RESET | GRm_STRING;
              
               token = GRget_token( &msg, TokenList, &input_mask, &grevent2,
                                    &EventSize, &resp, response_data );
		
               if( resp == DATA || resp == RESET ) 
			param_type = (char)RECTANGULAR;
               else if( resp == STRING )
                    {
                      if( response_data[0]=='s' || response_data[0]=='S' )
                      {
                        param_type = (char)SPHERICAL;
                      }
                      else if( response_data[0]=='c' || response_data[0]=='C' )
                      {
                        param_type = (char)CYLINDRICAL;
                      } 
                      else if( response_data[0]=='r' || response_data[0]=='R' ||
                        response_data[0]=='\0' )
                      {
                        param_type = (char)RECTANGULAR;
                      }
                      else token = UNKNOWN_TYPE;
                    }

               input_mask = GRm_DATA | GRm_RESET;
              
               break;
           
          case NO_ENTRIES : break;

          default    : return(OM_W_ABORT);

        }

      if(me->input_requested != NO_ENTRIES)
       {
        me->action = (IGRint) Action[ me->state ][ token ];
        me->state  = (IGRint) NewState[ me->state ][ token ];
       }

      /*"token %d new_action %d new_state %d\n",token,me->action,me->state */

    } while ( me->input_requested == NO_ENTRIES || 
	      TokenList[token] != GR_UNKNOWN_TYPE);  /* end do */

    *response = resp;

    return ( status );

} /* end execute method */

end implementation COcspoint;
