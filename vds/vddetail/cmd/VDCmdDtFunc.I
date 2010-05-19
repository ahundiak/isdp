/* $Id: VDCmdDtFunc.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtFunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtFunc.I,v $
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
# Revision 1.5  1996/04/12  09:48:54  pinnacle
# Replaced: vddetail/cmd/VDCmdDtFunc.I for:  by rgade for vds.240
#
# Revision 1.4  1996/03/28  10:34:42  pinnacle
# Replaced: vddetail/cmd/VDCmdDetail.sl for:  by msbraju for vds.240
#
# Revision 1.3  1995/11/10  10:44:50  pinnacle
# Replaced: vddetail/cmd/VDCmdDtFunc.I for:  by msbraju for vds.240
#
# Revision 1.2  1995/10/25  17:26:46  pinnacle
# Replaced: vddetail/cmd/VDCmdDtFunc.I for:  by tlbriggs for vds.240
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
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *
 * -------------------------------------------------------------------*/

/*
	File	VDSdraw_func.I
	Auteur	Ad Zuurhout
	Date	18-December-1991

	Description:
		This file contains functions to calculate object values
		relative to drawing view object.

		The following functions are defined:
			- VDdet_find_obj_matrix
			- VDdet_find_obj_range
			- VDdet_gen_window_name
			- VDdet_conv_int_ext
			- VDdet_conv_ext_int
			- VDdet_get_scale_fact

	History:
		Creation Date 01-01-92
*/

class implementation VDCmdDetail;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bstypes.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "parametric.h"
#include "msdef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "gocmacros.h"
#include "EMScmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "grmessage.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "UOMdef.h"
#include "UOMmacros.h"

#include "griodef.h"
#include "griomacros.h"
#include "VDdetail.h"

/* include/prototypes */
#include "bsbx2.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "maidmx.h"
#include "matypemx.h"
/**
  #include "VDpr_detail.h"
 **/

from	EMSsubbs	import GRdetplane;
from	EMSsubbs	import GRgenabsg;
from	GRvg		import GRgetrang;

#define	AS_DEBUG	1

/**************************************************************/
IGRboolean VDdet_find_obj_matrix( msg, obj_id, mat_out )
/**************************************************************/

/*
/* This function calculates the x, y, and z vector of an plane 
/* 	and put the vector values in the matrix.
/* Return Values:
/*	True	: successfull completed.
/*	False	: error.
/* */

