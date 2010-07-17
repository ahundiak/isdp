/* $Id: VSgetchildrn.I,v 1.3 2001/11/17 18:09:52 ylong Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsmisc/VSgetchildrn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSgetchildrn.I,v $
 *  Revision 1.3  2001/11/17 18:09:52  ylong
 *  fix for TR#MP5825
 *
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      11/17/01    Jayadev     Header added - fix for TR#MP5825 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation NDnode ;

#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "EMSutlmacros.h"
#include "VDchn.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchanobj.h"
#include "vsstrngproto.h"

extern OMuword		OPP_ACpretend_class_id,
			OPP_ACpretendin_class_id, 
                        OPP_VSfeature_class_id, 
                        OPP_ACconst_class_id, 
                        OPP_nci_macro_class_id ;

from VSfeature import   VStrackDescendent;
extern OM_S_CHANSELECT  AS_notification;
/*----------------------------------------------------------------------------*/
static int VSobjCmp( O1, O2 )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*O1,
	*O2 ; {

	const struct GRid	*o1 = (const struct GRid *) O1,
				*o2 = (const struct GRid *) O2 ;

	       if( o1->osnum <  o2->osnum )		return -1 ;
	  else if( o1->osnum == o2->osnum ) {
		     if( o1->objid <  o2->objid )	return -1 ;
		else if( o1->objid == o2->objid )	return  0 ;
		else					return  1 ;
	} else						return  1 ;
		
} /* VSobjCmp */
/*----------------------------------------------------------------------------*/
static void VSrmDupObjsInList( count, list, newcount )

int		count,
		*newcount ;
struct GRid	*list ; {

	int		i ;

	if( count == 1 ) {
		*newcount = 1 ;
	} else {
		qsort( list, (unsigned) count, sizeof *list, VSobjCmp ) ;

		*newcount = 1 ;
		for( i = 1 ; i < count ; i++ ) {
			if( !IF_EQ_GRID( list[i-1], list[i] ) ) {
				list[(*newcount)++] = list[i] ;
			}
		}
	}

} /* VSrmDupObjsInList */
/*----------------------------------------------------------------------------*/
static long VSgetListeningPretends( msg, notifier, count, list )

long			*msg ;
const struct GRid	*notifier ;
int			*count ;
struct GRid		**list ; {

	/*
	 * Get all ACpretendin objects on the notifier's notification
	 * channel.
	 */
	long		sts ;
	int		i,
			cnt ;
	struct GRid	*listeners = NULL ;

	*list = NULL ; *count = 0 ;

	{ OM_S_CHANSELECT notification ;
	  ems$make_chanselect( chan_label    = GRnotify_notification,
			       chan_selector = &notification ) ;
	  sts = VS_GetChanObjWithMalloc( notifier,
					 &notification,
					 &cnt,
					 &listeners ) ;
	}
	if( !sts ) {
		/*
		 * Not a notifier ? (eg. ASsources are not notifiers...).
		 */
		*msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}

	for( i = 0 ; i < cnt ; i++ ) {
		if( vs$is_ancestry_valid(
				object	= listeners + i,
				classid	= OPP_ACpretendin_class_id ) ) {
			(*count)++ ;
		} else {
			listeners[i].objid = NULL_OBJID ;
		}
	}

	/*
	 * Shrink list.
	 */
	if( *count ) {

		int j = 0 ;
		for( i = 0 ; i < cnt ; i++ ) {
			if( !IF_NULL_OBJID( listeners[i].objid ) ) {
				listeners[j++] = listeners[i] ;
			}
		}
	} else {
		if( cnt ) _FREE( listeners ) ; listeners = NULL ;
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
	*list	= listeners ;

	wrapup :
		return sts ;
	
} /* VSgetListeningPretends */
/*----------------------------------------------------------------------------*/
long VSgetChildren( msg, object, count, list )

long			*msg ;
const struct GRid	*object ;
int			*count ;
struct GRid		**list ; {

	/*
	 * Gets the two types of children.
	 * 1) Those in the same OS as `object' on the to-children channel.
	 * 2) Those in another OS: ACpretendin's on the notification channel.
	 */

	long		sts ;
	struct GRid	*sameOSchildren,
			*othrOSchildren ;
	int		sameOScount,
			othrOScount ;

