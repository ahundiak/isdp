/* #######################    APOGEE COMPILED   ######################## */
#include "exsysdep.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "msdef.h"
#include "madef.h"
#include "OMminimum.h"
#include "gocmacros.h"

/*
%safe
*/
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRlong GUbsp_format21 __((IGRshort *elebuf, IGRshort *ndices, 
                                  struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format24 __((IGRshort *elebuf, int ndices, 
                                  struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format25 __((IGRshort *elebuf, IGRshort *ndices, 
                                  struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format26 __((IGRshort *elebuf, IGRshort *ndices, 
                                  struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format27 __((IGRshort *elebuf, IGRshort *ndices, 
                                  struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_format28 __((IGRshort *elebuf, int ndices, 
                                  struct GUcontrol_struct *inbuf));
static GUbsp_vperiodicexpand __((struct GUcontrol_struct *inbuf));
static IGRlong GUbsp_knotld __((IGRlong *n, IGRshort iknot[], 
                                IGRdouble rknot[]));

#if defined(__cplusplus)
}
#endif
#undef __
/*
%endsafe
*/



#argsused
IGRlong GUbsp_format(status,elebuf,ndices,inbuf,insiz)

/*
 *
 *  This function formats IGDS elements so that the B-spline math functions
 *  may use them.
 *
 *  This function returns :
 *	0	illegal element
 *	1	success
 *	2 	buffer too small
 *	4	illegal option
 *
 */

IGRshort 	*status;	/* input/output - status infomation	*/
				/*   on entry:				*/
				/* 	1 sending element (set on 	*/
				/*	  initial call by caller)	*/
				/*   on exit:				*/
				/*	1 send another element		*/
				/*	3 last element read, call	*/
				/*	  interface function		*/
IGRshort	*elebuf;	/* input - buffer containing element	*/
IGRshort	*ndices;	/* input - dimension of design file	*/
struct		GUcontrol_struct
				/* input/output - buffer for master 	*/
		*inbuf;		/*	   data structure		*/

{

	IGRint eletyp;		/* type number of current element	*/
	IGRlong retstatus;	/* return status indicator		*/
	IGRint number;		/* temporary value			*/
	IGRlong msg;
	IGRlong i;

/*
 *
 *  Function declarations.
 *
 */
/*
	static IGRlong GUbsp_format21();
	static IGRlong GUbsp_format24();
	static IGRlong GUbsp_format25();
	static IGRlong GUbsp_format26();
	static IGRlong GUbsp_format27();
	static IGRlong GUbsp_format28();
*/

	if (*status != 1)		/* error condition		*/
	{
	  retstatus = 4;		/* set error return code	*/
	  return(retstatus);		/* return			*/
	}
#ifdef BIG_ENDIAN
	eletyp = elebuf[0] & 0x00ff;	/* form IGRinteger element type	*/
#else
	eletyp = elebuf[0] & 0xff00;	/* form IGRinteger element type	*/
	eletyp >>= 8;			/* shift to get type		*/
#endif

	switch (eletyp)
	{

	case 21:			/* pole element			*/

	  retstatus = GUbsp_format21(elebuf,ndices,inbuf);

	  if (inbuf->iscurve)		/* B-spline curve		*/
	  {
	    if (! inbuf->curve.rational)	/* non-rational		*/
	    {
	      *status = 3;		/* set to call interface	*/
	    }
	  }
	  else				/* B-spline surface		*/
	  {
	    if (! inbuf->surf.rational)	/* non-rational			*/
	    {
	      if (inbuf->surf.v_periodic)/* periodic in v		*/
	      {
	  	number = inbuf->surf.v_num_poles - inbuf->surf.v_order + 2;
	      }
	      else
	      {
		number = inbuf->surf.v_num_poles;
              }
	      if (inbuf->eledon == number)
	      {
		*status = 3;		/* set to call interface	*/
	      }
	    }
	  }
	  break;

	case 24:			/* surface header element	*/

	  retstatus = GUbsp_format24(elebuf,(int)ndices,inbuf);
	  break;

	case 25:			/* boundary element		*/

	  retstatus = GUbsp_format25(elebuf,ndices,inbuf);
	  break;

	case 26:			/* knot element			*/

	  retstatus = GUbsp_format26(elebuf,ndices,inbuf);
	  break;

	case 27:			/* curve header element		*/

	  retstatus = GUbsp_format27(elebuf,ndices,inbuf);
	  break;

	case 28:			/* weight element		*/

	  retstatus = GUbsp_format28(elebuf,(int)ndices,inbuf);

	  if (inbuf->iscurve)		/* B-spline curve		*/
	  {
            IGRboolean b_status;

	    *status = 3;		/* set to call interface	*/
	    b_status = GUbcweight ( &msg, &inbuf->curve );
	  }
	  else				/* B-spline surface		*/
	  {
	    if (inbuf->surf.v_periodic)	/* periodic in v		*/
	    {
	      number = inbuf->surf.v_num_poles - inbuf->surf.v_order + 2;
	    }
	    else
	    {
	      number = inbuf->surf.v_num_poles;
            }
	    if (inbuf->eledon == 2 * number)
	    {
	      *status = 3;		/* set to call interface	*/
	      for ( i = 0; i < inbuf->surf.u_num_poles * 
				inbuf->surf.v_num_poles; i++ )
	      {
		inbuf->surf.poles[3*i] *= inbuf->surf.weights[i];
		inbuf->surf.poles[3*i+1] *= inbuf->surf.weights[i];
		inbuf->surf.poles[3*i+2] *= inbuf->surf.weights[i];
	      }

	    }
	  }

	  break;

	default:			/* illegal element		*/
	  
	  retstatus = 0;		/* set error return		*/
	  break;

	}				/* end of case 			*/
	
	return(retstatus);

}

static IGRlong GUbsp_format21(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 21 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
IGRshort	*ndices;	/* input - dimension of design file	*/
struct		GUcontrol_struct 	
				/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRlong message;
	IGRlong dummy;
	IGRlong dummy1;

	status = 1;		/* initialize to success		*/
	
	GUbsp_i4tor8(ndices,&elebuf[19],&elebuf[18],inbuf->nextpol);
	++inbuf->eledon;			/* one more processed	*/

	if (inbuf->iscurve)	/* curve element			*/
	{

	  if (! inbuf->curve.rational)		/* non-rational curve	*/
	  {
	    if (inbuf->curve.periodic)		/* periodic curve	*/
	    {
	      dummy1 = elebuf[18];
	      MAbcupexpand(&message,&inbuf->curve.order,&inbuf->curve.rational,
			   &dummy1,inbuf->nextpol,inbuf->nextweight,
		           &dummy,inbuf->nextpol,inbuf->nextweight);
	    }
	    else				/* non-periodic curve	*/
	    {
	      dummy = inbuf->curve.num_poles;
	    }
	    inbuf->nextpol += 3 * dummy;	/* update pointers	*/
	    inbuf->nextdat = inbuf->nextpol;
	  }

	}
	else			/* surface element			*/
	{

	  if (! inbuf->surf.rational)		/* non-rational		*/
	  {
	    if (inbuf->surf.u_periodic)		/* periodic in u	*/
	    {
	      dummy1 = elebuf[18];
	      MAbcupexpand(&message,&inbuf->surf.u_order,&inbuf->surf.rational,
	                   &dummy1,inbuf->nextpol,inbuf->nextweight,
			   &dummy,inbuf->nextpol,inbuf->nextweight);
	    }
	    else				/* non-periodic in u	*/
	    {
	      dummy = inbuf->surf.u_num_poles;
	    }

	    inbuf->nextpol += 3 * dummy;	/* update pointers	*/
	    inbuf->nextdat = inbuf->nextpol;


/*
 *
 *  If we are on the last pole element of the non-rational surface, and the 
 *  surface is periodic in v,  we must expand the columns of the pole matrix
 *  to a full definition.
 *
 */

	    if (inbuf->surf.v_periodic)	/* periodic in v		*/
	    {
	      dummy = inbuf->surf.v_num_poles - inbuf->surf.v_order + 2;
	      if (inbuf->eledon == dummy) /* on last pole element	*/
	      {
	        GUbsp_vperiodicexpand(inbuf);
	      }
	    }

	  }

	}

	return(status);

}

#argsused
static IGRlong GUbsp_format24(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 24 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
struct		GUcontrol_struct 	
				/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRshort temp;
	IGRlong message;
	IGRlong num_uknots;
	IGRlong num_vknots;
	IGRlong num_poles;
	IGRlong num_left;

	status = 1;		        /* IGRintialize to success	*/
	inbuf->eledon = 0;		/* no pole/wt eles processed 	*/
	inbuf->iscurve = FALSE;		/* set surface indicator	*/
	inbuf->startbuf = (IGRdouble *) (GRalign_double (inbuf + 1));	
					/* set start of working buffer	*/
					/* to immediately follow con-	*/
					/* trol structure		*/
/*
 *
 *  Setup the surface's u direction parameters.
 *
 */
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x0f00)>>8);/* mask to get u order bits	*/
#else
	temp = elebuf[20] & 0x0f;	/* mask to get u order bits	*/
#endif
	inbuf->surf.u_order = temp + 2;	/* calculate order in u		*/
	inbuf->surf.u_num_poles =	/* set number of stored poles	*/
	  elebuf[21];			/* in each column		*/
	inbuf->knotu = elebuf[22];	/* set number of stored u knots	*/
	inbuf->rules[0] = elebuf[23];	/* set number of u rule lines	*/
	if (elebuf[23] < 2)		/* too few u rules requested	*/
	{
	  inbuf->rules[0] = 2;		/* reset to minimum allowed	*/
	}
	else
	{
	  if (elebuf[23] > 256)		/* too many u rules requested	*/
	  {
	    inbuf->rules[0] = 256;	/* reset to maximum allowed	*/
	  }
	}
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x8000)>>8);/* mask to get u periodic bit	*/
#else
	temp = elebuf[20] & 0x80;	/* mask to get u periodic bit	*/
#endif
	inbuf->surf.u_periodic =	/* shift to get periodic in u	*/
	  temp >> 7;			/* indicator			*/
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x4000)>>8);/* mask to get rational bit	*/
#else
	temp = elebuf[20] & 0x40;	/* mask to get rational bit	*/
#endif
	inbuf->surf.rational =		/* shift to get rational surf   */
	  temp >> 6;			/* indicator			*/

/*
 *
 *  Setup the surface's v direction parameters.
 *
 */

#ifdef BIG_ENDIAN
	temp = ((elebuf[24] & 0x0f00)>>8);/* mask to get v order bits	*/
#else
	temp = elebuf[24] & 0x0f;	/* mask to get v order bits	*/
#endif
	inbuf->surf.v_order = temp + 2;	/* calculate order in v		*/
	inbuf->surf.v_num_poles =	/* set number of stored pole	*/
	  elebuf[25];			/* elements			*/
	inbuf->knotv = elebuf[26];	/* set number of stored v knots	*/
	inbuf->rules[1] = elebuf[27];	/* set number of v rule lines	*/
	if (elebuf[27] < 2)		/* too few v rules requested	*/
	{
	  inbuf->rules[1] = 2;		/* reset to minimum allowed	*/
	}
	else
	{
	  if (elebuf[27] > 256)		/* too many v rules requested	*/
	  {
	    inbuf->rules[1] = 256;	/* reset to maximum allowed	*/
	  }
	}
#ifdef BIG_ENDIAN
	temp = ((elebuf[24] & 0x8000)>>8);/* mask to get v periodic bit	*/
#else
	temp = elebuf[24] & 0x80;	/* mask to get v periodic bit	*/
#endif
	inbuf->surf.v_periodic =	/* shift to get v periodic	*/
	  temp >> 7;			/* indicator			*/

/*
 *
 *  Setup the surface's miscellaneous entries such as slow indicator, number
 *  of boundaries, etc.
 *
 */

#ifdef BIG_ENDIAN
	temp = ((elebuf[24] & 0x4000)>>8);/* mask to get slow surf bit	*/
#else
	temp = elebuf[24] & 0x40;	/* mask to get slow surf bit	*/
#endif
	inbuf->slow = temp >> 6;	/* shift to get slow indicator	*/
	inbuf->surf.num_boundaries =	/* set number of boundaries	*/
	  elebuf[28];
	if (elebuf[28] > 16)		/* too many boundaries in defn	*/
	{
	  status = 0;			/* set for error		*/
	  return(status);		/* return			*/
	}
	temp = elebuf[16] & 0x8000;	/* mask to get solid/hole bit	*/
	if (temp == 0)			/* hole bit was cleared		*/
	{
	  inbuf->surf.on_off = 1;	/* set to on state		*/
	}
	else				/* hole bit was set		*/
	{
	  inbuf->surf.on_off = 0;	/* set to off state		*/
	}
	inbuf->curbdry = 0;		/* init current bdry number	*/

/*
 *
 *  Setup pointers to the surface's knot vectors.
 *
 */

	inbuf->surf.u_knots = 		/* initialize pointer to u 	*/
	  inbuf->startbuf;		/* knots			*/
	num_poles = 			/* find number of poles in u	*/
	  inbuf->surf.u_num_poles;
	if (inbuf->surf.u_periodic)	/* must adjust if periodic in u	*/
	{
	  num_poles += inbuf->surf.u_order - 2;
	}
	inbuf->surf.v_knots =		/* set pointer to v knots	*/
	  &inbuf->surf.u_knots[num_poles + inbuf->surf.u_order];

	inbuf->first_call = 1;		/* initialize to first call	*/
	inbuf->surf.u_non_uniform = TRUE; /* initialize to non-uniform	*/
	inbuf->surf.v_non_uniform = TRUE;
	if (inbuf->knotu == 0)		/* uniform surf in u 	 	*/
	{				/* generate u knot vector	*/
	  inbuf->surf.u_non_uniform = FALSE;	/* set for uniform	*/
/*
 *
 *  Generate the surface's uniform iterior u knots and then expand these knots
 *  to a full u knot vector.
 *
 */

	  MAbcuuniform(&message,&inbuf->surf.u_order,&inbuf->surf.u_periodic,
		       &inbuf->surf.u_num_poles,&num_uknots,inbuf->surf.u_knots);
	  MAbcukexpand(&message,&inbuf->surf.u_order,&inbuf->surf.u_periodic,
		       &num_uknots,inbuf->surf.u_knots,&num_uknots,
		       inbuf->surf.u_knots);
	}

/*
 *
 *  Setup pointers to the surface's pole and weight matrices and to the
 *  next data positions to fill.
 *
 */

	num_poles = 			/* find number of poles in v	*/
	  inbuf->surf.v_num_poles;
	if (inbuf->surf.v_periodic)	/* must adjust if periodic in v	*/
	{
	  num_poles += inbuf->surf.v_order - 2;
	}
	inbuf->nextdat =		/* set pointer to v knots	*/
	  &inbuf->surf.v_knots[num_poles + inbuf->surf.v_order];
	inbuf->surf.poles = inbuf->nextdat;
	inbuf->nextpol = 		/* set next pole position 	*/
	  inbuf->surf.poles;

	if (inbuf->knotv == 0)		/* uniform surf in v 	 	*/
	{				/* generate v knot vector	*/
	  inbuf->surf.v_non_uniform = FALSE;	/* set for uniform	*/
/*
 *
 *  Generate the surface's uniform iterior v knots and then expand these knots
 *  to a full v knot vector.
 *
 */

	  num_poles = inbuf->surf.v_num_poles;

	  MAbcuuniform(&message,&inbuf->surf.v_order,&inbuf->surf.v_periodic,
		       &num_poles,&num_vknots,inbuf->surf.v_knots);
	  MAbcukexpand(&message,&inbuf->surf.v_order,&inbuf->surf.v_periodic,
		       &num_vknots,inbuf->surf.v_knots,&num_vknots,
		       inbuf->surf.v_knots);
	}

	if (inbuf->surf.u_periodic)	/* periodic surf in u		*/
	{
	  inbuf->surf.u_num_poles +=	/* update to real number poles	*/
	    inbuf->surf.u_order - 2;
	}

	if (inbuf->surf.v_periodic)	/* periodic surf in v		*/
	{
	  inbuf->surf.v_num_poles +=	/* update to real number poles	*/
	    inbuf->surf.v_order - 2;
	}

	inbuf->surf.u_num_knots = inbuf->surf.u_num_poles + inbuf->surf.u_order;
	inbuf->surf.v_num_knots = inbuf->surf.v_num_poles + inbuf->surf.v_order;

	inbuf->surf.weights =		/* set-up pointer to weights	*/
	  &inbuf->surf.poles[3 * inbuf->surf.u_num_poles * inbuf->surf.v_num_poles];

/*
 *
 *  If the surface is periodic in v,  we must leave room at the beginning of 
 *  the pole and weights matrix to expand the columns.
 *
 */

	if (inbuf->surf.v_periodic)
	{
	  num_left = inbuf->surf.v_order/2 - 1;
	  inbuf->nextpol = &inbuf->surf.poles[3 * num_left * 
					      inbuf->surf.u_num_poles];
	  inbuf->nextweight = &inbuf->surf.weights[num_left *
						   inbuf->surf.u_num_poles];
	}
	else
	{
	  inbuf->nextpol = inbuf->surf.poles;
	  inbuf->nextweight = inbuf->surf.weights;
	}

/*
 *
 *  If the surface has boundaries, we must set up all the appropriate 
 *  pointers.
 *
 */

	inbuf->bdrysdon = 0;		/* no boundaries processed yet	*/
	if (inbuf->surf.num_boundaries != 0)
	{
	  inbuf->bdry_nums = (IGRshort *) inbuf->nextdat;
	  inbuf->surf.bdrys = 
	    (struct IGRbsp_bdry_pts *) 
	    (GRalign_double(&inbuf->bdry_nums[inbuf->surf.num_boundaries]));
	  inbuf->surf.bdrys[0].points = 
	    (IGRdouble *) (GRalign_double(
	    &inbuf->surf.bdrys[inbuf->surf.num_boundaries].num_points ));
	  inbuf->nextdat = inbuf->surf.bdrys[0].points;
	}

/*
 *
 *  Setup pointer to scratch area (immediately following all data).
 *
 */

	if (! inbuf->surf.rational)	/* non-rational surface		*/
	{
	  inbuf->scratch_buffer = &inbuf->surf.poles[3 * inbuf->surf.v_num_poles *
						     inbuf->surf.u_num_poles];
	}
	else				/* rational surface		*/
	{
	  inbuf->scratch_buffer = &inbuf->surf.weights[inbuf->surf.v_num_poles *
						       inbuf->surf.u_num_poles];
	}

	return(status);

}

#argsused
static IGRlong GUbsp_format25(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 25 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
IGRshort	*ndices;	/* input - dimension of design file	*/
struct		GUcontrol_struct 	
				/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRlong number;		/* temporary longword number to use	*/
	IGRint num_left;	/* number of columns expanded to left	*/
/*
	static IGRlong GUbsp_knotld();
*/
	
	status = 1;		/* initialize to success		*/

	if (elebuf[18] == inbuf->curbdry)	/* still same bdry	*/
	{
	  inbuf->surf.bdrys[inbuf->bdrysdon - 1].num_points += elebuf[19];
	  if (inbuf->surf.bdrys[inbuf->bdrysdon - 1].num_points > 4 * 151)
	  {
	    status = 0;		/* set error return			*/
	    return(status);
	  }
	}
	else			/* new boundary to process		*/
	{
	  ++inbuf->bdrysdon;	/* increment to boundary processed	*/
	  inbuf->curbdry = elebuf[18];
	  inbuf->bdry_nums[inbuf->bdrysdon - 1] = elebuf[18];
	  inbuf->surf.bdrys[inbuf->bdrysdon - 1].num_points = elebuf[19];
	  inbuf->surf.bdrys[inbuf->bdrysdon - 1].points = inbuf->nextdat;
	}

	number = 2 * elebuf[19];	/* number values to convert	*/
	status = GUbsp_knotld(&number,&elebuf[20],inbuf->nextdat);
	if (! status)			/* error occurred		*/
	{
	  return(status);
	}

/*
 * 
 *  Update pointers to next data, poles, weights, next poles, and next
 *  weights.
 * 
 */

	inbuf->nextdat += number;	/* increment pointer		*/
	inbuf->surf.poles = inbuf->nextdat;
	inbuf->surf.weights = &inbuf->surf.poles[3 * inbuf->surf.v_num_poles *
			      			 inbuf->surf.u_num_poles];

	if (inbuf->surf.v_periodic)	/* must adjust for expansion	*/
	{
	  num_left = inbuf->surf.v_order / 2 - 1;
	  inbuf->nextpol = &inbuf->surf.poles[3 * num_left * 
					      inbuf->surf.u_num_poles];
	  inbuf->nextweight = &inbuf->surf.weights[num_left *
						   inbuf->surf.u_num_poles];
	}
	else				/* no expansion necessary	*/
	{
	  inbuf->nextpol = inbuf->surf.poles;
	  inbuf->nextweight = inbuf->surf.weights;
 	}

/*
 *
 *  Setup pointer to scratch area (immediately following all data).
 *
 */

	if (! inbuf->surf.rational)	/* non-rational surface		*/
	{
	  inbuf->scratch_buffer = &inbuf->surf.poles[3 * inbuf->surf.v_num_poles *
						     inbuf->surf.u_num_poles];
	}
	else				/* rational surface		*/
	{
	  inbuf->scratch_buffer = &inbuf->surf.weights[inbuf->surf.v_num_poles *
						       inbuf->surf.u_num_poles];
	}

	return(status);

}

#argsused
static IGRlong GUbsp_format26(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 26 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
IGRshort	*ndices;	/* input - dimension of design file	*/
struct		GUcontrol_struct	
				/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRlong message;
	IGRlong num_uknots;	/* number of knots in u			*/
	IGRlong num_vknots;	/* number of knots in v			*/
	IGRlong number;		/* temporary longword number		*/
	
/*
	static IGRlong GUbsp_knotld();
*/

	status = 1;		/* initialize to success		*/

	if (inbuf->iscurve)		/* curve element		*/
	{
	  num_uknots = inbuf->knotu;	/* number of stored knots	*/
	  number = num_uknots;		/* longword version		*/
	  status = GUbsp_knotld(&number,&elebuf[18],inbuf->curve.knots);
	  if (! status)			/* error occurred		*/
	  {
	    return(status);
	  }
	  MAbcukexpand(&message,&inbuf->curve.order,&inbuf->curve.periodic,
		       &num_uknots,inbuf->curve.knots,&num_uknots,
		       inbuf->curve.knots);
	}
	else				/* surface element		*/
	{
	  num_uknots = inbuf->knotu;	/* number of stored u knots	*/
	  num_vknots = inbuf->knotv;	/* number of stored v knots	*/
	  if (num_uknots != 0)		/* must get u knots from ele	*/
	  {
	    number = num_uknots;	/* longword version		*/
	    status = GUbsp_knotld(&number,&elebuf[18],inbuf->surf.u_knots);
	    if (! status)		/* error occurred		*/
	    {
	      return(status);
	    }
	    MAbcukexpand(&message,&inbuf->surf.u_order,&inbuf->surf.u_periodic,
		         &num_uknots,inbuf->surf.u_knots,&num_uknots,
		         inbuf->surf.u_knots);
	  }	
	  if (num_vknots != 0)		/* must get v knots from ele	*/
	  {
	    number = num_vknots;	/* longword version		*/
	    status = GUbsp_knotld(&number,&elebuf[18 + 2*inbuf->knotu],
				inbuf->surf.v_knots);
	    if (! status)		/* error occurred		*/
	    {
	      return(status);
	    }
	    MAbcukexpand(&message,&inbuf->surf.v_order,&inbuf->surf.v_periodic,
		         &num_vknots,inbuf->surf.v_knots,&num_vknots,
		         inbuf->surf.v_knots);
	  }	
	}
/*
 *
 *  Clear the values of knotu and knotv in inbuf indicating that the knot
 *  element was encountered as expected.
 *
 */
	inbuf->knotu = 0;
	inbuf->knotv = 0;
	return(status);

}

#argsused
static IGRlong GUbsp_format27(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 27 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
IGRshort	*ndices;	/* input - dimension of design file	*/
struct		GUcontrol_struct 	/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRshort temp;
	IGRlong message;
	IGRlong num_knots;

	status = 1;			/* initialize to success	*/
	inbuf->eledon = 0;		/* no pole/wt eles processed 	*/
	inbuf->iscurve = TRUE;		/* set curve indicator		*/
	inbuf->startbuf = (IGRdouble *) (GRalign_double (inbuf + 1));
					/* set start of working buffer	*/
					/* to immediately follow con-	*/
					/* trol structure		*/
	inbuf->curve.num_boundaries = 0;
	inbuf->curve.bdrys = 0;
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x4000)>>8);/* mask to get rational bit	*/
#else
	temp = elebuf[20] & 0x40;	/* mask to get rational bit	*/
#endif
	inbuf->curve.rational =		/* shift to get rational curve	*/
	  temp >> 6;			/* indicator			*/
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x0f00)>>8);/* mask to get order bits	*/
#else
	temp = elebuf[20] & 0x0f;	/* mask to get order bits	*/
