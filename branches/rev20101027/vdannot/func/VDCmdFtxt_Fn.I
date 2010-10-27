
/* $Id: VDCmdFtxt_Fn.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/func/ VDCmdFtxt_Fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt_Fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/10/11  21:04:38  pinnacle
# tr179900822
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/11/06  06:37:30  pinnacle
# Replaced: vdannot/func/VDCmdFtxt_Fn.I for:  by ksundar for vds
#
# Revision 1.2  1997/11/05  09:02:54  pinnacle
# Replaced: vdannot/func/VDCmdFtxt_Fn.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/10/15  16:19:02  pinnacle
# Replaced: vdannot/func/VDCmdFtxt_Fn.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/02  12:10:36  pinnacle
# Replaced: ./vdannot/func/VDCmdFtxt_Fn.I for:  by azuurhou for vds.240
#
# Revision 1.4  1996/04/24  19:16:06  pinnacle
# Replaced: vdannot/func/VDCmdFtxt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.3  1996/03/28  20:20:04  pinnacle
# Replaced: vdannot/func/VDCmdFtxt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/08/18  23:04:08  pinnacle
# Replaced: vdannot/func/*.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/07/25  15:50:48  pinnacle
# Created: vdannot/func/VDCmdFtxt_Fn.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      4/15/96         Ad              Change ACgive_structure to 
 *                                      vd$review_params 
 *	10/15/96	HF		TR # 179603359
 *					Modified function VDSsplit_par_str().
 *					The original version of this function removes
 *					every blank from an attribute/parameter string.
 *					The new version strictly maintains the unmodified
 *					attribute/parameter and only splits the string of
 *					concatenated attributes/parameters in its separate
 *					fields (", " is assumed to be the separator token).
 *
 *	11/05/97	Ad/Sundar	Changed the function VDcreate_text2
 *					for expression objects.	
 *      10/11/99        ah              TR179900822 Crash when format is wrong type
 *                                      Users will still need to fix the format
 * -------------------------------------------------------------------*/

/*
 *
 *	Filename:	VDCmdFtxt_Fn.I
 *	Author:		Ad Zuurhout
 *
 *	Date:		05-MARS-1992
 *
 *	Description:	This file contains functions used by the command for
 *			creation of formatted text expresssion. 
 *	History:
 *	AdZ	05-Mrs-92	Creation date.
 *	AdZ	05-Oct-92	Add fct delete formats.
 */

class implementation Root;

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "acdef.h"
#include "acmacros.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "macro.h"
#include "parametric.h"
#include "expression.h"
#include "expmacros.h"

#include "ASmessages.h"

#include "AS_status.h"
#include "AS_debug.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDSannot.h"
#include "vdparmacros.h"
#include "v_miscmacros.h"

/*
#define vdserrDEBUG 1
#define vdsDEBUG 1
*/

#include "v_dbgmacros.h"

#include "VDdrwlo.h"
#include "vdtblmacros.h"
#include "VDattrexp.h"

from	NDmacro		import	ACgive_structure;
from	expression	import	NDgive_value;
from	ACcpx		import	ACfind_temp_obj;
from	ACrg_collect	import	AClist_attribute, NDdelete;

#define AS_DEBUG	1

extern	NDexec_batch();
extern	EXP_create(), EXP_create_double();
extern	EXP_delete_by_name(), EXP_delete_by_objid();
extern	int EXP_modify_by_name(), EXP_modify_by_objid();
extern	GRdpb_get();
extern short	VRlocate_pattern();


/************************************************************************/
/*	FUNCTION VDSsplit_buffer					*/
/************************************************************************/

