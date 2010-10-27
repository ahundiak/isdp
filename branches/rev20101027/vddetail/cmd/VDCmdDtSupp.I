/* $Id: VDCmdDtSupp.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtSupp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtSupp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	File	VDCmdDtSupp.I
	Auteur	Ad Zuurhout

	Description:
   
	    Functions for reference file management !!!

	History:
		Creation Date 01-01-92
	
*/

class implementation Root;

#include <stdio.h>
#include "AS_status.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "exmacros.h"
#include "VDdetail.h"

/* include/prototypes */
/**
  #include "VDpr_dtlref.h"
 **/

#define AS_DEBUG	1

from    Super_rfmgr     import GRget_channel_count, GRget_channel_objects;
from    GRreffile       import GRgetobjinfo, GRgetenvironment;
from	GRcontext	import GRgetinstance;

/*
    Recherche du nombre et de la liste des reference file attaches
    Cette fonction :
           - Demande le module environnement courant (pointeur svp)
           - Renvoie le nombre des reference file attaches dans refcount
           - Alloue et renvoie un tableau de structures dans lequel on
           retrouve le nom et le module env de chaque reference file
*/
/* ********************************************************** */
IGRint	VDdet_get_ref_info( mod_env, refcount, reftab )
/* ********************************************************** */

struct GRmd_env		*mod_env;
IGRlong			*refcount;
struct VDdet_reffile	**reftab;
/*.get_ref_info*/
{
long		sts, status;
OM_S_OBJID	Super_id;
IGRshort	count_nested;
GRobjid		*objlist;
GRspacenum	*oslist;
IGRint		i,j;
IGRlong		count;
IGRulong	prop_mask;
struct GRobj_info	refinfo;
struct VDdet_reffile	*curref, *ref;

  objlist = (GRobjid *)(NULL);
  oslist  = (GRspacenum *)(NULL);
  *refcount = 0;
  count = 0;

  /*| Get id of ref manager */
  status = ex$get_objid_from_NOD(
                        NODname         = "IGENOD",
                        objname         = "Ref Mgr",
                        pobjid          = &Super_id,
                        modid           = mod_env->md_id.objid,
                        mod_osnum       = mod_env->md_id.osnum);
  if(!(status&1)) goto wrapup ;

  /*"Ref Mgr id = %d\n", Super_id */
  /*| Get count of reference file */
  prop_mask = 0;
  count_nested = 0;
  status =
  om$send(msg	   = message Super_rfmgr.GRget_channel_count
                                   (&sts, &prop_mask, &count_nested, &count),
	  senderid = NULL_OBJID,
	  targetid = Super_id,
	  targetos = mod_env->md_id.osnum );
  if(!(status&1)) goto wrapup ;
  /*"Ref count = %d\n", count*/

  /*| Get reference file objects */
  i = (int)count;
  objlist = om$calloc( num = i, structure = GRobjid );
  oslist  = om$calloc( num = i, structure = GRspacenum );

  prop_mask = 0; count_nested = 0;
  status =
  om$send(msg      = message Super_rfmgr.GRget_channel_objects
                                     (&sts, &prop_mask, &count_nested, &count,
                                      objlist, oslist, &count),
	  senderid = NULL_OBJID,
	  targetid = Super_id,
	  targetos = mod_env->md_id.osnum );
  if(!(status&1)) goto wrapup ;

  i = (int) count;
  *reftab = om$calloc( num = i, structure = struct VDdet_reffile );

  /*
   * For all referemce files, get the object space and filename
   */
  curref = *reftab;
  for( i=0; i<count ; i++ ) {
    status =
    om$send(msg      = message GRreffile.GRgetobjinfo( &sts, &refinfo ),
	    senderid = NULL_OBJID,
	    targetid = objlist[i],
	    targetos = oslist[i] );
    if(!(status&1)) continue;

    status =
    om$send(msg      = message GRreffile.GRgetenvironment
                                          ( &sts, mod_env, &(curref->md_env) ),
	    senderid = NULL_OBJID,
	    targetid = objlist[i],
	    targetos = oslist[i] );
    if(!(status&sts&1)) continue;
    
    /*
     * see if this object space is active before
     * trying to use this context object.
     */				
    for(j=0, ref=*reftab;j<*refcount;j++, ref++){
      if( curref->md_env.md_id.osnum == ref->osnum ) break;
    }
    if(j >= *refcount){
      *refcount = *refcount + 1;
      curref->osnum = curref->md_env.md_id.osnum;

      VDdet_arrange_name( refinfo.type );
      strcpy( curref->ref_name, refinfo.type );
      /*" name=%s osnum=%d\n", refinfo.type, curref->md_env.md_id.osnum*/

      curref++;
    }
  }
  if( *refcount < count ){
    i = (int) *refcount;
    i *= sizeof(struct VDdet_reffile);
    *reftab = (struct VDdet_reffile *)om$realloc( ptr  = (char *)*reftab,
						  size = i );
  }

  /*| Free locals allocated ptrs */
  if( objlist ) om$dealloc( ptr = objlist );
  if( oslist )  om$dealloc( ptr = oslist );

  return( OM_S_SUCCESS );

wrapup:
  /*| Free locals allocated ptrs */
  
  if( objlist ) om$dealloc( ptr = objlist );
  if( oslist )  om$dealloc( ptr = oslist );
  if( *reftab ) om$dealloc( ptr = *reftab );
  *refcount = 0;
  return( OM_S_SUCCESS );
}