#endif
	inbuf->curve.order = temp + 2;	/* calculate curve's order	*/
	inbuf->curve.num_poles =	/* set number of stored poles	*/
	  elebuf[21];	
	inbuf->knotu = elebuf[22];	/* set number of stored knots	*/
#ifdef BIG_ENDIAN
	temp = ((elebuf[20] & 0x8000)>>8);/* mask to get periodic bit	*/
#else
	temp = elebuf[20] & 0x80;	/* mask to get periodic bit	*/
#endif
	inbuf->curve.periodic =		/* shift to get periodic curve	*/
	  temp >> 7;			/* indicator			*/
	inbuf->curve.knots = 		/* initialize pointer to knots	*/
	  inbuf->startbuf;
	inbuf->first_call = 1;		/* initialize to first call	*/
	inbuf->curve.non_uniform = TRUE;/* initialize to non-uniform	*/

	if (inbuf->knotu == 0)		/* uniform curve --- generate 	*/
	{				/* its knot vector		*/
	  inbuf->curve.non_uniform = FALSE;	/* set to non-uniform	*/

/*
 *
 *  Generate the curve's uniform iterior knots and then expand these knots
 *  to a full knot vector.
 *
 */

	  MAbcuuniform(&message,&inbuf->curve.order,&inbuf->curve.periodic,
		       &inbuf->curve.num_poles,&num_knots,inbuf->curve.knots);
	  MAbcukexpand(&message,&inbuf->curve.order,&inbuf->curve.periodic,
		       &num_knots,inbuf->curve.knots,&num_knots,
		       inbuf->curve.knots);
	  inbuf->nextdat = &inbuf->curve.knots[num_knots];
	  inbuf->curve.poles = inbuf->nextdat;
	}
	else				/* non-uniform curve --- knot	*/
	{				/* element will follow		*/
	  inbuf->nextdat = inbuf->startbuf;
	  inbuf->curve.poles = &inbuf->curve.knots[inbuf->knotu + 2 *
						   inbuf->curve.order];
	}

	inbuf->nextpol = 		/* set next pole position 	*/
	  inbuf->curve.poles;

	if (inbuf->curve.periodic)	/* periodic curve		*/
	{
	  inbuf->curve.num_poles +=	/* update to real number poles	*/
	    inbuf->curve.order - 2;
	}

	inbuf->curve.num_knots = inbuf->curve.num_poles + 
	  inbuf->curve.order;

	inbuf->curve.weights =		/* set-up pointer to weights	*/
	  &inbuf->curve.poles[3 * inbuf->curve.num_poles];
	inbuf->nextweight = inbuf->curve.weights;

