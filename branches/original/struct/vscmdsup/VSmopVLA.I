/* $Id: VSmopVLA.I,v 1.2 2001/01/17 00:10:21 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vcmdsup/VSmopVLA.I
 *
 * Description: Modify Operator Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopVLA.I,v $
 *      Revision 1.2  2001/01/17 00:10:21  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/06/01  15:21:10  pinnacle
# Replaced: struct/vscmdsup/VSmopVLA.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/05/03  19:57:02  pinnacle
# initial revision
#
# Revision 1.3  1999/06/16  15:51:28  pinnacle
# (No comment)
#
# Revision 1.2  1999/05/06  21:44:04  pinnacle
# (No comment)
#
# Revision 1.1  1999/04/26  20:53:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"
#include "VDvla2.h"

#include "VSmop.h"

/* -------------------------------------------
 * Wrapper for TVSmopOpInfoVLA
 */
IGRstat VSmopOpInfoVLA_Init(TVSmopOpInfoVLA *vla)
{
  IGRstat retFlag = 0;
  IGRint  max = VSMOP_VLA_OP_INFO_MAX;
  IGRint  add = VSMOP_VLA_OP_INFO_ADD;
  
  // Pass onto standard routine
  retFlag = VDvlaInit((TVDvla*)vla,sizeof(TVSmopOpInfo),max,add,NULL,NULL);

  return retFlag;
}

IGRstat VSmopOpInfoVLA_Free(TVSmopOpInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaFree((TVDvla*)vla,0);

  vla->vla.next = NULL;
  
  return retFlag;
}

IGRstat VSmopOpInfoVLA_Empty(TVSmopOpInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaEmpty((TVDvla*)vla);
  
  return retFlag;
}
IGRstat VSmopOpInfoVLA_Append(TVSmopOpInfoVLA *vla, 
                              TVSmopOpInfo    *data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaAppend((TVDvla*)vla,(IGRchar*)data);
  
  return retFlag;
}
IGRstat VSmopOpInfoVLA_GetAppend(TVSmopOpInfoVLA *vla, 
				 TVSmopOpInfo   **data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetAppend((TVDvla*)vla,(IGRchar**)data);
  
  return retFlag;
}
IGRstat VSmopOpInfoVLA_GetCnt(TVSmopOpInfoVLA *vla, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetCnt((TVDvla*)vla,cnt);
  
  return retFlag;
}
IGRstat VSmopOpInfoVLA_GetNth(TVSmopOpInfoVLA *vla, 
                              IGRint nth, 
                              TVSmopOpInfo *data, 
                              TVSmopOpInfo **dataP)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetNth((TVDvla*)vla,nth,(IGRchar*)data,(IGRchar**)dataP);
  
  return retFlag;
}

