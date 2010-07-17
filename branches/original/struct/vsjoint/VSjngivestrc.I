/* $Id: VSjngivestrc.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjngivestrc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjngivestrc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/04/05  16:14:08  pinnacle
# Post Joint Parents
#
# Revision 1.4  1998/04/02  10:45:02  pinnacle
# Replaced: vsjoint/VSjngivestrc.I for:  by svkadamb for struct
#
# Revision 1.3  1997/12/19  04:03:20  pinnacle
# Replaced: vsjoint/VSjngivestrc.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:52:10  pinnacle
# Replaced: vsjoint/VSjngivestrc.I for:  by svkadamb for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *	     suresh  modification 
 * 04/05/98  ah      Added parent posting attributes
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSjoint ;

// For the smart parent attributes
#include "VDsa.h"
#include "VDbro1.h"
#include "nddef.h"

#include "EMSmsgdef.h"
#include "msmacros.h"
#include "VDweldsym.h"
#include "vswelddef.h"
#include "vsjntmacros.h"
#include "vsjointdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )

extern struct VDweld_gadget_sym  sym_char[];
extern int                       VDread_weld_sym_char();

from ACpretend import ACfind_parent;

/* -----------------------------------------------------
 * Gets posting information for joint parents
 */
IGRstat VSjointGiveParentStructure(TGRid       *jntID, 
				   IGRchar     *attrName, 
				   Tret_struct *attrVal)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   parentID;
  IGRint  parentIND;
  IGRchar parentName[80];
  
  TGRid  *bufID = NULL;
  IGRint  bufCNT;
  
  //printf("Joint %s\n");

  // Which Parent
  if (!strncmp(attrName,"p0_",3)) parentIND = 0;
  else                            parentIND = 1;
  
  // Get List of parents
  sts = om$send(msg = message 
		NDnode.NDget_objects(
				     ND_ROOT | ND_IN_BUF ,
				     NULL,
				     0,
				     &bufID,
				     0,
				     OM_K_MAXINT,
				     &bufCNT),
		senderid = NULL_OBJID,
		targetid = jntID->objid,
		targetos = jntID->osnum);

  if (!(sts & 1)) goto wrapup;
  if (bufCNT < 2) goto wrapup;
  
  // Get specific parent
  parentID = bufID[parentIND];
  
  sts = om$send(msg = message 
		ACpretend.ACfind_parent(&parentID, NULL, NULL ),
		senderid = NULL_OBJID,
		targetid = parentID.objid ,
		targetos = parentID.osnum);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  //vdbro$PrintObject(objID = &parentID);
  
  // Map names
  *parentName = 0;
  if (!strcmp(attrName+3,"comp_seqno"  )) strcpy(parentName,VDSA_KEY_SA_PDM_SEQNO);
  if (!strcmp(attrName+3,"assembly_cat")) strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
  if (!strcmp(attrName+3,"assembly_nam")) strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
  if (!strcmp(attrName+3,"assembly_ver")) strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
  if (*parentName == 0) goto wrapup;
  
  sts = vdsa$GetStruct(objID = &parentID, name = parentName, rs = attrVal);
  if (sts & 1) retFlag = 1;
  
  //printf("Parent %d %s\n",retFlag,parentName);
  
wrapup:

  // Free bufID ???

  return retFlag;
}

