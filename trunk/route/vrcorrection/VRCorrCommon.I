/* $Id: VRCorrCommon.I,v 1.2 2001/02/20 01:13:08 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRCorrGlob.I
 *
 * Description:	Functions to Store/Set/Get global Parameters of
 *		VRCorrection objects. Could be called from PPL commands. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCorrCommon.I,v $
 *	Revision 1.2  2001/02/20 01:13:08  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/02/18  10:57:32  pinnacle
# Created: vrcorrection/VRCorrCommon.I by sbilla for ROUTE
#
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.2  1997/06/24  22:37:02  pinnacle
 * Replaced: vrcorrection/VRCorrCommon.C for:  by kddinov for route
 *
 * Revision 1.1  1997/02/24  00:11:48  pinnacle
 * Created: vrcorrection/VRCorrCommon.C by kddinov for route
 *
 *
 * History:
 *	Feb/03/97	kdd	VRCorrection_VRFlArSc
 *				VRCorrection_VRFlArSym
 *
 *      Feb/14/99	Reddy	TR179802496 : Flow arrow scale expressions 
 *				are put into directory subsystems and are
 *				retrieved from it. This filename is changed 
 *				from VRCorrCommon.C to VRCorrCommon.I in order
 *				to import the method NDgive_structure from
 *				NDNode. Corresponding change has been made in
 *				vrcorrection.m file.
 *
 *************************************************************************/

class implementation Root;

#include <stdlib.h>
#include "VRcompdef.h"

#include <stdio.h>
#include <math.h>
#include <string.h>

#include "OMprimitives.h"
#include "OMlimits.h"
#include "OMmacros.h"

#include "AS_status.h"
#include "exdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "nddef.h"
#include "ACattrib.h"

#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"

#include "vrdbgmacros.h"
#include "VDDbDef.h"
#include "VDmacdef.h"
#include "VDDfEntCode.h"
#include "VDSutil.h"

#include "vrtools_pto.h"
#include "vrpdu_pto.h"

#include "VRDbStruct.h"
#include "VRMcForm.h"
#include "vrinit_pto.h"
#include "VRdef.h"

#include "VRparamdef.h"
#include "VRco.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"

#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRPid.h"

#include "VRDbStruct.h"
#include "vrinit_pto.h"


from NDnode import NDgive_structure;

extern char	toupper(char);
/*
#define vdsDEBUG 1
#define vdserrDEBUG 1
*/

