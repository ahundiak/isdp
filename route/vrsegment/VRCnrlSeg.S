/******************************************************************************/
/*
/*       CLASS  NAME:   VRCnrlSeg
/*      
/*       SUBCLASS OF:   ACconc and ASnode
/*
/*       NOTES:
/*
/* History
/*
/*	momo	16-10-90	date new version design 
/*   
/*      Lori    21-11-94        Added method VerCSTopology
/******************************************************************************/

                    /*************************************/
                    /* C L A S S   D E S C R I P T I O N */
                    /*************************************/

/*
/* The class VRCnrlSeg is the control segment of the I/ROUTE application.  
/*
/* The Control Segment has a graphic representation of a line segment.
/*
/* The control segment is a subclass of ASnode because it "owns" the
/* components place on his graphic object. The components will be controled
/* by the control segment (i.e. their movement etc.).
/*
/* The control segment is also a child of 4 planes that determine its placement.
/*
/**/

class specification VRCnrlSeg (1:1) of VRconc, ASnode;


#include "VRcsdef.h"
#include "nddef.h"
#include "VRdef.h"
#include "VRcordef.h"
#include "VRcompdef.h" 
#include "VRdimdef.h" 
#include "vrconsdef.h"
#include "VRstructs.h" 
#include "ndmacros.h"


instance VRCnrlSeg
{
  /*
  /*   segment can be
  /*      piping  cs :      	VR_PIPING
  /*      hvac    cs :		VR_HVAC
  /*      cabling cs :		VR_CABLING
  /**/
  
  IGRshort csproduct;

  /*
  /*   TRUE : We compute or create correction.
  /**/
  
  IGRboolean CreateCorEntity;


  /*
  /*   TRUE : We evaluate constrains
  /**/
  
  IGRboolean EvaluateConstrains;

  /*
  /*   segment state : state used for constraints.
  /*
  /*   can be REVERSE or NOT
  /**/

  IGRint	csstate;

  /*
  /*   segment state : generic state
  /**/

  IGRint	my_state;

  /*
  /*   segment number of constrains 
  /**/

  IGRint	NbCons;

  /*
  /*   segment constrains type : See VRconsdef.h
  /**/

  IGRint	ConsType;

  /*
  /*   My Min Length
  /**/
  
  IGRdouble MinLength;

};



override GRlocate_owner,
	 GRget_locate_properties; 

override

NDupdate,
NDcompute_node, 	/* NDnode - compute the segment                                      */
NDplace, 		/* NDnode - place the segment                                        */
NDconnect, 		/* NDnode - overridden to set constrain type of the segment          */
NDchange_connect, 	/* NDnode - overridden to set constrain type of the segment when one */
                        /*          or more parents change. NDchange_connect dosn't call     */
                        /*          NDconnect but Root connect message, that is why we       */
                        /*          override it.                                             */
NDmove_to_root,         /* NDnode - delete ( vertical, common plane are deleted ), recompute */
                        /*          if not. if vertical plane is deleted we split the        */
                        /*          network.                                                 */
NDnotify_disconnect,    /* NDnode - overridden to merge segment and update the graph         */
ASpossible_parent,      /* ASnode - segment possible parents                                 */
VRget_nb_constrain,     /* ACconc - set number of segment constraints                        */
VRget_constrain;        /* ACconc - define the constraint                                    */


from VRconc inherit NDget_virtual_objects;


/*************************************************************/
/*                                                           */
/*		NEW MESSAGE NEDDED BY COMPONENT              */
/*                                                           */
/*************************************************************/


message VRGetTopo( IGRlong 			*msg;
                   IGRdouble			*my_vector;
		   struct	IGRplane 	*common_plane;
		   struct	IGRplane 	*vertical_plane;
		   struct	IGRplane 	*start_plane;
		   struct	IGRplane 	*end_plane;
		   struct	GRmd_env	*md_env           );

/******************************************************************************/
/*
/* Abstract :  This method returns structure of father segment planes 
/*	
/* Arguments
/*    input
/*	*md_env		struct GRmd_env		module environnement
/*    output
/*	*msg		IGRlong			completion code
/*      *my_vector	IGRdouble		my vector
/*      *common_plane   struct	IGRplane	common plane of the CS
/*      *vertical_plane struct	IGRplane	vertical plane of the CS
/*      *start_plane   	struct	IGRplane	start plane of the CS
/*      *end_plane   	struct	IGRplane	end plane of the CS
/*
/******************************************************************************/

