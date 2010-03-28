#ifndef batch
#define batch

#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

struct NDmodif_info
   {
    struct GRparms parms;
    IGRpoint point,boreline_pt1,boreline_pt2;
   };

struct NDxf_info
   {
     union {

            IGRmatrix mat; 		/* xform matrix */  
	    struct NDmodif_info mod;    /* modify information */

	   } info;
     IGRchar type;              	/* xform or modify */ 
   };

/* structure to store a batch list */

struct ext_list
  {
  struct GRid *list_id;   /* List of objects                                  */
  char *list_inf;         /* additionnal information per object if any        */
  char *list_name;        /* additionnal name per object if any               */
  int size;               /* Size of the lists                                */
  int nb_obj;             /* Number of objects in the list                    */
  int size_inf;           /* size of info per object in list_inf              */
  int size_name;          /* size of name per object in list_name             */
};
#endif
