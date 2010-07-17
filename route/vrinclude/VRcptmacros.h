#ifndef vrcptmacros_include

#define vrcptmacros_include

/***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern double VRSelectClosestCpt __((	IGRboolean		bFree,
				struct  GRid		*p_Component,
				struct	GRid		*p_Window,
				IGRdouble		*p_DataPoint,
				IGRshort		*p_Cpt,
				IGRdouble		*p_CptCoord,
				struct	GRmd_env	*p_Mdenv	));

extern IGRint VRIsCmpOrientable __((	IGRlong		*p_Msg,
				struct  GRid		*p_CmpId,
				IGRdouble		*p_RotAxis,
				struct	GRmd_env	*p_Mdenv	));

#if defined(__cplusplus)
}
#endif

/************************************************************************/
/*									*/
/* Abstract :	Given as inputs an I/ROUTE component object and a data	*/
/*		point, this macro gives the connect point of the given  */
/*		component nearest to the data point and returns the	*/
/*		minimum distance.					*/
/*									*/
/* Arguments :								*/
/*									*/
/* I IGRboolean	bFree		: Tells whether the selected Cpt must be*/
/*				  free or not. 				*/
/*				  set this to TRUE if Cpt has to be Free*/
/* I GRid	*p_Component	: Specified component's Id		*/
/* I GRid	*p_Window	: Specified window's Id ( in which the  */
/*				  data point has been given )		*/
/* I IGRdouble	*p_DataPoint	: Specified datapoint 			*/
/* O IGRshort	*p_Cpt		: Selected Cpt number 			*/
/* O IGRdouble	*p_CptCoord	: Selected Cpt's coordinates		*/
/*				  NULL if not required	 		*/
/* I GRmd_env	*p_Mdenv	: Specified component's module env	*/
/************************************************************************/

#omdef VR$SelectClosestCpt(	bFree=TRUE,
				p_Component=NULL,
				p_Window=NULL,
				p_DataPoint=NULL,
				p_Cpt,
				p_CptCoord=NULL,
				p_Mdenv)

VRSelectClosestCpt( bFree, p_Component, p_Window, p_DataPoint, p_Cpt, p_CptCoord, p_Mdenv )

#endomdef

/************************************************************************/
/*									*/
/* Abstract :	Given as input an I/ROUTE component object, this macro  */
/* 		finds out whether the component is rotatable or not.    */
/*		Returns 1 ( TRUE ) if the Cmp is orientable,else returns*/
/*		0( FALSE ).						*/
/*									*/
/* Arguments :								*/
/*									*/
/* O IGRlong	*p_Msg		: Return Code MSSUCC or MSFAIL		*/
/* I GRid	*p_CmpId	: Specified component's Id		*/
/* O IGRdouble	*p_RotAxis	: Vector defining the Rot Axis of the	*/
/*				  given component	 		*/
/* I GRmd_env	*p_Mdenv	: Specified component's module env	*/
/************************************************************************/

#omdef VR$IsCmpOrientable(	p_Msg=TRUE,
				p_CmpId,
				p_RotAxis=NULL,
				p_MdEnv)

VRIsCmpOrientable( p_Msg, p_CmpId, p_RotAxis, p_MdEnv )

#endomdef

#endif
