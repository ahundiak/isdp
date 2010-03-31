/* ###################   APOGEE COMPILED   ################## */
/*
Description

  This function accepts two curves and an overlap interval on each
  curve. It validates the overlap by sampling the specified number
  of points on the overlap interval of one curve (curv0) and checking
  if the overlap interval on the other curve (crv1) is within 
  tolerance. It returns the number of successful hits and the number
  of misses. The  value for 'sample_size' must be at least 2 (in which
  case only the end points of the overlap are used). Reasonable values
  of 'sampling_size' for various levels of leniency/strictness of
  validation, for example, are :

	lenient		4
	moderate	16
	strict		32
	extreme		64

  The validation-option-bits supported are :

  EMSvalovlap_WriteSamples	: Write all sampling info in file (if the
				  fileptr is not NULL) or stderr. 
  EMSvalovlap_WriteSummary	: Write all summary info in file (if the
				  fileptr is not NULL) or stderr. This
				  option is automatically used if the 
  				  WriteSamples option is specified.
  EMSvalovlap_DisplayMisses	: Hilite all misses.
  EMSvalovlap_TextMisses	: Write text in graphics window specified
				  in the button structure, showing the
				  gap-distances at misses.

Return Values

  EMS_S_Success		if all goes well.

  EMS_E_InvalidArg  	if num_hits or num_misses is a NULL pointer 
			
			OR
		
			if sample size is less than 2.

  EMS_E_BSerror		if a BS (math) call fails.

Notes

History

  RV	Sep-18-87	Creation
  RV	Aug-01-88	Added and supported validation options to write
			and display edge-matching information.
  SM	Jan-04-90	Instead of linear increments in curve parameter for
			successive sample points, divide curve into equal
			spaces over the given interval. This gives a more
			realistic sampling over the interval.
  Sudha jul-09-93       Modified for BSprototypes anisfication
  SCW   Feb-13-97       included emsmacros_c.h rather than emsmacros.h

*/

#include "EMS.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

/* igr.h replacement */

# ifndef igrdef_include
# include "igrdef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef grdpbdef_include
# include "grdpbdef.h"
# endif

# ifndef grdpbmacros_include
# include "grdpbmacros.h"
# endif

/* end of gr.h replacement */

#include <stdio.h>
#include "ex.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include <math.h>
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "bsmdstptcv.h"
#include "bsdividecv.h"
#include "bscvkttol2.h"
#include "bscveval.h"

#define SHIFT_FACTOR	10
#define TparsBuff	20

