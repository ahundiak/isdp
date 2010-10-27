/* $Id: VDSupdrefdep.I,v 1.3 2001/11/08 17:38:22 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdstartup/imp / VDSupdrefdep.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSupdrefdep.I,v $
 *      Revision 1.3  2001/11/08 17:38:22  ramarao
 *      Fixed TR# 5662.
 *
 *      Revision 1.2  2001/01/22 16:08:49  ahundiak
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/10/24  22:12:52  pinnacle
# turn off hilit
#
# Revision 1.2  2000/09/22  16:37:06  pinnacle
# ylong
#
# Revision 1.1  2000/04/12  22:42:58  pinnacle
# Created: vds/vdstartup/imp/VDSupdrefdep.I by azuurhou for Service Pack
#
# Revision 1.3  2000/04/01  18:10:12  pinnacle
# ylong
#
# Revision 1.2  2000/03/21  19:50:36  pinnacle
# ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1995/10/12  20:38:56  pinnacle
# Replaced: vdstartup/imp/VDSupdrefdep.I for:  by rmanem for vds.240
#
# Revision 1.2  1995/05/02  22:04:48  pinnacle
# Replace: vdstartup/imp/VDSupdrefdep.I by rmanem for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *	10/10/95	rmn	New function VDScheckBrokenConnections 
 *				Modified arguments to include the list of
 *				mismatched and broken connections.
 *	10/11/95	rmn	Backup to previous version with minimal
 *				changes.  Not supporting minimal table
 *				update for now.   For ease of backing up,
 *				the entire functions have been reproduced
 *				and ifdef'ed within MIN_TBL_UPDATE
 *				
 *				Fixed bugs.  If using the MIN_TBL_UPDATE
 *				functionality, must compare to check for
 *				consistency.  Code within MIN_TBL_UPDATE
 *				was not compiled and tested while fixing bugs
 *	03/20/00	ylong	TR179900821, hilite objects before change
 *	04/12/00	adz	TR179901369 Remove TR17990821.
 *	09/22/00	ylong	enable TR179900821 only for VDdrawing not Model.
 *      01/22/01        ah      sp merge
 * -------------------------------------------------------------------*/


class implementation GRcontext ;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "msdef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "refdef.h"
#include "asbox.h"
#include "nddef.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

from NDnode	import	NDchange_node,
			NDget_objects,
			NDmove_to_root ;
from NDmacro	import	ACconsume,
			ACtest_consumed ;
/*----------------------------------------------------------------------------*/
static long VDSprocessConsume( actOs, actEnv )

OMuword		actOs ;
struct GRmd_env *actEnv ; {

	long		sts,
			msg ;
	int		i,
			max ;
	OMuword		osnum,
			classid ;
	struct GRid	dummy ;

	extern OM_p_OSD	*OM_GA_OSDs ;
	extern OMuword	OPP_ACpretendin_class_id ;

	SetProc( VDSprocessConsume ); Begin

	osnum = actOs ;
	max = OM_GA_OSDs[osnum]->CurSpaceMapSize ;

	/*
	 * Loop on all objects in object space, looking for ACpretendin's: they
	 * are the intermediary between associative objects in the master file
	 * and their parents in reference files.
	 */
	for( i = 0 ; i < max ; i++ ) {
		sts = om$get_classid(	objid		= i,
					osnum		= osnum,
					p_classid	= &classid ) ;
		if( !( sts & 1 ) ) continue ;

		if( om$is_ancestry_valid(
				superclassid	= OPP_ACpretendin_class_id,
				subclassid	= classid ) != OM_S_SUCCESS )
			continue ;
		__DBGpr_int( "Got ACpretendin ", i ) ;
		sts = om$send(	msg	= message NDmacro.ACtest_consumed( &msg ),
				senderid= i,
				targetid= i,
				targetos= osnum ) ;

		if( !( sts & 1 & msg ) ) continue ;
		__DBGpr_com( "PRETEND is consumed!!!" ) ;

		sts = om$send(	msg	= message NDmacro.ACconsume(
							&msg, "", FALSE,
							&dummy, actEnv ),
				senderid= i,
				targetid= i,
				targetos= osnum ) ;
		if( !( sts & 1 & msg ) ) {
			__DBGpr_com( "ACconsume FAILED!!!\n" ) ;
		}

	}

