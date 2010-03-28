/*----
     NOTES:
           depending upon the argument passed in the init method (stored in
           me->mytype) 
     CHANGE HISTORY:

     S.Frezefond  17-jul-86  : Design date
     jla          03-nov-86  : Revue and associative implementation
     jla          20-mar-86  : curve implementation
     jla          09-nov-87  : closed curve control
     jla          10-jun-88  : event generator
     jla          10-jun-88  : command interruption when the user is asked for
			       the number of points
     Sudha        24-Oct-94  : Fix TR# 119422104 TD/SSL - added BSprototyping

----*/

class implementation COeqpts;

#include "msmacros.h"
#include "ASmessages.h"
#include "coparadef.h"
#include "AS_status.h"
#include "exmacros.h"
#include "bserr.h"
#include "OMmacros.h"
#include "bsprptoncv.h"

#define AS_DEBUG

from GRgraphics import GRdisplay,GRptproject,GRconstruct,GRlnproject,
		       GRchgprops;
from GRvg 	import GRgenabsg,GRgeomprops;

#define POINT_GEN       0x001   /* command asking for points           */
#define CURVE_GEN       0x002   /* command locating curve              */
#define NB_GEN          0x004   /* command asking number of points     */


#define BETWEEN_PT      0x005
#define ON_CURVE        0x006
#define ON_CURVE_LIM    0x007

