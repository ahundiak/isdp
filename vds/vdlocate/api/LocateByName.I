/* $Id: LocateByName.I,v 1.2 2001/01/19 22:00:32 jayadev Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdlocate/api/LocateByName.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: LocateByName.I,v $
 *	Revision 1.2  2001/01/19 22:00:32  jayadev
 *	changes in SP by HF
 *	
# Revision 1.1  2000/06/28  18:11:34  pinnacle
# Created: vds/vdlocate/api/LocateByName.I by jwfrosch for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *      06/28/00        HF              Use _MALLOC etc. macros
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
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
#include	"AS_status.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDmsg.h"
#include	"VDSpathdef.h"
#include	"VDStextdef.h"
#include	"VDSudp_mac.h"

#include	"vdpktapis.h"
#include	<v_miscmacros.h>

#define	VD_DEBUG
#include	<VDdebug.h>

#define	LBN_ALLOC_SIZE	10

extern	GRclassid	OPP_DIrectory_class_id;

from	GRcontext	import	GRgetmodule_env;

/* ***** */

IGRboolean	LBNcheckInput (	IGRchar	*string,
				IGRint	length,
				IGRchar	*txtset	)
{
  if ( (string == NULL) || (string[0] == '\0') )
  {
    txtset[0] = '\0';
    return TRUE;
  }
  else if (strlen (string) > length)
  {
    strncpy ( txtset, string, length );
    return FALSE;
  }
  else
  {
    strcpy ( txtset, string );
    return TRUE;
  }
}

/* ***** */

IGRboolean	LBNexpandInput (	IGRchar		*string,
					IGRchar		***yLst,
					IGRuint		*yMax,
					IGRchar		***nLst,
					IGRuint		*nMax,
					IGRlong		*msg		)
{
  IGRchar		retMsg[20];
  IGRlong		errKey;

  /* Initialize */
  *msg = MSFAIL;
  UI_status ("");

  /* Expand regular expression if needed */
  if ( string[0] != '\0' )
  {
    if (vds_getreg ( string, yLst, yMax, nLst, nMax,
                     &errKey, &retMsg ) != 1 )
    {
      if (errKey)	ex$message ( msgnumb = errKey,
                                     type    = "%s",
                                     var     = `retMsg` );
      return FALSE;

    }
  }
  else
  {
    *yMax = *nMax = 0;
    *yLst = *nLst = NULL;
  }

  /* Successful completion */
  *msg = MSSUCC;
  return TRUE;
}

/* ***** */

void	LBNdealloc (	IGRuint cnt,	IGRchar ***buf	)
{
  IGRint	i;

  if (*buf)
  {
    for ( i=0; i<cnt; i++)
    {
      if ( (*buf)[i] )
      {
        //om$dealloc (ptr = (*buf)[i]); (*buf)[i] = NULL;
        _FREE ((*buf)[i]);
      }
    }
    //om$dealloc (ptr = *buf); *buf = NULL;
    _FREE (*buf);
  }
}

/* ***** */

IGRboolean	LBNfindAttach ( IGRchar			*event,
				IGRchar			*attach,
				struct	GRmd_env	*Env,
				struct	GRid		*object	)
{
  IGRint		sts, i;
  OM_S_CHANSELECT	chan;
  IGRuint		Cnum=0;
  struct	GRid	Cobj, *Oobj;
  DIchar		Dnam[DI_PATH_MAX], **Onam;
  DIgrid		Dobj;
  IGRboolean		found=FALSE;

  /* Initialize */
  object->objid = NULL_OBJID;
  Cobj.objid    = NULL_OBJID;
  Dnam[0]       = '\0';
  Dobj.objid    = NULL_OBJID;
  Oobj          = NULL;
  Onam          = NULL;

