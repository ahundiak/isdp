/******************************************************************************
 *
 *	Author	:	momo
 *
 *	Creation:	November 19th, 1990
 *
 *	CLASS  NAME:	VRPCorentity
 *
 *	SUBCLASS OF:	VRCorrection
 *
 *	Description:	This class is the Piping correction entity class of the
 *			I/ROUTE application
 *
 *		
 *	Change History :
 *
 *
 *	  date	|  name	|	modification's description
 *	--------+-------+-----------------------------------
 *	Apr 3 02  Anand	  override VREvalComponent in VRPCorentity
 *
 ****************************************************************************/

class specification VRPCorentity (1:0) of VRCorrection;


instance VRPCorentity
{
};


override


  GRgetobjinfo,		/* GRgraphics   - repport the information about Piping*/
                        /*                correction entity                   */
  ASconstruct_go,	/* ASnode	- construct and connect component     */
  VREvaluate,		/* VRCorrection - evaluate piping correction entity   */
  VRGetCmpParams,	/* VRCorrection - get component union VRparam_attr    */
  VRChgCorCmpAttrs,	/* VRCorrection - change component attributes         */
  VRGetCorCmpAttrs,     /* VRCorrection - get component attributes            */
  VRGetTempAttr,	/* VRCorrection - get template attributes	      */
  VRBuild,		/* VRCorrection - build component correction withput  */
			/*                the straight			      */
  VRGetCorLenByCmp;     /* VRCorrection - get coomponent correction length    */
                        /*                beside a given component            */

override
  VREvalComponent;	/* VREvalComponent - Evaluate Mating flange (moved    */
			/*		  big chunk from VRCorrection to here)*/

end specification VRPCorentity;