	End
	return OM_S_SUCCESS ;

} /* VDSprocessConsume */

/*----------------------------------------------------------------------------*/
static long VDScheckMismatchConnections( osnum, RefOsnum, actEnv, updateFlag,
					p_misCon )

OMuword		osnum,
		RefOsnum ;
struct GRmd_env	*actEnv ;
int		updateFlag,
		*p_misCon ; {

	long			sts ;
	OMuint			misCon;
	int			i, j,
				count;
	OM_S_TAG_CON_INFO	*tags ;
	OM_S_OBJID		tagObjid,
				refObj ;
	OMuword			version,
				hisVersion,
				TagConVers ;
	OM_S_CHANSELECT		toTaggedObj,
				toChild ;
	OMuint			brkCon;
	struct GRid		obj, modelID;
	OM_S_CHANNUM		listener;

	SetProc( VDScheckMismatchConnections ); Begin

	/*
	 * If `updateFlag' is FALSE, the count of mismatched connection is
	 * returned but no updating takes place, otherwise the mismatched
	 * connections are updated.
	 */

	tags = NULL ; *p_misCon = 0 ;

	sts = om$get_channel_number(	channame	= "ASsource.listeners",
					p_channum	= &listener );
	CheckRC( sts, 1 );

	sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= (OMuint *) &misCon ) ;
	if( !( sts & 1 ) ) {
		/*
		 * Object space is probably not tagged, ie. no tagged 
		 * inter-object space connection was made.
		 */
		__DBGpr_int( "Osnum not tagged", RefOsnum );
		return OM_S_SUCCESS ;
	}


	if( !misCon ) {
		/*
		 * No mismatched connections.
		 */
		__DBGpr_int( "No mismatched connections in ", RefOsnum );
/*
		return OM_S_SUCCESS ;
*/
		goto BROKEN;
	}

	__DBGpr_int( "Mismatched connections", misCon ) ;


	tags =  _MALLOC( misCon, OM_S_TAG_CON_INFO ) ;
	if( !tags ) return OM_E_NODYNMEM ;

	sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= &misCon,
					size		= misCon,
					p_tag_con_info	= tags ) ;

	for( i = 0 ; i < misCon ; )
	{
	    om$tag_to_objid(	osnum		= RefOsnum,
				tag		= tags[i].tag,
				p_objid		= &refObj,
				p_version	= &hisVersion );

	    if( tags[i].chan.classid != listener.classid  ||
		tags[i].chan.number  != listener.number   ||
		hisVersion == tags[i].version )
	    {
		/* delete from list */

		for( j = i ; j < misCon-1 ; j++ )
		    tags[j] = tags[j+1];

		misCon--;
	    }
	    else
		i++;
	}

	__DBGpr_int( "Final Mismatched connections", misCon ) ;

	*p_misCon = misCon ;

	/* 
	 * added for TR179900821, hilite mismatched objects, by ylong,
	 * but it takes long time to hilite for big files. Turn off.
	 */
	if(0){ 
	    IGRlong		msg ;
	    IGRint		sts ;
	    IGRint		foundCnt ;
	    struct	GRid	*foundIDs ;
	    struct	GRid	srcID ;
	    GRclassid		classid ;
	    struct		OM_sd_chanselect	chn1, chn2 ;

	    sts = om$make_chanselect (	channame      = "NDchildren.children",
					p_chanselect  = &chn1 ) ;
	    sts = om$make_chanselect (	channame      = "ASsource.listeners",
					p_chanselect  = &chn2 ) ;


	    om$get_classid(	classname = "VDdrawing",
				p_classid = &classid);

	    for( i = 0; i < misCon; i++ ) {
		foundCnt = 0 ;
		foundIDs = NULL ;
		srcID.objid = tags[i].objid ;
		srcID.osnum = osnum ;
		__DBGpr_obj("srcID", srcID) ;
		sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID,
                                        &chn1,
                                        classid,
                                        &foundCnt,
                                        &foundIDs ) ;
		for( j =0; j < foundCnt; j++ ) {
			__DBGpr_obj("foundIDs ", foundIDs[j]) ;
			gr$display_object (	object_id = &foundIDs[j],
						mode	  = GRhd ) ;
		}
		_FREE(foundIDs) ;
		foundIDs = NULL ;
		foundCnt = 0 ;

		sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID,
                                        &chn2,
                                        0 ,		// all classed obj
                                        &foundCnt,
                                        &foundIDs ) ;
		for( j =0; j < foundCnt; j++ ) {
			__DBGpr_obj("all foundIDs ", foundIDs[j]) ;
			gr$display_object (	object_id = &foundIDs[j],
						mode	  = GRhd ) ;
		}
		_FREE(foundIDs) ;
		foundIDs = NULL ;
		foundCnt = 0 ;
	    }

	} /* end TR179900821 */

	if( !updateFlag ) {
/*
		return OM_S_SUCCESS ;
*/
		goto BROKEN;
	}

	for( i = 0 ; i < misCon ; i++ ) {

		__DBGpr_int( "Mismatched id ", tags[i].objid ) ;
		/*
		 * Put object onto the compute batch queue via NDchange_node.
		 * Do not test return code since if object is not subclass of
		 * NDnode, message send will fail...
		 */
		om$send(msg	= message NDnode.NDchange_node( actEnv ),
			senderid= tags[i].objid,
			targetid= tags[i].objid,
			targetos= osnum ) ;
		/*
		 * Have this object's tag version now match that oe its parent.
		 */
		om$tag_to_objid(	osnum	= RefOsnum,
					tag	= tags[i].tag,
					p_objid	= &tagObjid ) ;

		__DBGpr_int( "Tagged objid ", tagObjid ) ;
		/* TR179900821, hilite modified objects  */
		//  modelID.objid = tagObjid ;
		//  modelID.osnum = RefOsnum ;
		//  gr$display_object (	object_id = &modelID,
		//  			mode	  = GRhd ) ;

		toTaggedObj.type		= OM_e_num ;
		toTaggedObj.u_sel.number	= tags[i].tag_chan ; 
		toChild.type			= OM_e_num ;
		toChild.u_sel.number		= tags[i].chan ;

		om$test_connection(
				objid			= tags[i].objid,
				osnum			= osnum,
				p_chanselect		= &toChild,
				tag_osnum		= RefOsnum,
				tag_objid		= tagObjid,
				p_tag_version		= &version,
				p_tag_connect_version	= &TagConVers,
				p_tag_chanselect	= &toTaggedObj,
				force_flag		= TRUE ) ;
					
					
	}


	_FREE( tags ) ;

