/* $Id: SMOrie.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMOrie.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMOrie.I,v $
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

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igewindow.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "ex.h"

#include "AS_status.h"

#define AS_DEBUG

/* -------------------------------------------------------------------------------- */

struct SMorient_params 
{
  struct DPele_header   header[2];
  IGRdouble		*Origin;
  IGRdouble		*Zvect;
  IGRdouble		*tg_vect;
  IGRint		normal_flag;
};

IGRint SMoridyn( SMinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                    dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                    dummy_out3 )

struct 		SMorient_params	*SMinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;
/*.SMoridyn */
{
  IGRint			i;
  IGRlong			status;
  IGRdouble			view_scale, arrow_xsize, arrow_ysize, vect_size;
  IGRlong 			which_error, bytes_returned, retcode;
  struct 	win_var_list	var_list[2]; 	

  status  = OM_S_SUCCESS;

  /* -- Get view_scale to have always the same orientation Tee -- */
  var_list[0].var            = VVOL_VIEWPORT_SCALE;
  var_list[0].var_ptr        = ( char *) &view_scale;  
  var_list[0].num_bytes      = sizeof( IGRdouble );
  var_list[0].bytes_returned = &bytes_returned;
  var_list[1].var = END_PARAM;

  status = dp$inq_set_gragad( msg          = &retcode,
			      osnum        = point->osnum,
			      gragad_objid = point->objid,
			      which_error  = &which_error,
			      var_list     = var_list );
  as$status( action = RET_STATUS );

  vect_size   = 40 / view_scale;
  arrow_xsize =  2 / view_scale;
  arrow_ysize =  8 / view_scale;

  /* -- Initialise Tee display -- */
  for ( i=0; i<3; i++)
  {
	SMinfo->header[0].geometry.polyline->points[i]   = SMinfo->Origin[i];
	SMinfo->header[0].geometry.polyline->points[i+3] = SMinfo->Origin[i] + vect_size * SMinfo->normal_flag * SMinfo->Zvect[i];
	SMinfo->header[1].geometry.polyline->points[i]   = SMinfo->header[0].geometry.polyline->points[i+3] - arrow_xsize * SMinfo->tg_vect[i];
	SMinfo->header[1].geometry.polyline->points[i+3] = SMinfo->header[0].geometry.polyline->points[i+3] + arrow_xsize * SMinfo->tg_vect[i];
	SMinfo->header[1].geometry.polyline->points[i+6] = SMinfo->header[0].geometry.polyline->points[i+3] + arrow_ysize * SMinfo->normal_flag * SMinfo->Zvect[i];
	SMinfo->header[1].geometry.polyline->points[i+9] = SMinfo->header[0].geometry.polyline->points[i+3] - arrow_xsize * SMinfo->tg_vect[i];
   }

  *buffers = SMinfo->header;
  *num_buffers = 2;

  return(TRUE);

}

/* ----------------------------------------------------------------------------------- */

SMorient( Origin, Zvect, tg_vect, normal_flag, display )

IGRdouble		*Origin;
IGRdouble		*Zvect;
IGRdouble		*tg_vect;
IGRint			normal_flag;
struct 	IGRdisplay      *display;

/*.SMorient */
{
  struct	SMorient_params		SMinfo;
  IGRdouble                  		pt_buffer[6]; /* polyline end points  */
  IGRdouble                  		pt_buffer1[12];
  struct       	IGRpolyline     	polyline;     /* polyline geometry    */
  struct       	IGRpolyline     	polyline1;   
  struct 	IGRdisplay      	Display;      /* Active symbologies   */

  SMinfo.Origin       = Origin;
  SMinfo.Zvect        = Zvect;
  SMinfo.tg_vect      = tg_vect;
  SMinfo.normal_flag  = normal_flag;

  Display             = *display;
  Display.weight      = 2;

  polyline.num_points = 2;
  polyline.points     = pt_buffer;

  polyline1.num_points = 4;
  polyline1.points     = pt_buffer1;

  dp$build_dis_buffer(	buffer      = &SMinfo.header[0],
		  	type        = IGRPY,
		  	display_att = &Display,
		  	geometry    = ( struct IGRpolyline *) &polyline );

  dp$build_dis_buffer(	buffer      = &SMinfo.header[1],
		  	type        = IGRPY,
		  	display_att = &Display,
		  	geometry    = ( struct IGRpolyline *) &polyline1 );

  dp$dynamics( 	dyn_fun     = SMoridyn,
       		information = &SMinfo );

  return OM_S_SUCCESS;

}

end implementation Root;