/*
 *
 *  Setup pointer to scratch area (immediately following all data).
 *
 */

	if (! inbuf->curve.rational)	/* non-rational curve		*/
	{
	  inbuf->scratch_buffer = 
	    &inbuf->curve.poles[3 * inbuf->curve.num_poles];
	}
	else				/* rational curve		*/
	{
	  inbuf->scratch_buffer = 
	    &inbuf->curve.weights[inbuf->curve.num_poles];
	}

	return(status);

}

#argsused
static IGRlong GUbsp_format28(elebuf,ndices,inbuf)

/*
 *
 *  This function formats a type 28 IGDS element in the B-spline data 
 *  structure.
 *
 *  This function returns :
 *	0	error
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing element	*/
struct		GUcontrol_struct	
				/* input/output - buffer for master	*/
		*inbuf;		/*	   data structure		*/

{

	IGRlong status;		/* return status indicator		*/
	IGRlong message;
	IGRlong num_poles;
	IGRlong num_weights;
	IGRboolean periodic;
	IGRboolean rational;
	IGRshort order;
	IGRshort number;

/*
	static IGRlong GUbsp_knotld();
*/

	status = 1;		/* initialize to success		*/

	if (inbuf->iscurve)			/* curve element	*/
	{
	  if (inbuf->curve.periodic)		/* periodic curve	*/
	  {
	    num_poles = inbuf->curve.num_poles - inbuf->curve.order + 2;
	  }
	  else					/* non-periodic curve	*/
	  {
	    num_poles = inbuf->curve.num_poles;
	  }
	  periodic = inbuf->curve.periodic;
	  order = inbuf->curve.order;
	  rational = inbuf->curve.rational;
	}
	else					/* surface element	*/
	{
	  if (inbuf->surf.u_periodic)		/* periodic in u	*/
	  {
	    num_poles = inbuf->surf.u_num_poles - inbuf->surf.u_order + 2;
	  }
	  else					/* non-periodic in u	*/
	  {
	    num_poles = inbuf->surf.u_num_poles;
	  }
	  periodic = inbuf->surf.u_periodic;
	  order = inbuf->surf.u_order;
	  rational = inbuf->surf.rational;
	}

	num_weights = num_poles;		/* setup longword	*/
	status = GUbsp_knotld(&num_weights,&elebuf[18],inbuf->nextweight);
	if (! status)				/* error occurred	*/
	{
	  return(status);
	}
	++inbuf->eledon;			/* one more processed	*/
	if (periodic)				/* periodic element	*/
	{
	  MAbcupexpand(&message,&order,&rational,&num_poles,inbuf->nextpol,
	               inbuf->nextweight,&num_poles,inbuf->nextpol,
		       inbuf->nextweight);
	}
	inbuf->nextpol += 3 * num_poles;	/* update pointers	*/
	inbuf->nextweight += num_poles;
	inbuf->nextdat = inbuf->nextpol;


/*
 *
 *  If we are on the last weight element of the surface, and the surface is
 *  periodic in v,  we must expand the columns of the pole and weights matrix
 *  to a full definition.
 *
 */

	if (! inbuf->iscurve)		/* surface element		*/
	{
	  if (inbuf->surf.v_periodic)	/* periodic in v		*/
	  {
	    number = inbuf->surf.v_num_poles - inbuf->surf.v_order + 2;
	    if (inbuf->eledon == 2 * number) /* on last pole element	*/
	    {
	      GUbsp_vperiodicexpand(inbuf);
	    }
	  }

	}

	return(status);

}

