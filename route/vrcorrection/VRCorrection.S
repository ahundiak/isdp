/******************************************************************************
/*
/*	Author	:	momo
/*
/*	Creation:	November 19th, 1990
/*
/*      CLASS  NAME: The abstract class VRCorrection defines instance and 
/*                   methods required for correct behaviour of the Piping,
/*                   HVAC and Cabling correction entity.   
/*                                     
/*      
/*      SUBCLASS OF: ASnode
/*
/*      NOTES: : The aim of the correction entity is to adapte two components
/*               next to each other. As attributes of component can be changed
/*               the correction entity must be able to maintain pipe line
/*               coherency so naturaly correction entity must be an associative
/*               object depanding upon components that it adaptes.
/*               To adapte components correction entity places and owns 
/*               correction components ( reducer, flange in piping or reducer,
/*               transition in HVAC and Cabling ) and pipe.
/*               Correction entity can be consider as a complex node who 
/*               manages more than one component ( foot ).
/*                
/*		
/*	Change History :
/*
/*
/*		  date	|  name	|	modification's description
/*		--------+-------+-----------------------------------
/*		Feb 1997   KDD		GRgetattr
/*		05 APR 94 Manyam	Modified the definition of
/*					method "VRNotifyDelete"
/*		21 NOV 94 Lori  	Added method VRVerCorrTopology
/*
/******************************************************************************/

class specification VRCorrection (1:0) of IGRdir, ASnode;

#include "VRcordef.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRhvacstr.h"
#include "VRpipestr.h"


instance VRCorrection
{
  IGRdouble	my_length[2];    /* TO BE REMOVED */
 
  variable struct VR_CorCmpStr my_StrCmpList[1];
                                 /* Table getting all components information  */
				 /* SOME OF THIS PARAMETERS ARE TO BE REMOVED */
				 /* SEE VRcordef.h			      */

  IGRint	my_state;         /* variable can be set to : VR_COR_DEL,..   */

  IGRint 	my_NbCorCmp;      /* number of my components                  */

  IGRshort 	my_CmpCptIndex[my_nbParent];
                                  /* nb of connect point of each parent       */

  IGRshort 	Fitting_to_Fitting; /* TO BE REMOVED */

  IGRboolean	UpdateCmpCptIndex;  /* TO BE REMOVED */

  IGRboolean	UpdatePipeDim;      /* TO BE REMOVED */

  IGRshort	FlowDirection;   /* Flow direction                            */

  IGRdouble	FlowValue;	 /* Flow Value                                */
                  
};


/* The following messages are overriden to perform an operation specific to   */
/* the VRcorrection class                                                     */


override

  GRgetattr,			/* KDD VRCorrInfo.I */ 
  GRputattr,			/* KDD VRCorrInfo.I */ 

  GRdelete,                     /* GRgraphics - correction entity can not be  */
                                /*              deleted directly by the user  */
  GRget_locate_properties,      /* GRowner    - override to allow locate of   */
                                /*              any of the component of the   */
                                /*              correction entity             */
  NDmove_to_root,               /* NDnode     - override to change connexion  */
                                /*              or to delete my self          */
  NDplace,      		/* NDnode     - place correction              */
  NDcompute_node,		/* NDnode     - update correction             */
  NDcopy,                       /* NDnode     - override to copy correction   */
  NDdelete,                     /* NDnode     - override to set correction    */
                                /*              components state              */
  NDdisconnect,			/* NDnode     - I delete myself if I am discon*/
				/*              nected form my last parent    */
  NDmake_source,                /* NDnode     - override to have complex node */
                                /*              behaviour                     */
  ASpossible_parent,            /* ASnode     - to hsve a good behavior       */
  ASconstruct_go,		/* ASnode     - construct a component         */
  ACreturn_foot,                /* NDmacro    - override to have complex node */
                                /*              behaviour                     */
  ACgive_path,			/* ASnode     - get name of a component       */
  GRget_siblings;		/* GRowner    - to return its components      */
				/*              templates and the olets if    */
				/*              any to avoid the interference */
				/*              detection with them.	      */


