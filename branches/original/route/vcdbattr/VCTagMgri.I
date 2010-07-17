
/* $Id: VCTagMgri.I,v 1.2 2001/02/20 01:10:37 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCTagMgri.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCTagMgr class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTagMgri.I,v $
 *        Revision 1.2  2001/02/20 01:10:37  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/07/22  07:59:10  pinnacle
# Replaced: vcdbattr/VCTagMgri.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/11/30  15:39:26  pinnacle
# Created: vcdbattr/VCTagMgri.I by r250_int for route
#
# Revision 1.2  1997/11/17  20:52:10  pinnacle
# Replaced: vcdbattr/VCTagMgri.I for:  by vc241 for cabling
#
# Revision 1.1  1997/11/14  22:54:56  pinnacle
# Created: vcdbattr/VCTagMgri.I by onayragu for cabling
#
 *
 * History:
 *	11/12/97	Onay		Initial.
 *	16/07/98	Alwin		Corrected the Function VC_TagList, 
 *					memory allocated was less. TR179801127
 *					This was found when trying to convert
 *					old design file 947001.d(v 02.04.02.20 )
 *					to v 02.05.00.
 *
 *************************************************************************/

class implementation VCTagMgr;

#include "exproto.h"
#include "exmacros.h"
#include "VCproto.h"
#include "vc_define.h"
#include "vc_structs.h"
#include "vc_structs.h"
#include "vrdbgmacros.h"
#include "VCTagDef.h"
#include "VDmem.h"

from VCRoot import VCGetTagNo;

extern GRclassid	OPP_VCTerm_class_id, OPP_VCCable_class_id;
extern GRclassid	OPP_VCElTerm_class_id, OPP_VCFoTerm_class_id;
extern GRclassid	OPP_VCElCable_class_id, OPP_VCFoCable_class_id;
extern GRclassid	OPP_VCGuide_class_id;

/************************************************************************/
/* VC_TAGobj								*/
/* Check for TagManager existency as a super object. Create it if it	*/
/* does not exist. Call TagInit and TagEval method if creation.		*/
/* lMsg		IGRlong *	O	Return message.			*/
/* TagId	struct GRid *	O	TagManager Id created/retrieved	*/
/************************************************************************/

IGRint     VC_TAGobj (IGRlong      *msg,
               struct GRid         *TagId)
{
struct GRid	ModId;
IGRlong		lMsg;
IGRint		FctStatus;

*msg = MSFAIL;

FctStatus = ex$get_cur_mod (osnum = &ModId.osnum, id = &ModId.objid);

TagId->osnum	= ModId.osnum;
TagId->objid	= NULL_OBJID;

/********************************************************/
/* Object itself will be created by get_super macro	*/
/********************************************************/
FctStatus = ex$get_super (	mod_id		= ModId.objid,
			mod_osnum	= ModId.osnum,
			super_name	= "TagManager",
			create		= FALSE,
			wakeup_flag	= FALSE,
			super_class	= "VCTagMgr",
			super_id	= &TagId->objid,
			super_osnum	= &TagId->osnum );

if (!(FctStatus&1) || TagId->objid == NULL_OBJID)
  {
  FctStatus = ex$get_super (	mod_id		= ModId.objid,
				mod_osnum	= ModId.osnum,
				super_name	= "TagManager",
				create		= TRUE,
				wakeup_flag	= FALSE,
				super_class	= "VCTagMgr",
				super_id	= &TagId->objid,
				super_osnum	= &TagId->osnum );
  if (TagId->objid != NULL_OBJID)
    {
    FctStatus = om$send (msg = message VCTagMgr.VCTagInit (&lMsg),
        senderid = NULL_OBJID,
        targetid = TagId->objid,
        targetos = TagId->osnum);
    FctStatus = om$send (msg = message VCTagMgr.VCTagEval (&lMsg),
        senderid = NULL_OBJID,
        targetid = TagId->objid,
        targetos = TagId->osnum);
    }

  }

if (TagId->objid != NULL_OBJID)
  *msg = MSSUCC;

return (OM_S_SUCCESS);

} /* end function VC_TAGobj */

