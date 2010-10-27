/* $Id: VdsQuery.I,v 1.4 2001/06/04 21:43:49 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdlocate/api/VdsQuery.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsQuery.I,v $
 *	Revision 1.4  2001/06/04 21:43:49  ramarao
 *	Fixed TR# 5287.
 *	
 *	Revision 1.3  2001/02/02 21:41:29  ramarao
 *	Fix for ETL# 4635.
 *	
 *	Revision 1.2  2001/01/19 22:01:02  jayadev
 *	changes in SP by HF
 *	
# Revision 1.2  2000/11/08  16:03:58  pinnacle
# Replaced: vds/vdlocate/api/VdsQuery.I for:  by jwfrosch for Service Pack
#
# Revision 1.1  2000/06/28  18:11:44  pinnacle
# Created: vds/vdlocate/api/VdsQuery.I by jwfrosch for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *      06/28/00        HF              Use _MALLOC etc. macros
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	<memory.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"OMparameters.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"exmacros.h"
#include	"grmacros.h"
#include	"AS_status.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDQYdef.h"
#include	"vdparmacros.h"

#include	"vdpktapis.h"
#include	"v_miscmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

extern	IGRint	VDqry_create_object ();

extern	GRclassid	OPP_ACcpx_class_id;

from	GRreffile	import	GRgetenvironment;
from	NDmacro		import	ACtest_consumed;

static IGRint	max_size;

#define MAX_MALLOC	500

/*	#define	DEBUG	*/

/* ***** */

static void VDqryAddObjectEntry( IGRint                 *numObj,
				 struct GRobj_env       **Obj,
				 struct GRobj_env	entry    )
{
   if( (*Obj) == NULL )
   {
      (*Obj) =  _MALLOC( 500, struct GRobj_env );
      max_size = 500;
   }
   else if( (*numObj) == max_size )
   {
      (*Obj) = _REALLOC( (*Obj), (max_size+500), struct GRobj_env );
      max_size += 500;
   }
   (*Obj)[(*numObj)] = entry;
   (*numObj)++;
}

IGRlong	VDQbuildQuery	(	IGRlong			*msg,
				IGRint			where,
				IGRchar			*types,
				IGRchar			*condition,
				struct	GRid		*query	)
{
  IGRlong		sts=OM_S_SUCCESS;
  IGRchar		string[QUERY_LEN];

  /* Initialize */
  query->objid = NULL_OBJID;

  /* Build query string */
  switch (where)
  {
    case -1 :
      sprintf ( string, "select %s", types );
      break;

    case 0  :
      sprintf ( string, "select %s where ! %s",
                types, condition );
      break;

    case 1  :
      sprintf ( string, "select %s where %s",
                types, condition );
      break;
  }

  /* Create query object */
  sts = VDqry_create_object ( msg, query, "API", string, "vd$vds_query() API query" );
  as$status ( sts    = sts,
              msg    = "VDqry_create_object()",
              test   = (!(sts & 0x00000001 & (*msg))),
              action = GOTO_VALUE,
              value  = wrapup );

wrapup:
  return (sts);
}

/* ***** */

IGRboolean VDQvalidate	(	struct	GRid	*obj	)
{
  IGRboolean	ret=FALSE;
  IGRlong		consume;

  /* Verify that object is subclass of ACcpx */
  if ( vd_$is_ancestry_valid ( object  = obj,
                               classid = OPP_ACcpx_class_id ) )
  {

    /* Verify that the object isn't consumed */
    om$send ( msg = message NDmacro.ACtest_consumed (&consume),
              senderid = NULL_OBJID,
              targetid = obj->objid,
              targetos = obj->osnum );
    if (!consume)	ret=TRUE;
  }

  return (ret);
}

/* ***** */

void	VDQscanObjectSpace ( 	struct	GRmd_env	*Env,
				IGRint			*numObj,
				struct	GRobj_env	**Obj	)
{
  IGRint	i;
#ifdef DEBUG
  IGRint	before;
  before = *numObj;
#endif
  struct GRid 		tmp_id;
  struct GRobj_env	tmpObjEnv;

  __enterFunction ( name = "VDQscanObjectSpace" );

  tmp_id.osnum = Env->md_id.osnum;
  ex$get_modid ( mod_osnum =  tmp_id.osnum,
                 mod_id    = &tmp_id.objid );

  tmpObjEnv.mod_env = *Env;
  tmpObjEnv.mod_env.md_id = tmp_id;