message VREvaluate( IGRlong			*msg;
                    IGRint			count;
                    struct 	GRid		*list;
   		    struct 	GRmd_env	*md_env;
                    union	VRparam_attr	*PipeParams;
                    union	VRparam_attr	*Father0Params;
                    union	VRparam_attr	*Father1Params;
		    struct	VRPlaceStr	*PlaceStr );

/*---------------------------------------------------------------------------
/*
/* Evaluate the Correction entity
/*
/*      Argument description :
/*      --------------------
/*
/* 	I/O IGRlong		     *msg;		return code
/*      I/   IGRint		     count;		my parents' number
/*      I/  struct 	GRid	     *list;		my parents' list
/*      I/  struct 	GRmd_env     *md_env;		the module info
/*      I/O union	VRparam_attr *PipeParams;    	pipe params
/*      I/O union	VRparam_attr *Father0Params;    father0 params
/*      I/O union	VRparam_attr *Father1Params;    father1 params
/*
/*---------------------------------------------------------------------------*/

message VRGetCorCmpId( IGRlong 			*msg;
		       IGRchar			*CorCmpName;
		       IGRshort			RealPos;
	 	       IGRint		        ChanPos;
                       IGRint			*RetChanPos;
                       struct	GRid		*CorCmpId    );

/*---------------------------------------------------------------------------
/*
/* Abstract : given a correction component name or its real position in
/*            my StrCorCmpList or its index on the owner channel, I return its
/*            GRid.
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      return code
/*    I/   *CorCmpName	   IGRchar      correction component name
/*    I/   RealPos         IGRshort     correction component real position
/*    I/   ChanPos         IGRint      correction component owner channel index
/*    O/   RetChanPos      IGRint	ChanPos if asked for
/*    O/   *CorCmpId	   GRid	        correction cmp to calcul length
/*
/*---------------------------------------------------------------------------*/

message VRGetCorCmpLength( IGRlong 			*msg;
                           struct	GRid		*CorCmpId;
                           struct	GRmd_env	*md_env;
			   IGRdouble			*CorCmpLength  );

/*---------------------------------------------------------------------------
/*
/* Abstract : given a correction component Id or name or real position in
/*            my StrcorCmpList or owner channel index, I return its length
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong	     return code
/*    I/   *CorCmpId		GRid	     correction cmp to calcul length
/*    O/   *CorCmpLength	IGRdouble    correction component length
/*
/*---------------------------------------------------------------------------*/

message VRGetMatrix( IGRlong 			*msg;
                     struct	GRid		*CorCmpId;
                     IGRdouble			*CorCmpMatrix;
                     struct	GRmd_env	*md_env );

/*---------------------------------------------------------------------------
/*
/* Abstract : Adapte two connect points
/*
/* Arguments
/*   input :
/*      *msg            IGRlong		  return code
/*      *CorCmpId	GRid		  correction cmp to calcul length
/*      *CorCmpMatrix	IGRdouble	  correction component matrix
/*      *md_env		GRmd_env	  module env.
/*
/*---------------------------------------------------------------------------*/


message VRGetPipeCpts( IGRlong 				*msg;
                       struct		GRmd_env	*md_env;
                       IGRdouble			*PipeCptsCoord );

/*---------------------------------------------------------------------------
/*
/* Abstract : Adapte two connect points
/*
/* Arguments
/*   input :
/*      *msg            IGRlong		  return code
/*      *PipeCptsCoord	IGRdouble	  pipe cpts coord.
/*
/*---------------------------------------------------------------------------*/


message VRNotifyDelete(
	IGRlong			*msg;
	IGRint			NbParents;
	struct	GRid		*ParentIds );

/*---------------------------------------------------------------------------
/*
/* Abstract : notify correction that one or all of its parents will 
/* be deleted
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    NbParents	   	IGRint	  number of my parents
/*    I    *ParentIds	   	GRid	  parents GRid
/*
/*---------------------------------------------------------------------------*/


