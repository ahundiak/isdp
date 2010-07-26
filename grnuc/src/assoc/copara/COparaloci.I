/*----
     CHANGE HISTORY:

        jla  13-jul-88  : Design date

----*/

class implementation COparaloc;
#include "msmacros.h"
#include "ASmessages.h"
#include "grmessage.h"
#include "coparadef.h"
#include "AS_status.h"
#include "exmacros.h"
#include "nddef.h"
#include "OMmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "ASmatrix.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"


#define AS_DEBUG
/* #define GRst_ASSOC_KEYPOINT 47 */


from GRgraphics import GRconstruct,GRdisplay,GRlnproject,GRchgprops;

from NDnode import NDgive_structure,NDchg_state;

from IGEgragad import DPinrot;

from GRcurve    import GRmidpoint,GRendpoint,GRgenabsg;

from ACpretend  import ACpconnect;

from ci_macro import give_internal_ptr;

#define LINE_GEN      0x01        /* command creates a line  	           */
#define POINT_GEN     0x02        /* command creates a point  	           */
#define REF_GEN       0x04        /* command creates a coordinate syst     */

#define EVENT_GEN     0x10        /* command is an event generator         */
#define TRACK_GEN     0x20	  /* command accept a track point          */
#define WIND_GEN      0x40        /* command needs to get window matrix    */
#define PROJ_SNAP     0x80        /* command needs to project accept point */
				  /* on first located element 		   */

#define DBT_LINE      0x101        /* dec 257  */
#define BY_2_PT_SG    0x201        /* dec 513  */

#define BY_3_PT_ORTHO 0x301        /* dec 769  */
#define CURVE_ORTHO   0x401        /* dec 1025 */

#define KEY_SEG       0x4a1        /* dec 1185 */
#define KEY_SEG_EVENT 0x4b1	   /* dec 1201 */

#define INT_POINT     0x122        /* dec 290  */
#define INT_EVENT     0x132        /* dec 306  */

#define KEY_POINT     0x2a2 	   /* dec 674  */
#define KEY_EVENT     0x2b2	   /* dec 690  */
#define KEY_TEXT     0x1282	   /* not in command table */

#define MID_POINT     0x382        /* dec 898  */
#define MID_EVENT     0x392        /* dec 914  */
#define MID_TEXT     0x1382	   /* not in command table */

#define PROJ_POINT    0x4a2        /* dec 1186 */
#define PROJ_EVENT    0x4b2        /* dec 1202 */

#define CENT_POINT    0x5a2        /* dec 1442 */
#define CENT_EVENT    0x5b2        /* dec 1458 */

#define TANG_POINT    0x6a2	   /* dec 1698 */
#define TANG_EVENT    0x6b2        /* dec 1714 */


#define WIND_REF      0x144        /* dec 324 */
#define BY_3_PT_REF   0x204        /* dec 516 */
#define BY_Z_REF      0x304	   /* dec 772 */


#define NUM_STATES 3
#define NUM_ACTIONS 9
#define NUM_TOKENS 3


enum possible_states {  INITIAL,
                        HAV_1,
                        HAV_2   };

enum possible_actions { NIL,
                        ERR,
                        LOC_1,
                        STO_1,
                        LOC_2,
                        STO_2,
                        LOC_3,
			STO_3,
                        CREATE };

enum possible_entries { PARENT,
			NOENT  };
                    
extern GRclassid  OPP_ASlinedbt_class_id,
		  OPP_ASby2ptsg_class_id,
		  OPP_ASlineorth_class_id,
		  OPP_ASkeyseg_class_id,

       		  OPP_ASintpt_class_id,
		  OPP_ASkeypt_class_id,
		  OPP_ASindexpt_class_id,
		  OPP_AScenpt_class_id,
		  OPP_AStangpt_class_id,
		  OPP_ASboxpt_class_id,

       		  OPP_ASwindref_class_id,
       		  OPP_ASby3ptref_class_id,
       		  OPP_ASbyzref_class_id,

		  OPP_ACpretend_class_id;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ momo  Dec-88 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                            */
/*             verify that the roots of the objects are different             */
/*                                                                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


IGRint cmp_parent( msg, num_parents, list_parents, list_context )

IGRlong 	*msg;
OMuint  	*num_parents;
struct GRid 	*list_parents;
struct GRid	*list_context;

/*. cmp_parent */
{

 IGRint	iver1,iver2;

 for( iver1=0 ; iver1 < *num_parents ; iver1++ )
 {
   for( iver2=0 ; iver2 < iver1 ; iver2++ )
   {
     if( (IF_EQ_OBJID( list_parents[iver1].objid, list_parents[iver2].objid))&&
         (list_parents[iver1].osnum == list_parents[iver2].osnum)            && 
         (IF_EQ_OBJID( list_context[iver1].objid, list_context[iver2].objid))&&
         (list_context[iver1].osnum == list_context[iver2].osnum) )
     {
       *msg = OM_W_ABORT ;
       return 1;
     }

   }
 }

 *msg = OM_S_SUCCESS ;
 return 1;


}

