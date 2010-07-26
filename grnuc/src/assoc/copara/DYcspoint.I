/*
    Abstract:  DYrbcspt sets up the "additional information" needed 
               by PDdynamics when dynamically displaying a cs point

     CHANGE HISTORY:

     MA 17-mar-89 : designed

-----*/

class implementation COpara;

#include  "AS_status.h"
#include  "dpdef.h"
#include  "dpmacros.h"
#include  "igrdef.h"
#include  "igr.h"
#include  "dpstruct.h"
#include "OMmacros.h"

#define AS_DEBUG

struct cs_point_header
{
  struct DPele_header *absg;        /* abst. geometry */
};

#argsused
IGRint DYrbcspt( display, md_env )

struct IGRdisplay  *display;
struct GRmd_env     *md_env;
{
  IGRlong 			msg;
  IGRdouble                  	pt_buffer[3];
  IGRboolean 			dyn_on, inquire = 1;
  struct      DPele_header  	header;
  struct      IGRpointset   	pointset;
  struct      cs_point_header 	info_para;

  IGRint DYcspt();

  /*|  If dynamics is off then exit */
  DPdynflags(&msg, &inquire, &dyn_on, NULL);
  if(!dyn_on) return(1);

  pointset.num_points = 1;
  pointset.points = pt_buffer;

  /*
   *  Fill in header information
   */

  dp$build_dis_buffer ( buffer      = &header,
                        type        = IGRPS,   /*   type is point set  */
			display_att = display,
			geometry    = &pointset );

  info_para.absg = &header;

  /*  Invoke dynamics  */

  dp$dynamics( dyn_fun = DYcspt, information = &info_para );

  return ( TRUE );

}

#argsused
IGRint DYcspt( info_para,point,matrix,objects,num_objects,buffer,num_buffers,
               in_dummy1,in_dummy2,in_dummy3,out_dummy1,out_dummy2,out_dummy3 )

struct   cs_point_header    	*info_para;
struct   EX_button       	*point;
IGRdouble                	*matrix;
struct   GRid           	**objects;
IGRint                   	*num_objects;
struct   DPele_header   	**buffer;
IGRint                   	*num_buffers;
IGRchar                 	**in_dummy1;
IGRchar                 	**in_dummy2;
IGRchar                 	**in_dummy3;
IGRchar                 	**out_dummy1;
IGRchar                 	**out_dummy2;
IGRchar                 	**out_dummy3;

{
  info_para->absg->geometry.point_set->points[0] = point->x;
  info_para->absg->geometry.point_set->points[1] = point->y;
  info_para->absg->geometry.point_set->points[2] = point->z;

  *buffer = info_para->absg;
  *num_buffers = 1;

  return(1);

}

end implementation COpara;