message VRGetCptsInfo( IGRlong			*msg;
                       IGRint			NbParent;
                       struct	GRid		*MyParentId;
                       struct 	GRmd_env 	*md_env;
                       IGRshort			*NbVia;
                       IGRshort			*Cmp0CptIndex;
                       IGRshort			*Cmp1CptIndex;
                       IGRdouble		*Cpt0Coord;
                       IGRdouble		*Cpt1Coord;
                       IGRlong			*HaveToCorrectCmp0;
                       IGRlong			*HaveToCorrectCmp1;
 		       struct	VRcp_attr	*ConProp0;
		       struct	VRcp_attr	*ConProp1  );


/*---------------------------------------------------------------------------
/*
/* Abstract : get my parents cpts to Adapte index
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    NbParent	   	IGRint	  number of my parents
/*    I    *MyParentId	   	GRid	  my parents GRid
/*    I    *md_env	   	GRmd_env  module env.
/*    O    *NbVia		number of olets
/*    O    *Cmp0CptIndex	Cmp0 cpt Index
/*    O    *Cmp1CptIndex	Cmp1 cpt Index
/*    O    *Cpt0Coord		Coord. of cpt0
/*    O    *Cpt1Coord		Coord. of cpt1
/*    O    *HaveToCorrectCmp0	IGRlong	  MSSUCC if I have to adapte cmp0
/*    O    *HaveToCorrectCmp1	IGRlong	  MSSUCC if I have to adapte cmp1
/*    O    *ConProp0		VRcp_attr cpt0 attributs
/*    O    *ConProp1		VRcp_attr cpt1 attributs
/*
/*---------------------------------------------------------------------------*/

message VRGetDynCpts( IGRlong			*msg;
                      struct	GRid		*CmpId;
                      IGRshort			*NbCpts;
                      struct 	GRmd_env 	*md_env );

/*---------------------------------------------------------------------------
/*
/* Abstract : given component or correction component return its neighbor
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    *CmpId		GRid	  component GRid to get cpts
/*    O    *NbCpts		IGRshort  number of dynamic cpts
/*    I    *md_env	   	GRmd_env  module env.
/*
/*---------------------------------------------------------------------------*/

message VRGetNeighbor( IGRlong			*msg;
                        struct	GRid		*FatherId;
                        IGRint			CorCmpChanPos;
                        IGRshort		CmpCptIndex;
                        struct 	GRmd_env 	*md_env;
                        struct	GRid		*CmpNeighborId;
                        IGRshort		*CmpNeighborCptIndex );

/*---------------------------------------------------------------------------
/*
/* Abstract : given component or correction component return its neighbor
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    *FatherId		GRid	  my parents GRid
/*    I    *CorCmpChanPos	IGRint  Cmp to Get Neighbor ChanPos
/*    I    CmpCptIndex		IGRshort  Cpt Index of CmpToGetNeighbor
/*    I    *md_env	   	GRmd_env  module env.
/*    O    *CmpNeighborId	GRid	  The neighbor GRid
/*    O    *CmpNeighborCptIndex IGRshort  CmpNeighbor cpt Index
/*
/*---------------------------------------------------------------------------*/

message VRGetCmpNeighbor( IGRlong			*msg;
                          struct		GRid	*CmpToGetNeighborId;
                          IGRint			IndexFrom;
                          IGRint			IndexTo;
                          IGRshort			*NbNeighbor;
                          struct		GRid	*CmpNeighborId;
                          IGRshort			*CmpNeighborCptIndex;
                          struct 	GRmd_env 	*md_env );

/*---------------------------------------------------------------------------
/*
/* Abstract : given component or correction component return its neighbor
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    *CmpToGetNeighbor	GRid	  my parents GRid
/*    I    IndexFrom		IGRshort  neighbors given from IndexFrom
/*    I    IndexTo		IGRshort  neighbors given to IndexTo
/*    O    *NbNeighbor		IGRshort  number of neighbors
/*    O    *CmpNeighbor		GRid	  The neighbor GRid
/*    O    *CmpNeighborCptIndex IGRshort  CmpNeighbor cpt Index
/*    I    *md_env	   	GRmd_env  module env.
/*
/*---------------------------------------------------------------------------*/