/*~~~~~~~~~~~~~~~~~~~~~~~ end of cmp_parent ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             cs_for_dim                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

%safe
int AS_dim_in_progress = 0;
%endsafe
AScs_for_dim(window_id,cs_id)
struct GRid window_id,*cs_id;
/*.AScs_for_dim */
{
 IGRint _pla_i;
 IGRlong status;
 IGRchar *dat_local_st;
 IGRchar *_string1 = {"dim:windows:ige_wind000"};
 IGRchar *_string2 = {"dim:windows:dim_plan000"};
 IGRchar *_string3 = {"dim:windows:act_plan000"};
 struct GRid act_plan,dim_plan,dim_wind,dat_local;
#define                 AXEX    0
#define                 AXEY    1
#define                 BY2PT   2
#define                 AXEX_WIND    3
#define                 AXEY_WIND    4
#define                 ORTHOGONAL   5



 cs_id->objid = NULL_OBJID;
 if(!AS_dim_in_progress) return 1; 

/* 
   The dimensioning measurement axis must be either PARALLEL or 
   PERPENDICULAR to use the active dimensioning plane
*/

    di$translate ( objname  =  "dim:dat_local",
                   osnum = window_id.osnum,
                   p_objid  =  &dat_local.objid,
                   p_osnum  =  &dat_local.osnum);
   

    status = om$send(msg = message ci_macro.give_internal_ptr((IGRint *)&status,&dat_local_st),
		     senderid = NULL_OBJID,
		     targetid = dat_local.objid,
		     targetos = dat_local.osnum);

    if (! (dat_local_st[27] == AXEX || dat_local_st[27] == AXEY))
         return 1;
/*
   During a dim command, the point at tangency has to be construcuted 
   relative to the dim coor. syst
   This coor. syst. depends upon the window
*/

  for (_pla_i=0; _pla_i<100; _pla_i=_pla_i+1)
   {
    sprintf(_string1+20,"%d",_pla_i);
    /*"string1 %s\n",_string1 */
    di$translate ( objname  =  _string1,
                   osnum = window_id.osnum,
                   p_objid  =  &dim_wind.objid);
    /*"dim_wind %d\n",dim_wind.objid */

    if (IF_EQ_OBJID(dim_wind.objid,NULL_OBJID)) return 1;
    else if(!IF_EQ_OBJID(dim_wind.objid,window_id.objid)) continue;

    /*| found */

    sprintf(_string2+20,"%d",_pla_i);
    /*"string2 %s\n",_string2 */
    di$translate ( objname  =  _string2,
                   osnum = window_id.osnum,
                   p_objid  =  &dim_plan.objid);
    /*"dim_plan %d\n",dim_plan.objid */

    sprintf(_string3+20,"%d",_pla_i);
    /*"string3 %s\n",_string3 */
    di$translate ( objname  =  _string3,
                   osnum = window_id.osnum,
                   p_objid  =  &act_plan.objid);
    /*"act_plan %d\n",act_plan.objid */

    if(IF_EQ_OBJID(dim_plan.objid,act_plan.objid)) return 1; 

    act_plan.osnum = window_id.osnum;
    status = om$construct(classid = OPP_ACpretend_class_id,
			  osnum = window_id.osnum,
			  p_objid = &cs_id->objid);
    as$status(action = RET_STATUS);
    cs_id->osnum = window_id.osnum;

    status = om$send(msg = message ACpretend.ACpconnect(0,act_plan,"pla_wind"),
		     senderid = NULL_OBJID,
		     targetid = cs_id->objid,     
		     targetos = cs_id->osnum);
    if(!(status&1))
      { as$status();
	status = om$send(msg = message Root.delete(1),
		     senderid = NULL_OBJID,
		     targetid = cs_id->objid,     
		     targetos = cs_id->osnum);
	cs_id->objid = NULL_OBJID;
      }
    return 1;
   }
  return 1;
 }

 
 

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
   printf("COparaloc unknown case x-> %x d-> %d\n",me->mytype,me->mytype);
   me->num_locate = -1;
   return(OM_W_ABORT);
     
   case DBT_LINE :
   ex$message( msgnumb = AC_M_PlaLinTan2);
   me->as_classid  = OPP_ASlinedbt_class_id;
   me->num_locate = 2;
   me->loc[0]  = AS_P_IdCirPnt;
   me->acc[0]  = AS_P_AccCirPnt;
   me->req_type[0] = point_generic | conic_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdCirPnt;
   me->acc[1]  = AS_P_AccRej;
   me->req_type[1] = point_generic | conic_generic;
   me->reput[1] = 0;
   break;

   case BY_2_PT_SG :
   ex$message( msgnumb = AC_M_PlaSeg);
   me->as_classid  = OPP_ASby2ptsg_class_id;
   me->num_locate = 2;
   me->loc[0]  = AS_P_IdStart;
   me->acc[0]  = AS_P_AccEndPnt;
   me->req_type[0] = point_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdEndPnt;
   me->acc[1]  = AS_P_AccNexEd;
   me->req_type[1] = point_generic;
   me->reput[1] = 1;

   me->restart_state  = HAV_1;
   me->restart_action = LOC_2;
   me->reput_locate = 1;
   break;

   case KEY_SEG :
   case KEY_SEG_EVENT :
   if(me->mytype == KEY_SEG) {ex$message( msgnumb = AC_M_PlaKeySeg);}
   else			     {ex$message( msgnumb = AC_M_GenKeySeg);}

   me->as_classid  = OPP_ASkeyseg_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurve;
   me->acc[0]  = AS_P_AccOnKeySeg;
   me->req_type[0] = line_generic | curve_generic;
   me->reput[0] = 0;
   break;


   case CURVE_ORTHO :
   ex$message( msgnumb = AC_M_PlaOrth);
   me->num_locate = 2;

   me->as_classid = OPP_ASlineorth_class_id;
   me->loc[0]  = AS_P_IdMiddle;
   me->acc[0]  = AS_P_AccCurvSys;
   me->req_type[0] = point_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdCurvSys;
   me->acc[1]  = AS_P_AccExt;
   me->req_type[1] = ref_generic | curve_generic | conic_generic;
   me->reput[1] = 0;

   break;

   case BY_3_PT_ORTHO :
   ex$message( msgnumb = AC_M_Pla3PtOrth);
   me->as_classid = OPP_ASlineorth_class_id;
   me->num_locate = 3;
   me->loc[0]  = AS_P_IdMiddle;
   me->acc[0]  = AS_P_AccOxy1;
   me->req_type[0] = point_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdOxy1;
   me->acc[1]  = AS_P_AccOxy2;
   me->req_type[1] = point_generic;
   me->reput[1] = 1;

   me->loc[2]  = AS_P_IdOxy2;
   me->acc[2]  = AS_P_AccExt;
   me->req_type[2] = point_generic;
   me->reput[2] = 0;
   break;
  
   

   case INT_POINT :
   case INT_EVENT :
   if(me->mytype == INT_POINT){ ex$message( msgnumb = AC_M_PlaIntPnt);}
   else			      { ex$message( msgnumb = AC_M_PlaInt);}

   me->as_classid  = OPP_ASintpt_class_id;
   me->num_locate = 2;
   me->loc[0]  = GR_P_Id1stEle;
   me->acc[0]  = AS_P_Acc2ele;
   me->req_type[0] = line_generic | conic_generic | lbs_generic | curve_generic;
   me->reput[0] = 1;

   me->loc[1]  = GR_P_IdSecEle;
   me->acc[1]  = AS_P_AccNearInt;
   me->req_type[1] = line_generic | conic_generic | lbs_generic | curve_generic;
   me->reput[1] = 0;
   break;

   case KEY_EVENT :
   case KEY_POINT :
   if(me->mytype == KEY_POINT){ ex$message( msgnumb = AC_M_PlaKeyPnt);}
   else			      { ex$message( msgnumb = AC_M_PlaKey);}
   me->as_classid  = OPP_ASkeypt_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurOrTex;
   me->acc[0]  = AS_P_AccKey;
   me->req_type[0]=line_generic | curve_generic | conic_generic | lbs_generic;
   me->reput[0] = 0;
   break;

   case MID_POINT :
   case MID_EVENT :
   if(me->mytype == MID_POINT) {ex$message( msgnumb = AC_M_PlaMiddlPt);}
   else			       {ex$message( msgnumb = AC_M_PlaMiddl);}
   me->as_classid  = OPP_ASindexpt_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurOrTex;
   me->acc[0]  = AS_P_AccMid;
   me->req_type[0]=line_generic | curve_generic | conic_generic | lbs_generic;
   me->reput[0] = 0;
   break;

   case PROJ_POINT:
   case PROJ_EVENT:
   if(me->mytype == PROJ_POINT) {ex$message( msgnumb = AC_M_PlaProjPt);}
   else			        {ex$message( msgnumb = AC_M_PlaProj);}
   me->as_classid  = OPP_ASindexpt_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurve;
   me->acc[0]  = AS_P_AccProj;
   me->req_type[0] = line_generic | curve_generic | conic_generic;
   me->reput[0] = 0;
   break;

   case CENT_POINT:
   case CENT_EVENT:
   if(me->mytype == CENT_POINT){ ex$message( msgnumb = AC_M_PlaCentPt);}
   else			       { ex$message( msgnumb = AC_M_PlaCent);}
   me->as_classid  = OPP_AScenpt_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurve;
   me->acc[0]  = AS_P_AccCent;
   me->req_type[0] = curve_generic | conic_generic;
   me->reput[0] = 0;
   break;


   case TANG_POINT:
   case TANG_EVENT:
   if(me->mytype == TANG_POINT){ ex$message( msgnumb = AC_M_PlaTangPt);}
   else			       { ex$message( msgnumb = AC_M_PlaTang);}
   me->as_classid  = OPP_AStangpt_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdCurve;
   me->acc[0]  = AS_P_AccTang;
   me->req_type[0] = curve_generic | conic_generic;
   me->reput[0] = 0;
   break;



   case WIND_REF :
   ex$message( msgnumb = AC_M_PlaWinRef);
   me->as_classid  = OPP_ASwindref_class_id;
   me->num_locate = 1;
   me->loc[0]  = AS_P_IdOrgPnt;
   me->acc[0]  = AS_P_AccRej;
   me->req_type[0] = point_generic;
   me->reput[0] = 0;
   break;

   case BY_3_PT_REF :
   ex$message( msgnumb = AC_M_PlaRef3);
   me->as_classid  = OPP_ASby3ptref_class_id;
   me->num_locate = 3;
   me->loc[0]  = AS_P_IdOrgPnt;
   me->acc[0]  = AS_P_AccXaxis;
   me->req_type[0] = point_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdXax;
   me->acc[1]  = AS_P_AccYaxis;
   me->req_type[1] = point_generic;
   me->reput[1] = 1;

   me->loc[2]  = AS_P_IdYax; 
   me->acc[2]  = AS_P_AccRej;
   me->req_type[2] = point_generic;
   me->reput[2] = 0;
   break;


   case BY_Z_REF :
   ex$message( msgnumb = AC_M_PlaRefZ);
   me->as_classid  = OPP_ASbyzref_class_id;
   me->num_locate = 3;

   me->loc[0]  = AS_P_IdOrgPnt;
   me->acc[0]  = AS_P_AccCurZ;
   me->req_type[0] = point_generic;
   me->reput[0] = 1;

   me->loc[1]  = AS_P_IdCurZ;
   me->acc[1]  = AS_P_AccLinX;
   me->req_type[1] = line_generic | conic_generic | curve_generic;
   me->reput[1] = 1;

   me->loc[2]  = AS_P_IdLinX;
   me->acc[2]  = AS_P_AccRej;
   me->req_type[2] = line_generic;
   me->reput[2] = 0;
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



