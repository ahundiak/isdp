/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  GRsubbc  
     METHOD NAME:  EMprb2crvs

     Abstract: 
-----
%SC%    

     message GRsubbc.EMprb2crvs (&msg, &env1, &env2, crv1_GRid, crv2_GRid,
                                 param1, param2, &construct_list);

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

  *env1 	struct GRmd_env	 environment information necessary for
                                 getting the abstract geometry of the
                                 curve object 1.

  *env2 	struct GRmd_env	 environment information necessary for
                                 getting the abstract geometry of the
                                 curve object 2.

  crv1_GRid 	struct GRid	 object id and object space number of
                                 curve object 1.

  crv2_GRid	struct GRid	 object id and object space number of
				 curve object 2.

  param1	IGRdouble	 pointer to parameter of point on the
                                 first curve

  param2	IGRdouble	 pointer to parameter of point on the
                                 second curve.

  *construct_list                construct list for the new curve object
                struct           tangent to the two bspline curves
                GRvg_construct   
-----
%EX%
     ON EXIT:
        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
     
   Possible completion codes are:
   
      	MSSUCC		if the method was successful in doing its intended
                        task.

 	MSFAIL		if the method was not successful in determining
                        the parabola tangent to two curves or if it could
                        not allocate enough memory space for the curve 
                        structure.

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
 
     BSalloccv	     	-	allocation of memory for the curve structure
                                when given the order, no of poles, no of
                                boundaries etc.

     BSfreecv           -       deallocating the memory associated with
                                the curve structure
      
     BSparab3           -       routine which computes the parabola tangent
                                to two the two curves.
 
     OM_send_foreign    -       an OM routine which sends messages to an
                                object when given the message name, objid and
                                object space number.

     OM_send_object     -       an OM routine which sends messages to an
                                object in the same object space in which the
                                current object is residing.

     Methods:  

     GRgetsize          -       for getting the size of the abstract 
                                geometry associated with the curve objects

     GRgetgeom          -       for getting a pointer to the abstract geometry

     GRconstruct        -       for updating the instance data of the
                                curve object. 

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%
     

-----
%CH%

     CHANGE HISTORY:
	
     PP : 10/17/86        design date
    Sudha  06/16/93     Modified for BSprototype ansification

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method determines the parabola tangent to two curves and updates
the instance data of the curve object if it was successful. A curve
object of class GRbcsubbc needs to be constructed and  a message needs
to be send to that curve object with the appropriate arguments. The class
specific attributes of the construct list are currently being initialised
in the method. A rough description of the algorithm is as follows :

1) Get the abstract geometries of the two curve objects.

2) Allocate the necessary memory for the parabola curve structure. The
   math routine specifies that the curve order be 3, no of poles be 3
   and no of boundaries is assumed to be 0.

3) Invoke BSalloccv for determining the parabola.

4) If successful in determining the parabola:
  
   a) Initialise the class specific attributes of the construct
      list.
   b) Assign the newflag and the geometry fields of the construct list
   c) Send a GRconstruct message to the curve object.

5) Deallocate memory.
      

----*/
/*EH*/

class implementation GRsubbc;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
#include "OMerrordef.h"
#include "OMstackalloc.h"
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
#include "bsparab3.h"

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0
#endif

#define PERROR(rc,sts,label,error_message) \
 {\
  sts = OM_E_ABORT; \
  rc = MSFAIL;\
  goto label; \
 }

method EMprb2crvs (IGRlong *msg;
		   struct GRmd_env *env1;
		   struct GRmd_env *env2;
		   struct GRid crv1_GRid;
		   struct GRid crv2_GRid;
		   IGRdouble param1;
		   IGRdouble param2;
		   struct GRvg_construct *construct_list)

{
 IGRlong	status;                  /* OM return status */
 IGRlong	sts;                     /* OM return status */
 IGRlong	rc;                      /* completion code */
 IGRlong	num_bytes;               /* for memory allocation */