IGRint     VC_TAGchk (IGRshort        *nST,
                      IGRint           Cat,
                      IGRchar         *szTag)
{
  IGRint          status;
  IGRlong         retmsg;
  struct GRid     TagId;

  status = VC_TAGobj (&retmsg, &TagId);

  *nST = -1;

  if (retmsg == MSSUCC)
    status =
    om$send (msg = message VCTagMgr.VCTagChk (nST, Cat, szTag),
        senderid = NULL_OBJID,
        targetid = TagId.objid,
        targetos = TagId.osnum);

  return (status);
}

IGRint     VC_TAGadd (IGRshort        *nST,
                      IGRint           Cat,
                      IGRchar         *szTag,
		      struct GRid	*CompId)
{
  IGRint          status;
  IGRlong         retmsg;
  struct GRid     TagId;

  SetProc( Fn VC_TAGadd ); Begin 

  __DBGpr_obj( " Comp Id ", *CompId );

  status = VC_TAGobj (&retmsg, &TagId);
  __DBGpr_obj( " Tag Manager object Id ", TagId );

  *nST = -1;

  if (retmsg == MSSUCC)
  {
    __DBGpr_com( " Add the tag into Tag Manager " );
    status =
    om$send (msg = message VCTagMgr.VCTagAdd (nST, Cat, szTag, CompId),
        senderid = NULL_OBJID,
        targetid = TagId.objid,
        targetos = TagId.osnum);
  }

  End
  return (status);
}

IGRint     VC_TAGdel (IGRshort        *nST,
                      IGRint           Cat,
                      IGRchar         *szTag)
{
  IGRint          status;
  IGRlong         retmsg;
  struct GRid     TagId;

  status = VC_TAGobj (&retmsg, &TagId);

  *nST = -1;

  if (retmsg == MSSUCC)
    status =
    om$send (msg = message VCTagMgr.VCTagDel (nST, Cat, szTag),
        senderid = NULL_OBJID,
        targetid = TagId.objid,
        targetos = TagId.osnum);

  return (status);
}


method  VCTagInit  (IGRlong    *msg)
{
  /*   read DB tag table   ?   */
  me->nTagStat = 0;

  *msg = MSSUCC;

  return (OM_S_SUCCESS);
}

method  VCTagChk   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag)
{
  IGRint   i, iloop;

  *nST = -1;
  iloop = om$dimension_of (varray = me->taglist);

#ifdef MY_DEBUG
    printf ("TAGCHK %s\n", szTag);
#endif

  for (i=0; i<iloop; i++)
  {
    if ((CAT == me->taglist[i].nTagCat) &&
        (strcmp (me->taglist[i].Tag, szTag) == 0))
    {
      *nST = i;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

/*
/************************************************************************/
/* Method VCTagAdd							*/
/* nST		IGRshort *	I	Index in instance array.	*/
/* CAT		IGRint		I	Category to add the tag to.	*/
/* szTag	IGRchar *	I	Tag string.			*/
/* Id		struct GRid *	I	Id of elmt tagged.		*/
/* This method will add the string to the internal list of tagged	*/
/* elements.								*/
/* The purpose of the Id is only to restrict tag operation for some	*/
/* classes of components.						*/
/************************************************************************/

method  VCTagAdd   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag;
		    struct GRid	*Id )
{
IGRint   	iloop;
IGRint   	status;
GRclassid	ClassId;

SetProc( Md VCTagAdd ); Begin 

__DBGpr_me();

status	= OM_S_SUCCESS;

if (om$is_objid_valid (	osnum	= Id->osnum,
			objid	= Id->objid )
				  != OM_S_SUCCESS ) goto wrapup;
om$get_classid (	osnum		= Id->osnum,
			objid		= Id->objid,
			p_classid	= &ClassId );

if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCTerm_class_id) 
				== OM_S_SUCCESS)
  goto wrapup;

__DBGpr_obj( " Cable Object Id ", *Id );

__DBGpr_str( " Calling Md VCTagChk for ", szTag );
status = om$send (msg = message VCTagMgr.VCTagChk (nST, CAT, szTag),
      targetid = my_id);

__DBGpr_int( " Nb. of Tags present in TM ", *nST );

if (*nST >= 0)
  *nST = -1;
else
{
  iloop = om$dimension_of (varray = me->taglist);
  *nST  = iloop;
  __DBGpr_int( " Nb. of Tags ", iloop );

  status = om$vla_set_dimension (varray = me->taglist,
				 size   = (iloop + 1));

  me->taglist[iloop].nTagOrig = 0;
  me->taglist[iloop].nTagCat  = CAT;
  strcpy (me->taglist[iloop].Tag, szTag);

#ifdef MY_DEBUG
    printf ("TAGADD %d %s\n",iloop, szTag);
#endif
  }

wrapup :

End
return (status);

} /* end method VCTagAdd */