#define NUM_STATES 3
#define NUM_ACTIONS 9
#define NUM_TOKENS 3


enum possible_states {  INITIAL,
                        HAV_1,
                        HAV_2   };

enum possible_actions { NIL,
                        ERR,
                        LOC_1,
                        STO_1,
                        LOC_2,
                        STO_2,
                        LOC_3,
			STO_3,
                        CREATE };

enum possible_entries { PARENT,
			NOENT  };
                    


static IGRint TokenList[] =
                      { D_RESET,
                        GR_UNKNOWN_TYPE ,
                        LOC_PARENT        };



static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {
/*            **************** TOKENS *************
   Old State  *   BACKUP    ,  UNKNOWN   , PARENT */

/* INITIAL    */ {INITIAL   , INITIAL   , HAV_1     },
/* HAV_1      */ {INITIAL   , HAV_1     , HAV_2     },
/* HAV_2      */ {HAV_1     , HAV_2     , INITIAL   }};



static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*            **************** TOKENS ************
   Old State  *   BACKUP    , UNKNOWN   , PARENT */

/* INITIAL    */ {NIL       , LOC_1     , STO_1   },
/* HAV_1      */ {LOC_1     , LOC_2     , STO_2   },
/* HAV_2      */ {LOC_2     , LOC_3     , STO_3    }};


    struct GRvg_construct        cnst_lis;     /* construction list         */
    struct GRas                  asso_lis;     /* associative information   */

    IGRlong     cnst_lis_msg;  /* return msg from cnst          */

                                            
    enum GRdpmode     DisplayMode;    /* display mode for display msg send */



    IGRint      status;         /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */
    IGRlong     msg;            /* function return code */

    int    resp;
    struct GRevent           grevent2;     /* event returned by GRgetevent   */
    struct GRid              ConstructGrid;/* grid of the constructed object */
    struct GRid              DisplayGrid;
    struct GRid 	     tmp_grid;
    enum possible_entries entry_requested = NOENT;
    struct ret_struct ret_struct;
    IGRint token = 0,iloc = 0;
    IGRpoint dummy_pt,dummy_pt1,snap_point;
    IGRdouble dummy_par,dmin,xbar[3];
    struct IGRline boreline;
    IGRmatrix view_rot;
    struct GRparms parms;
    IGRint compute_type;

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

    asso_lis.num_parents = me->num_locate;
    asso_lis.parents = me->list_id;
    asso_lis.context = me->context;

    asso_lis.go_attr = NULL;
    asso_lis.as_attr = (IGRchar *) me->snap;


    DisplayMode = GRbd;                        /* how to display element   */

    /*
     * get module id and space number.
     */

    status = GRfindmod(&DisplayGrid);
    if( COERROR(status))
    {
        printf(" COparaloc: err: GRfindmod status = %d\n", status);
        om$report_error(sts = status);
    }

    /*
     *  Initialization for locate
     */

    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_RESET | GRm_BACK_UP;
    input_mask =  GRm_DATA | GRm_RESET | GRm_BACK_UP;


    /*
     *  loop until exit condition occurs
     */

   do
    {
        switch (me->action)
        {       
	 case NIL:			  /*| NILL */
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

               /*  Put the accept event in the input queue if required */

		if((me->grevent.response != SPECIFIED_OBJ) && me->reput[0])
		   status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));
		/* store additionnal information if necessary */
                if(me->mytype == DBT_LINE) 
		  {
		   me->snap[0] = me->grevent.event.button.x;
		   me->snap[1] = me->grevent.event.button.y;
		   me->snap[2] = me->grevent.event.button.z;
		  }

         case LOC_2:                      /*| LOC_2 */
		if(me->num_locate == 1)
		 {
		  me->action = CREATE;
		  entry_requested = NOENT;
		 }
		else
		 {
		  iloc = 1;
		  entry_requested = PARENT;
                 }
                break;

	 case STO_2 :                      /*| STO_2 */

               /*  Put the accept event in the input queue if required */

		if((me->grevent.response != SPECIFIED_OBJ) && me->reput[1])
		   status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));
         case LOC_3 :			  /*| LOC_3 */                      
		if(me->num_locate == 2)
		 {
		  me->action = CREATE;
		  entry_requested = NOENT;
		 }
		else
		 {
		  iloc = 2;
		  entry_requested = PARENT;
		 }
                break;

	 case STO_3 :                      /*| STO_3 */
               /*  Put the accept event in the input queue if required */

		if((me->grevent.response != SPECIFIED_OBJ) && me->reput[2])
		   status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));


	case CREATE  :                      /*| CREATE */


 /* Is there something specific to do before construction of this object */

  if(me->mytype & WIND_GEN || me->mytype & PROJ_SNAP)
    {
     status = om$send (msg      = message IGEgragad.DPinrot(&msg,view_rot),
                    targetid = grevent2.event.button.objid,
                    targetos = grevent2.event.button.osnum);

     /*^ pr_mat("view",4,4,view_rot); */
    }

  if(me->mytype & PROJ_SNAP)
    {
     boreline.point1 = &grevent2.event.button.x;
     boreline.point2 = dummy_pt1;
     dummy_pt1[0] = boreline.point1[0] + 100*view_rot[8];
     dummy_pt1[1] = boreline.point1[1] + 100*view_rot[9];
     dummy_pt1[2] = boreline.point1[2] + 100*view_rot[10];

     status = om$send(msg = message GRgraphics.GRlnproject(&msg,
                                  &me->env_info[0].md_env.matrix_type,
                                  me->env_info[0].md_env.matrix,
                                  &boreline,snap_point,dummy_pt,&dummy_par,
                                  &parms),
                      targetid = me->list_id[0].objid,
                      targetos = me->list_id[0].osnum);
     as$status(action = RET_STATUS);
     /*^
	pr_point("from",&grevent2.event.button.x);
	pr_point("to",snap_point);
	pr_point("dummy",dummy_pt);
     */

    }
  else
    {
     v_equal(&grevent2.event.button.x,snap_point);
    }



  compute_type = me->mytype;

  switch( me->mytype)
	  {
	  default :
		v_equal(snap_point,me->snap);
		break;

	   case DBT_LINE :
		me->snap[3] = me->grevent.event.button.x;
		me->snap[4] = me->grevent.event.button.y;
		me->snap[5] = me->grevent.event.button.z;

		/*
		   Is it a dbt_line or a segment by 2 points, and order the
		   obj_id to have the circle first
		*/

		if((me->obt_type[0] & point_generic) &&
		   (me->obt_type[1] & point_generic))
		  {
		   /*|create by2ptseg */
		   me->as_classid = OPP_ASby2ptsg_class_id;
		  }
		else if(me->obt_type[0] &conic_generic)
		  {
		   /*| create dbt line, first is circle */
		   me->as_classid = OPP_ASlinedbt_class_id;
		  }
		else
		  {
		   /*| create dbt line, first is point */
		   me->as_classid = OPP_ASlinedbt_class_id;
		   tmp_grid = me->list_id[1];
		   me->list_id[1] = me->list_id[0];
		   me->list_id[0] = tmp_grid;

		   tmp_grid = me->context[1];
		   me->context[1] = me->context[0];
 		   me->context[0] = tmp_grid;

		   me->snap[3] = me->snap[0];
		   me->snap[4] = me->snap[1];
		   me->snap[5] = me->snap[2];
		   me->snap[0] = me->grevent.event.button.x;
		   me->snap[1] = me->grevent.event.button.y;
		   me->snap[2] = me->grevent.event.button.z;
		  }
	       break;

	   case KEY_POINT :
	   case KEY_EVENT :
                if(!(me->obt_type[0]&lbs_generic))
		  {
		   v_equal(snap_point,me->snap);
   		   me->as_classid  = OPP_ASkeypt_class_id;
		  }
		else
		  {
		   /*| point at keypoint on text */
		   compute_type = MID_TEXT;
   		   me->as_classid  = OPP_ASboxpt_class_id;
	 	   as$any_give_structure(go_grid = me->list_id[0],
					 mod_env = &me->env_info[0],
					 inst = &ret_struct);

		   /* find solution nearest from accept point */
		   dmin = 1.e+32;
		   for(xbar[0] = 0.; xbar[0]<1.5 ; xbar[0]++)
		   { for(xbar[1] = 0.; xbar[1]<1.5 ; xbar[1]++)
			{ /*"xbar %lf %lf\n",xbar[0],xbar[1] */
			  ASbox_pt_eval(&ret_struct,xbar,dummy_pt);
			  /*^ pr_point("res",dummy_pt); */
			  v_sub(dummy_pt,snap_point,dummy_pt);
			  dummy_par = v_len(dummy_pt);
			  if(dummy_par<dmin)
			   {me->snap[0]= xbar[0];me->snap[1]=xbar[1];
			    dmin = dummy_par;
			   }
			}
		   }
			
		     /*^ pr_point("res",me->snap); */
		    }

	        break;

	   case MID_POINT : 
	   case MID_EVENT : 
                if(!(me->obt_type[0]&lbs_generic))
		  {
    		   me->snap[0] = 2.e+10;
  		   me->as_classid  = OPP_ASindexpt_class_id;

        	   status = om$send(msg=message GRcurve.GRmidpoint(&msg,
                                            &me->env_info[0].md_env.matrix_type,
                                             me->env_info[0].md_env.matrix,
                                             &parms, &me->snap[1]),
                      		      targetid = me->list_id[0].objid,
                      		      targetos = me->list_id[0].osnum);
		   as$status(action = RET_STATUS);
  	          }
		else
		  {
		   /*| point at middle on text */
		   compute_type = MID_TEXT;
   		   me->as_classid  = OPP_ASboxpt_class_id;
	 	   as$any_give_structure(go_grid = me->list_id[0],
					 mod_env = &me->env_info[0],
					 inst = &ret_struct);

		   /* find solution nearest from accept point */
		   dmin = 1.e+32;
		   xbar[1] = 0.5;
		   for(xbar[0] = 0.; xbar[0]<1.5 ; xbar[0]++)
			{ /*"xbar %lf %lf\n",xbar[0],xbar[1] */
			 ASbox_pt_eval(&ret_struct,xbar,dummy_pt);
			 /*^ pr_point("res",dummy_pt); */
			 v_sub(dummy_pt,snap_point,dummy_pt);
			 dummy_par = v_len(dummy_pt);
			 /*"dmin %ld dummy_par %lf\n",dmin,dummy_par */
			 if(dummy_par<dmin)
			   {me->snap[0]= xbar[0];me->snap[1]=xbar[1];
			    dmin = dummy_par;
			   }
			}
			
		    xbar[0] = 0.5;
		    for(xbar[1] = 0.; xbar[1]<1.5 ; xbar[1]++)
			{ /*"xbar %lf %lf\n",xbar[0],xbar[1] */
			 ASbox_pt_eval(&ret_struct,xbar,dummy_pt);
			 /*^ pr_point("res",dummy_pt); */
			 v_sub(dummy_pt,snap_point,dummy_pt);
			 dummy_par = v_len(dummy_pt);
			 if(dummy_par<dmin)
			   {me->snap[0]= xbar[0];me->snap[1]=xbar[1];
			    dmin = dummy_par;
			   }
			}
		     /*^ pr_point("res",me->snap); */
		    }

        	break;

        case PROJ_POINT:
        case PROJ_EVENT:
        	me->snap[0] = 2.e+10;
	        v_equal(snap_point,&me->snap[1]);
        	break;



       case CENT_POINT : 
       case CENT_EVENT :
	     if(!(me->obt_type[0] & conic_generic))
	       {
		/*| curve ---> index point */
        	me->snap[0] = 2.e+10;
	        v_equal(snap_point,&me->snap[1]);

        	cnst_lis.properties =  0; /* no display nor locate */
        	asso_lis.num_parents = 1;
        	status = om$construct(osnum = me->ModuleInfo.md_id.osnum,
                              classid = OPP_ASindexpt_class_id,
                             p_objid = &me->list_id[1].objid,
                             msg = message GRgraphics.GRconstruct(&cnst_lis));
        	as$status(action = RET_STATUS);
        	me->list_id[1].osnum = me->ModuleInfo.md_id.osnum;

        	status = om$send(msg = message NDnode.NDchg_state
                                              (ND_SUP_ONLY , ND_SUP_ONLY),
                         targetid = me->list_id[1].objid,
                         targetos = me->list_id[1].osnum);
        	as$status(action = RET_STATUS);

        	cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        	me->context[1].objid = NULL_OBJID;
        	asso_lis.num_parents = 2;
	       }
	     else
	       { 
		asso_lis.num_parents = 1;
	       }
            break;


   	   case TANG_EVENT :
	       /* if during dimensioning connect tangent point to 
		  dimensioning plane */
		 {
		  struct GRid window_id,cs_id;
		
                  window_id.objid = grevent2.event.button.objid;
                  window_id.osnum = grevent2.event.button.osnum;

		  AScs_for_dim(window_id,&cs_id);
		  if(!IF_NULL_OBJID(cs_id.objid))
		    {
      /*" tangent point connected to dim plane %d %d",cs_id.objid,cs_id.osnum */
		     asso_lis.parents[asso_lis.num_parents] = cs_id;
		     asso_lis.context[asso_lis.num_parents].objid = NULL_OBJID;
        	     asso_lis.num_parents = me->num_locate+1;
		    }
		  else
		    {
		     asso_lis.num_parents = me->num_locate;
		    }
		 }
			


	   case TANG_POINT :

	        v_equal(snap_point,me->snap);
		v_equal( view_rot ,&me->snap[3]);
		v_equal(&view_rot[4],&me->snap[6]);
		break;


	   
	   case WIND_REF : 

        	AStrans_mat(view_rot,me->snap);
		break;
	 }