IGRlong			*msg;
struct	GRid		*obj_id;
IGRdouble		*mat_out;
/*.find_obj_matrix*/
{
IGRlong			status;
struct	IGRplane	plane;
IGRpoint		point;
IGRvector		z_vec;
IGRvector		x_vec, y_vec, ty_vec;
IGRmatrix		matrix;
struct	IGRbsp_surface	*surface;
IGRchar			*gen_ptr;
IGRshort		i, cond, mxtype;
BSrc			rc;
GRclassid		sender_class;

  surface = NULL;
  gen_ptr = NULL;

  plane.point  = point;
  plane.normal = z_vec;

  MAidmx( msg, mat_out );
  MAidmx( msg, matrix );
  if( ! (MAtypemx ( msg, matrix, &mxtype ))){
    printf(" VDdet_get_obj_matrix : fct MAtypemx failed \n");
    goto wrapup;
  }

  /* get the normal of the plane EMSsubbs */
  status =
  om$get_classid(       osnum     = obj_id->osnum,
                        objid     = obj_id->objid,
                        p_classid = &sender_class );

  if( om$is_ancestry_valid(subclassid   = sender_class,
                        superclassname  = "EMSsolid" ) == OM_S_SUCCESS ){
        /* select a reference plane object */
	*msg = MSSUCC ;
        return TRUE ;
  }
 
  status =
  om$send(msg = message EMSsubbs.GRdetplane(	msg,
						&mxtype,
						matrix,
						&plane ),
	  targetid = obj_id->objid,		
          targetos = obj_id->osnum,
	  senderid = NULL_OBJID );
  as$status();
  as$status(sts = *msg);
	
  if( !(status & *msg & 1)) {
    printf(" VDdet_give_values:  EMSsubbs.GRdetplane failed \n");
    goto wrapup;
  }

  /*" plane.pnt: %f %f %f \n", point[0], point[1], point[2]	*/
  /*" plane.nor: %f %f %f \n", z_vec[0], z_vec[1], z_vec[2]	*/

  /*| get the genabsg : of the object EMSsubbs */
  status =
  om$send(msg = message EMSsubbs.GRgenabsg(	msg,
						&mxtype,
						matrix,
						&gen_ptr),
	  targetid = obj_id->objid,
	  targetos = obj_id->osnum,
	  senderid = NULL_OBJID );
  as$status();
  as$status(sts = *msg);
  if( !(status & *msg & 1)){
    printf(" VDdet_give_values: EMSsubbs.GRgenabsg failed \n");
    goto wrapup;
  }

  surface = (struct IGRbsp_surface *) gen_ptr;
  /*| define x_vector / y_vector */
  cond = 3 * surface->u_num_poles;
  for(i=0; i<3; i++){
    x_vec[i]  = surface->poles[3+i]    - surface->poles[i];
    ty_vec[i] = surface->poles[cond+i] - surface->poles[i];
  }

  BScrossp( &rc, z_vec, x_vec, y_vec );

  /*
   * Commented out following portion. In some cases following code
   * leads to a matrix which does not form right handed screw system.
   * This is fix for TR#179526919
   * Raju - 11/10/1995
   */
/*
  / * test if the y-vector is in the right direction * /
  if( BSdotp( &rc, y_vec, ty_vec ) < 0 ){
    / * | inverse y-vector * /
    for(i=0;i<3;i++) y_vec[i] = ty_vec[i];
    / * for(i=0;i<3;i++) y_vec[i] *= -1; * /
  }
*/


  BSnorvec( &rc, x_vec );
  BSnorvec( &rc, y_vec );
  BSnorvec( &rc, z_vec );

  for( i=0; i<3; i++){
    mat_out[i]   = x_vec[i];
    mat_out[4+i] = y_vec[i];
    mat_out[8+i] = z_vec[i];
    mat_out[4*i+3] = 0.0;
    mat_out[12+i]  = 0.0;
  }
  mat_out[15] = 1.0;

  if( gen_ptr ) GRabsg_del( gen_ptr );
  *msg = MSSUCC;
  return( TRUE );

wrapup:
  if( gen_ptr ) GRabsg_del( gen_ptr );
  *msg = MSFAIL;
  return( FALSE );
}

/**************************************************************/
IGRboolean VDdet_find_obj_range( msg, my_obj, matrix, range )
/**************************************************************/

/*
 * This function determine the volume of the object in the new
 * reference environment and object space.
 */