BROKEN :

    	__DBGpr_int("\nChecking for broken connections in\n", RefOsnum);

        tags = NULL ; brkCon = 0;

        sts = om$broken_connects(	osnum           = osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = (OMuint *) &brkCon ) ;

        if( !( sts & 1 ) ) {
                /*
                 * Object space is probably not tagged, ie. no tagged
                 * inter-object space connection was made.
                 */
		__DBGpr_int( "Osnum not tagged", RefOsnum );
                return OM_S_SUCCESS ;
        }

        __DBGpr_int( "Initial broken connections ", brkCon ) ;

        if( !brkCon ) {
                /*
                 * No broken connections.
		 */

		__DBGpr_int( "No broken connections in ", RefOsnum );
                return OM_S_SUCCESS ;
        }

	/* 
	 * need to get the list, in order to verify that they do have
	 * dependencies in the active file 
	 */

        tags = _MALLOC( brkCon, OM_S_TAG_CON_INFO ) ;
        if( !tags ) return OM_E_NODYNMEM ;

        sts = om$broken_connects( 	osnum           = osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = &brkCon,
                                        size            = brkCon,
                                        p_tag_con_info  = tags ) ;

#if 0
	/* Commented for TR# 5662. */
	for( i = 0 ; i < brkCon ; )
	{
	    count = 0;
	    sts = om$send(	msg	= message NDnode.NDget_objects(
						ND_CHILDREN,
						NULL, 0, NULL, 0, OM_K_MAXINT,
						&count ),
				senderid= NULL_OBJID,
				targetid= tags[i].objid,
				targetos= osnum );

	    if( tags[i].chan.classid != listener.classid  ||
		tags[i].chan.number  != listener.number   ||
		!(sts & 1) || count < 1 )
	    {
		/* delete from list */

		for( j = i ; j < brkCon-1 ; j++ )
		    tags[j] = tags[j+1];

		brkCon--;
	    }
	    else
		i++;
	}