GUbsp_i4tor8(ndices,i4buf,num_points,r8buf)

/*
 *
 *  This function accepts an array of longword points in the dimension of
 *  the design file and converts them IGRinto 3-d homogeneous IGRdouble points. 
 *  The input points buffer (i4buf) and the output buffer (r8buf) cannot
 *  be the same array.
 *
 */

IGRshort	*ndices;	/* input - dimension of design file	*/
IGRshort	*i4buf;		/* input - array of longword points in	*/
				/*	   the dimension of design file	*/
IGRshort	*num_points;	/* input - number of points to convert	*/
IGRdouble  	r8buf[][3];	/* output - array of homogeneous 3-d	*/
				/*	    IGRdouble points		*/

{

	IGRint i,j;		/* loop counters			*/
	IGRint number;		/* working number of points to convert	*/
	IGRint dimension;	/* working dimension			*/
	IGRshort *buffer;	/* working pointer to i4buf location	*/
	IGRlong temp_long;
	IGRshort *temp_ptr;


	temp_ptr = (IGRshort *) &temp_long;
	number = *num_points;
	dimension = *ndices;
	buffer = i4buf;

	for (i = 0; i < number; i++)
	{
	  for (j = 0; j < dimension; j++)
	  {
	    *temp_ptr = *(buffer++);
	    *(temp_ptr+1) = *(buffer++);
	    r8buf[i][j] = temp_long;
	  }
	}
	if (dimension == 2)	/* must clear out z values		*/
	{
	  for (i = 0; i < number; i++)
	  {
	    r8buf[i][2] = GUACT_Z_2D;
	  }
	}

}