extern GRclassid OPP_ASindexpt_class_id;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{

/*"mytype %x\n",me->mytype */

  switch(me->mytype)
     {
      case BETWEEN_PT : /* equidistant point between 2 points */
        ex$message( msgnumb = AC_M_PlaEqPnt2);
	break;
      case ON_CURVE_LIM : /* equidistant point on curve with limits */
        ex$message( msgnumb = AC_M_PlaEqPntCL);
	break;
      case ON_CURVE : /* equidistant point on curve */
        ex$message( msgnumb = AC_M_PlaEqPntC);
	break;
    }
  return( OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response; char *response_data; int  pos)
{


#define NUM_STATES 4
#define NUM_TOKENS 4


enum possible_states { 	INITIAL,
			HAV_SUP,
			HAV_PT1,
			HAV_PT2
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_SUP,
			STO_SUP,
			LOC_PT1,
			STO_PT1,
			LOC_PT2,
			STO_PT2,
			GET_NUM,
			RES_NUM,
			CREATE
		       };

enum possible_entry { PARENT,
		      NUMBER,
		      NOENT };


static IGRint TokenList[] =
 		      { RESET,
			STRING,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            **************** TOKENS *************
   Old State  *   RESET   , STRING  ,  UNKNOWN  , PARENT    */

/* INITIAL    */ {INITIAL , INITIAL , INITIAL   , HAV_SUP   },
/* HAV_SUP    */ {INITIAL , INITIAL , HAV_SUP   , HAV_PT1   },
/* HAV_PT1    */ {HAV_SUP , INITIAL , HAV_PT1   , HAV_PT2   },
/* HAV_PT2    */ {HAV_PT1 , INITIAL , HAV_PT2   , INITIAL   }};



static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*            **************** TOKENS ************
   Old State  *   RESET   , STRING  , UNKNOWN   , PARENT    */

/* INITIAL    */ {NIL     , ERR     , LOC_SUP   , STO_SUP   },
/* HAV_SUP    */ {LOC_SUP , CREATE  , LOC_PT1   , STO_PT1   },
/* HAV_PT1    */ {LOC_PT1 , ERR     , LOC_PT2   , STO_PT2   },
/* HAV_PT2    */ {LOC_PT2 , CREATE  , GET_NUM   , ERR       }};

  struct GRvg_construct        cnst_lis;     /* construction list         */
  struct GRas                  asso_lis;     /* associative const. list   */

  IGRlong     cnst_lis_msg;  /* return msg from cnst          */


  enum GRdpmode     DisplayMode;    /* display mode for display msg send */
  GRclassid         classid;        /* classid for object        */

  /* KLUDGE - THERE IS NO SYMBOL "GRCLASSLENGTH" IN ANY INCLUDE FILE YET - 
    IT IS DEFINED IN THIS FILE UNTIL THIS IS DONE  */



  IGRint      status;         /* routine return status */
  IGRint      size;           /* size of GRevent buffer (struct GRevent) */
  IGRlong     display_flag;   /* display flag for locate filter */
  IGRlong     input_mask;     /* mask for GRgetevent */
  IGRlong     locate_mask;    /* mask for GRgetevent */
  IGRlong     msg;            /* function return code */

  struct  GRevent           grevent1;     /* event returned by GRgetevent */
  struct  GRevent           grevent2;     /* event returned by GRgetevent */
  struct GRid               PointGrid;    /* grid for line segment        */
  struct GRid               DisplayGrid;

  IGRint resp;
  struct GRid locate_obj;
  struct GRid  context;
  struct ret_struct obj_struct;
  IGRint token = 0;
  IGRint nb_point,i_point;
  IGRdouble xbary[4];
  IGRint ok;
  IGRint obj_generic = 0;
  enum possible_entry entry_requested = NOENT;
  struct    GRprops  props;
  IGRdouble eps = 1.e-10;


  *response = TERMINATE;
/* cnst_list initialization */

  cnst_lis.msg = &cnst_lis_msg;         /* message returned from construct*/
  cnst_lis.env_info = &me->ModuleInfo; /* context returned          */
  cnst_lis.display = &me->Active_display; /* constr display params*/
  cnst_lis.geometry = 0;          		    /* bspline geometry     */
  cnst_lis.newflag = FALSE;
  cnst_lis.level = me->Active_level;
  cnst_lis.properties =  GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.class_attr = (IGRchar *) &asso_lis;
  cnst_lis.name = NULL;

  asso_lis.parents  = me->list_id;
  asso_lis.go_attr  = NULL;
  asso_lis.as_attr  = (IGRchar *)xbary;

  asso_lis.context = me->context;

  /* How to display the element */
  DisplayMode = GRbd;

  classid = OPP_ASindexpt_class_id;

  /*
   * get module id and space number.
   */
  status = GRfindmod(&DisplayGrid);
  if( !(status&1))
  {
    printf(" COeqpts: err: GRfindmod status = %d\n", status);
    om$report_error(sts = status);
  }


  /*
   *  Initialization for locate
   */

  size = sizeof (struct GRevent);
  ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
  locate_mask = GRm_DATA | GRm_RESET;
  input_mask = GRm_DATA | GRm_RESET;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS;


  /*
   *  loop until exit condition occurs
   */

 do
  {
    switch (me->action)
    {

    case NIL :				/*| NIL */
	break;

    case ERR :				/*| ERR */
	ex$message( msgnumb = AS_E_InvDefRest);
	me->state = INITIAL;
	me->action = LOC_SUP;

    case LOC_SUP :			/*| LOC_SUP */
	me->closed = FALSE;
        input_mask = GRm_DATA | GRm_RESET;
	if(me->mytype&CURVE_GEN)
	  {
	   ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdCurve);
	   switch(me->mytype)
	    {
	     default : 
	        ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
		break;

	     case ON_CURVE_LIM :
	   	ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccStart);
		break;

	    }
	   obj_generic = line_generic | conic_generic | curve_generic;
	   entry_requested = PARENT;
	  }
	else
	  {
	   me->action = LOC_PT1;
	   me->state = HAV_SUP;
	   entry_requested = NOENT;
	  }
        break;


    case STO_SUP :			/*| STO_SUP */
	me->list_id[0] = locate_obj;
        me->context[0] = context;
	me->num_id = 1;

        /* Is the curve open or closed ? */
        status = om$send
                 (msg  = message GRvg.GRgeomprops(&msg,
                                    &me->ModuleInfo.md_env.matrix_type,
                                    me->ModuleInfo.md_env.matrix,
                                    &props),
                  targetid = me->list_id[0].objid,
                  targetos = me->list_id[0].osnum);
  	as$status(action = RET_STATUS);
        me->closed = props.phy_closed;

	if((me->mytype & POINT_GEN ) && (grevent1.response != SPECIFIED_OBJ))
	status = EXputq_front(&msg, &resp, (IGRlong *)&size, (IGRchar *)&(grevent2.event));
	
    case LOC_PT1 :			/*| LOC_PT1 */
        input_mask = GRm_DATA | GRm_RESET;
	if(me->mytype & POINT_GEN )
	  {
	   ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdStart);
	   ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccEndPnt);
	   entry_requested = PARENT;
	   obj_generic = point_generic;
	  }
	else
	  {
	   me->action = GET_NUM;
	   entry_requested = NOENT;
	  }
        break;


    case STO_PT1 :				/*| STO_PT1 */ 
        if(me->mytype&CURVE_GEN) me->num_id = 1;
        else			 me->num_id = 0;

	me->list_id[me->num_id] = locate_obj;
        me->context[me->num_id] = context;
	me->num_id += 1;
        

	if(grevent1.response != SPECIFIED_OBJ)
	   status = EXputq_front(&msg, &resp, (IGRlong *)&size, (IGRchar
*)&(grevent2.event));

     case LOC_PT2 :				/*| LOC_PT2 */
        input_mask = GRm_DATA | GRm_RESET;

	ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdEndPnt);
 	
        if( me->closed)
	   { ex$message( buff =  me->acc_prompt , msgnumb = AS_P_AccOriePnt);}
	else
	   { ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej); }

	entry_requested = PARENT;
	obj_generic = point_generic;
        break;


     case STO_PT2 :				/*| STO_PT2 */
       if(me->mytype&CURVE_GEN) me->num_id = 2;
       else			me->num_id = 1;
       me->list_id[me->num_id] = locate_obj;
       me->context[me->num_id] = context;
       me->num_id += 1;

     /* If closed curve put the points in the right order */

       if(me->closed)
         {
	  struct ret_struct ptdef;
 	  struct GRparms pt_parms;
	  IGRpoint pt1,pt2;
          IGRdouble par1,par2,par3;
          IGRchar *ptr;
          struct IGRbsp_curve *bc;
          IGRlong msg;
          IGRlong rc;
    	  IGRboolean	  rc1;

	  ASany_give_struct(me->list_id[1].objid,me->list_id[1].osnum,
	  		    &me->ModuleInfo,&ptdef);

          status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &me->ModuleInfo.md_env.matrix_type,
                                       me->ModuleInfo.md_env.matrix,
                                       ptdef.var.point_st.pt,pt1,&pt_parms),
                            targetid = me->list_id[0].objid,
                            targetos = me->list_id[0].osnum);
        

	  ASany_give_struct(me->list_id[2].objid,me->list_id[2].osnum,
	  		    &me->ModuleInfo,&ptdef);

          status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &me->ModuleInfo.md_env.matrix_type,
                                       me->ModuleInfo.md_env.matrix,
                                       ptdef.var.point_st.pt,pt2,&pt_parms),
                            targetid = me->list_id[0].objid,
                            targetos = me->list_id[0].osnum);

          status=om$send(msg = message GRvg.GRgenabsg(&msg,
					&me->ModuleInfo.md_env.matrix_type,
		 		 	 me->ModuleInfo.md_env.matrix, &ptr),
                         targetid = me->list_id[0].objid,
		         targetos = me->list_id[0].osnum);
    	  as$status(action = RET_STATUS);

          bc = (struct IGRbsp_curve *)ptr;

    	  BSprptoncv(&rc,bc,pt1,&par1,&rc1);
    	  if(rc != BSSUCC)
           {printf("can't compute parameter value\n");
            return(OM_W_ABORT);}
	  
    	  BSprptoncv(&rc,bc,pt2,&par2,&rc1);
    	  if(rc != BSSUCC)
           {printf("can't compute parameter value\n");
            return(OM_W_ABORT);}
	  
    	  BSprptoncv(&rc,bc,&grevent2.event.button.x,&par3,&rc1);
    	  if(rc != BSSUCC)
           {printf("can't compute parameter value\n");
            return(OM_W_ABORT);}

	  if(par2<par1) par2 +=1 ;
	  if(par3<par1) par3 +=1 ;
	  if((par3-par1)*(par3-par2)>0)
	    {
	     struct GRid prov;
	     prov = me->list_id[1];
	     me->list_id[1]=me->list_id[2];
	     me->list_id[2]=prov;
	     /*| flip points */
	    }
         }

      /*
       * get number of points
       */

      case GET_NUM :				/*| GET_NUM */

         ex$message( msgnumb = AS_P_NumPnt);
         input_mask = GRm_STRING | GRm_RESET;
  	 entry_requested = NUMBER;
	 break;

      /*
       * Reset when the number of points is asked for 
       */
	
    case RES_NUM :				/*| RES_NUM */
      switch(me->mytype)
       { 
        case ON_CURVE:
	     me->state = INITIAL;
	     me->action = LOC_SUP; 
	     break;

        case BETWEEN_PT:
        case ON_CURVE_LIM:
	     me->state = HAV_PT1;
	     me->action = LOC_PT2; 
	     break;
       }
      entry_requested = NOENT;
      break;

	

     case CREATE  :				/*| CREATE */
         ok = sscanf(response_data,"%d",&nb_point);
         if( ok != 1 || nb_point <=0 )
	   {
            entry_requested = NOENT;
            me->state = INITIAL;
            me->action = LOC_SUP;
            ex$message( msgnumb = AS_E_INumRest);
            break;
	   }

      /*
       *  construct object by classid
       */

  /* get active symbology and level */

    if(ASget_active_symb(&me->Active_level,&me->Active_display) != OM_S_SUCCESS)
		 return (OM_W_ABORT);

    cnst_lis.level = me->Active_level;           
    me->Active_display.weight += 3 ;

    asso_lis.num_parents = me->num_id;
    PointGrid.osnum = me->ModuleInfo.md_id.osnum;
 
