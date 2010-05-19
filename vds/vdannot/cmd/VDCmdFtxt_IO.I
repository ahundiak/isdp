/* $Id: VDCmdFtxt_IO.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdFtxt_IO.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt_IO.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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
# Revision 1.2  1996/03/28  20:18:24  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_IO.I for:  by yzhu for vds.240
#
# Revision 1.1  1994/11/21  20:11:38  pinnacle
# delete by mistake
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
 *
 *
 *	Filename:	VDCmdFtxt_IO.I
 *
 *	Author:		Ad Zuurhout
 *
 *	Date:		April - 1992
 *
 *	Description:	Methods used for the command object:
 *
 *			Read Formatted Text File
 *			Write Formatted Text File
 *
 *	History:
 *	April	1992	Creation date.
 *      May     1993    Modified to fix TR#179310602       rmn
 */


class implementation VDCmdFtxt;

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include "macro.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "AS_status.h"
#include "parametric.h"
#include "exdef.h"
#include "ex.h"
#include "grio.h"
#include "griomacros.h"
#include "FI.h"
#include "FEI.h"
#include "dp.h"
#include "dpmacros.h"
#include "expression.h"
#include "DItypedef.h"
#Include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "acdef.h"
#include "acmacros.h"
#include "AS_status.h"
#include "VDSannot.h"
#include "VDmsg.h"
#include "vdsmacros.h"
#include "v_dbgmacros.h"

from	IGRdir		import	dump;


/************************************************************************/
/*	METHOD	get_read_option						*/
/************************************************************************/

method get_read_option ( long * sts )
{
int	status = OM_S_SUCCESS;
  SetProc(VDCmdFtxt_IO.get_read_option); Begin 
/*
 * This methods accept any input and test if the excisting list
 * has to be overridden or be left.
 */

  *sts = MSSUCC;
  /*" event: <%s>\n", me->event1.event.keyin */

  if( me->event1.event.keyin[0] == 'n' || 
      me->event1.event.keyin[0] == 'N' )
         me->Override_option = FALSE;
  else   me->Override_option = TRUE;

  /*" Override_option: %d\n", me->Override_option */

  End
  return ( status );
}


/************************************************************************/
/*	METHOD	display_default						*/
/************************************************************************/

method display_default ( long * sts )
{
int	status = OM_S_SUCCESS;
FILE	*fp;
  SetProc(VDCmdFtxt_IO.display_default); Begin
/*
 * This method displays the default list of formats, which
 * are defined in the file:
 *
 *	$PWD/FormatText
 *	or
 *	$VDS/config/FormatText
 */

  *sts = MSSUCC;
  fp = NULL;
  strcpy( me->Config_file, VD_FTEXT_FILE );
 
  if( vd$openfile(	file_name    = me->Config_file,
			product_name = "Vds",
			sub_path     = "config",
			cur_dir      = TRUE,
			p_file       = &fp ) == 0 ){
    /*| no default file available */
    ex$message( msgnumb = VD_S_NoDefFile, type="%s", var = `me->Config_file` );
  }
  else{
    ex$message( msgnumb = VD_S_DefFile, type="%s", var = `me->Config_file` );
  }

  if( fp ) fclose( fp );

  *sts = MSSUCC;
  End
  return( status );
}


/************************************************************************/
/*	METHOD	read_file						*/
/************************************************************************/