static GUbsp_vperiodicexpand(inbuf)

/*
 *
 *  This function accepts the data structure for a B-spline surface which 
 *  is periodic in v and all the stored poles have been processed (and the
 *  proper room was left in the structure for expanding the poles in v),
 *  and performs the v direction expansion of pole columns.
 *
 */

struct	GUcontrol_struct		/* input/output - buffer for master 	*/
	*inbuf;			/*                data structure	*/

{

	IGRint i,j,k;		/* loop counters			*/
	IGRint num_left,num_right;/* expansion numbers			*/
	IGRint stored;		/* number of stored columns of surface	*/
	IGRdouble (*epoles)[4],(*opoles)[4];
				/* pointers to use in referencing the	*/
				/* expanded poles column and the orig-	*/
				/* inal poles column			*/
	IGRdouble *eweights,	/* pointers for weights			*/
	       *oweights;

	if (! inbuf->surf.v_periodic)	/* non-periodic in v		*/
	{
	  stored = inbuf->surf.v_num_poles;
	}
	else
	{
	  stored = inbuf->surf.v_num_poles - inbuf->surf.v_order + 2;
	}

	num_left = inbuf->surf.v_order  / 2 - 1;
	num_right = inbuf->surf.v_order - 1 - num_left - 1;

	for (i = 0; i < num_left; i++)
	{
	  epoles = (IGRdouble (*)[]) &inbuf->surf.poles[(num_left - 1 - i) * 3 *
				      inbuf->surf.u_num_poles];
	  opoles = (IGRdouble (*)[]) &inbuf->surf.poles[(stored + num_left - 2 - 
				      i) * 3 * inbuf->surf.u_num_poles];

	  for (j = 0; j < inbuf->surf.u_num_poles; j++)
	  {
	    for (k = 0; k < 3; k++)
	    {
	      epoles[j][k] = opoles[j][k];
	    }
	  }
	}
	for (i = 0; i < num_right; i++)
	{
	  epoles = (IGRdouble (*)[]) &inbuf->surf.poles[(stored + num_left + i)
				      * 3 * inbuf->surf.u_num_poles];
	  opoles = (IGRdouble (*)[]) &inbuf->surf.poles[(num_left + i + 1) * 3 *
				      inbuf->surf.u_num_poles];

	  for (j = 0; j < inbuf->surf.u_num_poles; j++)
	  {
	    for (k = 0; k < 3; k++)
	    {
	      epoles[j][k] = opoles[j][k];
	    }
	  }
	}
	if (inbuf->surf.rational)	/* rational surface		*/
	{
	  for (i = 0; i < num_left; i++)
	  {
	    eweights = &inbuf->surf.weights[(num_left - 1 - i) * 
				            inbuf->surf.u_num_poles];
	    oweights = &inbuf->surf.weights[(stored + num_left - 2 - i) *
				            inbuf->surf.u_num_poles];

	    for (j = 0; j < inbuf->surf.u_num_poles; j++)
	    {
	      eweights[j] = oweights[j];
	    }
	  }
	  for (i = 0; i < num_right; i++)
	  {
	    eweights = &inbuf->surf.weights[(stored + num_left + i)  *
				            inbuf->surf.u_num_poles];
	    oweights = &inbuf->surf.weights[(num_left + i + 1) *
				            inbuf->surf.u_num_poles];

	    for (j = 0; j < inbuf->surf.u_num_poles; j++)
	    {
	      eweights[j] = oweights[j];
	    }
	  }
	}

}	  

