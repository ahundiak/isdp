/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRls2pt_rtr
 
     Abstract: This routine takes a list of events defining the two
	      points of a line to be created, preprocesses the data
	      and routes the input to the appropriate math function
	      to find the line.
-----
%SC%

    VALUE = GRls2pt_rtr(msg,events,num_events,out_geom)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRrt_event	 array of point events
     num_events   IGRshort       number of events
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				    - MSINARG if too many events for
				 this router.
				    - GRILLDEFINITION if illegal 
				 definition for placing line
				    - GRNOTIMPLEMENTED if the input
				 events map to a function which has
				 not been implemented yet.

     out_geom     IGRbsp_curve   output line

     VALUE () = TRUE  - line found
		FALSE - no line found

-----
%MD%

     MODULES INVOKED:
			 GRsort_events
			 MAltfrbc
			 MAptbcproj
			 MAuvcnrbc
			 MAaddvc
			 MA3protmx
			 MAtrnmx
			 MAlpfrbc
			 MA2pttobc
			 MAlt2bc
			 MAultbcabc
			 MAulpbcabc
			 MAulabcabc
			 MAlatobc
			 MAptlnproj
			 MAptplproj
			 MAlptobcpt
			 MAltbcpbc
			 MAlp2bc
			 MAlalnfpt
			 MAbcrevparm
			 GOlpfrbs
-----
%NB%

     NOTES:

-----

%CH%
     CHANGE HISTORY:
	
	RDH     03/05/86 : Design date.
	RDH     03/05/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

 This routine determines which events have occurred and preprocesses
input which is TANGENT FROM or PERPENDICULAR FROM. This preprocessing
entails getting the tangent or normal vector at the input point on
the geometry the line is to be TANGENT/PERPENICULAR from and 
setting the event_type flag for the event to be VC or PL depending
on whether the geometry type is a CURVE or SURFACE. If the geometry
is a surface and we have TANGENT FROM, the returned tangent vector
is actually the normal vector of the tangent plane at the input 
point, thus we set the event_type for this event to PL. Otherwise,
if the geometry is not a surface or the event type is not TANGENT
FROM, we get the tangent or normal vector to the geometry at the
input point and set the event_type to VC.
 If the event type is not TANGENT FROM or PERPENDICULAR FROM, we
set event_type to the event subtype, get the geometry and geometry
type and size. Then we allocate stack storage and copy the geometry
into the storage.
 The next step in the routine is to find an array of permuted indices
which indicate the order in which event data is to be supplied to
the called math routine. Then we build the polynomial which forces
the switch to switch to the correct case. This polynomial is a 
number in the system whose base is 2 * TOTAL converted to the base
10 number system. This guarantees that the map to the case is
unique.
 Finally, the routine switches on the value of the above polynomial
to route the input data to the appropriate math routine. If the 
polynomial does not match one of the cases, the default case will 
set the return code to GRILLDEFINITION and the routine fails.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "grrouterpriv.h"
#include "ex.h"
#include "grio.h"
#include "grerr.h"
#include "bserr.h"

#define GRPL GRrt_TOTAL+1
#define GRVC GRrt_TOTAL+2
#define GRLS_TOTAL GRrt_TOTAL+2


IGRboolean GRls2pt_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		     */
	   struct GRrtevent    *events;     /* array of events 		     */
           IGRshort            *num_events; /* number of events              */
	   struct IGRbsp_curve *out_geom;   /* output line                   */

{
  struct IGRbsp_curve bc_ln;		    /* B-spline line		     */
  struct IGRline  ln;			    /* line to project onto	     */
  struct IGRplane pl;      		    /* tangent plane to surface      */

  IGRpoint pjpt;			    /* project point		     */
  IGRpoint sol_pt;
  
  IGRvector vc;				    /* tangent/normal vector         */

  IGRmatrix mat;			    /* coordinate system transform   */

  IGRdouble sol_upars[2];		    /* solution parameters	     */
  IGRdouble poles[6];			    /* poles for bc_ln		     */
  IGRdouble knots[4];			    /* knots for bc_ln		     */
  IGRdouble tol;			    /* project tolerance	     */
  IGRdouble t;				    /* t parameter of pjpt	     */
  IGRdouble u;				    /* u parameter of pjpt	     */
  IGRdouble deg_angle;