method  VCTagDel   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag)
{
  IGRint   iloop;
  IGRint   i;
  IGRint   status;

  status =
  om$send (msg = message VCTagMgr.VCTagChk (nST, CAT, szTag),
      targetid = my_id);

#ifdef MY_DEBUG
    printf ("TAGDEL %d %s\n",*nST, szTag);
#endif
  if (*nST >= 0)
  {
    iloop = om$dimension_of (varray = me->taglist);

    for (i=*nST; i<(iloop-1); i++)
      me->taglist[i] = me->taglist[i+1];

    status = om$vla_set_dimension (varray = me->taglist,
                                   size   = (iloop - 1));
  }

  return (status);
}

/************************************************************************/
/* VCTagDump								*/
/* Returns every tags already placed in active design file.		*/
/* NbTag	IGRint *	O	Number of tag returned.		*/
/* TagList	VCtagmgr *	O	List of tag structures.		*/
/*									*/
/* The calling function is responsible for freeing allocated memory.	*/
/************************************************************************/

method  VCTagDump   (IGRint      	*NbTag;
                    struct VCtagmgr	**TagList )
{
IGRint   	i, iloop;
struct VCtagmgr	*List;

*NbTag	= 0;
iloop	= 0;
List	= 0;

iloop	= om$dimension_of (varray = me->taglist);
if (iloop == 0)
  goto wrapup;

List = _MALLOC (iloop,struct VCtagmgr);
if (List == 0)
  goto wrapup;

*NbTag	= iloop;

for (i=0; i<iloop; i++)
  {
  List [i].nTagCat	= me->taglist [i].nTagCat;
  strcpy (List [i].Tag, me->taglist [i].Tag);
  } /* end for */

wrapup :

if (List)
  *TagList	= List;

return (OM_S_SUCCESS);

} /* end method VCTagDump */

/************************************************************************/
/* VC_TAGList								*/
/* Function to retrieve list of objects in given object space which 	*/
/* can be potentially tagged.						*/
/* Osnum	GRspacenum	I	Osnum to scrutanize.		*/
/* NbInList	IGRint	*	O	Number of structures.		*/
/* TagList	VCTagInfo *	O	structure containing objects.	*/
/* First round to count objects, then allocate proper number and	*/
/* finally retrieve informations about every objects.			*/
/* Calling function is responsible for freeing memory.			*/
/************************************************************************/

IGRint     VC_TAGList (	GRspacenum		Osnum,
			IGRint			*NbInList,
			struct VCTagInfo	**TagList )
{
IGRint			Count, MaxIds, NbTerm, NbCable, NbGuide, Index;
IGRint			FctStatus;
struct GRid		Id;
struct VCTagInfo	*List;
GRclassid		ClassId;

SetProc( Fn VC_TagList ); Begin 

Count		= 0;
List		= 0;
*NbInList	= 0;
NbTerm		= 0;
NbGuide		= 0;
NbCable		= 0;
FctStatus	= OM_S_SUCCESS;

/************************************************************************/
/* First count number of Cable components potentially tagged to alloc 	*/
/************************************************************************/
Id.osnum	= Osnum;
MaxIds		= OM_GA_OSDs [Osnum]->CurSpaceMapSize;
for (Id.objid = 0;Id.objid < MaxIds;Id.objid++)
{
  if (om$is_objid_valid (	osnum	= Id.osnum,
				objid	= Id.objid )
					!= OM_S_SUCCESS ) continue;

  om$get_classid (	osnum		= Id.osnum,
			objid		= Id.objid,
			p_classid	= &ClassId );

  /***** This check is not required any more -- Alwin for TR179801127

  if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCTerm_class_id)
				== OM_S_SUCCESS)
    {
    NbTerm++;
    }
  else

  *****/

  if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCGuide_class_id)
				== OM_S_SUCCESS)
  {
    NbGuide++;
  }
  else 
  if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCCable_class_id)
				== OM_S_SUCCESS )
  {
      NbCable++;
  }
} /* end for */

