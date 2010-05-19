/* $Id: VDchanCheck.I,v 1.5 2001/10/30 16:32:43 ramarao Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdmisc/VDchancheck.I
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *
 *      11/03/00        Ming            created
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"
#include "EMSutlmacros.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "exmacros.h"

#include "VDmem.h"
#include "v_dbgmacros.h"

extern IGRlong   VDbroGenClassIdList();


/*+fe
 -------------------------------------------------------------------------
  Function VD_disconnectObjectOnChannelByIndex

  Abstract
	By giving channel number and index, the following function disconnects
    	a object which connects to the channel at the given index from the
    	channel.

  Arguments

	struct GRid		obj		I	object
	OM_S_CHANNUM		chnNum		I	Channecl Number
        IGRint			index		I	index of object.

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRint	VD_disconnectObjectOnChannelByIndex( struct GRid  obj,
			     		     OM_S_CHANNUM chnNum,
			     		     IGRint	  index )
{
  IGRint                status, num, indx, ii, chanFlag;
  OM_S_CONNECT_SIDE     side1, side2;
  OM_p_CONNECT_SIDE     s1, s2;
  OM_p_CHANNEL_HDR      p_chan;
  OMuword               s1def_flags;
  OM_p_CHANNEL_LINK     link;
  OM_p_OBJID            p_objid;
  IGRchar               set_in_use;
  OM_S_CHANSELECT       chnSelect;

  __DBGpr_obj(" VD_disconnectObjectOnChannelByIndex ", obj );

  status = OM_S_SUCCESS;
  s1 = &side1;
  s2 = &side2;
  link = NULL;
  p_objid = NULL;
  set_in_use = FALSE;
  chanFlag = 1;

  /*
  ** Obtain the channel selector.
  */
  status = om$make_chanselect( channum      = chnNum,
                               p_chanselect = &chnSelect );
  if( !(status&1) ) return( status );

  /*
  ** Build the side s1 of the channel.
  */
  status = om$connect_build_side( osnum  = obj.osnum,
                                  objid  = obj.objid,
                                  chsel  = &chnSelect,
                                  relidx = 0,
                                  side   = s1 );
  if( !(status&1) )
  {
    /*
    ** If the side s1 of the channel can not be builded, release the side s1.
    */
    om$connect_release_side( side1 = s1 );
    return( status );
  }

  p_chan = *(s1->pp_chan);
  if( !p_chan )
  {
    om$connect_release_side( side1 = s1 );
    return( OM_I_CHAN_EMPTY );
  }

  /*
  ** Retrieve the channel type flag which indicate what type of channel it 
  ** is. (absordered, relordered. ..).
  */
  s1def_flags = s1->chdef->p_type->w_flags;

  /*
  ** Decide how many objects on the side s1 of the channel for each type.
  */
  if( s1def_flags&CD_absordered )
  {
    num = s1->tail.last_index;
  }
  if( s1def_flags&CD_relordered )
  {
    num = s1->tail.last_index - s1->tail.collapse_count;
  }
  else
  { 
    chanFlag = 0;
    num = s1->tail.last_index;
  }

  /*
  ** Check if the index is valid (must be between zero and number of objects.
  */
  if( index < 0 || index > num )
  {
    om$connect_release_side( side1 = s1 );
    return( OM_E_INVALIDRANGE );
  }

  /*
  ** Retrieve the channel data pointer
  */
  if( chanFlag )
  {
    if( (p_chan->flags&OM_CH_restricted) )
      p_objid = (OM_p_OBJID)s1->p_chandata;
    else
      link = (OM_p_CHANNEL_LINK)s1->p_chandata;

    /*
    ** For each type of channel, find the correct position of channel data 
    ** pointer at the given index.
    */
    if( p_chan->flags&OM_CH_relordered )
    {
      if(s1->tail.collapse_count)
      {
      	indx = 0;
      	if( p_chan->flags&OM_CH_restricted )
      	{
          for( ii = 0 ; ; p_objid++ , indx++ )
	  { /* skip all holes in channel array */
            if( !IF_NULL_OBJID(*p_objid) )
	    {
              ii++;
              if( ii > index ) break;
            }
          }
        }
        else
        {  /* not restricted */
          link = (OM_p_CHANNEL_LINK)(s1->p_chandata);
          for( ii = 0 ; ; link++ , indx++ )
	  { /* skip all holes in channel array */
            if( !IF_NULL_OBJID(link->objid) )
	    {
              ii++;
              if( ii > index ) break;
            }
          }
        }
      }  /* if collapse count not 0 */
      else
      {
        indx = index;
        if( p_chan->flags&OM_CH_restricted )
        {
          p_objid += indx;
        }
        else
        {
          link += indx;
        }
      }
    }      /* if relatively ordered */
    else
    {  /* absordered - can be fixed or regular */
      indx = index;
      if( p_chan->flags&OM_CH_restricted )
      {
        p_objid += indx;
      }
      else
      {
        link += indx;
      }
    }      /* if absolutely ordered */

    if( !(p_chan->flags&OM_CH_in_use) )
    {
      set_in_use = TRUE;
      p_chan->flags |= OM_CH_in_use;
    }

    status = OM_S_SUCCESS;

    /*
    ** Release the object on the channel at the given index
    */
    if( p_chan->flags&OM_CH_restricted )
    {
      if( !IF_NULL_OBJID(*p_objid) )
      {
        s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid;

        status = om$connect_pside( side1 = s1, side2 = s2 );
        if( 1&status )
        {
          if( status == OM_S_SUCCESS )
          {  /* s2 OS may not be loaded - let dangle */
            status = om$connect_disconnect  ( side1 = s2, side2 = s1 );
            status = om$connect_release_side( side1 = s2 );
          }
          status = om$connect_disconnect  ( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
        else
        {
          status = om$connect_disconnect  ( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
      } /* close if ! NULL_OBJID */
    }
    else
    {
      if( !IF_NULL_OBJID(link->objid) )
      {
        s1->p_chlink = link;
        status = om$connect_pside ( side1 = s1, side2 = s2 );
        if( 1&status )
        {
          if( status == OM_S_SUCCESS )
          {  /* s2 OS may not be loaded - let dangle */
            status = om$connect_disconnect  ( side1 = s2, side2 = s1 );
            status = om$connect_release_side( side1 = s2 );
          }
          status = om$connect_disconnect  ( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
        else
        {
          status = om$connect_disconnect  ( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
      } /* close if ! NULL_OBJID */
    } /* not restricted */

    if( set_in_use )
      p_chan->flags = (p_chan->flags & (~OM_CH_in_use));
  }
  else
  {
    if( s1def_flags&CD_restricted )
      p_objid = (OM_p_OBJID)(s1->p_chandata);
    else
      link = (OM_p_CHANNEL_LINK)(s1->p_chandata);

    if( (!(s1def_flags&(CD_1_1|CD_m_1))) &&
        (!(p_chan->flags&OM_CH_in_use)) )
    {
      set_in_use = TRUE;
      p_chan->flags |= OM_CH_in_use;
    }

    if( s1def_flags&CD_restricted )
    {
      for( ii = num ; ii > 0 ; ii-- , p_objid++ )
      {
        if( !IF_NULL_OBJID(*p_objid) )
	{
          s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid;
          status = om$connect_pside( side1 = s1, side2 = s2 );
          if( 1&status )
 	  {
            if( status == OM_S_SUCCESS )
	    {  /* s2 OS may not be loaded - let dangle */
              status = om$connect_disconnect( side1 = s2, side2 = s1 );
              status = om$connect_release_side( side1 = s2 );
            }
            status = om$connect_disconnect( side1 = s1, side2 = s2 );
            status = om$connect_return_chent( side1 = s1 );
          }
          else
	  {
 	    status = om$connect_disconnect( side1 = s1, side2 = s2 );
            status = om$connect_return_chent( side1 = s1 );
          }
        } /* close if ! NULL_OBJID */
      } /* close for */
    }
    else
    {
      for( ii = num ; ii > 0 ; ii-- , link++ )
      {
        if( !IF_NULL_OBJID(link->objid) )
	{
          s1->p_chlink = link;
          status = om$connect_pside( side1 = s1, side2 = s2 );
          if( 1&status )
	  {
            if( status == OM_S_SUCCESS )
	    {  /* s2 OS may not be loaded - let dangle */
              status = om$connect_disconnect( side1 = s2, side2 = s1 );
              status = om$connect_release_side ( side1 = s2 );
            }
            status = om$connect_disconnect( side1 = s1, side2 = s2 );
            status = om$connect_return_chent( side1 = s1 );
          }
          else
  	  {
            om$connect_disconnect  ( side1 = s1, side2 = s2 );
            om$connect_return_chent( side1 = s1 );
          }
        } /* close if ! NULL_OBJID */
      } /* close for */
    } /* not restricted */

    if( !(s1def_flags&(CD_1_1|CD_m_1)) )
    {
      if( set_in_use )
        p_chan->flags &= (~OM_CH_in_use); /* clear in_use flag if you set it */
    }
  }


wrapup :
  /*
  ** Release the side s1 of the channel
  */
  status = om$connect_release_side( side1 = s1 );

  return ( OM_S_SUCCESS );
} /* VD_disconnectObjectOnChannelByIndex */

/*+fe
 -------------------------------------------------------------------------
  Function VD_checkObjectChannelFlagValid

  Abstract
        Function checks whether two flags of the given channel match. 
	if they don't match, the channel was corrupted. If return 0, 
	the two flags don't match and the channel was corrupted.

  Arguments

	OMuword			osnum		I   	object osnum
	OM_S_OBJID		objid		I	object ID
	OM_p_CHANSELECT		p_chanselect	I	Channecl selector.

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRint VD_checkObjectChannelFlagValid( OMuword         osnum,
				       OM_S_OBJID      objid,
				       OM_p_CHANSELECT p_chanselect )					
{
   OM_p_CHANNEL_HDR    *p_channel;        /*  channel pointer                */
   int                 *p_chandata;       /*  ptr to channel data            */
   OMuword              w_channel_flags;  /*  Flags word in the channel      */
   OM_S_BIG_TAIL        tail;             /*  channel tail                   */
   OM_p_CHANNEL_DEFN    p_chdef;          /*  ptr to channel defn            */
   int			status, flag1, flag2;
   OM_p_OBJECTHDR 	p_object;


   status = OM_S_SUCCESS;
   p_object = NULL;

   /*--------------------------------*/
   /*  Get a pointer to the channel  */
   /*--------------------------------*/

   status = om$get_channel( osnum        = osnum,
             		    objid        = objid,
             		    object       = p_object,
             		    p_chanselect = p_chanselect,
             		    pp_channel   = &p_channel,
             		    pp_chandata  = &p_chandata,
             		    pp_chandef   = &p_chdef,
             		    p_tail       = &tail );

   if( !(1&status) ) return( OM_S_SUCCESS );

   if( (*p_channel) == NULL ) return( OM_S_SUCCESS );

   /*-----------------------*/
   /*  check res1chan case  */
   /*-----------------------*/
   if( (p_chdef->p_type->w_flags&CD_restricted) &&
       (p_chdef->p_type->w_flags&(CD_1_1|CD_m_1)) )
   {
     return (OM_S_SUCCESS);
   }

   /*
   ** The following checks whether or not the two flags match -
   ** (*p_channel)->flags and p_chdef->p_type->w_flags.  For example,
   ** if (*p_channel)->flags has a channel type CD_1_1, the flag
   ** p_chdef->p_type->w_flags also has to have a channel type OM_CH_1_1.
   ** Check all seven types of channel.
   */
   w_channel_flags = (*p_channel)->flags;

   if( (p_chdef->p_type->w_flags&CD_1_1) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_1_1) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_m_1) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_m_1) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_1_m) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_1_m) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_m_m) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_m_m) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_absordered) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_absordered) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_relordered) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_relordered) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }

   if( (p_chdef->p_type->w_flags&CD_restricted) ) flag1 = 1;
   else flag1 = 0;
   if( (w_channel_flags&OM_CH_restricted) ) flag2 = 1;
   else flag2 = 0;
   if( flag1 != flag2 )
   {
     status = 0;
     goto wrapup;
   }


