#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "ma.h"

/* prototype files */
#include "dpalignper.h"

#include "maidmx.h"
#include "mamulmx.h"
#include "matrlmx.h"
#include "mayrotmx.h"
#include "maptsxfor.h"
#include "mazrotmx.h"


IGRint DPalignper( msg, in_flags, vpn_in, vup_in, origin, rotate, matrix)

IGRlong		*msg;
IGRlong		in_flags;
IGRdouble	*vpn_in;
IGRdouble	*vup_in;
IGRdouble	*origin;
IGRdouble	*rotate;
IGRdouble	*matrix;
{

IGRshort	four=4;
IGRint		status;
IGRlong 	num_pnts=1;
IGRdouble	vpn[3];
IGRdouble	vup[3];
IGRdouble	eye_org[3];
IGRdouble	tmat[16];
IGRdouble	zmatrix[16];
IGRdouble	ymatrix[16];
IGRdouble	ex_mtx[4][4];
IGRdouble	rotation[4][4];

    status = TRUE;
    /* rotate the vpn to the neg. z axis */
    vpn[0] = -vpn_in[0];
    vpn[1] = -vpn_in[1];
    vpn[2] = -vpn_in[2]; 

    vup[0] = vup_in[0];
    vup[1] = vup_in[1];
    vup[2] = vup_in[2];

    status = MAzrotmx ( msg, vpn, zmatrix);
    if ( status & 1 )
    {
	num_pnts = 1;
    	status = MAptsxform(msg,&num_pnts,zmatrix,vup,vup);
    }
    if ( status & 1 )
    {
    	/* projecting the VUP into the x-y plane. */
	vup[2]=0;

 	/* finding the matrix necessary to rotate
    	the VUP's projection to the y-axis*/
	if (vup[0] == 0 && vup[1] < 0)
	{
	    MAidmx(msg,ymatrix);
	    ymatrix[0] = -1;
	    ymatrix[5] = -1;
	}
	else
	{
    	    status = MAyrotmx ( msg, vup, ymatrix);
	}
    }
    if ( status & 1 )
    {
    	eye_org[0] = - origin[0];
    	eye_org[1] = - origin[1];
    	eye_org[2] = - origin[2];
	status = MAtrlmx ( msg, eye_org, tmat );
    }
    if ( status & 1 )
    {
	status = MAmulmx ( msg, &four, &four, &four, ymatrix, zmatrix, rotate);
    }
    MAidmx(msg, (IGRdouble *)ex_mtx);
    ex_mtx[2][2] = -1;
    status = MAmulmx ( msg, &four, &four, &four, (IGRdouble *)ex_mtx, rotate, 
				(IGRdouble *)rotation);
    if ( in_flags & DPLEFT_VIEW )
    {
	status = MAmulmx ( msg, &four, &four, &four, (IGRdouble *)rotation, tmat, matrix);
    }
    else
    {
	status = MAmulmx ( msg, &four, &four, &four, rotate, tmat, matrix);
    }
    if (in_flags & DPLEFT_ROT )
    {
	OM_BLOCK_MOVE(rotation,rotate,sizeof(IGRdouble) *16);
    }

return (status);
}