#endif

	for( i = 0 ; i < brkCon ; ++i )
	{
            count = 0;
            sts = om$send(      msg     = message NDnode.NDget_objects(
                                                ND_CHILDREN,
                                                NULL, 0, NULL, 0, OM_K_MAXINT,
                                                &count ),
                                senderid= NULL_OBJID,
                                targetid= tags[i].objid,
                                targetos= osnum );

            if( tags[i].chan.classid != listener.classid  ||
                tags[i].chan.number  != listener.number   ||
                !(sts & 1) || count < 1 ) tags[i].objid = NULL_OBJID ;
	}

	j = 0;
        for( i = 0 ; i < brkCon ; ++i )
        {
	   if( tags[i].objid != NULL_OBJID )
	   {
	      tags[j] = tags[i] ;
	      ++j; 
	   }
	}
	brkCon = j;

	__DBGpr_int( "Nb broken connections", brkCon );

	*p_misCon += brkCon;
	__DBGpr_int( "Final total number of connections", *p_misCon );

        if( !updateFlag ) {
		sts = OM_S_SUCCESS;
                goto wrapup;
        }

        for( i = 0 ; i < brkCon ; i++ ) {

		__DBGpr_int( "Broken id ", tags[i].objid );

                /*
                 * Send NDmove_to_root message to dependencies.
                 */
                om$send(msg     = message NDnode.NDmove_to_root( &sts,
								&obj,
								actEnv ),
                        senderid= tags[i].objid,
			p_chanselect = &ND_children,
                        targetos= osnum ) ;

		/* delete the temporary pretendin object */

		__DBGpr_int( "Deleting object id", tags[i].objid );
		om$send(msg	= message Root.delete( 0 ),
			senderid= NULL_OBJID,
			targetid= tags[i].objid,
			targetos= osnum );
	}

wrapup :
	_FREE( tags );

	End
	return sts ;

} /* VDScheckMismatchConnections */
/*----------------------------------------------------------------------------*/

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */

static long VDScheckMismatchConnections( osnum, RefOsnum, actEnv, updateFlag,
					p_misCon, lMismatch )

OMuword			osnum,
			RefOsnum ;
struct GRmd_env		*actEnv ;
int			updateFlag,
			*p_misCon ; 
OM_S_TAG_CON_INFO	lMismatch[];
{

	long			sts ;
	OMuint			misCon;
	int			i ;
	OM_S_OBJID		tagObjid,
				refObjid;
	OMuword			version,
				hisVersion,
				TagConVers ;
	OM_S_CHANSELECT		toTaggedObj,
				toChild ;
	OM_S_TAG_CON_INFO	*tags = NULL;
	OM_S_CHANNUM		listener;

	SetProc( VDScheckMismatchConnections ); Begin

	/*
	 * If `updateFlag' is FALSE, the count of mismatched connection is
	 * returned but no updating takes place, otherwise the mismatched
	 * connections are updated.
	 * The list of mismatched connections is returned if lMismatch != NULL
	 */

	*p_misCon = 0 ;

	sts = om$get_channel_number(	channame	= "ASsource.listeners",
					p_channum	= &listener );
	CheckRC( status, 1 );

	/* get number of mismatched connections */

	sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= &misCon );

	if( !( sts & 1 ) ) {
		/*
		 * Object space is probably not tagged, ie. no tagged 
		 * inter-object space connection was made.
		 */
		__DBGpr_int( "Osnum not tagged", RefOsnum ) ;
		sts = OM_S_SUCCESS ;
		goto wrapup;
	}

	if( !misCon ) {
		/*
		 * No mismatched connections.
		 */
		__DBGpr_int( "No mismatched connections in ", RefOsnum ) ;
		sts = OM_S_SUCCESS ;
		goto wrapup;
	}

	/* get the list of mismatched connections */

	if( lMismatch )
	{
	    sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= &misCon,
					size		= misCon,
					p_tag_con_info	= lMismatch ) ;
	}

	/* if we need to update, but lMismatch = NULL, must allocate memory */

	if( !lMismatch )
	{
	    tags = _MALLOC( misCon, OM_S_TAG_CON_INFO );
	    if( !tags )
	    {
		sts =  OM_E_NODYNMEM;
		goto wrapup;
	    }

	    sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= &misCon,
					size		= misCon,
					p_tag_con_info	= tags ) ;
	}
	else
	    tags = lMismatch;