IGRstat VSmopPieceInfoVLA_FreeNth( TVSmopPieceInfoVLA *pieceVLA, 
                                   IGRint nth )
{
  IGRstat 		retFlag;
  TVDvlax               *piece_vlax, *piece_vlaxx;
  TVDvlax               *item_vlax, *item_vlaxx;
  TVSmopPieceInfoVLA    *pieceInfoVLA;
  TVSmopItemInfoVLA     *itemInfoVLA;
  TVSmopOpInfoVLA       *opInfoVLA;
  TVDvla		*vla;
  IGRint		j, opPosition, num;
  

  retFlag = 0;
  num     = nth + 1;

  if( !(pieceVLA) ) goto wrapup;

  vla = (TVDvla *)pieceVLA;

  /*
  ** Check if it is in the first section of pieces
  */
  if( nth < vla->max )
  {
    itemInfoVLA = &(pieceVLA->data[nth].itemInfoVLA);

    /*
    ** Free the first section of items
    */
    for( j = 0 ; j < itemInfoVLA->vla.cnt ; j++ )
    {
      opInfoVLA = &(itemInfoVLA->data[j].opInfoVLA);
      VSmopOpInfoVLA_Free( opInfoVLA );
      opInfoVLA->vla.cnt = 0;
    }

    /*
    ** Free any downstream items
    */
    item_vlax = (TVDvlax *)(itemInfoVLA->vla.next);
    while( item_vlax )
    {
      item_vlaxx = (TVDvlax *)item_vlax->next;
      for( j = 0 ; j < item_vlax->cnt ; j++ )
      {
        opInfoVLA = &(((TVSmopItemInfo *)(item_vlax->data))[j].opInfoVLA);
        VSmopOpInfoVLA_Free( opInfoVLA );
        opInfoVLA->vla.cnt = 0;
      }
      item_vlax = item_vlaxx;
    }

    VSmopItemInfoVLA_Free( itemInfoVLA );
    itemInfoVLA->vla.cnt = 0;
  
    retFlag = 1;
    goto wrapup;
  }

  /*
  ** Find the right position for the piece freed
  */
  piece_vlax = (TVDvlax *)vla->next;
  num -= vla->max;
  while( piece_vlax )
  {
    piece_vlaxx = (TVDvlax *)piece_vlax->next;
    if( num <= piece_vlax->max )
    {
      opPosition = num - 1;
      break;
    }
    num -= piece_vlax->max;
    piece_vlax = piece_vlaxx;
  }

  /*
  ** Free it
  */

  if( piece_vlax )
  {
    itemInfoVLA = 
    &(((TVSmopPieceInfo *)(piece_vlax->data))[opPosition].itemInfoVLA);

    /*
    ** Free the first section of items
    */
    for( j = 0 ; j < itemInfoVLA->vla.cnt ; j++ )
    {
      opInfoVLA = &(itemInfoVLA->data[j].opInfoVLA);
      VSmopOpInfoVLA_Free( opInfoVLA );
      opInfoVLA->vla.cnt = 0;
    }

    /*
    ** Free any downstream items
    */
    item_vlax = (TVDvlax *)(itemInfoVLA->vla.next);
    while( item_vlax )
    {
      item_vlaxx = (TVDvlax *)item_vlax->next;
      for( j = 0 ; j < item_vlax->cnt ; j++ )
      {
        opInfoVLA = &(((TVSmopItemInfo *)(item_vlax->data))[j].opInfoVLA);
        VSmopOpInfoVLA_Free( opInfoVLA );
        opInfoVLA->vla.cnt = 0;
      }
      item_vlax = item_vlaxx;
    }

    VSmopItemInfoVLA_Free( itemInfoVLA );
    itemInfoVLA->vla.cnt = 0;
  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}/* VSmopPieceInfoVLA_FreeNth */

IGRstat VSmopItemInfoVLA_FreeNth( TVSmopItemInfoVLA *itemVLA, 
                                  IGRint nth )
{
  IGRstat 		retFlag;
  TVDvlax               *item_vlax, *item_vlaxx;
  TVSmopOpInfoVLA       *opInfoVLA;
  TVDvla		*vla;
  IGRint		opPosition, num;
  

  retFlag = 0;
  num     = nth + 1;

  if( !(itemVLA) ) goto wrapup;

  vla = (TVDvla *)itemVLA;

  /*
  ** Check if it is in the first section of pieces
  */
  if( nth < vla->max )
  {
    opInfoVLA = &(itemVLA->data[nth].opInfoVLA);
    VSmopOpInfoVLA_Free( opInfoVLA );
    opInfoVLA->vla.cnt = 0;
  
    retFlag = 1;
    goto wrapup;
  }

  /*
  ** Find the right position for the piece freed
  */
  item_vlax = (TVDvlax *)vla->next;
  num -= vla->max;
  while( item_vlax )
  {
    item_vlaxx = (TVDvlax *)item_vlax->next;
    if( num <= item_vlax->max )
    {
      opPosition = num - 1;
      break;
    }
    num -= item_vlax->max;
    item_vlax = item_vlaxx;
  }

  /*
  ** Free it
  */
  if( item_vlax )
  {
    opInfoVLA = 
    &(((TVSmopItemInfo *)(item_vlax->data))[opPosition].opInfoVLA);
    VSmopOpInfoVLA_Free( opInfoVLA );
    opInfoVLA->vla.cnt = 0;
  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}/* VSmopItemInfoVLA_FreeNth */

IGRstat VSmopOpInfoVLA_OverwriteNth( TVSmopOpInfoVLA *vla, 
				     IGRint	     *nth,
                                     TVSmopOpInfo    *data,
				     TVSmopOpInfo    **dataP )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaOverwriteNth( (TVDvla *)vla,
			       nth,
			       (IGRchar *)data,
			       (IGRchar **)dataP,
			       NULL );

  
  return retFlag;
} /* VSmopOpInfoVLA_OverwriteNth */

IGRstat VSmopItemInfoVLA_OverwriteNth( TVSmopItemInfoVLA *vla, 
				       IGRint	         *nth,
                                       TVSmopItemInfo    *data,
				       TVSmopItemInfo    **dataP,
				       TVSmopItemInfo    **dataPNew )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaOverwriteNth( (TVDvla *)vla,
			       nth,
			       (IGRchar *)data,
			       (IGRchar **)dataP,
 			       (IGRchar **)dataPNew );

  
  return retFlag;
} /* VSmopItemInfoVLA_OverwriteNth */

