/* $Id: VRsketch.S,v 1.1.1.1 2001/01/04 21:13:10 cvs Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrsketch/VRsketch.S
 *
 * Description:
 *  This file contains the specification for the commands : 
		Piping  sketch : VRSkPipeLine,0,VRSkPp
 *	        HVAC    sketch : VRSkDuctLine,1,VRSkDcLn
 *		Raceway sketch : VRSkRaceway,2,VRSkRw
 *
 *  VRsketch.S ==> 
	this file contains the specification for the following methods :
 *
 *                    ==> init 
				   : is overridden to initialize the 
 *				     instance data particulary the product 
 *				     and locate filter eligible class.
 *                    ==> wakeup
 *                                 : is overridden to update sketch form gadgets
 *                    ==> delete
 *                                 : is overridden to terminate correctly the 
 *					current network.
 *                    ==> sleep
			 	   : is overridden to erase sketch form 
				    and undisplay construct point way 
 *				    if neccessary
 *                    ==> dynamics
 *                                 : is overridden to call funtion of 
 *					product the right dynamic function.
 *                    ==> form_notification
 *                                 : is overridden to ( gerer ) the sketch form.
 *		      ==> VRSkSetRetCode
 *                                 : set my_ret instance data
 *		 	==> VRSkFormBottonOff
 *                                 : set to off all sketch form gadgets
 *			==> VRSkPopupLocate
 *                                 : set to off sketch form locate gadget
 *			==> VRSkPopupSkewed
 *                                 : set to off sketch form skewed gadget
 * Dependencies:
 *
 * Log History:
 *	$Log: VRsketch.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/03/20  06:34:50  pinnacle
# Created: vrsketch/VRsketch.S by aharihar for route
#
 *
 *
 * History:
 *      Feb 2000	Anand   Split VRsketch.sl into .t, .S and .I
 *
 ***********************************************************************/


class specification VRsketch (1:0) of VRCmpMgr;

#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dpstruct.h"
#include "parametric.h"
#include "vdbmacros.h"
#include "VRstructs.h" 
#include "ACattrib.h"
#include "ACrg_collect.h"
/* Added for CR179308634 - Livelookup of parts from database */
#include "VRsketchdef.h"
#include "VRRwDimen.h"
#include "VRlivlkup.h"


