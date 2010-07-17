/* $Id: VSelmsonsupp.I,v 1.1.1.1 2001/01/04 21:10:50 cvs Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsmisc/VSelmsonsupp.I
*
* Description: This file has the function VSgetElementsOnSupport which gets 
*              all the elements on the support object
*
* Dependencies:
*
* Revision History:
*      $Log: VSelmsonsupp.I,v $
*      Revision 1.1.1.1  2001/01/04 21:10:50  cvs
*      Initial import to CVS
*
# Revision 1.2  1999/07/28  14:58:14  pinnacle
# tr179900593
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      07/23/99  Jayadev The following function was added for TR179900593
*                        VSGetTwistedStiffeners()
*                        Some changes are made in VSgetElementsOnSupport to
*                        allow the command "Select stiffeners on Plate" to 
*                        identify twisted stiffeners
***************************************************************************/
class implementation VSfeature ;

#include <string.h>		/* For memcpy()	*/
#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDchn.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
extern GRclassid OPP_VStwsBeam_class_id;

IGRstat VSGetTwistedStiffeners(TGRid *support, TVDvlaID *twsVla)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,j,k,l;
  
  TGRobj_env supportOE;
  TVDvlaID   axisVla;
  TGRid      axisID;

  TGRobj_env axisOE;
  TVDvlaID   pretendVla;
  TGRid      pretendID;
  
  TGRid twsID;
  TGRid twsIDx;
  
  // Init
  VDahGetObjectEnv(support,&supportOE);
  if (supportOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get all the axis objects
  vdvla_id$Construct(vla = &axisVla);
  
  vdchn$GetChildrenByClass(objOE     = &supportOE,
			   className = "VSbeamAxis",
			   vla       = &axisVla);
  
  // loop on the beam axes to get the twisted stiffener objs 
  for(i=0;vdvla_id$GetAt(vla = &axisVla,nth = i,objID = &axisID);i++) {
    
    // Not sure if this is quite right
    VDahGetObjectEnv(&axisID,&axisOE);

    // Get all pretends from the axis
    vdvla_id$Construct(vla = &pretendVla);
    vdchn$GetChildrenByClass(objOE     = &axisOE,
			     className = "ACpretend",
			     vla       = &pretendVla);
    
    
    // Cycle through pretends
    for(j = 0; vdvla_id$GetAt(vla = &pretendVla,nth = j,objID = &pretendID); j++) {
      
      // Cycle through each child
      for(k = 0; vdchn$Get2(objID  = &pretendID,
			    chnIDx = VDCHN_IDX_CHILDREN,
                            nth    = k,              
			    outID  = &twsID);
	  k++) {
	
	sts = vdobj$IsAncestryValid(objID = &twsID,
				    superClassID = OPP_VStwsBeam_class_id);
	if (sts & 1) {
	  // Just to be safe, verify don't have any duplicates
	  for(l = 0; vdvla_id$GetAt(vla = &pretendVla,nth = l,objID = &twsIDx); l++) {
	    if ((twsID.objid == twsIDx.objid) &&
		(twsID.osnum == twsIDx.osnum)) {
	      twsID.objid = NULL_OBJID; // Just a trick to prevent appending
	    }
	  }
	  if (twsID.objid != NULL_OBJID) {
	    vdvla_id$Append(vla = twsVla, objID = &twsID);
	  }
	}
      }// end of "k" child loop 
    } // end of "j" pretend loop
    vdvla_id$Delete(vla = &pretendVla);
  } // end of "i" axis loop
  vdvla_id$Delete(vla = &axisVla);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/*----------------------------------------------------------------------------*/
long VSgetElementsOnSupport( msg, support, STRUCTtype, wantVisibleOnes,
			     count, list )
  
long		*msg ;
unsigned long	STRUCTtype ;
int		wantVisibleOnes,
		*count ;
struct GRid	*support,
		**list ; {

	long		sts ;		/* OM return code		*/
	int		i,		/* Loop-on-children index	*/
			j,		/* Loop-on-children index	*/
			childrenCount,	/* Count of children		*/
			elmCount ;	/* Count of elements on support	*/
	int		*visCnt,axCount ;/* Counts of visible elements	*/
	int             stfCount;       /* Count of twisted stiffeners  */
	struct GRid	*children,	/* List of non-pretend children	*/
			**visList ;	/* Lists of visible elements	*/
	unsigned long	type ;		/* Type of a child if structural*/
        TVDvlaID        twsVla;         /* for TR179900593 */	

	/*
	 * `STRUCTtype' must be VS_m_SRC_BEAM/VS_m_STF_BEAM/VS_m_PLATE
	 * `support' must be an associative object.
	 *
	 * If `wantVisibleOnes' is FALSE, just return direct children which
	 * are elements (some may have been split in two).
	 * If `wantVisibleOnes' is TRUE, take into account the fact that
	 * some may have been split.
	 * If `list' is not NULL and `wantVisibleOnes' is FALSE, returns the
	 * ids of direct children which are elements.
	 * If `list' is not NULL and `wantVisibleOnes' is TRUE, returns the ids
	 * of the visible results corresponding to element, ie. if plate
	 * supported one element S1 which has been split into S2 and S3,
	 * return *count = 2 and the ids of S2 and S3, NOT that of S1.
	 */

	*count	= 0 ;
	if( list ) *list = NULL ;
	childrenCount	= 0 ;
	stfCount        = 0 ;
	children	= NULL ;
	visCnt		= NULL ;
	visList		= NULL ;
	
	sts = VSgetChildrenGoThruPretends(	msg,
						support,
						&childrenCount,
						&children ) ;
	__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;
	
	// Code addition for TR179900593 begins
	
	vdvla_id$Construct(vla = &twsVla);
	
        sts = VSGetTwistedStiffeners(support,&twsVla); 
	
	stfCount = vdvla_id$GetCnt(vla = &twsVla);
	// Now add these twisted stiffeners to the children list 
	
	if((stfCount!=0) && (children!=NULL))
	{
	  if((children = _REALLOC(children,(childrenCount+stfCount),struct GRid))!=NULL)
	  {
	    TGRid twistID;
	    for(i=0;vdvla_id$GetAt(vla = &twsVla,nth = i,objID = &twistID);i++)
	    {
	      children[childrenCount+i].objid = twistID.objid;
	      children[childrenCount+i].osnum = twistID.osnum;
	    }
	  }
	  childrenCount += stfCount;
	}
	vdvla_id$Delete(vla = &twsVla);
       	// Code addition for TR179900593 ends
	
	elmCount = 0 ;
	for( i = 0 ; i < childrenCount ; i++ ) {
		/*
		 * The following message send will fail is child does not
		 * understand the message.
		 */
		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
				senderid= NULL_OBJID,
				targetid= children[i].objid,
				targetos= children[i].osnum ) ;
		if(    ! ( sts & 1 & *msg )
		    || ( type & STRUCTtype ) != STRUCTtype ) {
		    	/*
		    	 * Flag this child as not-a-valid-element.
		    	 */
			children[i].objid = NULL_OBJID ;
			continue ;
		}

		/*
		 * Do not want visible elements, just direct children.
		 */
		if( !wantVisibleOnes ) { elmCount++ ; continue ; }

		/*
		 * Find visible result corresponding to element child.
		 */
		j = 0 ;
		sts = om$send(	msg	= message VSfeature.VS__getVisDivRes(
								msg, &j, NULL ),
				senderid= NULL_OBJID,
				targetid= children[i].objid,
				targetos= children[i].osnum ) ;
		if( sts & 1 & *msg ) {
			elmCount += j ;
		}
	}

	*count = elmCount ;

	if( ! ( list && elmCount ) ) {
		/*
		 * Do not want ids of elements or not elements at all.
		 */
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	/*
	 * Compress list of children, removing non-valid elements.
	 */
	for( i = j = 0 ; i < childrenCount ; i++ ) {
		if( !IF_NULL_OBJID( children[i].objid ) ) {
			children[j++] = children[i] ;
		}
	}
	/*
	 * Set `childrenCount' to be the count of non-pretend children which are
	 * elements.
	 */
	childrenCount = j ;

	if( !wantVisibleOnes ) {
		/*
		 * Just want direct element children.
		 */
		*list = children ; sts = OM_S_SUCCESS ; *msg = MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Here want visible results corresponding to element children.
	 */
	visList = _MALLOC( childrenCount, struct GRid *	) ;
	visCnt  = _MALLOC( childrenCount, int		) ;
	if( !( visList && visCnt ) ) vs$mem_fail() ;

	for( i = 0 ; i < childrenCount ; i++ ) {
		sts = om$send(	msg	= message VSfeature.VSgetVisDivRes(
								msg,
								visCnt + i,
								visList+ i ),
				senderid= NULL_OBJID,
				targetid= children[i].objid,
				targetos= children[i].osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetVisDivRes", wrapup ) ;
	}

	/*
	 * Merge lists into one.
	 */
	if( !( *list = _MALLOC( elmCount, struct GRid ) ) ) vs$mem_fail() ;
	for( i = j = 0 ; i < childrenCount ; i++ ) {
		memcpy(	(char *) ( *list + j ),
			(char *) visList[i],
			visCnt[i] * sizeof( struct GRid ) ) ;
		j += visCnt[i] ;
	}

	wrapup :
		if( list ) {
			if( *list != children ) _FREE( children ) ;
		} else _FREE( children ) ;
		if( visList ) {
			for( i = 0 ; i < childrenCount ; i++ ) {
				if( visCnt[i] ) _FREE( visList[i] ) ;
			}
			_FREE( visCnt  ) ;
			_FREE( visList ) ;
		}
		return sts ;

} /* VSgetElementsOnSupport */
/*----------------------------------------------------------------------------*/
end implementation VSfeature ;