IGRstat VSmopPieceInfoVLA_OverwriteNth( TVSmopPieceInfoVLA *vla, 
				        IGRint	           *nth,
                                        TVSmopPieceInfo    *data,
				        TVSmopPieceInfo    **dataP,
					TVSmopPieceInfo    **dataPNew )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaOverwriteNth( (TVDvla *)vla,
			       nth,
			       (IGRchar *)data,
			       (IGRchar **)dataP,
 			       (IGRchar **)dataPNew );

  
  return retFlag;
} /* VSmopPieceInfoVLA_OverwriteNth */

IGRstat VSmopItemInfoVLA_ResetDataP( TVSmopItemInfo    *dataP )
{
  IGRstat 	    retFlag;
  TVSmopOpInfoVLA   *opInfoVLA;

  
  retFlag = 0;

  opInfoVLA = &(dataP->opInfoVLA);
  opInfoVLA->vla.data = (IGRchar *)&(opInfoVLA->data[0]);

  retFlag = 1;

  
  return retFlag;
} /* VSmopItemInfoVLA_ResetDataP */

IGRstat VSmopPieceInfoVLA_ResetDataP( TVSmopPieceInfo    *dataP )
{
  IGRstat 	    retFlag;
  TVSmopItemInfoVLA *itemInfoVLA;
  TVSmopOpInfoVLA   *opInfoVLA;
  IGRint	    i;

  
  retFlag = 0;

  itemInfoVLA = &dataP->itemInfoVLA;
  itemInfoVLA->vla.data = (IGRchar *)&(itemInfoVLA->data[0]);

  for( i = 0 ; i < itemInfoVLA->vla.cnt ; i++ )
  {
    opInfoVLA = &(itemInfoVLA->data[i].opInfoVLA);
    opInfoVLA->vla.data = (IGRchar *)&(opInfoVLA->data[0]);
  }

  retFlag = 1;

  
  return retFlag;
} /* VSmopPieceInfoVLA_ResetDataP */

IGRstat VSmopOpInfoVLA_RearrangeVla( TVSmopOpInfoVLA *vla, 
				     IGRint	     *numOp,
                                     IGRint          *totalNumOp )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaRearrangeVla( (TVDvla*)vla, numOp, totalNumOp );

  
  return retFlag;
} /* VSmopOpInfoVLA_RearrangeVla */

IGRstat VSmopItemInfoVLA_RearrangeVla( TVSmopItemInfoVLA *vla, 
				       IGRint	         *numOp,
                                       IGRint            *totalNumOp )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaRearrangeVla( (TVDvla*)vla, numOp, totalNumOp );

  
  return retFlag;
} /* VSmopItemInfoVLA_RearrangeVla */

IGRstat VSmopPieceInfoVLA_RearrangeVla( TVSmopPieceInfoVLA *vla, 
				        IGRint	           *numOp,
                                        IGRint             *totalNumOp )
{
  IGRstat retFlag;

  
  retFlag = 0;

  /*
  ** Pass onto standard routine
  */
  retFlag = VDvlaRearrangeVla( (TVDvla*)vla, numOp, totalNumOp );

  
  return retFlag;
} /* VSmopPieceInfoVLA_RearrangeVla */

/* -------------------------------------------
 * Wrapper for TVSmopItemInfoVLA
 */