  for ( i=0; i < OM_GA_OSDs[Env->md_id.osnum]->CurSpaceMapSize; i++ )
  {
    tmpObjEnv.obj_id.objid = i;
    tmpObjEnv.obj_id.osnum = Env->md_id.osnum;

    if ( VDQvalidate ( &tmpObjEnv.obj_id) )
    {
      VDqryAddObjectEntry( numObj, Obj, tmpObjEnv );
    }
  }

  __exitFunction ( name = "VDQscanObjectSpace", argfmt = "numObj = %d, Env->md_id = [%d,%d]",
                    args = `*numObj, Env->md_id.osnum, Env->md_id.objid` );
#ifdef DEBUG
  printf( "%3d not consumed ACcpx on %d objects in [%2d|%d]\n", *numObj-before,
          OM_GA_OSDs[Env->md_id.osnum]->CurSpaceMapSize,
          Env->md_id.osnum, Env->md_id.objid );
#endif
}

/* ***** */

void	VDQreferenceFiles (	struct	GRmd_env	*Env,
				OM_S_CHANSELECT		Channel,
				IGRint			*numObj,
				struct	GRobj_env	**Obj	)
{
  IGRlong			sts=OM_S_SUCCESS, msg;
  struct	GRid		Mgr, Ref;
  IGRuint			numRef=0;
  IGRint			i, maxObj=0, siz=sizeof(struct GRobj_env);
  IGRint			numOld, numNew;
  struct	GRmd_env	New;

  /* Get Super_rfmgr */
  sts = ex$get_super ( mod_id      = Env->md_id.objid,
                       mod_osnum   = Env->md_id.osnum,
                       super_name  = "Ref Mgr",
                       super_class = "Super_rfmgr",
                       create      = 0,
                       super_id    = &Mgr.objid,
                       super_osnum = &Mgr.osnum );
  if (sts != OM_S_SUCCESS)	return;

  /* Count objects on channel */
  om$get_channel_count ( p_chanselect = &Channel,
                         osnum        = Mgr.osnum,
                         objid        = Mgr.objid,
                         count        = &numRef );

  /* Work on objects on channel */
  for ( i=0; i<numRef; i++ )
  {
    /* Get object on channel */
    Ref.objid = NULL_OBJID;
    Ref.osnum = Env->md_id.osnum;
    om$get_objid_at_index ( osnum        = Mgr.osnum,
                            objid        = Mgr.objid,
                            p_chanselect = &Channel,
                            index        = i,
                            objidaddr    = &Ref.objid,
                            osnumaddr    = &Ref.osnum );

    /* Reference file environment */
    sts = om$send ( msg = message GRreffile.GRgetenvironment ( &msg, Env, &New ),
                    senderid = NULL_OBJID,
                    targetid = Ref.objid,
                    targetos = Ref.osnum );
#ifdef DEBUG
    printf( "From OldEnv [%d|%d] get NewEnv [%d|%d]\n",
            Env->md_id.osnum, Env->md_id.objid,
            New.md_id.osnum, New.md_id.objid );
#endif
    if (  (sts & 0x00000001 & msg)
          && (Env->md_id.osnum != New.md_id.osnum) )
    {
      /* Scan referenced object space */
      VDQscanObjectSpace ( &New, numObj, Obj );

      /* Recursive call */
      VDQreferenceFiles ( &New, Channel, numObj, Obj );
    }
#ifdef DEBUG
    else	printf( "Rejected !\n");
#endif
  }
}

/* ***** */

IGRlong	VDQeligibleList	(	struct	GRmd_env	*CurEnv,
				IGRboolean		ref_search,
				IGRint			*numObj,
				struct	GRobj_env	**Obj	)
{
  IGRlong			sts=OM_S_SUCCESS;
  IGRint			maxObj=0;
  OM_S_CHANSELECT		Super_rfmgr_mgr;

  /* Initialize */
  *numObj = 0;
  *Obj = NULL;

  /* Scan current object space */
  VDQscanObjectSpace ( CurEnv, numObj, Obj );

  /* Make channel */
  om$make_chanselect ( channame     = "Super_rfmgr.mgr",
                       p_chanselect = &Super_rfmgr_mgr );

  /* Retrieve reference files */
  if( ref_search == TRUE )
     VDQreferenceFiles ( CurEnv, Super_rfmgr_mgr, numObj, Obj );

wrapup:
  return (sts);
}