message VRget_planes( IGRlong 			*msg;
  		      struct	GRid 		*common_plane;
		      struct	GRid 		*vertical_plane;
		      struct	GRid 		*start_plane;
		      struct	GRid 		*end_plane        );

/******************************************************************************/
/*
/* Abstract :  This method returns structure of father segment planes 
/*	
/* Arguments
/*    input
/*
/*    output
/*	*msg		IGRlong			completion code
/*      *my_vector	IGRdouble		my vector
/*      *common_plane   struct	GRid		common plane of the CS
/*      *vertical_plane struct	GRid		vertical plane of the CS
/*      *start_plane   	struct	GRid		start plane of the CS
/*      *end_plane   	struct	GRid		end plane of the CS
/*
/******************************************************************************/

message VRget_terminators( IGRlong 			*msg;
                           IGRint			*nb_cmp;
             		   struct 	GRmd_env	*md_env;
		  	   IGRdouble 			*cmp_pt;
		  	   struct 	GRid 		*cmp_id   );

/******************************************************************************/
/*
/* Abstract : get the terminators of a segment.
/*
/* Arguments
/*   output :
/*	*msg		IGRlong		completion code
/*	*mnb_cmp	IGRint		number of component
/*	*cmp_pt		IGRdouble	2 origin pts of terminators (size 6)
/*	*cmp_id		struct GRid	2 terminators (size 2)
/*	
/* Return Value for msg
/*	- MSSUCC
/*	- MSFAIL
/*
/*****************************************************************************/

message VRsplit_segment( IGRlong 			*msg;
			 IGRboolean			SharePlane;
            	         IGRdouble			*split_point;
            	         struct 	GRmd_env	*md_env;
		         struct	GRid			*NewSeg_id    );


/******************************************************************************/
/*
/* Abstract : split segment
/*
/* Arguments
/*   output :
/*	*msg		IGRlong		  completion code
/*      *NewSeg_id	struct GRid	  new segment
/*
/*   input  :
/*	*split_point	IGRdouble	  split point
/*	*md_env		struct GRmd_env	  module env.
/*	
/* Return Value for msg
/*	- MSSUCC
/*	- MSFAIL
/*
/*****************************************************************************/

message VRmerge_segments( IGRlong		*msg;
			  struct GRid 		*segment_to_merge; 
                          struct GRmd_env 	*md_env;
                          struct GRid		*PrevConnectedCmpId;
                          struct GRid		*cmp_to_connect );


/******************************************************************************/
/*
/* Abstract : notify segment for a merge
/*
/* Arguments
/*   input :
/*    I/O  *msg                 IGRlong		  return code
/*    I/   *segment_to_merge	struct GRid	  segment to merge
/*    I/   *md_env		struct GRmd_env	  module env.
/*    I/   *PrevConnectedCmpId	struct GRid       my prev. connected component
/*    O/   *cmp_to_connect	struct GRid	  my new cmp
/*
/*
/*****************************************************************************/

message VRnotify_merge( IGRlong *msg; struct GRmd_env *md_env );


/******************************************************************************/
/*
/* Abstract : notify segment for a merge
/*
/* Arguments
/*   input :
/*      *msg            IGRlong		  return code
/*	*md_env		struct GRmd_env	  module env.
/*
/******************************************************************************/


message VRChgSegState( IGRshort CorState, ConstState );

/******************************************************************************/
/*
/* Abstract : notify segment for a merge
/*
/* Arguments
/*   input :
/*    I/   CorState  	IGRshort      new segment state ( 0 , 1 )
/*    I/   ConstState  	IGRshort      new segment state ( 0 , 1 )
/*
/******************************************************************************/

message VRSegMinLength( IGRlong 			*msg;
			IGRint				Operation;
			IGRdouble			*MinLength;
		        struct 		GRmd_env 	*md_env        );

/******************************************************************************/
/*
/* Abstract : init, update and/or get my minimum length
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong         	return code
/*    I/   Operation	   IGRint		see VRcsdef.h
/*    O/   *MinLength	   IGRdouble		needed if operation is VR_GET_LENGTH
/*    I/   *md_env	   struct GRmd_env	module env.
/*
/******************************************************************************/

message VRGetMyCmpLength( IGRlong 			*msg;
                          struct 	GRid 		*MyCmpId;
                          struct 	GRmd_env 	*md_env;
		          IGRdouble			*CmpLength );