wrapup:

  return status;
} /* VD_checkObjectChannelFlagValid */

/*+fe
 -------------------------------------------------------------------------
  Function VD_searchTargetObjectOnChannel

  Abstract
	Function retrieves all right objects on other side s2 of a channel.

  Arguments

	struct GRid		to_obj		I	object on this side
							of the channel.
	OM_S_CHANNUM		chnNum		I	channel number of this
							side of the channel.
   	IGRint			disconnectFlag  I	flag for disconnecting
	IGRint			*count		O	No. of objects on other
							side of the channel.
	struct GRid		*objList	O	object list on other
							side of the channel.

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRint  VD_searchTargetObjectOnChannel( struct GRid  to_obj,
                                        OM_S_CHANNUM chnNum,
					IGRint	     disconnectFlag,
					IGRint	     *count,
					struct GRid  *objList )
{
  IGRint                status, i, j, k, ii, matchFlag, index;
  IGRlong		sts;
  OM_S_CONNECT_SIDE     side1;
  OM_p_CONNECT_SIDE     s1;
  OM_S_CHANSELECT       chnSelect, channel_select;
  struct GRid		frm_obj, bad_obj;
  IGRint		chnCount, chnSize, objFlag;
  GRobjid               objid_max;
  GRspacenum            osnum;
  GRclassid             classId, classIdList[256];
  OM_S_CHANNUM		frm_chnNum, to_chnNum;
  OM_S_OBJECT_LINKAGE   *chnObjList;
  IGRchar               chnName[OM_K_MAXCHANNAME_LEN];


  if( !count ) goto wrapup;

  status = OM_S_SUCCESS;
  s1 = &side1;
  *count = 0;
  osnum = 2;
  chnObjList = NULL;

  /*
  ** Obtain the channel selector.
  */
  status = om$make_chanselect( channum      = chnNum,
                               p_chanselect = &channel_select );
  if( !(status&1) ) return( status );

  status = om$make_chanselect( channum      = chnNum,
                               p_chanselect = &chnSelect );
  if( !(status&1) ) return( status );

  /*
  ** Build side of channel.
  */
  status = om$connect_build_side( osnum  = to_obj.osnum,
                                  objid  = to_obj.objid,
                                  chsel  = &chnSelect,
                                  relidx = 0,
                                  side   = s1 );
  if( !(status&1) )
  {
    om$connect_release_side( side1 = s1 );
    return( status );
  }

  /*
  ** Find channel number of counterpart channel of the channel. For example,
  ** For channel GRcmpowner.to_components, its counterpart channel is
  ** GRconnector.to_owners.
  */
  if( (s1->chdef) )
  {
    if( (s1->chdef->p_type) )
    {
      to_chnNum.classid = s1->chdef->p_type->channum.classid;
      to_chnNum.number  = s1->chdef->p_type->channum.number;
    }
  }

  /*
  ** Retrieve the maximum number of objid in the file.
  */
  objid_max = OM_GA_OSDs[osnum]->CurSpaceMapSize;

  for( i = 1 ; i < objid_max ; i = i + 1 )
  {
    frm_obj.objid = i;
    frm_obj.osnum = osnum;

    sts = om$get_index( osnum_c      = to_obj.osnum,
                        objid_c      = to_obj.objid,
                        p_chanselect = &channel_select,
                        objid        = frm_obj.objid,
                        osnum2       = frm_obj.osnum,
                        indexaddr    = ( OMuint * ) &index );
    if( sts & 1 )
    {
       if( objFlag )
       {
          if( objList )
          {
             objList[index] = frm_obj;
          }
          (*count)++;
       }
    }
  }

  /*
  ** Cycle through all the objects in the file to check if any object connects
  ** to the given object by the counterpart channel.
  */
  for( i = 1 ; i < objid_max ; i = i + 1 )
  {
    frm_obj.objid = i;
    frm_obj.osnum = osnum;
    objFlag = 0;
    status = om$get_classid( objid = frm_obj.objid,
                             osnum = frm_obj.osnum,
                             p_classid = &classId );
    if( !(status&1) ) continue;

    /*
    ** Get the counterpart channel number.
    */
    frm_chnNum.classid = to_chnNum.classid;
    frm_chnNum.number  = to_chnNum.number;

    /*
    ** Get the counterpart chanel name.
    */
    chnName[0] = '\0';
    status = om$get_channel_name( channum  = frm_chnNum,
                                  channame = chnName );
    if( !(status&1) ) continue;

    /*
    ** Get the counterpart channel selector
    */
    status = om$make_chanselect( channum      = frm_chnNum,
                                 p_chanselect = &chnSelect );
    if( !(status&1) ) continue;

    /*
    ** Check whether or not the counterpart channel was corrupted.
    ** If the channel was corrupted,  continue to process next object.
    */
    status = VD_checkObjectChannelFlagValid( frm_obj.osnum,
                                             frm_obj.objid,
                                             &chnSelect );
    if( !(status&1) ) continue;

    /*
    ** If the counterpart channel was not corrupted, retrieve all the objects
    ** on this channel.   Check if any of these objects is the given object.
    */
    chnCount = 0;
    status  = om$get_channel_count( osnum        = frm_obj.osnum,
                                    objid        = frm_obj.objid,
                                    p_chanselect = &chnSelect,
                                    count        = (OMuint *)&chnCount );
    if(!(status&1) || chnCount <= 0 ) continue;

    chnObjList = NULL;
    chnObjList = _MALLOC( chnCount, OM_S_OBJECT_LINKAGE );
    if( chnObjList == NULL )
    {
      printf("Memory allocation failed!\n");
      goto wrapup;
    }
    chnSize = chnCount * sizeof( OM_S_OBJECT_LINKAGE );

    status =
    om$get_channel_objects( osnum        = frm_obj.osnum,
                            objid        = frm_obj.objid,
                            p_chanselect = &chnSelect,
                            list         = chnObjList,
                            size         = chnSize,
                            count        = (OMuint *)&chnCount );
    if( !(status&1) || chnCount <= 0 )
    {
      _FREE( chnObjList );
      chnObjList = NULL;
      continue;
    }

    /*
    ** Check if any of these objects is the given object.  If it is, disconnect
    ** the checking object from the counterpart channel in order to reconnect
    ** later.
    */
    for( k = 0 ; k < chnCount ; k++ )
    {
      if( chnObjList[k].S_objid == to_obj.objid && 
          chnObjList[k].osnum   == to_obj.osnum )
      {
	objFlag = 1;
	if( disconnectFlag )
	  /*
	  ** Disconnect the checking object
	  */
	  status = 
	  VD_disconnectObjectOnChannelByIndex( frm_obj, frm_chnNum, k );
      }
    }

    _FREE( chnObjList );
    chnObjList = NULL;

    /*
    ** Store the checking object which connected to the given object on
    ** the counterpart channel.
    */
    if( objFlag )
    {
      if( objList ) 
      {
        objList[*count] = frm_obj;
      }
      (*count)++;
    }
  }

 status = OM_S_SUCCESS;


