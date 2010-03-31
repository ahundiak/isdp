class implementation Root;
#include "OMmacros.h"
#include "emsmacros.h"
#include "GRtypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "comiscmac.h"
#include "EMSdprquery.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define  SURF_ELEMENT 0
#define  CSURF_ELEMENT 1
#define  CURVE_ELEMENT 2

from IGEgragad  import DPinrot;
from GRvg  import GRgetsize;
from GRvg  import GRgetgeom;
from EMSsurface  import EMgetInfoAboutComponents;

/*
Name
 COmeasget_mindist

Abstract
Measure distance between two objects.

Description
Mesaures the minimum distance between any 2 objects including
solids.

Return Value
returns the minimum distance and the points at which this
minimum distance occurred on the 2 input objects.

Notes
This function can be called using a macro defined in EMSmsdismac.h
in $MODEL/include directory.

History
 03/29/95 : Srividya  : created
*/

/* The macro if used to measure the distance between 2 objects 
 * expands to the following function
 */

IGRint COmeasget_mindist(msg,first_grid,second_grid,mod_env1,
			mod_env2,ev1,ev2,app_flag,point1,point2,mindist )
IGRlong *msg;
struct GRid first_grid,second_grid;
struct GRmd_env *mod_env1,*mod_env2;
struct GRevent *ev1,*ev2;
IGRboolean app_flag;
IGRdouble *point1,*point2;
IGRdouble *mindist;
{
 IGRint type1,type2;
 IGRint status =1;
 struct GRid temp_grid;
 IGRdouble mdist = 0.0;


     *mindist = 0.0;
/* Gets the type of the input objects */
     status = COmeasget_graphics_type(first_grid,&type1);
     if(!(1 & status)) return(1);
     status = COmeasget_graphics_type(second_grid,&type2);
     if(!(1 & status)) return(1);


/* Depending on the type , the corresponding function is called
 * for calculating the min. distance
 */

     if((type1 == SURF_ELEMENT && type2 == CSURF_ELEMENT) || 
	(type1 == CSURF_ELEMENT && type2 == SURF_ELEMENT))
       {
       if(type1 == CSURF_ELEMENT)
         {
         temp_grid = first_grid;
         first_grid = second_grid;
         second_grid = temp_grid;
         }

        status = COmeasget_mindist_sfcomsf(first_grid, second_grid,
					mod_env1,mod_env2, ev1,ev2,
					app_flag,point1,point2,&mdist);
       }
     else

     if(type1 == CSURF_ELEMENT  && type2 == CSURF_ELEMENT)
	status = COmeasget_mindist_comsfcomsf(first_grid, second_grid,
					mod_env1,mod_env2,ev1,ev2,
					app_flag,point1,point2,&mdist);
     else
     if((type1 == CURVE_ELEMENT  && type2 == CSURF_ELEMENT) ||
       (type1 == CSURF_ELEMENT && type2 == CURVE_ELEMENT))
       {
       if(type1 == CSURF_ELEMENT)
         {
         temp_grid = first_grid;
         first_grid = second_grid;
         second_grid = temp_grid;
         }
 

        status = COmeasget_mindist_cvcomsf(first_grid, second_grid,
					mod_env1,mod_env2,ev1,ev2,
					app_flag,point1,point2,&mdist);
       }
       else
	{
/* By default , this function is called for measuring the distance
 */
	status = Measmin_dist(first_grid.objid,first_grid.osnum,
                                  second_grid.objid,
                                  second_grid.osnum,
                                  ev1,ev2,mod_env1,mod_env2,
				  app_flag,point1,point2,&mdist);
	}

       if(status & 1)
       *mindist = mdist;
       else return(0);

return(1);
}

/* If the input objects are surface and a composite curve ,
 * this function gets called
 */
IGRint COmeasget_mindist_sfcomsf(first_grid, second_grid,mod_env1,mod_env2,
                                        ev1,ev2,
					app_flag,point1,point2,mdist)
struct GRid first_grid, second_grid;
struct GRmd_env *mod_env1,*mod_env2;
struct GRevent *ev1,*ev2;
IGRboolean app_flag;
IGRdouble *point1,*point2;
IGRdouble *mdist;
{
	int  no_comp, i,sts;
	double  mindist,dist;
        IGRlong status ,msg;
        struct EMScomponent_info *comp_info;
	IGRdouble pnt1[3],pnt2[3];

   mindist = dist = 0.0;
   
/* get components of comp surface */
       status = om$send(msg = message EMSsurface.EMgetInfoAboutComponents( 
						&msg ,
                        			&no_comp, &comp_info ),
                       senderid = NULL_OBJID,
                       targetid = second_grid.objid,
                       targetos = second_grid.osnum );
 
        if(!(status & 1))
        om$report_error( sts = status);

/* get min dist between the surface and comp surface */
	for( i = 0; i < no_comp; i++)
	{
	    sts = Measmin_dist(first_grid.objid,first_grid.osnum,
				  comp_info[i].surf_id,
				  second_grid.osnum, 
				  ev1,ev2,mod_env1,mod_env2,
				  app_flag,pnt1,pnt2,&dist);
            if(!(sts & 1)) return(0); 

		if( !i  || ( mindist > dist ) ) 
			{
			IGRint ii;
			for(ii = 0; ii < 3; ii++)
                           {
                           point1[ii]=pnt1[ii];
			   point2[ii]=pnt2[ii];
			   }
			 mindist = dist;
			 }
	}
        *mdist = mindist;
	return(1); /* successful completion of get min dist pt compsf */
}