/******************************************************************************
*
*  This function stores/sets/gets the 3D flow arrow scale vector 
*	for all objects of class VRCorrection.
*
*-------------------------------------------------------------------------------
*  PARAMETERS 
*
*  setflag	= 1 set the scale array. 3 different X, Y & Z scales.
*		 -1 set the scale array. Single scale factor for all axis.
*		  0 get the scale array
*
*  XYZscale	= 3D scale array
*
*-------------------------------------------------------------------------------
*  ALGORITHM:
*  All negative or zero values are filtered out, and old values remain. 
*  For XYZscale={2.0, 0.0, 3.0}, scaling is: X = 2, Y unchanged, Z = 3
*
*-------------------------------------------------------------------------------
*  RETURN STATUS
*	1 = OK
*	0 = Unknown setflag.
*
*-------------------------------------------------------------------------------
*  Sample call:
*
*  	int           rc,setflag;
*  	double        XYZscale[3];
*
*  	rc = VRCorrection_VRFlArSc ( setflag, XYZscale);
*-------------------------------------------------------------------------------
*
*  HISTORY
*  Feb 97	kdd	creation 
*
*******************************************************************************/
int VRCorrection_VRFlArSc( int		setflag,
			   double	*XYZscale)
{
	double		VRArrowScale[3]={1.0, 1.0, 1.0};
  	int		status= 1;
	struct 		GRid ExpressionId[6];
	IGRchar 	szPathName[DI_PATH_MAX]; 
	GRspacenum      nOS ;
	struct GRid     dirobj;

	SetProc( VRCorrection_VRFlArSc ); Begin 

 switch ( setflag )
 {

  case -1:					/* Set uniform scale */
      __DBGpr_com( " Case: Set uniform scale ");

  	if ( *XYZscale <= 0.0 ) { break; }

        VRArrowScale[0] = *XYZscale;
        VRArrowScale[1] = *XYZscale;
        VRArrowScale[2] = *XYZscale;
	break;

  case 1:					/* Set non uniform scale */
      __DBGpr_com( "Case: Set non-uniform scale  ");

	if (XYZscale[0] > 0.0) VRArrowScale[0] = XYZscale[0];
	if (XYZscale[1] > 0.0) VRArrowScale[1] = XYZscale[1];
	if (XYZscale[2] > 0.0) VRArrowScale[2] = XYZscale[2];
	break ;

  case 0:					/* Get scale */	
	__DBGpr_com( " Case: Get  scale case  ");
	XYZscale[0] = VRArrowScale[0];
	XYZscale[1] = VRArrowScale[1];
	XYZscale[2] = VRArrowScale[2];
	break;

  default: 
	status = 0;
	goto wrapup;
  }

        /** TR179802496 Begin  - Reddy **/

  if( setflag != 0 )
  {
	IGRchar x_scalevalue[20];
	IGRchar y_scalevalue[20];
	IGRchar z_scalevalue[20];
      __DBGpr_com( " Setting the values for expressions for X,Y,Z scales in the directory subsystem ");

	/* Change to the HOME directory */
	status = di$cd( dirname = DIR_G_home_name );
	__DBGpr_str( " Current Home Directory is ",DIR_G_home_name);

	/* Check whether the directory already exists */

	 nOS = OM_Gw_current_OS ;
	 strcpy (szPathName,DIR_G_home_name);
	 strtok (szPathName,":");
         strcat (szPathName, ":IGENOD" );
         strcat (szPathName, ":flowarrowscale");    
	 __DBGpr_str( " Directory is ",szPathName);

         status =di$translate (    objname = szPathName,
	                           osnum   = nOS,
				   p_objid = &dirobj.objid,
				   p_osnum = &dirobj.osnum );

	if (status != DIR_S_SUCCESS)
	{ 

	__DBGpr_com( " Creating a new directory ");
	
        status = di$mkdir (dirname = szPathName,
			   osnum   = nOS,
			   p_dirid = &dirobj.objid,
			   p_osnum = &dirobj.osnum );
	as$status();
        }
	 
       __DBGpr_str( " Directory to place scaling expressions is",szPathName);
       
        /* Change to the directory where you want to place the expressions */
	  
	status = di$cd (dirname = szPathName,
			  osnum   = nOS);

      __DBGpr_str( " Directory is changed to",szPathName);

       /* Get the ExpressionId if it is already created
       	  in the Directory Subsystem (:<filename>:usr:flowarrowscale)*/

       /* X-scale */
	ExpressionId[0].osnum = OM_Gw_current_OS ;
      __DBGpr_int( " ExpressionId[0].osnum",ExpressionId[0].osnum);
	status = di$translate(
				  objname = "X-scale",
				  p_objid = &ExpressionId[0].objid,
				  p_osnum = &ExpressionId[0].osnum );
	if( status != DIR_S_SUCCESS )
        {
	  sprintf(x_scalevalue,"%f",VRArrowScale[0]);
	__DBGpr_com( " Creating the expression for X-scale in dir.subsystem");
	__DBGpr_str( " x_scalevalue is",x_scalevalue);

	  status = exp$create (
				exp_name   = "X-scale",
				exp_syntax = x_scalevalue,
				osnum      = ExpressionId[0].osnum,
				p_exp_id   = &ExpressionId[0].objid,
				p_osnum    = &ExpressionId[0].osnum,
				type_rq    = EXP_TEXT );
       }
       else
       {
	  sprintf(x_scalevalue,"%f",VRArrowScale[0]);
        __DBGpr_com( " Modifying  the expression for X-scale ");
	__DBGpr_str( " x_scalevalue is",x_scalevalue);
 	  status = exp$modify ( exp_id = ExpressionId[0].objid,
			        osnum  = ExpressionId[0].osnum,
	       		        exp_syntax = x_scalevalue);
       }			       

	  /*  Y-scale */
	  ExpressionId[1].osnum = OM_Gw_current_OS ;
	  status = di$translate(    objname = "Y-scale",
				    p_objid = &ExpressionId[1].objid,
				    p_osnum = &ExpressionId[1].osnum );

	  if( status != DIR_S_SUCCESS )
	  {
	    __DBGpr_com( "Creating the expression for Y-scale dir.subsystem");
	      sprintf(y_scalevalue,"%f",VRArrowScale[1]);
	    __DBGpr_str( " y_scalevalue is",y_scalevalue);

	  status = exp$create (
				exp_name   = "Y-scale",
				exp_syntax = y_scalevalue,
				osnum      = ExpressionId[1].osnum,
				p_exp_id   = &ExpressionId[1].objid,
				p_osnum    = &ExpressionId[1].osnum,
				type_rq    = EXP_TEXT );
         }
	 else
	 {
	    __DBGpr_com( " Modifying  the expression for Y-scale ");
	      sprintf(y_scalevalue,"%f",VRArrowScale[1]);
	    __DBGpr_str( " y_scalevalue is",y_scalevalue);

	     status = exp$modify ( exp_id = ExpressionId[1].objid,
				   osnum  = ExpressionId[1].osnum,
				   exp_syntax = y_scalevalue );
         }			       

	  /*   Z-scale */
	  ExpressionId[2].osnum = OM_Gw_current_OS ;
	  status = di$translate(  objname = "Z-scale",
				  p_objid = &ExpressionId[2].objid,
				  p_osnum = &ExpressionId[2].osnum );


	if( status != DIR_S_SUCCESS )
        {

	__DBGpr_com(" Creating the expression for Z-scale in dirr. subsystem ");
	  sprintf(z_scalevalue,"%f",VRArrowScale[2]);
	__DBGpr_str( " z_scalevalue is",z_scalevalue);


	  status = exp$create ( exp_name   = "Z-scale",
				exp_syntax = z_scalevalue,
				osnum      = ExpressionId[2].osnum,
				p_exp_id   = &ExpressionId[2].objid,
				p_osnum    = &ExpressionId[2].osnum,
				type_rq    = EXP_TEXT );
         }
	 else
	 {
	    __DBGpr_com( " Modifying  the expression for Z-scale ");
	      sprintf(z_scalevalue,"%f",VRArrowScale[2]);
	    __DBGpr_str( " z_scalevalue is",z_scalevalue);
	      status = exp$modify ( exp_id = ExpressionId[2].objid,
				    osnum  = ExpressionId[2].osnum,
				    exp_syntax = z_scalevalue );
         }	
		       
         /* Re-Setting it to the PWD directory  */
	 status =di$cd( dirname = DIR_G_home_name );
	 UI_status( "Flow Arrow scale is set " );
       __DBGpr_com("Resetting the directory to home");
       __DBGpr_str( "PWD", DIR_G_home_name);

   }
   else
   {
        /* Retieve the information from directory sub-system */

	__DBGpr_com( " Retrieving the expressions for X,Y,Z scales from the directory  sub-system ");
	
	/* Setting it to the HOME directory i.e ":filename:usr" */
	   status = di$cd( dirname = DIR_G_home_name );
	 __DBGpr_str( " HOME directory", DIR_G_home_name);

        /* Check if your directory exists. If it does, change to that directory.
 	   Else ,since XYZscale has already been set to 1,1,1 (in the switch 
	   statement ) goto wrapup */

	 nOS = OM_Gw_current_OS ;
	 strcpy (szPathName,DIR_G_home_name);
	 strtok (szPathName,":");
         strcat (szPathName, ":IGENOD" );
         strcat (szPathName, ":flowarrowscale");    

       __DBGpr_str( " Directory path for search is ",szPathName);

         status =di$translate (    objname = szPathName,
                                   osnum   = nOS,
                                   p_objid = &dirobj.objid,
                                   p_osnum = &dirobj.osnum );

        if (status != DIR_S_SUCCESS)
	{
	  __DBGpr_com( " Directory not found. Default values are");
	  __DBGpr_dbl( " X scale is  ",VRArrowScale[0]);
	  __DBGpr_dbl( " Y scale is  ",VRArrowScale[1]);
	  __DBGpr_dbl( " Z scale is  ",VRArrowScale[2]);
	    goto wrapup;
	}

	/* Change to the 'flowarrowscale directory  */
  	   
       __DBGpr_str( " Directory from which the scaling expressions are retrieved is ",szPathName);

        status = di$cd (dirname = szPathName,
       		        osnum   = nOS);

	/* Get the ExpressionId if it is already created in the
	   Directory Subsystem */

        /* X-Scale */

	   status = di$translate(  objname = "X-scale",
				   p_objid = &ExpressionId[3].objid,
				   p_osnum = &ExpressionId[3].osnum );

	   if( ExpressionId[3].objid != NULL_OBJID )
	   {
		IGRlong retcode=MSSUCC;
		struct  GRmd_env        *md_env;
		IGRchar opt_code[20]; 
		struct ret_struct ExprSt;
		status =
		om$send ( msg = message NDnode.NDgive_structure(
				     &retcode, &ExprSt, md_env ),
                 	  senderid = NULL_OBJID,
			  targetid = ExpressionId[3].objid,
			  targetos = ExpressionId[3].osnum );
		as$status ();
		strcpy( opt_code, ExprSt.var.text_st.text_string );
                XYZscale[0] = atof(opt_code);
		__DBGpr_dbl( " x_scalevalue",XYZscale[0]);
		
	   }
	   else 
	   {
	      goto wrapup;
	   }
	
		
	  /* Y-Scale */

	  status = di$translate( objname = "Y-scale",
				  p_objid = &ExpressionId[4].objid,
				  p_osnum = &ExpressionId[4].osnum );

	  if( ExpressionId[4].objid != NULL_OBJID )
	   {
		IGRlong retcode=MSSUCC;
		struct  GRmd_env        *md_env;
		IGRchar opt_code[20];
		struct ret_struct ExprSt;
		status =
		om$send ( msg = message NDnode.NDgive_structure(
				     &retcode, &ExprSt, md_env ),
                 	  senderid = NULL_OBJID,
			  targetid = ExpressionId[4].objid,
			  targetos = ExpressionId[4].osnum );
		as$status ();
		strcpy( opt_code, ExprSt.var.text_st.text_string );
                XYZscale[1] = atof(opt_code);
		__DBGpr_dbl( " y_scalevalue",XYZscale[1]);
	   }
	   else 
	   {
	      goto wrapup;
	   }

	    /* Z-Scale */

	     status = di$translate( objname = "Z-scale",
				    p_objid = &ExpressionId[5].objid,
				    p_osnum = &ExpressionId[5].osnum );

	     if( ExpressionId[5].objid != NULL_OBJID )
	     {
		IGRlong retcode=MSSUCC;
		struct  GRmd_env        *md_env;
		IGRchar opt_code[20] ;
		struct ret_struct ExprSt;
		status =
		om$send ( msg = message NDnode.NDgive_structure(
				     &retcode, &ExprSt, md_env ),
                 	  senderid = NULL_OBJID,
			  targetid = ExpressionId[5].objid,
			  targetos = ExpressionId[5].osnum );
		as$status ();
		strcpy( opt_code, ExprSt.var.text_st.text_string );
                XYZscale[2] = atof(opt_code);
		__DBGpr_dbl( " z_scalevalue",XYZscale[2]);
	     }
	     else
	     {
	         goto wrapup;
	     }

	 /*  Re-Setting it to the PWD directory  */
	     status = di$cd( dirname = DIR_G_home_name );
	   __DBGpr_com( " Resetting the directory to Home");
	   __DBGpr_str( " PWD ", DIR_G_home_name);
     }
        
        /** TR179802496 End  - Reddy  **/

__DBGpr_com( "End: if-else condition of VRCorrection_VRFlArSc");

wrapup:
End
return (status) ;
}


