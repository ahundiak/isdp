/* $Id $  */

/*************************************************************************
 * I/VDS
 *
 * File:        src/vdmisc/VDexpvalue.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      02/12/00   Jayadev      VDexpNodeEvaluate() added for COz_evalExp.u 
 *	03/23/00   Adz		Invalid Free.
 *************************************************************************/
/*
	I/VDS	Copy
*/
class implementation expression ;

#include <stdio.h>
#include "vdtr_macros.h"
#include "VDexp.h"
#include "VDmem.h"
/*----------------------------------------------------------------------------*/
long VD_expValue( exp_id, exp_os, p_value )

OM_S_OBJID	exp_id ;
OMuword		exp_os ;
double		*p_value ; {

	long			sts,
				msg ;
	struct ret_struct	rs ;

	sts = om$send(	msg	= message NDnode.NDgive_structure(
							&msg, &rs, NULL ),
			targetid= exp_id,
			targetos= exp_os,
			senderid= exp_id ) ;
			
	*p_value = rs.var.root_pm_st.value ;
	
	return sts ;

} /* VD_expValue */
/*----------------------------------------------------------------------------*/
long VD_createExp( name, value, osnum, p_objid )

char		*name ;
double		value ;
OMuword		osnum ;
OM_S_OBJID	*p_objid ; {

	long		sts ;
	extern OMuword	OPP_expression_class_id,
			OPP_Gexp_class_id ;

	sts = om$construct(	classid	= name	? OPP_expression_class_id
						: OPP_Gexp_class_id,
				osnum	= osnum,
				p_objid	= p_objid ) ;
	if( sts & 1 ) {
		char		syntax[200] ;
		short		rc ;

		sprintf( syntax, "%20.9lf", value ) ;
		sts = om$send(	msg	= message expression.create(	name,
									syntax,
									&rc ),
				senderid= *p_objid,
				targetid= *p_objid,
				targetos= osnum ) ;
		if( !( sts & 1 & rc ) ) {
			om$send(msg	= message Root.delete( 0 ),
				targetid= *p_objid,
				targetos= osnum,
				senderid= *p_objid ) ;
			sts = OM_W_ABORT ;
		}
	}
	return sts ;

} /* VD_createExp */
/*----------------------------------------------------------------------------*/
long VD_createTextExp( name, value, osnum, p_objid )

char		*name ;
char		*value ;
OMuword		osnum ;
OM_S_OBJID	*p_objid ; {

	long		sts ;
	extern OMuword	OPP_text_exp_class_id,
			OPP_Gtext_exp_class_id ;

	sts = om$construct(	classid	= name	? OPP_text_exp_class_id
						: OPP_Gtext_exp_class_id,
				osnum	= osnum,
				p_objid	= p_objid ) ;
	if( sts & 1 ) {
		short		rc ;

		sts = om$send(	msg	= message expression.create(	name,
									value,
									&rc ),
				senderid= *p_objid,
				targetid= *p_objid,
				targetos= osnum ) ;
		if( !( sts & 1 & rc ) ) {
			om$send(msg	= message Root.delete( 0 ),
				targetid= *p_objid,
				targetos= osnum,
				senderid= *p_objid ) ;
			sts = OM_W_ABORT ;
		}
	}
	return sts ;

} /* VD_createTextExp */
/*----------------------------------------------------------------------------*/
/* Expression evaluation routine for all the nodes under a tree */

IGRint VDexpNodeEvaluate(struct GRid treeNode,IGRchar *expName)
{
  IGRlong               msg, sts, bad_cnt,isConsumed ;
  IGRchar		nodeInfo[1024];
  GRclassid	        classid[1];
  struct GRid           rootNode, *stageNodeList;
  struct GRobj_env      expNode;
  IGRint 		stageNodeCount, i, j;
  struct ACrg_coll      expColl;
  IGRboolean            expFlag; 
  
  stageNodeList  = NULL;
  stageNodeCount = 0;
  sts            = 0;
  
  if(expName == NULL) goto wrapup;
  if(expName[0] == '\0') goto wrapup;
  
  UI_status( "Expression evaluation for children of a tree Node" );
  sleep(1);  
  // check if the supplied tree node is appropriate  - TBD
  
  rootNode = treeNode;
  
  // get all the children of this root node 
  sts = vd$trget_nodes( nodeID     = &rootNode,
			lookupType = VDTR_FIND_ALL_NODE,
			outID      = &stageNodeList,
			cnt        = &stageNodeCount ) ;
  if((!sts) || (!stageNodeList) || (!stageNodeCount))
  {
    UI_status(" No nodes under the current one ");
    goto wrapup;
  }
  
  // loop on all the nodes to evaluate the expressions
  for(i = 0; i < stageNodeCount; i = i + 1)
  {
    
    expNode.obj_id = stageNodeList[i];
    expFlag = 0;
    // evaluate the expression for each node
    
    vd$exp_evaluate(flag    = &expFlag,   
		    expName = expName,
		    object  = &expNode, 
		    rgColl  = &expColl); 

    strcpy(nodeInfo,"evaluation");
    vd$trget_getNodePrint(nodeID = &expNode.obj_id,
			  title  = nodeInfo);


    if(expFlag) printf("\nexpression[%s] is TRUE for above node",expName);
    else printf("\nexpression[%s] is FALSE for above node ",expName);
    
    printf("\n#########################\n"); 
  } 
 wrapup:
  _FREE(stageNodeList);
  
  UI_status( "Done" );
  sleep(1);  
  
  return 1;
}

end implementation expression ;