instance VRsketch
{
				/*************************************/
				/* TO PLACE COMPONENT BY AABBCC CODE */
				/*************************************/

  IGRshort			CmpFunction;	/* component function 			     */
  IGRboolean			ChangePocket;	/* TRUE if EMS pocket menu has been swapped  */
  IGRchar 			*PocketMenuName;/* active pocket menu name    		     */
  IGRboolean			IS_CONNECTABLE; /* located  component is connectable	     */
  IGRshort			FirstCptNum;	/* cpt number of first located connectable   */
						/* component				     */
  IGRshort			SecondCptNum;  	/* cpt number of second located connectable  */
						/* component				     */
  IGRint			EvalCompTopo;	/* component evalauted topo		     */
  IGRvector			PrevSegAxis;	/* Last created segment direction            */
  IGRvector			Cmp_Yaxis;  	/* to create component y axis                */
  struct	GRid		ListIds[VR_NB_ATTR + VR_MAX_CPTS];
						/* list of component template		     */
  struct	VRGenInfo	CmpStr;     	/* generic structure of component	     */
  struct	ACrg_coll	*p_MissingParamsList;
					 	/* list of the missing parameters returned by*/
						/* the evaluate   			     */

				/************************/
  				/* SKEWED WITH AN ANGLE */  
				/************************/

  IGRboolean			AngleFlag; 	/* to know if an angle has been setted in    */
						/* Skewed mode				     */

				/********************/
	  			/* NEW SKETCH FORMS */
				/********************/

  IGRchar			*form_name;	/* sketch form name	 		     */
  Form				form_ptr;	/* sketch form pointer			     */
  IGRint			shape_gadget;   /* active shape gadget ( HVAC, CABLING )     */


				/********************/
				/* Needed Instances */
				/********************/

  IGRshort			SketchMode;	/* AUTOMATIQUE or MANUAL sketch mode         */
  struct	GRmd_env	FirstLocatedElemMdEnv;
						/* first located compoent module info	     */
  struct	GRmd_env	SecondLocatedElemMdEnv;
						/* second located compoent module info	     */
  IGRboolean			PlaceDangling; 	/* if TRUE the system place dangling at the 
						/* end of the line at the current line route */
  IGRshort			first_pt_free;  /* used for the fitting to fitting           */
  IGRshort			next_pt_free;   /* used for the fitting to fitting           */
  IGRshort			CmpPosition;	/* Positin of component to replace	     */
  IGRshort                      CmpOrientation[VR_MAX_CPTS];
                                          	/* to place component we need t know its     */
						/* orientation on each supports              */
  IGRint			FirstType;	/* first located component type needed to    */
						/* know the component to place instead of the*/
						/* located one                               */
  IGRint			CmpFirstType;   /* first located component type needed when  */
			                        /* user deletes all added segment to an      */
						/* existant line route to know the type of   */
						/* the starting component to replace it      */
  IGRint			SecondType;     /* second component type needed to know the  */
						/* component to place instead of the located */
						/* one.		          	             */
  IGRint			num_of_seg;     /* number of added segments                  */
  IGRint			my_state; 	/* my current state                          */
  IGRlong			my_ret;         /* my return code                            */
  IGRpoint			prev_pt;        /* previous user given point                 */
  IGRpoint			first_pt;       /* first user given point : is the start     */
						/* point of the next created segment         */
  IGRpoint			next_pt;        /* next user given point : is the end point  */
       						/* of the next created segment               */
  IGRint			NbOfImpDirection;
						/* number of imposed direction		     */
  IGRdouble			ImpDirForDyn[3*VR_MAX_CPTS];
					        /* used for dynamics to propose only valid   */
						/* direction to sketch from located component*/
  IGRdouble			CmpAngle; 	/* needed to place in line cmp    	     */
  IGRboolean    		twist_orient;   /* TRUE if the current width is twedted      */
  IGRboolean    		twist_save;     /* used to know if we need to place a twisted*/
						/* component				     */
  IGRboolean    		ZwindowFlag;    /* if TRUE we need to get the Z window axis  */
						/* to calcul the next point 	 	     */
  IGRdouble			Z_Window[3];    /* Z window axis given by the dynamic funtion*/
  IGRdouble			section_matrix[9];
				          	/* section orientation matrix     	     */
                                          	/* X --> [0..2]; Y --> [3..5];    	     */
                                          	/* Z --> [6..8];                  	     */
  IGRboolean			orthogonal_sketch;
                                          	/* TRUE if sketch is orthogonal   	     */
  IGRboolean			LocateMode;	/* TRUE if user is locating a component 	     */

  IGRboolean			extend;   	/* to know if the user given next point      */
						/* corresponds to an extend or not of the    */
						/* last created segment			     */
  IGRboolean			act_param_change;
                                          	/* if TRUE user has changed the active       */
						/* parameters befor given the next point     */
  variable 	struct GRid	seg_GRid[MAX_SEG];
                                                /* list of all added segment on the current  */
						/* line					     */
  struct 	GRid		plane_to_move_id;
                                           	/* plan to move if is an extend              */
  struct 	GRid		prev_seg_id;    /* last created segment                      */
  struct	GRid		FirstLocatedElemId; 
                                          	/* first located component id     	     */
  struct	GRid		SecondLocatedElemId; 
                                          	/* second located component id    	     */
  struct 	GRid		ElbowSecSegId;  /* needed when we located an elbow to start  */
  struct 	GRas		assoc_list;     /* assoc construction list 		     */
  struct 	GRvg_construct	const_list;     /* segment graphic construction list 	     */
  struct 	GRvg_construct	cmp_const_list; /* component graphic construction list	     */
  struct	GRsymbology	LineSymbology;  /* current symbology for created segments    */
  struct	GRid		ActParamId;	/* active system collection parameters       */
						/* identifier				     */
  struct	GRid		BufParamId;     /* last collection paramters identifier befor*/
						/* user given the next point 		     */

				/********************************/
				/* CONSTRUCTION POINT GENERATOR */ 
				/********************************/

  IGRdouble 			cst_pts[12];	/* all proposed way points                   */
  IGRdouble			way_cst_pts[9]; /* all proposed way points without the first */
						/* segment                                   */
  struct 	IGRdisplay    	cst_display;    /* display attributes of all proposed line   */
  struct 	IGRdisplay	way_cst_display;/* display attributes of all proposed line   */
						/* without the first segment		     */
  struct 	IGRpolyline    	cst_poly;	/* geometry of all the proposed line         */
  struct 	IGRpolyline    	way_cst_poly;   /* geometry of all the proposed line without */
						/* the first segment                         */
  struct 	DPele_header	cst_buffer;	/* header element needed to display on       */
						/* dynamic all the proposed line             */
  struct 	DPele_header	way_cst_buffer; /* header element needed to display on       */
						/* dynamic all the proposed line without the */
						/* first segment			     */
				/************************/
  				/* ID MANAGEMENT	*/  
				/************************/
  IGRint	PrevLineNum;	/* previous line seq num */
  IGRboolean	bLineNumUsed;	/* whether the prev line seq num is used
				   or not				*/

  IGRboolean    bI_Need_Pick;   /* Locate of destination gives problems
                                   when either directly after inserting
                                   a component, or locating the origin
                                   component. Need at least one set of
                                   coordinates in between 

                                   Safest way is to keep track of this
                                   situation and block the locate
                                   button when necessary. 

                                      TR # 179600603                   */
  /* Next four added for CR179308634 - Livelookup of parts in db */
  IGRboolean	first_entry;   	/* first entry flag for livelookup     */
  IGRboolean	new_live;	/* new form for livelookup	       */
  IGRboolean    proc_livelook;
  union VRlivoutbuff OB;
  /* Next was added for CR179801061-save width/depth for shape changes */
  IGRdouble width_sav;
  IGRdouble depth_sav;
  /* Next are dynamic depth additions-CR179900491 */
  IGRint active_cpt;
  struct VRRwCptDetails RWcptdata[10];

  /* added by alwin for handling 'shape transition components'. Currently used
  only for Raceways. If the bIsShapeTransition is set to TRUE, it means
  we should use the "nShapeCode" as the shape_code value, irrespective of what
  is displayed in the form. */

  IGRboolean    bIsShapeTransition;
  IGRint        nShapeCode;

};