Count	= NbCable + NbTerm + NbGuide;
__DBGpr_int( " Total Number of Tagged Objects ", Count );

if (Count==0)
  goto wrapup;

List	= _MALLOC (Count, struct VCTagInfo);

if (!List)
{
  __DBGpr_com( " Memory Allocation Error ->List :-( " );
  goto wrapup;
}

Index	= 0;
for (Id.objid = 0;Id.objid < MaxIds;Id.objid++)
{
  if (om$is_objid_valid (	osnum	= Id.osnum,
				objid	= Id.objid )
					!= OM_S_SUCCESS ) continue;

  om$get_classid (	osnum		= Id.osnum,
			objid		= Id.objid,
			p_classid	= &ClassId );

  if (
     ( om$is_ancestry_valid (	subclassid	= ClassId,
				  superclassid	= OPP_VCCable_class_id ) 
				  == OM_S_SUCCESS )  ||
     ( om$is_ancestry_valid (	subclassid	= ClassId,
				  superclassid	= OPP_VCGuide_class_id)
				  == OM_S_SUCCESS ) )

    /***** Not needed anymore -- Alwin for TR179801127

    om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCTerm_class_id) 
				== OM_S_SUCCESS ||
      )
    *****/

  {
    List [Index].Id		= Id;
    List [Index].ClassId	= ClassId;
    List [Index].Flag		= 0;

    FctStatus = om$send (msg = message VCRoot.VCGetTagNo (List [Index].szTag),
		senderid = NULL_OBJID,
		targetos = Id.osnum,
		targetid = Id.objid );

    if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCElTerm_class_id)
				== OM_S_SUCCESS )
      {
      List [Index].Cat	= VCTAG_CAT_ELTERM;
      }
    else
    if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCFoTerm_class_id)
				== OM_S_SUCCESS )
      {
      List [Index].Cat	= VCTAG_CAT_FOTERM;
      }
    else
    if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCElCable_class_id)
				== OM_S_SUCCESS )
      {
      List [Index].Cat	= VCTAG_CAT_ELCABLE;
      }
    else
    if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCFoCable_class_id)
				== OM_S_SUCCESS )
      {
      List [Index].Cat	= VCTAG_CAT_FOCABLE;
      }
    else
    if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VCGuide_class_id)
				== OM_S_SUCCESS )
      {
      List [Index].Cat	= VCTAG_CAT_GUIDE;
      }
    else
      {
      List [Index].Cat	= VCTAG_CAT_GENERAL;
      }
    Index++;
    *NbInList	= Index;
  }
} /* end for */

wrapup :

if (List)
  *TagList	= List;

End
return FctStatus;

} /* end function VC_TAGList */

/************************************************************************/
/* method VCTagEval							*/
/* This method will retrieve all tagged objects from current object	*/
/* space and inform the Tag Manager.					*/
/************************************************************************/

method  VCTagEval  (IGRlong    *msg)
{
struct VCTagInfo	*List;
IGRint			Count, ii, FctStatus;
IGRshort		nST;

*msg	= MSSUCC;
List	= 0;

VC_TAGList (OM_Gw_current_OS, &Count, &List);
for (ii=0;ii<Count;ii++)
  {
  nST	= -1;
  FctStatus = om$send (msg = message VCTagMgr.VCTagAdd (	&nST,
							List [ii].Cat,
							List [ii].szTag,
							&List [ii].Id ),
        targetid = my_id );

  } /* end for */

if (List)
  {
  _FREE (List);
  List	= 0;
  }

return (OM_S_SUCCESS);

} /* end method VCTagEval */


end implementation VCTagMgr;