  IGRlong poly;                             /* evaluated polynomial          */
  IGRlong base;				    /* base of the polynomial        */
  IGRlong power;			    /* base to the power of i        */
  IGRlong n;				    /* index			     */
  IGRlong mess;				    /* return code		     */

  IGRshort coef;
  IGRshort order[GRMAX_LS_EVENTS];          /* order of events               */
  IGRshort event_types[GRMAX_LS_EVENTS];    /* event subtypes                */
  IGRshort ordered_types[GRMAX_LS_EVENTS];  /* ordered event subtypes	     */
  IGRshort total;			    /* total number of subtypes	     */
  IGRshort dim;				    /* dimension of mat		     */
  IGRint i;                               /* indexes                       */

  IGRboolean revparm;			    /* reverse parameterization flag */
  extern IGRboolean GRsort_events();
  extern IGRboolean MAltfrbc();
  extern IGRboolean MAptbcproj();
  extern IGRboolean MAuvcnrbc();
  extern IGRboolean MAaddvc();
  extern IGRboolean MA3protmx();
  extern IGRboolean MAtrnmx();
  extern IGRboolean MAlpfrbc();
  extern IGRboolean MA2pttobc();
  extern IGRboolean MAptlnproj();
  extern IGRboolean MAptplproj();
  extern IGRboolean MAlalnfpt();
  extern IGRboolean MAultbcabc();
  extern IGRboolean MAulpbcabc();
  extern IGRboolean MAulabcabc();
  extern IGRboolean MAbcrevparm();
  extern IGRboolean BSlnpttncv();
  extern IGRboolean BSlntn2cvs();
  extern IGRboolean BSnorcvpt();
  extern IGRboolean BSlntncvncv();
  extern IGRboolean BSlnn2cvs();
  extern void       BSlnangptcv();

#ifndef IDRAW
extern    IGRboolean    GOlpfrbs();
#endif

  *msg = MSSUCC;

  bc_ln.poles = poles;			     /* init bc_ln		     */
  bc_ln.knots = knots;
  ln.point1 = poles;			     /* init line		     */
  ln.point2 = &poles[3];

