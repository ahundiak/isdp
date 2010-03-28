#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "gocmacros.h"
#include "go.h"
#include "msdef.h"


/*
 *
 *  Static variables containing current Abstract Geometry Buffer critical data.
 * 
 */

static IGRchar *absg_buffer = 0;	/* top of buffer		*/
static IGRchar *geometry = 0;		/* geometry in buffer		*/
static struct GRid *occupant = {0};	/* ID of current occupant of	*/
					/* buffer			*/
static IGRlong total_geometry_size = 0;	/* size of available geometry	*/
					/* buffer			*/
#define DEFAULT_SIZE 5000		/* default size of buffer	*/
#define ALIGNMENT_VALUE  8
#define BUFFER_EXPAND    1000

extern    IGRchar    *GRabsg_init();
extern    IGRchar    *GRget_more_mem();

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRabsg_test
 
     Abstract:

		This function tests to see if a given object 
	already occupies the abstract geometry buffer.  If so,
	a pointer to that abstract geometry is returned.

-----
%SC%

     VALUE = GRabsg_test(msg,matrix_type,matrix,osnum,objid,absgptr)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *matrix_type IGRshort	 type of environment matrix
     matrix	  IGRmatrix	 environment matrix
     *osnum	  GRspacenum	 object space number of requesting
				 object
     *objid	  GRobjid	 object id of requesting object

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code message
				   MSSUCC - if successful
				   MSFAIL - if an error occurred 
				   	    (i.e., buffer is not
					    initialized and cannot
					    be initialized now)
     **absgptr	  IGRchar	 pointer to geometry in abstract
				 geometry buffer if criteria matches

     VALUE (int) = 	  TRUE	- if given object matches the current
				  occupant of the buffer
			= FALSE - if given object doesn't match the 
				  current occupant of the buffer or
				  if an error occurred
				   
-----
%MD%

     MODULES INVOKED:

			GRabsg_init

-----
%NB%

     NOTES:		None.

-----
%CH%
     CHANGE HISTORY:
	
	REJ  05/05/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	If the abstract geometry buffer is not initialized, call
	the init. function.  Now, if all the object criteria matches
	then return the pointer saved in the static variable 
	geometry.  Else, return FALSE.

----*/
/*EH*/

int GRabsg_test(msg,matrix_type,matrix,osnum,objid,absgptr)

IGRlong		*msg;		/* output - completion code message	*/
IGRshort	*matrix_type;	/* input - type of the matrix		*/
IGRmatrix	matrix;		/* input - environment matrix		*/
GRspacenum	*osnum;		/* input - object space number of 	*/
				/* 	   requesting object		*/
GRobjid		*objid;		/* input - object id of requesting obj.	*/
IGRchar		**absgptr;	/* output - pointer to geometry buffer	*/
				/*	    if all criteria matches	*/

{

	IGRint i;		/* loop counter				*/
	IGRint status;		/* return value of function		*/
	struct GRabsg_hdr *current;


	status = FALSE;		/* initialize to not current occupant	*/
	*msg = MSSUCC;		/* initialize to success		*/

	if ( ! absg_buffer)
	{
	  if (! (absg_buffer = GRabsg_init(DEFAULT_SIZE)))
	  {
	    status = FALSE;
	    *msg = MSFAIL;
	    goto wrapup;
	  }
	}
	
	current = (struct GRabsg_hdr *) absg_buffer;
	
	if ((IF_EQ_OBJID(*objid,occupant->objid)) &&
	    (*osnum == occupant->osnum))
	{
	  if (*matrix_type == current->matrix_type)
	  {
	    status = TRUE;			/* initialize to match	*/
	    if (*matrix_type != MAIDMX)		/* must test matrix	*/
	    {
	      for (i = 0; i < 16; i++)
	      {
	        if (matrix[i] != current->matrix[i])
	        {
		  status = FALSE;
		  break;
		}
	      }
	    }
	  }
	}

	if (status)
	{
	  *absgptr = geometry;
	}

wrapup:

	return(status);

}

