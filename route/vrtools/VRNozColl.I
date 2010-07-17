/* $Id: VRNozColl.I,v 1.2 2001/02/20 01:17:56 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRNozColl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRNozColl.I,v $
 *	Revision 1.2  2001/02/20 01:17:56  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/04/01  05:40:42  pinnacle
# Replaced: vrtools/VRNozColl.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:31:38  pinnacle
# Replaced: vrtools/VRNozColl.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb	Add prototypes
	March/99   Reddy        TR179900392 - Width and depth values are
	                        getting are getting truncated to 6 digits.
 *
 *************************************************************************/
/*************************************************************/
/*	File 	: VRNozCol.I
/*	Author	: B Demars ( ISDC, Paris )
/*	Date	: 12-OCT-92 Route release 2.1.0.
/*
/*	* 12-OCT-92	2.1.0.
/*		Bruno
/*		Implement the two functions that will allow
/*		the Nozzle's collection to have expressions
/*		as templates.
/*
/*	* 15-OCT-92	2.1.0.
/*		Karine
/*		Two functions for expressions
/*		One to create or modify expression
/*		One to get expression value
/*************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "igr.h"
#include "msdef.h"
#include <stdio.h>
#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "parametric.h"
#include "VRDbParamDef.h"
#include "vrparameters.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "expression.h"
#include "expmacros.h"
#include "VRchgattrdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "VRdbcodlst.h"
#include "AS_status.h"
#include "vrdbgmacros.h"

#include "vrpdu_pto.h"
#define AS_DEBUG

from  ACrg_collect	import 	ACget_attribute_at_index,
				ACget_named_attribute,
				ACmod_list_attribute;
from  NDnode		import 	NDgive_structure;


/*-------------------------------------------------------------------*/
/*	function VRGenericLink
/*
/* 
/* This function is assigned to a "ACdyn_coll" and links one to one the
/* expressions template of the collection to the attributes stored.
/* It is activated by the NDupdate method of the collection ( compute
/* processus ).
/*
/* This function returns 	MSSUCC if everything goes allright.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint VRGenericLink( 	msg, CollId, Attr,
			md_env, NbTemp, TempIds, TempState, Context )
			       
IGRlong 	*msg ;		/* O : Return code, MSSUCC or MSFAIL.    */
struct GRid	CollId;		/* I : Collection's object id            */
struct ACrg_coll *Attr;		/* I : Attribute in which this function is
				       stored ???*/
struct GRmd_env	*md_env ; 
IGRint		NbTemp;		/* I : Number of the expression template */
struct GRid	*TempIds;	/* I : List of expression templates */
IGRint		*TempState;	/* I : Compute status of each expression */
struct GRid	Context;	/* I : List of the context of each expression */

