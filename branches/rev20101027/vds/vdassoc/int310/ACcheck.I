/* $Id: ACcheck.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int310 / ACcheck.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACcheck.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * I/VDS
 *
 * Correction adapted to handle checkin/checkout for invisible modules, which
 * are working during their sleep process with the visible module.
 *
 * adz: 05/28/94 : integrated as dloadable for in I/VDS.
 */

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "codef.h"
#include "ex.h"
#include "exdef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "exmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "acdef.h"
#include "acmacros.h"
#include "AS_status.h"

#define AS_DEBUG

#include "AS_status.h"

struct VD_OMspace {
	int	osnum;
	char	name[200];
};

void
VD_show_OMspace()
{
  int	i;
  printf(" MaxOS : %d \n", OM_Gw_maxOS );
  for( i = 0 ; i < OM_Gw_maxOS ; i=i+1 ) {
    if( OM_GA_OSDs[ i ] ){
	printf("name:%d:%s:%x\n",i,OM_GA_OSDs[i]->name,OM_GA_OSDs[i]->flags );
    }
  }
}  

void
VD_get_module_list( cnt, list )
int	*cnt;
struct	VD_OMspace	**list;
{
  int	i;
  int   count;

  struct  VD_OMspace *plist;

  /*
   * get the number of active object spaces (visible/invisible)
   */

  count=0;
  for( i = 0 ; i < OM_Gw_maxOS ; i++ ) { if( OM_GA_OSDs[ i ] ){ count++; } }

#ifdef	DEBUG
  printf(" VD_get_module_list : %d \n", count );
#endif

  *cnt = 0;
  *list = NULL;
  *list = (struct VD_OMspace *)om$malloc(size = count*sizeof(struct VD_OMspace));
  if( *list ){
    plist = *list;
    for( i = 0 ; i < OM_Gw_maxOS ; i++ ) {
      if( OM_GA_OSDs[ i ] ){
	strcpy( plist[*cnt].name, OM_GA_OSDs[i]->name );
	plist[*cnt].osnum = i ;

#ifdef	DEBUG
  	printf(" %d : %d : %s \n", i, OM_GA_OSDs[i]->name );
#endif

	(*cnt)++;
      }
    }
  }
  return ;
}

/********************************************************************
  Unmount the object space directories of the macro library before
  save of the current object space.
  These directories were mounted when loading the symbols of contents
  table between tmp_defn in the current file and the real definition
  in the reference file is establish. (function ACload_symbol)
*********************************************************************/

VD_unmount_invisible_lib(osnum,name)
GRspacenum 	osnum;
IGRchar		*name;
/*.ASunmount_invisible_lib*/
{
IGRlong		status;
OM_S_OBJID	tmp;
IGRchar		*p_name;
IGRchar		dir_name[DI_PATH_MAX];
GRspacenum	file_osnum, lib_osnum;
int		invisible_index;

#ifdef	DEBUG
  printf(" START ASunmount_invisible_lib : %d %s \n", osnum, name );
#endif

  status =
  ex$get_cur_mod(	osnum = &file_osnum );

  status =
  di$give_pathname(	osnum = file_osnum,
		     pathname = dir_name );

  strcat( dir_name, ":constructs_lib" );

  status =
  di$translate(		osnum	= file_osnum,
			objname = dir_name,
			p_objid = &tmp);

  if(status != DIR_S_SUCCESS) return(OM_S_SUCCESS);

  /*
   * see if the library is mounted in the sub-directory system.
   */

  p_name = strrchr( name, '/' );
  p_name = p_name ? p_name+1 : name ;
  strcat( dir_name, ":" );
  strcat( dir_name, p_name );

  status =
  di$translate(		osnum   = file_osnum,
			objname = dir_name,
			p_objid = &tmp);
  if(status != DIR_S_SUCCESS) return(OM_S_SUCCESS);

  status =
  di$give_osnum(	pathname = dir_name ,
			p_osnum  = &lib_osnum);
  if(!(status&1)) return( OM_S_SUCCESS );

#ifdef DEBUG
  printf(" found (%d) [%d] %s\n", osnum, lib_osnum , dir_name );
#endif
	    
  if( osnum == lib_osnum  &&
      ex$is_invis(	mod_osnum	= lib_osnum,
			index		= &invisible_index )){

    status =
    ex$close_module(	ftype = EX_invisible,
			index = invisible_index,
			flag  = 0 );
    as$status( sts = status );

#ifdef	DEBUG
    printf(" removed[ %d ] %s\n", status , dir_name );
#endif
  }
  else{

#ifdef DEBUG
    printf(" UMOUNT invisible %d %s \n", invisible_index, dir_name );
#endif
    status =
    di$umount(		dirname = dir_name );
    if(!(status&1))di$report_error(sts = status);
  }

  /*
   * cleanup the library list structures.
   */
#ifdef DEBUG
    printf(" LIB_PATH: %s REM_PATH\n", p_name );
#endif
  status =
  ac$construct_path(	mode	= AC_REM_PATH,
			name	= p_name );
  as$status();

  return(OM_S_SUCCESS);
}

end implementation Root;