IGRlong			*msg;
struct	GRobj_env	*my_obj;
IGRdouble		*matrix;
IGRdouble		*range;
/*.find_obj_range*/
{
IGRlong			status;
IGRshort		mxtype;         /* for optimized point transform */
IGRchar			*gen_ptr;
struct	IGRbsp_surface	*surface;
IGRlong			tot_poles;
IGRmatrix		tmp_matrix;
IGRdouble		*m_ptr;
GRclassid		sender_class;

  *msg = MSSUCC;

  surface = NULL;
  gen_ptr = NULL;

  if( matrix == NULL ){
    /* get default matrix */
    MAidmx( msg, tmp_matrix );
    m_ptr = tmp_matrix;
  }
  else m_ptr = matrix;

  /* get the normal of the plane EMSsubbs */
  status =
  om$get_classid(       osnum     = my_obj->obj_id.osnum,
                        objid     = my_obj->obj_id.objid,
                        p_classid = &sender_class );

  if( om$is_ancestry_valid(subclassid   = sender_class,
                        superclassname  = "EMSsolid" ) == OM_S_SUCCESS ){
        /* select a reference plane object */

	IGRboolean	world = 1 ;

	status =
	om$send(msg = message GRvg.GRgetrang(	msg,
						&mxtype,
						m_ptr,
						&world,
						range ),
		targetid = my_obj->obj_id.objid,
		targetos = my_obj->obj_id.osnum,
		senderid = NULL_OBJID );

        return ( status & *msg & 1 ) ? TRUE : FALSE ;
  }
  

  if( MAtypemx ( msg, m_ptr, &mxtype )){

    /* convert points to the local rectangular system */
    status =
    om$send(msg = message EMSsubbs.GRgenabsg(	msg,
						&mxtype,
						m_ptr,
						&gen_ptr ),
	    targetid = my_obj->obj_id.objid,
	    targetos = my_obj->obj_id.osnum,
	    senderid = NULL_OBJID );
    as$status( );
    as$status( sts = *msg );
    if( !(status & *msg & 1)){
      printf(" VRdet_find_obj_volume : EMSsubbs.GRgenabsg failed \n");
      goto wrapup;
    }

    surface = (struct IGRbsp_surface *) gen_ptr;
    surface->num_boundaries = 0;
    tot_poles =  surface->u_num_poles * surface->v_num_poles;

    /*" num_poles : %d\n", tot_poles */
    status =
    BSbx2(	msg,
		&tot_poles,
		(IGRpoint *) surface->poles,
		NULL,
		&range[0],
		&range[3]);
    if (!status){
      printf(" VDdet_find_obj_volume : BSbx2 failed \n");
      goto wrapup;
    }
  }
  else{
    goto wrapup;
  }

  /*^ 
    printf(" range[0]: %f %f %f \n", range[0], range[1], range[2] );
    printf(" range[1]: %f %f %f \n", range[3], range[4], range[5] );
   */

  if( gen_ptr) GRabsg_del( gen_ptr );
  *msg = MSSUCC;
  return( TRUE );

wrapup:
  if( gen_ptr) GRabsg_del( gen_ptr );
  *msg = MSFAIL;
  return( FALSE );
}


/**************************************************************/
IGRboolean VDdet_gen_window_name( msg, osnum, name )
/**************************************************************/

/*
/* This function looks in the system window directory, test the 
/*	window names to return an unique name
/* 	and put the vector values in the matrix.
/* Return Values:
/*	True	: successfull completed.
/*	False	: error.
/*	name	: window name
/* */

IGRlong		*msg;
GRspacenum	osnum;
IGRchar		*name;
/*.gen_window_name*/
{
IGRlong			status;
IGRchar			path[80], path_buf[80], **lines;
IGRchar			tst_path[80], win_name[80];
struct	digrid		*grids;

IGRboolean		found;
DIint			count;
IGRlong			i, index;

  *msg = MSSUCC;

  /* get file information */
  di$give_pathname(	osnum	= osnum,
			pathname= path ) ;

  DIstmcpy( path_buf, path,"views","regviews","GRviews", NULL ) ;
  status = di$find(	start_dir	= path_buf,
			lines		= &lines,
			grids		= &grids,
			ptr		= &count ) ;
  as$status( sts = status, msg = "Error in msg di$find" );

  if( name[0] != '\0' ){
    /* test existing name */
    found = FALSE;
    sprintf( tst_path,"%s:%s", path_buf, name );
    for( i=0; i<count; i++ ){
      if( strcmp( tst_path, lines[i] ) == 0 ) found = TRUE;
    }

    if( ! found ){
      /* name is unique and accepted */
      goto wrapup;
    }
  } 

  if( name[0] == '\0' ) strcpy( name, VD_DET_WINDOW_NAME );
  
  index = 0;
  while( TRUE ){
    sprintf( win_name,"%s-%d", name, index );
    sprintf( tst_path,"%s:%s", path_buf, win_name );

    found = FALSE;
    for( i=0; i<count; i++ ){
      if( strcmp( tst_path, lines[i] ) == 0 ) found = TRUE;
    }

    if( ! found ){
      strcpy( name, win_name );
      break;
    }
    index++;
  }
   
wrapup:

  di$free( count = count, lines = lines ) ;
  if( grids ) free( grids );

  *msg = MSSUCC;
  return( TRUE );
}