VDSsplit_buffer( buffer, name, string, params )
IGRchar	*buffer;
IGRchar	*name;
IGRchar	*string;
IGRchar	*params;
/*.VDSsplit_buffer*/
{
IGRint	i,ii,j,k,len;
IGRchar	tmp_str[TEXT_SIZE];
/*
 * This function read a text buffer from the ASCII input file
 * and split them in case a format name is defined for the format text
 */
  name[0] = '\0';
  string[0] = '\0';
  params[0] = '\0';
  len = strlen(buffer);

  if( ! len ) return( FALSE );

  i=0;
  while((buffer[i] == ' ' ) ||
	(buffer[i] == '\t') ||
	(buffer[i] == '\n') ){
    i++;
    if( buffer[i] == '\0' )
      return( FALSE );
  }

  if( buffer[i] == '\"' ){
    /*| no formatname defined */
    k=0;
    i++; /* string start after double quote */
    for(j=i;j<len;j++) string[k++] = buffer[j];
    string[k] = '\0';
  }
  else{
    k=0;
    while( i<len && buffer[i] != '=' ) name[k++] = buffer[i++];
    name[k] = '\0';
    if( i==len){
      /* error in buffer */
      return( FALSE );
    }
    /*" name: %s\n", name */
    i++;
    while(buffer[i] == ' ' || buffer[i] == '\t' ||
    	  buffer[i] == '\n'|| buffer[i] == '\"' ){
      i++;
      if( buffer[i] == '\0' )
        return( FALSE );
    }
    k=0;
    for(j=i;j<len;j++) string[k++] = buffer[j];
    string[k] = '\0';
  }
  
  /* remove the space character at end */
  len = strlen( name );
  while((len>0)&&(name[len] == '\0')&&(name[len-1] == ' ')){
    len--; name[len] = '\0';
  }
  /*" name: <%s>\n", name */

  /* find parameters string */
  i = len = strlen( string );
  while( i >= 0 ){
    if( string[i] == '\"' )
      break;
    i--;
  }
  ii = i;
  /* skip the comma */
  while((string[i] == '\"')||(string[i] == ' ')||(string[i] == ',')) i++;

  k=0;
  for(j=i;j<len;j++) params[k++] = string[j];
  params[k] = '\0';
  /*" params: <%s>\n", params */

  string[ii] = '\0';
  len = strlen( string );
  while( (len>0) && (string[len] == '\0') && (string[len-1] == ' ') ){
    len--; string[len] = '\0';
  }

  /*" string: <%s>\n", string */
  strcpy( tmp_str, string );
  len = strlen( tmp_str );
  /*" len(%d): <%s>\n", len, tmp_str */

  /* convert the newline characters */
  i=k=0;
  while(i<len){
    if( tmp_str[i] == '\\' && tmp_str[i+1] == 'n' ){
      string[k++] = 27;
      string[k++] = 10;
      i+=2;
    }
    else{
      string[k++] = tmp_str[i++];
    }
  }
  string[k] = '\0';
  /*" string: <%s>\n", string */

  return( TRUE );
}

/************************************************************************/
/*	FUNCTION VDSwrite_formats					*/
/************************************************************************/