  if( *num_events <= GRMAX_LS_EVENTS )    
    {
      for(i=0; i < *num_events && *msg  == MSSUCC; ++i)/* Process the events */
         {  
           if( events[i].subtype == GRREG )
             {
	       event_types[i] = GRREG;
             }
	   else
	     {
	       if( events[i].subtype == GRTF || events[i].subtype == GRAF )
		 {
		   /* get the tangent to the geometry at the event[i].pt     */

                   if( events[i].props[0].type ==  GRSURFACE ) /* we have a  */
							       /* surface    */
		     {
		       *msg = MSFAIL;
#ifndef IDRAW
		       GOlpfrbs(msg,events[i].geoms[0],events[i].pt,
				&events[i].objs[0].parms.u,
				&events[i].objs[0].parms.v,&bc_ln);

		       MAsubvc(&mess,&poles[3],&poles[0],vc);

		       pl.point = events[i].pt;
		       pl.normal = vc;

		       event_types[i] = GRPL;
#endif /* IDRAW */
		     }
		   else				  /* we have a curve	     */
		     {
		       MAltfrbc(msg,events[i].geoms[0],events[i].pt,&bc_ln);

		       if( events[i].subtype == GRTF )
			 {
			   event_types[i] = GRVC; 
			 }
		       else			  /* angle from curve	     */
			 {
			   tol = 0.05;
			   if( MAptbcproj(msg,events[i].pt,events[i].geoms[0],
					  &tol,pjpt,&u) )
			     {
			       if( MAuvcnrbc(msg,events[i].geoms[0],&u,
					     events[0].vc,vc) )
				 {
				   MAaddvc(&mess,events[i].pt,vc,vc);

				   if( MA3protmx(msg,ln.point1,ln.point2,vc,
						 mat) )
				     {
					dim = 4;
					MAtrnmx(&mess,&dim,mat,mat);
				   
			       		event_types[i] = GRAF;
				     }
				 }
			      }
			 }
		     }
		 }
	       else
		 {
		   if( events[i].subtype == GRPF )
		     {
		       if( events[i].props[0].type == GRSURFACE )
			 {
			   *msg = MSFAIL;
#ifndef IDRAW
			   GOlpfrbs(msg,events[i].geoms[0],events[i].pt,
				    &events[i].objs[0].parms.u,
				    &events[i].objs[0].parms.v,&bc_ln);
#endif /* IDRAW */
			 }
		       else
			 {
			   MAlpfrbc(msg,events[i].geoms[0],events[i].pt,
				    events[0].vc,&bc_ln);
			 }

		       event_types[i] = GRVC;
		     }
		   else
		     {
		       event_types[i] = events[i].subtype;
#ifndef IDRAW
	       	       if( events[i].props[0].type == GRSURFACE )
					    /* add offset to differentiate   */
		         {		    /* between surface and other     */
		           event_types[i] += GRrt_TOTAL; /* geometry         */
		         }
#endif /* IDRAW */

                     }
                 }
             }
         }

      if( *msg & 1 )
	{
          total = GRLS_TOTAL;		    /* sort the events		     */

          GRsort_events(&mess,event_types,num_events,&total,ordered_types,
			order);

          poly = 0;
          power = 1;
          base  = 2 * GRrt_TOTAL;
          n = *num_events - 1;		    /* build the polynomial          */

          for(i=0; i < *num_events; ++i)
	  {
	    coef = ordered_types[n - i];

            poly += coef * power;

            power *= base;
	  }	   

          revparm = FALSE;

          switch ( poly )                   /* Branch on the value of        */
          {	  		    	    /* the polynomial.               */
            case LABEL2(GRREG,GRREG):
            {
              MA2pttobc(msg,events[ order[0] ].pt,events[ order[1] ].pt,
			out_geom); 

	      break;
            }

            case LABEL2(GRREG,CURVE(GRTT)):
            {
	      BSlnpttncv(&mess,events[ order[1] ].geoms[0],events[ order[1] ].pt,
			 events[ order[0] ].pt,out_geom,sol_upars);
			   
	      if( mess == BSSUCC )
	      {
	        if( order[1] )
	        {
	           revparm = TRUE;
	        }
	      }
	      else
	      {
	      	*msg = MSFAIL;
	      }
	      
	      break;
            }

            case LABEL2(CURVE(GRTT),CURVE(GRTT)):
            {					/* order is fixed here	     */
	      BSlntn2cvs(&mess,events[0].geoms[0],events[1].geoms[0],
                         events[0].pt,events[1].pt,out_geom,
		         &sol_upars[0],&sol_upars[1]);

              if( mess != BSSUCC )
              {
                *msg = MSFAIL;
              }
              
	      break;
            }
#ifndef IDRAW
            case LABEL2(GRREG,SURFACE(GRTT)):
            {
	      *msg = GRNOTIMPLEMENTED;

	      break;
            }
#endif /* IDRAW */

            case LABEL2(GRREG,GRVC):		/*tangent and perp from curve*/
            {					/* and perp from surface     */
	      MAptlnproj(&mess,events[ order[0] ].pt,&ln,pjpt,&t);

	      MA2pttobc(msg,pjpt,events[ order[1] ].pt,out_geom);

	      if( order[0] )
	      {
	        revparm = TRUE;
	      }

	      break;
            }

	    case LABEL2(GRREG,GRPL):
	    {
 	      MAptplproj(msg,events[ order[0] ].pt,&pl,pjpt);

	      MA2pttobc(msg,pjpt,events[ order[1] ].pt,out_geom);

	      if( order[0] )
	      {
	        revparm = TRUE;
	      }

	       break;
	    }

            case LABEL2(GRREG,CURVE(GRPT)):
            {
              BSnorcvpt(&mess,events[ order[1] ].geoms[0],events[ order[0] ].pt,
                        events[ order[1] ].pt,out_geom);

              if( mess == BSSUCC )
              {
	        if( order[1] )
	        {
	          revparm = TRUE;
	        }
	      }
              else
              {
                *msg = MSFAIL;
              }
              
	      break;
            }

#ifndef IDRAW
            case LABEL2(GRREG,SURFACE(GRPT)):
            {

	      GOlptobs(msg,events[ order[1] ].geoms[0],events[ order[0] ].pt,
		       &events[ order[1] ].objs[0].parms.u,
		       &events[ order[1] ].objs[0].parms.v,&sol_upars[0],
		       &sol_upars[1],out_geom);

	      if( order[0] )
	      {
		revparm = TRUE;
	      }

	      break;
            }
#endif /* IDRAW */

            case LABEL2(CURVE(GRTT),CURVE(GRPT)):
            {
	      BSlntncvncv(&mess,events[ order[0] ].geoms[0],
	      		  events[ order[1] ].geoms[0],events[ order[0] ].pt,
	      		  events[ order[1] ].pt,out_geom,&sol_upars[0],
	      		  &sol_upars[1]);
	      		  
	      if( mess == BSSUCC )
	      {
	        if( order[0] )
	        {
	          revparm = TRUE;
	        }
	      }
	      else
	      {
	      	*msg = MSFAIL;
	      }

	      break;
            }

	    case LABEL2(CURVE(GRPT),CURVE(GRPT)):
	    {
	      BSlnn2cvs(&mess,events[0].geoms[0],events[1].geoms[0],
	      		  events[0].pt,events[1].pt,out_geom,&sol_upars[0],
	      		  &sol_upars[1]);
	
	      if( mess != BSSUCC )
	      {
	      	*msg = MSFAIL;
	      }
	      
	      break;
	    }

	    case LABEL2(GRREG,CURVE(GRAT)):
	    {
	      MAraddeg(msg,&events[ order[1] ].val[0],&deg_angle);
	      
	      BSlnangptcv(events[ order[1] ].geoms[0],events[ order[1] ].pt,
	      		  events[ order[0] ].pt,deg_angle,sol_upars,sol_pt,
	      		  out_geom,&mess);

	      if( mess == BSSUCC )
	      {
	        if( order[1])
	        {
		  revparm = TRUE;
	        }
	      }
	      else
	      {
	      	*msg = MSFAIL;
	      }

	      break;
	    }

	    case LABEL2(GRREG,CURVE(GRAF)):
	    {
	      MAlalnfpt(msg,&ln,events[ order[1] ].pt,events[ order[0] ].pt,
			&events[ order[1] ].val[0],mat,out_geom);

	      break;
	    }

	    case LABEL2(CURVE(GRAF),GRVL):
	    {
	      *msg = GRNOTIMPLEMENTED;

	      break;
	    }

	    case LABEL2(CURVE(GRAT),CURVE(GRTT)):
	    {
	      MAultbcabc(msg,events[ order[1] ].geoms[0],
			 events[ order[0] ].geoms[0],
			 &events[ order[1] ].objs[0].parms.u,
			 &events[ order[0] ].objs[0].parms.u,
			 &events[ order[0] ].val[0],&sol_upars[0],
			 &sol_upars[1],out_geom);

	      if( order[0] )
	      {
		revparm = TRUE;
	      }

	      break;
	    }

	    case LABEL2(CURVE(GRAT),CURVE(GRPT)):
	    {
	      MAulpbcabc(msg,events[ order[1] ].geoms[0],
			 events[ order[0] ].geoms[0],
			 &events[ order[1] ].objs[0].parms.u,
			 &events[ order[0] ].objs[0].parms.u,
			 &events[ order[0] ].val[0],&sol_upars[0],
			 &sol_upars[1],out_geom);

	      if( order[0] )
	      {
		revparm = TRUE;
	      }

	      break;
	    }

	    case LABEL2(CURVE(GRAT),CURVE(GRAT)):
	    {
	      MAulabcabc(msg,events[0].geoms[0],events[1].geoms[0],
			 &events[0].objs[0].parms.u,&events[1].objs[0].parms.u,
			 &events[0].val[0],&events[1].val[0],&sol_upars[0],
			 &sol_upars[1],out_geom);

	      if( order[0] )
	      {
		revparm = TRUE;
	      }

	      break;
	    }

            default:
            {
              *msg = GRILLDEFINITION; 

	      break;  
            }

          }/* END OF SWITCH */
        }  
    } 
  else
    {
      *msg = MSINARG;			    /* Too many events for line	*/
    }

  if( *msg == MSSUCC  &&  revparm == TRUE )
    {
      MAbcrevparm(msg,out_geom,out_geom);
    }

  return( *msg & 1 );

}/* This has been an R.D.H., S.D.G. production!!! */
