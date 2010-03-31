/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  EMSgenbs 
     METHOD NAME:  EMplctbesrf

     Abstract: 
-----
%SC%    

     message EMSgenbs.EMplctbesrf ( &msg, &env, crv_GRid, tube_rad,
                                    &bendradii, &construct_list)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------

 *env           struct GRmd_env  module environment information for
                                 getting the abstract geometry for the
                                 curve object about which a tube surface
                                 is being placed.

 crv_GRid       struct GRid      structure containing the object id and the
                                 object space number of curve object.
 
 tube_rad       IGRdouble        the radius of the tube surface that is being
                                 constructed.

 *bend_radii    IGRdouble        pointer to the array of bend radii

 *construct_list struct          construction information for the tube surface
                GRvg_construct   object
                                  
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg       IGRlong        completion code

 Possible completion codes are :

           MSSUCC       -        indicates that the method was 
                                 successful in determining a tube 
                                 surface and updating the instance
                                 data of the surface object.

           MSFAIL       -        indicates failure .   
           MSINARG      -        if the bend radius is too large.
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
   
     BStube           -          Math routine for determining the
                                 tube surface

     OM_send_foreign  -          OM routine for sending messages when given
                                 the object space no and the object id.

     OM_send_object   -          OM routine for sending messages to an
                                 object

     OM_stack_alloc   -          OM routine for allocation of stack memory.

     OM_stack_dealloc -          OM routine for deallocating stack memory. 

     Methods:  

     GRgetsize        -          for getting the size of the abstract
                                 curve structure

     GRgetgeom        -          for getting the pointer to the abstract
                                 curve geometry.

     GRconstruct      -          for updating the instance data of the
                                 curve object
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

-----
%CH%

     CHANGE HISTORY:

    AIC : 15-Jul-87 : Do not generate element specific attributes.
    PP  : 10/17/86  : design date .
    rlw : 07/13/88  : Prasad forgot to initialize the surface data structure
                      pointers and as a result when certain method failed
                      he tried to free unallocated random memory.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method constructs a tube surface when given the tube radius,
bend radii and a curve. 

Algorithm:

1) Get the abstract geometry of the curve object.

2) Allocate memory for the tube surface.

3) Invoke the appropriate math routine for determining the surface
   structure.

4) If successful in determining the surface structure:
   
   a) Initialise the class_attr field of construct_list.
   
   b) Assign the newflag and geometry fields of construct_list.
 
   c) Send a GRconstruct message.
   
   else
   declare failure.
  
5) Deallocate memory.
----*/
/*EH*/


class implementation EMSgenbs;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0
#endif

#include <stdio.h>
#include "OMerrordef.h"
#include "OMstackalloc.h"
#include "bserr.h"
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


#define PERROR(sts,rc,label,error_message) \
 {\
  sts = OM_E_ABORT; \
  rc = MSFAIL;\
  fprintf (stderr, "\n%s", error_message);\
  goto label; \
 }

method EMplctbesrf ( IGRlong *msg;
                     struct GRmd_env *env;
                     struct GRid crv_GRid;
                     IGRdouble tube_rad;
                     IGRdouble *bradii;
                     struct GRvg_construct *construct_list)

{


  IGRlong       factor;         /* used for allocating memory and equals
                                   4 * no of linear poles */
  IGRlong       rc;             /* bs completion code */
  IGRlong       bstatus;        /* bs return code */
  IGRlong       status;         /* OM return code */
  IGRlong       num_bytes;      /* used for allocating memory */
  IGRlong       total_poles;    /* for the tube surface structure */
  
 
  struct        IGRbsp_curve *crv;  
                                /* pointer to the abstract geometry of 
                                   the curve object */

  struct        IGRbsp_surface surface;
                                /* structure storing geometry of the
                                   tube surface */ 

  extern   IGRboolean    BStube ();      /* function declarations */

/* ************
  
   Initialisation
   
   ************ */

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;
  crv = NULL;
  surface.v_knots = NULL;	/* rlw - 07/13/88 - added surface stuff */
  surface.u_knots = NULL;
  surface.weights = NULL;
  surface.poles = NULL;


/* ************

   Get the abstract geometry of the curve object

   ************ */

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize (msg,
                          &env->md_env.matrix_type, 
                          env->md_env.matrix, &num_bytes),
                   senderid = my_id,
                   targetid = crv_GRid.objid,
                   targetos = crv_GRid.osnum);
  EMomerr_hndlr(status, wrapup, "EMplctbesrf : GRgetsize error");

  crv = (struct IGRbsp_curve *) OM_stack_alloc(num_bytes);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom (msg,
                          &env->md_env.matrix_type, 
                          env->md_env.matrix, (IGRchar *)crv),
                   senderid = my_id,
                   targetid = crv_GRid.objid,
                   targetos = crv_GRid.osnum);
  EMomerr_hndlr(status,wrapup,"EMplctbesrf : GRgetgeom error");

/* ***********  
  
   Allocate memory for the surface structure 

   *********** */

  factor = 4 * crv->num_poles;
  total_poles = 7 * (factor - 5);

  num_bytes = total_poles * 3 * sizeof (double);
  surface.poles = (double *)OM_stack_alloc(num_bytes);
  if (!surface.poles) PERROR(status, *msg, wrapup, "No stack memory")
  
  num_bytes = total_poles * sizeof (double);
  surface.weights = (double *) OM_stack_alloc(num_bytes);
  if (!surface.weights) PERROR(status, *msg, wrapup, "No stack memory")

  num_bytes = 10 * sizeof (double);
  surface.u_knots = (double *) OM_stack_alloc(num_bytes);
  if (!surface.u_knots) PERROR(status, *msg, wrapup, "No stack memory")

  num_bytes = (factor - 2) * sizeof (double);
  surface.v_knots = (double *) OM_stack_alloc(num_bytes);
  if (!surface.v_knots) PERROR(status, *msg, wrapup, "No stack memory")



                                 /* invocation of math routine to
                                    determine the surface structure */
  bstatus = BStube (&rc , crv, bradii, &tube_rad, &surface);

  if (bstatus)  /* if successful in determining a surface */
   {
/* *************

   Initialisation of class specific attributes of the construct list
   for the surface object and assigning geometry and newflag fields.
   And sending a GRconstruct message

   ************* */

     construct_list->geometry =  (IGRchar *) &surface;
     construct_list->newflag = FALSE;

     status = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRconstruct(
                              construct_list),
                      senderid = my_id,
                      targetid = my_id);
     EMomerr_hndlr (status,wrapup,"EMplctbesrf : GRconstruct error");
     
     *msg = MSSUCC;
    
   }
   else  /* if unsuccessful in determining a surface */
   { 
     *msg = MSFAIL;
     if (rc == BSFAIL) *msg = MSINARG;
   }

/* *************

   Cleanup operations

   ************* */

wrapup:

   if ((*msg != MSSUCC) || (!status))
    {
      status = om$send(mode = OM_e_wrt_object,
                       msg = message Root.delete(1),
                       senderid = my_id,
                       targetid = my_id);
      if (!status) status = OM_E_ABORT;
    }

  if (crv) OM_stack_dealloc(crv);     
  if (surface.v_knots) OM_stack_dealloc(surface.v_knots);
  if (surface.u_knots) OM_stack_dealloc(surface.u_knots);
  if (surface.weights) OM_stack_dealloc(surface.weights);
  if (surface.poles) OM_stack_dealloc (surface.poles);

  return(status);

}

end implementation EMSgenbs;