#if 0
	/* Commented for TR# 5662 */
	for( i = 0 ; i < misCon ; )
	{
	    om$tag_to_objid(	osnum		= RefOsnum,
				tag		= tags[i].tag,
				p_objid		= &refObj,
				p_version	= &hisVersion );

	    if( tags[i].chan.classid != listener.classid  ||
		tags[i].chan.number  != listener.number   ||
		hisVersion == tags[i].version )
	    {
		/* delete from list */

		for( j = i ; j < misCon-1 ; j++ )
		    tags[j] = tags[j+1];

		misCon--;
	    }
	    else
		i++;
	}
#endif

	for( i = 0 ; i < misCon ; ++i )
        {
            om$tag_to_objid(    osnum           = RefOsnum,
                                tag             = tags[i].tag,
                                p_objid         = &refObj,
                                p_version       = &hisVersion );

            if( tags[i].chan.classid != listener.classid  ||
                tags[i].chan.number  != listener.number   ||
                hisVersion == tags[i].version ) 
	      tags[i].objid = NULL_OBJID;
	}

	j = 0;
        for( i = 0 ; i < misCon ; ++i )
        {
	   if( tags[i].objid != NULL_OBJID )
	   {
		tags[j] = tags[i] ;
		++j;
	   }
	}
	misCon = j;

	*p_misCon = misCon ;
	__DBGpr_int( "Final mismatched connections", misCon );

	if( !updateFlag ) 
	{
		sts = OM_S_SUCCESS ;
		goto wrapup;
	}

	for( i = 0 ; i < misCon ; i++ ) {

		__DBGpr_int( "Mismatched id ", tags[i].objid ) ;
		/*
		 * Put object onto the compute batch queue via NDchange_node.
		 * Do not test return code since if object is not subclass of
		 * NDnode, message send will fail...
		 */
		om$send(msg	= message NDnode.NDchange_node( actEnv ),
			senderid= tags[i].objid,
			targetid= tags[i].objid,
			targetos= osnum ) ;
		/*
		 * Have this object's tag version now match that of its parent.
		 */
		om$tag_to_objid(	osnum	= RefOsnum,
					tag	= tags[i].tag,
					p_objid	= &tagObjid ) ;

		__DBGpr_int( "Tagged objid ", tagObjid ) ;

		toTaggedObj.type		= OM_e_num ;
		toTaggedObj.u_sel.number	= tags[i].tag_chan ; 
		toChild.type			= OM_e_num ;
		toChild.u_sel.number		= tags[i].chan ;

		om$test_connection(
				objid			= tags[i].objid,
				osnum			= osnum,
				p_chanselect		= &toChild,
				tag_osnum		= RefOsnum,
				tag_objid		= tagObjid,
				p_tag_version		= &version,
				p_tag_connect_version	= &TagConVers,
				p_tag_chanselect	= &toTaggedObj,
				force_flag		= TRUE ) ;
					
					
	}

	if( tags != lMismatch )
	    _FREE( tags );

	wrapup :
	End
	return sts ;

} /* VDScheckMismatchConnections */

/*----------------------------------------------------------------------------*/
static long VDScheckBrokenConnections( 	osnum, RefOsnum, actEnv, updateFlag,
					p_brkCon, lBroken )