static IGRlong GUbsp_knotld(n,iknot,rknot)

/*
 * 
 *  This function converts knots and weights from I*4 to R*8 and 
 *  scales them by the proper scaling constant.
 *
 */

IGRlong		*n;		/* input - number of values to convert	*/
IGRshort	iknot[];	/* input - array of IGRlong to convert  */
IGRdouble	rknot[];	/* output - array of IGRdouble coverted	*/
				/*	    values			*/

{

	IGRint i;
	IGRshort	*iknot_temp;
	IGRlong		temp;
	IGRshort	*temp_ptr;
	IGRlong status;

	status = 1;		/* set to success			*/
	iknot_temp = iknot;
	temp_ptr = (IGRshort *) &temp;

	for (i = 0; i < *n; i++)
	{
	  *temp_ptr = *iknot_temp;
	  *(temp_ptr+1) = *(iknot_temp+1);
	  rknot[i] = (IGRdouble) temp / (IGRdouble) 2147483647.0;
	  iknot_temp += 2;
	}

	return(status);

}


IGRlong GUbsp_bufsize(elebuf,datflg,size)

/*
 *
 *  This function determines the minimum size (in words) that the buffer
 *  to be sent to the formatter and interface must be in order to carry
 *  out the desired operation.  This determination is made from the 
 *  B-spline element header.
 *
 *  This function returns :
 *	0	error (illegal element)
 *	1	success
 *
 */