/* get active symbology and level */

    if(ASget_active_symb(&me->Active_level,&me->Active_display) 
       					!= OM_S_SUCCESS) return (OM_W_ABORT);
    cnst_lis.level = me->Active_level;           
    if(me->mytype & POINT_GEN) me->Active_display.weight += 3;


/* add track point */

    if(  (compute_type & TRACK_GEN) 
       &&(!IF_NULL_OBJID(G_active_trackpoint.objid))
       && ( 1 & om$is_objid_valid(objid = G_active_trackpoint.objid,
                                  osnum = G_active_trackpoint.osnum )))
      {
       me->list_id[me->num_locate] = G_active_trackpoint;
       me->context[me->num_locate].objid = NULL_OBJID;
       asso_lis.num_parents = me->num_locate + 1;
      }


/* modify momo le 6-Dec-1988                                                  */
/* verify that the roots of the objects are different                         */

    cmp_parent( &msg,
                &asso_lis.num_parents,
                asso_lis.parents,
                asso_lis.context );

    if( msg == OM_W_ABORT )
    {
      ex$message(msgnumb = AS_S_RtDif);
      me->state = INITIAL;
      me->action= LOC_1;
      entry_requested = NOENT;
      break;
    }
   /* end of modify */

    /*| construct the object */
    ConstructGrid.osnum = me->ModuleInfo.md_id.osnum;

    status = om$construct(osnum = ConstructGrid.osnum,
			  classid =  me->as_classid,
                          p_objid = &ConstructGrid.objid,
                          msg = message GRgraphics.GRconstruct( &cnst_lis));
    as$status(action = RET_STATUS);

   /*
    * Display object
    */

    status = om$send(msg = message GRgraphics.GRdisplay( &msg,
                            &me->ModuleInfo.md_env.matrix_type,
                            me->ModuleInfo.md_env.matrix,
                            &DisplayMode, &DisplayGrid),
                     targetid = ConstructGrid.objid,
		     targetos = ConstructGrid.osnum);
    as$status(action = RET_STATUS);