OMuword			osnum,
			RefOsnum ;
struct GRmd_env		*actEnv ;
int			updateFlag,
			*p_brkCon ; 
OM_S_TAG_CON_INFO	lBroken[];
{

	long			sts ;
	int			i, j,
				count ;
	OMuint			brkCon;
	struct GRid		obj;
	OM_S_TAG_CON_INFO	*tags = NULL;
	OM_S_CHANNUM		listener;

	SetProc( VDScheckBrokenConnections ); Begin

	/*
	 * If `updateFlag' is FALSE, the count of broken connection is
	 * returned but no updating takes place, otherwise the broken
	 * connections are updated.
	 * The list of broken connections is returned if lBroken != NULL
	 */

	*p_brkCon = 0 ;
        brkCon = 0;

	sts = om$get_channel_number(	channame	= "ASsource.listeners",
					p_channum	= &listener );
	CheckRC( status, 1 );

        sts = om$broken_connects(	osnum           = osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = (OMuint *) &brkCon ) ;
	__DBGpr_int( "Initial Nb broken connections", brkCon );

        if( !( sts & 1 ) ) {
                /*
                 * Object space is probably not tagged, ie. no tagged
                 * inter-object space connection was made.
                 */
		__DBGpr_int( "Osnum not tagged", RefOsnum );
                sts =  OM_S_SUCCESS ;
		goto wrapup;
        }

        if( !brkCon ) {
                /*
                 * No broken connections.
		 */
		__DBGpr_int( "No broken connections in", RefOsnum );
                sts = OM_S_SUCCESS ;
		goto wrapup;
        }

	if( lBroken )
	{
            sts = om$broken_connects( 	osnum           = osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = &brkCon,
                                        size            = brkCon,
                                        p_tag_con_info  = lBroken ) ;
	}

	/* if lBroken = NULL, must allocate memory */

	if( !lBroken )
	{
	    tags = _MALLOC( brkCon, OM_S_TAG_CON_INFO );
	    if( !tags )
	    {
		sts = OM_E_NODYNMEM;
		goto wrapup;
	    }

            sts = om$broken_connects( 	osnum           = osnum,
                                        tagged_osnum    = RefOsnum,
                                        p_count         = &brkCon,
                                        size            = brkCon,
                                        p_tag_con_info  = tags ) ;
	}
	else
	    tags = lBroken;

	for( i = 0 ; i < brkCon ; )
	{
	    count = 0;
	    sts = om$send(	msg	= message NDnode.NDget_objects(
						ND_CHILDREN,
						NULL, 0, NULL, 0, OM_K_MAXINT,
						&count ),
				senderid= NULL_OBJID,
				targetid= tags[i].objid,
				targetos= osnum );

	    if( tags[i].chan.classid != listener.classid  ||
		tags[i].chan.number  != listener.number   ||
		!(sts & 1) || count < 1 )
	    {
		/* delete from list */

		for( j = i ; j < brkCon-1 ; j++ )
		    tags[j] = tags[j+1];

		brkCon--;
	    }
	    else
		i++;
	}

	*p_misCon = brkCon;

	__DBGpr_int( "Final total number of connections", *p_misCon );

        if( !updateFlag ) {
                return OM_S_SUCCESS ;
        }

        for( i = 0 ; i < brkCon ; i++ ) {

		__DBGpr_int( "Broken id ", tags[i].objid );

                /*
                 * Send NDmove_to_root message to dependencies.
                 */
                om$send(msg     = message NDnode.NDmove_to_root( &sts,
								&obj,
								actEnv ),
                        senderid= tags[i].objid,
			p_chanselect = &ND_children,
                        targetos= osnum ) ;

		/* delete the temporary pretendin object */

		__DBGpr_int( "Deleting object id", tags[i].objid );
		om$send(msg		= message Root.delete( 0 ),
			senderid	= NULL_OBJID,
			targetid	= tags[i].objid,
			targetos	= osnum );
	}

	if( tags != lBroken )
	    _FREE( tags );

    wrapup :
	End
	return sts ;

} /* VDScheckBrokenConnections */

