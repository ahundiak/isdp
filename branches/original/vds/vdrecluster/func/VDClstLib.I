/* $Id: VDClstLib.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/func/VDClstLib.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDClstLib.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
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
# Revision 1.2  1995/12/06  18:17:32  pinnacle
# Replaced: vdrecluster/func/VDClstLib.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/12/06  15:56:52  pinnacle
# Created: vdrecluster/func/VDClstLib.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR	DESCRIPTION
 *
 *	12/05/95	HF	Override of I/EMS Review Macro Library functionality
 *				in order to reduce the memory problems such as
 *				running out of swap space when many large libraries
 *				are attached.
 *
 ******************************************************************************/

/*
 * Implement utilities to clusterise a macro library
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "acdef.h"
#include "acrepdef.h"
#include "macro.h"
#include "acmacros.h"
#include "ACcondit.h"
#include "nd.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "exmacros.h"
#include "parametric.h"
#include "bs.h"

#include "AS_status.h"

//#define	VD_DEBUG

#include "VDdebug.h"

/*
 * macro defintion types
 */

#define SMMAC		2
#define CONDMAC		3
#define DEFNMAC		4

from	ACmacro_defn	import	ACgive_name,
				ACgive_temp_desc,
				ACgive_feet_desc,
				ACcopy_default,
				ACgive_upscan,
				ACbuild_min_macro,
				ACmremove_all;

from	NDnode		import	NDdelete,
				NDget_objects;

from	ACcomplex	import	ACget_other;
from	OMCluster	import	init_OMCluster;
from	ci_mac_def	import	ACplace;

from	ACcond_def	import	ACgive_condit_desc,
				ACtake_feet,
				ACtake_condit,
				ACtake_template;

from	ACncpx		import	ACget_rep;

from	ACconst		import	ACmplace_from_def,
				ACmplace;
from	ACpretend	import	ASreturn_go,
				NDgive_structure;
from	expression	import	create;

extern	GRclassid	OPP_ci_mac_def_class_id,
			OPP_ACcond_def_class_id,
			OPP_ACmacro_defn_class_id;

extern GRclassid	OPP_GRcsbase_class_id;
extern GRclassid	OPP_expression_class_id;

extern int              ACauto_save;

extern int	VD_unmount_invisible_lib ( GRspacenum 	 osnum,  char	*name );
extern void	VD_get_OMspace_num ( GRspacenum	*osn, char *name, char *full_name );
extern int	GetObjectsFromRtree( GRclassid ClassId, int nb_req, GRobjid *obj_array, double extend);

