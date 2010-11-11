/* $Id: VDCmdDtFile.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtFile.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtFile.I,v $
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
	File	VDSdet_orie.I
	Auteur	Ad Zuurhout (I.S.D.C.)
	Date	15-Mai-1991

	Description:

	History:
*/
class implementation VDCmdDetail;

/* 
 * include files
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%safe
#include <math.h>
%endsafe

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdsmacros.h"
#include "FI.h"
#include "CIforms.h"
#include "ODE.h"

#include "AS_status.h"
#include "VDdetail.h"

/* include/prototypes */

#define	AS_DEBUG	1


VD_ViewOrientationFile( flag, fm_ptr, cnt, view, h_vec, v_vec )
int	flag;	 /* FALSE -> display only the view orienation names 	*/
		 /* TRUE  -> find the hor/ver vectors 			*/
char	*fm_ptr; /* active form pointer					*/
int	*cnt;	 /* return the number defined view orientations		*/
char	*view;	 /* view orienation name to be found when flag = TRUE 	*/
IGRdouble	*h_vec;  /* return the found horizontal vector values		*/
IGRdouble	*v_vec;  /* return the found vertical vector values		*/

{
FILE	*file_ptr;
IGRint	i, row;
IGRchar	buff[1000];
IGRchar	name[80];
IGRchar	vec[6][30];

  file_ptr = NULL;
  if( flag == VD_DET_NAME_COUNT ) *cnt = 0;
  if( flag == VD_DET_NAME_SEARCH ){
    if( view == NULL    ) return( FALSE );
    if( view[0] == '\0' ) return( FALSE );
  }

  /* 
   *look if the predefined file ViewOrienation is found
   */
  if( vd$openfile(	file_name    = VD_DET_VIEWORIENT,
			product_name = "Vds",
			sub_path     = "config",
			cur_dir      = TRUE,
			p_file       = &file_ptr ) == 0 ){
    return( FALSE );
  }
  
  /*| get line in buffer */
  row = VD_DET_AXIS_LIST_MIN;
  while( fgets( buff, sizeof(buff), file_ptr ) != NULL ){

    if( buff[0] == '#' )
      continue;

    if( sscanf( buff,"%s %s %s %s %s %s %s", name,
			vec[0], vec[1], vec[2], vec[3], vec[4], vec[5] ) == 7 ){

      /*" Name = <%s> \n", name */

      if( flag == VD_DET_NAME_SEARCH ){

        /* test if name is equal to view name */

	if( strcmp( view, name ) == 0 ){
	  for(i=0;i<3;i++){
	    h_vec[i] = atof( vec[i]   );
	    v_vec[i] = atof( vec[3+i] );
	  }
	  fclose( file_ptr );
	  return( TRUE );
	}

	continue;

      }
      else{
	if( flag == VD_DET_NAME_DISPLAY ){
	/* set values in associative list */

	FIfld_set_list_default_text( fm_ptr, VD_DET_AXIS_TOGGLE,
				 	row++, 0, name, FALSE );
	}
	else{
	  if( flag == VD_DET_NAME_COUNT ){
	    /* count number of defined view orientations */
	    (*cnt)++;
	  }
	  else{
	    /* error in flag definition */
	    fclose( file_ptr );
	    return( FALSE );
	  }
	}
      }
    }
  }

  fclose( file_ptr );

  return( TRUE );

}

VD_ViewVolumeFile( flag, fm_ptr, cnt, view, min_v, max_v, orig )

int	flag;	 /* FALSE -> display only the view volume names 	*/
		 /* TRUE  -> find the view volume and origin 	 	*/
char	*fm_ptr; /* active form pointer					*/
int	*cnt;	 /* number of found view volume definitions		*/
char	*view;	 /* view volume name to be found when flag = TRUE 	*/
IGRdouble	*min_v;  /* return the found minimum volume values		*/
IGRdouble	*max_v;  /* return the found maximum volume values		*/
IGRdouble	*orig;	 /* return the found origin values			*/
{
FILE	*file_ptr;
IGRint	i, row;
IGRchar	buff[1000];
IGRchar	name[80];
IGRchar	vec[9][30];

  file_ptr = NULL;
  if( flag == VD_DET_NAME_COUNT ) *cnt = 0;
  if( flag == VD_DET_NAME_SEARCH ) {
    if( view == NULL    ) return( FALSE );
    if( view[0] == '\0' ) return( FALSE );
  }

  /* 
   *look if the predefined file ViewOrienation is found
   */
  if( vd$openfile(	file_name    = VD_DET_VIEWVOLUME,
			product_name = "Vds",
			sub_path     = "config",
			cur_dir      = TRUE,
			p_file       = &file_ptr ) == 0 ){
    return( FALSE );
  }
  
  /*| get line in buffer */
  row = VD_DET_VOLUME_LIST_MIN;
  while( fgets( buff, sizeof(buff), file_ptr ) != NULL ){

    if( buff[0] == '#' )
      continue;

    if( sscanf( buff,"%s %s %s %s %s %s %s %s %s %s", name,
					vec[0], vec[1], vec[2],
					vec[3], vec[4], vec[5],
					vec[6], vec[7], vec[8]  ) == 10 ){

      /*" Name = <%s> \n", name */

      if( flag == VD_DET_NAME_SEARCH ){

        /* test if name is equal to view name */

	if( strcmp( view, name ) == 0 ){
	  for(i=0;i<3;i++){
	    min_v[i] = atof( vec[i]   );
	    max_v[i] = atof( vec[3+i] );
	    orig[i]  = atof( vec[6+i] );
	  }
	  fclose( file_ptr );
	  return( TRUE );
	}

	continue;

      }
      else{
	if( flag == VD_DET_NAME_DISPLAY ){
	  /* set values in associative list */

	  FIfld_set_list_default_text( fm_ptr, VD_DET_VOLUME_TOGGLE,
				 	row++, 0, name, FALSE );
	}
	else{
	  if( flag == VD_DET_NAME_COUNT ){
	    /* count number predefined view volumes */
	    (*cnt)++;
	  }
	  else{
	    /* error in flag options */
	    fclose( file_ptr );
	    return( FALSE );
	  }
	} 
      }
    }
  }

  fclose( file_ptr );

  return( TRUE );

}


end implementation VDCmdDetail;