VDSwrite_formats( for_name, string, params, macro, option )
IGRchar		*for_name;
IGRchar		*string;
IGRchar		*params;
IGRchar		*macro;
IGRboolean	option;
/*.VDSwrite_formats*/
{
int	status = OM_S_SUCCESS;
IGRchar	f_name[TEXT_SIZE], for_dir[TEXT_SIZE];
IGRchar	dir_name[TEXT_SIZE], pwd_dir[TEXT_SIZE];
GRspacenum cur_os;
struct	GRid	obj;
IGRint	index,len;

  SetProc( VDCmdFtxt_Fn.VDSwrite_formats ); Begin


  /* TR179601237 
  len = 0;
  len = strlen(string);
  if ( len > 80 ) {
        __DBGpr_str(" string > 80", string);
        string[80]='\0';
        __DBGpr_str(" cut string ", string);
  }
  len = 0;
  len = strlen(params);
  if ( len > 80 ) {
        __DBGpr_str(" params > 80", params);
        params[80]='\0';
        __DBGpr_str(" cut params ", params);
  }
  */
/*
 * This function creates or modifies an expression in the directory system.
 * In case a format name (arg: name) is defined the expression get it's 
 * own name, otherwise a default name will be generated.
 */

  pwd_dir[0] ='\0';

  if( macro == NULL ){
    /*| no valid expression found */
    return( OM_S_SUCCESS );
  }

  if( string == NULL ){
    /*| no valid expression */
    return( OM_S_SUCCESS );
  }

  /* get current directory */
  status = di$pwd( dirname = pwd_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't get current directory name \n");
    goto wrapup;
  }

  /*" macro  : %s\n", macro  */
  /*" string : %s\n", string */
  /*" params : %s\n", params */

  ex$get_cur_mod( osnum = &cur_os );
  status = di$give_pathname( osnum = cur_os, pathname = dir_name );
  as$status( action = RET_STATUS );

  status = di$cd( dirname = dir_name );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't go to directory: %s \n", dir_name );
    goto wrapup;
  }

  strcat( dir_name, VD_FTEXT_DIR );

  /* test if directory exists */
  status = di$translate(objname = dir_name,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /* create directory */
    obj.objid = NULL_OBJID;
    status = di$mkdir(	dirname = VD_FTEXT_DIR,
			p_dirid = &obj.objid,
			p_osnum = &obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /* mkdir fails */
      printf(" Can't create directory : %s\n", dir_name );
      goto wrapup;
    }
  }

  /* goto directory formats */
  status = di$cd( dirname = dir_name );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't get current directory name \n");
    goto wrapup;
  }
  
  sprintf( for_dir, "%s:%s", dir_name, macro );

  /* test if macro directory already exist */
  status = di$translate(objname = for_dir,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /* create directory */
    obj.objid = NULL_OBJID;
    status = di$mkdir(	dirname = macro,
			p_dirid = &obj.objid,
			p_osnum = &obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /* mkdir fails */
      printf(" Can't create directory : %s\n", for_dir );
      goto wrapup;
    }
  }

  /* test is directory */
  {
    IGRchar classname[TEXT_SIZE];
    IGRint		suc;
    IGRlong		bytes, received;
    struct GRmd_env	mod_env;

    status = om$get_classname( osnum = obj.osnum,
				objid = obj.objid,
				classname = classname );

    /*" classname : %s\n", classname */
    if( strcmp( classname, "ACrg_collect" ) == 0 ){

      /*| get module environment */
      bytes = sizeof( struct GRmd_env );
      status = gr$get_module_env(	msg 	= &suc,
					sizbuf	= &bytes,
					buffer	= &mod_env,
					nret	= &received );

      /*| macro is still ACrg_collect */
      status =
      om$send(msg = message ACrg_collect.NDdelete( &mod_env ),
	      targetid = obj.objid,
	      targetos = obj.osnum,
	      senderid = NULL_OBJID );
      as$status();

      /* create directory */
      obj.objid = NULL_OBJID;
      status = di$mkdir(dirname = macro,
  			p_dirid = &obj.objid,
			p_osnum = &obj.osnum );
      if( status != DIR_S_SUCCESS ){
	/* mkdir fails */
	printf(" Can't create directory : %s\n", for_dir );
	goto wrapup;
      }
    }
  } 

  /* goto the formats directory */
  status = di$cd( dirname = for_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't change working directory to : %s\n", for_dir );
    goto wrapup;
  }

  if( for_name != NULL ){
    strcpy( f_name, for_dir );
    strcat( f_name, ":" );
    strcat( f_name, for_name );
    /* " f_name: %s\n", f_name */
 
    obj.objid = NULL_OBJID;
    status = 
    di$translate(	objname = f_name,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
    /*^di$report_error( sts = status ); */
    if( status == DIR_S_SUCCESS ){
      if( option ){
        /*| modify expression */

	/* goto the formats directory */
	status = di$cd( dirname = f_name );
	if( status != DIR_S_SUCCESS ){
	  printf(" Can't change working directory to : %s\n", for_dir );
	  goto wrapup;
	}

        status =
	exp$modify(	exp_name = VD_FTEXT_STRING,
			osnum	 = cur_os,
			exp_syntax = string );
        if( !(status & 1) ){
            printf( "Can't modify expression\n" ); 
	    om$report_error( sts = status );
            goto wrapup;
        }
        status =
	exp$modify(	exp_name = VD_FTEXT_PARAMS,
			osnum	= cur_os,
			exp_syntax = params );
        if( !(status & 1) ){
            printf( "Can't modify expression\n" );    
	    om$report_error( sts = status );
            goto wrapup;
        }
      }
    }
    else{
      /* create expression directory */
      obj.objid = NULL_OBJID;
      status = di$mkdir(dirname = for_name,
			p_dirid = &obj.objid,
			p_osnum = &obj.osnum );
      if( status != DIR_S_SUCCESS ){
	/* mkdir fails */
	printf(" Can't create directory : %s\n", for_name );
        goto wrapup;
      }

      /*" f_name: %s\n", f_name */
      status = di$cd( dirname = f_name );
      if( status != DIR_S_SUCCESS ){
        printf(" Can't change working directory to : %s\n", f_name );
        goto wrapup;
      }

      /*| create expression */
      status = exp$create(	exp_name = VD_FTEXT_STRING,
				type_rq = EXP_TEXT,
				osnum = cur_os,
				exp_syntax = string,
				p_exp_id = &(obj.objid) );
      if( !(status & 1) ){
            printf( " Can't create expression\n");
	    om$report_error( sts = status );
            goto wrapup;
      }

      status = exp$create(	exp_name = VD_FTEXT_PARAMS,
				type_rq = EXP_TEXT,
				osnum = cur_os,
				exp_syntax = params,
				p_exp_id = &(obj.objid) );
      if( !(status & 1) ){
            printf( " Can't create expression\n");
	    om$report_error( sts = status );
            goto wrapup;
      }
    }
  }
  else{
    /* find new index value */
    index = 0;
    while( TRUE ){
      sprintf( f_name,"%s:%s_%d", for_dir, macro, index );
      /*" f_name: %s\n", f_name */
      obj.objid = NULL_OBJID;
      status = di$translate(	objname = f_name,
				p_objid = &obj.objid,
				p_osnum = &obj.osnum );
      if( status != DIR_S_SUCCESS ){
	/* found a new one */
        break;
      }
      else index++;
    }

    sprintf( f_name, "%s_%d", macro, index );
    obj.objid = NULL_OBJID;
    status = di$mkdir(	dirname = f_name,
			p_dirid = &obj.objid,
			p_osnum = &obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /* mkdir fails */
      printf(" Can't create directory : %s\n", f_name );
      goto wrapup;
    }

    sprintf( f_name, "%s:%s_%d", for_dir, macro, index );
    status = di$cd( dirname = f_name );
    if( status != DIR_S_SUCCESS ){
      printf(" Can't change working directory to : %s\n", f_name );
      goto wrapup;
    }

    /* create expression */
    status = exp$create(	exp_name = VD_FTEXT_STRING,
				type_rq = EXP_TEXT,
				osnum = cur_os,
				exp_syntax = string,
				p_exp_id = &(obj.objid) );
    if( !(status & 1) ){
            printf( " Can't create expression\n");
	    om$report_error( sts = status );
            goto wrapup;
    }

    status = exp$create(	exp_name = VD_FTEXT_PARAMS,
				type_rq = EXP_TEXT,
				osnum = cur_os,
				exp_syntax = params,
				p_exp_id = &(obj.objid) );
    if( !(status & 1) ){
            printf( " Can't create expression\n");
	    om$report_error( sts = status );
            goto wrapup;
    }
  }

wrapup:

  /* goto the current directory */
  if( pwd_dir[0] != '\0' ){
    status = di$cd( dirname = pwd_dir );
    if( status != DIR_S_SUCCESS ){
      printf(" Can't change working directory to : %s\n", pwd_dir );
    }
  }

  End
  return( status );
}