/*----------------------------------------------------------------------------*/
method	ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long			sts,		/* OM completion code	*/
				msg ;		/* Return status	*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSjointAttr		joint ;		/* My joint attributes	*/

	enum {
		getAttrStr,	/* Use GRvg.GRgetattr		*/
		getAttrDbl,
		getAttrWAC,
		getAttrWAP,
		getAttrWAPos,
		getAttrWAF,
		getAttrWAI,
		getAttrWAS,
		getCodeDesc,
		getProcDesc,
		getSideDesc,
		getPosDesc,
		getNothing,	/* Don't do anything		*/
		wrtMsg		/* Send to self wrt message	*/
	} msgType ;
	char			*frStr = NULL ;
	double			*frDbl = NULL ;

	SetProc( VSjoint_ACgive_structure ) ; Begin ; __DBGpr_me() ;

	__DBGpr_str( "foot", attrName ) ;

	myAttr.specific = (void *) &joint ;

	/* Check for parent posting attributes */
	if (!strncmp(attrName,"p0_",3) || !strncmp(attrName,"p1_",3)) {

	  TGRid jntID;
	  
	  jntID.objid	= my_id ;
	  jntID.osnum	= OM_Gw_current_OS ;

	  sts = VSjointGiveParentStructure(&jntID, attrName, attrVal);
	  if (sts & 1) {
	    msg = MSSUCC ;
	    sts = OM_S_SUCCESS ;
	  }
	  else {
	    msg = MSFAIL;
	  }
	  
	  goto wrapup;
	}
	
	/*
	 * Get value for "virtual foot".
	 */
	       if(( EQ_STRING( attrName, VS_K_jnWldCodAttr ) ) || 
	          ( EQ_STRING( attrName, VS_D_jnWldCodAttr ) ) ) {

		myAttr.Iwant	= VS_m_WeldAttr ;
		msgType		= getAttrWAC ;

	} else if(( EQ_STRING( attrName, VS_K_jnWldPrcAttr ) ) ||
		  ( EQ_STRING( attrName, VS_D_jnWldPrcAttr ) ) ) {  
		myAttr.Iwant	= VS_m_WeldAttr ;
		msgType		= getAttrWAP ;

	} else if(( EQ_STRING( attrName, VS_K_jnWldInfAttr ) ) || 
	 	  ( EQ_STRING( attrName, VS_D_jnWldInfAttr ) ) ) {

		myAttr.Iwant	= VS_m_WeldAttr ;
		msgType		= getAttrWAI ;

	} else if(( EQ_STRING( attrName, VS_K_jnWldSidAttr ) ) || 
		  ( EQ_STRING( attrName, VS_D_jnWldSidAttr ) ) ) {

		myAttr.Iwant	= VS_m_WeldAttr ;
		msgType		= getAttrWAS ;

	} else if(( EQ_STRING( attrName, VS_K_jnAllwncAttr ) ) || 
		  ( EQ_STRING( attrName, VS_D_jnAllwncAttr ) ) ) {

		myAttr.Iwant	= VS_m_Allowance ;
		msgType		= getAttrDbl ;
		frDbl		= &joint.allowance ;

	} else if(( EQ_STRING( attrName, VS_K_jnGrvAngAttr ) ) || 
		  ( EQ_STRING( attrName, VS_D_jnGrvAngAttr ) ) ) {

		myAttr.Iwant	= VS_m_GrooveAngle ;
		msgType		= getAttrDbl ;
		frDbl		= &joint.grooveAngle ;

	} else if( EQ_STRING( attrName, VS_K_jnPitchAttr ) ) {

		myAttr.Iwant	= VS_m_Pitch ;
		msgType		= getAttrDbl ;
		frDbl		= &joint.pitch ;

	} else if(( EQ_STRING( attrName, VS_K_jnIncrLnAttr ) ) || 
		  ( EQ_STRING( attrName, VS_D_jnIncrLnAttr ) ) ) {

		myAttr.Iwant	= VS_m_IncrLength ;
		msgType		= getAttrDbl ;
		frDbl		= &joint.incrLength ;

	} else if(( EQ_STRING( attrName, VS_K_jnUsrSymAttr ) ) || 
		  ( EQ_STRING( attrName, VS_D_jnUsrSymAttr ) ) ){

		myAttr.Iwant	= VS_m_UsrSymbol ;
		msgType		= getAttrStr ;
		frStr		= joint.usrSymbol ;

	} else if( EQ_STRING( attrName, VS_K_jnWldPosAttr ) ) {

		myAttr.Iwant    = VS_m_AddWeldAttr ;
		msgType		= getAttrWAPos ;

	}  else if( EQ_STRING( attrName, VS_K_jnShrnkAttr ) ) {

		myAttr.Iwant    = VS_m_Shrinkage ;
		msgType		= getAttrDbl;
		frDbl		= &joint.shrinkage ;

	}  else if( EQ_STRING( attrName, VS_K_jnFieldWeld ) ) {

		myAttr.Iwant    = VS_m_AddWeldAttr ;
		msgType		= getAttrWAF;

	} else if( EQ_STRING( attrName, VS_K_jnWldSizAttr ) ) {

		myAttr.Iwant	= VS_m_Size ;
		msgType		= getAttrDbl ;
		frDbl		= &joint.size ;

	} else if( EQ_STRING( attrName, VS_K_jnWldLenAttr ) ) {
		VSintegral	mp ;

		sts = om$send(	msg	= message VSpart.VSgetMassProperties(
							&msg, myEnv, &mp ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "VSpart.VSgetMassProperties", wrapup ) ;

		msgType				= getNothing ;
		attrVal->var.root_pm_st.value	= mp.dims[0] ;
		attrVal->type			= double_type ;

	} else if( EQ_STRING( attrName, VS_K_jnWldCodeDesc) ) {
		msgType = getCodeDesc ;
	} else if( EQ_STRING( attrName, VS_K_jnWldProcDesc ) ) {
		msgType = getProcDesc ;
	} else if( EQ_STRING( attrName, VS_K_jnWldSideDesc ) ) {
		msgType = getSideDesc ;
	} else if( EQ_STRING( attrName, VS_K_jnWldPosDesc ) ) {
		msgType = getPosDesc ;
	} else  {
		/*
		 * Use ancestor class's method.
		 */
		msgType		= wrtMsg ;
	}

	switch( msgType ) {

	case getAttrStr	:
	case getAttrDbl :
	case getAttrWAC :
	case getAttrWAP :
	case getAttrWAPos:
	case getAttrWAF:
	case getAttrWAI :
	case getAttrWAS :
	case getCodeDesc :
	case getProcDesc :
	case getSideDesc :
	case getPosDesc :

		sts = om$send(	msg	= message GRvg.GRgetattr(
						&msg, (char *) &myAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;

		switch( msgType ) {
			case getCodeDesc : {
				int	index = 0,
					cnt1 = 0;
				char    buffer[DESC_SIZE] ;

				index = (int)joint.weldAttr.code ;

				sts = VDread_weld_sym_char( &cnt1 );

				if( !(sts & 1 && cnt1 ) ) {
				    ex$message( msgnumb     = index,
					        buff        = buffer ) ;
				    strcpy( attrVal->var.text_st.text_string,
						buffer );
				} else {
				    strcpy( attrVal->var.text_st.text_string,
						sym_char[index].desc );
				}
				attrVal->type = text_type ;
				}
				break ;

			case getProcDesc : {
				int	index = 0,
					cnt1 = 0;
				char    buffer[DESC_SIZE] ;
				char 	**procList = NULL ;

				index = (int)joint.weldAttr.process ;
				/*
         			 * Retrieve list of weld processes from 
				 * an ASCII file
         			 */
        			sts = vs$getWeldProcASCII ( msg   = &msg,
                                        		    count = &cnt1,
                                        		    list  = &procList );
				if( !(sts & msg & 1 && cnt1 ) ) {
					long 	*list = NULL  ;
					int	count ;
				    /*
				     * list not to be freed 
				     */
				    sts = vs$getWeldProcesses(
							msg  	= &msg,
                                                	count   = &count,
                                                	list    = &list ) ;
				    if( ! list )  goto wrapup ;
				    ex$message( msgnumb     = list[index],
					        buff        = buffer ) ;
				    strcpy( attrVal->var.text_st.text_string,
						buffer );
				} else {
				    strcpy( attrVal->var.text_st.text_string,
						procList[index] );
				}
				attrVal->type = text_type ;
				VSfreeList( cnt1, procList);
				}
				break ;

			case getSideDesc : {
				char	*wldSide = NULL ;
				switch( (int)joint.weldAttr.side ) {
					case VS_K_wldLeftSide :
						wldSide = "left" ;
						break ;
					case VS_K_wldRightSide:
						wldSide = "right" ;
						break ;
					case VS_K_wldBothSides:
						wldSide = "both" ;
						break ;
				}
				strcpy( attrVal->var.text_st.text_string,
					wldSide );
				attrVal->type = text_type ;
				}
				break ;

			case getPosDesc : {
				char	*wldPos = NULL ;
				switch( (int)joint.addWldAttr.position ) {
					case VS_K_wldFloorPos :
						wldPos = "floor" ;
						break ;
					case VS_K_wdlHorzPos :
						wldPos = "horizontal" ;
						break ;
					case VS_K_wldCeilPos:
						wldPos = "ceiling" ;
						break ;
					case VS_K_wldVertPos:
						wldPos = "vertical" ;
						break ;
				}
				strcpy( attrVal->var.text_st.text_string,
					wldPos );
				attrVal->type = text_type ;
				}
				break ;

			case getAttrStr	:
				__DBGpr_com( "String" ) ;
				strcpy( attrVal->var.text_st.text_string,
					frStr ) ;
				attrVal->type = text_type ;
				break ;

			case getAttrDbl :
				attrVal->var.root_pm_st.value = *frDbl ;
				attrVal->type = double_type ;
				break ;

			case getAttrWAC :
			attrVal->var.root_pm_st.value = joint.weldAttr.code ;
			attrVal->type = double_type ;
			break ;

			case getAttrWAP :
			attrVal->var.root_pm_st.value = joint.weldAttr.process ;
			attrVal->type = double_type ;
			break ;

			case getAttrWAPos :
			attrVal->var.root_pm_st.value = joint.addWldAttr.position;
			attrVal->type = double_type ;
			break ;

			case getAttrWAF :
			attrVal->var.root_pm_st.value =joint.addWldAttr.fieldweld;
			attrVal->type = double_type ;
			break ;

			case getAttrWAI :
			attrVal->var.root_pm_st.value = joint.weldAttr.info ;
			attrVal->type = double_type ;
			break ;

			case getAttrWAS :
			attrVal->var.root_pm_st.value = joint.weldAttr.side ;
			attrVal->type = double_type ;
			break ;
		}
		break ;

		case wrtMsg	:
		__DBGpr_com( "wrt message" ) ;
		sts = om$send(	msg	= message VSfeature.ACgive_structure(
								ok,
								notUsed,
								attrName,
								attrVal,
								myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		msg = *ok ? MSSUCC : MSFAIL ;
		break ;

		case getNothing	:
		msg = MSSUCC ;
		sts = OM_S_SUCCESS ;
		break ;

		default		: vs$inv_arg( msg = &msg ) ;
	}		
	wrapup :
		End
		*ok = ( msg & 1 ) != 0 ;
		return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;




