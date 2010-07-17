/*******************************************************************************
/*
/*	Author	:	momo
/*
/*	Creation:	November 19th, 1990
/*
/*
/*		This file contains the definition of all correction constants.
/*		
/*	
/*	Change History :
/*
/*
/*		  date	|  name	|	modification's description
/*		--------+-------+-----------------------------------
/*		Feb 97	 kdd	struct VRCorrection
/*
/*
/******************************************************************************/

#ifndef	vr_cor_def_include
#define vr_cor_def_include



	/* -- maximum length of component name string -- */

#define	CorCmp_MAX_CHAR	5

	/* -- maximum correction component -- */

#define	MAX_CorCmp	5

	/* -- number of maximum predefined correction parent -- */

#define	my_nbParent	2

	/* -- Definition of compute correction type -- */

#define VR_IMMEDIATE_COMPUTE	0x0001
#define	VR_DEFFER_COMPUTE	0x0002 
#define	VR_NO_COMPUTE		0x0004
#define	VR_PLACE		0x0008


	/* -- Define used to get correction component parameters -- */

#define VR_ADP			1
#define VR_RED			2

	/* -- Defintion of my state  -- */

#define	VR_COR_INIT		0xff00
#define	VR_COR_BUILD		0x006f
#define	VR_COR_REBUILD		0x0600

#define VR_ADAPTER0		0x0001
#define VR_REDUCER0		0x0002
#define VR_ADAPTER1		0x0004
#define VR_REDUCER1		0x0008
#define	VR_STRAIGHT		0x0010
#define	VR_TRANS0		0x0020
#define	VR_TRANS1		0x0040


#define	VR_FIT_TO_FIT		0x0100
#define	VR_UPDATE_CON		0x0200
#define	VR_UPDATE_PIPE		0x0400

#define	VR_COR_PID_REP		0x1000
#define	VR_DISP_FLOW		0x2000


/******************************************************************************
/*
/*   structure to store in the instance of the correction entity repporting
/*   			correction components informations
/*
/*****************************************************************************/

struct VR_CorCmpStr
{
  IGRdouble	CmpRelPosition0;	  /* TO BE REMOVED */

  IGRdouble	CmpRelPosition1; 	  /* TO BE REMOVED */

  IGRchar	CmpName[CorCmp_MAX_CHAR]; /* correction component name : needed
                                          /* to have pretend functionnalities
                                          /**/

  IGRshort	CmpRealPos;       	  /* correction component position
                                          /* in my list
                                          /*/

  IGRshort 	CmpFatherIndex;           /* index of my owner's father
                                          /**/

  IGRshort	CmpItemNum;               /* TO BE REMOVE */

  IGRshort	CmpJustification;         /* placment justification
                                          /**/

  IGRchar	CmpRepresentation;        /* TO BE REMOVED */


  IGRshort	CmpOrientation;           /* TO BE REMOVED */

};

/*****************************************************************************/

struct VRPlaceStr
{
  IGRshort	CmpItemNum;               /* VR_PIPE, VR_REDUCER, ...
                                          /**/

  IGRshort	CmpJustification;         /* placment justification
                                          /**/

  IGRchar	CmpRepresentation;        /* placement representation
                                          /**/

  IGRshort	CmpOrientation;           /* component orientation
                                          /**/
};

/******************************************************************************
* KDD
*   structure to store the VRCorrection instance + selection mask.
*       Used in GRgetattr and GRputatt methods.
*
******************************************************************************/
struct VRCorrection_common 
{

        int     Iwant;          /* selection mask defined below  */

        IGRdouble     my_length[2];

        struct VR_CorCmpStr *my_StrCmpList;
                                /* to get the size om$dimension_of DIbtree.h */

        IGRint        my_state;

        IGRint        my_NbCorCmp;

        IGRshort      my_CmpCptIndex[my_nbParent];

        IGRshort      Fitting_to_Fitting;

        IGRboolean    UpdateCmpCptIndex;

        IGRboolean    UpdatePipeDim;

        IGRshort      FlowDirection;

        IGRdouble     FlowValue;
};

typedef struct VRCorrection_common  VRCorrection_struct ;

/******************************************************************************
* KDD  Definition of Selector names for VRCorrection_common.Iwant field.
******************************************************************************/
#define VRCorrection_my_length          1
#define VRCorrection_my_StrCmpList      2
#define VRCorrection_my_state           3
#define VRCorrection_my_NbCorCmp        4
#define VRCorrection_my_CmpCptIndex     5
#define VRCorrection_Fitting_to_Fitting 6
#define VRCorrection_UpdateCmpCptIndex  7
#define VRCorrection_UpdatePipeDim      8
#define VRCorrection_FlowDirection      9
#define VRCorrection_FlowValue          10

#endif