IGRint VSmopItemInfoVLA_InitData(void *data, IGRint cnt)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  TVSmopItemInfo *itemInfo;
  
  // Arg check
  if (data == NULL) goto wrapup;
  itemInfo = (TVSmopItemInfo*)data;
  
  // Make sure nested vla's are initialized
  for(i = 0; i < cnt; i++) {
    VSmopOpInfoVLA_Init(&itemInfo[i].opInfoVLA);
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

IGRstat VSmopItemInfoVLA_Init(TVSmopItemInfoVLA *vla)
{
  IGRstat retFlag = 0;
  IGRint  max = VSMOP_VLA_ITEM_INFO_MAX;
  IGRint  add = VSMOP_VLA_ITEM_INFO_ADD;
  IGRint  i;
  
  // Pass onto standard routine
  retFlag = VDvlaInit((TVDvla*)vla,sizeof(TVSmopItemInfo),
		      max,add,
		      VSmopItemInfoVLA_InitData,NULL);

  // Need to init the op vlas for each item info
  /* Commented by Ming. Init already in VSmopItemInfoVLA_InitData().
  for(i = 0; i < max; i++) {
    VSmopOpInfoVLA_Init(&vla->data[i].opInfoVLA);
  }
  */

  return retFlag;
}

IGRstat VSmopItemInfoVLA_Free(TVSmopItemInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaFree((TVDvla*)vla,0);

  vla->vla.next = NULL;
  
  return retFlag;
}

IGRstat VSmopItemInfoVLA_Empty(TVSmopItemInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaEmpty((TVDvla*)vla);
  
  return retFlag;
}
IGRstat VSmopItemInfoVLA_Append(TVSmopItemInfoVLA *vla, 
                                TVSmopItemInfo    *data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaAppend((TVDvla*)vla,(IGRchar*)data);
  
  return retFlag;
}
IGRstat VSmopItemInfoVLA_GetAppend(TVSmopItemInfoVLA *vla, 
				   TVSmopItemInfo   **data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetAppend((TVDvla*)vla,(IGRchar**)data);
  
  return retFlag;
}
IGRstat VSmopItemInfoVLA_GetCnt(TVSmopItemInfoVLA *vla, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetCnt((TVDvla*)vla,cnt);
  
  return retFlag;
}
IGRstat VSmopItemInfoVLA_GetNth(TVSmopItemInfoVLA *vla, 
                                IGRint nth, 
                                TVSmopItemInfo *data, 
                                TVSmopItemInfo **dataP)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetNth((TVDvla*)vla,nth,(IGRchar*)data,(IGRchar**)dataP);
  
  return retFlag;
}

/* -------------------------------------------
 * Wrapper for TVSmopPieceInfoVLA
 */

IGRint VSmopPieceInfoVLA_InitData(void *data, IGRint cnt)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  TVSmopPieceInfo *pieceInfo;
  
  // Arg check
  if (data == NULL) goto wrapup;
  pieceInfo = (TVSmopPieceInfo*)data;
  
  // Make sure nested vla's are initialized
  for(i = 0; i < cnt; i++) {
    VSmopItemInfoVLA_Init(&pieceInfo[i].itemInfoVLA);
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

IGRstat VSmopPieceInfoVLA_Init(TVSmopPieceInfoVLA *vla)
{
  IGRstat retFlag = 0;
  IGRint  max = VSMOP_VLA_PIECE_INFO_MAX;
  IGRint  add = VSMOP_VLA_PIECE_INFO_ADD;
  
  // Pass onto standard routine
  retFlag = VDvlaInit((TVDvla*)vla,
		      sizeof(TVSmopPieceInfo),
		      max,add,
		      VSmopPieceInfoVLA_InitData,NULL);
  
  return retFlag;
}

IGRstat VSmopPieceInfoVLA_Free(TVSmopPieceInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaFree((TVDvla*)vla,0);

  vla->vla.next = NULL;
  
  return retFlag;
}

IGRstat VSmopPieceInfoVLA_Empty(TVSmopPieceInfoVLA *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaEmpty((TVDvla*)vla);
  
  return retFlag;
}
IGRstat VSmopPieceInfoVLA_Append(TVSmopPieceInfoVLA *vla, 
                                 TVSmopPieceInfo    *data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaAppend((TVDvla*)vla,(IGRchar*)data);
  
  return retFlag;
}
IGRstat VSmopPieceInfoVLA_GetAppend(TVSmopPieceInfoVLA *vla, 
				    TVSmopPieceInfo   **data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetAppend((TVDvla*)vla,(IGRchar**)data);
  
  return retFlag;
}
IGRstat VSmopPieceInfoVLA_GetCnt(TVSmopPieceInfoVLA *vla, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetCnt((TVDvla*)vla,cnt);
  
  return retFlag;
}
IGRstat VSmopPieceInfoVLA_GetNth(TVSmopPieceInfoVLA *vla, 
                                 IGRint nth, 
                                 TVSmopPieceInfo *data, 
                                 TVSmopPieceInfo **dataP)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetNth((TVDvla*)vla,nth,(IGRchar*)data,(IGRchar**)dataP);
  
  return retFlag;
}


end implementation Root;