/************************************************************************/
/*	FUNCTION VDSdelete_formats					*/
/************************************************************************/

VDSdelete_formats( for_name, macro )
IGRchar		*for_name;
IGRchar		*macro;
/*.VDSwrite_formats*/
{
int	status = OM_S_SUCCESS;
IGRchar	f_name[TEXT_SIZE];
IGRchar	for_dir[TEXT_SIZE];
IGRchar	dir_name[TEXT_SIZE];
IGRchar	pwd_dir[TEXT_SIZE];
GRspacenum cur_os;
struct	GRid	f_obj,obj;

/*
 * This function delete a formattted text expression in the directory system.
 * It delete first the two expressions, followed by removing the 
 * sub-directory.
 */

  pwd_dir[0] ='\0';

  if( macro == NULL || for_name == NULL ){
    /*| no valid expression found */
    return( OM_S_SUCCESS );
  }

  /* get current directory */
  status = di$pwd( dirname = pwd_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't get current workingi directory.\n");
    goto wrapup;
  }

  /*" macro   : %s\n", macro  */
  /*" for_name: %s\n", for_name */

  ex$get_cur_mod( osnum = &cur_os );
  status = di$give_pathname( osnum = cur_os, pathname = dir_name );
  as$status( action = RET_STATUS );

  status = di$cd( dirname = dir_name );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't change working directory to : %s \n", dir_name );
    goto wrapup;
  }

  strcat( dir_name, VD_FTEXT_DIR );

  /* test if directory exists */
  status = di$translate(objname = dir_name,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /* no directory active */
    goto wrapup;
  }

  /* goto directory formats */
  status = di$cd( dirname = dir_name );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't change working directory to : %s\n", dir_name );
    goto wrapup;
  }
  
  sprintf( for_dir, "%s:%s", dir_name, macro );

  /* test if macro directory exist */
  status = di$translate(objname = for_dir,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /* macro group directory not found */
    goto wrapup;
  }

  /* goto the formats directory */
  status = di$cd( dirname = for_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't change working directory to : %s\n", for_dir );
    goto wrapup;
  }

  if( for_name != NULL ){

    strcpy( f_name, for_dir );
    strcat( f_name, ":" );
    strcat( f_name, for_name );
    /* " f_name: %s\n", f_name */
 
    obj.objid = NULL_OBJID;
    status = 
    di$translate(	objname = f_name,
			p_objid = &f_obj.objid,
			p_osnum = &f_obj.osnum );
    /*^di$report_error( sts = status ); */
    if( status == DIR_S_SUCCESS ){

      IGRint		suc;
      IGRlong		bytes, received;
      struct GRmd_env	md_env;

      /*| get module environment */
      bytes = sizeof( struct GRmd_env );
      status = gr$get_module_env(	msg 	= &suc,
					sizbuf	= &bytes,
					buffer	= &md_env,
					nret	= &received );

      /* goto the formats directory */
      status = di$cd( dirname = f_name );
      if( status != DIR_S_SUCCESS ){
	printf(" Can't change working directory to : %s\n", f_name );
	goto wrapup;
      }

      /* get the STRING and PARAMS objid's */
      obj.objid = NULL_OBJID;
      status =
      di$translate(	objname = VD_FTEXT_STRING,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
      if( status == DIR_S_SUCCESS ){
	if( obj.objid != NULL_OBJID ){
	  status = 
	  exp$delete(	exp_id  = obj.objid,
			osnum   = obj.osnum,
			p_md_env= &md_env );
          as$status( action = GOTO_VALUE, value = wrapup ) ;
	  nd$exec_batch();
	}
      }
      obj.objid = NULL_OBJID;
      status =
      di$translate(	objname = VD_FTEXT_PARAMS,
			p_objid = &obj.objid,
			p_osnum = &obj.osnum );
      if( status == DIR_S_SUCCESS ){
	if( obj.objid != NULL_OBJID ){
	  status = 
	  exp$delete(	exp_id  = obj.objid,
			osnum   = obj.osnum,
			p_md_env= &md_env );
          as$status( action = GOTO_VALUE, value = wrapup ) ;
	  nd$exec_batch();
	}

      }
      /* delete the format_expr directory */
      status = di$cd( dirname = for_dir );
      if( status != DIR_S_SUCCESS ){
	printf(" Can't change working directory to : %s\n", for_dir );
	goto wrapup;
      }
      status =
      di$rmdir(	dirname = f_name );
      if( status != DIR_S_SUCCESS ){
	printf("Warning, problem removing directory %s\n", f_name );
	goto wrapup;
      }
      nd$exec_batch();
    }
  }

wrapup:

  /* goto the current directory */
  if( pwd_dir[0] != '\0' ){
    status = di$cd( dirname = pwd_dir );
    if( status != DIR_S_SUCCESS ){
      printf(" Can't change working directory to : %s\n", pwd_dir );
    }
  }

  return( status );
}