/*----
%GP% CODE CLASSIFICATION
----
%HD%

  MODULE NAME 		GRabsg_init
  Abstract:   

		Allocates and initializes the abstract geometry 
	memory buffer.

----
%SC%

  VALUE = GRabsg_init (nbytes)

----
%EN%
  ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *nbytes      IGRlong	 the number of bytes to allocate

----
%EX%
  ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

      VALUE (IGRboolean) = TRUE - memory is allocated
  		           FALSE - memory cannot be allocated
----
%MD%

  MODULES INVOKED: 
			OM_malloc()
----
%NB%

  NOTES:		None.

----
%CH%
  CHANGE HISTORY:

	mjm	12/18/85 : creation
	REJ	05/05/86 : Rewrite for single object in buffer.
	
----
%PD%
----------------------------------------------------------------------------
	P R O G R A M       D E S C R I P T I O N 
----------------------------------------------------------------------------

    	The memory requested for the abstract geometry buffer is sent to
	OMmalloc.  A failure here causes a  failure of the routine. 
	All the internal variables of the allocation routine are init-
	ialized.

----*/
/*EH*/



IGRchar *GRabsg_init(size)

IGRlong	size;			/* input - number of bytes to allocate	*/

{
	
	struct GRabsg_hdr *hdr;

	if (absg_buffer = om$malloc(size = size+ ALIGNMENT_VALUE))  
/*
 *
 * memory was allocated so initialize variables
 *
 */
	{
	  geometry = GRalign_double(absg_buffer + sizeof(struct GRabsg_hdr));
	  total_geometry_size = 
		size - sizeof(struct GRabsg_hdr) - ALIGNMENT_VALUE;
	  hdr = (struct GRabsg_hdr *) absg_buffer;
	  occupant = &hdr->id;
	  occupant->osnum = 0;
	  occupant->objid = NULL_OBJID;
	}

  	return(absg_buffer);

}



/*----
%GP% CODE CLASSIFICATION
----
%HD%

  MODULE NAME 		GRabsg_del
  
	Abstract: 

		Deletes an abstract geometry from the 
	abstract geometry buffer.

----
%SC%

  VALUE = GRabsg_del(absgptr_ptr)

----
%EN%
  ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     absgptr_ptr  *IGRchar	 pointer to an object abstract 
				 geometry pointer
----
%EX%
  ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
  
  VALUE (IGRboolean) = TRUE, the geometry was deleted
  		       FALSE, the abstract geoemrty pointer is 
			      invalid
----
%MD%

  MODULES INVOKED: 	None

----
%NB%
  NOTES: 

	The abstract geometry pointer is set to 0 by this function 
	after the abstract geometry is deleted

----
%CH%
  CHANGE HISTORY:

	mjm	01/15/86 : creation date
	REJ	05/05/86 : Rewrite for single object in buffer.
        mrm     06/22/92   Make sure occupant is initialized before referencing

----
%PD%
----------------------------------------------------------------------------
	P R O G R A M       D E S C R I P T I O N 
----------------------------------------------------------------------------

The abstract geometry is deleted and then the abstract geoemtry pointer
is set to 0.

----*/
/*EH*/

IGRboolean GRabsg_del(absgptr_ptr)

IGRchar *absgptr_ptr;			/* input geometry pointer	*/

{

	IGRboolean ret_value;

	if(absgptr_ptr == geometry)
	{
	  ret_value = TRUE;
	}
	else
	{
	  ret_value = FALSE;
	  goto wrapup;
	}
        if (occupant)
        {
	  occupant->osnum = 0;
	  occupant->objid = NULL_OBJID;
        }

wrapup:

	return(ret_value);

}

/*----
%GP% CODE CLASSIFICATION
----
%HD%

  MODULE NAME 		GRabsg_del_by_objid
  
	Abstract: 

		Deletes an abstract geometry from the 
	abstract geometry buffer using object id and space
	number.

----
%SC%

  VALUE = GRabsg_del(objid, osnum)

----
%EN%
  ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     objid	  *GRobjid 	 pointer to an object id 
     osnum	  *GRspacenum	 pointer to a space number

----
%EX%
  ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
  
  VALUE (IGRboolean) = TRUE, the geometry was deleted

----
%MD%

  MODULES INVOKED: 	None

----
%NB%
  NOTES: 

	The abstract geometry pointer is set to 0 by this function 
	after the abstract geometry is deleted

----
%CH%
  CHANGE HISTORY:

	RDH	07/10/86 : Creation date.
        mrm     06/22/92   Make sure occupant is initialized before referencing

----
%PD%
----------------------------------------------------------------------------
	P R O G R A M       D E S C R I P T I O N 
----------------------------------------------------------------------------

The abstract geometry is deleted and then the abstract geoemtry pointer
is set to 0.

----*/
/*EH*/

