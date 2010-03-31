/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  GRsubbc
     METHOD NAME:  EMblnd2cvs

     Abstract: 
-----
%SC%    

     message GRsubbc.EMblnd2cvs (&msg, &env1, &env2, crv1_GRid,
                                  crv2_GRid, u_crv1, u_crv2, dpt_crv1,
                                  dpt_crv2, &construct_list)

     The command object needs to construct an empty object of class
     GRbcsubbc and send it an EMblnd2cvs message with the
     appropriate arguments.

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

 *env1		struct GRmd_env	 Module environment information for
				 getting the abstract geometry 
                                 associated with curve object with
                                 GRid crv1_GRid.

 *env2          struct GRmd_env	 Module environment information for
                                 getting the abstract geometry
                                 associated with curve object with
                                 GRid crv2_GRid.

 crv1_GRid	struct GRid	 object id and the object space number
				 of curve object 1

 crv2_GRid	struct GRid 	 object id and the object space number
				 of curve object 2

 u_crv1		IGRdouble	 u parameter of the point on curve 1
				 from where the blend starts

 u_crv2		IGRdouble	 u parameter of the point on curve 2
				 where the blend ends.

 dpt_crv1	IGRpoint	 direction of blend from curve1

 dpt_crv2	IGRpoint	 direction of blend from curve2

 *construct_list struct          construction information for the blend
 		 GRvg_construct  curve object

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				 
				 Possible completion codes:

				 MSSUCC  -  if the method was
				 	    successful in determining the
					    blend curve stucture and in
					    updating the instance data of
					    the object

				 MSFAIL  -  if the method was unsuccessful
					    in determining the blend curve
					    structure. OM_S_SUCCESS is
					    returned if there was only a 
					    failure in the math routine 
					    
				 MSINARG -  if invalid direction points
					    This happens when the direction
					    point is within dist_tol of the
					    point on the curve.
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
     
     BSblend_cv		- 	The math routine which performs the
				blend 

     OM_send_foreign	-	An OM routine which sends a message to
				an object given the object id and the
				object space number

     OM_send_object	-	An OM routine which sends a message to an
				object given the object id

     Methods: 

     GRgetsize		- 	Returns the size of the abstract geometry
				of an object

     GRgetgeom		- 	Returns the pointer to the abstract geometry
				of the object

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

An OM return code of OM_S_SUCCESS is returned if all OM routines called
in the method were successful and there were no memory allocation
problems. If the latter was true a return status of OM_E_ABORT is
returned.

-----
%CH%

     CHANGE HISTORY:
	
	PP		10/15/86 : design date
        rlw             02/11/88 : Use incoming element specific
    Sudha  06/16/93     Modified for BSprototype ansification
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method determines the blend curve between two curve objects starting
from u_crv1 on curve 1 and ending at u_crv2 on curve 2.

Alogirthm:

1) Get the abstract geometry of the two curve objects.

2) Invoke BSblend_cv to determine the structure of the blend curve.

3) If successful 
   a) Assign the class_attr, geometry and newflag fields of the 
      construct list.
   b) Send a message to GRconstruct with the construct list as its
      argument

   else
 
   a) Assign the completion code appropriately.

4) Perform clean up operations.
----*/
/*EH*/

class implementation GRsubbc;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
#include "OMerrordef.h"   /* OM error definitions */
#include "msmacros.h"           
#include "emsmacros.h"

/* igr.h replacement */

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
/*#include "grdef.h"*/
#include "bserr.h"
#include "bsblend_cv.h"

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#define BLND_CRV_NO_POLES 4
#define BLND_CRV_NO_KNOTS 8



method EMblnd2cvs ( IGRlong *msg;
                     struct GRmd_env *env1;
		     struct GRmd_env *env2;
		     struct GRid crv1_GRid;
		     struct GRid crv2_GRid;
		     IGRdouble u_crv1;
		     IGRdouble u_crv2;
		     IGRpoint dpt_crv1;
 		     IGRpoint dpt_crv2;
		     struct GRvg_construct *construct_list;)

{

  IGRlong	status;			/* OM return status */
  IGRlong	rc;			/* BS return code */
  IGRlong	num_bytes;		/* used for allocation of memory
					   purposes */
  