/*
   If event generator, change the state of the constructed object 
   and exit (event generator always produces points
*/
    if(me->mytype & EVENT_GEN)
       {
        IGRshort clear = 0;
        IGRshort props_to_clear = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

        status = om$send(msg = message NDnode.NDgive_structure
					(&msg,&ret_struct,&me->ModuleInfo),
                         targetid = ConstructGrid.objid,
                         targetos = ConstructGrid.osnum);
        as$status(action = RET_STATUS);
                          
        status = om$send(msg = message NDnode.NDchg_state
                                              (ND_SUP_ONLY , ND_SUP_ONLY),
                         targetid = ConstructGrid.objid,
                         targetos = ConstructGrid.osnum);
        as$status(action = RET_STATUS);

        status = om$send(msg = message GRgraphics.GRchgprops
                                                (&msg,&clear,&props_to_clear),
                         targetid = ConstructGrid.objid,
                         targetos = ConstructGrid.osnum);
        as$status(action = RET_STATUS);

        grevent2.event.button.x = ret_struct.var.point_st.pt[0];
        grevent2.event.button.y = ret_struct.var.point_st.pt[1];
        grevent2.event.button.z = ret_struct.var.point_st.pt[2];
        grevent2.num_id = 1;
        grevent2.located_object[0].located_obj.objid = ConstructGrid.objid;
        grevent2.located_object[0].located_obj.osnum = ConstructGrid.osnum;
        grevent2.located_object[0].module_info = me->ModuleInfo;
        grevent2.subtype = GRst_ASSOC_KEYPOINT;

        ex$putque(msg = &msg, response = &resp,
                  byte =  (IGRlong *)&size, buffer = (IGRchar *)&(grevent2.event));
        *response = TERMINATE;
        return(OM_S_SUCCESS);
       }


       /* prepare restart of the command */

       me->state =  me->restart_state;
       me->action = me->restart_action;
       entry_requested = NOENT;
       if(me->reput_locate > -1)
	 { me->list_id[0] = me->list_id[me->reput_locate];
	   me->context[0] = me->context[me->reput_locate];
	   me->env_info[0] = me->env_info[me->reput_locate];
	 }



   }   /* end switch (me->action) */


