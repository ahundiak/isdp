/* $Id: SMSMgrOver.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSMgrOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSMgrOver.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
# Revision 1.2  1996/04/29  09:03:22  pinnacle
# Replaced: smsection/imp/SMSMgrOver.I for:  by ksundar for vds.240
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
/*  History :
/*	CH  : 15 Jun 92	  creation date.
/*
/* */

class implementation SMsection;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "growner.h"

#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EMSutil.h"

#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMsection.h"
#include "SMcomp_def.h"
#include "VDmem.h"

#include "AS_status.h"

#define AS_DEBUG



/* ******************* MSG SMWhoAreYou() ************************       */

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
 if(type     != NULL) *type     = SM_SCT;
 if(sub_type != NULL) *sub_type = 0xffff;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMFillSfFile() ************************	*/

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRchar		tpipo[81], axis;
 IGRint			inc, nb_parts, i, j, k;
 IGRdouble		dpipo, struct_coef, x, y, z;
 struct GRid		my_grid, cmp_id, crv_id;
 IGRint			tt_crvs, nb_alloc;
 IGRint			y_index, z_index, nb_pts; 
 struct IGRbsp_curve 	*geom;
 IGRshort		state;

 *msg    = MSFAIL;
 x       = 0;
 y_index = 0; 
 z_index = 0; 

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   return OM_W_ABORT;
  }
   
 /* Get the compartment */
 status = om$send(msg = message SMsection.SMGetComp(&loc_msg, &cmp_id, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No compartment !!! */
   return(OM_W_ABORT);
  }
 
 /*
  * The Calculation section is maybe in deffer mode, if true, it has to be
  * recomputed.
  */
 
 status = om$send(msg = message SMmgr.SMGetState(&state),
 			targetid = my_id);
 if(!(status & 1)) return OM_W_ABORT;

 if(state & SM_NOT_COMP)
  {
   IGRboolean CurCalFlg;

   /* Get the calculation section state to turn it on and restore it */
   SMGetCalSctFlg(&CurCalFlg);
   if(CurCalFlg != TRUE) SMSetCalSctFlg(1);
   status = om$send(msg = message NDnode.NDs_compute_node(&loc_msg, 0, NULL),
   			targetid = my_id);
   if(CurCalFlg != TRUE) SMSetCalSctFlg(0);
   if(!(status & 1)) return OM_W_ABORT;

   status = om$send(msg = message SMmgr.SMGetState(&state),
 			targetid = my_id);
   if(!(status & 1)) return OM_W_ABORT;
  }

 if(state & SM_CAL_ERR) return OM_W_ABORT;

 inc = 1;  /* Always include .... */

 /* get the struct coef */
 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "struct_coef", 
 						      &struct_coef, NULL),
 			targetid = cmp_id.objid,
 			targetos = cmp_id.osnum);
 as$status(action = RET_STATUS)
 if(!(loc_msg &1)) return OM_W_ABORT;

 /* Get the number of parts */
 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "NbPart", 
 						      &dpipo, NULL),
 			targetid = my_id);
 as$status(action = RET_STATUS)
 if(!(loc_msg &1)) return OM_W_ABORT;
 nb_parts = (int) dpipo;

 /* Get the number of parts */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "axis", 
 						      tpipo, NULL),
 			targetid = my_id);
 as$status(action = RET_STATUS)
 if(!(loc_msg &1)) return OM_W_ABORT;
 if(     tpipo[0] == 'x' || tpipo[0] == 'X') 	axis = 'x';
 else if(tpipo[0] == 'y' || tpipo[0] == 'Y') 	axis = 'y';
 else if(tpipo[0] == 'z' || tpipo[0] == 'Z') 	axis = 'z';
 else return OM_W_ABORT;

 tt_crvs  = 0;
 nb_alloc = 0;
 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   fprintf(p_file, "VOLUME \"\" %d %lf\n", inc, struct_coef);
   fprintf(p_file, "GENERAL \"%c\" %d\n", axis, nb_parts);
   fprintf(p_file, "\n");
 
   for(i=0;i<nb_parts;i++)
    {
     IGRdouble		incr, x1, x2;
     IGRint		nb_crvs;
     IGRchar		tmp_string[81];

     sprintf(tmp_string,"Inc_%d",i);
     status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmp_string, 
 						      &incr, NULL),
 			targetid = my_id);
     as$status(action = RET_STATUS);
     if(!(loc_msg &1)) return OM_W_ABORT;
    
     /* Convert it to output unit */
     SMConvDistIntUnit(incr,  out_units, &incr, OM_Gw_current_OS);

     sprintf(tmp_string,"NbCrv_%d",i);
     status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmp_string, 
 						      &dpipo, NULL),
 			targetid = my_id);
     as$status(action = RET_STATUS);
     if(!(loc_msg &1)) return OM_W_ABORT;
     nb_crvs = (int) dpipo;

     sprintf(tmp_string,"X1_%d",i);
     status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmp_string, 
 						      &x1, NULL),
 			targetid = my_id);
     as$status(action = RET_STATUS);
     if(!(loc_msg &1)) return OM_W_ABORT;
     /* Convert it to output unit */
     SMConvDistIntUnit(x1,  out_units, &x1, OM_Gw_current_OS);
     
     sprintf(tmp_string,"X2_%d",i);
     status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmp_string, 
 						      &x2, NULL),
 			targetid = my_id);
     as$status(action = RET_STATUS);
     if(!(loc_msg &1)) return OM_W_ABORT;
     SMConvDistIntUnit(x2,  out_units, &x2, OM_Gw_current_OS);

     fprintf(p_file, "\tPART %lf %lf %lf %d\n", x1, x2, incr, nb_crvs);
     fprintf(p_file, "\n");
     
     
     for(j=tt_crvs;j<tt_crvs + nb_crvs;j++)
      {
       IGRshort 		mat_type;
       IGRdouble 		mat[16], *PtPts;
       struct IGRpolyline 	polyline;
       IGRboolean		ToFree;
       

       /* Get the curve object */
       sprintf(tmp_string,"curve%d",j);
       status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, 
				tmp_string, &crv_id, &mat_type, mat),
 			targetid = my_id);
       as$status(action = RET_STATUS);
       if(!(loc_msg &1)) return OM_W_ABORT;

       status = om$send(msg = message GRvg.GRgenabsg(&loc_msg, 
			 &mat_type, mat, (IGRchar **) &geom),
 			targetid = crv_id.objid,
 			targetos = crv_id.osnum);
       as$status(action = RET_STATUS);
       if(!(loc_msg &1)) return OM_W_ABORT;

       if(geom->order == 2)
        {
	 nb_pts = geom->num_poles;
	 if(geom->planar != TRUE)
	  {
	   printf("arning, sections are not planar !!!\n");
	  }

         if(geom->rational)
          {
           for(k=0;k<nb_pts;k=k+1)
	    {
	     geom->poles[3*k  ] = geom->poles[3*k  ]/geom->weights[k];
	     geom->poles[3*k+1] = geom->poles[3*k+1]/geom->weights[k];
	     geom->poles[3*k+2] = geom->poles[3*k+2]/geom->weights[k];
	    }
          }
	 ToFree = FALSE;
         PtPts = geom->poles;
	}
       else 
        {
         IGRdouble		tol;
	 IGRlong                sizebuf, nret;
	 IGRint                 coef;

	 /* Sections are not linear, strock them */

	 sizebuf = sizeof(tol);
 	 gr$get_chord_height_tolerance(msg    = &loc_msg,
                               	       sizbuf = &sizebuf,
                               	       buffer = &tol,
                               	       nret   = &nret);

	 /* Update tolerance to number of points */
	 coef = 2 + geom->num_poles / 50;
	 
	 tol = coef * tol;
         ems$stroke_bspline_curve(msg      = &loc_msg, curve    = geom,
	 			 tolerance = tol     , polyline = &polyline);
         if(!(loc_msg & 1))
	  {
	   printf("Error when stocking the bspline curve\n");
           return OM_W_ABORT;
          } 
         nb_pts = polyline.num_points;
	 ToFree = TRUE;
         PtPts = polyline.points;
   	}
       
        
       if(axis == 'x') 
        {
	 x = PtPts[0];
	 y_index = 1; 
	 z_index = 2; 
	}
       else if(axis == 'y') 
        { 
	 x = PtPts[1]; 
	 y_index = 2; 
	 z_index = 0;
	}
       else if(axis == 'z') 
        { 
	 x = PtPts[2]; 
	 y_index = 0; 
	 z_index = 1; 
	}
       SMConvDistIntUnit(x,  out_units, &x, OM_Gw_current_OS);
       fprintf(p_file, "\t\tL_STRING %lf %d\n", x, nb_pts);

       for(k=0;k<nb_pts;k++)
        {
	 y = PtPts[(3*k) + y_index];
	 z = PtPts[(3*k) + z_index];

         SMConvDistIntUnit(y,  out_units, &y, OM_Gw_current_OS);
         SMConvDistIntUnit(z,  out_units, &z, OM_Gw_current_OS);
  	 fprintf(p_file, "\t\t\t%lf %lf\n", y, z);
	}
       if(ToFree) _FREE(polyline.points);
      }
     tt_crvs = j;
     fprintf(p_file, "\n");
    }

   fprintf(p_file, "\n");

  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

end implementation SMsection;
 


