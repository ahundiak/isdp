/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRvg
     FUNTION NAME: GRget2objgeom

     Abstract: This routine gets the geometries and geometrical
	      properties of two objects. A flag for each object
	      is used to determine whether the geometries we
	      get are to be extended or not.
-----
%SC%    

     GRget2objgeom(msg,obj1,env1,ex1,obj2,env2,ex2,buf1,buf2,s1,s2,
		   ptr1,ptr2,props1,props2)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     obj1	  GRid		 first object      
     env1	  GRmdenv_info	 environment information for obj1
     ex1	  IGRboolean	 get extended geom for obj1 flag
     obj2	  GRid		 second object
     env2	  GRmdenv_info	 environment information for obj2
     ex2	  IGRboolean	 get extened geometry for obj2 flag
     buf1	  IGRchar	 default geometry buffer
     buf2	  IGRchar	 default geometry buffer
     s1		  IGRlong	 size of buf1 in bytes
     s2		  IGRlong	 size of buf2 in bytes
   
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure due to an
				 error.

    ptr1	  IGRchar	 pointer to geometry one
    ptr2	  IGRchar	 pointer to geometry two
    props1	  GRprops	 properties of obj1 
    props2	  GRprops  	 properties of obj2

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     OM_malloc
     Methods:
	     GRgeomprops
	     GRgetexsize
	     GRgetexgeom

-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	    If the flag ex1 or ex2 is TRUE, then this routine  will
	   get their extended geometries.

	    If buf1 or buf2 do not contain enough storage for their
	   geometries, this routine will allocate the needed storage.
	   On exiting with no errors, ptr1 will be equal to buf1 or 
	   will point to allocated storage and ptr2 will be equal to
	   buf2 or will point to allocated storage.
-----
%CH%

     CHANGE HISTORY:
	
	RDH     08/08/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine takes two object ids and attempts to find thier
properties and geometries. Input buffers will be used as storage for
the geometries if the indicated sizes are large enough. If the size
or sizes are too small, OM_malloc is called to allocate storage for
the geometries. In any case, ptr1 and ptr2 will point to the 
geometries on exiting with no errors. On exiting, if ptr1 is equal 
to buf1 then no allocation was done. The same is true for ptr2.

----*/
/*EH*/

class implementation GRvg;

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


IGRboolean GRget2objgeom(msg,obj1,env1,ex1,obj2,env2,ex2,buf1,buf2,s1,s2,
			 ptr1,ptr2,props1,props2)

	IGRlong 		*msg;		/* return code		     */
	struct GRid		*obj1;		/* object one		     */
	struct GRmdenv_info	*env1;		/* environment info, obj1    */
	IGRboolean		*ex1;		/* extended geom flag obj1   */
	struct GRid		*obj2;		/* object two		     */
	struct GRmdenv_info	*env2;		/* environment info, obj2    */
	IGRboolean		*ex2;		/* extended geom flag bj2    */
	IGRchar			*buf1;		/* default buffer, geom1     */
	IGRchar			*buf2;		/* default buffer, geom2     */
	IGRlong			*s1;		/* size of buf1		     */
	IGRlong			*s2;		/* size of buf2		     */
	IGRchar			**ptr1;		/* geometry pointer, obj1    */
	IGRchar			**ptr2;		/* geometry pointer, obj2    */
	struct GRprops		*props1;	/* properties of obj1	     */
	struct GRprops		*props2;	/* properties of obj2	     */

{
  IGRlong size1,size2;				/* sizes of geometries	     */
  IGRlong OMmsg;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  *ptr1 = 0;
  *ptr2 = 0;

  					/* get geometrys		     */
  OMmsg = om$send(mode = OM_e_wrt_object, msg = message 
		  GRvg.GRgeomprops(msg,&env1->matrix_type,env1->matrix,props1),
                  senderid = NULL_OBJID,
                  targetid = obj1->objid,
                  targetos = obj1->osnum);


