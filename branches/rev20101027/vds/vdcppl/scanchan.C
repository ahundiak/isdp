/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	Recursively lists the tree of objects contained in a (complex) element,	*/
/*	on the selected channel:						*/
/*	Following channels are currently selectable:				*/
/*										*/
/*		0 = to_component channel					*/
/*		1 = to_owners							*/
/*		2 = children							*/
/*		3 = father							*/
/*										*/
/*	Any other channel of interest can be added simply to function:		*/
/*		chan_num_name() at the end of this file				*/
/*										*/
/*	In order to execute, the file "scanchan.o" / scan.so must have been	*/
/*	loaded (dynamically)							*/
/*										*/
/*		argv[1] = chan_num, argv[2] = filename				*/
/*				OR						*/
/*		argv[1] = chan_num OR argv[1] = filename			*/
/*										*/
/*	Function my_scan_chan()        is called from main() in "COScanChan.u"	*/
/*		 init_my_global_vars() is called from main() in "COScanChan.u"	*/
/*										*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#include	<stdio.h>

#include	<OMminimum.h>
#include	<OMerrordef.h>
#include	<OMtypes.h>
#include	<OMindex.h>
#include	<OMlimits.h>
#include	<OMspecify.h>
#include	<OMrelation.h>
#include	<OMextern.h>
#include	<OMprimindex.h>
#include	<OMprimitives.h>
#include	<ciminimum.h>
#include	<grdpbdef.h>
#include	<grdpbmacros.h>

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				GLOBAL VARIABLES				*/
/*										*/
/*		main() in "COScanChan.u" calls init_my_global_vars()		*/
/*			to initialize global variables.				*/
/*										*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static struct	GRmd_env	MOD_ENV;
static OM_S_CHANSELECT		my_chansel;

static int	prof;			/* for recursively indenting printf()	*/