/* If both the input objects are composite curves ,
 * this function gets called
 */
IGRint COmeasget_mindist_comsfcomsf(first_grid, second_grid,mod_env1,mod_env2,
					 ev1,ev2,
					app_flag,point1,point2,mdist)
struct GRid first_grid, second_grid;
struct GRmd_env *mod_env1,*mod_env2;
struct GRevent *ev1,*ev2;
IGRboolean app_flag;
IGRdouble *point1,*point2;
IGRdouble *mdist;
{
	int  no_surf1, no_surf2, i, j, k;
	IGRlong	sts,msg,status;
	double  mindist = 0.0,dist;
        struct EMScomponent_info *comp_info[2];
	IGRdouble pnt1[3],pnt2[3];

        /* get components of comp surface */
       status = om$send(msg = message EMSsurface.EMgetInfoAboutComponents(
                                                &msg ,
                                                &no_surf1, &comp_info[0] ),
                       senderid = NULL_OBJID,
                       targetid = first_grid.objid,
                       targetos = first_grid.osnum );
 
        if(!(status & 1))
        om$report_error( sts = status);

        /* get components of comp surface */
       status = om$send(msg = message EMSsurface.EMgetInfoAboutComponents(
                                                &msg ,
                                                &no_surf2, &comp_info[1] ),
                       senderid = NULL_OBJID,
                       targetid = second_grid.objid,
                       targetos = second_grid.osnum );
 
        if(!(status & 1))
        om$report_error( sts = status);

/* get min dist between the comp surfaces */

	for( i = 0; i < no_surf1; i++)
	{
		for( j=0; j < no_surf2; j++ )
		{
                 sts = Measmin_dist(comp_info[0][i].surf_id, first_grid.osnum,
				comp_info[1][j].surf_id,
                                second_grid.osnum, 
				ev1,ev2,mod_env1,mod_env2,
				  app_flag,pnt1,pnt2,&dist);
                 if(!(sts & 1)) return(0);
 
			if( ( !i && !j )  || ( mindist > dist ) ) 
			{
			IGRint ii;
                        for(ii = 0; ii < 3; ii++)
                           {
                           point1[ii]=pnt1[ii];
                           point2[ii]=pnt2[ii];
                           }
                         mindist = dist;
                         }

		}

	}
	*mdist = mindist;

	return(1); /* successful completion of get min dist compsf's */
}

/* If the input objects are curve and a composite curve ,
 * this function gets called
 */
IGRint COmeasget_mindist_cvcomsf(first_grid, second_grid,mod_env1,mod_env2,
				 ev1,ev2,
					app_flag,point1,point2,mdist)
struct GRid first_grid, second_grid;
struct GRmd_env *mod_env1,*mod_env2;
struct GRevent *ev1,*ev2;
IGRboolean app_flag;
IGRdouble *point1,*point2;
IGRdouble *mdist;
{
	int  no_surf, i, j;
	IGRlong	sts,msg,status;
	double mindist = 0.0,dist;
        struct EMScomponent_info *comp_info;
	IGRdouble pnt1[3],pnt2[3];

        /* get components of comp surface */
       status = om$send(msg = message EMSsurface.EMgetInfoAboutComponents(
                                                &msg ,
                                                &no_surf, &comp_info ),
                       senderid = NULL_OBJID,
                       targetid = second_grid.objid,
                       targetos = second_grid.osnum );
 
        if(!(status & 1))
        om$report_error( sts = status);


/* get min dist between the curve and comp surface */

	for( i = 0; i < no_surf; i++)
	{
		sts = Measmin_dist(first_grid.objid, first_grid.osnum,
                                comp_info[i].surf_id,
                                second_grid.osnum, 
				ev1,ev2,mod_env1,mod_env2,
				  app_flag,pnt1,pnt2,&dist);
                 if(!(sts & 1)) return(0);
 
		if( !i  || ( mindist > dist ) ) 
			{
			IGRint ii;
                        for(ii = 0; ii < 3; ii++)
                           {
                           point1[ii]=pnt1[ii];
                           point2[ii]=pnt2[ii];
                           }
                         mindist = dist;
                         }

	}
        *mdist = mindist;

	return(1); /* successful completion of get min dist pt compsf */
}