#endif			/* -----------End MIN_TBL_UPDATE-------------- */


/*----------------------------------------------------------------------------*/

#ifdef MIN_TBL_UPDATE	/* -----------Begin MIN_TBL_UPDATE------------ */

long VDScheckRefFilesDependency(	msg, updateFlag, 
					nbMismatch, lMismatch,
					nbBroken, lBroken, 
					nbModRef, ModRefList,	
					nbBrkRef, BrkRefList )
long 			*msg ;
int			updateFlag;	/* 1 = update, 0 = don't update      */	
int			*nbMismatch ;	/* Total nb of mismatch connections  */
OM_S_TAG_CON_INFO	lMismatch[] ;	/* list of mismatch connections      */
int			*nbBroken ;	/* Total nb of broken connections    */
OM_S_TAG_CON_INFO	lBroken[] ;	/* List of broken connections        */
int			*nbModRef ;	/* Nb of ref files with modified objs*/
OMuword			ModRefList[] ;  /* list of ref files wih mod objs    */
int			*nbBrkRef ;	/* Nb of ref files with deleted objs */
OMuword			BrkRefList[] ; 	/* list of ref files with del objs   */

#endif 			/* -----------End MIN_TBL_UPDATE------------- */

long VDScheckRefFilesDependency( msg, updateFlag, nbModRef, ModRefList )
long 	*msg ;
int	updateFlag,
	*nbModRef;