/*.VRGenericLink */
{
 IGRint	i;

 *msg = ND_COMP_SUCC;

 /*" CollId : <%d,%d>\n", CollId.objid, CollId.osnum */
 /*" %d Expressions\n", NbTemp */

 for ( i=0; i<NbTemp; i++ )
 {
   /* -- loop on expressions for updating the attributes -- */

   /*" Expression[%d]: <%d,%d>\n",i,TempIds[i].objid,TempIds[i].osnum */

   /* -- Update attribute -- */
   if ( TempState[i] != ND_COMP_SAME )
   {
	IGRint			status;
	struct ACrg_coll	AttrSt;
	struct ret_struct	ExprSt;

	/* -- Expression modified : -- */
	/*" ---->Modified ... \n"*/

	/* -- Get attributes by index -- */

	status = 
	om$send ( msg = message ACrg_collect.ACget_attribute_at_index
			(msg,  i, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();
	if (!(status&1)) continue;

	/*" Attribute name : %s\n", AttrSt.name */

	/* -- Get expression value -- */
	status = 
	om$send ( msg = message NDnode.NDgive_structure
			(msg, &ExprSt, md_env ),
		senderid = NULL_OBJID,
		targetid = TempIds[i].objid,
		targetos = TempIds[i].osnum );
	as$status ();
	if (!status&1) continue;

	if ( ExprSt.type == double_type )
	{
	  /*" Attribute value : %f\n", ExprSt.var.root_pm_st.value */
	  if ( AttrSt.desc.type == AC_ATTRIB_DOUBLE )
	    AttrSt.desc.value.att_exp = ExprSt.var.root_pm_st.value;
	}
	else
	{
	  /*" Attribute value : <%s>\n",ExprSt.var.text_st.text_string */
	  if ( AttrSt.desc.type == AC_ATTRIB_TEXT )
	    strcpy ( 	AttrSt.desc.value.att_txt,
			ExprSt.var.text_st.text_string );
	}

	/* -- Update collection -- */
	status = 
	om$send ( msg = message ACrg_collect.ACmod_list_attribute
			(msg,  1, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();

   }/* end update attribute */		

 }/* end loop on expressions */

 return OM_S_SUCCESS;

}/* end VRGenericLink */


/*-------------------------------------------------------------------*/
/*	function VRPNozSysLink
/*
/* 
/* This function is assigned to a "ACdyn_coll" and links named
/* (hardcoded) specific attributes in the System collection to
/* the expressions templates of this collection.
/*
/* This function returns 	MSSUCC if everything goes allright.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint VRNozSysLink( 	msg, CollId, Attr, md_env, NbTemp, TempIds, 
			TempState, Context )
			       
IGRlong 	*msg ;		/* O : Return code, MSSUCC or MSFAIL.    */
struct GRid	CollId;		/* I : Collection's object id            */
struct ACrg_coll *Attr;		/* I : Attribute in which this function is
				       stored ???*/
struct GRmd_env	*md_env ; 
IGRint		NbTemp;		/* I : Number of the expression template */
struct GRid	*TempIds;	/* I : List of expression templates */
IGRint		*TempState;	/* I : Compute status of each expression */
struct GRid	Context;	/* I : List of the context of each expression */

/*.VRNozSysLink */
{
 IGRint		i;
 IGRshort    	list_num; 
 IGRshort    	code_num;

 #define END_PREP_INDEX 3
 #define PRESSURE_INDEX 4

 /* There are 7 expressions templates of this collection */
 static IGRchar	*AttrPNames[VRPNbNozAttr] = 
				{ VR_N_TAG_NUMBER_AN,
				  VR_N_SERVICE_AN,
				  VR_N_GDIAMETER_DB,
				  VR_N_PREPS_G_IN,
				  VR_N_RATINGS_G_DB,
				  VR_N_THICK_OVER_AN,
				  VR_N_END_STD_G_IN };

 *msg = ND_COMP_SUCC;

 /*" CollId : <%d,%d>\n", CollId.objid, CollId.osnum */
 /*" %d Expressions\n", NbTemp */

 /* -- Loop on expressions -- */
 for ( i=0; i<NbTemp & i<VRPNbNozAttr; i++ )
 {
   /*" Expression : <%d,%d>\n",TempIds[i].objid,TempIds[i].osnum */

   /* -- Update attribute -- */
   if ( TempState[i] != ND_COMP_SAME )
   {
	IGRint			status;
	struct ACrg_coll	AttrSt;
	struct ret_struct	ExprSt;

	/*" ---->Modified  \n" */


	/* -- Get attributes by name -- */

	strcpy ( AttrSt.name, AttrPNames[i] );
	/*" Attribute name : %s\n", AttrSt.name */
	/*" i : %d\n", i */

	status = 
	om$send ( msg = message ACrg_collect.ACget_named_attribute
			(msg, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();
	if (!(status&1)) continue;

	/* -- Get expression value -- */
	status = 
	om$send ( msg = message NDnode.NDgive_structure
			(msg, &ExprSt, md_env ),
		senderid = NULL_OBJID,
		targetid = TempIds[i].objid,
		targetos = TempIds[i].osnum );
	as$status ();
	if (!status&1) continue;

	if ( ExprSt.type == double_type )
	{
	  /*" Attribute value : %f\n", ExprSt.var.root_pm_st.value */
	  if ( AttrSt.desc.type == AC_ATTRIB_DOUBLE )
	    AttrSt.desc.value.att_exp = ExprSt.var.root_pm_st.value;
	}
	else
	{
	  /*" Attribute value : <%s>\n",ExprSt.var.text_st.text_string */
	  if ( AttrSt.desc.type == AC_ATTRIB_TEXT )
	    strcpy ( 	AttrSt.desc.value.att_txt,
			ExprSt.var.text_st.text_string );
	}

	/* -- Update collection -- */
	status = 
	om$send ( msg = message ACrg_collect.ACmod_list_attribute
			(msg,  1, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();

	if( i==END_PREP_INDEX || i==PRESSURE_INDEX )
	{
		if(i==END_PREP_INDEX )
		{
	  		list_num = VR_P_END_COND_LSTNUM;
			strcpy ( AttrSt.name, VR_N_PREP_G_IN );
		}
		else
		{
	  		list_num = VR_P_PRES_CLASS_LSTNUM;
	  		strcpy ( AttrSt.name, VR_N_RATING_G_DB );
		}
	
	  	/*" Attribute name : %s\n", AttrSt.name */
	
	  	status = 
	  	om$send( msg      = message ACrg_collect.ACget_named_attribute
							       ( msg, &AttrSt ),
		   	 senderid = NULL_OBJID,
		     	 targetid = CollId.objid,
		   	 targetos = CollId.osnum );
	  	as$status ();

	        /*" Attribute value : <%s>\n",ExprSt.var.text_st.text_string */
		/*" list_num = %d\n", list_num */

	  	VRget_code_num( msg, VR_PIPING, list_num, ExprSt.var.text_st.text_string,
            		        &code_num, NULL );

		/*"code_num = %d\n", code_num */

	  	AttrSt.desc.value.att_exp = code_num;

  	  	/* -- Update collection -- */
	  	status = 
	  	om$send( msg      = message ACrg_collect.ACmod_list_attribute
	  		  				 ( msg, 1, &AttrSt ),
			 senderid = NULL_OBJID,
		    	 targetid = CollId.objid,
		   	 targetos = CollId.osnum );
  	  	as$status ();
	}
   }/* end update attribute */		

 }/* end loop on expressions */

 return OM_S_SUCCESS;

}/* end VRNozSysLink */

/*-------------------------------------------------------------------*/
/*	function VRHNozSysLink
/*
/* 
/* This function is assigned to a "ACdyn_coll" and links named
/* (hardcoded) specific attributes in the System collection to
/* the expressions templates of this collection.
/*
/* This function returns 	MSSUCC if everything goes allright.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint VRHNozSysLink( 	msg, CollId, Attr, md_env, NbTemp, TempIds, 
			TempState, Context )
			       
IGRlong 	*msg ;		/* O : Return code, MSSUCC or MSFAIL.    */
struct GRid	CollId;		/* I : Collection's object id            */
struct ACrg_coll *Attr;		/* I : Attribute in which this function is
				       stored ???*/
struct GRmd_env	*md_env ; 
IGRint		NbTemp;		/* I : Number of the expression template */
struct GRid	*TempIds;	/* I : List of expression templates */
IGRint		*TempState;	/* I : Compute status of each expression */
struct GRid	Context;	/* I : List of the context of each expression */

/*.VRNozSysLink */
{
 IGRint		i;

 /* There are 5 expressions templates of this collection */
 static IGRchar	*AttrHNames[VRHNbNozAttr] = 
				{ VR_N_TAG_NUMBER_AN,
				  VR_N_SERVICE_AN,
				  VR_N_WIDTH1_DB,
				  VR_N_DEPTH1_DB,
				  VR_N_FLOW_RATE_DB,
				  VR_N_PREPS_G_IN };

 *msg = ND_COMP_SUCC;

 /*" CollId : <%d,%d>\n", CollId.objid, CollId.osnum */
 /*" %d Expressions\n", NbTemp */

 /* -- Loop on expressions -- */
 for ( i=0; i<NbTemp & i<VRHNbNozAttr; i++ )
 {
   /*" Expression : <%d,%d>\n",TempIds[i].objid,TempIds[i].osnum */

   /* -- Update attribute -- */
   if ( TempState[i] != ND_COMP_SAME )
   {
	IGRint			status;
	struct ACrg_coll	AttrSt;
	struct ret_struct	ExprSt;

	/*" ---->Modified  \n" */


	/* -- Get attributes by name -- */

	strcpy ( AttrSt.name, AttrHNames[i] );
	/*" Attribute name : %s\n", AttrSt.name */
	/*" i : %d\n", i */

	status = 
	om$send ( msg = message ACrg_collect.ACget_named_attribute
			(msg, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();
	if (!(status&1)) continue;

	/* -- Get expression value -- */
	status = 
	om$send ( msg = message NDnode.NDgive_structure
			(msg, &ExprSt, md_env ),
		senderid = NULL_OBJID,
		targetid = TempIds[i].objid,
		targetos = TempIds[i].osnum );
	as$status ();
	if (!status&1) continue;

	if ( ExprSt.type == double_type )
	{
	  /*" Attribute value : %f\n", ExprSt.var.root_pm_st.value */
	  if ( AttrSt.desc.type == AC_ATTRIB_DOUBLE )
	    AttrSt.desc.value.att_exp = ExprSt.var.root_pm_st.value;
	}
	else
	{
	  /*" Attribute value : <%s>\n",ExprSt.var.text_st.text_string */
	  if ( AttrSt.desc.type == AC_ATTRIB_TEXT )
	    strcpy ( 	AttrSt.desc.value.att_txt,
			ExprSt.var.text_st.text_string );
	}

	/* -- Update collection -- */
	status = 
	om$send ( msg = message ACrg_collect.ACmod_list_attribute
			(msg,  1, &AttrSt ),
		senderid = NULL_OBJID,
		targetid = CollId.objid,
		targetos = CollId.osnum );
	as$status ();

   }/* end update attribute */		

 }/* end loop on expressions */

 return OM_S_SUCCESS;

}/* end VRHNozSysLink */
/*************************************************************************/

IGRint VRBuildExp( msg, ExpType, ExpName, ExpText, ExpValue,  Expression, MdEnv )
IGRlong 		*msg ;
IGRchar			ExpType;
IGRchar			*ExpName;
IGRchar			*ExpText;
IGRdouble		*ExpValue;
struct	GRid		*Expression;
struct	GRmd_env 	*MdEnv;

/*.VRBuildExp */
{
  IGRlong			status;
  struct	ret_struct	ExprSt;

  *msg = MSSUCC;

  /* ----- Check if expression already exist ----- */
  /*"ExpName = <%s> \n",ExpName*/
  if( ExpName[0] )
  {
	/*| get the ezpression id */
  	status = di$translate ( objname = ExpName,
                       	  	p_objid = &Expression->objid );
  }

  /* ------ If exp exist return its value ------ */
  if( Expression->objid != NULL_OBJID )
  {
	/*| exp exist */
	status = 
	om$send ( msg = message NDnode.NDgive_structure( msg, &ExprSt, MdEnv ),
		senderid = NULL_OBJID,
		targetid = Expression->objid,
		targetos = Expression->osnum );
	as$status ();

	if( ExpType == EXP_DOUBLE && ExprSt.type == double_type )
	{
			*ExpValue = ExprSt.var.root_pm_st.value;
			/*"ExpVal = %f\n", *ExpValue */
	}
	else if( ExpType == EXP_TEXT && ExprSt.type == text_type )
	{
			strcpy( ExpText, ExprSt.var.text_st.text_string );
			/*"ExpVal = %s\n", ExpText */
	}
	else return OM_E_INVARG;

	*msg = MSFAIL;
  }  
  /* ------ If exp doesn't exist create it ------- */
  else
  {
	/* --- Exp type is a string --- */
	if( ExpType == EXP_TEXT )
	{
		/*"ExpText = <%s> \n",ExpText*/
		/* --- When no exp name is given --- */
		if( !ExpName[0])
		{
			status = 
			exp$create ( exp_syntax = ExpText,
               	             	     p_exp_id   = &Expression->objid,
				     osnum      = Expression->osnum,
		              	     p_osnum    = &Expression->osnum,
               	             	     type_rq    = EXP_TEXT );
		}
		/* --- When exp name is given --- */
		else
		{
			status = 
			exp$create ( exp_name   = ExpName,
               	     	     	     exp_syntax = ExpText,
				     osnum      = Expression->osnum,
               	             	     p_exp_id   = &Expression->objid,
		             	     p_osnum    = &Expression->osnum,
               	             	     type_rq    = EXP_TEXT );
		}
	}
	else
	{
		/*"ExpValue = %f \n", *ExpValue*/
		/*| ----- Create double expression ----- */ 
		if( !ExpName[0] )
		{
			IGRchar  expvalue[20];
			__DBGpr_dbl( " The value is " , *ExpValue);
			sprintf( expvalue ,"%lf",*ExpValue) ;
			__DBGpr_str( " The value in string format is ", expvalue);
		/** TR179900392 - Following macro arguments are changed so as to take the text string as the argument */
		/* It can alos be done in other way.Pass the values for depth 
		   and width as text strings in VRInsertNozzle method of 
		   file VRPlNozzlei.I(VRPlNozzle.sl)*/
		   
			status = 
			exp$create ( exp_syntax = expvalue,
               	             	     p_exp_id   = &Expression->objid,
				     osnum      = Expression->osnum,
		              	     p_osnum    = &Expression->osnum,
               	             	     type_rq    = EXP_TEXT);
		}
		else
		{
			status = 
			exp$create ( exp_name   = ExpName,
               	     	     	     exp_value  = *ExpValue,
				     osnum      = Expression->osnum,
               	             	     p_exp_id   = &Expression->objid,
		             	     p_osnum    = &Expression->osnum,
               	             	     type_rq    = ExpType );
			}
	}

  }

  return OM_S_SUCCESS;

}

/*****************************************************************************/

IGRint VRCheckExp( msg,  ExpName, ExpValue, MdEnv )
IGRlong 		*msg ;
IGRchar			*ExpName;
IGRchar			*ExpValue;
struct	GRmd_env 	*MdEnv;

{
  IGRlong		status;
  struct GRid		Expression;
  struct ret_struct	ExprSt;

  Expression.objid = NULL_OBJID;
  Expression.osnum = MdEnv->md_id.osnum;

  /*"Exp Name = <%s>\n", ExpName */

  /* -- Check if expression already exist -- */
  if( ExpName[0] )
  {
  	status = di$translate ( objname = ExpName,
                       	  	p_objid = &Expression.objid );
  }

  if( Expression.objid != NULL_OBJID )
  {
	/*"Expression = %d %d \n", Expression.objid, Expression.osnum */

	/* -- Get expression value -- */
	status = 
	om$send ( msg = message NDnode.NDgive_structure
					( msg, &ExprSt, MdEnv ),
		senderid = NULL_OBJID,
		targetid = Expression.objid,
		targetos = Expression.osnum );
	as$status ();

	if ( ExprSt.type == double_type )
		sprintf(ExpValue, "%f", ExprSt.var.root_pm_st.value);
	else
		strcpy( ExpValue, ExprSt.var.text_st.text_string);

    	/*"ExpValue = <%s> \n", ExpValue */
  }

  return OM_S_SUCCESS;

}


end implementation Root;