/************************************************************************/
/*	FUNCTION VDSinit_ldexpr						*/
/************************************************************************/

VDSinit_ldexpr( expr )
struct	VDldline_expr	*expr;
/*.VDSinit_ldexpr*/
{
  expr->formatname[0] = '\0';
  expr->string[0] = '\0';
  expr->params[0] = '\0';
  expr->expr_id.objid = NULL_OBJID;

  return( TRUE );
} 


/************************************************************************/
/*	FUNCTION VDSsplit_par_str()					*/
/************************************************************************/

VDSann_find_nb_prints( expr )
IGRchar	*expr;
{
IGRint		i,len;
IGRint		num = 0;
  
  len = strlen( expr );
  if( ! len ){
    /*| no params */
    return( num );
  }

  /* count number of parameters */
  i=0;
  while( i<len ){
	if( expr[i++] == '%' ) num++;
  }
  
  return num ;
}


/************************************************************************/
/*	FUNCTION VDSsplit_par_str()					*/
/************************************************************************/

VDSsplit_par_str( expr, nb_pars, p_ptr )
IGRchar	*expr;
IGRint	*nb_pars;
IGRchar ***p_ptr;
/*.VDSsplit_par_str*/
{
IGRint	st_i,len;
IGRint  i,j,p_i,p_len;
IGRchar	**pars_ptr = NULL;
IGRchar	*str_ptr;

  *nb_pars = 0;
  
  len = strlen( expr );
  if( !len ){
    /*| no params */
    return( TRUE );
  }

  /* count number of parameters */
  i=0;
  *nb_pars = 1;
  while( i<len ){ if( expr[i++] == ',' ) (*nb_pars)++; }
  /*" nb_pars: %d, expr: %s\n", *nb_pars, expr */
  
  pars_ptr = _MALLOC ( (*nb_pars) * sizeof(IGRchar *), IGRchar * );
  if( pars_ptr == NULL )
    return( TRUE );

  *p_ptr = pars_ptr;
  /* set the parameters in list */
  st_i = 0; /* start index */
  for(i=0;i<*nb_pars;i++)
  {
    p_i = 0;

    /* get buffer length */
    for(j=st_i; j<len && expr[j]!=',';j++) p_i++;
    str_ptr = _CALLOC ( p_i+1, IGRchar );
   
    /* get macro name */
    p_len = st_i + p_i;
    p_i = 0;
    for(j=st_i;j<p_len;j++)	// HF: 10/15/96 TR#179603359
    {
      if( expr[j] == ' ' && ( j > 0 && expr[j-1] == ',' ) )
      {
	continue;
      }
      else
      {
	str_ptr[p_i++] = expr[j];
      }
    }
    str_ptr[p_i] = '\0';

    pars_ptr[i] = str_ptr;
    /*" pars_ptr[%d]: %s\n", i, pars_ptr[i] */

    str_ptr = NULL;
    st_i = p_len+1;
  }
  return( TRUE );
}


