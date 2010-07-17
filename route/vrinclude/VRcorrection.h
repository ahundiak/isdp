/*******************************************************************************
/*
/*
/*	Author	: momo
/*
/*	Creation: November, 19th, 1990
/*
/*
/*	Change History
/*
/*	 Date	    |   name  | modification's description
/*      ------------+---------+------------------------------------------
/*
/*
/******************************************************************************/


#ifndef VRcorrection_include

#define VRcorrection_include


/******************************************************************************
/*
/*   structure to store in the instance of the correction entity repporting
/*   			correction components informations
/*
/*****************************************************************************/

struct VR_CorCmpStr
{
  IGRdouble	CmpRelPosition0;	  /* position relative par rapport au
                                          /* composant 0
                                          /**/

  IGRdouble	CmpRelPosition1; 	  /* position relative par rapport au
                                          /* composant 0 => only used by the
                                          /* pipe
                                          /**/

  IGRchar	CmpName[CorCmp_MAX_CHAR]; /* correction component name : needed
                                          /* to have pretend functionnalities
                                          /**/

  IGRshort	CmpRealPos;       	  /* correction component position
                                          /* in my list
                                          /*/

  IGRshort 	CmpFatherIndex;           /* index of my owner's father
                                          /**/

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
/*
/*		structure to place correction entity
/*
/*****************************************************************************/

struct VR_CorPlaceStr
{

  IGRboolean 	CorType;      /* set to TRUE if my fathers are FITTING TO     */
                              /* FITTING                                      */

  IGRshort	*CmpCptIndex; /* number of father connect points I adapte     */

  IGRdouble	CptVectLength;/* length between Cpts                          */

};


#endif