wrapup:
  om$connect_release_side( side1 = s1 );
  _FREE( chnObjList );

  return status;
} /* VD_searchTargetObjectOnChannel */

/*+fe
 -------------------------------------------------------------------------
  Function VD_reconnectobjectsOnChannel

  Abstract
	Function reconnects the corrupted object to the right objects.

  Arguments

	struct GRid		to_obj		I	object on this side
							of the channel.
	OM_S_CHANNUM		chnNum		I	channel number of this
							side of the channel.
	IGRint			count		I	No. of objects on other
							side of the channel.
	struct GRid		*objList	I	object list on other
							side of the channel.

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRint  VD_reconnectobjectsOnChannel( struct GRid  to_obj,
                                      OM_S_CHANNUM chnNum,
				      IGRint	   count,
				      struct GRid  *objList )
{
  IGRint                status, i;
  OM_S_CONNECT_SIDE     side1;
  OM_p_CONNECT_SIDE     s1;
  OM_S_CHANSELECT       to_chnSelect, frm_chnSelect;
  OM_S_CHANNUM		to_chnNum;
  IGRchar               chnName[OM_K_MAXCHANNAME_LEN];

  SetProc( VD_reconnectobjectsOnChannel ); Begin

  status = OM_S_SUCCESS;
  s1 = &side1;
  
  if( count <= 0 || objList == NULL ) goto wrapup; 

  status = om$make_chanselect( channum      = chnNum,
                               p_chanselect = &to_chnSelect );
  if( !(status&1) ) return( status );

  /*
  ** Build the side s1 of the channel.
  */
  status = om$connect_build_side( osnum  = to_obj.osnum,
                                  objid  = to_obj.objid,
                                  chsel  = &to_chnSelect,
                                  relidx = 0,
                                  side   = s1 );
  if( !(status&1) )
  {
    om$connect_release_side( side1 = s1 );
    return( status );
  }

  /*
  ** Find counterpart channel number of channel. Explained in detail in 
  ** function VD_searchTargetObjectOnChannel()
  */
  if( (s1->chdef) )
  {
    if( (s1->chdef->p_type) )
    {
      to_chnNum.classid = s1->chdef->p_type->channum.classid;
      to_chnNum.number  = s1->chdef->p_type->channum.number;
    }
  }

  /*
  ** Release the side s1 of the channel
  */
  om$connect_release_side( side1 = s1 );

  status = om$get_channel_name( channum  = to_chnNum,
                                channame = chnName );
  if( !(status&1) ) return( status );

  status = om$make_chanselect( channum      = to_chnNum,
                               p_chanselect = &frm_chnSelect );
  if( !(status&1) ) return( status );

  /*
  ** Reconnect the corrupted object to the right objects.
  */
  __DBGpr_obj(" OBJECT to connect to -->", to_obj );
  for( i = 0 ; i < count ; i++ )
  {
    __DBGpr_obj(" OBJECT to -->", objList[i] );
    status = om$send( msg      = message Root.connect( to_chnSelect,
						       OM_K_MAXINT,
						       objList[i].objid,
						       objList[i].osnum,
						       frm_chnSelect,
						       OM_K_MAXINT ),
                      senderid = NULL_OBJID,
                      targetid = to_obj.objid,
                      targetos = to_obj.osnum );
    if( !(status&1) ){
	__DBGpr_com(" FAILED Root.connect ");
    }
  }

  status = OM_S_SUCCESS;