#if 0

int convert_lev_array( msg, levels, buffer )
IGRint	*msg; 
IGRint	*levels;
IGRchar	*buffer;
{
short	start, level;
char	tmp[VD_DET_TEXT_MAX];

  *msg = MSSUCC;
  buffer[0] = '\0';

  if( levels == NULL ){
    strcpy( buffer, VD_DET_DEF_LAYER );
    *msg = MSFAIL;
    return( FALSE );
  } 

  level = 0;
  while( level < DP_NUM_OF_LEVELS ){

    if(!( 0x00000001 & (levels[level/32] >> (level % 32)))){
      level++;
      break;
    }

    start = level++;
    while( 0x00000001 & (levels[level/32] >> (level % 32)) &&
	   level < DP_NUM_OF_LEVELS ){
      level++;
    }
    if( level - start == 1 )
      sprintf( tmp, "%d,%d", start, level );
    else
      sprintf( tmp, "%d-%d", start, level );

    if( strcmp( buffer, "" ))
      strcpy( buffer, tmp );
    else{
      if( strlen( buffer) + strlen( tmp ) < VD_DET_TEXT_MAX ){
        strcat( buffer, "," );
	strcat( buffer, tmp );
      }
    }
    level++;
  }

  *msg = MSSUCC;
  return(OM_S_SUCCESS );
}

#endif

int VDconvert_lev_string( msg, buffer, levels )
IGRint	*msg; 
IGRchar	*buffer;
IGRint	*levels;
{
int	status;
int	exit, is_dash, had_dash;
int	cur, i,j,k, num_char;
char	tmpbuf[256];
int	tmplev1, tmplev2;

  *msg     = MSSUCC;
  status   = TRUE;
  tmplev1  = tmplev2 = 0;

  for( i=0; i<32; i++) levels[i] = 0x0;

  num_char = strlen ( buffer );
  exit     = FALSE;	/*exit on ; or # chars */
  is_dash  = FALSE;	/*assume no dash */
  had_dash = FALSE;	/*assume no dash */
  i        = 0;		/*counter thru tmpbuf*/
        
  for(cur=0 ; cur<=num_char; cur++){

    /*** look for ending delimeter ***/

    if( exit ) goto wrapup; /*if had ; before num chars*/
    if( (buffer[cur] == '-') || (buffer[cur] == ',') ||
	(buffer[cur] == ';') || (cur == num_char)){

      /* start if delimeter found end delimeter */
      if( buffer[cur] == ';' ) exit = TRUE;
      is_dash = FALSE; /* assume not a dash */
      if( buffer[cur] == '-' ){
	/* is dash must remember for next number */
	is_dash = TRUE;
      }
      if( i == 0 ) goto error;
      else{
	/* have something in tmpbuf-convert it */
	tmpbuf[i] = 0;
        for( k=0; k<i; k++ ){
          status = !(isalpha(tmpbuf[k]));
          if (!status ) break;
	}

        if(status){
	  /* convert this string to a number */
	  status = sscanf ( tmpbuf,"%d",&tmplev2);
	}
	if( !status ){
	  /* start not converted see if it is in table */
          if( is_dash || had_dash ){
	    /* if you had dash and would not translate error */
            goto error;
          }
	}
	else{
	  /* start of did translate from scanf */
	  if( is_dash ){
	    tmplev1 = tmplev2; /* save this number */
	    had_dash = TRUE;
	    goto next;
	  }
	  else{
	    /* not a dash but did you have one earlier */
	    if( !had_dash ) tmplev1 = tmplev2;		      		
	    if( tmplev1 > tmplev2  || tmplev1 < 0 || tmplev2 >1023 )
	      goto error;

            had_dash = FALSE;
	    is_dash = FALSE;

	    for( j=tmplev1; j<=tmplev2; j++ ){
	      levels[j/32] |= (1 << (j % 32));
	    }
	  }
	}
next:
	i = 0;
      }
    }
    else{
      /* not a delimeter */
      tmpbuf[i] = buffer[cur];
      i++;
      if( i > 255 ) goto error;
    }
  }
wrapup:
 return ( OM_S_SUCCESS );
   
error:
 /*| error detected in syntax */
 for( i=0; i<32; i++) levels[i] = 0xffffffff;
 *msg = DPINVINP;
 return ( OM_S_SUCCESS );
}