message VRGetCptIndex( IGRlong		*msg;
                       struct	GRid	*MyParentId;
                       IGRshort		*MyParentCptIndex );

/*---------------------------------------------------------------------------
/*
/* Abstract : given component GRid, I return its Cpt index that I adapt
/*
/* Arguments
/*   input :
/*    I/O  *msg            	IGRlong   return code
/*    I    *MyParentId	   	GRid	  my parents GRid
/*    O    *MyParentCptIndex	IGRshort	my parent cpt index
/*
/*---------------------------------------------------------------------------*/

message VRget_state( IGRint *state );

/*---------------------------------------------------------------------------
/*
/* Abstract : return correction state.
/*
/* Arguments
/*   input :
/*    O    *state	IGRint my state
/*
/*---------------------------------------------------------------------------*/

message VRchg_state( IGRint mask, n_state );

/******************************************************************************/
/*
/* Abstract : this message is used to change the state of the target element :
/*            me->state = (me->state & ~mask) | nstate;
/*
/*****************************************************************************/

message VRChgCorInstance( IGRlong	*msg;
                          IGRshort	*FittingToFitting;
                          IGRshort	*MyFirstParentCptIndex;
                          IGRshort	*MySecondParentCptIndex );

/*---------------------------------------------------------------------------
/*
/* Abstract : set new correction instance data
/*
/* Arguments
/*   input :
/*    I/O  *msg            		IGRlong   return code
/*    I    *FittingToFitting    	IGRshort  fitting to fitting flag
/*    I    *MyFirstParentCptIndex	IGRshort  my parent cpt index
/*    I    *MySecondParentCptIndex	IGRshort  my parent cpt index
/*
/*---------------------------------------------------------------------------*/

message VRUpdateConnection( IGRlong		 *msg;
                            struct	GRid	 *CmpToAskForNextParentId;
                            IGRshort		 CmpToAskForNextParentIndex;
                            struct	GRmd_env *md_env );

/*---------------------------------------------------------------------------
/*
/* Abstract : update correction entity connection befor compute
/*
/* Arguments
/*   input :
/*    I/O  *msg            	      IGRlong   return code
/*    I/   *CmpToAskForNextParentId   GRid      my parent to ask for my 
/*                                              next father
/*    I/   CmpToAskForNextParentIndex IGRshort  Cpt index
/*    I/   *md_env		      GRmd_env  modeule_env
/*
/*---------------------------------------------------------------------------*/

message VRNotifyModif( IGRlong	*msg );

/*---------------------------------------------------------------------------
/*
/* Abstract : set my UpdateInstance flag
/*
/* Arguments
/*   input :
/*    I/O  *msg            	      IGRlong   return code
/*
/*---------------------------------------------------------------------------*/

message VRGetCorCmpPretendId( IGRlong		*msg;
                              IGRchar         	*CorCmpName;
                              struct	GRid	*CorCmpPretendId );


/*---------------------------------------------------------------------------
/*
/* Abstract : delete correction component given by Id,name, real position
/*            in my StrcorCmpList or owner channel index.
/*
/* Arguments
/*   input :
/*    I/O  *msg             IGRlong	  	return code
/*    I/   *CorCmpname      IGRchar   		correction component name
/*    O/   *CorCmpPretendId struct GRid		correction component pretend
/*
/*---------------------------------------------------------------------------*/


message VRGetCorLength( IGRshort 			Type;
                        struct		GRmd_env	*md_env;
			IGRdouble 			*MyLength );

/*---------------------------------------------------------------------------
/*
/* Abstract : get my length
/*
/* Arguments
/*   input :
/*    I/   type		IGRshort	0 : My all Length;
/*                                      1 : my length without my pipe;
/*                                      2 : only my pipe length
/*    I/   *md_env	GRmd_env  	modeule_env
/*    O/   *MyLength	IGRdouble	my length
/*
/*---------------------------------------------------------------------------*/

