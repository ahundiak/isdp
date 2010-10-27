/*$Id: VDtextrot.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/imp/VDtextrot.I
 * Description:
 *
 * Dependencies:
 *
 o Revision History:
 *      $Log: VDtextrot.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/18  23:11:20  pinnacle
# Created: vdannot/imp/VDtextrot.I by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/18/98         Ming           Overwrite function
 *					DMget_text_rotation_matrix()
 *					in grnuc/src/dim/dim_root/groverride.I
 * -------------------------------------------------------------------*/

class implementation DMroot;

#include "OMmacros.h"
#include "igetypedef.h"
#include "grdpb.h"
#include "bserr.h"
#include "dimdef.h"
#include "dimmacros.h"
#include "dm_status.h"

extern double fabs();
extern GRclassid OPP_VDfrmtxt_class_id;


IGRint DMget_text_rotation_matrix( dp_rotation,
				   lbsys_matrix,
				   text_matrix,
				   txt_offset,
        			   txt_length,
				   dim_id,
				   dim_os,
				   mx_type,
				   matrix,
				   new_type,
				   new_env )
IGRdouble	*dp_rotation;
IGRdouble	*lbsys_matrix;
IGRdouble	*text_matrix;
IGRdouble	txt_offset;
IGRdouble	txt_length;
OM_S_OBJID	dim_id;
OMuword		dim_os;
IGRshort	*mx_type;
IGRdouble	*matrix;
IGRshort	*new_type;
IGRdouble	*new_env;

/*
** DMget_text_rotation_matrix
*/
{
  IGRmatrix          inv_matrix;
  IGRdouble          *vw_xvec, *vw_yvec, *vw_zvec;
  IGRint             status, rc, i, opindex;
  BSrc 		     bs_rc;
  IGRshort           four;
  IGRlong            long_rc;
  IGRdouble          txt_xvec[3], txt_yvec[3], txt_zvec[3];
  IGRdouble          dotx, dotyx, dotxy;
  IGRdouble          cross_vwz_txtx[3], text_pt[3];
  struct DMloc_param par_loc;
  OMuword	     dim_classid;


  vw_xvec = &dp_rotation[0];
  vw_yvec = &dp_rotation[4];
  vw_zvec = &dp_rotation[8];

  /* 
  ** Purify fix - for annotations text position is not set
  */
  par_loc.txt_posn = -1;

  status=
  dm$get_dim_param( type      = DM_LOC_PARAM,
		    dim_objid = dim_id,
		    dim_osnum = dim_os,
		    p_data    = (char *)&par_loc );
  dm$status(action = RET_STATUS);

  /*^
		print_matrix("vw_matrix",dp_rotation);
		print_matrix("env_matrix",matrix);
		print_matrix("lbsys",lbsys_matrix);
		print_matrix("text_matrix",text_matrix);
  */

  for( i = 0 ; i < 3 ; i++ )
  {
    txt_xvec[i] = text_matrix[i*4];
    txt_yvec[i] = text_matrix[i*4+1];
    txt_zvec[i] = text_matrix[i*4+2];
    text_pt[i]  = text_matrix[i*4+3];
  }

  dotx = BSdotp( &bs_rc, txt_xvec, vw_xvec );

  /*"dotx=%f\n",dotx */

  if( (dotx > 1e-10) || (dotx < -1e-10) )
  {
    BScrossp( &bs_rc, vw_zvec, txt_xvec, cross_vwz_txtx );

    if( BSdotp(&bs_rc, txt_yvec, cross_vwz_txtx) > 0.0 )
    {
      if( dotx > 0.0 )
	opindex = 8;			/* Do not rot. txt mat. */
      else
	opindex = 3;			/* Rotate about Z axis */
    }
    else
    {
      if( dotx > 0.0 )
	opindex = 6;			/* Rotate about X axis */
      else
        opindex = 5;			/* Rotate about Y axis */
    }
  } 
  else
  {
    dotxy = BSdotp( &bs_rc, txt_xvec, vw_yvec );
    dotyx = BSdotp( &bs_rc, txt_yvec, vw_xvec );

    if( dotxy > 0.0 )
    {
      if( dotyx < 0.0 )
	opindex = 8;			/* Do not rotate */
      else
        opindex = 6;			/* Rotate about X axis */
    }
    else
    {
      if( dotyx < 0.0 )
	opindex = 5;			/* Rotate about Y axis */
      else
        opindex = 3;			/* Rotate about Z axis */
    }
  }

  /*"opindex = %d\n", opindex*/

  if( opindex != 8 )
  {
    om$get_classid( osnum = dim_os,
		    objid = dim_id,
		    p_classid = &dim_classid );

    if( dim_classid != OPP_VDfrmtxt_class_id )
    {
      if( opindex&1 )
      {
        /*
        ** |- X opp
        */
        math_v_opposite( txt_xvec, txt_xvec );

        if( fabs(txt_length - 0.0) > 0.001 )
        {
	  /*
          ** "txt_length = %f\n", txt_length
          */

	  MATH_ptdelta( &rc, text_pt, txt_xvec, txt_length, text_pt );
        }
      }

      if( opindex&2 )
      {
        /*
        ** |- Y opp
        */
        math_v_opposite( txt_yvec, txt_yvec );

        if( par_loc.txt_posn == TXT_POSN_ABOVE )
        {
	  /*
          ** "txt pt moved in Y dir: offset = %f\n", txt_offset
          */
	  MATH_ptdelta( &rc, text_pt, txt_yvec, txt_offset, text_pt );
        }
      }

      if( opindex&4 )
      {
        /*
        ** |- Z opp
        */
        math_v_opposite( txt_zvec, txt_zvec );
      }
    }

    for( i = 0 ; i < 3 ; i++ )
    {
      text_matrix[i*4]   = txt_xvec[i];
      text_matrix[i*4+1] = txt_yvec[i];
      text_matrix[i*4+2] = txt_zvec[i];
      text_matrix[i*4+3] = text_pt[i];
    }

    /*
    ** print_matrix("text_matrix", text_matrix);
    */

    four=4;
    MAinvmx( &long_rc, &four, lbsys_matrix, inv_matrix );
    MAmulmx( &long_rc, &four, &four, &four, text_matrix, inv_matrix, new_env );
    MAtypemx( &long_rc, new_env, new_type );

    /*
    ** print_matrix("new_env", new_env);
    */
  }
  else
  {
    /*
    ** |- Not rotation applied
    */
    *new_type = *mx_type;
    memcpy(new_env, matrix, 16*sizeof(double));
  }

  return( OM_S_SUCCESS );
}

end implementation DMroot;
