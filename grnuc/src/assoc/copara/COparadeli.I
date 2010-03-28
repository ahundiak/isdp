/*----
     CHANGE HISTORY:

     jla 20-jan-87   : design date
----*/

class implementation COparadel;

#include "coparadef.h"
#include "AS_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "ma.h"
#define AS_DEBUG        

#define NB_POINT       2   /* Number of points for a partial delete           */

from GRvg 
  import
  GRgenabsg,
  GRgeomprops;

from GRgraphics
  import
  GRptproject,
  GRconstruct,
  GRdisplay;

extern GRclassid OPP_ASdelseg_class_id,
                 OPP_ASmodbsp_class_id;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup 
  (
  IGRint Centring_Attribute      /* Centring Attribute of the display message */
 )

{ /*| Display the users message */

  UI_prompt("");
  ex$message( msgnumb = AC_M_ParaDele);

  /*| Return the status error */

  return(OM_S_SUCCESS);
}/* end of wakeup method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute
  (
  int  *response;                /* type of response                          */
  char *response_data;           /* contents of the response                  */
  int  pos                       
 )
  {


#define NUM_STATES   3
#define NUM_ACTIONS  8
#define NUM_TOKENS   3

enum entry { POINT,              /* Entry request for the next event          */   
             DATA_POINT,
             NOTHING
           };  

enum possible_states { 	INITIAL,
			WAIT_PT1,
			WAIT_PT2
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_SEG,
			STO_SEG,
			LOC_PT1,
			STO_PT1,
			LOC_PT2,
			MAKE_SEG
	 	       };

static IGRint TokenList[] =
 		      { 
			RESET,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ************* TOKENS *****************
  Old State  *     RESET   ,  UNKNOWN  , PARENT   */

/* INITIAL   */ { INITIAL  , INITIAL   , WAIT_PT1 },
/* WAIT_PT1  */ { INITIAL  , WAIT_PT1  , WAIT_PT2 },
/* WAIT_PT2  */ { WAIT_PT1 , WAIT_PT2  , INITIAL  }};




static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *********************** TOKENS ********************
   Old State  *     RESET    ,  UNKNOWN   , PARENT   */

/* INITIAL   */ {   LOC_SEG  ,  LOC_SEG   , STO_SEG   },
/* WAIT_PT1  */ {   LOC_SEG  ,  LOC_PT1   , STO_PT1   },
/* WAIT_PT2  */ {   LOC_PT1  ,  LOC_PT2   , MAKE_SEG  }};

                                                                            
  IGRlong   cnst_lis_msg;        /* Return msg from cnst                      */
  IGRchar   *p_geom;             /* Pointer on the abstract geometry          */
  long      status;              /* Status returned by om                     */
  IGRint    token = 0;           /* Token of the token list                   */
  IGRint    size;		 /* Size of GRevent buffer (struct GRevent)   */
  IGRlong   display_flag;	 /* Display flag for locate filter            */
  IGRlong   input_mask;	         /* Mask for GRgetevent                       */
  IGRlong   locate_mask;         /* mask for GRgetevent                       */
  IGRlong   msg;                 /* Function return code                      */
  IGRint    resp;                /* Local response of the command object      */
  IGRint    generic = 0;         /* Type of element waited                    */
  struct    GRas     asso_lis;   /* Associative information                   */
  struct    GRevent  grevent1;   /* Locate event returned by GRgetevent       */
  struct    GRevent  grevent2;   /* Accept event returned by GRgetevent       */
  struct    GRid     locate_obj; /* Object located                            */
  struct    GRid     SegmentGrid;/* Identifier of the line segment            */
  struct    GRid     DisplayGrid;/* mod_id abd space number                   */
  struct    GRid     tmp_GRid;   /* Tempory GRid for permutation              */
  struct ret_struct ret_struct;  /* Parametric structure returned             */
  struct IGRbsp_curve *bsp_curve;/* Abstract geom pointer	              */
  struct GRvg_construct cnst_lis;/* Construction list                         */
  struct    GRprops  props;      /* Properties of the support                 */
  struct    GRparms  p3_parms;   /* Parameters of the pt_proj3                */
  IGRpoint  point;               /* Coordinates of the selected point         */
  IGRpoint  pt_proj;             /* Projected point on the B_spline           */
  IGRpoint  pt3;                 /* Point to accept the part to delete        */
  IGRmatrix matrix;              /* Environment matrix                        */
  IGRshort  mat_type;		 /* Environment matrix type                   */
  int       index;               /* Index for a loop                          */
  enum      entry entry_request = NOTHING;
                                 /* Entry requested for the next event        */
  enum      GRdpmode DisplayMode;/* Display mode for display msg send         */
  struct    GRparms  p_parms
                      [NB_POINT];/* Parameters of the pt_proj                 */
  struct GRid  modif_id;         /* Identifier of the modifier of the curve   */
  struct GRid  null_grid;
  struct GRid  context;
 
 
  *response = TERMINATE;

  /*| Initialization */

  cnst_lis.msg = &cnst_lis_msg;         /* message returned from construct*/
  cnst_lis.env_info = &ME.COroot->ModuleInfo; /* context returned          */
  cnst_lis.display = &ME.COpara->Active_display; /* constr display params*/
  cnst_lis.geometry = 0;                           /* bspline geometry     */
  cnst_lis.newflag = FALSE;           
  cnst_lis.level = ME.COpara->Active_level;           
  cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.class_attr = (IGRchar *)  &asso_lis;
  cnst_lis.name = NULL;

  asso_lis.parents = ME.COparadel->list_id;
  asso_lis.num_parents = 3;
  asso_lis.go_attr = NULL;
  asso_lis.as_attr = (IGRchar *) ME.COparadel->point;
  asso_lis.context = me->context;

  DisplayMode = GRbd;                        /* how to display element   */

  /*| Get module id and space number */

  status = GRfindmod(&DisplayGrid);
  as$status();

  /*| Initialization for locate */

  size = sizeof (struct GRevent);
  locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
  input_mask = GRm_DATA | GRm_RESET;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS;

  /*| Loop until exit condition occurs  */

  do
    {
    switch (ME.COpara->action)
      {       
      case NIL :
      /*| case NIL */
        break;

      case ERR :
      /*| case ERR */

	ex$message( msgnumb = AS_E_InvDefRest);
	ME.super_cmd->state = INITIAL;
	ME.COpara->action= LOC_SEG;

      case LOC_SEG :
      /*| case LOC_SEG */

        generic = line_generic | conic_generic | curve_generic;
	ex$message( buff = ME.COpara->loc_prompt, msgnumb = AS_P_IdElePDel);
	ex$message( buff = ME.COpara->acc_prompt, msgnumb = AS_P_AccFromPnt);
        entry_request = POINT;
        break;


      case STO_SEG :
      /*| case STO_SEG */

        status = as$make_source( go_grid = locate_obj, as_grid = &locate_obj,
                                 as_os = me->ModuleInfo.md_id.osnum);
        as$status();
        if(ret_struct.type & line_generic)
          {
          /*| The class is a line */

          me->as_classid = OPP_ASdelseg_class_id;
	  }
	else
          {
          /*| The class is a B_spline */

          me->as_classid = OPP_ASmodbsp_class_id;
          status = om$send
                     (msg  = message GRvg.GRgeomprops(&msg,
                                     &ME.COroot->ModuleInfo.md_env.matrix_type,
                                     ME.COroot->ModuleInfo.md_env.matrix,
                                     &props),
                      targetos = locate_obj.osnum,
                      targetid = locate_obj.objid);
          as$status();
   
          /*| Ask if the curve has a modifier */

         null_grid = NULL_GRID;
         ASfind_modifier(locate_obj,null_grid,&modif_id);
         ME.COparadel->closed = (IF_NULL_OBJID(modif_id.objid)&&(props.closed));
          /*" curve closed = %d\n", ME.COparadel->closed */
        }/* end if(ret_struct.type & line_generic) */

        ME.COparadel->list_id[0]=locate_obj;
        ME.COparadel->context[0]=context;
        status = EXputq_front(&msg, &resp, &size, &(grevent2.event));

      case LOC_PT1 :
      /*| case LOC_PT1 */

	generic = point_generic;
	ex$message( buff = ME.COpara->loc_prompt, msgnumb = AS_P_LocFrPnt);
	ex$message( buff = ME.COpara->acc_prompt, msgnumb = AS_P_AccToPnt);
        entry_request = POINT;
	break;

      case STO_PT1 :
      /*| case STO_PT1 */
     
	ME.COparadel->list_id[1]=locate_obj;
        ME.COparadel->context[1]=context;
	status = EXputq_front(&msg, &resp, &size,&(grevent2.event));

      case LOC_PT2 :
      /*| case LOC_PT2 */

	ex$message( buff = ME.COpara->loc_prompt ,msgnumb = AS_P_LocToPnt);
        if(!ME.COparadel->closed)
          {
          /*| Open curve */

          ex$message( buff = ME.COpara->acc_prompt,msgnumb = AS_P_AccRej);
          }
        else
          {
          /*| Closed curve */

          ex$message( buff = ME.COpara->acc_prompt,msgnumb = AS_P_AccPartDel);
        }/* end if(!ME.COparadel->closed)*/
        generic = point_generic;
        entry_request = POINT;
	break;

        
      case MAKE_SEG :
      /*| case MAKE_SEG */

        /*| Construct the object ASmodbsp */

        if(!IF_EQ_OBJID(ME.COparadel->list_id[1].objid,locate_obj.objid) ||
           !IF_EQ_OBJID(ME.COparadel->context[1].objid,context.objid))
          {
          /*| The second point is not the same as the first */

	  ME.COparadel->list_id[2]=locate_obj;
	  ME.COparadel->context[2]=context;
          ME.COparadel->point[3]=0;/* 0 snap point */

          if(ME.COparadel->closed)
            {
            /*| ------------ */
            /*| Closed curve */
            /*| ------------ */
  
            /*| Project the 3rd point on the curve */
  
            pt3[0]=grevent2.event.button.x;
            pt3[1]=grevent2.event.button.y;
            pt3[2]=grevent2.event.button.z;
            status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                           &ME.COroot->ModuleInfo.md_env.matrix_type,
                                           ME.COroot->ModuleInfo.md_env.matrix,
                                           pt3,pt_proj,&p3_parms),
                            targetos = ME.COparadel->list_id[0].osnum,
                            targetid = ME.COparadel->list_id[0].objid);
            as$status();
      
            for(index=0; index < NB_POINT; index++)
              {
              /*" Project the point %d\n",ME.COparadel->list_id[index+1].objid*/
 
              mat_type = MAIDMX;
              MAidmx(&msg,matrix);
              status = om$send(msg    = message GRvg.GRgenabsg(&msg,
                                                &mat_type,
                                                matrix,
                                                &p_geom),
                             targetos = ME.COparadel->list_id[index+1].osnum,
                             targetid = ME.COparadel->list_id[index+1].objid);
              as$status();

              bsp_curve =(struct IGRbsp_curve *)p_geom;
              point[0] = bsp_curve->poles[0];
              point[1] = bsp_curve->poles[1];
              point[2] = bsp_curve->poles[2];

              status = om$send(msg     = message GRgraphics.GRptproject(&msg,
                                              &ME.COroot->ModuleInfo.md_env.matrix_type,
                                              ME.COroot->ModuleInfo.md_env.matrix,
                                              point,pt_proj,&(p_parms[index])),
                              targetos = ME.COparadel->list_id[0].osnum,
                              targetid = ME.COparadel->list_id[0].objid);
              as$status();
            }/* end for(index=0; index < NB_POINT; index++) */

            p_parms[1].u = p_parms[1].u - p_parms[0].u;
            if(p_parms[1].u < 0.) p_parms[1].u = 1.0+p_parms[1].u;
            p3_parms.u =p3_parms.u - p_parms[0].u;
            if(p3_parms.u < 0.) p3_parms.u = 1.0+p3_parms.u;
            p_parms[0].u = 0.0;

            if(p3_parms.u > p_parms[1].u)
              {
              /*| make a permutation */

              tmp_GRid=ME.COparadel->list_id[1];
              ME.COparadel->list_id[1]=ME.COparadel->list_id[2];
              ME.COparadel->list_id[2]=tmp_GRid;
            }/* end if(p3_parms.u < p_parms[2].u)*/
          }/*| if(ME.COparadel->closed)*/

          /*| Constructing the partial deleted segment */

          SegmentGrid.osnum = ME.COroot->ModuleInfo.md_id.osnum;
          status = om$construct
                     (classid = ME.COparadel->as_classid,
                      p_objid = &SegmentGrid.objid,
                      osnum   = SegmentGrid.osnum,
                      msg     = message GRgraphics.GRconstruct(&cnst_lis));
          as$status();
  
          /*| Display object by object id */

          status = om$send
                     (msg      = message GRgraphics.GRdisplay( &msg,
                                         &ME.COroot->ModuleInfo.md_env.matrix_type,
                                         ME.COroot->ModuleInfo.md_env.matrix,
                                         &DisplayMode, &DisplayGrid),
                      targetid = SegmentGrid.objid,
                      targetos = SegmentGrid.osnum);
          as$status();
          }
        else
          {
          /*| The second point is the same as the first */

          ex$message( msgnumb = AS_E_InvDefRest);
        }/* end if(!IF_EQ_OBJID(ME.COparadel->list_id[1],locate_obj))*/

	/*| Restart the command */

        generic = line_generic | conic_generic | curve_generic;
        ex$message( buff = ME.COpara->loc_prompt, msgnumb = AS_P_IdElePDel);
        ex$message( buff = ME.COpara->acc_prompt , msgnumb = AS_P_AccFromPnt);
        entry_request = POINT;
        break;

    }/* end switch (ME.super_cmd->state) */

  if(entry_request != NOTHING)
    {
    switch(entry_request)
      {
      case DATA_POINT :
        token = GRget_token(&msg,TokenList,&input_mask,&grevent1,&size,
	    		    &resp,response_data);
        break;

      case POINT:

     token = ASget_parent (&msg,TokenList, &grevent1, &grevent2,
              &locate_mask, &input_mask, &size, &display_flag, &resp,
              response_data, ME.COpara->loc_prompt,
              ME.COpara->acc_prompt,ME.COpara->reloc_prompt,
              &ME.COpara->attr, &ME.COpara->locate_stack,
              generic,&locate_obj,&context,&ret_struct);
    }/* end switch(entry_request)*/

    /*| Compute new state and new action */

    ME.COpara->action = (IGRint) Action[   ME.super_cmd->state ][ token ];
    ME.super_cmd->state =  (IGRint) NewState[ ME.super_cmd->state ][ token ];
  }/* end if(entry_request != NOTHING) */

  /*"token : %d \n",token */
  /*"new_state : %d \n",ME.super_cmd->state */
  /*"new_action : %d \n",ME.COpara->action */


  }while( TokenList[token]  != GR_UNKNOWN_TYPE);   /* end do */

  *response = resp;
  return( status);
}/* end execute method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation COparadel;