IGRboolean GRabsg_del_by_objid(objid, osnum)

GRobjid	   *objid;
GRspacenum *osnum;

{

	IGRboolean ret_value;

	if (occupant &&
            occupant->objid == *objid &&
            occupant->osnum == *osnum)
	{
	  occupant->osnum = 0;
	  occupant->objid = NULL_OBJID;
	  ret_value = TRUE;
	}
	else
	{
	  ret_value = FALSE;
	}

	return(ret_value);

}

/* This routine deletes any current geometry from the buffer */

IGRboolean GRabsg_del_all()

{
	if (absg_buffer)
	{
	    occupant->osnum = 0;
	    occupant->objid = NULL_OBJID;
	}

	return(TRUE);
}

/*----
%GP% CODE CLASSIFICATION
----
%HD%
  MODULE NAME 	GRabsg_alloc

  Abstract: 

		Allocates memory for abstract geometry
 
----
%SC%

  VALUE = GRabsg_alloc(msg, hdr)

----
%EN%
  ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *hdr         struct 	 pointer to the structure 
		  GRabsg_hdr     containing  the geometry size, the 
				 whole size (uninitialized), the 
				 object id of the object associated
				 with the abstract geometry and
  				 the object space and the context 

----
%EX%
  ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong        the completion code message
				  - MSSUCC successful completion
				  _ MSFAIL not enough memory
  
	VALUE (*IGRchar) = 0 if no memory could be allocated
  		           pointer to the memory allocated 
----
%MD%

  MODULES INVOKED:	None.

----
%NB%

  NOTES:		None.

----
%CH%

  CHANGE HISTORY:

	mjm	12/18/85 : creation date
	REJ	05/05/86 : Rewrite for single object in buffer.

----
%PD%
----------------------------------------------------------------------------
	P R O G R A M       D E S C R I P T I O N 
----------------------------------------------------------------------------

----*/
/*EH*/

IGRchar *GRabsg_alloc(msg, hdr)

IGRlong		   *msg;		/* completion code		*/
struct GRabsg_hdr  *hdr;		/* the object id data		*/

{
	struct GRabsg_hdr *cur_hdr;
	IGRchar *return_pointer = 0;


	*msg = MSSUCC;

	if ( ! absg_buffer)
	{
	  if (! (absg_buffer = GRabsg_init((long)DEFAULT_SIZE)))
	  {
	    return_pointer = 0;
	    *msg = MSFAIL;
	    goto wrapup;
	  }
	}

/*
 *
 * size needed is always a multiple of 4 bytes since memory is allocated 
 * on longword boundaries
 *
 */

	hdr->whole_size = sizeof(struct GRabsg_hdr) + 
			  hdr->geometry_size + ALIGNMENT_VALUE;

		
	if (hdr->geometry_size > total_geometry_size)
	{
	  if (! GRget_more_mem(hdr->whole_size + BUFFER_EXPAND))
	  {
	    *msg = MSFAIL;
	    return_pointer = 0;
	    goto wrapup;
	  }
	}

	return_pointer = geometry;
	cur_hdr = (struct GRabsg_hdr *) absg_buffer;
	*cur_hdr = *hdr;
	
wrapup:

	return(return_pointer);
  
}

/*
 *
 *  Static function for reallocating the Abstract Geometry Buffer.
 *
 */

static IGRchar *GRget_more_mem(nbytes)

IGRlong	nbytes;

{
	struct GRabsg_hdr *hdr;

	om$dealloc(ptr = absg_buffer);

	if (absg_buffer = om$malloc(size = nbytes + ALIGNMENT_VALUE))
	{
	  geometry = GRalign_double(absg_buffer + sizeof(struct GRabsg_hdr));
	  total_geometry_size = nbytes -
		(sizeof(struct GRabsg_hdr) + ALIGNMENT_VALUE);
	  hdr = (struct GRabsg_hdr *) absg_buffer;
	  occupant = &hdr->id;
	  occupant->osnum = 0;
	  occupant->objid = NULL_OBJID;
	}

	return(absg_buffer);
}
 
