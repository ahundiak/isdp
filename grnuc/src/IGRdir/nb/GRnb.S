class specification GRnb (2:0) of Root;

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"

#define EXIT_BUTTON            1
#define ABORT_BUTTON           4
#define READ_IN_BUTTON        11
#define WRITE_OUT_BUTTON      12
#define EDIT_FIELD            14
#define DELETE_BUTTON         15
#define NAME_FIELD            16
#define FILE_NAME_FIELD       20

instance GRnb
{
  variable char notes [0]	/* The notes we have so far */;
};


message init_form ();
/*
   DIsplays the form with the text in notes.

   Return Status: OM_S_SUCCESS;
*/


message close_form ( int save );
/*
   Undisplays and deletes the form after saving (if save is TRUE) the text in notes.

   Return Status: OM_S_SUCCESS;

   Input Arguments:
      int save:		if TRUE then the text from the EDIT_FIELD is saved into
                        the instance data of the note book (notes).
*/


end specification GRnb;