  if( 1 & *msg & OMmsg )
    {
      OMmsg = om$send(mode = OM_e_wrt_object, msg = message 
		      GRvg.GRgeomprops(msg,&env2->matrix_type,env2->matrix,
				       props2),
                      senderid = NULL_OBJID,
                      targetid = obj2->objid,
                      targetos = obj2->osnum);


      if( 1 & *msg & OMmsg )
	{
	  if( !(props1->subtype == GREC || 
	        props1->subtype == GRES || props1->subtype == GRCS ||
	        props2->subtype == GREC || 
 	        props2->subtype == GRES || props2->subtype == GRCS) )
	    {
	      if( *ex1 )
		{
	          OMmsg = om$send(mode = OM_e_wrt_object, msg = message 
				  GRvg.GRgetexsize(msg,&env1->matrix_type,
						   env1->matrix,&size1),
                              senderid = NULL_OBJID,
                              targetid = obj1->objid,
                              targetos = obj1->osnum);

		}
	      else
		{
	          OMmsg = om$send(mode = OM_e_wrt_object, msg = message 
				  GRvg.GRgetsize(msg,&env1->matrix_type,
						   env1->matrix,&size1),
                              senderid = NULL_OBJID,
                              targetid = obj1->objid,
                              targetos = obj1->osnum);

		}

	      if( 1 & *msg & OMmsg )
		{
		  if( size1 <= *s1 )
		    {
		      *ptr1 = buf1;
		    }
		  else
		    {
		      if( !( *ptr1 = om$malloc(size = size1 ) ) )
			{
			  *msg = MSFAIL;
			}
		    }

		  if( 1 & *msg )
		    {
		      if( *ex1 )
			{
		          OMmsg = om$send(mode = OM_e_wrt_object, msg = message
				      GRvg.GRgetexgeom(msg,&env1->matrix_type,
						       env1->matrix,*ptr1),
                                      senderid = NULL_OBJID,
                                      targetid = obj1->objid,
                                      targetos = obj1->osnum);

			}
		      else
			{
		          OMmsg = om$send(mode = OM_e_wrt_object, msg = message
				      GRvg.GRgetgeom(msg,&env1->matrix_type,
						       env1->matrix,*ptr1),
                                      senderid = NULL_OBJID,
                                      targetid = obj1->objid,
                                      targetos = obj1->osnum);

			}

		      if( 1 & *msg & OMmsg )
		      {
			if( *ex2 )
			{
	                  OMmsg = om$send(mode = OM_e_wrt_object, msg = message
					  GRvg.GRgetexsize(msg,
					  &env2->matrix_type,env2->matrix,
					  &size2),
                                          senderid = NULL_OBJID,
                                          targetid = obj2->objid,
                                          targetos = obj2->osnum);

			}
		        else
			{
	                  OMmsg = om$send(mode = OM_e_wrt_object, msg = message
					  GRvg.GRgetsize(msg,
					  &env2->matrix_type,env2->matrix,
					  &size2),
                                          senderid = NULL_OBJID,
                                          targetid = obj2->objid,
                                          targetos = obj2->osnum);

			}

	                if( 1 & *msg & OMmsg )
		          {
			    if( size2 <= *s2 )
			      {
			          *ptr2 = buf2;
			      }
			    else
			      {
			        if( !( *ptr2 = om$malloc(size = size2 ) ) )
				  {
				    *msg = MSFAIL;
			 	  }
			      }

			    if( 1 & *msg )
			      {
				if( *ex2 )
				{
		  	  	  OMmsg = om$send(mode = OM_e_wrt_object,
                                                msg = message GRvg.GRgetexgeom(
						      msg,&env2->matrix_type,
						      env2->matrix,*ptr2),
                                                  senderid = NULL_OBJID,
                                                  targetid = obj2->objid,
                                                  targetos = obj2->osnum);

				}
				else
				{
		  	  	  OMmsg = om$send(mode = OM_e_wrt_object,
                                                msg = message GRvg.GRgetgeom(
						      msg,&env2->matrix_type,
						      env2->matrix,*ptr2),
                                                  senderid = NULL_OBJID,
                                                  targetid = obj2->objid,
 		                                  targetos = obj2->osnum);
				}
			      }
			    }
			}
		    }
  		}
	    }
	    else
	    {
		*msg = MSFAIL;
	    }
	}
    }

  if( !( 1 & OMmsg ) )
    {
      *msg = MSFAIL;
    }

  return( 1 & *msg);

}/* This has been an R.D.H. production!!! */

end implementation GRvg;