wrapup:

  End
  return( status );
} /* VD_reconnectobjectsOnChannel */

/*+fe
 -------------------------------------------------------------------------
  Function VD_disconnectObjectOnChannel

  Abstract
	Function disconnects all objects on one side of the channel.  It is 
	similar to the function VD_disconnectObjectOnChannelByIndex() which
        disconnect only one object at the given index.  Can reference to the
        comments in function VD_disconnectObjectOnChannelByIndex().

  Arguments

	struct GRid		to_obj		I	object on this side
							of the channel.
	OM_S_CHANNUM		chnNum		I	channel number of this
							side of the channel.

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRint	VD_disconnectObjectOnChannel( struct GRid  obj,
			     	      OM_S_CHANNUM chnNum )
{
  IGRint                status, num, indx, ii, chanFlag;
  OM_S_CONNECT_SIDE     side1, side2;
  OM_p_CONNECT_SIDE     s1, s2;
  OM_p_CHANNEL_HDR      p_chan;
  OMuword               s1def_flags;
  OM_p_CHANNEL_LINK     link;
  OM_p_OBJID            p_objid;
  IGRchar               set_in_use;
  OM_S_CHANSELECT       chnSelect;


  SetProc( VD_disconnectObjectOnChannel ); Begin

  status = OM_S_SUCCESS;
  s1 = &side1;
  s2 = &side2;
  link = NULL;
  p_objid = NULL;
  set_in_use = FALSE;
  chanFlag = 1;

  status = om$make_chanselect( channum      = chnNum,
                               p_chanselect = &chnSelect );
  if( !(status&1) ) return( status );

  status = om$connect_build_side( osnum  = obj.osnum,
                                  objid  = obj.objid,
                                  chsel  = &chnSelect,
                                  relidx = 0,
                                  side   = s1 );
  if( !(status&1) )
  {
    om$connect_release_side( side1 = s1 );
    return( status );
  }

  p_chan = *(s1->pp_chan);
  if( !p_chan )
  {
    om$connect_release_side( side1 = s1 );
    return( OM_I_CHAN_EMPTY );
  }
  
  num = s1->tail.last_index;
  s1def_flags = s1->chdef->p_type->w_flags;

  if( s1def_flags&CD_restricted )
    p_objid = (OM_p_OBJID)(s1->p_chandata);
  else
    link = (OM_p_CHANNEL_LINK)(s1->p_chandata);

  if( (!(s1def_flags&(CD_1_1|CD_m_1))) &&
      (!(p_chan->flags&OM_CH_in_use)) )
  {
    set_in_use = TRUE;
    p_chan->flags |= OM_CH_in_use;
  }

  if( s1def_flags&CD_restricted )
  {
    for( ii = num ; ii > 0 ; ii-- , p_objid++ )
    {
      if( !IF_NULL_OBJID(*p_objid) )
      {
        s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid;

/* Following two Lines are commented - Rama Rao TR# 5324

        status = om$connect_pside( side1 = s1, side2 = s2 );
        if( 1&status )
*/
	if( 0 )
        {
          if( status == OM_S_SUCCESS )
          {  /* s2 OS may not be loaded - let dangle */
            status = om$connect_disconnect( side1 = s2, side2 = s1 );
            status = om$connect_release_side( side1 = s2 );
          }
          status = om$connect_disconnect( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
        else
	{
 	  status = om$connect_disconnect( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
      } /* close if ! NULL_OBJID */
    } /* close for */
  }
  else
  {
    for( ii = num ; ii > 0 ; ii-- , link++ )
    {
      if( !IF_NULL_OBJID(link->objid) )
      {
        s1->p_chlink = link;
        status = om$connect_pside( side1 = s1, side2 = s2 );
        if( 1&status )
        {
          if( status == OM_S_SUCCESS )
          {  /* s2 OS may not be loaded - let dangle */
            status = om$connect_disconnect( side1 = s2, side2 = s1 );
            status = om$connect_release_side ( side1 = s2 );
          }
          status = om$connect_disconnect( side1 = s1, side2 = s2 );
          status = om$connect_return_chent( side1 = s1 );
        }
        else
  	{
          om$connect_disconnect  ( side1 = s1, side2 = s2 );
          om$connect_return_chent( side1 = s1 );
        }
      } /* close if ! NULL_OBJID */
    } /* close for */
  } /* not restricted */

  if( !(s1def_flags&(CD_1_1|CD_m_1)) )
  {
    if( set_in_use )
      p_chan->flags &= (~OM_CH_in_use); /* clear in_use flag if you set it */
  }


wrapup :
  status = om$connect_release_side( side1 = s1 );

  End
  return ( OM_S_SUCCESS );
} /* VD_disconnectObjectOnChannel */


end implementation Root;