OMuword ModRefList[];
{

	long 		sts,		/* OM return code		*/
			numberOfBytes,
			BytesReceived ;
	char 		osname[OM_K_MAXOSNAME_LEN];
	short		flag ;
	int  		count,		/* ... of contexts		*/
			misCon,		/* Count of mismatched
					   connection in one ref. file	*/
#ifdef MIN_TBL_UPDATE	/* -----------Begin MIN_TBL_UPDATE------------ */
			brkCon,		/* count of broken conntions
					   in one ref. file 		*/
			misInd,		/* index into lMismatch 	*/
			brkInd,		/* index into lBroken	 	*/
			brkRef,		/* Count of ref files with 
					   broken connections		*/
#endif			/* -----------End MIN_TBL_UPDATE-------------- */
			modRef,		/* Count of modified ref. files	*/
    			i ;		/* Loop index			*/
	OMuword		RefOsnum ;	/* Osnum of a ref file		*/
	struct GRid	ctxId,		/* the context id 		*/	
			rfmgr ;		/* Id of ref. file mgr		*/
	OM_S_CHANSELECT rfmgrTOctx ;	/* Ref. file mgr -> context	*/

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */

	OM_S_TAG_CON_INFO *pMismatch;	/* pointer to lMismatch		*/
	OM_S_TAG_CON_INFO *pBroken;	/* pointer to lBroken		*/
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

	struct GRmd_env	ctxEnv,		/* Environment from context	*/
			ActiveEnv ;	/* Environment of mater file	*/

	SetProc( VDScheckRefFilesDependency ); Begin

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
	/*
	 * If `updateFlag' is FALSE then the list and  count of reference files
	 * which have mismatched/broken connections is returned and no 
	 * update of the active file takes place, otherwise the active file 
	 * is updated.
	 * Outputs nbMismatch, nbBroken, nbModRef, nbBrkRef,
	 *     lMismatch, lBroken, ModRefList, BrkRefList are suppressed if NULL
	 */
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

        /*
         * If `updateFlag' is FALSE then the list and  count of reference files
         * which have changed is returned and no update of the active file
         * takes place, otherwise the active file is updated.
         */


#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
	brkRef  = 0 ;
	misInd  = brkInd = 0;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

	modRef	= 0 ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	if( nbModRef ) *nbModRef = 0 ;

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
	if( nbMismatch ) *nbMismatch = 0 ;
	if( nbBroken ) *nbBroken = 0 ;
	if( nbBrkRef ) *nbBrkRef = 0 ;

	pMismatch = pBroken = NULL;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

	numberOfBytes = sizeof ActiveEnv ;
	gr$get_module_env(	msg	= msg,
				sizbuf	= &numberOfBytes,
				buffer	= &ActiveEnv,
				nret	= &BytesReceived ) ;

	__DBGpr_int( "Active osnum", ActiveEnv.md_id.osnum ) ;

	/*
	 * Reconsume objects in reference files.
	 */
	VDSprocessConsume( ActiveEnv.md_id.osnum, &ActiveEnv ) ;
		
	/*
	 * Get all attached reference files and process mismatched connections
	 * in all of them.
	 */
	sts = om$make_chanselect(	
				channame	= "Super_rfmgr.to_context",
				p_chanselect	= &rfmgrTOctx ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Get the context Super.
	 */
	sts = GRgetctxsuper( msg, &rfmgr ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = om$get_channel_count(	osnum		= rfmgr.osnum,
					objid		= rfmgr.objid,
					p_chanselect	= &rfmgrTOctx,
					count		= (OMuint *) &count ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Loop on contexts.
	 */
	for( i = 0 ; i < count ; ++i ) {

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
							msg,
							&ctxEnv.md_env.matrix_type,
							ctxEnv.md_env.matrix,
							&RefOsnum,
							&flag,
							&ctxId ),
			senderid	= rfmgr.objid,
			targetos	= rfmgr.osnum,
			p_chanselect	= &rfmgrTOctx,
			to		= i,
			from		= i ) ;

		if( !( 1 & sts & *msg ) ) continue ;

		if( flag & GREMPTY_CONTEXT ) continue ;

		/*
		 * See if this object space is active before
		 * trying to use this context object.
		 */
		 sts = om$os_number_to_name(	osnum	= RefOsnum,
						osname	= osname ) ;
		__DBGpr_str( "Osname ", osname ) ;

		if( !( 1 & sts ) ) {
			/*
			 * Skip this osnum.
			 */
			__DBGpr_int("No OS name for", RefOsnum );
			continue ;
		}

		if( !( flag & GRACTIVATED_CONTEXT ) ) {
			/*
			 * This is the master file. Skip it.
			 */
			__DBGpr_str("Context not active for", osname );
			continue ;
		}

		sts = VDScheckMismatchConnections(	ActiveEnv.md_id.osnum,
							RefOsnum,
							&ActiveEnv,
							updateFlag,
							&misCon );
		__DBGpr_int( "\t\tmisCon", misCon );

		if( misCon ) {
			if( ModRefList ) ModRefList[modRef] = RefOsnum;
			modRef++;	
		}

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
		if( lMismatch )
		    pMismatch = &lMismatch[misInd];
		sts = VDScheckMismatchConnections(	ActiveEnv.md_id.osnum,
							RefOsnum,
							&ActiveEnv,
							updateFlag,
							&misCon,
							pMismatch ) ;
		__DBGpr_int( "misCon", misCon );

		if( misCon ) {
			if( ModRefList ) ModRefList[modRef] = RefOsnum ;
			modRef++;
			if( nbMismatch ) *nbMismatch += misCon;
			misInd += misCon;
		}
			
		if( lBroken )
		    pBroken = &lBroken[brkInd];
		sts = VDScheckBrokenConnections(	ActiveEnv.md_id.osnum,
							RefOsnum,
							&ActiveEnv,
							updateFlag,
							&brkCon,
							pBroken ) ;
		__DBGpr_int( "brkCon", brkCon );

		if( brkCon ) {
			if( BrkRefList ) BrkRefList[brkRef] = RefOsnum ;
			brkRef++;
			if( nbBroken ) *nbBroken += brkCon;
			brkInd += brkCon;
		}
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

	} /* End for */

	if( nbModRef ) *nbModRef = modRef ;
	__DBGpr_int( "\t\tmodRef", modRef );

#ifdef MIN_TBL_UPDATE   /* -----------Begin MIN_TBL_UPDATE------------ */
	if( nbBrkRef ) *nbBrkRef = brkRef ;
#endif                  /* -----------End MIN_TBL_UPDATE-------------- */

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

    wrapup :
		End
		return sts ;

} /* VDScheckRefFilesDependency */
/*----------------------------------------------------------------------------*/

end implementation GRcontext ;