  /* Get directory full name */
  sts = di$split ( pathname = event, dirname = Dnam );
  as$status ( sts    = sts,
              msg    = "di$split()",
              test   = (sts != DIR_S_SUCCESS),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Get directory ID */
  sts = di$translate ( objname = Dnam,
                       p_objid = &Dobj.objid,
                       p_osnum = &Dobj.osnum );
  as$status ( sts    = sts,
              msg    = "di$translate()",
              test   = (sts != DIR_S_SUCCESS),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Make channel selection */
  om$make_chanselect ( channame = "Super_rfmgr.mgr",
                       p_chanselect = &chan );

  /* Get channel ID */
  sts = ex$get_super ( mod_id      = Env->md_id.objid,
                       mod_osnum   = Env->md_id.osnum,
                       super_name  = "Ref Mgr",
                       super_class = "Super_rfmgr",
                       create      = 0,
                       super_id    = &Cobj.objid,
                       super_osnum = &Cobj.osnum );
  as$status ( sts    = sts,
              msg    = "ex$get_super()",
              test   = (sts != OM_S_SUCCESS),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Count objects on channel */
  om$get_channel_count ( p_chanselect = &chan,
                         osnum        = Cobj.osnum,
                         objid        = Cobj.objid,
                         count        = &Cnum );
  if (Cnum <= 0)
  {
    printf( "%d objects found on channel [%d|%d]\n",
            Cnum, Cobj.osnum, Cobj.objid );
    return FALSE;
  }

  /* Allocate memory */
  //Oobj = om$calloc ( num = Cnum, structure = struct GRid );
  //Onam = om$calloc ( num = Cnum, structure = IGRchar * );
  Oobj = _CALLOC ( Cnum , struct GRid );
  Onam = _CALLOC ( Cnum , IGRchar * );
  for ( i=0; i<Cnum; i++ )
  {
    Onam[i] = NULL;
    //Onam[i] = om$calloc ( num = DI_PATH_MAX, structure = IGRchar );
    Onam[i] = _CALLOC ( DI_PATH_MAX , IGRchar );
  }

  /* Get channel objects */
  for ( i=0; i<Cnum; i++ )
  {
    /* Get channel object at index i */
    om$get_objid_at_index ( osnum        = Cobj.osnum,
                            objid        = Cobj.objid,
                            p_chanselect = &chan,
                            index        = i,
                            objidaddr    = &Oobj[i].objid,
                            osnumaddr    = &Oobj[i].osnum );

    /* Untranslate object */
    sts = di$untranslate ( objname = Onam[i],
                           objid   = Oobj[i].objid,
                           osnum   = Oobj[i].osnum );
    as$status ( sts    = sts,
                msg    = "di$untranslate()",
                test   = (sts != DIR_S_SUCCESS),
                action = GOTO_VALUE,
                value  = wrapup );

    /* Get object relative name */
    sts = di$split ( pathname = Onam[i],
                     name     = Onam[i] );
    as$status ( sts    = sts,
                msg    = "di$split()",
                test   = (sts != DIR_S_SUCCESS),
                action = GOTO_VALUE,
                value  = wrapup );

    if ( (attach[0] != '\0') && (! strcmp ( attach, Onam[i] ) ) )
    {
      found = TRUE;
      *object = Oobj[i];
      break;
    }
  }

wrapup:
  LBNdealloc ( Cnum, (IGRchar ***) &Onam );
  if (Oobj)
  {
    //om$dealloc (ptr = Oobj);	Oobj = NULL;
    _FREE (Oobj);
  }

  return found;
}

/* ***** */

IGRlong	LBNlocateObject (	IGRchar			*event,
				struct	GRmd_env	*Env,
				IGRchar			*Path,
				IGRchar			*attach,
				IGRint			*count,
				IGRint			*number,
				struct	GRobj_env	**object,
				IGRlong			*msg	)
{
  IGRlong			sts=OM_S_SUCCESS;
  IGRboolean			abs=FALSE;
  IGRchar			pathname[DI_PATH_MAX], **Snam;
  IGRint			i, j, pathlen=0;
  IGRint			siz=sizeof(struct GRobj_env);
  IGRuint			Snum=1;
  DIchar			***lin;
  DIgrid			**exp;
  DIint				*num;
  GRclassid			clid;
  struct	GRid		Aobj, Cobj;
  struct	GRmd_env	*env;
  OM_S_CHANSELECT		chan;
  DIchar			path[DI_PATH_MAX];

  /* Initialize */
  sprintf ( pathname, "%s%s", Path, VDS_REF_DIR );
  pathlen = strlen (pathname);
  lin = NULL;
  exp = NULL;
  num = NULL;
  env = NULL;
  Aobj.objid = Cobj.objid = NULL_OBJID;
  Snam = NULL;
  om$make_chanselect( channame     = "GRreffile.to_context",
                      p_chanselect = &chan);

  /* Set absolute path flag (if needed) */
  if (event[0] == ':')	abs = TRUE;

  /* Get search pathes (if needed) */
  if (!abs)
  {
    sts = vds$get_search_path ( nb_search	= (IGRint *) &Snum,
                                search_path = &Snam );
    as$status ( sts    = sts,
                msg    = "vds$get_search_path()",
                test   = (!(sts & 0x00000001) || (Snum <= 0) ),
                action = GOTO_VALUE,
                value  = wrapup );
  }

  /* Allocate arrays */
  //lin = om$calloc ( num = Snum, structure = DIchar ** );
  //exp = om$calloc ( num = Snum, structure = DIgrid * );
  //num = om$calloc ( num = Snum, structure = DIint );
  //env = om$calloc ( num = Snum, structure = struct GRmd_env );
  lin = _CALLOC ( Snum , DIchar ** );
  exp = _CALLOC ( Snum , DIgrid * );
  num = _CALLOC ( Snum , DIint );
  env = _CALLOC ( Snum , struct GRmd_env );

  /* General Loop */
  for ( i=0; i<Snum; i++ )
  {
    /* Initialize arrays */
    lin[i] = (DIchar **) NULL;
    exp[i] = (DIgrid *) NULL;
    num[i] = (DIint) 0;
    env[i] = *Env;
    if (abs)	strcpy( path, event );
    else		sprintf( path, "%s:%s", Snam[i], event );

    /* Search in EMS directories */
    sts = di$dump ( regexp = path,
                    lines  = &lin[i],
                    grids  = &exp[i],
                    ptr    = &num[i] );
    if (sts != DIR_S_SUCCESS)	goto nextstep;

    /* Reallocate memory if needed */
    if ( *count < *number+num[i] )
    {
      //*object = (struct GRobj_env *) om$realloc ( ptr  = (IGRchar *) *object,
      //                                            size = (*number+num[i]) * siz );
      *object = _REALLOC ( *object, (*number+num[i]) , struct GRobj_env );
    }

    /* Verify if there is a least an EMS directory */
    for ( j=0; j<num[i]; j++)
    {
      om$get_classid ( osnum	   = exp[i][j].osnum,
                       objid	   = exp[i][j].objid,
                       p_classid = &clid );
      if ( om$is_ancestry_valid (
        subclassid = clid,
        superclassid = OPP_DIrectory_class_id )
           == OM_S_SUCCESS )	continue;
    }

    if (! strncmp ( event, pathname, pathlen ) )
    {
      *msg = MSFAIL;
      as$status ( sts    = sts,
                  msg    = "LBNfindAttach()",
                  test   = (! LBNfindAttach ( path, attach,
                                              Env, &Aobj ) ),
                  action = GOTO_VALUE,
                  value  = wrapup );
      *msg = MSSUCC;

      /* Get context of attachement */
      om$get_objid_at_index ( osnum        = Aobj.osnum,
                              objid        = Aobj.objid,
                              p_chanselect = &chan,
                              index        = 0,
                              objidaddr    = &Cobj.objid,
                              osnumaddr    = &Cobj.osnum );

      /* Get context environment */
      sts = om$send ( msg = message GRcontext.GRgetmodule_env ( msg, &env[i] ),
                      senderid = NULL_OBJID,
                      targetid = Cobj.objid,
                      targetos = Cobj.osnum );
      as$status ( sts    = sts,
                  msg    = "GRcontext.GRgetmodule_env",
                  test   = (!(sts & 0x00000001 & (*msg))),
                  action = GOTO_VALUE,
                  value  = wrapup );
    }
    else	/* Object isn't in a reference file */
    {
      env[i] = *Env;
    }

    /* Store data */
    for ( j=0; j<num[0]; j++ )
    {
      (*object)[*number].obj_id.osnum  = exp[i][j].osnum;
      (*object)[*number].obj_id.objid  = exp[i][j].objid;
      (*object)[*number].mod_env	= env[i];
      (*number)++;
    }
nextstep:
    sts  = OM_S_SUCCESS;
    *msg = MSSUCC;
  }

wrapup:
  LBNdealloc ( Snum, (IGRchar ***) &lin );
  LBNdealloc ( Snum, (IGRchar ***) &exp );
  if (num)
  {
    //om$dealloc (ptr = num);	num = NULL;
    _FREE (num);
  }
  if (env)
  {
    //om$dealloc (ptr = env);	env = NULL;
    _FREE (env);
  }
  return sts;
}

/* ***** */

IGRlong		LBNconstructList (	IGRuint			Pnum,
					IGRchar			**Plst,
					IGRuint			Enum,
					IGRchar			**Elst,
					IGRuint			Snum,
					IGRchar			**Slst,
					struct	GRmd_env	*Env,
					IGRchar			*Path,
					IGRchar			*attach,
                               		IGRint			*number,
					struct	GRobj_env	**object,
					IGRlong			*msg	)
{
  IGRlong		sts=OM_S_SUCCESS;
  IGRint		count=LBN_ALLOC_SIZE, i, j, k;
  IGRchar		event[DI_PATH_MAX];

  /* Initialize */
  *number = 0;
  *object = NULL;
  *msg    = MSFAIL;

  /* First allocation */
  //*object  = om$calloc ( num = count, structure = struct GRobj_env );
  *object = _CALLOC ( count , struct GRobj_env );

  /* Loop on input argument lists */
  i = 0;	do {
    j = 0;	do {
      k = 0;	do {
        event[0] = '\0';
        if (Plst)	strcat ( event, Plst[i] );
        if (Elst)	strcat ( event, Elst[j] );
        if (Slst)	strcat ( event, Slst[k] );
        if (event[0] != '\0')
        {
          sts = LBNlocateObject( event, Env, Path, attach,
                                 &count, number, object, msg );
          as$status ( sts    = sts,
                      msg    = "LBNlocateObject()",
                      test   = (!(sts & 0x00000001 & (*msg))),
                      action = GOTO_VALUE,
                      value  = wrapup );
        }
	k++;
      }	while (k < Snum);
      j++;
    }	while (j < Enum);
    i++;
  }	while (i < Pnum);

wrapup:
  return sts;
}
/* ***** */

IGRlong	VDlocate_by_name (	IGRlong			*msg,
				IGRchar			*prefix,
				IGRchar			*select,
				IGRchar			*suffix,
				IGRchar			*attach,
				IGRint			*number,
				struct	GRobj_env	**object	)
{
  IGRlong			sts=OM_S_SUCCESS;
  IGRlong			siz=sizeof(struct GRmd_env), ret=0;
  struct	VDStextlist	txtLst;
  struct	VDStextset	txtSet;
  struct	GRmd_env	Env;
  IGRchar			Path[DI_PATH_MAX];
  IGRchar			**yPlst, **nPlst, **yElst, **nElst, **ySlst, **nSlst;
  IGRuint			i, yPnum, nPnum, yEnum, nEnum, ySnum, nSnum;
  struct	GRobj_env	*local;

  /* Initialize VDStextlist structure */
  *number            = 0;
  local              = NULL;
  *msg               = MSFAIL;
  yPnum              = nPnum = yEnum = nEnum = ySnum = nSnum = 0;
  yPlst              = nPlst = yElst = nElst = ySlst = nSlst = NULL;
  txtLst.num_textset = 1;
  txtLst.inc_textset = 1;
  txtLst.max_textset = 1;
  txtLst.text        = &txtSet;
  VDSset_null_text ( &(txtLst.text[0]) );

  __enterFunction ( name = "VDlocate_by_name", argfmt = "select = <%s>, attach = <%s>",
                    args = `select, attach` );

  /* Check <Prefix> input */
  if (! LBNcheckInput ( prefix, VDS_PREFIX_MAX, txtLst.text[0].prefix ) )
    goto wrapup;

  /* Expand <Prefix> */
  if (! LBNexpandInput ( txtLst.text[0].prefix, &yPlst, &yPnum, &nPlst, &nPnum, msg ) )
    goto wrapup;

  /* Check <Selection Expression> input */
  if (! LBNcheckInput ( select, VDS_EXPRES_MAX, txtLst.text[0].expres ) )
    goto wrapup;

  /* Expand <Selection Expression> */
  if (! LBNexpandInput ( txtLst.text[0].expres, &yElst, &yEnum, &nElst, &nEnum, msg ) )
    goto wrapup;

  /* Check <Suffix> input */
  if (! LBNcheckInput ( suffix, VDS_SUFFIX_MAX, txtLst.text[0].suffix ) )
    goto wrapup;

  /* Expand <Suffix> */
  if (! LBNexpandInput ( txtLst.text[0].suffix, &ySlst, &ySnum, &nSlst, &nSnum, msg ) )
    goto wrapup;

  /* Check expanded lists */
  if ( (! yPlst) && (! yElst) && (! ySlst) )
  {
    ex$message ( msgnumb = VD_S_LocNoObj );
    *msg = VD_S_LocNoObj;
    goto wrapup;
  }

  /* Get current module environment */
  gr$get_module_env ( msg    = msg,
                      sizbuf = &siz,
                      buffer = &Env,
                      nret   = &ret );

  /* Build active file pathname */
  sts = di$give_pathname ( osnum    = Env.md_id.osnum,
                           pathname = Path );
  as$status ( sts    = sts,
              msg    = "di$give_pathname()",
              test   = (sts != DIR_S_SUCCESS),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Construct objects' list */
  sts = LBNconstructList ( yPnum, yPlst, yEnum, yElst, ySnum, ySlst,
                           &Env, Path, attach, number, &local, msg );
  as$status ( sts    = sts,
              msg    = "LBNconstructList()",
              test   = (!(sts & 0x00000001 & (*msg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Allocate memory for output array (if needed) */
  if (object)
  {
    *object = NULL;
    //*object = om$calloc ( num = *number, structure = struct GRobj_env );
    *object = _CALLOC ( *number , struct GRobj_env );

    for ( i=0; i<*number; i++ )
      (*object)[i] = local[i];
  }

wrapup:
  LBNdealloc ( yPnum, &yPlst );	LBNdealloc ( nPnum, &nPlst );
  LBNdealloc ( yEnum, &yElst );	LBNdealloc ( nEnum, &nElst );
  LBNdealloc ( ySnum, &ySlst );	LBNdealloc ( nSnum, &nSlst );

  if (local)
  {
    //om$dealloc (ptr = local); local = NULL;
    _FREE (local);
  }

  __exitFunction ( name = "VDlocate_by_name", argfmt = "*msg = %d, *number = %d",
                   args = `*msg, *number` );
  return (sts);
}

end implementation Root;