static int	siz_tot, totcnt, totmal, totfree;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int get_size_elem
(
  struct GRid	OBJET,	/* Input	*/
  FILE         *fp
)
{
  short	sz;
  int		msg, sts, size = 0;
  double	*mtrx;

  OM_S_MESSAGE	p_msg;

  /*
   * In a ".C" file, it is NOT POSSIBLE to use om$send as usual :
   *
   *	om$send ( msg = message GRclass.GRmethod( args... ), ... );
   *
   * Define a structure containing the arguments for the message p.e. :
   *
   *	"GRvg.GRgetsize"
   *
   * This structure is then used in the macro : om$make_message ,
   * which returns in the keyword "p_msg"
   * a structure of type OM_S_MESSAGE, to be used in om$send
   * as input to the keyword "msg"
   */

  struct p_arg
  {
    int	        *msg;
    short	*matrix_type;
    double	*matrix;
    int	        *size;
  } p_arglist;

  mtrx = MOD_ENV.md_env.matrix;

  sz   = sizeof (p_arglist);

  sts = om$make_message ( classname	= "GRvg",
                          methodname	= "GRgetsize",
                          size		= sz,
                          p_arglist	= &p_arglist,
                          p_msg		= &p_msg);

  p_arglist.msg         = &msg;
  p_arglist.matrix_type = &MOD_ENV.md_env.matrix_type;
  p_arglist.matrix      = mtrx;
  p_arglist.size        = &size;

  if ( ! sts )
  {
    fprintf( fp,"om$make_message() error ; sts = %#x, sz = %d\n",sts,sz );
//	om$report_error (sts = sts);
    return (0);
  }

  /* Now send the message : "GRvg.GRgetsize" */

  sts = om$send (	msg	 = &p_msg,
			senderid = OBJET.objid,
			targetid = OBJET.objid,
			targetos = OBJET.osnum );

  if ( ! sts )
  {
    fprintf( fp,"GRvg.GRgetsize error ; sts = %#x\n",sts );
//	om$report_error (sts = sts);
    return (0);
  }

  return (size);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static OM_S_OBJECT_LINKAGE	*get_conn_obj
(
  OM_S_OBJECT_LINKAGE	objet,	/* Input	*/
  int			*count,	/* Output	*/
  FILE                  *fp
)
{
  char		        classname[80];
  OMuword		clid;
  int			i0, size, sts, sz = 0;
  OMuint		cnt = 0;
  struct	GRid	OBJ_ID;
  OM_S_OBJECT_LINKAGE	*lobj = NULL;

  *count = 0;

  if ( om$is_objid_valid ( osnum = objet.osnum, objid = objet.S_objid ) != OM_S_SUCCESS )
  {
    fprintf( fp,"INVALID [objid, osnum]\n");
    return NULL;
  }

  om$get_classname (	objid		= objet.S_objid,
			osnum		= objet.osnum,
			classname	= classname  );

  om$get_classid   (	classname	= classname,
			p_classid	= &clid );

  OBJ_ID.objid = objet.S_objid;
  OBJ_ID.osnum = objet.osnum;

  size     = get_size_elem(OBJ_ID, fp);
  siz_tot += size;

  for ( i0=0 ; i0 < prof-1 ; i0++ ) fprintf( fp, "  ");

  if ( size > 0 )
    fprintf( fp,"[%d,%d]  clid = [%4d, %-12s] size(b) = %5d\n",objet.S_objid, objet.osnum, clid, classname, size);
  else
    fprintf( fp,"[%d,%d]  clid = [%4d, %-12s]\n",objet.S_objid, objet.osnum, clid, classname);

  /* find the number of objects on the channel */

  sts = om$get_channel_count ( osnum		= objet.osnum,
                               objid		= objet.S_objid,
                               p_chanselect	= &my_chansel,
                               count		= &cnt );
  if ( cnt > 0 )
  {
    sz   = sizeof( OM_S_OBJECT_LINKAGE ) * cnt;
    lobj = ( OM_S_OBJECT_LINKAGE * ) om$malloc (size = sz);

    if ( lobj )
    {
      sts = om$get_channel_objects( osnum        = objet.osnum,
                                    objid        = objet.S_objid,
                                    p_chanselect = &my_chansel,
                                    size         = cnt,
                                    list         = lobj,
                                    count        = &cnt );

      totcnt += cnt;
      totmal += sz;
      *count  = cnt;

      if ( ! sts )
      {
        om$report_error(sts=sts);
        return NULL;
      }
    }
  }

  return ( lobj );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

init_my_global_vars
(
  OM_S_CHANSELECT	my_channel_sel
)
{
  prof       = 0;
  siz_tot    = 0;
  totcnt     = 1;
  totmal     = 0;
  totfree    = 0;
  my_chansel = my_channel_sel;

  gr$get_module_env( buffer = &MOD_ENV );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int my_scan_chan		/* scans channel for an object, and recurses */
(
  OM_S_OBJECT_LINKAGE	obj,	/* Input	*/
  FILE                 *fp
)
{
  int			cnt = 0, sz = 0;
  OM_S_OBJECT_LINKAGE *p_obj = NULL;
  OM_S_OBJECT_LINKAGE *s_obj = NULL;

  prof += 1;

  p_obj = get_conn_obj ( obj, &cnt, fp );

  if ( p_obj )
  {
    s_obj = p_obj;
    sz    = sizeof( OM_S_OBJECT_LINKAGE ) * cnt;
  }

  while ( cnt-- >= 1)
  {
    if ( ! my_scan_chan( *p_obj++, fp ) ) break;
  }
  prof -= 1;

  if ( s_obj )
  {
    om$dealloc (ptr = s_obj);
    totfree += sz;
  }
  return (1);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

print_my_summarization ( FILE *fp )
{
  if ( totcnt > 1 )
  {
    fprintf( fp, "\nTotal number of elements : %d     size(bytes) : %d\n",totcnt,siz_tot);
//    fprintf( fp, "Total malloc()e'd space  : %d, free()'d space : %d\n",totmal,totfree);
  }
}

print_my_header ( FILE *fp, char *name)
{
  fprintf( fp, "\n------------------------ %s ------------------------\n\n", name);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