method read_file ( long * sts )
{
int	status = OM_S_SUCCESS;
FILE	*f_ptr;
IGRchar	OPEN[2], CLOSE[2];
IGRchar	string[TEXT_SIZE], tmp1[TEXT_SIZE];
IGRchar	buffer[BUFFER_MAX], format[BUFFER_MAX];
IGRchar	for_params[DB_TEXT_SIZE], for_string[DB_TEXT_SIZE];
IGRchar	for_name[TEXT_SIZE], for_macro[TEXT_SIZE];
IGRint	i, len, next_format, nb_format;
struct	GRid	macro_id;
  SetProc(VDCmdFtxt_IO.read_file); Begin
/*
 * This action read the filename, given by the user.
 * The file has to be defined in current directory or in the
 * vds/config directory.
 * Return Code :
 *	File not found, 	error message is returned.
 *	File syntax error,	error message is returned.     	
 *	Format accepted,	confirmation of result.
 */

  *sts = MSSUCC;
  f_ptr = NULL;

  strcpy( OPEN,  VD_FTEXT_OPEN );
  strcpy( CLOSE, VD_FTEXT_CLOSE ); 

  /* test input event */

/* added test for me->event1.response - to fix TR */

  if( strlen( me->event1.event.keyin ) == 0 || 
		    me->event1.response == EX_RJT_MOVEON ){
    /*| null string inserted */
    if( vd$openfile(	file_name    = me->Config_file,
			product_name = "Vds",
			sub_path     = "config",
			cur_dir      = TRUE,
			p_file       = &f_ptr ) == 0 ){
      /*| there was no default file */
      *sts = VD_FTEXT_NO_FILE;
      return( OM_S_SUCCESS );
    }
  }
  else{
    if( me->event1.event.keyin[0] != '/' ){
      if( vd$openfile(	file_name    = me->event1.event.keyin,
			product_name = "Vds",
			sub_path     = "config",
			cur_dir      = TRUE,
			p_file       = &f_ptr ) == 0 ){
	/* there is no file found */
	*sts = VD_FTEXT_NO_FILE;
	return( OM_S_SUCCESS );
      }
    }
    else{
      /*| check total pathname */
      if( access( me->event1.event.keyin, 04 ) != 0 ){
	/*| file not found */
	*sts = VD_FTEXT_NO_FILE;
	return( OM_S_SUCCESS );
      }
      else{
        if((f_ptr = fopen( me->event1.event.keyin ,"r")) == NULL ){
	  /*| file is not readable */
	  *sts = VD_FTEXT_NOT_READABLE;
	  return( OM_S_SUCCESS );
	}
      }
    }
  }

  /*
   * Format of the drawing file:
   * ---------------------------
   *
   *	format for <macro_name> 
   *	{
   *	  "<text_string>", par,par, ...
   *	  <format_name> = "<text_string>", par, par, ...
   *	}
   */

  nb_format = 0;

  while( TRUE ){

    if( ! VDread_line( f_ptr, buffer ))
      goto end_of_file;

    /*" buffer : %s\n", buffer */

    /* look for macro definition */
    if( sscanf( buffer,"%s %s %s", string, tmp1, for_macro ) != 3 )
      continue;

    if( ( strcmp( string, VD_FTEXT_FORMAT ) != 0 ) &&
	( strcmp( tmp1  , VD_FTEXT_FOR    ) != 0 ) )
      continue;

    /*
     * test if macro type exist, or if a global definition.
     */
    if ( strncmp( for_macro, VD_FTEXT_GLOBAL, 6 ) < 0 ){
      macro_id.objid = NULL;
      status = 
      ac$find_macro_defn(	action          = ACfind_no_load,
				macro_name      = for_macro,
				p_macro_defn_id = &macro_id );
      as$status();
      if( macro_id.objid == NULL_OBJID ){
        printf(" error : macro <%s> does not exist\n", for_macro );
        continue;
      }
      /*" macro[ %d,%d]: %s\n",  macro_id.objid, macro_id.osnum, for_macro */
    }


get_open:

    i = 0;
    len = strlen( buffer );
    while( i < len )	if( buffer[i] == OPEN[0] ) break;
			else i++;

    if( i >= len ){
      if( ! VDread_line( f_ptr, buffer )){
        goto end_of_file;
      }
      goto get_open;
    }

    len = strlen( &buffer[i+1] );
    format[0] = '\0';
    if( len )
      strcpy( format, &buffer[i+1] );

    len = strlen( format );
    while( len ){
      if( format[len] == '\0' ||
          format[len] == '\n' ||
          format[len] == ' ' )
        format[len--] = '\0';
      else break;
    }

    /* text on empty text string */
    while( strcmp( format, "" ) == 0 ){

      /* get new line */
      if( ! VDread_line( f_ptr, format ))
        goto end_of_file;

      i = 0;
      len = strlen( format );
      while( i < len ){
        if( format[i] == CLOSE[0] ){
  	  /*| found CLOSE character */
	  next_format = FALSE;
	  format[i] = '\0';
          break;
        }
	i++;
      }
    }

get_format:

    next_format = TRUE;

    if( ! VDread_line( f_ptr, buffer ))
      goto end_of_file;
    
    i = 0;
    len = strlen( buffer );
    while( i < len ){
      if( buffer[i] == CLOSE[0] ){
  	/*| found CLOSE character */
	next_format = FALSE;
        buffer[i] = '\0';
	break;
      }
      i++;
    }

    len = strlen( format );
    if( format[len-1] == ',' || buffer[0] == ',' ){
      if( format[len-1] == ',' && buffer[0] == ',' ){
	/*| connect two lines */
	format[len-1] = '\0';
      }
      strcat( format, buffer );
      if( next_format )
        goto get_format;
    }

    /*" format: %s\n", format */

    /* split format buffer */
    if(  VDSsplit_buffer( format, for_name, for_string, for_params )){

      /*^
	printf(" FORMAT : %s\n", for_name );
	printf(" STRING : %s\n", for_string );
	printf(" PARAMS : %s\n", for_params );
       */

      VDSwrite_formats( for_name, for_string, for_params, for_macro, me->Override_option);
      nb_format++;
    }

    strcpy( format, buffer );

    if( next_format )
      goto get_format;
  }

end_of_file:

  fclose( f_ptr );

  if( nb_format )
    ex$message( msgnumb = VD_S_FormLoad, type="%d", var = `nb_format` );

  *sts = VD_FTEXT_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/************************************************************************/
/*	FUNCTION VDread_line						*/
/************************************************************************/

VDread_line( fp, buffer )
FILE	*fp;
IGRchar	*buffer;
{
IGRint	i,ii,len;

    SetProc(VDCmdFtxt_IO.VDread_line); Begin
  buffer[0] = '\0';

  if( fgets( buffer, BUFFER_MAX, fp ) == NULL ){
    /*| end_of_file */
    return FALSE;
  }

  /* remove space characters at end of buffer */
  len = strlen( buffer );
  while(--len){
    if( buffer[len] == '\n' || buffer[len] == ' ' ){
      buffer[len] = '\0';
      continue;
    }
    break;
  }

  /* remove space characters at begin of buffer */
  len = strlen( buffer );
  i = 0;
  while( i < len &&
       ( buffer[i] == ' ' || buffer[i] == '\t' || buffer[i] == '\n' ))
    i++;

  ii = 0;
  while( i < len )	buffer[ii++] = buffer[i++];
  buffer[ii] = '\0';
  
  /*" buffer: %s\n", buffer */
  End
  return( TRUE );
}

/************************************************************************/
/*	METHOD	formats_defined						*/
/************************************************************************/

method formats_defined ( long * sts )
{
int	status = OM_S_SUCCESS;
GRspacenum	cur_os;

    SetProc(VDCmdFtxt_IO.formats_defined); Begin
  *sts = VD_FTEXT_SUCCESS;

  /*| give pathname */
  ex$get_cur_mod ( osnum = &cur_os );
  status = di$give_pathname(osnum  = cur_os, pathname = me->dir_name );
  if( status != DIR_S_SUCCESS ){
    printf("error di$give_pathname\n");
    goto quit;
  }

  strcat( me->dir_name, VD_FTEXT_DIR );
  /*" dir_name : <%s> \n", me->dir_name */

  me->formats_dir.objid = NULL_OBJID;
  status =
  di$translate(	objname = me->dir_name,
		p_objid = &me->formats_dir.objid,
		p_osnum = &me->formats_dir.osnum );
  if( status != DIR_S_SUCCESS ){
    *sts = VD_FTEXT_NOT_WRITEABLE;
    return OM_S_SUCCESS;
  }

quit:
  End
  return OM_S_SUCCESS;
}


/************************************************************************/
/*	METHOD	write_file						*/
/************************************************************************/

method write_file ( long * sts )
{
int		msg,status = OM_S_SUCCESS;
FILE		*pf;
IGRchar		**macros;
IGRint		i,ii,size,len,nb_macros;
IGRchar		classname[DI_PATH_MAX],file_name[DI_PATH_MAX];
DIgrid		*macro_ids;
IGRint		nb_formats;

    SetProc(VDCmdFtxt_IO.write_file); Begin
  *sts = VD_FTEXT_SUCCESS;

  nb_macros = 0;
  macros    = NULL;
  macro_ids = NULL;

  pf = NULL;
  nb_formats = 0;

  /*
   * test the filename occurence
   */
  if( me->event1.event.keyin[0] == '\0')
    strcpy( file_name, VD_FTEXT_FILE );
  else
    strcpy( file_name, me->event1.event.keyin);

  len = strlen( me->dir_name );
  if( ! len ){
    *sts = VD_FTEXT_NOT_WRITEABLE;
    return OM_S_SUCCESS;
  }

  /* find all defined macros */
  status = 
  om$send(msg = message IGRdir.dump(	&msg,
					"*",
					NULL,
					&macros,
					&macro_ids,
					&nb_macros,
					0 ),
	  targetid = me->formats_dir.objid,
	  targetos = me->formats_dir.osnum,
	  senderid = NULL_OBJID );
  as$status(action = GOTO_VALUE, value=wrapup);
  /*
   * open write file
   */
  if( (pf = (FILE *) fopen( file_name, "w" )) == NULL ){
    printf(" cannot open file: %s\n",file_name);
    *sts = VD_FTEXT_SEVERE_ERROR;
    goto wrapup;
  }

  /*
   * get all expression of each macro type
   */
  for( i=0; i<nb_macros; i++){

    /* test object class */
    om$get_classname(	osnum   = macro_ids[i].osnum,
			objid   = macro_ids[i].objid,
			classname = classname );

    if( strcmp( classname, "ACrg_collect" ) == 0 ){
      /*| class equal to ACrg_collect */
      continue;
    }

    strcpy( me->macro_name, macros[i] );

    status =
    om$send(msg = message VDCmdFtxt.get_exist_formats( sts ),
	    targetid = my_id );
    as$status(action = GOTO_VALUE, value=wrapup);

    size = om$dimension_of( varray = me->ldexpr_list );
    if( size ){
      if( ! VDSwrite_header( pf, macros[i] )){
	/*| error in write header */
	continue;
      }

      /*
       * write each line in file
       */
      for( ii=0; ii< size; ii++){

	nb_formats++;
	if( ii != size-1 )
	  VDSwrite_ldexpr( pf, &(me->ldexpr_list[ii]), FALSE );    
	else
	  VDSwrite_ldexpr( pf, &(me->ldexpr_list[ii]), TRUE );
      }
    }
  }

  if( nb_formats ){
    ex$message( msgnumb = VD_S_FormWrtn, type="%d", var = `nb_formats` );
  }    

wrapup:
  /*
   * close the filename
   */
  if( pf ){ fflush( pf ); fclose( pf ); pf = NULL; }
  di$free( lines = macros, count = nb_macros );
  if( nb_macros ) DIfree( macro_ids );

  End
  return OM_S_SUCCESS;
}

end implementation VDCmdFtxt;