/************************************************************************/
/*	FUNCTION VDSwrite_header					*/
/************************************************************************/

VDSwrite_header( fp, macro )
FILE	*fp;
IGRchar	*macro;
/*.VDSwrite_header*/
{

  if(( fp == NULL ) || ( macro == NULL ))
    return FALSE;

  fprintf( fp, "\n%s %s ", VD_FTEXT_FORMAT, VD_FTEXT_FOR );
  fprintf( fp, "%s\n", macro );
  fprintf( fp, "%s\n", VD_FTEXT_OPEN );

  return TRUE;
}

/************************************************************************/
/*	FUNCTION VDSwrite_expr_file					*/
/************************************************************************/

VDSwrite_ldexpr( fp, expr, close )
FILE	*fp;
struct	VDldline_expr	*expr;
IGRboolean	close;
/*.VDSwrite_ldexpr*/
{
IGRchar *format_ptr;

  if(( fp == NULL ) || ( expr == NULL ))
    return TRUE;

  /*
   * print the formatted text expression name
   */
  if( expr->formatname[0] != '\0' ){
    format_ptr = strrchr( expr->formatname, ':' );
    format_ptr = format_ptr ? format_ptr+1 : expr->formatname ;
    fprintf( fp, "%s = ", format_ptr );
  }

  /* find the newlines in the string */
  {
  IGRchar	 *token;
  IGRchar	tmp[TEXT_SIZE];
  IGRchar	newline[3];
  IGRchar	newline_str[3];
  IGRchar	quote[2];

    strcpy( quote, "\"");

    newline[0] = 27;
    newline[1] = 10;
    newline[2] = '\0';

    strcpy( newline_str, "\\n" );
    strcpy( tmp, expr->string );
    token = strtok( tmp, newline );

    fprintf( fp, "%s", quote );
    fprintf( fp ,"%s", token );
    while( token != (char *)NULL){
      token = strtok( NULL, newline );
      if( token != (char *)NULL){
        fprintf( fp, "%s", newline_str );
	fprintf( fp ,"%s", token);
      }
    }
    fprintf( fp, "%s", quote );
  }

  /*
   * print the parameter list
   */
  if( expr->params[0] != '\0' )
    fprintf( fp, ", %s\n", expr->params );
  else
    fprintf( fp, "\n" );
 
  if( close )
    fprintf( fp, "%s\n\n", VD_FTEXT_CLOSE );

  return( TRUE );
} 




