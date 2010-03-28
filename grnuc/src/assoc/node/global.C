#include "OMminimum.h"
#include "GM.h"
#include "GMdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "batch.h"
#include "nddef.h"


/*
   Global data used in NDnode.
   in a separate file to make dy load easier 
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*      GRAPH INFO 							      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
struct GMgraph ND_graph;          /* Global graph for the system              */

IGRboolean ASbroadcast_in_progress = FALSE;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*      BATCH INFO 							      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* Current mode of the batch          */
char NDactive_mode = ND_TRANSACTION;

/* Current mode of the graph manadger          */
char NDgraph_mode  = ND_BROAD_COP | ND_CONN_COP | ND_NO_BROAD_DEL;

/*                    Global variables for a modification                     */

struct  ext_list  NDmodif       /* List of the objects to modify              */
        = {NULL,NULL,NULL,0,0,0,0};
int     *NDmodif_flag = NULL;

#define ND_MAX_FUN 5

int NDnb_start_modif = 0;
int (*NDstart_modif [ND_MAX_FUN]) ();  /* user function called at begining of */
                                       /* modify batch                        */


int NDnb_end_modif = 0;
int (*NDend_modif [ND_MAX_FUN]) ();    /* user function called at end of      */
                                       /* modify batch                        */

/* used by dim_conv.o, I don't know why */

struct GRmd_env NDor_env,NDto_env;

/*                    Global variables for a delete                           */

struct  ext_list  NDdelete      /* List of the objects to delete              */
        = {NULL,NULL,NULL,0,0,0,0};


/* Do we tell error to the user */

IGRboolean NDtell_user = FALSE;

/* Does model print or not error messages */

int ems_do_print_error_messages = 1;