/******************************************************************************
*  This function stores/sets/gets the Flow Arrow Symbol for VRUpdateFlowArrow
*
* 	This function is needed in vrflowco/VRflowdir.sl to determine the 
*	next symbol. The direction will be inherited from the current symbol. 
*-------------------------------------------------------------------------------
*  PARAMETERS
*
*  setflag      = 1 set current Flow Arrow Symbol
*                 0 get current Flow Arrow Symbol
*                 2 set Update flag
*                -2 get Update flag
*
*  code         = Flow Arrow Symbol code 
*		  single arrow (VR_FLOW_IN or VR_FLOW_OUT)
*		  double arrow (VR_FLOW_BIDIRECTION)
*-------------------------------------------------------------------------------
*  RETURN STATUS
*       1 = OK
*       0 = Unknown code .
*******************************************************************************/
int VRCorrection_VRFlArSym( int  setflag,
                            int	 *code)
{
static	int 	flow_symbol={0};
static  int	UpdateFlag={0}; 

	int	status = 1;

   switch ( setflag) { 

   case 1:
	flow_symbol = *code;
	break;

   case 0:
	*code = flow_symbol;
	break;

   case 2:
	UpdateFlag = *code;
	break;

   case -2:
	*code = UpdateFlag;
	break;

   default:
	status = 0; 
	goto wrapup; 
   }

wrapup:

return (status);
}


end implementation Root;