 struct		IGRbsp_curve *crv1;      /* pointer to the abstract geometry
					    associated with the curve object
                                            1 */
 struct		IGRbsp_curve *crv2;      /* pointer to the abstract geometry
                                            associated with the curve object
					    2 */
 struct		IGRbsp_curve parabola;  /*  parabola  structure */
 IGRpoint poles[3];                 /* parabola poles */
 IGRdouble knots[6];                /* parabola knots */
 struct		IGResbc eleonly;         /* structure for defining the 
				            class_attr field of the
                                            construct list */ 
                                            

/* Initialisation */

 status = OM_S_SUCCESS;
 *msg = MSSUCC;
 parabola.poles = poles[0];
 parabola.knots = knots;
 parabola.rational = FALSE;
 parabola.num_boundaries = 0;

/* *******************
   
   get the abstract geometry of curve object 1 

   ******************* */


 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize (
                          msg, &env1->md_env.matrix_type , 
			  env1->md_env.matrix, &num_bytes),
                  senderid = my_id,
                  targetid = crv1_GRid.objid,
                  targetos = crv1_GRid.osnum);
 EMomerr_hndlr(status,wrapup,"EMprb2crvs: Error GRgetsize");

 crv1 = (struct IGRbsp_curve *)OM_stack_alloc(num_bytes);

 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom (
                         msg, &env1->md_env.matrix_type , 
			 env1->md_env.matrix, (IGRchar *)crv1),
                  senderid = my_id,
                  targetid = crv1_GRid.objid,
                  targetos = crv1_GRid.osnum);
 EMomerr_hndlr(status, wrapup,"EMprb2crvs: Error GRgetgeom");

/* *********************

   get the abstract geometry of the curve object 2 

   ********************* */

 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize (
                          msg, &env2->md_env.matrix_type , 
		 	  env2->md_env.matrix, &num_bytes),
                  senderid = my_id,
                  targetid = crv2_GRid.objid,
                  targetos = crv2_GRid.osnum);
 EMomerr_hndlr(status,wrapup,"EMprb2crvs: Error GRgetsize");

 crv2 = (struct IGRbsp_curve *)OM_stack_alloc(num_bytes);

 status = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom (
                         msg, &env2->md_env.matrix_type , 
			 env2->md_env.matrix, (IGRchar *)crv2),
                  senderid = my_id,
                  targetid = crv2_GRid.objid,
                  targetos = crv2_GRid.osnum);
 EMomerr_hndlr(status, wrapup,"EMprb2crvs: Error GRgetgeom");

/* ****************

   Call the math routine to determine the parabola tangent to two
   curves
   
   ****************  */

   status = BSparab3 (msg, crv1, crv2, &param1, &param2, &parabola);

   if (BSOKAY (*msg)) /* if successful in determining the parabola */
    {

/* ****************

   Assign the class_attr, newflag and geometry fields of the
   construct list associated with the curve structure and send
   a GRconstruct message.   

   **************** */

      eleonly.is_curvedis = TRUE;
      eleonly.is_polydis = FALSE;
      construct_list->class_attr = (IGRchar *)&eleonly;
      construct_list->geometry = (IGRchar *) &parabola;
      construct_list->newflag = FALSE;

      status = om$send(mode = OM_e_wrt_object,
                       msg = message GRvg.GRconstruct(construct_list),
                       senderid = my_id,
                       targetid = my_id);

      EMomerr_hndlr(status, wrapup, "EMprb2crvs: Error GRconstruct");
    }
   else  /* if not succesful in determining parabola */
    {
      if (*msg == BSINARG)
        {
          status = OM_S_SUCCESS;
          *msg = EMS_E_InvalidArg;
        }
      else
        {
          status = OM_E_ABORT;
          *msg = MSFAIL;
        }
    }

if (*msg == BSSUCC) *msg = MSSUCC;


wrapup:     /* deallocate memory */

   if ((*msg != MSSUCC) || (!status))
    {
      status = om$send(mode = OM_e_wrt_object,
                       msg = message Root.delete(1),
                       senderid = my_id,
                       targetid = my_id);
      if (!status) status = OM_E_ABORT;
    }
  if (crv1) OM_stack_dealloc (crv1);
  if (crv2) OM_stack_dealloc (crv2);

  return(status);

}
end implementation GRsubbc; 