/******************************************************************************/
/*
/* Abstract : get my components length
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong         	return code
/*    I/   *MyCmpId	   struct GRid		children list
/*    I/   *md_env	   struct GRmd_env	module env.
/*    I/   *CmpLength	   IGRdouble		my cmp0 length.
/*
/******************************************************************************/

message VRGetMyCorLength( IGRlong 			*msg;
                          struct 	GRid 		*MyCmpId;
                          struct 	GRmd_env 	*md_env;
			  IGRdouble			*CorLength );

/******************************************************************************/
/*
/* Abstract : get my correction length
/*
/* Arguments
/*   input :
/*    I/O  *msg            IGRlong         	return code
/*    I/   *MyCmpId	   struct GRid		children list
/*    I/   *md_env	   struct GRmd_env	module env.
/*    I/   *CorLength	   IGRdouble		my correction length.
/*
/******************************************************************************/

message VRSegConstrainsType( IGRint Operation, NewConsType, *SegConsType );

/************************************************************************************/
/*
/* Abstract : init, update, get my constrains type
/*
/* Arguments
/*   input :
/*    I/  Operation	IGRint	operation type ( see VRcsdef.h )
/*    I/  NewConsType	IGRint	my new constrains type.
/*    O/  *SegConsType	IGRint	my constrain type needed if operation is VR_GET_TYPE
/*
/***********************************************************************************/


message VRGetNeighbors( IGRlong 		*msg;
                        IGRint			SizeBuff;
                        IGRint			*NbOfNeigh;
		        struct	GRid		*NeiIds;
		        struct	GRmd_env	*md_env );

/******************************************************************************/
/*
/* Abstract :  This method returns structure of father segment planes 
/*	
/* Arguments
/*    input
/*	SizeBuff	IGRint			size of NeiIds
/*	*md_env		struct GRmd_env		module environnement
/*    output
/*	*msg		IGRlong			completion code
/*      *NbOfNeigh	IGRint			number of neighbors
/*      *NeiIds		struct	GRid		list of neighbors
/*
/******************************************************************************/

message VRGetComponents( IGRlong 			*msg;
                         IGRint			        *nb_cmp;
		  	 struct 	GRid 		*cmp_id   );

/******************************************************************************/
/*
/* Abstract : This message select only components on the children channel
/*            of segment. List of components is independante of components'
/*            index on the segment.
/*
/* Arguments
/*   output :
/*	*msg		IGRlong		completion code
/*	*nb_cmp		IGRint		number of component
/*	*cmp_id		struct GRid	2 terminators (size 2)
/*
/*****************************************************************************/

message VRGetSegProduct( IGRshort *SegProduct );

/******************************************************************************/
/*
/* Abstract : This message return segment product
/*
/* Arguments
/*   output :
/*	*SegProduct	IGRshort
/*
/*****************************************************************************/

message VRnotify_disconnect( 	IGRshort delete_flag;
				struct GRid previous_connected );

/******************************************************************************/
/*
/* Abstract : This message is added to disconnect a nozzle form a network using
/*	      the NDnotify_disconnect.
/*
/* Arguments
/*   output :
/*
/*****************************************************************************/


message VRget_state ( IGRint *n_state );

/******************************************************************************/
/*
/* Abstract : this message is used to get the state my_state of the target
/*            element.
/*
/*****************************************************************************/


message VRchg_state( IGRint mask, n_state );

/******************************************************************************/
/*
/* Abstract : this message is used to change the state of the target element :
/*            me->state = (me->state & ~mask) | nstate;
/*
/*****************************************************************************/

message VRVerCSTopology( IGRlong *msg; struct VRvfy_objs *NewObj; 
			 struct GRmd_env *md_env;
			 struct VRvfy_file *FileData;
			 IGRboolean bVerbose; IGRint *ErrorCnt);

/******************************************************************************/
/*
/* Abstract : this message is used to verify segment toplogy  It can also 
/*            return the planes connected to the control segment so they
/*            can be verified.  Results are printed to reports. 
/*    *msg       O    - return status
/*    *NewObj    I/O  - objects to be returned to be later verified if any
/*    *md_env    I    - module environment 
/*    *FileData  I/O  - File info for verbose and error report
/*    bVerbose   I    - Flag, TRUE if verbose report is to be generated
/*    *ErrorCnt  I/O  - Count of Errors found 
/*
/*****************************************************************************/

end specification VRCnrlSeg;