/********************************************************************************/
/*	FUNCTION VDcreate_text2							*/
/********************************************************************************/

VDcreate_text2(		to_format,	/*In: string to format*/
 			to_params,	/*IN: string of parameters */
			mod_env,	/*In: current module */
			macro,		/*In: macro identifier */
			text_output )	/*Out: Formatted Text */

IGRchar		*to_format;	
IGRchar		*to_params;
struct GRmd_env	*mod_env;      
struct GRid	*macro;   
IGRchar		*text_output; 
/*.VDcreate_text2*/
{
int		status = OM_S_SUCCESS;
IGRint		sts;
IGRlong		msg;
IGRchar		**pars = NULL;
struct	GRid	pars_id;
struct	ACrg_coll	coll;

IGRchar		control[1024];
IGRchar		*tc, *ctl, tmp_c[1024];
IGRchar		buf[TEXT_SIZE*2], perc[2];
IGRint		flag,len,nb_pars,i=0,ii=0;
IGRint		nb_prints = 0;
IGRshort	pposn, tposn;

IGRchar *p;

  SetProc( VDcreate_text2 ); Begin

  __DBGpr_str(" to_format", to_format );
  __DBGpr_str(" to_params", to_params );

  tmp_c[0] = '\0';
  control[0] = '\0';
  text_output[0] = '\0';
  flag = FALSE;
  pars = NULL;
  nb_pars = 0;

  if( macro->objid == NULL_OBJID ){
    /* no macro defined */
    flag = TRUE;
    goto wrapup;
  }

  __DBGpr_obj(" Macro ", *macro );

  strcpy( control, to_format );
  ctl = control;

  /* get the paramters values */
  if( len = strlen( to_params )){

    /* create test character */
    perc[0] = '%';
    perc[1] = '\0';
    *tmp_c = perc[0];
    tc  = tmp_c+1;
    
    ctl = control;
    VDSsplit_par_str( to_params, &nb_pars, &pars );
    nb_prints = VDSann_find_nb_prints( to_format  );

    if( nb_prints < nb_pars ) return FALSE ;

    /*
     * On start with the index -1 to write the formatted text in
     * the output buffer before adding the arguments
     */

    for(i=-1;i<nb_pars; i++){

      pposn = VRlocate_pattern( perc, ctl ); 
      if( pposn == 0 ){
	/* get next format character */
	ctl = ctl + 1;
	continue;
      }
      else if( pposn != -1 ){
	/* check double printf */
	tposn = 0;
	while ( *(ctl+pposn+1) == perc[0] ){
	  tposn = VRlocate_pattern( perc, (ctl+pposn+1) );
	  if( tposn == -1 )
	    break;
	  else
	    pposn= pposn+tposn;
        }
        if( tposn == -1 ) break;
      }

      /* copy the start text */
      if( i == -1 ){
	if( pposn > 0 ){
	  strncpy( text_output, ctl, pposn );
	  text_output[pposn] = '\0';
	  ctl = ctl + pposn + 1;
	}
	else{
	  strcpy( text_output, ctl );
	  break;   /* no format */
	}
	continue;
      }
     
      if( pposn > -1 ){
	strncpy( tc, ctl, pposn );
	tc[pposn] = '\0';
	ctl = ctl + pposn + 1; 
      } /* if on percent posn */
      else{
	strcpy( tc, ctl ); 
      }

      /* AD: Check here if we process with attribute or expression;
       */
      if ( strncmp(pars[i], "~~" , 2) ){

      /*" pars[%d]: %s\n", i, pars[i] */
      /*
       * See if string is an feet of the macro.
       */
      strncpy( coll.name , pars[i], 79 );
      pars_id.objid = NULL_OBJID;
      status =
      vd$review_params( pMsg            = &msg,
                        pComponent      = macro,
                        NbParams        = 1,
                        pList           = &coll,
                        pMdEnv          = mod_env );
      if( status&msg&1 ){
        if( coll.desc.type == AC_ATTRIB_DOUBLE ){
	  __DBGpr_dbl(" F1und Value ", coll.desc.value.att_exp );

	  // TR179900822 Try to prevent crash when format is wrong
	  p = strchr(tmp_c,'s');
	  if (p) *p = 'f';
          sprintf( buf, tmp_c, coll.desc.value.att_exp );
        }
        else if( coll.desc.type == AC_ATTRIB_TEXT ){
	  __DBGpr_str(" Found String", coll.desc.value.att_txt );

	  // TR179900822 Try to prevent crash when format is wrong
	  p = strchr(tmp_c,'f');
	  if (p) *p = 's';	
	  sprintf( buf, tmp_c, coll.desc.value.att_txt );
        }
        else{
	  strcpy( buf, ctl );
	  strcpy( buf, " ? " );
        }
      }
      else {

	struct GRid Temp;
	double	value;

	__DBGpr_com(" Check as template ");

        status =
        om$send(msg = message ACcpx.ACfind_temp_obj( &sts, pars[i], &Temp ),
		senderid = NULL_OBJID,
                targetid = macro->objid,
                targetos = macro->osnum);
        if( status & sts & 1 ){
          status =
          om$send(msg = message expression.NDgive_value( &value ),
		  senderid = NULL_OBJID,
                  targetid = Temp.objid,
                  targetos = Temp.osnum );
	}
        if( status & sts & 1 ){
          sprintf( buf, tmp_c, value );
        }
	else {
	  strcpy( buf, " ? " ); 
	}
      }
     }else {
	/* Added for expression objects -- sundar */
		GRspacenum	cur_os;
		IGRchar		tab_name[VD_CREXP_CHR_NAME];
		struct GRobj_env	objList;
 
                strcpy(tab_name,pars[i]+2);
 
                ex$get_cur_mod (osnum = &cur_os);
		objList.mod_env = *mod_env;
		objList.obj_id     = *macro;
		status =
                vd$tblexp_exec( msg     = &msg,
                                osnum   = cur_os,
                                tabnam  = tab_name,
				flag	= TRUE,
				mode	= VD_EXP_SILENT,
				num_objs= 1,
				objList	= &objList,
				attr	= &coll ); 
 
		if ( status & msg & 1 ){
        	  if( coll.desc.type == AC_ATTRIB_DOUBLE ){
		    __DBGpr_dbl(" F2und Value ", coll.desc.value.att_exp );

		    // TR179900822 Try to prevent crash when format is wrong
		    p = strchr(tmp_c,'s');
		    if (p) *p = 'f';
	            sprintf( buf, tmp_c, coll.desc.value.att_exp );
      		  }
   	          else if( coll.desc.type == AC_ATTRIB_TEXT ){
	  	    __DBGpr_str(" Found String", coll.desc.value.att_txt );

		    // TR179900822 Try to prevent crash when format is wrong
		    p = strchr(tmp_c,'f');
		    if (p) *p = 's';
		    sprintf( buf, tmp_c, coll.desc.value.att_txt );
        	  }
		  else{
		    strcpy( buf, ctl );
		    strcpy( buf, " ? " );
		  }
		} else{
			buf[0] = '\0';
		}
    /* Added for expression objects -- sundar */
    }

      __DBGpr_str(" text_output: ", text_output );
      __DBGpr_str(" buffer       ", buf );

      strcat( text_output, buf );

      for (ii=0; ii<pposn+2;ii++) tc[ii]=0; 
    }
  }
  else{
    strcat( text_output, ctl );
  }

wrapup:

  if( flag ){
    /*
     * error detected: copy origin format
     */
    strcpy( text_output, to_format );
  }

  _LOOPFREE ( pars, nb_pars );
  _FREE ( pars );

  End
  return( OM_S_SUCCESS ); 
}

end implementation Root;