	sts = om$send(	msg	= message NDnode.NDget_objects(
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&sameOSchildren,
						/* from = */ 0,
						/* to   = */ OM_K_MAXINT,
						&sameOScount ),
			senderid= object->objid,
			targetid= object->objid,
			targetos= object->osnum ) ;	
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	sts = VSgetListeningPretends(	msg,
					object,
					&othrOScount,
					&othrOSchildren ) ;
	__CheckRC( sts, *msg, "VSgetListeningPretends", wrapup ) ;

	*count = sameOScount + othrOScount ;

	if( *count ) {
		int	i, j ;

		if( !( *list = _MALLOC( *count, struct GRid ) ) ) {
			*count = 0 ;
			vs$mem_fail() ;
		}

		i = 0 ;
		for( j = 0 ; j < sameOScount ; j++ ) {
			(*list)[i++] = sameOSchildren[j] ;
		}
		for( j = 0 ; j < othrOScount ; j++ ) {
			(*list)[i++] = othrOSchildren[j] ;
		}
		if( othrOScount ) _FREE( othrOSchildren ) ;
	}

	wrapup :
		return sts ;

} /* VSgetChildren */
/*----------------------------------------------------------------------------*/
long VSgetChildrenGoThruPretends( msg, object, count, list )

long			*msg ;
const struct GRid	*object ;
int			*count ;
struct GRid		**list ; {

	long		sts ;
	struct GRid	*clist,
			**glist,
			*buffer ;
	int		ccnt,
			*gcnt,
			i,
			j,
			k,
			total ;

	*list = clist = NULL ; glist = NULL ; gcnt = NULL ; *count = 0 ;

	sts = VSgetChildren( msg, object, &ccnt, &clist ) ;
	__CheckRC( sts, *msg, "VSgetChildren", wrapup ) ;

	if( !ccnt ) { *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ; }

	if( !( glist = _CALLOC( ccnt, struct GRid * ) ) ) vs$mem_fail() ;
	if( !( gcnt  = _CALLOC( ccnt, int           ) ) ) vs$mem_fail() ;

	total = 0 ;
	for( i = 0 ; i < ccnt ; i++ ) {
		if( vs$is_ancestry_valid(
					object	= clist + i,
					classid	= OPP_ACpretend_class_id ) ) {
			sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
							NULL,
							0,
							&buffer,
							/* from */ 0,
							/* to   */ OM_K_MAXINT,
							gcnt + i ),
					senderid= clist[i].objid,
					targetid= clist[i].objid,
					targetos= clist[i].osnum ) ;
			if( !( sts & 1 ) ) goto wrapup ;
			if( gcnt[i] ) {
				/*
				 * Count in pretend's children but not pretend
				 * itself.
				 */
				glist[i] = (struct GRid *) VSmemdup( buffer,
						 gcnt[i] * sizeof *buffer ) ;
				total += gcnt[i] ;
			} else {
				/*
				 * Childless pretend: count it out.
				 */
				gcnt[i]	= -1 ;
				glist[i]= NULL ;
			}
		} else {
			total++ ;
		}
	}

	if( !total ) {
		*count = 0 ; sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}
	if( !( *list = _MALLOC( total, struct GRid ) ) ) vs$mem_fail() ;

	j = 0 ;
	for( i = 0 ; i < ccnt ; i++ ) {
		if( glist[i] ) {
			buffer = glist[i] ;
			for( k = 0 ; k < gcnt[i] ; k++ ) {
				if( j >= total ) {
					printf( "VSgetChildren buffer overflow\n" ) ;
				}
				(*list)[j++] = buffer[k] ;
			}
		} else if( gcnt[i] != -1 ) {
			if( j >= total ) {
				printf( "VSgetChildren buffer overflow\n" ) ;
			}
			(*list)[j++] = clist[i] ;
		}
	}
	/*
	 * Going through pretends, we may have obtained the same object twice,
	 * therefore remove multiplicated objects.
	 */
	VSrmDupObjsInList( total, *list, &total ) ;

	*count	= total ;
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( clist ) ;
		_FREE( gcnt  ) ;
		if( glist ) {
			for( i = 0 ; i < ccnt ; i++ ) {
				_FREE( glist[i] ) ;
			}
			_FREE( glist ) ;
		}
		if( !( sts & 1 & *msg ) ) {
			_FREE( *list ) ; *list = NULL ; *count = 0 ;
		}
		return sts ;

} /* VSgetChildrenGoThruPretends */
/*----------------------------------------------------------------------------*/
long VSfindChildByType(	const struct GRid	*target,
			OMuword			classId,
			struct GRid		*child ) {

	long		sts ;
	long		msg ;
	int		count = 0 ;
	struct GRid	*list = NULL ;

	child->objid = NULL_OBJID ;

	sts = VSgetChildrenGoThruPretends( &msg, target, &count, &list ) ;

	if( sts & 1 & msg ) {
	  int i ; 

	  for( i = 0 ; i < count ; i++ ) {
	     if( vs$is_ancestry_valid(	object	= list + i,
	   				classid	= classId ) ) {
	       *child = list[i] ; break ;
	     }
	  }
	  if( count ) _FREE( list ) ;
	}

	return sts ;

} /* VSfindChildByType */
/*----------------------------------------------------------------------------*/
/*
 * Given a curve object, this routine navigates through the dependencies and
 * gets all the feature children of the owner macro holding this curve
 */