message VRMergeCorrection( IGRlong			*msg;
		           struct	GRid		*OldCmpId;
    		           struct	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract : method called to merge a correction
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    I/   *OldCmpId       struct GRid		component to change
/*    I/   *md_env	   struct GRmd_env	module env.
/*
/******************************************************************************/


message VRSplit( IGRlong			*msg;
                 struct	GRid		*CmpId;
                 IGRshort			MyType;
                 IGRshort			CopyType;
                 struct	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract : method called to split a correction
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    I/   CmpId	   struct GRid		needed to update connection
/*    I/   MyType	   IGRshort		TRUE, FALSE, -1 ( nothing to do )
/*    I/   CopyType	   IGRshort		TRUE, FALSE, -1 ( nothing to do )
/*    I/   *md_env	   struct GRmd_env	module env.
/*
/******************************************************************************/


message VRGetPipeId( IGRlong		*msg;
                     struct	GRid	*PipeId );

/******************************************************************************/
/*
/* Abstract : method called correction pipe
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      return code
/*    O/   *PipeId	   struct GRid	my pipe GRid
/*
/******************************************************************************/


message VRGetCorLenByCmp( IGRlong			*msg; 
                          struct 	GRid		*CmpId;
                          struct 	GRmd_env	*md_env;
  		          IGRdouble 			*Length );

/******************************************************************************/
/*
/* Abstract : method called to get correction component length on a segment
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    I/   *CmpId	   struct GRid		my component GRid
/*    I/   *md_env	   struct GRmd_env	my module nev
/*    O/   *Length	   			my length
/*
/******************************************************************************/

message VRGetMyCmp( IGRlong			*msg;
                    struct	GRid		*CorCmpId;
                    struct 	GRid		*CmpId;
                    struct 	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract : get component of a given correction component
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    I/   *CorCmpId	   struct GRid		my component GRid
/*    O/   *CmpId	   struct GRid		component GRid ==> my parent
/*    I/   *md_env	   struct GRmd_env	my module nev
/*
/******************************************************************************/

message VRGetFlow( IGRlong			*msg;
		   IGRdouble			*FlowDir;
                   IGRdouble			*FlowValue;
                   struct 	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract : get component of a given correction component
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    O/   *FlowDir	   IGRdoube		Flow direction
/*    O/   *FlowValue	   IGRdoube		Flow Value
/*    I/   *md_env	   struct GRmd_env	my module nev
/*
/******************************************************************************/

message VRGetMyDirection( IGRlong			*msg;
			  IGRdouble			*MyDirection;
                          struct 	GRmd_env	*md_env   );

/******************************************************************************/
/*
/* Abstract : get component of a given correction component
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    O/   *MyDirection	   IGRdoube		normalize my direction vector
/*    I/   *md_env	   struct GRmd_env	my module nev
/*
/******************************************************************************/


message VRSetFlow( IGRlong			*msg;
                   IGRdouble			*FlowDir;
                   IGRdouble			*FlowValue;
                   struct 	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract : get component of a given correction component
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong      	return code
/*    I/   *FlowDir	   IGRdoube		normalize Flow direction vector
/*    I/   *md_env	   struct GRmd_env	my module nev
/*
/******************************************************************************/

message VRPropagateFlow(IGRlong         	*msg;
			struct GRid		*FirstCorr;
                        IGRshort        	*FlowDirection;
			IGRdouble		*FlowRate;
                        IGRshort        	*PropagatePoint;
                        struct GRid     	*PropagateParent;
			struct GRmd_env		*md_env);
/******************************************************************************
*
* Abstract : Propagates flow direction from VRCorrection objects. 
*
* Arguments:
*
* O: IGRlong		*msg		return code
*
* I: struct GRid        *FirstCorr      first correction in the infinite loop.
*					May be NULL, then will assume my_id.
*
* I: IGRshort        	*FlowDirection	flow direction to propagate 
*				The flow direction now (June 97) is defined from
*				zeroth parent of the correction:
*				flow_dir vector=(Coord_Par_1 - Coord_Par_0).
*
* I: IGRdouble		*FlowRate	flow rate at this point (NULL, OK). 
*					(Algorithm not implemented). 
*
* I: IGRshort		*PropagatePoint	  connect point to propagate from. 
*
* I: struct GRid	*PropagateParent  parent to propagate from (NULL, OK). 
*	
* I: struct GRmd_env  	*md_env  	  Pointer to the module environment.
*-------------------------------------------
*
* Note: Whatever the PropagatePoint, remeber that the flow direction is defined
*	 as a vector from ConPt_0 to ConPt_1 (or Parent_0 to Parent_1).
*
* Note: Either PropagateParent or PropagatePoint can be specified. 
*	 If both are given, they must be consistent. 
*	 If only one is given, I will find the other one.
*
******************************************************************************/

message VRShowInstance();
                      
/*---------------------------------------------------------------------------
/*
/* Abstract : Print Instance data
/*
/*---------------------------------------------------------------------------*/

message VRGetHangers( IGRlong *msg; struct GRid *CmpId; IGRint ArraySize; 
                      struct GRid HangerIds[]; IGRint *NbHangers; IGRdouble *dCpCoors; 
		      struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRGetHangers
/*
/*      Returns the list of hanger objects connected to the component.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*CmpId		I : Component Id
/*
/* IGRint		*ArraySize	I : Size of the HangerIds array.
/*
/* struct GRid		HangerIds[]	O : Array of Hanger objects
/*					    ( can be specified as NULL )
/* IGRint		*NbHangers	O : number of found hanger objects
/*
/* IGRdouble		*dCpCoors	O : Hangers' connection coordinates.
/*					    This buffer must be sized at 
/*					    (ArraySize*3).
/* struct GRmd_env	*md_env		I : pointer to object's module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRCreate( IGRlong *msg; IGRint OldState; IGRint *ComputeTable;
  		  struct GRid *ParamsTable; union VRparam_attr *PipeParams, 
		  *DimParamsTable;IGRchar *go_cnst_lis; struct GRas *assoc_list;
		  struct VRPlaceStr *PlaceStr; struct GRmd_env *md_env );


/*---------------------------------------------------------------------------
/* VRCreate
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRBuild( IGRlong *msg; IGRint OldState; union VRparam_attr *PipeParams,
		 *DimParams; struct GRid *ActParamId, *UserParamId;
  		 IGRchar *go_cnst_lis; struct GRas *assoc_list;
		 struct VRPlaceStr *PlaceStr; struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRBuild
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRGetProductName( IGRshort *ProductName );

/*---------------------------------------------------------------------------
/* VRGetProductName
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRUpdate( IGRint count; struct GRid *list; struct VRPlaceStr *PlaceStr;
		  struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRUpdate
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRGetCmpParams( IGRint CompType;
	 	        union VRparam_attr *PipeParams, *FatherParams,
					   *CmpParams );

/*---------------------------------------------------------------------------
/* VRGetCmpParams
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRChgCorCmpAttrs( IGRlong *msg; struct GRid *CorCmpId;
		         union VRparam_attr *CmpParams; IGRchar cRep;
			 struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRChgCorCmpAttrs
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRGetCorCmpAttrs( IGRlong *msg; union VRparam_attr *CmpParams; 
			  struct GRid *ActParamId, *CmpParamId;
			  struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRGetCorCmpAttrs
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRGetTempAttr( IGRlong *msg; struct GRid *TempId, *ActParamId,
		      *UserParamId; union VRparam_attr *TempParams;
		      struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRGetTempAttr
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VREvalComponent( IGRlong		*msg;
			 IGRint 		CompType;
			 union VRparam_attr 	*PipeParams, *FatherParams;
			 IGRchar		*go_cnst_list;
		  	 struct	GRas		*assoc_list;
			 struct	GRmd_env	*md_env;
			 struct	GRid	   	*CorCmpId );

/*---------------------------------------------------------------------------
/* VREvalComponent
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRGetPipeTempId( IGRlong		*msg;
  		         IGRint		ChanPos;
                         struct	GRmd_env	*md_env;
  		         struct	GRid		*PipeTempId;
		         IGRshort		*TempCpt );


/*---------------------------------------------------------------------------
/* VRGetPipeTempId
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRUpdateFlowArrow( IGRlong			*retmsg;
		           IGRint			count;
		           struct	GRid		*list;
  			   struct	GRsymbology	*symb;
                           struct 	GRmd_env 	*md_env );


/*---------------------------------------------------------------------------
/* VRUpdateFlowArrow
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

message VRDeleteFlowArrow( IGRlong			*retmsg;
                           struct 	GRmd_env 	*md_env );

/*---------------------------------------------------------------------------
/* VRDeleteFlowArrow
/*
/*      Argument description :
/*      --------------------
/*
/*---------------------------------------------------------------------------
/* */

/******************************************************************************
* method VRGetNumCptOfMyComps
*
* Description:  This method gets the number of connect points for my components.
*               It sorts them in three groups:
*               - components with 1 connect point;
*               - components with 2 connect points;
*               - components with 3+ connect points;
*------------------------------------------------------------------------------
*
* Parameters:
*
* (O) IGRlong           *msg            return code (always == status).
*
* (O) IGRint            *NumComp1Cpt    If !NULL will have the number of
* 	                              	components with 1 connect point.
*
* (O) IGRint            *NumComp2Cpt    If !NULL will have the number of
*   	                                components with 2 connect points.
*
* (O) IGRint            *NumComp3Cpt    If !NULL will have the number of
*                               	components with 3 or more connect points
*
* (O) struct GRid       *LstComp1Cpt    If !NULL contains list with the ID of my
*                                       components with 1 conect point.
*				        The list is terminated by 
*					LstComp1Cpt->objid = NULL_OBJID.
*
* (O) struct GRid       *LstComp2Cpt    If !NULL contains list with the ID of my
*                                       components with 2 conect points.
*				        The list is terminated by 
*					LstComp2Cpt->objid = NULL_OBJID.
*
* (O) struct GRid       *LstComp3Cpt    If !NULL contains list with the ID of my
*                                       components with 3+ conect points.
*				        The list is terminated by 
*					LstComp3Cpt->objid = NULL_OBJID.
*
* (I) struct GRmd_env   *md_env 	module environment.
*------------------------------------------------------------------------------
*
*  Note: Caller MUST provide space for LstComp1Cpt, LstComp2Cpt and LstComp3Cpt.
*        If You have allocated memory for 3 entries in LstComp3Cpt, make sure
*        (LstComp3Cpt +3) = NULL, this will stop me loading the list. 
*------------------------------------------------------------------------------
*
* Return status:
*
* OM_S_SUCCESS  always.
*
******************************************************************************/
message VRGetNumCptOfMyComps(IGRlong             *msg;
                             IGRint              *NumComp1Cpt;
                             IGRint              *NumComp2Cpt;
                             IGRint              *NumComp3Cpt;
                             struct GRid         *LstComp1Cpt;
                             struct GRid         *LstComp2Cpt;
                             struct GRid         *LstComp3Cpt;
                             struct GRmd_env     *md_env);

/*---------------------------------------------------------------------------
/*
/*  Naming capability
/*
/*---------------------------------------------------------------------------*/


override        translate,
                add,
                IGRdir.remove,
                dump;

override        GRgetname,
                GRputname,
                GRchgname;

override        delete;


message DIgive_output( char *out_s);

/* ABSTRACT

  This message is sent with a "make_message to the expression

  ARGUMENTS

  out_s   I  : The name of the expression
          O  : the name of the expression concatenated with its syntax
*/

message VRVerCorrTopology( IGRlong *msg; struct GRmd_env *md_env;
			  struct VRvfy_file *FileData;
			  IGRboolean bVerbose; IGRint *ErrorCnt );

/* ABSTRACT

  This message verifies the topology of the correction.

  ARGUMENTS

  *msg          O  : return message 
  *md_env       I  : module environment
  *FileData    I/O : file info for reports
  bVerbose      I  : flag, TRUE if verbose report is to be generated
  *ErrorCnt    I/O : count of errors found 

*/


reject VRGetCorLenByCmp, VRGetCmpParams, VRChgCorCmpAttrs, VRGetCorCmpAttrs,
       VRGetTempAttr, VRBuild;


end specification VRCorrection;