/* verify that the roots of the objects are different                         */

        cmp_parent( &msg, 
                    &asso_lis.num_parents, 
                    asso_lis.parents, 
                    asso_lis.context );

        if( msg == OM_W_ABORT )
        {
         ex$message(msgnumb = AS_S_RtDif);
         me->state = INITIAL;
         me->action= LOC_SUP;
         entry_requested = NOENT;
         break;
        }

   for(i_point=0 ; i_point<nb_point ; i_point++)
   {
    switch(me->mytype)
     { 
      case ON_CURVE:
	if(nb_point != 1)
	  {
	   if(me->closed)
	          xbary[0] = (eps*(nb_point-i_point) + (1.-eps)*i_point)/
					             (IGRdouble) (nb_point);
	   else
	          xbary[0] = (eps*(nb_point-i_point-1) + (1.-eps)*i_point)/
					             (IGRdouble) (nb_point-1);
	  }
	else
	  {
	    xbary[0] = 0.5;
	  }
	break;

      case BETWEEN_PT:
      case ON_CURVE_LIM:
	xbary[0] = (IGRdouble) (i_point+1)/(IGRdouble) (nb_point+1);
	break;

     }

        status = om$construct(osnum = PointGrid.osnum, classid = classid,
			     p_objid = &PointGrid.objid,
                             msg = message GRgraphics.GRconstruct(&cnst_lis));
  	as$status(action = RET_STATUS);


        /*
         * Display object by object id
         */

          status = om$send(msg = message GRgraphics.GRdisplay( &msg,
                      		&me->ModuleInfo.md_env.matrix_type,
                      		me->ModuleInfo.md_env.matrix,
                      		&DisplayMode, &DisplayGrid),
            	           targetid = PointGrid.objid,
			   targetos = PointGrid.osnum);
  	  as$status(action = RET_STATUS);
     } /* end of the for construction loop */
     me->state = INITIAL;
     me->action= LOC_SUP;
     entry_requested = NOENT;
     break;
    }   /* end switch (me->action) */


/* 
   next definition point or reset
*/


     switch (entry_requested) 
      {
       case PARENT :
	   token = ASget_parent (&msg,TokenList, &grevent1, &grevent2,
                    &locate_mask, &input_mask, &size, &display_flag,
                    &resp, response_data, me->loc_prompt,
		    me->acc_prompt, me->reloc_prompt,
		    &me->attr, &me->locate_stack,
                    obj_generic,&locate_obj,&context,&obj_struct);
	   break;

      case NUMBER :
        token = GRget_token(&msg,TokenList,&input_mask,&grevent2,&size,
                            &resp,response_data);
        break;

     case NOENT :
        break;
    }

    /* new action and new state */
	
   if(entry_requested != NOENT)
     {
      me->action = (IGRint) Action[   me->state ][ token ];
      me->state =  (IGRint) NewState[ me->state ][ token ];
     }
   /*"new action %d new state %d\n",me->action,me->state */

  }  while(entry_requested  == NOENT  ||
	     TokenList[token] != GR_UNKNOWN_TYPE);   /* end do */


  *response = resp;
  return(OM_S_SUCCESS);

}   /*  end execute method */

end implementation COeqpts;