  IGRdouble	knots[BLND_CRV_NO_KNOTS];
					/* the knots array of the blend
					   curve */

  IGRpoint      poles[BLND_CRV_NO_POLES]; 
					/* the poles array of the blend
					   curve */
  
  struct	IGRbsp_curve  *crv1;    /* pointer to the abstract geometry
					   of curve object 1 */
  struct	IGRbsp_curve  *crv2;    /* pointer to the abstract geometry
					   of curve object 2 */
  struct	IGRbsp_curve  blndcrv;  /* structure storing the geometry of
					   the blend curve */

/* ****************

   Initialisation

   **************** */

  *msg = BSSUCC;
  status = OM_S_SUCCESS;
  crv1 = NULL;
  crv2 = NULL;
  blndcrv.poles = poles[0];
  blndcrv.knots = knots;
  blndcrv.bdrys = NULL; 
  blndcrv.weights = NULL;
  blndcrv.rational = FALSE;
  blndcrv.num_boundaries = 0;


/* *****************

   Get the abstract geometry of the two curve objects

   ***************** */

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize ( msg,
                            &env1->md_env.matrix_type, 
			    env1->md_env.matrix, &num_bytes ),
                   senderid = my_id,
                   targetid = crv1_GRid.objid,
                   targetos = crv1_GRid.osnum);
  EMomerr_hndlr(status, wrapup, "EMblnd2cvs : GRgetsize error");

  crv1 = (struct IGRbsp_curve *)malloc(num_bytes);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom ( msg,
			    &env1->md_env.matrix_type, 
			    env1->md_env.matrix, (IGRchar *)crv1),
                   senderid = my_id,
                   targetid = crv1_GRid.objid,
                   targetos = crv1_GRid.osnum);
  EMomerr_hndlr(status, wrapup, "EMblnd2cvs :GRgetgeom error");

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize ( msg,
                            &env2->md_env.matrix_type, 
			    env2->md_env.matrix, &num_bytes ),
                   senderid = my_id,
                   targetid = crv2_GRid.objid,
                   targetos = crv2_GRid.osnum);
  EMomerr_hndlr(status, wrapup, "EMblnd2cvs : GRgetsize error");

  crv2 = (struct IGRbsp_curve *)malloc(num_bytes);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom ( msg,
			    &env2->md_env.matrix_type, 
			    env2->md_env.matrix, (IGRchar *)crv2),
                   senderid = my_id,
                   targetid = crv2_GRid.objid,
                   targetos = crv2_GRid.osnum);
  EMomerr_hndlr(status, wrapup, "EMblnd2cvs :GRgetgeom error");


/* ************

   Invocation of the math routine to determine the blend curve structure

   ************ */

  (void) BSblend_cv(crv1, crv2, u_crv1, u_crv2, dpt_crv1, dpt_crv2,
                       &blndcrv, &rc);
  if (rc == BSSUCC) /* if successful in determining the blend curve
			 structure */
    {
				  /* Initialisation of class specific
				     attributes of GRbcsubbc class */

        construct_list->geometry = (IGRchar *) &blndcrv;
        construct_list->newflag = FALSE;




                                  /* Send a message to GRconstruct */


	status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRconstruct(
		 construct_list),
                         senderid = my_id,
                         targetid = my_id);
        EMomerr_hndlr(status, wrapup, "EMblnd2cvs : GRconstruct error");

        *msg = MSSUCC;
       }
      else /* if unsuccessful in determining the blend curve structure */
       {
         *msg = MSFAIL;
         if (rc == BSINARG) *msg = MSINARG; /* if invalid direction points */
      
       }

 
/* 	Deallocate memory 	*/

wrapup:  /* should always succeed here */

   if ((*msg != MSSUCC) || (!status))
    {
      status = om$send(mode = OM_e_wrt_object,
                       msg = message Root.delete(1),
                       senderid = my_id,
                       targetid = my_id);
      if (!status) status = OM_E_ABORT;
    }
   if (crv1) free(crv1);
   if (crv2) free(crv2);
   return(status);
}

end implementation GRsubbc;

  
  