/* ********************************************************** */
IGRint	VDdet_get_refspace( refcount, reftab )
/* ********************************************************** */

IGRlong			*refcount;
struct VDdet_reffile	**reftab;
/*.VDdet_get_ref_info*/
{
IGRlong		status, sts;
int		i,j;
struct	GRid	Super;
OMuint		count;
OM_S_CHANSELECT super_chan, ref_chan;
struct VDdet_reffile	*curref, *ref;

  *refcount = 0;
  count = 0;

  /*| Get id of ref manager */
  status =
  om$make_chanselect(	channame = "Super_rfmgr.to_context",
			p_chanselect = &super_chan );
  if(!(status&1)) goto wrapup;

  status =
  om$make_chanselect(	channame = "GRcontext.to_reffile",
			p_chanselect = &ref_chan );
  if(!(status&1)) goto wrapup;

  /* get the context Super        */
  status = GRgetctxsuper(&sts,&Super);
  if(!(status&1)) goto wrapup;
  /*" Super : %d,%d\n", Super.objid, Super.osnum */

  status =
  om$get_channel_count( osnum = Super.osnum,
			objid = Super.objid,
			p_chanselect = &super_chan,
			count = &count );
  if(!(status&1)) goto wrapup;

  i = (int)count;
  *reftab = om$calloc( num = i, structure = struct VDdet_reffile );
  curref = *reftab;

  for( i=0; i<count; i++ ){

    status =
    om$send(msg = message GRcontext.GRgetinstance(
					&sts,
					&(curref->mx_type),
					curref->matrix,
					&(curref->osnum),
					&(curref->flags),
					&(curref->ctx_id) ),
	    senderid = Super.objid,
	    targetos = Super.osnum,
	    p_chanselect = &super_chan,
	    to = i, from = i );
    if(!(status&sts&1)) continue;

    if ( !( curref->flags & GRACTIVATED_CONTEXT)) continue;

    status =
    om$os_number_to_name(	osnum	= curref->osnum,
				osname	= curref->ref_name );
    if(!(status&1)) continue;
    
    /*
     * see if this object space is active before
     * trying to use this context object.
     */				

    for(j=0, ref=*reftab;j<*refcount;j++, ref++){
      if(curref->osnum == ref->osnum ) break;
    }
    if(j >= *refcount){
      *refcount = *refcount + 1;
      curref++;
    }
  }

  if( *refcount < count ){
    i = (int) *refcount;
    i *= sizeof(struct VDdet_reffile);
    /* (struct VDdet_reffile *) *reftab = om$realloc( */
    /* (char *) *reftab = */
    om$realloc( ptr  = (char *)*reftab, size = i );
  }

  return( OM_S_SUCCESS );

wrapup:
  if( *reftab) om$dealloc( ptr = *reftab );
  *refcount = 0;
  return( OM_S_SUCCESS );
}


/* Suppression des caracteres en trop dans le nom d'un reference file */
IGRint VDdet_arrange_name( refname )
IGRchar	*refname;
{
int	i;

  for( i=strlen(refname); i>0; i-- ){

    if( refname[i] == ',' ){

      refname[i] = '\0';
      break;
    }
  }

return ( OM_S_SUCCESS );
}



end implementation Root;