struct FT_sd_objarray
{
	IGRint	 size;		/* Total size of this structure in bytes	*/
	IGRint	 count;		/* Number of entries in the array		*/
	IGRint	 tree_type;	/* The type of tree				*/
	GRobjid  array[1000];	/* Array to hold objids				*/
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*			Global Variable's					*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static FILE	*fp;		// File-pointer for LOG-file

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

struct cond
{
  int                     num_cond;
  int                     num_def;
  struct ACcond_descrip  *desc;
  struct ACcond_temp     *def;
};

struct mac_info
{
  struct cond             condit;
  char                   *mac_name;
  struct GRid             mac_id;
  int                     prop;
  int                     tot_up;
  struct sup             *xdup;
  int                     nb_temp;
  struct stemp           *temp_defn;
  int                     nb_feet;
  struct myfeet          *myfeet;
  struct NDcp_struct      copy_list;	/* copied graph in current env	*/
  struct GRid            *grtemp;	/* copied templates		*/
  struct GRid            *grfeet;	/* copied feet			*/
};

struct mac_id_nm
{
  char                   *mac_nm;
  struct GRid             mac_id;
  short			  mac_tp;
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int comp_macro_names0
(
  struct mac_id_nm	*istr,
  struct mac_id_nm	*ostr
)
{
  return ( strcmp ( istr->mac_nm, ostr->mac_nm ) );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * The function "comp_macro_names1()" tries to arrange that conditional macro's
 * will appear AFTER the referenced macro's; so what we try to achieve is a
 * subsort based on macro_type.
 */
 
int comp_macro_names1
(
  struct mac_id_nm	*istr,
  struct mac_id_nm	*ostr
)
{
  int			  i, status, retval, mac_is_foot = FALSE;
  char                    macro_nam_1[DI_PATH_MAX],
			  macro_nam_2[DI_PATH_MAX];
  struct GRid		  macro_def_1, macro_def_2;
  struct mac_info	  mac_info;

  if (	   ( istr->mac_tp != 2 && ostr->mac_tp != 2 )
	|| ( istr->mac_tp == 2 && ostr->mac_tp == 2 ) )
  {
    return ( strcmp ( istr->mac_nm, ostr->mac_nm ) );
  }

  retval = 1;
  macro_nam_1[0] = '\0';
  macro_nam_2[0] = '\0';

  if ( istr->mac_tp == 2 )		// Conditional Macro
  {
    macro_def_1 = istr->mac_id;
    macro_def_2 = ostr->mac_id;
    strcpy ( macro_nam_1, ostr->mac_nm );
    strcpy ( macro_nam_2, istr->mac_nm );
  }

  if ( ostr->mac_tp == 2 )		// Conditional Macro
  {
    macro_def_1 = ostr->mac_id;
    macro_def_2 = istr->mac_id;
    retval	= -retval;
    strcpy ( macro_nam_1, istr->mac_nm );
    strcpy ( macro_nam_2, ostr->mac_nm );
  }

  status = om$send (	msg	 = message ACcond_def.ACgive_condit_desc
						       ( &mac_info.condit.num_cond,
							 &mac_info.condit.desc,
							 &mac_info.condit.num_def,
							 &mac_info.condit.def ),
			senderid = NULL_OBJID,
			targetid = macro_def_1.objid,
			targetos = macro_def_1.osnum );
  as$status ();

  mac_is_foot = FALSE;

  __printf ( "COND_MAC_ID [%d,%d] Name <%s>\n", `macro_def_2.osnum, macro_def_2.objid, macro_nam_2` );
  __printf ( "TEST_MAC_ID [%d,%d] Name <%s>\n", `macro_def_1.osnum, macro_def_1.objid, macro_nam_1` );

  for ( i = 0; i < mac_info.condit.num_cond; i++ )
  {
    __printf ( "MAC_FOOT_ID[%d] Name <%s>\n", `i, mac_info.condit.desc[i].konst` );

    if ( strcmp ( macro_nam_1, mac_info.condit.desc[i].konst ) == 0 )
    {
      mac_is_foot = TRUE;
      break;
    }
  }
  __printf ( "mac_is_foot = %d, retval = %d\n", `mac_is_foot, retval` );

  if ( mac_is_foot == TRUE )
  {
    return retval;
  }
  else
  {
    return ( strcmp ( istr->mac_nm, ostr->mac_nm ) );
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	Construct_clst
( 
  OMuword	  osnum,
  OMuword	* clustnum,
  OM_S_OBJID	* clustoid
)
{
  int			sts;
  OM_S_NEIGHBOR		neighbor;

  __enterFunction ( name = "Construct_clst" );

  neighbor.clusterid = 0;
  neighbor.groupid   = OM_GS_NULL_NEIGHBOR.groupid;

  sts = om$construct ( classname	= "OMCluster",
		       osnum		= osnum,
		       neighbor		= neighbor,
		       p_objid		= clustoid,
		       msg		= message OMCluster.init_OMCluster ( clustnum ) );
  if ( !( 1 & sts ) )
  {
    printf ( "Error Construct Cluster %d\n", sts );
    if ( fp ) fprintf ( fp, "Error Construct Cluster %d\n", sts );

    __exit_error_Function ( name = "Construct_clst" );

    return 0;
  }

  __exitFunction ( name = "Construct_clst" );

  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

CstMacdefn
(
  struct mac_info        *macdef,
  OMuint                  lib_os,
  struct GRmd_env        *md_env,
  struct GRid            *newmacro
)
{
  int                     status;
  int                     def_mode;
  long                    msg;
  OM_S_NEIGHBOR           neighbor;
  OMuword                 clustnum;
  OM_S_OBJID              clustoid;

  __enterFunction ( name = "CstMacdefn" );

  def_mode = ACcant_place_sym | ACminimal_graph;

  status = Construct_clst ( lib_os, &clustnum, &clustoid );
  if ( !( status & 1 ) )
  {
    printf ( "ERROR Construct_clst\n" );
    if ( fp ) fprintf ( fp, "ERROR Construct_clst\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  neighbor.groupid	= OM_GS_NULL_NEIGHBOR.groupid;
  neighbor.clusterid	= clustnum;

  /*
   * as we do not have the graphic graph, we will build it in order
   * to fill the structure needed at the construction of defn
   */

  status = om$construct ( classid	= OPP_ACmacro_defn_class_id,
			  msg		= message ACmacro_defn.ACbuild_min_macro
							( ( int * ) &msg, def_mode, macdef->mac_name,
							macdef->tot_up, macdef->grtemp, macdef->xdup,
							macdef->nb_temp, macdef->temp_defn,
							macdef->nb_feet, macdef->myfeet, macdef->grfeet,
							NULL_GRID, md_env ),
			  osnum		= lib_os,
			  neighbor	= neighbor,
			  p_objid	= &newmacro->objid );

  newmacro->osnum = lib_os;
  if ( !( status & msg & 1 ) )
  {
    printf ( "ERROR ACmacro_defn.ACbuild_min_macro\n" );
    if ( fp ) fprintf ( fp, "ERROR ACmacro_defn.ACbuild_min_macro\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  status = ac$add_macro_name ( osnum		= newmacro->osnum,
			       macro_name	= macdef->mac_name,
			       macro_defn_id	= newmacro->objid );
//  as$status ();

  if ( status & 1 )
  {
    __exitFunction ( name = "CstMacdefn" );

    return 1;
  }

wrapup:

  __exit_error_Function ( name = "CstMacdefn" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

CstCondit
(
  struct mac_info        *macdef,
  OMuint                  lib_os,
  struct GRid            *newmacro
)
{
  int                     i, k, status, index, error, *num_def = NULL;
  OM_S_NEIGHBOR           neighbor;
  OMuword                 clustnum;
  OM_S_OBJID              clustoid;
  char                    macro_name[DI_PATH_MAX], *cname, *strchr ();
  struct GRid            *mac	= NULL;
  char                   *feet_list	= NULL;
  struct ACcond_val      *value	= NULL;

  __enterFunction ( name = "CstCondit" );

  error = 0;
  status = Construct_clst ( lib_os, &clustnum, &clustoid );
  if ( !( status & 1 ) )
  {
    printf ( "ERROR Construct_clst\n" );
    if ( fp ) fprintf ( fp, "ERROR Construct_clst\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  neighbor.groupid	= OM_GS_NULL_NEIGHBOR.groupid;
  neighbor.clusterid	= clustnum;

  status = om$construct ( classid	= OPP_ACcond_def_class_id,
			  osnum		= lib_os,
			  neighbor	= neighbor,
			  p_objid	= &newmacro->objid );

  newmacro->osnum = lib_os;
  if ( !( status & 1 ) )
  {
    printf ( "ERROR om$construct ACcond_def\n" );
    if ( fp ) fprintf ( fp, "ERROR om$construct ACcond_def\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*
   * Make sure that all the macros contained have also been copied
   */

  di$give_pathname ( osnum	= newmacro->osnum,
		     pathname	= macro_name );
  strcat ( macro_name, ":constructs:" );
  cname = strchr ( macro_name, '\0' );

  mac = ( struct GRid * ) om$malloc ( size = macdef->condit.num_cond * sizeof ( struct GRid ) );
  if ( mac == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  num_def = ( int * ) om$malloc ( size = macdef->condit.num_cond * sizeof ( int ) );
  if ( num_def == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  value = ( struct ACcond_val * ) om$malloc ( size = macdef->condit.num_cond * sizeof ( struct ACcond_val ) );
  if ( value == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  for ( i = 0; i < macdef->condit.num_cond; i++ )
  {
    strcpy ( cname, macdef->condit.desc[i].konst );
    value[i]	= macdef->condit.desc[i].cond;
    num_def[i]	= macdef->condit.desc[i].temp_nb_def;

    status = di$translate ( objname	= macro_name,
			    p_objid	= &mac[i].objid,
			    p_osnum	= &mac[i].osnum );
    if ( !( status & 1 ) )
    {
      error = 1;
      di$report_error ( sts = status );
      printf ( "Macro <%s> has to be copied first to the target library\n", macro_name );
      if ( fp ) fprintf ( fp, "Macro <%s> has to be copied first to the target library\n", macro_name );
    }
  }
  if ( error )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  status = om$send ( msg	= message ACcond_def.ACtake_template
						     ( macdef->tot_up, macdef->xdup,
						       macdef->nb_temp, macdef->temp_defn ),
		     senderid	= NULL_OBJID,
		     targetid	= newmacro->objid,
		     targetos	= newmacro->osnum );
  as$status ();

  if ( macdef->nb_feet == 0 )
  {
    printf ( "ERROR no feet\n" );
    if ( fp ) fprintf ( fp, "ERROR no feet\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  feet_list = ( char * ) om$malloc ( size = macdef->nb_feet * macro_MAX_CHAR * sizeof ( char ) );
  if ( feet_list == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }
  for ( k = 0; k < macdef->nb_feet; k++ )
  {
    strncpy ( feet_list + k * macro_MAX_CHAR, macdef->myfeet[k].name, macro_MAX_CHAR );
    feet_list[k * macro_MAX_CHAR + macro_MAX_CHAR - 1] = '\0';
  }
  status = om$send ( msg	= message ACcond_def.ACtake_feet
						     ( macdef->nb_feet, feet_list, &index ),
		     senderid	= NULL_OBJID,
		     targetid	= newmacro->objid,
		     targetos	= newmacro->osnum );
  as$status ();

  status = om$send ( msg	= message ACcond_def.ACtake_condit
						     ( macdef->mac_name,
						       macdef->condit.num_cond,
						       mac, value,
						       num_def, macdef->condit.def ),
		     senderid	= NULL_OBJID,
		     targetid	= newmacro->objid,
		     targetos	= newmacro->osnum );
  as$status ();

wrapup:

  if ( mac )
  {
    free ( mac );
    mac = NULL;
  }

  if ( num_def )
  {
    free ( num_def );
    num_def = NULL;
  }

  if ( value )
  {
    free ( value );
    value = NULL;
  }

  if ( feet_list )
  {
    free ( feet_list );
    feet_list = NULL;
  }

  if ( error == 0 )
  {
    __exitFunction ( name = "CstCondit" );

    return 1;
  }
  else
  {
    __exit_error_Function ( name = "CstCondit" );

    return 0;
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

CstSMMac
(
  struct mac_info        *macdef,
  char                   *ToLib,
  struct GRmd_env        *my_env,
  struct GRid            *newmacro
)
{
  int                     k, suc, error, status;
  int                     nb_temp_feet, nb_feet, nb_temp;
  char                  **temp_list = NULL;
  int                    *temp_type = NULL;
  char                  **feet_list = NULL;
  int                    *temp_feet_ind = NULL;
  char                    savname[macro_MAX_CHAR], **temp_feet_list = NULL;

  __enterFunction ( name = "CstSMMac" );

  error	= 0;
  nb_feet = nb_temp_feet = nb_temp = 0;

  /*
   * fill the arg for SMCrtMacDef
   */

  nb_temp = macdef->nb_temp;

  /*
   * need to remove old macro
   *
   * ACmremove_all adds in mac_info.mac_name, the library name ??
   */

  strcpy ( savname, macdef->mac_name );

  status = om$send ( msg	= message ACmacro_defn.ACmremove_all( &suc, 1, my_env ),
		     senderid	= NULL_OBJID,
		     targetid	= macdef->mac_id.objid,
		     targetos	= macdef->mac_id.osnum );

  if ( !( status & 1 ) )
  {
    printf ( "ERROR ACmacro_defn.ACmremove_all\n" );
    if ( fp ) fprintf ( fp, "ERROR ACmacro_defn.ACmremove_all\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }
  strcpy ( macdef->mac_name, savname );

  if ( nb_temp )
  {
    temp_list = ( char ** ) om$malloc ( size = nb_temp * sizeof ( char * ) );
    if ( temp_list == NULL )
    {
      printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
      if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
      error = 1;
      __print_goto ( "wrapup" );
      goto wrapup;
    }
    for ( k = 0; k < nb_temp; k++ )
    {
      temp_list[k] = NULL;
    }

    for ( k = 0; k < nb_temp; k++ )
    {
      temp_list[k] = ( char * ) om$malloc ( size = macro_MAX_CHAR * sizeof ( char ) );
      if ( temp_list[k] == NULL )
      {
	printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
	if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
	error = 1;
	__print_goto ( "wrapup" );
	goto wrapup;
      }
    }
    temp_type = ( int * ) om$malloc ( size = nb_temp * sizeof ( int ) );
    if ( temp_type == NULL )
    {
      printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
      if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
      error = 1;
      __print_goto ( "wrapup" );
      goto wrapup;
    }
  }

  for ( k = 0; k < nb_temp; k++ )
  {
    strcpy ( temp_list[k], macdef->temp_defn[k].name );
    temp_type[k] = macdef->temp_defn[k].type;
  }

  nb_temp_feet = 0;

  for ( k = 0; k < macdef->nb_feet; k++ )
  {
    if ( macdef->myfeet[k].chan == feet_in_template )
    {
      nb_temp_feet++;
    }
  }

  nb_feet = macdef->nb_feet - nb_temp_feet;

  if ( nb_feet )
  {
    feet_list = ( char ** ) om$malloc ( size = nb_feet * sizeof ( char * ) );
    if ( feet_list == NULL )
    {
      printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
      if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
      error = 1;
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    for ( k = 0; k < nb_feet; k++ )
    {
      feet_list[k] = NULL;
    }

    for ( k = 0; k < nb_feet; k++ )
    {
      feet_list[k] = ( char * ) om$malloc ( size = macro_MAX_CHAR * sizeof ( char ) );
      if ( feet_list[k] == NULL )
      {
	printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
	if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
	error = 1;
	__print_goto ( "wrapup" );
	goto wrapup;
      }
    }
  }

  if ( nb_temp_feet )
  {
    temp_feet_list = ( char ** ) om$malloc ( size = nb_temp_feet * sizeof ( char * ) );
    if ( temp_feet_list == NULL )
    {
      printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
      if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
      error = 1;
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    for ( k = 0; k < nb_temp_feet; k++ )
    {
      temp_feet_list[k] = NULL;
    }

    for ( k = 0; k < nb_temp_feet; k++ )
    {
      temp_feet_list[k] = ( char * ) om$malloc ( size = macro_MAX_CHAR * sizeof ( char ) );
      if ( temp_feet_list[k] == NULL )
      {
	printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
	if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
	error = 1;
	__print_goto ( "wrapup" );
	goto wrapup;
      }
    }

    temp_feet_ind = ( int * ) om$malloc ( size = nb_temp_feet * sizeof ( int ) );
    if ( temp_feet_ind == NULL )
    {
      printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
      if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
      error = 1;
      __print_goto ( "wrapup" );
      goto wrapup;
    }
  }

  for ( k = 0; k < nb_temp_feet; k++ )
  {
    strcpy ( temp_feet_list[k], macdef->myfeet[k].name );
    temp_feet_ind[k] = macdef->myfeet[k].pos;
  }

  for ( k = 0; k < nb_feet; k++ )
  {
    strcpy ( feet_list[k], macdef->myfeet[k + nb_temp_feet].name );
  }

  status = SMCrtMacDef ( macdef->mac_name, ToLib, macdef->nb_temp,
			 temp_list, temp_type, nb_feet, feet_list, nb_temp_feet,
			 temp_feet_ind, temp_feet_list, newmacro );

  if ( !( status & 1 ) )
  {
    printf ( "ERROR SMCrtMacDef <%s> \n", macdef->mac_name );
    if ( fp ) fprintf ( fp, "ERROR SMCrtMacDef <%s> \n", macdef->mac_name );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

wrapup:

  /*
   * free the structures
   */

  if ( temp_list && nb_temp )
  {
    for ( k = 0; k < nb_temp; k++ )
    {
      if ( temp_list[k] )
      {
	free ( temp_list[k] );
	temp_list[k] = NULL;
      }
    }
    free ( temp_list );
    temp_list = NULL;
  }

  if ( temp_type )
  {
    free ( temp_type );
    temp_type = NULL;
  }

  if ( feet_list && nb_feet )
  {
    for ( k = 0; k < nb_feet; k++ )
    {
      if ( feet_list[k] )
      {
	free ( feet_list[k] );
	feet_list[k] = NULL;
      }
    }
    free ( feet_list );
    feet_list = NULL;
  }

  if ( temp_feet_list && nb_temp_feet )
  {
    for ( k = 0; k < nb_temp_feet; k++ )
    {
      if ( temp_feet_list[k] )
      {
	free ( temp_feet_list[k] );
	temp_feet_list[k] = NULL;
      }
    }
    free ( temp_feet_list );
    temp_feet_list = NULL;
  }
  if ( temp_feet_ind )
  {
    free ( temp_feet_ind );
    temp_feet_ind = NULL;
  }
  nb_feet = nb_temp_feet = nb_temp = 0;

  if ( error == 0 )
  {
    __exitFunction ( name = "CstSMMac" );

    return 1;
  }
  else
  {
    __exit_error_Function ( name = "CstSMMac" );

    return 0;
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

VDcimacdef
(
  OM_S_OBJID             *cimacdef,
  IGRint                 *status,
  IGRint                  prop,
  IGRchar                *name,
  IGRchar                *int_name,
  IGRint                  int_size,
  IGRint                  temp_num,
  IGRchar               **temp_names,
  IGRint                 *temp_types,
  IGRint                  temp_feet_num,
  IGRint                 *temp_feet_index,
  IGRchar               **temp_feet_names,
  IGRint                  intern_feet_num,
  IGRchar               **intern_feet_names,
  IGRint                 *intern_feet_types,
  IGRint                  extern_feet_num,
  IGRchar               **extern_feet_names,
  IGRint                 *external_feet_types,
  IGRint                 *feet_order,
  OMuint                  osnum
)
{
  IGRint                  stat;
  OM_S_NEIGHBOR           neighbor;
  OMuword                 clustnum;
  OM_S_OBJID              clustoid;

  __enterFunction ( name = "VDcimacdef" );

  neighbor = OM_GS_NULL_NEIGHBOR;

  stat = Construct_clst ( osnum, &clustnum, &clustoid );

  if ( stat & 1 )
  {
    neighbor.clusterid = clustnum;
  }

  stat = om$construct ( classid	= OPP_ci_mac_def_class_id,
			osnum	= osnum,
			neighbor= neighbor,
			p_objid	= cimacdef,
			msg	= message ci_mac_def.ACplace ( 
							   status,
							   prop, name,
							   int_name, int_size,
							   temp_num, temp_names,
							   temp_types,
							   temp_feet_num,
							   temp_feet_index, temp_feet_names,
							   intern_feet_num, intern_feet_names,
							   intern_feet_types,
							   extern_feet_num, extern_feet_names,
							   external_feet_types,
							   feet_order ) );

  __exitFunction ( name = "VDcimacdef", argfmt = "stat = %d, *status = %d, name = <%s>", args = `stat, *status, name` );

  return ( stat );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * Get all the macro id in the given macro lib and sort alphabetically
 */

int	GetMacInLibSort
(
  char                   *macro_lib,
  int			  sort,
  struct GRid           **macro_def,
  int                    *nb_macro
)
{
  int                     i, index, nb_lines;
  int                     status;
  char                    dir_name[DI_PATH_MAX];
  char                   *mc_types [] = { "reglr_id", "cimac_id", "condt_id" };
  struct GRid             mac_id, *exp = NULL;
  struct mac_id_nm       *reglr_id = NULL, *cimac_id = NULL,  *condt_id = NULL,  *any_mac_id = NULL;
  int                     nr_reglr, nr_cimac, nr_condt, nr_any;
  GRclassid               mac_class;

  __enterFunction ( name = "GetMacInLibSort" );

  *macro_def = NULL;
  *nb_macro  = 0;

  /*
   * Get contents of selected macro library
   */

  VDSget_filename ( dir_name );
  strcat ( dir_name, ":constructs_lib:" );
  strcat ( dir_name, macro_lib );

  status = di$translate ( objname = dir_name,
			  p_objid = &mac_id.objid,
			  p_osnum = &mac_id.osnum );
  if ( !( status & 1 ) )
  {
    /*
     * The macro lib is not mounted, so do it
     * Add name to the path (if not already done)
     */
    status = ac$construct_path ( mode = AC_ADD_PATH,
				 name = macro_lib );
    if ( !( status & 1 ) )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }
  }

  strcat ( dir_name, ":constructs:*" );

  status = di$dump ( regexp	= dir_name,
		     grids	= ( DIgrid ** ) & exp,
		     ptr	= &nb_lines );

  if ( status != DIR_S_SUCCESS )
  {
    di$report_error ( sts = status );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  if ( !nb_lines )
  {
    __exitFunction ( name = "GetMacInLibSort" );

    return 1;
  }

  /*
   * take only macro definitions
   */

  ( *macro_def ) = ( struct GRid * ) om$malloc ( size = nb_lines * sizeof ( struct GRid ) );

  if ( ( *macro_def ) == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  reglr_id = ( struct mac_id_nm * ) om$malloc ( size = nb_lines * sizeof ( struct mac_id_nm ) );

  if ( reglr_id == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  cimac_id = ( struct mac_id_nm * ) om$malloc ( size = nb_lines * sizeof ( struct mac_id_nm ) );

  if ( cimac_id == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  condt_id = ( struct mac_id_nm * ) om$malloc ( size = nb_lines * sizeof ( struct mac_id_nm ) );

  if ( condt_id == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  any_mac_id = ( struct mac_id_nm * ) om$malloc ( size = nb_lines * sizeof ( struct mac_id_nm ) );

  if ( any_mac_id == NULL )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  index = nr_reglr = nr_cimac = nr_condt = nr_any = 0;

  for ( i = 0; i < nb_lines; i++ )
  {
    om$get_classid ( osnum	= exp[i].osnum,
		     objid	= exp[i].objid,
		     p_classid	= &mac_class );

    if ( om$is_ancestry_valid ( subclassid	= mac_class,
				superclassid	= OPP_ACcpx_defn_class_id ) != OM_S_SUCCESS )
    {
      continue;
    }

    if ( om$is_objid_valid ( osnum = exp[i].osnum, objid = exp[i].objid ) != OM_S_SUCCESS )
    {
      char	name [DI_PATH_MAX];
      status = di$untranslate (	osnum	= exp[i].osnum,
				objid	= exp[i].objid,
				objname	= name );
      if ( status != DIR_S_SUCCESS )
      {
	di$report_error ( sts = status );
      }
      printf ( "SKIPPING INVALID OBJECT [%d] = [%d,%d], name = <%s>\n", i, exp[i].osnum, exp[i].objid, name );
      if ( fp ) fprintf ( fp, "SKIPPING INVALID OBJECT [%d] = [%d,%d], name = <%s>\n", i, exp[i].osnum, exp[i].objid, name );

      continue;
    }

    if ( om$is_ancestry_valid ( subclassid	= mac_class,
				superclassid	= OPP_ci_mac_def_class_id ) == OM_S_SUCCESS )
    {
      cimac_id[nr_cimac].mac_id.objid	= exp[i].objid;
      cimac_id[nr_cimac].mac_id.osnum	= exp[i].osnum;
      cimac_id[nr_cimac].mac_tp		= 1;
      any_mac_id[nr_any].mac_tp		= 1;

      status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &cimac_id[nr_cimac].mac_nm ),
		       senderid	= NULL_OBJID,
		       targetid	= exp[i].objid,
		       targetos	= exp[i].osnum );
      as$status ();

      __printf ( "\tcimac_id [%5d] = [%d,%d], name = <%s>",
		`nr_cimac, cimac_id[nr_cimac].mac_id.osnum, cimac_id[nr_cimac].mac_id.objid, cimac_id[nr_cimac].mac_nm` );

      nr_cimac++;
    }
    else if ( om$is_ancestry_valid (subclassid	= mac_class,
				    superclassid= OPP_ACcond_def_class_id ) == OM_S_SUCCESS )
    {
      condt_id[nr_condt].mac_id.objid	= exp[i].objid;
      condt_id[nr_condt].mac_id.osnum	= exp[i].osnum;
      condt_id[nr_condt].mac_tp		= 2;
      any_mac_id[nr_any].mac_tp		= 2;

      status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &condt_id[nr_condt].mac_nm ),
		       senderid	= NULL_OBJID,
		       targetid	= exp[i].objid,
		       targetos	= exp[i].osnum );
      as$status ();

      __printf ( "\tcondt_id [%5d] = [%d,%d], name = <%s>",
		`nr_condt, condt_id[nr_condt].mac_id.osnum, condt_id[nr_condt].mac_id.objid, condt_id[nr_condt].mac_nm` );

      nr_condt++;
    }
    else if ( om$is_ancestry_valid (subclassid	= mac_class,
				    superclassid= OPP_ACmacro_defn_class_id ) == OM_S_SUCCESS )
    {
      reglr_id[nr_reglr].mac_id.objid	= exp[i].objid;
      reglr_id[nr_reglr].mac_id.osnum	= exp[i].osnum;
      reglr_id[nr_reglr].mac_tp		= 0;
      any_mac_id[nr_any].mac_tp		= 0;

      status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &reglr_id[nr_reglr].mac_nm ),
		       senderid	= NULL_OBJID,
		       targetid	= exp[i].objid,
		       targetos	= exp[i].osnum );
      as$status ();

      __printf ( "\treglr_id [%5d] = [%d,%d], name = <%s>",
		`nr_reglr, reglr_id[nr_reglr].mac_id.osnum, reglr_id[nr_reglr].mac_id.objid, reglr_id[nr_reglr].mac_nm` );

      nr_reglr++;
    }

    any_mac_id[nr_any].mac_id.objid = exp[i].objid;
    any_mac_id[nr_any].mac_id.osnum = exp[i].osnum;

    status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &any_mac_id[nr_any].mac_nm ),
		       senderid	= NULL_OBJID,
		       targetid	= exp[i].objid,
		       targetos	= exp[i].osnum );
    as$status ();

    nr_any++;
  }

  /*
   * Sort the separate macro_def buffers alphabetically ...
   */
  if ( sort == 3 )
  {
    if ( nr_reglr )
    {
      qsort ( (char *)reglr_id, nr_reglr, sizeof ( struct mac_id_nm ), (int (*)(const void *, const void *)) comp_macro_names0);
    }

    if ( nr_cimac )
    {
      qsort ( (char *)cimac_id, nr_cimac, sizeof ( struct mac_id_nm ), (int (*)(const void *, const void *)) comp_macro_names0);
    }

    if ( nr_condt )
    {
      qsort ( (char *)condt_id, nr_condt, sizeof ( struct mac_id_nm ), (int (*)(const void *, const void *)) comp_macro_names0);
    }
  }

  if ( sort == 1 )
  {
    if ( nr_any )
    {
      qsort ( (char *)any_mac_id, nr_any, sizeof ( struct mac_id_nm ), (int (*)(const void *, const void *)) comp_macro_names1);
    }
  }

  if ( sort >= 2 )
  {
    /*
     * Ensure to process regular macros first ...
     */
    if ( nr_reglr )
    {
      for ( i=0; i < nr_reglr; i++ )
      {
	printf ( "\treglr_id [%5d] = [%2d,%6d], name = <%s>\n", index, reglr_id[i].mac_id.osnum, reglr_id[i].mac_id.objid, reglr_id[i].mac_nm );
	if ( fp ) fprintf ( fp, "\treglr_id [%5d] = [%2d,%6d], name = <%s>\n", index, reglr_id[i].mac_id.osnum, reglr_id[i].mac_id.objid, reglr_id[i].mac_nm );

	( *macro_def )[index++] = reglr_id[i].mac_id;
      }
    }

    if ( nr_cimac )
    {
      for ( i=0; i < nr_cimac; i++ )
      {
	printf ( "\tcimac_id [%5d] = [%2d,%6d], name = <%s>\n", index, cimac_id[i].mac_id.osnum, cimac_id[i].mac_id.objid, cimac_id[i].mac_nm );
	if ( fp ) fprintf ( fp, "\tcimac_id [%5d] = [%2d,%6d], name = <%s>\n", index, cimac_id[i].mac_id.osnum, cimac_id[i].mac_id.objid, cimac_id[i].mac_nm );

	( *macro_def )[index++] = cimac_id[i].mac_id;
      }
    }

    /*
     * Ensure to process conditional macros last ...
     */
    if ( nr_condt )
    {
      for ( i=0; i < nr_condt; i++ )
      {
	printf ( "\tcondt_id [%5d] = [%2d,%6d], name = <%s>\n", index, condt_id[i].mac_id.osnum, condt_id[i].mac_id.objid, condt_id[i].mac_nm );
	if ( fp ) fprintf ( fp, "\tcondt_id [%5d] = [%2d,%6d], name = <%s>\n", index, condt_id[i].mac_id.osnum, condt_id[i].mac_id.objid, condt_id[i].mac_nm );

	( *macro_def )[index++] = condt_id[i].mac_id;
      }
    }
  }
  else
  {
    if ( nr_any )
    {
      for ( i=0; i < nr_any; i++ )
      {
	printf ( "\t%s [%5d] = [%2d,%6d], name = <%s>\n", mc_types [ any_mac_id[i].mac_tp ], index, any_mac_id[i].mac_id.osnum, any_mac_id[i].mac_id.objid, any_mac_id[i].mac_nm );
	if ( fp ) fprintf ( fp, "\t%s [%5d] = [%2d,%6d], name = <%s>\n", mc_types [ any_mac_id[i].mac_tp ], index, any_mac_id[i].mac_id.osnum, any_mac_id[i].mac_id.objid, any_mac_id[i].mac_nm );

	( *macro_def )[index++] = any_mac_id[i].mac_id;
      }
    }
  }

  *nb_macro = index;
  dir_name [ strlen (dir_name) - 1 ] = '\0';

  printf ( "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d\nIn directory <%s>\n",
		   *nb_macro, nr_reglr, nr_condt, nr_cimac, dir_name );
  if ( fp ) fprintf ( fp, "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d\nIn directory <%s>\n",
		   *nb_macro, nr_reglr, nr_condt, nr_cimac, dir_name );

  if ( exp )
  {
    free ( exp );
    exp = NULL;
  }
  om$dealloc ( ptr = reglr_id );
  om$dealloc ( ptr = cimac_id );
  om$dealloc ( ptr = condt_id );
  om$dealloc ( ptr = any_mac_id );

  __exitFunction ( name = "GetMacInLibSort" );

  return 1;

wrapup:

  if ( exp )
  {
    free ( exp );
    exp = NULL;
  }
  om$dealloc ( ptr = reglr_id );
  om$dealloc ( ptr = cimac_id );
  om$dealloc ( ptr = condt_id );
  om$dealloc ( ptr = any_mac_id );

  __exit_error_Function ( name = "GetMacInLibSort" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	GetMacInfo
(
  struct GRid            *macro_def,
  IGRint                  def_type,
  struct mac_info        *mac_info
)
{
  int                     i, k, error, status, index, index1, nb_other, nb_template, nb_entry, nb_entry_max;
  long                    msg;
  struct GRid            *entry_max, *entry, *template, *buf, *feet;
  struct GRmd_env         my_env, md_env;
  IGRlong                 sizebuf, nret;
  OM_S_OBJID             *other;

  __enterFunction ( name = "GetMacInfo" );

  mac_info->grtemp		= NULL;
  mac_info->grfeet		= NULL;
  mac_info->copy_list.nb_obj	= 0;

  error		= 0;
  template	= NULL;
  feet		= NULL;
  entry		= NULL;

  mac_info->mac_id = *macro_def;

  sizebuf = sizeof ( struct GRmd_env );
  gr$get_module_env ( msg	= &msg,
		      sizbuf	= &sizebuf,
		      buffer	= &md_env,
		      nret	= &nret );

  my_env = md_env;
  my_env.md_id.osnum = mac_info->mac_id.osnum;

  status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &mac_info->mac_name ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_upscan
						     ( &mac_info->tot_up,
						       &mac_info->prop,
						       &mac_info->xdup ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_temp_desc
						     ( &mac_info->nb_temp, &mac_info->temp_defn ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_feet_desc
						     ( &mac_info->nb_feet, &mac_info->myfeet ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();

  /*
   * special case for conditional
   */

  if ( def_type == CONDMAC )
  {
    status = om$send ( msg	= message ACcond_def.ACgive_condit_desc
						       ( &mac_info->condit.num_cond,
							 &mac_info->condit.desc,
							 &mac_info->condit.num_def,
							 &mac_info->condit.def ),
		       senderid	= NULL_OBJID,
		       targetid	= macro_def->objid,
		       targetos	= macro_def->osnum );
    as$status ();
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*
   * Get macro template
   */

  status = om$send ( msg	= message NDnode.NDget_objects ( ND_ROOT | ND_IN_BUF,
							  NULL, 0, &buf, 0, OM_K_MAXINT, &nb_template ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();
  if ( def_type == SMMAC )
  {
    /*
     * do not get more info for ci_mac_def
     */
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  if ( nb_template == 0 )
  {
    printf ( "ERROR no template for the macro def\n" );
    if ( fp ) fprintf ( fp, "ERROR no template for the macro def\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  template = ( struct GRid * ) om$malloc ( size = nb_template * sizeof ( struct GRid ) );
  if ( !template )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }
  OM_BLOCK_MOVE ( buf, template, nb_template * sizeof ( struct GRid ) );

  status = om$send ( msg	= message ACcomplex.ACget_other ( &msg, &nb_other, &other ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def->objid,
		     targetos	= macro_def->osnum );
  as$status ();

  feet = ( struct GRid * ) om$malloc ( size = mac_info->nb_feet * sizeof ( struct GRid ) );
  if ( !feet )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  for ( i = 0; i < mac_info->nb_feet; i++ )
  {
    if ( ( mac_info->myfeet[i].chan & 3 ) == feet_in_graphic )
    {
      index	= mac_info->myfeet[i].pos;
      index1	= mac_info->myfeet[i].chan >> 2;

      feet[index].objid = other[index1];
      feet[index].osnum = mac_info->mac_id.osnum;

      if ( om$is_objid_valid ( osnum = feet[index].osnum, objid = feet[index].objid ) != OM_S_SUCCESS )
      {
	printf ( "index1 = %d ==>> other[%d] = feet[%d] = [%d,%d] is INVALID in MACRO <%s>\n",
		index1, index1, index, feet[index].osnum, feet[index].objid, mac_info->mac_name );

	printf ( "  myfeet[%d] : pos = %#o, chan = %#o (index1 = `chan >> 2'), prop = %#o, name = <%s>\n",
		i, mac_info->myfeet[i].pos, mac_info->myfeet[i].chan, mac_info->myfeet[i].prop, mac_info->myfeet[i].name );

	if ( fp ) fprintf ( fp, "index1 = %d ==>> other[%d] = feet[%d] = [%d,%d] is INVALID in MACRO <%s>\n",
		index1, index1, index, feet[index].osnum, feet[index].objid, mac_info->mac_name );

	if ( fp ) fprintf ( fp, "  myfeet[%d] : pos = %#o, chan = %#o (index1 = `chan >> 2'), prop = %#o, name = <%s>\n",
		i, mac_info->myfeet[i].pos, mac_info->myfeet[i].chan, mac_info->myfeet[i].prop, mac_info->myfeet[i].name );
      }
    }
  }

  entry = ( struct GRid * ) om$malloc ( size = ( mac_info->nb_feet + nb_template ) * sizeof ( struct GRid ) );
  if ( !entry )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  nb_entry = 0;
  for ( i = 0; i < nb_template; i++ )
  {
    entry[nb_entry++] = template[i];
  }

  for ( i = 0; i < mac_info->nb_feet; i++ )
  {
    entry[nb_entry++] = feet[i];
  }

  status = nd$get_internal_graph ( p_initial	= entry,
				   nb_initial	= nb_entry );

  status = nd$get_list_in_graph ( p_count	= &nb_entry_max,
				  buf_addr	= &entry_max );

  /*
   * Copy now the graph in current osnum
   */

  status = nd$copy_graph ( cp_type	= ND_INSIDE_MACRO,
			   p_clone	= &mac_info->copy_list,
			   from_info	= &my_env,
			   to_info	= &md_env );
  as$status ();

  mac_info->grtemp = ( struct GRid * ) om$malloc ( size = nb_template * sizeof ( struct GRid ) );

  if ( !mac_info->grtemp )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  mac_info->grfeet = ( struct GRid * ) om$malloc ( size = mac_info->nb_feet * sizeof ( struct GRid ) );
  if ( !mac_info->grfeet )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  index = 0;
  for ( i = 0; i < mac_info->copy_list.nb_obj; i++ )
  {
    for ( k = 0; k < mac_info->nb_feet; k++ )
    {
      if ( mac_info->copy_list.list[i].original == feet[k].objid )
      {
	mac_info->grfeet[index].objid = mac_info->copy_list.list[i].clone;
	mac_info->grfeet[index].osnum = md_env.md_id.osnum;
	index++;
      }
    }
  }

  index = 0;
  for ( i = 0; i < mac_info->copy_list.nb_obj; i++ )
  {
    for ( k = 0; k < nb_template; k++ )
    {
      if ( mac_info->copy_list.list[i].original == template[k].objid )
      {
	mac_info->grtemp[index].objid = mac_info->copy_list.list[i].clone;
	mac_info->grtemp[index].osnum = md_env.md_id.osnum;
	index++;
      }
    }
  }

wrapup:

  if ( entry )
  {
    free ( entry );
    entry = NULL;
  }
  if ( template )
  {
    free ( template );
    template = NULL;
  }
  if ( feet )
  {
    free ( feet );
    feet = NULL;
  }
  if ( error )
  {
    if ( mac_info->grtemp )
    {
      free ( mac_info->grtemp );
      mac_info->grtemp = NULL;
    }
    if ( mac_info->grfeet )
    {
      free ( mac_info->grfeet );
      mac_info->grfeet = NULL;
    }
    __exit_error_Function ( name = "GetMacInfo" );

    return 0;
  }
  else
  {
    __exitFunction ( name = "GetMacInfo" );

    return 1;
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	RebuildLib
(
  char                   *FromLib,
  char                   *ToLib,
  int			  sort,
  int			  verbose,
  int			  proc_only,
  int			  do_cntinue,
  int			  skip_nstd_noz,
  int			  append_to_lib,
  char                   *mac_to_skp
)
{
  int                     i, k, status, skipmac = 0, errcnt = 0;
  long                    msg;
  int                     nb_macros, nb_proc_macros = 0, def_type, nb_nested_nozz = 0;
  GRobjid		 *nested_nozl;
  struct GRid            *macro_def, newmacro, new_default, old_default;
  struct mac_info         mac_info;
  struct GRid             lib_id;
  struct GRmd_env         my_env, md_env, new_env;
  IGRlong                 sizebuf, nret;
  char                    dir_name	[DI_PATH_MAX],
			  full_name	[DI_PATH_MAX],
			  wkdir_nam_tot	[DI_PATH_MAX],
			  new_full_name	[DI_PATH_MAX],
			  strng		[80],
			  log_file	[20],	
			 *mac_name;
  GRclassid               mac_class;
  int                     save_save;
  int                     nr_ci_macros, nr_regular_macros, nr_condit_macros, nr_invalid_macros;

  __enterFunction ( name = "RebuildLib" );

  macro_def = NULL;

  sprintf ( log_file, "%s.LOG", FromLib );
  fp = fopen ( log_file, "w" );
  if ( fp )
  {
    printf ( "LOG_file <%s> opened\n", log_file );
    fprintf ( fp, "\n\tLOG_file <%s> for New Macro Library  <%s>\n\n", log_file, ToLib );
    if ( verbose )
    {
      fprintf ( fp, "Verbose output will be generated\n");
    }
    if ( do_cntinue )
    {
      fprintf ( fp, "Continue processing even if errors occur (if possible)\n");
    }
    else
    {
      fprintf ( fp, "Processing will stop when errors occur\n");
    }
    if ( proc_only >= 0 )
    {
      fprintf ( fp, "Only index [%d] will be processed\n", proc_only );
    }
    if ( skip_nstd_noz )
    {
      fprintf ( fp, "Macro's containing nested Nozzle's will NOT be processed\n");
    }
    else
    {
      fprintf ( fp, "Macro's containing nested Nozzle's WILL BE processed\n");
    }

    if ( sort == 1 )
    {
      fprintf ( fp, "Sort Option %d : Libraries will be sorted alphabetically\n", sort );
    }
    else if ( sort == 2 )
    {
      fprintf ( fp, "Sort Option %d : Libraries will be grouped NOT sorted alphabetically\n", sort );
    }
    else if ( sort == 3 )
    {
      fprintf ( fp, "Sort Option %d : Libraries will be grouped AND sorted alphabetically\n", sort );
    }
    else
    {
      fprintf ( fp, "Sort Option %d : Libraries will not be sorted\n", sort );
    }
    fprintf ( fp, "\n" );
  }
  else
  {
    printf ( "Unable to open LOG_file <%s>\n", log_file );
  }

  mac_info.grtemp = NULL;
  mac_info.grfeet = NULL;
  mac_info.copy_list.nb_obj = 0;

  nr_ci_macros = nr_regular_macros = nr_condit_macros = nr_invalid_macros = 0;

  def_type = 0;

  if ( mac_to_skp )
  {
    skipmac = 1;
  }

  /*
   * Get the active mac_lib
   */

  status = ac$construct_wd ( mode	= AC_SET,
			     name	= ToLib,
			     dir	= &lib_id );
  if ( !( status & 1 ) )
  {
    printf ( "ERROR set active library <%s>\n", ToLib );
    if ( fp ) fprintf ( fp, "ERROR set active library <%s>\n", ToLib );
    __print_goto ( "wrapup" );
    errcnt++;
    goto wrapup;
  }

  VDSget_filename ( dir_name );
  strcat ( dir_name, ":constructs_lib:" );

  /*
   * The working directory has to be removed (unmounted) and the corresponding
   * UNIX file has to be deleted as well, otherwise the library will be appended to.
   */

  if ( append_to_lib == FALSE )
  {
    sprintf ( wkdir_nam_tot, "%s%s", dir_name, ToLib );
    status = RemoveMacroLib ( wkdir_nam_tot );
  }

  /*
   * Set the mac_lib active
   */

  status = ac$construct_wd ( mode	= AC_SET,
			     name	= ToLib,
			     dir	= &lib_id );
  if ( !( status & 1 ) )
  {
    printf ( "ERROR set active library <%s>\n", ToLib );
    if ( fp ) fprintf ( fp, "ERROR set active library <%s>\n", ToLib );
    __print_goto ( "wrapup" );
    errcnt++;
    goto wrapup;
  }

  /*
   * Macro Library will be sorted depending on sort option chosen
   */

  status = GetMacInLibSort ( FromLib, sort, &macro_def, &nb_macros );

  if ( !( status & 1 ) )
  {
    printf ( "ERROR GetMacInLibSort() in <%s>\n", FromLib );
    if ( fp ) fprintf ( fp, "ERROR GetMacInLibSort() in <%s>\n", FromLib );
    __print_goto ( "wrapup" );
    errcnt++;
    goto wrapup;
  }

  sizebuf = sizeof ( struct GRmd_env );
  gr$get_module_env ( msg	= &msg,
		      sizbuf	= &sizebuf,
		      buffer	= &md_env,
		      nret	= &nret );

  save_save	= ACauto_save;
  ACauto_save	= 0;

  /*
   * Preprocess all mac_defs: Check for nested Nozzles
   */

  status = PreProcMacDefs ( &errcnt, nb_macros, macro_def, &nb_nested_nozz, &nested_nozl );
  if ( errcnt )
  {
    printf ( "ERROR PreProcMacDefs in <%s>\n", FromLib );
    if ( fp ) fprintf ( fp, "ERROR PreProcMacDefs in <%s>\n", FromLib );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*
   * Increase errcnt when there are nested nozzle macros, but these are NOT skipped,
   * to indicate partial success in rebuilding.
   */

  if ( nb_nested_nozz && ! skip_nstd_noz )
  {
    errcnt++;
  }

  if ( nb_nested_nozz )
  {
    printf ( "\n\tThe Library <%s> contains %d Macro's with nested Nozzle's\n", FromLib, nb_nested_nozz );
    if ( fp ) fprintf ( fp, "\n\tThe Library <%s> contains %d Macro's with nested Nozzle's\n", FromLib, nb_nested_nozz );

    for ( i = 0; i < nb_macros; i++ )
    {
      int	nested_found;

      if ( proc_only >= 0 && proc_only != i ) continue;

      nested_found = 0;

      status = om$send (msg		= message ACmacro_defn.ACgive_name ( &mac_name ),
			senderid	= NULL_OBJID,
			targetid	= macro_def[i].objid,
			targetos	= macro_def[i].osnum );

      if ( nb_nested_nozz )
      {
        for ( k=0; k < nb_nested_nozz; k++ )
        {
	  if ( macro_def[i].objid == nested_nozl[k] )
	  {
	    nested_found++;
	    break;
	  }
	  else
	  {
	    continue;
	  }
        }
        if ( nested_found )
        {
	  printf ( "(Nested Nozzle) Macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	  if ( fp ) fprintf ( fp, "(Nested Nozzle) Macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	  continue;
        }
      }
    }

    if ( skip_nstd_noz )
    {
      printf ( "\n\tThese Macro's cannot be processed and will be skipped\n\n" );
      if ( fp ) fprintf ( fp, "\n\tThese Macro's cannot be processed and will be skipped\n\n" );
   }
    else
    {
      printf ( "\tWARNING: These Macro's cannot be processed and should be skipped\n\n" );
      if ( fp ) fprintf ( fp, "\tWARNING: These Macro's cannot be processed and should be skipped\n\n" );
    }
  }

//goto wrapup;	// REMOVE_WHEN_FINISHED_TESTING

  /*
   * Copy each macro from FromLib to ToLib
   *
   * for ci_macros and c macros if .e exist in the product => ci_macro
   *
   * else C macro ...
   */

  nr_ci_macros = nr_regular_macros = nr_condit_macros = nr_invalid_macros = 0;

  for ( i = 0; i < nb_macros; i++ )
  {
    int	nested_found;

    if ( fp ) fflush ( fp );

    if ( proc_only >= 0 && proc_only != i ) continue;

    nested_found = 0;

    status = om$send (	msg		= message ACmacro_defn.ACgive_name ( &mac_name ),
			senderid	= NULL_OBJID,
			targetid	= macro_def[i].objid,
			targetos	= macro_def[i].osnum );

    if ( nb_nested_nozz )
    {
      for ( k=0; k < nb_nested_nozz; k++ )
      {
	if ( macro_def[i].objid == nested_nozl[k] )
	{
	  nested_found++;

	  if ( skip_nstd_noz )
	  {
	    printf ( "Skipping (nested nozzle) macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	    if ( fp ) fprintf ( fp, "Skipping (nested nozzle) macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	    break;
	  }
	  else
	  {
	    printf ( "Processing (nested nozzle) macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	    if ( fp ) fprintf ( fp, "Processing (nested nozzle) macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
	    break;
	  }
	}
      }
      if ( nested_found && skip_nstd_noz )
      {
	continue;
      }
    }

    /*
     * Skip macro['s] with name <mac_to_skp> ...
     */ 
    if ( skipmac )
    {
      if ( mac_to_skp [ strlen ( mac_to_skp ) - 1 ] == '*' )
      {
	if ( strncmp ( mac_name, mac_to_skp , strlen ( mac_to_skp ) - 1 ) == 0 )
	{
      	  printf ( "Skipping macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
      	  if ( fp ) fprintf ( fp, "Skipping macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
      	  continue;
	}
      }
      else
      {
	if ( strcmp ( mac_name, mac_to_skp    ) == 0 )
	{
      	  printf ( "Skipping macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
      	  if ( fp ) fprintf ( fp, "Skipping macro[%d] = [%d,%d], name = <%s>\n", i, macro_def[i].osnum, macro_def[i].objid, mac_name );
      	  continue;
	}
      }
    }

    om$get_classid ( osnum	= macro_def[i].osnum,
		     objid	= macro_def[i].objid,
		     p_classid	= &mac_class );

    if ( om$is_ancestry_valid ( subclassid	= mac_class,
				superclassid	= OPP_ci_mac_def_class_id ) == OM_S_SUCCESS )
    {
      def_type = SMMAC;
      printf ( "Macro <%s> not converted (ci_mac_def)\n", mac_name );
      if ( fp ) fprintf ( fp, "Macro <%s> not converted (ci_mac_def)\n", mac_name );
      continue;
    }
    else if ( om$is_ancestry_valid ( subclassid		= mac_class,
				     superclassid	= OPP_ACcond_def_class_id ) == OM_S_SUCCESS )
    {
      def_type = CONDMAC;
    }
    else if ( om$is_ancestry_valid ( subclassid		= mac_class,
				     superclassid	= OPP_ACmacro_defn_class_id ) == OM_S_SUCCESS )
    {
      def_type = DEFNMAC;
    }
    else
    {
      printf ( "Not a valid macro definition ....? ? \n" );
      if ( fp ) fprintf ( fp, "Not a valid macro definition ....? ? \n" );
      errcnt++;

      if ( do_cntinue )
      {
	goto nxt;
      }
      else
      {
	__print_goto ( "wrapup" );
	goto wrapup;
      }
    }

    /*
     * free previous def
     */

    if ( mac_info.grtemp )
    {
      free ( mac_info.grtemp );
      mac_info.grtemp = NULL;
    }

    if ( mac_info.grfeet )
    {
      free ( mac_info.grfeet );
      mac_info.grfeet = NULL;
    }

    /*
     * get macro definition details
     */

//    printf ( "==>> GetMacInfo : ID[%d]\n", i );

    status = GetMacInfo ( &macro_def[i], def_type, &mac_info );
    if ( !( status & 1 ) )
    {
      printf ( "ERROR get macro definition details \n" );
      if ( fp ) fprintf ( fp, "ERROR get macro definition details \n" );
      errcnt++;

      if ( do_cntinue )
      {
	goto nxt;
      }
      else
      {
	__print_goto ( "wrapup" );
	goto wrapup;
      }
    }

//    printf ( "<<== GetMacInfo : ID[%d] = [%d,%d], name = <%s>\n",
//	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );

    sprintf ( full_name, "%s%s:constructs:%s$def", dir_name, FromLib, mac_info.mac_name );
    sprintf ( new_full_name, "%s%s:constructs:%s$def", dir_name, ToLib, mac_info.mac_name );

    my_env = md_env;
    my_env.md_id.osnum = mac_info.mac_id.osnum;
    my_env.md_id.objid = NULL_OBJID;

    /*
     * need to differentiate each class to use the good construction code
     */

//    printf ( "==>> Construct  : ID[%d] = [%d,%d], name = <%s>\n",
//	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );

    switch ( def_type )
    {
    case SMMAC:
      {
	printf ( "Macro <%s> not converted (ci_mac_def) : ID[%d] = [%d,%d]\n",
			mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid );
	if ( fp ) fprintf ( fp, "Macro <%s> not converted (ci_mac_def) : ID[%d] = [%d,%d]\n",
			mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid );
	nr_ci_macros++;
	continue;

      /***** do not do anything, just print the macro_name

	status = CstSMMac(&mac_info, ToLib, &my_env, &newmacro);
	if(!(status&1))
	{
	  printf("ERROR CstSMMac <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid );
	  qprintf("ERROR CstSMMac <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid );
	  errcnt++;

	  if ( do_cntinue )
	  {
	    goto nxt;
	  }
	  else
	  {
	    __print_goto ( "wrapup" );
	    goto wrapup;
	  }
	}

	break;
       *****/
      }
    case CONDMAC:
      {
	status = CstCondit ( &mac_info, lib_id.osnum, &newmacro );
	if ( !( status & 1 ) )
	{
	  printf ( "ERROR CstCondit <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid  );
	  if ( fp ) fprintf ( fp, "ERROR CstCondit <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid  );
	  errcnt++;

	  if ( do_cntinue )
	  {
	    goto nxt;
	  }
	  else
	  {
	    __print_goto ( "wrapup" );
	    goto wrapup;
	  }
	}
	nr_condit_macros++;
	break;
      }
    case DEFNMAC:
      {
	status = CstMacdefn ( &mac_info, lib_id.osnum, &md_env, &newmacro );

	if ( !( status & 1 ) )
	{
	  printf ( "ERROR CstMacdefn <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid  );
	  if ( fp ) fprintf ( fp, "ERROR CstMacdefn <%s> : ID[%d] = [%d,%d]\n",
	  		mac_info.mac_name, i, macro_def[i].osnum, macro_def[i].objid  );
	  errcnt++;

	  if ( do_cntinue )
	  {
	    goto nxt;
	  }
	  else
	  {
	    __print_goto ( "wrapup" );
	    goto wrapup;
	  }
	}
	nr_regular_macros++;
	break;
      }
    default:
      {
	printf ( "Not a valid macro definition ....? ? : ID[%d] = [%d,%d]\n",
			i, macro_def[i].osnum, macro_def[i].objid );
	if ( fp ) fprintf ( fp, "Not a valid macro definition ....? ? : ID[%d] = [%d,%d]\n",
			i, macro_def[i].osnum, macro_def[i].objid );
	nr_invalid_macros++;
	break;
      }
    }

//    printf ( "<<== Construct  : ID[%d] = [%d,%d], name = <%s>\n",
//	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );

    /*
     * copy default parameter box if any (impossible to construct in
     * a cluster) because need the old definition
     */

    status = di$translate ( objname	= full_name,
			    p_objid	= &old_default.objid,
			    p_osnum	= &old_default.osnum );

    if ( ( status & 1 ) && def_type != SMMAC )
    {
      status = di$translate ( objname	= new_full_name,
			      p_objid	= &new_default.objid,
			      p_osnum	= &new_default.osnum );
      if ( !( status & 1 ) )
      {
	new_env = my_env;
	new_env.md_id.osnum = newmacro.osnum;

	if ( verbose )
	{
	  printf ( "==>> ACmacro_defn.ACcopy_default : ID[%d] = [%d,%d], name = <%s>\n",
	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );
	  if ( fp ) fprintf ( fp, "==>> ACmacro_defn.ACcopy_default : ID[%d] = [%d,%d], name = <%s>\n",
	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );
	}
	status = om$send ( msg	= message ACmacro_defn.ACcopy_default
						   ( &msg, &newmacro, &my_env, &new_env, &new_default ),
			   senderid	= NULL_OBJID,
			   targetid	= mac_info.mac_id.objid,
			   targetos	= mac_info.mac_id.osnum );

	if ( verbose )
	{
	  printf ( "<<== ACmacro_defn.ACcopy_default : ID[%d] = [%d,%d], name = <%s>\n",
	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );
	  if ( fp ) fprintf ( fp, "<<== ACmacro_defn.ACcopy_default : ID[%d] = [%d,%d], name = <%s>\n",
	  		i, macro_def[i].osnum, macro_def[i].objid, mac_info.mac_name );
	}
	as$status ();
	if ( !( status & msg & 1 ) )
	{
	  printf ( "ERROR ACcopy_default on ID[%d] = [%d,%d]\n", i, mac_info.mac_id.osnum, mac_info.mac_id.objid );
	  if ( fp ) fprintf ( fp, "ERROR ACcopy_default on ID[%d] = [%d,%d]\n", i, mac_info.mac_id.osnum, mac_info.mac_id.objid );
	  __print_goto ( "wrapup" );
	  errcnt++;
	  goto wrapup;
	}
      }
    }

    /*
     * need to delete the temporary elts of the copied graph
     * need to be done only specific case and also if fails
     */
nxt:
    for ( k = 0; k < mac_info.copy_list.nb_obj; k++ )
    {
      if ( om$is_objid_valid ( osnum	= md_env.md_id.osnum,
			       objid	= mac_info.copy_list.list[k].clone ) == OM_S_SUCCESS )
      {
	status = om$send ( msg		= message NDnode.NDdelete ( &md_env ),
			   senderid	= NULL_OBJID,
			   targetid	= mac_info.copy_list.list[k].clone,
			   targetos	= md_env.md_id.osnum );
      }
    }

    if ( ( i%100 ) == 0 )
    {
      printf ( "%7d macros of %d processed...\n", i+1, nb_macros );
      if ( fp ) fprintf ( fp, "%7d macros of %d processed...\n", i+1, nb_macros );
    }
  }

  nb_proc_macros = nr_regular_macros + nr_condit_macros + nr_ci_macros + nr_invalid_macros;

  printf ( "\n" );
  if ( fp ) fprintf ( fp, "\n" );

  if ( errcnt || ( nb_macros != nb_proc_macros ) )
  {
    printf ( "Total number of macros skipped or NOT processed due to errors = %d\n", nb_macros - nb_proc_macros );
    if ( fp ) fprintf ( fp, "Total number of macros skipped or NOT processed due to errors = %d\n", nb_macros - nb_proc_macros );
  }

  printf ( "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d, nr_invalid_macros = %d\n",
		   nb_macros, nr_regular_macros, nr_condit_macros, nr_ci_macros, nr_invalid_macros );

  if ( fp )
  {
    fprintf ( fp, "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d, nr_invalid_macros = %d\n",
		   nb_macros, nr_regular_macros, nr_condit_macros, nr_ci_macros, nr_invalid_macros );
    fflush ( fp );
  }

  ACauto_save = save_save;
  ac$save_wd ();

  if ( nested_nozl )
  {
    free ( nested_nozl );
    nested_nozl = NULL;
  }

  if ( mac_info.grtemp )
  {
    free ( mac_info.grtemp );
    mac_info.grtemp = NULL;
  }

  if ( mac_info.grfeet )
  {
    free ( mac_info.grfeet );
    mac_info.grfeet = NULL;
  }

  if ( macro_def )
  {
    free ( macro_def );
    macro_def = NULL;
  }

  __exitFunction ( name = "RebuildLib" );

  if ( errcnt == 0 )
  {
    sprintf ( strng, "SUCCESS Rebuilding Library <%s>", FromLib );
    UI_status ( strng );
    printf ( "%s\n", strng );
    if ( fp ) fprintf ( fp, "%s\n", strng );

    if ( fp )
    {
      fclose ( fp );
    }

    return 1;
  }
  else
  {
    sprintf ( strng, "Partial SUCCESS Rebuilding Library <%s>", FromLib );
    UI_status ( strng );
    printf ( "%s\n", strng );
    if ( fp ) fprintf ( fp, "%s\n", strng );

    if ( fp )
    {
      fclose ( fp );
    }

    return (errcnt = -errcnt);
  }

wrapup:

  nb_proc_macros = nr_regular_macros + nr_condit_macros + nr_ci_macros + nr_invalid_macros;

  printf ( "\n" );
  if ( fp ) fprintf ( fp, "\n" );

  printf ( "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d, nr_invalid_macros = %d\n",
		   nb_macros, nr_regular_macros, nr_condit_macros, nr_ci_macros, nr_invalid_macros );

  if ( fp )
  {
    fprintf ( fp, "Total nb_macros = %d, nr_regular_macros = %d, nr_condit_macros = %d, nr_ci_macros = %d, nr_invalid_macros = %d\n",
		   nb_macros, nr_regular_macros, nr_condit_macros, nr_ci_macros, nr_invalid_macros );
    fflush ( fp );
  }

  for ( k = 0; k < mac_info.copy_list.nb_obj; k++ )
  {
    status = om$send ( msg	= message NDnode.NDdelete ( &md_env ),
		       senderid	= NULL_OBJID,
		       targetid	= mac_info.copy_list.list[k].clone,
		       targetos	= md_env.md_id.osnum );
  }

  if ( nested_nozl )
  {
    free ( nested_nozl );
    nested_nozl = NULL;
  }

  if ( mac_info.grtemp )
  {
    free ( mac_info.grtemp );

        mac_info.grtemp = NULL;
  }

  if ( mac_info.grfeet )
  {
    free ( mac_info.grfeet );
    mac_info.grfeet = NULL;
  }

  if ( macro_def )
  {
    free ( macro_def );
    macro_def = NULL;
  }
  sprintf ( strng, "ERROR Rebuilding Library <%s>", FromLib );
  UI_status ( strng );
  printf ( "%s\n", strng );
  if ( fp ) fprintf ( fp, "%s\n", strng );

  if ( fp )
  {
    fclose ( fp );
  }

  __exit_error_Function ( name = "RebuildLib" );

  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	PreProcMacDefs
(
  int			*retmsg,
  int			 nb_macros,
  struct GRid		*macro_def,
  int			*nb_nstd_nzz,
  GRobjid		**nested_nozzl
)
{
  short			  rc;
  int                     i, j0, k0, error, status, index, index1, nb_other, nb_template, nb_entry, def_type;
  int                     nb_noz = 0;
  long                    msg;
  struct GRid            *entry, *template, *buf, *feet, macro_id, plcd_mac, expr_id;
  struct GRmd_env         my_env, md_env;
  IGRlong                 sizebuf, nret;
  OM_S_OBJID             *other;
  struct mac_info         mac_info;
  GRclassid               mac_class;
  char			  classname [DI_PATH_MAX];
  char                    macro_name[DI_PATH_MAX], *cname;
  struct ret_struct	  ret_struct;
//  struct FT_sd_objarray   ObjArray;
  GRobjid		  obj_array[1];
  int			  nb_req = 1;
  GRclassid		  ClassId = OPP_GRcsbase_class_id;
  double		  extend = 10.0;

  struct GRid      base_coor_id;

  __enterFunction ( name = "PreProcMacDefs" );

  *nested_nozzl = NULL;

  sizebuf = sizeof ( struct GRmd_env );
  gr$get_module_env ( msg	= &msg,
		      sizbuf	= &sizebuf,
		      buffer	= &md_env,
		      nret	= &nret );

  my_env = md_env;
  base_coor_id.objid = NULL_OBJID;

  /*
   * Attempting to fix the problem with macros containing nested nozzles ...
   * - Get the ID of the base_coord system
   * - create a dummy expression
   * Use these as templates for placing in the designfile the macros which
   * contain nested nozzles.
   * Does NOT solve the problem yet, but code is being kept for future testing ...
   */

  if ( base_coor_id.objid == NULL_OBJID )
  {
    status = GetObjectsFromRtree ( ClassId, nb_req, obj_array, extend );
    if ( status == 1 )
    {
      base_coor_id.objid = obj_array[0];
      base_coor_id.osnum = md_env.md_id.osnum;
    }
    __printf ( "base_coor_id = [%d,%d]", `base_coor_id.osnum, base_coor_id.objid` );

//    status = om$construct (	classid = OPP_expression_class_id,
//				osnum	=  expr_id.osnum = md_env.md_id.osnum,
//				p_objid	= &expr_id.objid,
//				msg	= message expression.create ( "dummy_name", "1.0", &rc) );
//
//    __printf ( "expr_id      = [%d,%d], rc = %d", `expr_id.osnum, expr_id.objid, rc` );
  }

 for ( j0=0; j0 < nb_macros; j0++ )
 {
  mac_info.mac_id		= macro_def[j0];
  mac_info.grtemp		= NULL;
  mac_info.grfeet		= NULL;
  mac_info.copy_list.nb_obj	= 0;

  my_env.md_id.osnum = mac_info.mac_id.osnum;

  error		= 0;
  template	= NULL;
  feet		= NULL;
  entry		= NULL;
  def_type	= 0;

  status = om$send ( msg	= message ACmacro_defn.ACgive_name ( &mac_info.mac_name ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_upscan
						     ( &mac_info.tot_up,
						       &mac_info.prop,
						       &mac_info.xdup ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_temp_desc
						     ( &mac_info.nb_temp, &mac_info.temp_defn ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  status = om$send ( msg	= message ACmacro_defn.ACgive_feet_desc
						     ( &mac_info.nb_feet, &mac_info.myfeet ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  status = GetMacType ( j0, macro_def, &def_type );

  if ( def_type == SMMAC )
  {
    /*
     * do not get more info for ci_mac_def
     */
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*
   * special case for conditional
   */

  if ( def_type == CONDMAC )
  {
    status = om$send ( msg	= message ACcond_def.ACgive_condit_desc
						       ( &mac_info.condit.num_cond,
							 &mac_info.condit.desc,
							 &mac_info.condit.num_def,
							 &mac_info.condit.def ),
		       senderid	= NULL_OBJID,
		       targetid	= macro_def[j0].objid,
		       targetos	= macro_def[j0].osnum );
    as$status ();

    di$give_pathname ( osnum	= mac_info.mac_id.osnum,
		       pathname	= macro_name );
    strcat ( macro_name, ":constructs:" );
    cname = strchr ( macro_name, '\0' );

    for ( i = 0; i < mac_info.condit.num_cond; i++ )
    {
      strcpy ( cname, mac_info.condit.desc[i].konst );

      status = di$translate(objname	= macro_name,
			    p_objid	= &macro_id.objid,
			    p_osnum	= &macro_id.osnum );
      if ( !( status & 1 ) )
      {
	di$report_error ( sts = status );
	printf ( "Macro <%s> has to be copied first to the target library\n", macro_name );
	if ( fp ) fprintf ( fp, "Macro <%s> has to be copied first to the target library\n", macro_name );
      }

      __printf ( "COND_MAC_ID[%d] [%d,%d] Name <%s> desc[%2d] [%d,%d] <%s>",
	`j0, macro_def[j0].osnum, macro_def[j0].objid, mac_info.mac_name, i, macro_id.osnum, macro_id.objid, mac_info.condit.desc[i].konst` );

//      printf ( "COND_MAC_ID[%d] [%d,%d] Name <%s> desc[%2d] [%d,%d] <%s>\n",
//	j0, macro_def[j0].osnum, macro_def[j0].objid, mac_info.mac_name, i, macro_id.osnum, macro_id.objid, mac_info.condit.desc[i].konst );
    }

    for ( i = 0; i < mac_info.condit.num_cond; i++ )
    {
      int	nb_nstd_sav, found_nested_macro;
      strcpy ( cname, mac_info.condit.desc[i].konst );

      status = di$translate(objname	= macro_name,
			    p_objid	= &macro_id.objid,
			    p_osnum	= &macro_id.osnum );
      if ( !( status & 1 ) )
      {
	di$report_error ( sts = status );
	printf ( "Macro <%s> has to be copied first to the target library\n", macro_name );
	if ( fp ) fprintf ( fp, "Macro <%s> has to be copied first to the target library\n", macro_name );
      }

      found_nested_macro = 0;
      nb_nstd_sav = *nb_nstd_nzz;
      for ( k0 = 0; k0 < nb_nstd_sav; k0++ )
      {
	if ( macro_id.objid == (*nested_nozzl) [k0] )
	{
	  (*nb_nstd_nzz)++;

	  if ( *nested_nozzl == NULL )
	  {
	    (*nested_nozzl) = ( GRobjid * ) om$malloc ( size = *nb_nstd_nzz * sizeof ( GRobjid ) );
	  }
	  else
	  {
	    (*nested_nozzl) = ( GRobjid * ) om$realloc ( size = *nb_nstd_nzz * sizeof ( GRobjid ), ptr = (char *) (*nested_nozzl) );
	  }

	  if ( *nested_nozzl == NULL )
	  {
	    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
	    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
	    error = 1;
	    __print_goto ( "wrapup" );
	    goto wrapup;
	  }

	  (*nested_nozzl) [ *nb_nstd_nzz - 1 ] = macro_def[j0].objid;

	  found_nested_macro++;
	  break;
	}
      }
      if ( found_nested_macro )
      {
	break;
      }
      else
      {
	continue;
      }
    }

    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*
   * Get macro template
   */

  status = om$send ( msg	= message NDnode.NDget_objects ( ND_ROOT | ND_IN_BUF,
							  NULL, 0, &buf, 0, OM_K_MAXINT, &nb_template ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  if ( nb_template == 0 )
  {
    printf ( "ERROR no template for the macro def\n" );
    if ( fp ) fprintf ( fp, "ERROR no template for the macro def\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  template = ( struct GRid * ) om$malloc ( size = nb_template * sizeof ( struct GRid ) );
  if ( !template )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }
  OM_BLOCK_MOVE ( buf, template, nb_template * sizeof ( struct GRid ) );

  status = om$send ( msg	= message ACpretend.NDgive_structure (
							&msg,
							&ret_struct,
							&my_env ),
		     senderid	= NULL_OBJID,
		     targetid	= mac_info.mac_id.objid,
		     targetos	= mac_info.mac_id.osnum );
  as$status ();
  __printf ( "ACpretend.NDgive_structure() status = %d, msg = %d, ret_struct = %#x", `status, msg, ret_struct.type` );

  for ( i = 0; i < nb_template; i++ )
  {
    om$get_classid ( osnum	= template[i].osnum,
		     objid	= template[i].objid,
		     p_classid	= &mac_class );
    om$get_classname(osnum	= template[i].osnum,
		     objid	= template[i].objid,
		     classname	= classname );

    __printf ( "TEMPLATE_ID[%d] [%d,%d] Name <%s> template[%2d] [%d,%d] clid %d Name <%s>",
    `j0, macro_def[j0].osnum, macro_def[j0].objid, mac_info.mac_name, i, template[i].osnum, template[i].objid, mac_class, classname` );
  }

  status = om$send ( msg	= message ACcomplex.ACget_other ( &msg, &nb_other, &other ),
		     senderid	= NULL_OBJID,
		     targetid	= macro_def[j0].objid,
		     targetos	= macro_def[j0].osnum );
  as$status ();

  feet = ( struct GRid * ) om$malloc ( size = mac_info.nb_feet * sizeof ( struct GRid ) );
  if ( !feet )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  for ( i = 0; i < mac_info.nb_feet; i++ )
  {
    if ( ( mac_info.myfeet[i].chan & 3 ) == feet_in_graphic )
    {
      index	= mac_info.myfeet[i].pos;
      index1	= mac_info.myfeet[i].chan >> 2;

      feet[index].objid = other[index1];
      feet[index].osnum = mac_info.mac_id.osnum;

      if ( om$is_objid_valid ( osnum = feet[index].osnum, objid = feet[index].objid ) != OM_S_SUCCESS )
      {
	printf ( "index1 = %d ==>> other[%d] = feet[%d] = [%d,%d] is INVALID in MACRO <%s>\n",
		index1, index1, index, feet[index].osnum, feet[index].objid, mac_info.mac_name );

	printf ( "  myfeet[%d] : pos = %#o, chan = %#o (index1 = `chan >> 2'), prop = %#o, name = <%s>\n",
		i, mac_info.myfeet[i].pos, mac_info.myfeet[i].chan, mac_info.myfeet[i].prop, mac_info.myfeet[i].name );

	if ( fp ) fprintf ( fp, "index1 = %d ==>> other[%d] = feet[%d] = [%d,%d] is INVALID in MACRO <%s>\n",
		index1, index1, index, feet[index].osnum, feet[index].objid, mac_info.mac_name );

	if ( fp ) fprintf ( fp, "  myfeet[%d] : pos = %#o, chan = %#o (index1 = `chan >> 2'), prop = %#o, name = <%s>\n",
		i, mac_info.myfeet[i].pos, mac_info.myfeet[i].chan, mac_info.myfeet[i].prop, mac_info.myfeet[i].name );
      }
    }
  }

  entry = ( struct GRid * ) om$malloc ( size = ( mac_info.nb_feet + nb_template ) * sizeof ( struct GRid ) );
  if ( !entry )
  {
    printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
    if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
    error = 1;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  nb_entry = 0;
  for ( i = 0; i < nb_template; i++ )
  {
    entry[nb_entry++] = template[i];
  }

  nb_noz = 0;

  for ( i = 0; i < mac_info.nb_feet; i++ )
  {
    entry[nb_entry++] = feet[i];

    om$get_classid ( osnum	= feet[i].osnum,
		     objid	= feet[i].objid,
		     p_classid	= &mac_class );
    om$get_classname(osnum	= feet[i].osnum,
		     objid	= feet[i].objid,
		     classname	= classname );

//    if ( mac_class == OPP_VRNozHold_class_id )	// Cannot use this in VDS
    if ( strcmp ( classname, "VRNozHold" ) == 0 )
    {
      __printf ( "NOZZLE_ID[%d] [%d,%d] Name <%s> feet[%2d] [%d,%d] clid %d Name <%s>",
      `j0, macro_def[j0].osnum, macro_def[j0].objid, mac_info.mac_name, i, feet[i].osnum, feet[i].objid, mac_class, classname` );

//      nb_noz++;	// CANCELLED (to prevent placement of macro with nested nozzle)

      (*nb_nstd_nzz)++;

      if ( *nested_nozzl == NULL )
      {
      	(*nested_nozzl) = ( GRobjid * ) om$malloc ( size = *nb_nstd_nzz * sizeof ( GRobjid ) );
      }
      else
      {
     	(*nested_nozzl) = ( GRobjid * ) om$realloc ( size = *nb_nstd_nzz * sizeof ( GRobjid ), ptr = (char *) (*nested_nozzl) );
      }

      if ( *nested_nozzl == NULL )
      {
	printf ( "NO DYNAMIC MEMORY (malloc fails)\n" );
	if ( fp ) fprintf ( fp, "NO DYNAMIC MEMORY (malloc fails)\n" );
	error = 1;
	__print_goto ( "wrapup" );
	goto wrapup;
      }

      (*nested_nozzl) [ *nb_nstd_nzz - 1 ] = macro_def[j0].objid;

      break;
    }
  }

  if ( nb_noz )
  {
    template[0] = base_coor_id;
    for ( i = 1; i < nb_template; i++ )
    {
      template[i] = expr_id;
    }
    status = CstPlcMacro ( &msg, mac_info.mac_name, nb_template, template, &md_env, &plcd_mac );

    if ( status & msg & 1 )
    {
      printf ( "(Nested Nozzle) Macro ID [%d,%d] Name <%s> HAS BEEN PLACED\n",
		plcd_mac.osnum, plcd_mac.objid, mac_info.mac_name );

      if ( fp ) fprintf ( fp, "(Nested Nozzle) Macro ID [%d,%d] Name <%s> HAS BEEN PLACED\n",
		plcd_mac.osnum, plcd_mac.objid, mac_info.mac_name );
    }
    goto wrapup;
  }
  else
  {
    goto wrapup;
  }

wrapup:

  *retmsg = error;

  if ( entry )
  {
    free ( entry );
    entry = NULL;
  }
  if ( template )
  {
    free ( template );
    template = NULL;
  }
  if ( feet )
  {
    free ( feet );
    feet = NULL;
  }

  if ( error )
  {
    if ( mac_info.grtemp )
    {
      free ( mac_info.grtemp );
      mac_info.grtemp = NULL;
    }
    if ( mac_info.grfeet )
    {
      free ( mac_info.grfeet );
      mac_info.grfeet = NULL;
    }
    continue;
  }
  else
  {
    continue;
  }
 }

  __exitFunction ( name = "PreProcMacDefs" );

  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	GetMacType
(
  int		 i,
  struct GRid	*macro_def,
  int		*macro_type
)
{
  int	 	 def_type = 0, status;
  GRclassid	 mac_class;
  char		*mac_name;

  __enterFunction ( name = "GetMacType" );

  om$get_classid ( osnum	= macro_def[i].osnum,
		   objid	= macro_def[i].objid,
		   p_classid	= &mac_class );

  if ( om$is_ancestry_valid (	subclassid	= mac_class,
				superclassid	= OPP_ci_mac_def_class_id ) == OM_S_SUCCESS )
  {
    def_type = SMMAC;
    status = om$send (	msg		= message ACmacro_defn.ACgive_name ( &mac_name ),
			senderid	= NULL_OBJID,
			targetid	= macro_def[i].objid,
			targetos	= macro_def[i].osnum );

    as$status ();
    printf ( "Macro[%d] <%s> will not be converted (ci_mac_def)\n", i, mac_name );
    if ( fp ) fprintf ( fp, "Macro[%d] <%s> will not be converted (ci_mac_def)\n", i, mac_name );
  }
  else if ( om$is_ancestry_valid ( subclassid	= mac_class,
				   superclassid	= OPP_ACcond_def_class_id ) == OM_S_SUCCESS )
  {
    def_type = CONDMAC;
  }
  else if ( om$is_ancestry_valid ( subclassid	= mac_class,
				   superclassid	= OPP_ACmacro_defn_class_id ) == OM_S_SUCCESS )
  {
    def_type = DEFNMAC;
  }
  else
  {
    printf ( "ID[%d] = [%d,%d] Is Not a Valid Macro Definition ....?!?\n", i, macro_def[i].osnum, macro_def[i].objid);
    if ( fp ) fprintf ( fp, "ID[%d] = [%d,%d] Is Not a Valid Macro Definition ....?!?\n", i, macro_def[i].osnum, macro_def[i].objid);
  }

  *macro_type = def_type;

  __exitFunction ( name = "GetMacType" );

  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int CstPlcMacro
(
  int			*retmsg,
  char			*macro_name,
  int			 nb_template,
  struct GRid		*template,
  struct GRmd_env	*md_env,
  struct GRid		*hdr
)
{
  int		 suc = 0, status;
  char		 rep = 0;

  __enterFunction ( name = "CstPlcMacro" );

  hdr->objid = NULL_OBJID;
  hdr->osnum = md_env->md_id.osnum;

  status = om$construct (	classname = "ACconst",
				osnum	  =  hdr->osnum,
				p_objid   = &hdr->objid );
  as$status( action = RET_STATUS );

  status = om$send (	msg	 = message ACconst.ACmplace (
							&suc,
							 (int)AChdr_nodisplay,
							 rep,	//AC_NO_REP,
							macro_name, 
							 nb_template,
							template,
							md_env ),
			senderid = NULL_OBJID,
			targetid = hdr->objid,
 			targetos = hdr->osnum );
  as$status();

  *retmsg = suc;

  __exitFunction ( name = "CstPlcMacro" );

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * Remove the Macro Library if it already exists
 */

int	RemoveMacroLib
(
  char                   *macro_lib
)
{
  int                     i0;
  int                     status;
  char                    full_name[DI_PATH_MAX], strng[80], *ToLib = NULL;
  GRspacenum		  mac_osnum;
  FILE			 *fp1 = NULL;

  __enterFunction ( name = "RemoveMacInLib" );

  /*
   * Set the mac_lib active
   */

  ToLib = strrchr ( macro_lib, ':' );
  if ( ToLib )
  {
    ToLib++;
//    printf ( "ToLib = <%s>\n", ToLib );
  }

  /*
   * Get osnum of macro library to remove
   */
  full_name[0] = '\0';
  VD_get_OMspace_num ( &mac_osnum, ToLib, full_name );

  /*
   * Remove macro library
   */
  if ( mac_osnum > 2 )
  {
    status = VD_unmount_invisible_lib ( mac_osnum, ToLib );
  }

  if ( full_name[0] != '\0' )
  {
    fp1 = fopen ( full_name, "r" );
    if ( fp1 )
    {
      fclose ( fp1 );

      sprintf ( strng, "Library <%s> already exists and will first be removed", full_name );
      UI_status ( strng );
      printf ( "%s\n", strng );
      if ( fp ) fprintf ( fp,"%s\n", strng );
      {
	i0 = remove ( full_name );
	if ( i0 )
	{
	  sprintf ( strng, "Failed to remove Library <%s>", full_name );
	  UI_status ( strng );
	  printf ( "%s\n", strng );
	  if ( fp ) fprintf ( fp,"%s\n", strng );
	}
      }
    }
  }

  __exitFunction ( name = "RemoveMacInLib" );

  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void	VD_get_OMspace_num
(
  GRspacenum	*osn,
  char		*name,
  char		*full_name
)
{
  int	i;
  char	*ptr = NULL;

  __enterFunction ( name = "VD_get_OMspace_num" );

  *osn = 0;
  __printf ( "MaxOS : %d", OM_Gw_maxOS );
  for( i = 0 ; i < OM_Gw_maxOS ; i=i+1 )
  {
    if( OM_GA_OSDs[ i ] )
    {
      ptr = strrchr ( OM_GA_OSDs[i]->name, '/' );
      if ( ptr )
      {
	ptr++;
	if ( strcmp ( ptr, name ) == 0 )
	{
	  *osn = i;
	  strcpy( full_name, OM_GA_OSDs[i]->name );
	  break;
	}
      }
    }
  }

  __exitFunction ( name = "VD_get_OMspace_num" );
}  

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/********************************************************************
  Unmount the object space directories of the macro library before
  save of the current object space.
  These directories were mounted when loading the symbols of contents
  table between tmp_defn in the current file and the real definition
  in the reference file is establish. (function ACload_symbol)
*********************************************************************/

int	VD_unmount_invisible_lib
(
  GRspacenum 	 osnum,
  char		*name
)
{
  IGRlong	 status;
  OM_S_OBJID	 tmp;
  IGRchar	*p_name;
  IGRchar	dir_name[DI_PATH_MAX];
  GRspacenum	 file_osnum, lib_osnum;
  int		 invisible_index;

  __enterFunction ( name = "VD_unmount_invisible_lib" );

  __printf ( "START ASunmount_invisible_lib : %d %s", `osnum, name` );

  status = ex$get_cur_mod ( osnum = &file_osnum );

  status = di$give_pathname (	osnum	 = file_osnum,
				pathname = dir_name );

  strcat( dir_name, ":constructs_lib" );

  status = di$translate(osnum	= file_osnum,
			objname = dir_name,
			p_objid = &tmp);

  if ( status != DIR_S_SUCCESS ) goto wrapup;

  /*
   * see if the library is mounted in the sub-directory system.
   */

  p_name = strrchr( name, '/' );
  p_name = p_name ? p_name+1 : name ;
  strcat( dir_name, ":" );
  strcat( dir_name, p_name );

  status = di$translate(osnum   = file_osnum,
			objname = dir_name,
			p_objid = &tmp);
  if ( status != DIR_S_SUCCESS ) goto wrapup;

  status = di$give_osnum(pathname = dir_name ,
			 p_osnum  = &lib_osnum);
  if ( ! ( status & 1 ) ) goto wrapup;

  __printf ( "found (%d) [%d] %s", `osnum, lib_osnum , dir_name` );
	    
  if( osnum == lib_osnum  &&
      ex$is_invis(	mod_osnum	= lib_osnum,
			index		= &invisible_index ) )
  {
    status = ex$close_module(	ftype = EX_invisible,
				index = invisible_index,
				flag  = 0 );
    as$status( sts = status );

    __printf ( "removed[ %d ] %s", `status , dir_name` );
  }
  else
  {
    __printf ( "UMOUNT invisible %d %s", `invisible_index, dir_name` );

    status = di$umount ( dirname = dir_name );
    if ( ! ( status & 1 ) ) di$report_error ( sts = status );
  }

  /*
   * cleanup the library list structures.
   */
  __printf ( "LIB_PATH: %s REM_PATH", p_name );

  status = ac$construct_path(	mode	= AC_REM_PATH,
				name	= p_name );
  as$status();

wrapup:

  __exitFunction ( name = "VD_unmount_invisible_lib" );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int GetObjectsFromRtree
(
  GRclassid		 ClassId,
  int			 nb_req,
  GRobjid		*obj_array,
  double		 extend
)
{
  DB_3D_DBL_BOX		Fence;
//struct OM_sd_objarray	*ObjArray;
  struct FT_sd_objarray	ObjArray;

  struct GRid		ModuleGrid;
  OM_S_CHANSELECT   	chan;
  OM_S_MESSAGE		p_msg;
  IGRlong	   	sts;
  OM_S_KEY_DESC		rtree_key_test;

  IGRint		ret_bis,i,size, Size;
  char			classname[256];

  GRclassid		ObjClassId;
  IGRint		ObjCount;
  IGRint		MaxCount;

  struct arglist
		{
		  struct OM_sd_objarray	*Array;
		  OM_S_KEY_DESC		*rtree_key;
		  IGRchar		 null0;
		  IGRint		 null1;
		  IGRint		*ret;
		} my_arglist;

  __enterFunction ( name = "GetObjectsFromRtree" );

  GRfindmod (&ModuleGrid);

  Fence.xmin = -extend;
  Fence.ymin = -extend; 
  Fence.zmin = -extend; 
  Fence.xmax =  extend; 
  Fence.ymax =  extend; 
  Fence.zmax =  extend; 

  __printf ( "ModuleGrid = [%d,%d]", `ModuleGrid.osnum, ModuleGrid.objid` );

  sts = om$make_chanselect (	channame	= "module.primary",
				p_chanselect	= &chan);
  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    __exit_error_Function ( name = "GetObjectsFromRtree" );
    return 0;
  }

  Size = 3 * sizeof (int) + sizeof (ObjArray.array);
  ObjArray.size = Size;

  ObjArray.count	= 0;
  ObjArray.tree_type	= KEY_3D_DBL;
  rtree_key_test.type	= KEY_3D_DBL;

  rtree_key_test.key.p_3ddbl = (DB_3D_DBL_BOX *)&Fence;
 
  size = sizeof(my_arglist);

  __printf ( "size = %d",size );
  __printf ( "Size = %d",Size );

  sts = om$make_message (	classname	= "OMrtree",
		  		methodname	= "translate",
		  		size		= size,
		  		p_arglist	= &my_arglist,
		  		p_msg		= &p_msg);

  my_arglist.Array	= (struct OM_sd_objarray *) &ObjArray;
  my_arglist.rtree_key	= &rtree_key_test;
  my_arglist.null0	=  0;
  my_arglist.null1	=  0;
  my_arglist.ret	= &ret_bis;

  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    __exit_error_Function ( name = "GetObjectsFromRtree" );
    return 0;
  }

  __printf ( "p_msg.select.DefClassid = %d",p_msg.select.DefClassid );
  __printf ( "p_msg.select.ReqClassid = %d",p_msg.select.ReqClassid );
  __printf ( "p_msg.select.FuncIndex  = %d",p_msg.select.FuncIndex );
  __printf ( "p_msg.size = %d",p_msg.size);

  sts = om$send (	msg	 = &p_msg,
			senderid = ModuleGrid.objid,
			targetos = ModuleGrid.osnum,
			p_chanselect = &chan);

 if(sts! = OM_S_SUCCESS)
 {
   om$report_error(sts = sts);
   __exit_error_Function ( name = "GetObjectsFromRtree" );
   return 0;
 }

  /*
   * Control if the ObjArray was big enough to hold the objects
   */
  MaxCount = ( ObjArray.size - 3 * sizeof (IGRint) ) / sizeof (GRobjid);

  __printf ("GetObjectsFromRtree.. MaxCount = %d", MaxCount);

  if (ObjArray.count >= MaxCount)
  {
    printf ("GetObjectsFromRtree.. ObjArray limited to %d Objects\n", MaxCount); 
    if ( fp ) fprintf ( fp,"GetObjectsFromRtree.. ObjArray limited to %d Objects\n", MaxCount); 
    ObjArray.count = MaxCount;
  }

  ObjCount = 0;
  for(i=0; i < ObjArray.count; i++)
  {
    om$get_classid (	objid	  = ObjArray.array[i],
			osnum	  = ModuleGrid.osnum,
			p_classid = &ObjClassId);

    om$get_classname (	objid     = ObjArray.array[i],
			osnum	  = ModuleGrid.osnum,
			classname = classname);

    if (om$is_ancestry_valid (	subclassid   = ObjClassId,
				superclassid = ClassId) == OM_S_SUCCESS)
    {
      ObjArray.array[ObjCount] = ObjArray.array[i];
      __printf ( "ObjArray.array[%i] = %i, ClassId = %i, classname = <%s>",
		`i, ObjArray.array[ObjCount], ObjClassId,classname` );
      ObjCount++;
    }
  }
  ObjArray.count = ObjCount;

  if ( ObjCount )
  {
    for(i=0; i < MIN (nb_req, ObjCount); i++ )
    {
      obj_array[i] = ObjArray.array[i];
    }
  }

  __printf ("GetObjectsFromRtree: ObjCount = %d", ObjCount);

  __exitFunction ( name = "GetObjectsFromRtree" );

  return ObjCount;
}

end implementation Root;