IGRint VSgetFeatChildrenOfMacro(
                                struct GRid	curve,
  			        struct GRid	**featureChild,
			        IGRint		*childCnt 
                               )
{
  IGRint                retFlag = 0;
  struct GRid           owner, super_owner;
  IGRlong               msg, sts;
  IGRint                nbChild,i, featureCnt;
  struct GRid           *children, *featureObjs, pretend;
  OM_S_OBJECT_LINKAGE   *child;
  OMuint                count; 

  *childCnt     = 0;
  *featureChild = NULL; 
  owner.objid   = NULL_OBJID;
  pretend.objid = NULL_OBJID;
  nbChild       = 0;
  child         = NULL ;
  children      = NULL ;
  count         = 0;
  featureCnt    = 0;
  featureObjs   = NULL ;
 
  // check if an owner exists 
  vdchn$Get2(objID  = &curve,
             chnIDx = VDCHN_IDX_TO_OWNERS,
             nth    = 0,
             outID  = &owner );
  if(owner.objid == NULL_OBJID)
  {
    __DBGpr_obj("owner doesnot exist for",curve);
    goto check_notify; 
  }
  else __DBGpr_obj("owner ",owner);
  
  __DBGpr_obj("curve ",curve);
  __DBGpr_obj("owner ",owner);
  
  if((vs$is_ancestry_valid( object  = &owner,
			    classid = OPP_ACconst_class_id) != OM_S_SUCCESS) &&
     (vs$is_ancestry_valid( object  = &owner,
                            classid = OPP_nci_macro_class_id)!= OM_S_SUCCESS ))
  {
    __DBGpr_com("owner not an macro");
    goto wrapup; 
  }
  
  sts = VSgetChildrenGoThruPretends( &msg,
				     &owner,
				     &nbChild,
				     &children ) ; 
  if(!(sts&msg&1) || (nbChild == 0) || (children == NULL))
  {
    __DBGpr_obj("child donot exist for owner",owner);

    // goto the super_owner macro and get the children
    super_owner.objid = NULL_OBJID;
    vdchn$Get2(objID  = &owner,
	       chnIDx = VDCHN_IDX_TO_OWNERS,
	       nth    = 0,
	       outID  = &super_owner );
    if(super_owner.objid == NULL_OBJID)
    {
      __DBGpr_com("super_owner doesnot exist");
      goto wrapup; 
    }
    else __DBGpr_obj("super_owner ",super_owner);

    __DBGpr_obj("curve ",curve);
    __DBGpr_obj("owner ",owner);
    __DBGpr_obj("super_owner ",super_owner);

        
    if((vs$is_ancestry_valid( object  = &super_owner,
			      classid = OPP_ACconst_class_id)!=OM_S_SUCCESS)) 
    {      
      __DBGpr_com("super_owner not an ACconst");
      goto wrapup;      
    }
    if(children) free(children);
    nbChild = 0;
    sts = VSgetChildrenGoThruPretends( &msg,
				       &super_owner,
				       &nbChild,
				       &children ) ; 
    if(!(sts&msg&1) || (nbChild == 0) || (children == NULL))
    {
      __DBGpr_com("super_owner doesnot have children");
      goto wrapup;       
    }
    else
    {
      goto fill_list;
    }
  }
  else
  {
    goto fill_list;
  }
  
  
 check_notify:
  /*
   * check if there is a listener 
   * The below call is failing !!! 
   *
   vdchn$Get2(objID    = &curve,
   //chnIDx = VDCHN_IDX_NOTIFICATION,
   chnName  = VDCHN_NAME_NOTIFICATION,
   nth      = 0,
   outID    = &pretend );
   __DBGpr_obj("pretend ",pretend);
   */
  // Doing it the hard way
  nbChild = 0;
  sts  = om$get_channel_count(objid      = curve.objid,
			      osnum        = curve.osnum,
			      p_chanselect = &AS_notification,
			      count        = &count);
  
  if(count == 0)
  {
    __DBGpr_obj("No object to notify for ",curve);
    goto wrapup;
  }
  child =(OM_S_OBJECT_LINKAGE *) alloca
                                  (count * sizeof(OM_S_OBJECT_LINKAGE));
  sts = om$get_channel_objects( objid        = curve.objid,
				osnum        = curve.osnum,
				p_chanselect = &AS_notification,
				list         = child,
				size         = count,
				count        = &count );
  pretend.objid = child[0].S_objid; 
  pretend.osnum = child[0].osnum;
  
  nbChild = 0;
  sts = VSgetChildren(&msg, &pretend, &nbChild, &children);
  if(!(sts&msg&1) || (nbChild == 0) || (children == NULL))
  {
    __DBGpr_com("pretend doesnot have children");
    goto wrapup;       
  }
  
 fill_list:
  featureObjs = _MALLOC(nbChild,struct GRid);
  
  for( i=0; i<nbChild; i++ ) {
    
    if( vs$is_ancestry_valid( object  = &children[i],
			      classid = OPP_VSfeature_class_id )!= OM_S_SUCCESS)
      continue ;
    
    featureObjs[featureCnt] = children[i];
    featureCnt = featureCnt ++;
    __DBGpr_obj("child Feature ",children[i]);
  }
  
  if(featureCnt == 0)
  {
    __DBGpr_com("No feature children for the Macro");
    goto wrapup;
  }
  
  // fill in the output list
  
  *childCnt = featureCnt;
  *featureChild = _MALLOC(featureCnt,struct GRid);
  for( i=0; i<featureCnt; i++ ) (*featureChild)[i] = featureObjs[i];

  //Done
  retFlag = 1;
wrapup:
  _FREE(child);
  _FREE(children);
  _FREE(featureObjs);
  return retFlag;
}
/*************************************************************************/
/* This function takes in a curve and a feature object and checks if the
 * curve has already been processed on the feature and retSts = 1 if so 
 * This has been done for TR# MP5412; the feature object is a global variable
 * set from the VSlocate command
 */   