IGRint EMvalcv_ovlap(EMmsg, crv0, crv1, ovlap0, ovlap1, sample_size,
		     num_hits, num_misses, tolerance, option, button, fileptr)

			
	 IGRlong *EMmsg;		/* return code 		*/
	 struct IGRbsp_curve *crv0;     /* curve0		*/
	 struct IGRbsp_curve *crv1;	/* curve1		*/
	 IGRdouble *ovlap0;		/* overlap on curve0	*/
	 IGRdouble *ovlap1;		/* overlap on curve1    */
	 IGRint sample_size;		/* number of sample pts.*/
	 IGRint *num_hits;		/* number of hits	*/
	 IGRint *num_misses;		/* number of misses     */
	 IGRdouble tolerance;		/* stitch tolerance 	*/
	 IGRushort option;	/* validation option	*/
	 struct EX_button *button;	/* window-id, x,y,z etc */
	 FILE *fileptr;			/* fileptr of log-file,
					   stderr if NULL	*/
{
 IGRlong     	        OM_stat;
 IGRlong   		error, bytes_in, bytes_out;
 IGRdouble 		dist, dist_tol, cht_tol,
			knot_tol0, knot_tol1,
			ovlap0_bgn, ovlap0_end,
			ovlap1_bgn, ovlap1_end,
			hit_par, worst_miss0, worst_miss1;
 IGRpoint		point0, point1, base_point;
 IGRint			num_hits0, num_misses0, num_hits1, num_misses1, i, 
			num_spaces;
 IGRboolean		was_hit;
 struct IGRdisplay      ActiveDisplay;
 struct GRmd_env	ModuleInfo;
 IGRchar             	text[64];
 struct var_list	list[3];
 IGRdouble		dit_tol, scale;
 BSrc			rc;

 IGRlong		ECdisplayPointSetByBuffer0();
 IGRdouble		*tpars = NULL, tparsbuff[TparsBuff];

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (!num_hits || !num_misses || sample_size < 2)
     {*EMmsg  = EMS_E_InvalidArg; goto wrapup;}

 if(sample_size > TparsBuff)
  tpars = (IGRdouble *) om$malloc(size = sample_size * sizeof(IGRdouble));
 else tpars = (IGRdouble *) tparsbuff;
 EMerr_hndlr(!tpars, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 num_spaces = sample_size - 1;

 BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

 BScvkttol2(crv0->order, crv0->knots, crv0->num_poles, 
	    crv0->poles, crv0->weights, &knot_tol0, &rc);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

 BScvkttol2(crv1->order, crv1->knots, crv1->num_poles, 
	    crv1->poles, crv1->weights, &knot_tol1, &rc);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

 *num_hits = 0;
 *num_misses = 0;
 num_hits0 = num_misses0 = 0;
 num_hits1 = num_misses1 = 0;
 worst_miss0 = worst_miss1 = 0.0;

 if (option & EMSvalovlap_TextMisses)
 {
   bytes_in = sizeof (IGRdouble);

   gr$get_dit_tolerance (msg = EMmsg, sizbuf = &bytes_in, 
                    buffer = &dit_tol, nret = &bytes_out);
   EMerr_hndlr(EMis_error(*EMmsg), OM_stat, OM_E_ABORT, wrapup);

   list[0].var = VVOL_VIEWPORT_SCALE;
   list[0].var_ptr = (IGRchar *) &scale;
   list[0].num_bytes = sizeof(IGRdouble);
   list[0].bytes_returned = &bytes_out;
   list[1].var = END_PARAM;
   list[1].var_ptr = NULL;
   list[1].num_bytes = 0;
   list[1].bytes_returned = NULL;

   dp$inq_set_gragad(msg = EMmsg,
                     osnum = button->osnum,
                     gragad_objid = button->objid,
                     which_error = &error, var_list = list);
   EMerr_hndlr(EMis_error(*EMmsg), OM_stat, OM_E_ABORT, wrapup);

   dit_tol /= scale; dit_tol *= SHIFT_FACTOR;
 }
 if (option & EMSvalovlap_DisplayMisses)
 {
    bytes_in = sizeof(ActiveDisplay);
    gr$get_active_display(msg = EMmsg, sizbuf = &bytes_in,
		      buffer = &ActiveDisplay, nret = &bytes_out);
    EMerr_hndlr(EMis_error(*EMmsg), OM_stat, OM_E_ABORT, wrapup);
    ActiveDisplay.weight += 4;

    bytes_in = sizeof(ModuleInfo);
    gr$get_module_env(msg = EMmsg, sizbuf = &bytes_in,
		      buffer = &ModuleInfo, nret = &bytes_out);
    EMerr_hndlr(EMis_error(*EMmsg), OM_stat, OM_E_ABORT, wrapup);
 }

 if (ovlap0[0] < ovlap0[1])
 {
	ovlap0_bgn = ovlap0[0];
	ovlap0_end = ovlap0[1];  
 }
 else
 {
	ovlap0_bgn = ovlap0[1];
	ovlap0_end = ovlap0[0];  
 }
 if (ovlap1[0] < ovlap1[1])
 {
	ovlap1_bgn = ovlap1[0];
	ovlap1_end = ovlap1[1];  
 }
 else
 {
	ovlap1_bgn = ovlap1[1];
	ovlap1_end = ovlap1[0];  
 }


 (void) BSdividecv(&rc, crv0, &ovlap0_bgn, &ovlap0_end, &num_spaces, tpars);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

 for (i=0; i<sample_size; i++)
 {
   BScveval(crv0, tpars[i], 0, &point0, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

   BSmdstptcv(crv1, point0, &hit_par, base_point, &dist, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

   if (dist > tolerance || hit_par < ovlap1_bgn - knot_tol1 || 
			  hit_par > ovlap1_end + knot_tol1)
   {
     was_hit = FALSE;
     if (dist > worst_miss0) worst_miss0 = dist;
     if (option & EMSvalovlap_DisplayMisses)
     {
       OM_stat = ECdisplayPointSetByBuffer0(EMmsg, ActiveDisplay, 
         	 ModuleInfo, OM_GO_TransOS_0, 1, point0, GRhd, IGRPY); 
       if (! (1&OM_stat)) goto wrapup;
     }
     if (option & EMSvalovlap_TextMisses)
     {
        strcpy(text," gap = ");
        OM_stat = EFshort_cvtn(text, dist, 0,64); 

	button->x = point0[0] + dit_tol;
	button->y = point0[1] + dit_tol; 
	button->z = point0[2];

        OM_stat = EMrastext(EMmsg, text, button);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);   
     }
     num_misses0++;
   }
   else
   {
     was_hit = TRUE;
     num_hits0++;
   }
   if (option & EMSvalovlap_WriteSamples)
   {
	 fprintf(fileptr ? fileptr : stderr,
	   "Sample point on edge1 : %f,%f,%f\tat %f\n",
	   point0[0],point0[1],point0[2], tpars[i]);
	 fprintf(fileptr ? fileptr : stderr,
	   "Mindist point on edge2 : %f,%f,%f\tat %f\n",
	   base_point[0],base_point[1],base_point[2],hit_par);
	 fprintf(fileptr ? fileptr : stderr,"Minimum distance : %f\t",dist);
	 fprintf(fileptr ? fileptr : stderr, was_hit ? "(HIT)\n" : "(MISS)\n");
	 fprintf(fileptr ? fileptr : stderr, 
	 "----------------------------------------------------------------\n");
   }
 }


 (void) BSdividecv(&rc, crv1, &ovlap1_bgn, &ovlap1_end, &num_spaces, tpars);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

 for (i=0; i < sample_size; i++)
 {
   BScveval(crv1, tpars[i], 0, &point1, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

   BSmdstptcv(crv0, point1, &hit_par, base_point, &dist, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

   if (dist > tolerance || hit_par < ovlap0_bgn - knot_tol0 || 
			  hit_par > ovlap0_end + knot_tol0)
   {
     was_hit = FALSE;
     if (dist > worst_miss1) worst_miss1 = dist;
     if (option & EMSvalovlap_DisplayMisses)
     {
       OM_stat = ECdisplayPointSetByBuffer0(EMmsg, ActiveDisplay, 
         	 ModuleInfo, OM_GO_TransOS_0, 1, point1, GRhd, IGRPY); 
       if (! (1&OM_stat)) goto wrapup;
     }
     if (option & EMSvalovlap_TextMisses)
     {
        strcpy(text," gap = ");
        OM_stat = EFshort_cvtn(text, dist, 0,64); 

	button->x = point1[0] - dit_tol;
	button->y = point1[1] - dit_tol;
	button->z = point1[2];

        OM_stat = EMrastext(EMmsg, text, button);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);   
     }
     num_misses1++;
   }
   else
   {
     was_hit = TRUE;
     num_hits1++;
   }
   if (option & EMSvalovlap_WriteSamples)
   {
	 fprintf(fileptr ? fileptr : stderr,
	   "Sample point on edge2 : %f,%f,%f\tat %f\n",
	   point1[0],point1[1],point1[2],tpars[i]);
	 fprintf(fileptr ? fileptr : stderr,
	   "Mindist point on edge1 : %f,%f,%f\tat %f\n",
	   base_point[0],base_point[1],base_point[2],hit_par);
	 fprintf(fileptr ? fileptr : stderr,"Minimum distance : %f\t",dist);
	 fprintf(fileptr ? fileptr : stderr, was_hit ? "(HIT)\n" : "(MISS)\n");
	 fprintf(fileptr ? fileptr : stderr, 
	 "----------------------------------------------------------------\n");
   }
 }

 *num_hits = num_hits0 + num_hits1;
 *num_misses = num_misses0 + num_misses1;

 if ((option & EMSvalovlap_WriteSamples) ||
     (option & EMSvalovlap_WriteSummary) ||
     ((option & EMSvalovlap_WriteMissSummary) && *num_misses))
 {
   fprintf(fileptr ? fileptr : stderr, "\nSUMMARY OF EDGE-MATCH :\n");
   fprintf(fileptr ? fileptr : stderr, "\nMatch Tolerance : %f\n", tolerance);
   fprintf(fileptr ? fileptr : stderr, 
	"Sample size per edge : %d\n", sample_size);

   fprintf(fileptr ? fileptr : stderr, 
	"From edge 1 : \tNumber of hits :\t%d\n", num_hits0);
   fprintf(fileptr ? fileptr : stderr, 
	"            : \tNumber of missess :\t%d\n", num_misses0);
   fprintf(fileptr ? fileptr : stderr, 
	"            : \tWorst miss :\t%f\n", worst_miss0);

   fprintf(fileptr ? fileptr : stderr, 
	"From edge 2 : \tNumber of hits :\t%d\n", num_hits1);
   fprintf(fileptr ? fileptr : stderr, 
	"            : \tNumber of missess :\t%d\n", num_misses1);
   fprintf(fileptr ? fileptr : stderr, 
	"            : \tWorst miss :\t%f\n", worst_miss1);
 } 

 wrapup:

  if(tpars && (tpars != tparsbuff)) om$dealloc(ptr = tpars);
  EMWRAPUP(*EMmsg, OM_stat, "In EMvalcv_ovlap")
  return(OM_stat);
}