int VDdet_conv_ext_int( Input, Output, Osnum )
IGRdouble	Input;
IGRdouble	*Output;
OMuword		Osnum;
{
IGRlong	status, msg;

  status = uom$cvt_imp_to_wrk( msg	= &msg,
				unit_type = GRIO_DISTANCE,
				osnum	= Osnum,
				primary	= Input,
				result	= Output );

  return( status & msg & 1 );
}


int VDdet_conv_int_ext( Input, Output, Osnum )
IGRdouble	Input;
IGRdouble	*Output;
OMuword		Osnum;
{
IGRlong	status, msg;
IGRshort	num_alias;
IGRchar		convert_array[150];


  num_alias = 1;
  status = uom$cvt_imp_to_alias( msg	= &msg,
				unit_type = GRIO_DISTANCE,
				working_units = &Input,
				osnum	= Osnum,
				num_alias = &num_alias,
				cvt_list = convert_array );

  if(!(status & msg & 1 )) return 0;

  if( sscanf( convert_array, "%lf", Output) != 1 ) return 0;

  return 1;

}

int VDdet_get_scale_fact( scale_str, scale )
IGRchar		*scale_str;
IGRdouble	*scale;
{
IGRchar	text[100], tmp1[256], tmp2[256];
IGRint	len, i, j;

  *scale = 1.0;

  strcpy( text, scale_str );
  len = strlen( text );
  if( len == 0 ) *scale = 1.0;
  else{
    i=0;
    while( text[i] != ':' && i<len ){ tmp1[i] = text[i]; i++; }
    if( i == len ) *scale = 0.0;
    else{
      tmp1[i]= '\0';
      i++; j=0;
      while( i<len ){ tmp2[j++] = text[i++]; }
      tmp2[j]= '\0';
      *scale = atof( tmp1 ) / atof( tmp2 );
    }
  }
  return( 1 );
}


int VDdet_get_def_units( osnum, info, units )
GRspacenum	osnum;
IGRchar		*info;
IGRchar		*units;
{
GRIOalias_name        default_units[UOM_K_MAX_DEFS];
IGRshort              i, num_defaults;
IGRint	              status;
IGRlong               msg;
IGRchar               buffer[256];

  i = 0;        /* retrieve the input defaults */

  if( units == NULL )
    return( TRUE );

  units[0] = '\0';

  status = co$get_default_units(msg           = &msg,
                                table_name    = GRIO_DISTANCE,
                                osnum         = osnum,
                                flag          = &i,
                                num_defaults  = &num_defaults,
                                default_units = default_units );

  if(status&msg&1){
    if( info != NULL ) strcpy( buffer, info );
    else buffer[0] = '\0';

    strcat( buffer, &default_units[0][0] );
    for( i=1;i<num_defaults; ++i ){
      strcat( buffer, "," );
      strcat( buffer, &default_units[i][0] );
    }
    strcpy( units, buffer );
  }

  return( TRUE );
}

end implementation VDCmdDetail;