IGRint VScheckCurveonFeature(
                             struct GRid	curve,
                             struct GRid        VSlocatedObj,
                             IGRlong		*retSts 
                            )
{
  IGRint       i, sts, retFlag;
  IGRint       parent_cnt, childCnt;
  IGRlong      sts1;
  struct GRid  *childList, *parent_list;
  
  *retSts     = 0; 
  retFlag     = 0;
  childCnt    = 0; 
  parent_cnt  = 0; 
  childList   = NULL;
  parent_list = NULL;
  
  if( vs$is_ancestry_valid( object  = &VSlocatedObj,
                 	    classid = OPP_VSfeature_class_id )!= OM_S_SUCCESS)
  {
    __DBGpr_com("Located Object not a feature ");    
    goto wrapup;
  }
  
  __DBGpr_obj("VSlocatedObj ",VSlocatedObj);
  
  sts =  VSgetFeatChildrenOfMacro(curve, &childList, &childCnt);
  if((!(sts&1)) || (childList == NULL) || (childCnt == 0))
  {
    __DBGpr_obj("VSgetFeatChildrenOfMacro failed for ",curve);
    goto wrapup;
  } 
  
  /* 
   * check to see if there is any relation b/w the located object
   * with any of the objects in the children list
   */
  for(i = 0; i<childCnt; i++)
  {
    _FREE(parent_list);
    parent_cnt = 0;
    sts1 = om$send( msg = message VSfeature.VStrackDescendent(
                                  &VSlocatedObj, &parent_cnt, &parent_list ),
                    senderid = NULL_OBJID,
                    targetid = childList[i].objid,
                    targetos = childList[i].osnum  ); 
    if(!(sts1&1)) continue; 
    
    if(parent_cnt == 0)
    {
      // see if the located object is this feature itself
      if((VSlocatedObj.objid == childList[i].objid) &&
         (VSlocatedObj.osnum == childList[i].osnum))
      {
        __DBGpr_obj("Related feature object ",childList[i]);
        *retSts = 1;
        retFlag = 1;
        goto wrapup;
      }
    }
    else
    {
      __DBGpr_obj("Related feature object ",childList[i]);
      *retSts = 1;
      retFlag = 1;
      goto wrapup;
    }
  }
  
  //Done
  retFlag = 1;
 wrapup:
  _FREE(childList);
  _FREE(parent_list);
  return retFlag;
}
end implementation NDnode ;