/*      definition of the parents */

   switch (entry_requested)
    {
     case PARENT :
     /*
       -en attendant de pouvoir passer directement le message number a
        get_parent
       - pouvoir definir egalement "eligible element" et "non eligible element"
     */

	ex$message( buff =  me->loc_prompt, msgnumb = me->loc[iloc]);
	ex$message( buff =  me->acc_prompt, msgnumb = me->acc[iloc]);
	ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);
        if(me->reput[iloc] > 0)
            display_flag = ELEM_HILIGHT | ALL_WINDOWS | LC_ACCEPT_CURSOR;
        else
            display_flag = ELEM_HILIGHT | ALL_WINDOWS;
	token = ASget_parent (&msg,TokenList, &me->grevent, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt, me->acc_prompt, 
                       me->reloc_prompt, &me->attr, &me->locate_stack,
                       me->req_type[iloc],&me->list_id[iloc],&me->context[iloc],
		       &ret_struct);
	if(TokenList[token] == LOC_PARENT)
        {
          me->obt_type[iloc] = ret_struct.type;
	  me->env_info[iloc] = me->grevent.located_object[0].module_info;
	  /*"matrix type 1: %d\n",me->grevent.located_object[0].module_info.md_env.matrix_type */
	}
	break;

     case NOENT :
        break;
    }

/* new action and new state */

	
   if(entry_requested != NOENT)
     {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state  = (IGRint) NewState[ me->state ][ token ];
     }

  /*"token %d new_action %d new_state %d\n",token,me->action,me->state*/


    }  while(entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    return( status);

}   /*  end execute method */

end implementation COparaloc;