/* ***** */

IGRlong	VDvds_query (	IGRlong			*msg,
			IGRchar			*types,
			IGRint			where,
			IGRchar			*condition,
			IGRboolean		ref_search,
			IGRint			*number,
			struct	GRobj_env	**object	)
{
  IGRlong		sts       = OM_S_SUCCESS, loc_sts, loc_msg;
  IGRlong		siz       = sizeof(struct GRmd_env), ret;
  IGRint		numSearch = 0;
  struct GRmd_env	Env;
  struct GRid		queryObject;
  struct GRobj_env	*Search, *Found;

#ifdef DEBUG
  IGRint		i;
  IGRchar		name[DI_PATH_MAX];
#endif

  __enterFunction ( name = "VDvds_query", argfmt = "types = <%s>, condition = <%s>",
                    args = `types, condition` );

  /* Initialize */
  *msg              = MSFAIL;
  *number           = 0;
  Search            = NULL;
  Found             = NULL;
  queryObject.objid = NULL_OBJID;
  max_size	    = 0;

  if (types[0] == '\0')	goto wrapup;

  /* Get active environment */
  sts = gr$get_module_env ( msg	  = msg,
                            sizbuf = &siz,
                            buffer = &Env,
                            nret   = &ret );
  as$status ( sts    = sts,
              msg    = "gr$get_module_env()",
              test   = (!(sts & 0x00000001 & (*msg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Build query object */
  sts = VDQbuildQuery ( msg, where, types, condition, &queryObject );
  as$status ( sts    = sts,
              msg    = "VDQbuildQuery()",
              test   = (!(sts & 0x00000001 & (*msg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Scan object spaces (including reference files) */
  sts = VDQeligibleList ( &Env, ref_search, &numSearch, &Search );
  as$status ( sts    = sts,
              msg    = "VDQeligibleList()",
              test   = (!(sts & 0x00000001)),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Process query */
  sts =
    vd$qry_process ( sts        = msg,
                     objects    = Search,
                     nb_objects = numSearch,
                     queries    = &queryObject,
                     nb_queries = 1,
                     found      = &Found,
                     nb_found   = number );
  as$status ( sts    = sts,
              msg    = "vd$qry_process()",
              test   = (!(sts & 0x00000001 & (*msg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Fill output array (if needed) */
  if (object)
  {
    *object = NULL;
    if (!(*number))
      goto wrapup;
    //*object = om$calloc ( num = *number, structure = struct GRobj_env );
    *object = _CALLOC ( *number , struct GRobj_env );
    if (!(*object)) {	*msg = MSFAIL;	goto wrapup; }
    else
    {
      int i;
      numSearch = (*number);
      (*number) = 0;

      for( i=0; i<numSearch; ++i )
      {
         if( ( ( ref_search == FALSE ) && 
	       ( Found[i].obj_id.osnum == Env.md_id.osnum ) ) ||
	     ( ref_search == TRUE ) )
	 {
	    (*object)[(*number)++] = Found[i];
	 }
      }
    }
  }

#ifdef DEBUG
  /* Print result */
  for ( i=0; i<*number; i++ )
  {
    om$get_classname ( osnum     = Found[i].obj_id.osnum,
                       objid     = Found[i].obj_id.objid,
                       classname = name );

    printf( "Found %3d is [%2d|%d] in [%2d|%d]\t<%s>\n",
            i, Found[i].obj_id.osnum, Found[i].obj_id.objid,
            Found[i].mod_env.md_id.osnum,
            Found[i].mod_env.md_id.objid, name );
  }
#endif

wrapup:
  if (Found)
  {
    //om$dealloc(ptr = Found);	Found = NULL;
    _FREE ( Found );
  }
  if (Search)
  {
    //om$dealloc(ptr = Search);	Search = NULL;
    _FREE ( Search );
  }
  if (queryObject.objid != NULL_OBJID)
  {
    loc_sts = gr$delete_object ( msg          = &loc_msg,
                                 object_id    = &queryObject,
                                 display_flag = 0 );
    as$status ( sts    = loc_sts,
                msg    = "gr$delete_object()",
                test   = (!(loc_sts & 0x00000001 & loc_msg)) );
  }
  __exitFunction ( name = "VDvds_query", argfmt = "*msg = %d, *number = %d",
                   args = `*msg, *number` );
  return (sts);
}

/* ***** */

end implementation Root;