IGRshort	*elebuf;	/* input - buffer containing B-spline 	*/
				/*	   header element		*/
IGRshort	*datflg;	/* input - option to perform		*/
				/*	0,2  stroke with I*4 output	*/
				/*	1,3  stroke with R*8 output	*/
				/*	4  stroke into fixed number of	*/
				/*	   parametrically evenly spaced	*/
				/*	   points with I*4 output	*/
				/*	other => format only		*/
IGRlong	*size;			/* output - number of words required 	*/
				/*	    for the data structure 	*/
				/*	    buffer			*/


{

	IGRlong retstatus;	/* return status (=1 if successful,	*/
				/* =0 if error occurred			*/
	IGRboolean iscurve;	/* curve/surface indicator		*/
	IGRint eletyp;		/* type number of given element		*/
	IGRlong poleu;		/* number of stored poles in u		*/
	IGRlong polev;		/* number of stored poles in v		*/
	IGRlong n = 0;		/* true number of poles in u		*/
	IGRlong m = 0;		/* true number of poles in v		*/
	IGRshort k = 0;		/* order in u				*/
	IGRshort l = 0;		/* order in v				*/
	IGRshort b1 = 0;	/* number of boundaries			*/
	IGRlong  b2 = 0;	/* approx. number of boundary points	*/
	IGRlong  r = 0;		/* total number of rule lines 		*/
	IGRint slow;		/* slow (=1) surface indicator		*/
	IGRboolean u_periodic,	/* periodic indicators in u and v	*/
		v_periodic;
	IGRboolean rational;	/* rational element indicator		*/
	IGRint temp;
	IGRlong msg;
	IGRlong size2;
	struct IGRbsp_surface surf;
	IGRlong rules[2];
	struct IGRbsp_bdry_pts bdrys;

	retstatus = 1;			/* initialize to success	*/

#ifdef BIG_ENDIAN
	eletyp = elebuf[0] & 0x00ff;	/* form IGRinteger element type	*/
#else
	eletyp = elebuf[0] & 0xff00;	/* form IGRinteger element type	*/
	eletyp >>= 8;			/* shift to get type		*/
#endif

	switch (eletyp)			/* find relevant parameters	*/
	{
	case 27:			/* curve header			*/

	  iscurve = TRUE;
	  poleu = elebuf[21];		/* number of stored poles	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] & 0x4000)>>8);/* mask to get rational bit	*/
#else
	  temp = elebuf[20] & 0x40;	/* mask to get rational bit	*/
#endif
	  rational = temp >> 6;		/* shift to get rational 	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] & 0x0f00)>>8);/* mask to get order bits	*/
#else
	  temp = elebuf[20] & 0x0f;	/* mask to get order bits	*/
#endif
	  k = temp + 2;			/* calculate curve's order	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] & 0x8000)>>8);/* mask to get periodic bit	*/
#else
	  temp = elebuf[20] & 0x80;	/* mask to get periodic bit	*/
#endif
	  u_periodic = temp >> 7;	/* shift to get u_periodic	*/
	  n = poleu;			/* initialize n			*/
	  if (u_periodic)		/* must adjust true number 	*/
	  {				/* of poles			*/
	    n += k - 2;
	  }
	  
 	  *size = BS_STRUCT_SIZE + 4*(n+k) + 12*n;
	  if (rational)			/* must allow for weights	*/
	  {
	    *size += 4 * n;
	  }
	  break;

	case 24:			/* surface header		*/

	  iscurve = FALSE;
	  poleu = elebuf[21];		/* number of stored poles in u	*/
	  polev = elebuf[25];		/* number of stored poles in v	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] & 0x4000)>>8);/* mask to get rational bit	*/
#else
	  temp = elebuf[20] & 0x40;	/* mask to get rational bit	*/
#endif
	  rational = temp >> 6;		/* shift to get rational 	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] & 0x0f00)>>8);/* mask to get u order bits	*/
#else
	  temp = elebuf[20] & 0x0f;	/* mask to get u order bits	*/
#endif
	  k = temp + 2;			/* calculate u order		*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[24] & 0x0f00)>>8);/* mask to get v order bits	*/
#else
	  temp = elebuf[24] & 0x0f;	/* mask to get v order bits	*/
#endif
	  l = temp + 2;			/* calculate v order		*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[20] &0x8000)>>8);/*mask to get u periodic bit	*/
#else
	  temp = elebuf[20] & 0x80;	/* mask to get u periodic bit	*/
#endif
	  u_periodic = temp >> 7;	/* shift to get u_periodic	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[24] &0x8000)>>8);/*mask to get v periodic bit	*/
#else
	  temp = elebuf[24] & 0x80;	/* mask to get v periodic bit	*/
#endif
	  v_periodic = temp >> 7;	/* shift to get v_periodic	*/
	  r = elebuf[23] + elebuf[27];	/* number of rule lines		*/
	  if (r < 4)			/* too few requested		*/
	  {
	    r = 4;			/* reset to minimum		*/
	  }
	  else
	  {
	    if (r > 512)		/* too many requested		*/
	    {
	      r = 512;			/* reset to maximum		*/
	    }
	  }
	  b1 = elebuf[28];		/* number of boundaries		*/
	  b2 = elebuf[28] * 4;		/* default to max num of eles	*/
	  if (b2 > 16)			/* too many eles guessed	*/
	  {
	    b2 = 16;			/* reset to maximum		*/
	  }
	  b2 *= 151;			/* default to max pts per ele	*/
#ifdef BIG_ENDIAN
	  temp = ((elebuf[24] & 0x4000)>>8);/* mask to get slow bit	*/
#else
	  temp = elebuf[24] & 0x40;	/* mask to get slow bit		*/
#endif
	  slow = temp >> 6;		/* shift to get slow indicator	*/
	  n = poleu;			/* initialize			*/
	  m = polev;
	  if (u_periodic)		/* must adjust true number 	*/
	  {				/* of poles in u		*/
	    n += k - 2;
	  }
	  if (v_periodic)		/* must adjust true number 	*/
	  {				/* of poles in v		*/
	    m += l - 2;
	  }
	  
 	  *size = BS_STRUCT_SIZE + 4*(n+k+m+l) + 5*b1 + 8*b2 + 12*n*m;
	  if (rational)			/* must allow for weights	*/
	  {
	    *size += 4 * n * m;
	  }


	  break;

	default:			/* illegal element		*/

	  retstatus = 0;		/* set error indicator		*/
	  goto wrapup;			/* return			*/

	}				/* end of case statement	*/

	switch (*datflg)		/* case on option to perform	*/
	{
	case 0:				/* stroking options		*/
	case 1:
	case 2:
	case 3:

	  if (iscurve)			/* curve element		*/
	  {
            IGRboolean b_status;

	    b_status = MAbcsize(&msg,&k,&size2);
	    *size += (size2 * 4);
	  }
	  else				/* surface element		*/
	  {
	    rules[0] = r;
	    rules[1] = 0;
	    surf.u_num_poles = n;
	    surf.v_num_poles = m;
	    surf.u_order = k;
	    surf.v_order = l;
	    surf.num_boundaries = 1;	/* simulate 1 bdry with all pts	*/
	    surf.bdrys = &bdrys;
	    surf.bdrys[0].num_points = b2;
	    MAbssize(&msg,&surf,rules,&size2);
	    *size += (size2 * 4);
	  }
	  break;

	case 4:				/* parametric stroking option	*/
	default:			/* other option			*/

	  break;

	}				/* end of option cases		*/

wrapup:

	return(retstatus);		

}