message VRskformon ( long * sts );

message VRskformoff ( long * sts );

override init;

override wakeup;

override delete;

override sleep;

message VRSkFormBottonOff ( long * sts );

message VRSkPopupLocate ( long * sts );

message VRSkPopupSkewed ( long * sts );

override dynamics;

message VRSkSetRetCode ( IGRshort type );

override status_disp;

message VRskupdate_form ( long * sts );

message VRSkEraseMissingForm ( long * sts );

message VRSwapSketchForm ( IGRshort Mode );

override form_notification;

override initial_form_notification;

message VRSkUnLockId ( IGRshort	Mode );

message VRIsPrevSegSkewed ( IGRlong *sts );

message VRskdelangle ( IGRlong *sts  				);

message VRskgetangle ( IGRlong *sts 					);

message VRSkGetEvent ( IGRlong *sts 					);

message VRSkGetLocateState ( IGRlong *sts 					);

message VRskmerge ( IGRlong *sts 					);

message VRskinit_buffer ( int * sts 					);

message VRskinit ( IGRlong *sts 					);

message VRskfstpt ( IGRlong *sts  				);

message VRsknextpt ( IGRlong *sts 					);

message VRskcrseg ( IGRlong *sts 					);

message VRskendline ( IGRlong *sts					);

message VRSkEndLineRoute ( IGRlong *sts					);

message VRSkPlaceEndDangling ( IGRlong *sts					);

message VRskdelseg ( IGRlong *sts 					);

message VRskdelta ( IGRlong *sts 					);

message VRskgetnxtpt ( IGRlong *sts 					);

message VRskget_valid_sol ( IGRlong *sts 					);

message VRskend_valid_sol ( IGRlong *sts 					);

message VRskdisp_all_way ( IGRlong *sts 					);

message VRskfstchoice ( IGRlong *sts 					);

message VRsknextchoice ( IGRlong *sts 					);

message VRskcstpt ( IGRlong *sts 					);

message VRskcstsol ( IGRlong *sts 					);

message VRskfstelm ( IGRlong *sts 					);

message VRskupdate_event ( IGRlong *sts 					);

message VRskconnect ( IGRlong *sts 					);

message VRSkGetElbowPrevSeg ( IGRlong 		*sts;
			     	  struct	GRid	*LocatedElbowId;
                                  struct	GRid	*ElbowPriSegId;
                                  struct	GRid	*ElbowSecSegId 		);

message VRSkGetElbowInfo ( IGRlong *sts 					);

message VRSkInitInstance ( IGRlong *sts 					);

message VRSKEraseHvacTee ( IGRlong *sts 					);

message VRSkSwitchFormParams ( IGRlong *sts 					);

message VRSkDisplayOrientTee ( IGRlong *sts 					);

message VRSkEraseStatusForm ( IGRlong *sts 					);

message VRSkPopupStatusField ( IGRlong *sts 					);

message VRSkGetCmpCode ( IGRlong *sts 					);

message VRSkActiveEmsPocket ( IGRlong *sts 					);

message VRGetReturnCode ( IGRlong *sts 					);

message VRPlaceCmp ( IGRlong *sts 					);

message VRSkUpdateNetWork ( IGRlong *sts 					);

message VRskrestart ( IGRlong *sts 					);

message VRSkGetCptInfo ( IGRlong *sts 					);

message VRSkInitCmpOrient ( IGRlong *sts 					);

message VRSkPartialInitInst ( IGRlong *sts 					);

message VRDeleteGraphics ( IGRlong *sts 					);

message VRSkSetCmpInstance ( IGRlong *sts 					);

end specification VRsketch;