/* returns the type of the object to be either a curve or a surface
 * or a composite curve
 */
IGRint COmeasget_graphics_type ( gra_id, type)
struct GRid  gra_id;
IGRint *type;
{
  
	OMuword super_classes[3];
	int typ[3];
	OMuword class_id;
	int status, i;

	extern OMuword OPP_GRcurve_class_id;
	extern OMuword OPP_EMScompsurf_class_id;
	extern OMuword OPP_EMSsurface_class_id;

        *type = -1;
	super_classes[0] = OPP_GRcurve_class_id;
	super_classes[1] = OPP_EMScompsurf_class_id;
	super_classes[2] = OPP_EMSsurface_class_id;

	typ[0] = CURVE_ELEMENT;
	typ[1] = CSURF_ELEMENT;
	typ[2] = SURF_ELEMENT;


/* get the class_id of the graphics */

	status = om$get_classid( objid = gra_id.objid,
				 osnum = gra_id.osnum,
				 p_classid = &class_id );

 		
	if(!(status & 1))
	om$report_error( sts = status);

	for(i=0; i< 3; i++ )
	{
		status = om$is_ancestry_valid( subclassid = class_id,
					superclassid = super_classes[i] );

		if( status == OM_S_SUCCESS )
                  {
 			*type = typ[i];
			break;
                  }
	} 

	return(1); /* Not any one of the types */
}

/* The actual minimum distance is calculated in this function */
IGRint Measmin_dist(objid1,osnum1,objid2,osnum2,ev1,ev2,mod_ev1,mod_ev2,
				  app_flag,pnt1,pnt2,dist)
GRobjid objid1;
OMuword osnum1;
GRobjid objid2;
OMuword osnum2;
struct GRevent *ev1,*ev2;
struct GRmd_env *mod_ev1,*mod_ev2;
IGRboolean app_flag;
IGRdouble *pnt1,*pnt2;
IGRdouble *dist;
{

  struct GRid fgrid,sgrid;
  GRobjid myid = NULL_OBJID;
  IGRlong ret_size,status,msg,size;
  struct GRparms       Parms1,Parms2;
  IGRpoint             pl_pt,point1,point2,approx_pt,dummy_pt;
  IGRvector            view_vector;
  struct IGRline       line;
  extern    IGRboolean    GR2objminline();
  IGRboolean           apparent_flag = FALSE,absolute_flag;
  IGRdouble distance=0.0;
  IGRmatrix rot_matrix;
  IGRint ii;


  fgrid.objid = objid1;
  fgrid.osnum = osnum1;
  sgrid.objid = objid2;
  sgrid.osnum = osnum2;

  line.point1 = point1;
  line.point2 = point2;


  status = co$project_event(msg     =  &msg,
                            event   =  ev1,
                            module  =  mod_ev1,
                            cob_id  =  myid,
                            grid    = &fgrid,
                            parms   = &Parms1,
                            point   =  dummy_pt);
 
  status = co$project_event(msg     =  &msg,
                            event   =  ev2,
                            module  =  mod_ev2,
                            cob_id  =  myid,
                            grid    = &sgrid,
                            parms   = &Parms2,
                            point   =  approx_pt);

  if(app_flag)
  {
      size = sizeof(apparent_flag);
      status = gr$get_apparent_flag(msg = &msg,
                                sizbuf = &size,
                                buffer = &apparent_flag,
                                nret= &ret_size);

      status = COproj_pt_to_view_pl(&msg,
                                      ev1,
                                      pl_pt);
      /* load view vector */
      status = om$send(msg = message IGEgragad.DPinrot(&msg,
                                                       rot_matrix ),
                       senderid = NULL_OBJID,
                       targetid = ev1->event.button.objid,
                       targetos = ev1->event.button.osnum );
 
      view_vector[0] = rot_matrix[8];
      view_vector[1] = rot_matrix[9];
      view_vector[2] = rot_matrix[10];
  }

  size = sizeof(absolute_flag);
  status = gr$get_local_abs_flag(msg = &msg,
                                 sizbuf = &size,
                                 buffer = &absolute_flag,
                                 nret= &ret_size);
 
  /* GR2objminline wants local=TRUE and absolute=FALSE */
  /* This is opposite to the dpb setting */
  absolute_flag = ! absolute_flag;


  status = GR2objminline(&msg,
                         &fgrid,
                         &mod_ev1->md_env,
                         &Parms1,
                         &sgrid,
                         &mod_ev2->md_env,
                         &Parms2,
                         &absolute_flag,
                         &apparent_flag,
                         pl_pt,
                         view_vector,
                         approx_pt,
                         &line);

  status = MA2ptdis(&msg,
                    point1,
                    point2,
                    &distance );

  *dist = distance;
  for(ii = 0; ii < 3 ; ii++)
    {
    pnt1[ii] = point1[ii];
    pnt2[ii] = point2[ii];
    }
  return(status);
}

end implementation Root;
