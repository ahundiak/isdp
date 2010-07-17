
/* $Id: VSEnvIgds.sl,v 1.1.1.1 2001/01/04 21:10:41 cvs Exp $  */

/* I/STRUCT
 *
 * File:     <source_directory> / VSEnvIgds.sl
 *
 * Description:
 *      This command object generates the PDS envelope file and the 
 * corresponding IGDS design file from the geometry of specified objects in
 * I/STRUCT files.
 *
 * Dependencies:
 *     envelope.o, env.o
 *
 * History:
 *   
 *      04/25/94         rmn             creation 
 *	10/28/97	S.M.Pathak       modification
 */



/*+cmd
  Command Object Class VSEnvIgds

  Superclass

      CEO_LOCATE

  Abstract

      The command object generates PDS envelope and IGDS design files from the
  geometry of selected objects in an I/STRUCT design file.  Objects can be
  selected by the user, using input generators or by locating graphic objects
  one by one.  Combinations are also possible.  Once all the objects are 
  selected, the files are generated.

  Methods

      my_init             Private      Initializes instance variables and
                                       default values

      form_notification   Private      Handles user input for output filenames
                                       in form 

      process_locate      Private      Processes data returned by locate filter
                                       and enables chain locate

      generate_files      Private      Generates the output envelope and IGDS
                                       files with the list of objects selected
                                       by the user

      highlight           Private      Highlights all the objects selected 
                                       before making the next call to locate
                                       filter 

      wrap_up             Private      Dehighlights all the objects, before
                                       the command terminates
     

  Forms

      Output files     VSEnvIgdsFl.fm  Get the names of output PDS envelope  
                                       to create and IGDS files to create  


-cmd*/

/*************************************************************************
 * CLASS SPECIFICATION AREA
 ************************************************************************/

command_string  VSC_M_EnvIgds,0,VSEnvIgds
class           VSEnvIgds
super_class     CEO_LOCATE
command_table   "vs.cmd"
product_name    "$STRUCT"

start_state     start

form            "VSEnvIgdsFl.fm",0,0,"-1","-1"

/*************************************************************************
 *        SPECIFICATION AREA
 ************************************************************************/

specification

#define LIST_SIZE     50

/*+v
*/
instance
{

     IGRchar *pds_file_name;       /* name of pds envelope file to create  */
     IGRchar *igds_file_name;      /* name of igds file to create          */

     IGRchar *def_pds_file_name;   /* default names */
     IGRchar *def_igds_file_name;

     IGRchar seed_file_name[20];      

/* list of objects selected */
     struct GRid   *l_objects;

/* No. of objects in the above list */
     int     nb_objects_list;     

/* No. of free positions in l_objects  */
     int     nb_free_positions;

}

/*
-v*/


/*************************************************************************
                implementation area
*************************************************************************/

implementation

#include <stdio.h>
#include <string.h>
#include "FI.h"
#include "OMlimits.h"
#include "OMtypes.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "OMprimindex.h"
#include "coparamac.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "gomacros.h"
#include "vsdef.h"
#include "vs.h"
#include "dp.h"
#include "dpmacros.h"
#include "transerr.h"
#include "msdef.h"
#include "EMSmsgdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "acrepdef.h"
#include "AS_status.h"
#include "AS_debug.h"

#include "VSmsg.h"
#include "grmacros.h"

%safe
#include "DIprims.h"
%endsafe

/*
#define DEBUG              1
*/

#define TRUE               1
#define FALSE              0

/* #defines for VSAdd_to_list function */

#define IndId(grid) (grid##->objid)
#define IndOs(grid) (grid##->osnum)
#define Arg(field)  ((struct list_info *)(f_info->info))->##field

/* Form return values */

#define VS_FORM_REJECT     255
#define VS_FORM_ACCEPT     256

/* Initial size of the list : l_objects */

#define LIST_SIZE          50

/* Gadgets */

#define PDS_FIELD          14
#define IGDS_FIELD         15

from ACncpx         import ACtest_consumed,ACget_NV_rep;
from VSfeature      import VSgetResultType;
from NDmacro        import ACreturn_foot;
from EMSsurface     import EMcreate_envelope_and_igds_files;
from GRgraphics     import GRfunction;
from OMObjSpace     import pass;

/* externs */

extern GRunit_database_type();

/* Extern functions defined in env.I file */

extern void EFwrite_component_to_envelope_file(); 
extern void VSEFwrite_envelope_and_igds_files ();

/* External memory allocation functions */

extern char * calloc();
extern char * realloc();

/* Extern form manipulation functions */

extern int FIg_get_type();
extern int FIfld_get_text_length();
extern int FIfld_set_default_text();
extern int FIfld_get_text();
extern int FIfld_set_text();


/* 
 * Structure type to store pointers to command objects's instance variables.
 */

struct list_info
{
     int                  *p_nb_objects_list;
     int                  *p_nb_free_positions;
     struct GRid          **p_l_objects;
};


/*+fi
  Internal Function Get_Text

  Abstract
       Gets the text from the active field in the form

  Algorithm
       Get the length of the text.
       Allocate appropriate memory for the text
       Store the text 


  Notes/Remarks
       5 extra bytes are allocated for the text to accomodate file extension
  The PDS envelope file has extension ".env" and the IGDS file has 
  extension ".dgn". 

  Returns
       FI_NO_MEMORY   If memory not available
       0              if success

*/

static int 
Get_text(   
          Form    fp,            /* I   Pointer to the form     */
          int     g_label,       /* I   The label of the gadget */
          char ** text,          /* I/O The text contained in the field */
          int   * text_size      /* I/O The space allocated for the text */
         )

/*
-fi*/
{
     int status;
     int text_len;
     int select_flag;
     int row = 0;
     int col = 0;
     int pos = 0;


     status = FIfld_get_text_length( fp, g_label, row, col, &text_len );

/* Increment text_len by 5 : one for NULL, and 4 for filename extension */

     text_len += 5;

     if( * text_size < text_len )
     {
          if( * text_size > 0 )
          {
          /* Realloc space for larger string */
               * text = realloc( * text, text_len );
          }
          else
          {
          /* Calloc space for string */
               * text = calloc( 1, text_len );
          }
     * text_size = text_len;
     }

     if( ! * text )
     {
          * text_size = 0;
          return( FI_NO_MEMORY );
     }

     status = FIfld_get_text(  fp, g_label, row, col, * text_size,
                               * text, &select_flag, &pos );

     return(0);
}


/*+fi
  Internal Function is_same

  Abstract
       Compares two object ids.

  Returns
       TRUE   if objids are same
       FALSE  if objids are not same
*/

static int 
is_same( 
        struct GRid obj1,     /* I  Objid of first object  */ 
        struct GRid obj2      /* I  Objid of second object */
       )

/*
-fi*/

{
     if( (obj1.osnum == obj2.osnum) && (obj1.objid == obj2.objid) )
          return( TRUE );
     else
          return( FALSE );
}


/*+fi
  Internal Function VSAdd_to_list

  Abstract
       This function is called by GRfunction for every struct object in the
  design file.  If the object is not consumed, the object id is added to
  the Command Objects' instance data : l_objects; other instance variables 
  are updated to reflect the addition to the list.

  Notes
       The "info" field of the structure pointed to by f_info, is a pointer to
  a "list_info" structure, which has the necessary pointers to the 
  Command Objects' instance variables.

  Returns
          OM_S_SUCCESS     if no error encountered
          OM_E_NODYDMEM    if realloc fails as a result of insufficient memory.

*/

IGRint
VSAdd_to_list(
               IGRlong                  *msg,    /* Return value            */
               struct GRid              *Objid,  /* my objid                */
               struct GRfunction_info   *f_info  /* additional arguments to
                                                    function passed through
                                                    info field of this
                                                    structure               */
             )

/*
-fi*/

{
     int             status;
     OMuint          new_size;

     IGRlong         is_consumed;
     

     *msg = MSSUCC;

#ifdef DEBUG
     printf("\nObjid = %d, Osnum = %d",IndId(Objid), IndOs(Objid));
#endif

/* Check if object is consumed */

     is_consumed = 1;
     status = om$send( msg     = message ACncpx.ACtest_consumed( &is_consumed ),
                       senderid = NULL_OBJID,
                       targetid = IndId(Objid),
                       targetos = IndOs(Objid) );
     
     if( is_consumed )
          return( OM_S_SUCCESS );

#ifdef DEBUG
     printf("\nValid object found");
#endif

/* 
 * If object is not consumed, it should be added to the list of objects
 * If there are no free positions, allocate more space 
 */
     if( !( *Arg(p_nb_free_positions) ) )
     {

#ifdef DEBUG
     printf("\nIn VSAdd_to_list function : allocating more space");
#endif
          new_size            = (* Arg( p_nb_objects_list ) + LIST_SIZE) * 
                                sizeof( struct GRid );

          *Arg( p_l_objects ) = 
          (struct GRid *) om$realloc( ptr  = (char *)(*Arg( p_l_objects )),
                                      size = new_size ); 

          if( *Arg( p_l_objects ) == NULL )
          {     
               om$report_error( sts = OM_E_NODYNMEM );
               return OM_E_NODYNMEM;
          }

          *Arg(p_nb_free_positions) += LIST_SIZE;
     }

/* Store the object and update instance variables */

     ( *Arg(p_l_objects) )[ *Arg( p_nb_objects_list ) ].objid = IndId( Objid );
     ( *Arg(p_l_objects) )[ *Arg( p_nb_objects_list ) ].osnum = IndOs( Objid );

     (*Arg( p_nb_objects_list ))++;
     (*Arg( p_nb_free_positions ))--; 

     return OM_S_SUCCESS;
}


/*************************************************************************
                 state_table area
*************************************************************************/

state_table

#include "VSmsg.h"

#define DEBUG               "yes"

#define VS_FORM_REJECT     255
#define VS_FORM_ACCEPT     256

at init do my_init

/*
 * Display the form showing the default names for output files.
 * Ask user to modify form, and accept when done.
 */

state start

     message_key         VS_M_EnvFlGen
     prompt_key          VS_P_ModForm
     dynamics            off
     display_form        0

     filter              get_event

     on EX_RJT_MOVEON or GR_UNKNOWN_TYPE.VS_FORM_REJECT
          do erase_form 0                              state terminate

     on GR_UNKNOWN_TYPE.VS_FORM_ACCEPT
          do status_key  VS_S_MvSlElFl     
          do erase_form 0                              state locate_objects


/*
 * Ask user to locate all the objects for which data will be written in the
 * output files.  Chain locate is done for selecting the objects.
 * Before every call to the locate filter, the objects selected so far are
 * highlighted.
 */

state locate_objects

     message_key         VS_M_EnvFlGen
     prompt_key          VS_P_IdElMvon     
     accept_key          VS_P_AccIdNxtEl     
     relocate_key        VS_S_CnotFndEl

/* Reference file objects to be locatable */

     locate_owner        " LC_RIGID_OWNER | LC_FLEX_COMP | LC_REF_OBJECTS "

     locate_eligible     "+VSfeature"

/* highlight the elements selected so far */

     display_mode        GRbdhd
     execute             highlight

     filter              locate_noauto

     on EX_DATA or EX_OBJID
          do process_locate
               on SUCCESS                                  state .
               on ELSE         do status "ENTERED IN ERROR"  
				do wrap_up               state terminate

          state .

     on EX_RJT_MOVEON or EX_RESET
          do generate_files
          do wrap_up                                       state terminate

/*************************************************************************
     METHOD :  my_init 
*************************************************************************/

/*+mi
  Private Message my_init

  Abstract
       Initialization of the following variables is done :
          - command object's instance variables
          - default names for output files, based on the current design file

  Notes/Remarks
       The default extensions for output files are :
          - ".env" for PDS envelope file
          - ".dgn" for IGDS design file

  Status/Return Code
      OM_S_SUCCESS     if success;

-mi*/


action my_init
{
     OMuint     size;
     Form       fp;
     DIchar     dirname[DI_PATH_MAX]; /* Current directory path   */
     char       *file_name;            /* Current design file name */
     char       colon[] = ":", 
                dot[] = ".";

/* initialize instance variables */

     me->nb_objects_list = 0;
     me->nb_free_positions = LIST_SIZE;

     size          = LIST_SIZE * sizeof( struct GRid );
     me->l_objects = (struct GRid *) om$malloc( size = size ); 

     if( me->l_objects == NULL )
     {     
          om$report_error( sts = OM_E_NODYNMEM );
          return OM_E_NODYNMEM;
     }

/* Get the current directory path */

     status = di$pwd( dirname = dirname );

     as$status();
     if(!status)
     {
          me->state = TERMINATE;
          goto quit;
     }

#ifdef DEBUG
     printf("\nDirectory Path Name : %s ", dirname);
#endif

/* 
 * Get the active design file name 
 * This is the first string in the directory path delimited by ":"
 */

     file_name = strtok(dirname,colon);

#ifdef DEBUG
     printf("\nFile name : %s ", file_name);
#endif

/* remove the file name extension */

     file_name = strtok(file_name,dot);

#ifdef DEBUG
     printf("\nFile name without extension : %s ", file_name);
#endif

/* Allocate memory for instance variables */

     me->pds_file_name = (char *)malloc(strlen(file_name) + 5);
     me->igds_file_name = (char *)malloc(strlen(file_name) + 5);
     me->def_pds_file_name = (char *)malloc(strlen(file_name) + 5);
     me->def_igds_file_name = (char *)malloc(strlen(file_name) + 5);

/* Store filename in my instance variables and add proper extensions */

     strcpy(me->pds_file_name, file_name);     
     strcat(me->pds_file_name, ".env");     
     strcpy(me->igds_file_name, file_name);     
     strcat(me->igds_file_name, ".dgn");     

/* set up the default ouput file names */

     strcpy(me->def_pds_file_name, me->pds_file_name);
     strcpy(me->def_igds_file_name, me->igds_file_name);

/* form pointer */

     fp = me->forms[0].form_ptr;

/* Set up the default values for the fields in the form */

     status = FIfld_set_default_text(fp, PDS_FIELD, 0, 0, me->pds_file_name, 0);

     status = FIfld_set_default_text(fp,IGDS_FIELD, 0, 0, me->igds_file_name,0);

}

/*************************************************************************
     METHOD :   form_notification 
*************************************************************************/

/*+mo
  Overridden Message
        form_notification from CEO.S

  Abstract
        Manipulates form "VSEnvIgdsFl.fm"

  Arguments
           int        form_label      I     Form label
          int        gadget_label    I     PDS_FIELD, IGDS_FIELD
          double     value           I     Value of the gadget
          char       *form_ptr       I     Form pointer 


-mo*/

action form_notification
{
     int     text_size;
     int     actual_length;

     switch( gadget_label )
     {
          case PDS_FIELD:     

          /* Get PDS envelope file name */

               text_size = sizeof( me->pds_file_name );
               status = Get_text( form_ptr, gadget_label, & me->pds_file_name, 
                                 & text_size );

          /* If error, terminate command by rejecting form */

               if( status != FI_SUCCESS )
               {
                    _put_response(resp= VS_FORM_REJECT);
                    goto quit;
               }

          /* 
           * string length, not including the extra spaces allocated for file
           * extension
           */
               actual_length = strlen(me->pds_file_name);

          /*
           * if user entered null string, use the default filename and update
           * the field in the form 
           */

               if( actual_length == 0 )
               {
                    strcpy( me->pds_file_name, me->def_pds_file_name );
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, 
                                    me->pds_file_name, FALSE );
                    goto quit;
               }

          /*
           * check if file name extension, if exists, is valid;  if not ".env"
           * add the extension, and update the field
           */

               if(strcmp( ".env", & me->pds_file_name[actual_length-4]) != 0 )
               {
                    strcat( me->pds_file_name, ".env" );
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, 
                                    me->pds_file_name, FALSE );
                    actual_length += 4;
               }

          /*
           * if the user modified the pds file name, we automatically
           * update the igds file name.  The user can change the igds file name
           * if he chooses to.
           */

          /* reallocate space for igds file name, if required */

               if( sizeof( me->igds_file_name ) < (actual_length + 1) )
               me->igds_file_name = realloc( me->igds_file_name, 
                                             (actual_length+1) );

          /* 
           * update the igds file name, and the corresponding field in the
           * form with the proper extension
           */

               strcpy( me->igds_file_name, me->pds_file_name );
               strcpy( & me->igds_file_name[actual_length-4], ".dgn" );

               me->igds_file_name[actual_length] = '\0';
               FIfld_set_text( form_ptr, IGDS_FIELD, 0, 0, 
                               me->igds_file_name,FALSE );

          break;

case IGDS_FIELD:     

          /* Get IGDS file name */

               text_size = sizeof( me->igds_file_name );
               status = Get_text( form_ptr, gadget_label, & me->igds_file_name,
                                  & text_size );

          /* If error, terminate command by rejecting form */

               if( status != FI_SUCCESS )
               {
                    _put_response( resp= VS_FORM_REJECT );
                    goto quit;
               }

          /* 
           * string length, not including the extra spaces allocated for file
           * extension
           */
               actual_length = strlen( me->igds_file_name );

          /*
           * if user entered null string, use the default filename and update
           * the field in the form 
           */

               if(actual_length == 0)
               {
                    strcpy(me->igds_file_name, me->def_igds_file_name);
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, 
                                    me->igds_file_name, FALSE );
                    goto quit;
               }

          /*
           * check if file name extension, if exists, is valid;  if not ".dgn",
           * add the extension, and update the field
           */

               if(strcmp(".dgn", & me->igds_file_name[actual_length-4]) != 0)
               {
                    strcat( me->igds_file_name, ".dgn" );
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, 
                                    me->igds_file_name, FALSE );
               }
          break;

          case FI_CANCEL:     

               _put_response(resp= VS_FORM_REJECT);

          break;

          case FI_ACCEPT:     

               _put_response(resp= VS_FORM_ACCEPT);

          break;

     }

}

/*************************************************************************
     METHOD  :  process_locate 
*************************************************************************/

/*+mi
  Private Message process_locate

  Abstract
       Processes the objects returned by the locate filter.

  Algorithm
          - Call as$start_fence to get the list of objects
          - Store the objects in l_objects instance data, without duplication
          - Return accept point to the queue to enable chain locate

  Status/Return Code
      OM_S_SUCCESS  if success;

-mi*/

action process_locate
{

     long       msg;
     int        i, j; 
     OMuint     new_size; 
     OMuint     size_increment, excess;
     GRspacenum osnum;


/* 
 * flag to indicate if object is present in the list of objects, which
 * indicates if the user is locating the same object again
 */
     int        is_present;

/* no. of objects returned by as$start_fence */
     int        nb_objects;     

/* 
 * buffer to hold the objids of the located objects; this is passed to 
 * as$start_fence  which allocates memory for the buffer
 */
     struct GRid *buffer;

/* 
 * resp is always set to EX_DATA; this is used in returning the accept point
 * to the queue, with putque function
 */
     int         resp = EX_DATA;

/* no of bytes returned to the queue */

     long        size = sizeof( struct GRevent ) - sizeof( long ) * 2;


/* get osnum of located object */

     osnum = me->event1.located_object[0].located_obj.osnum;

/*
 * call the macro as$start_fence with non-null value for response, so that
 * the user is prompted with "Accept fence contents/Reject" in case he selected
 * a fence
 */

     
     status = as$start_fence( set = &me->event1.located_object[0].located_obj,
                              osnum            = osnum,
                              nb_obj           = &nb_objects,
                              p_obj            = &buffer,
                              response         = me->response,
                              response_data    = me->response_data);

     as$status( action = RET_STATUS );

#ifdef DEBUG
     printf("\nNo of objects returned = %d", nb_objects);
#endif


/* store the located objects in l_objects */

     if( nb_objects )
     {

     /* 
      * if space is not available  for all the located objects, 
      * allocate more space; update the no. of free positions.
      */

          if( nb_objects > me->nb_free_positions )
          {

#ifdef DEBUG
     printf("\nAllocating more space for list\n");
#endif

          /*
           * Increment the size of the list by integral multiples of LIST_SIZE.
           */

               excess         = nb_objects - me->nb_free_positions;
               size_increment = ( excess/LIST_SIZE + 1 ) * LIST_SIZE;
               new_size       = ( me->nb_objects_list + me->nb_free_positions +
                                size_increment ) * sizeof( struct GRid );

               me->l_objects = ( struct GRid * ) om$realloc( 
                                                 ptr  = (char *)me->l_objects,
                                                 size = new_size );

               if( me->l_objects == NULL )
               {
                    om$report_error( sts = OM_E_NODYNMEM );
                    return OM_E_NODYNMEM;
               }

               me->nb_free_positions += size_increment;
          }

/* store the located objects in l_objects , without duplication */

          for( i=0; i<nb_objects; i++)
          {

#ifdef DEBUG
     printf("\nObject id  = < %d , %d >", buffer[i].osnum, buffer[i].objid);
#endif
               is_present = FALSE;
     
     /* check if object is already present in the list */

               for( j = 0; j < me->nb_objects_list ; j++)
               {
                    if( is_same( me->l_objects[j], buffer[i] ) )
                    {
                         is_present = TRUE;
                         break;
                    }
               }
     
          /* if object is not present, add it to the list */
     
               if( !is_present )
               {
     
#ifdef DEBUG
     printf("\n< %d , %d> not present", buffer[i].osnum, buffer[i].objid);
#endif
                    me->l_objects[me->nb_objects_list] = buffer[i];
                    me->nb_objects_list++;
                    me->nb_free_positions--;
               }
          }

#ifdef DEBUG
     printf("\nNo of free positions : %d", me->nb_free_positions);
     printf("\nNo of objects in list : %d", me->nb_objects_list);

     printf("\nLIST OF OBJECTS :");
     for(i=0; i< me->nb_objects_list; i++)
          printf("\n\t%d,\t%d",me->l_objects[i].osnum,me->l_objects[i].objid);
#endif

     }


/*
 * If the user selected a fence or some set of objects using input generator,
 * the response is EX_OBJID;  In this case the accept prompt was "Accept fence
 * contents/Reject" and not "Accept (Identify next element) / Reject". So there
 * is no second point that needs to be returned to the queue to be processed by
 * locate filter.
 */

/* if response is not a fence, then return the accept point to the queue */

     if( me->event1.response != EX_OBJID )
     {

          status = ex$putque( msg       = &msg, 
                              byte      = &size,
                              response  = &resp, 
                              buffer    = (char *)(&me->event1.event) );

          as$status( sts     = status & msg,
                     action  = RET_STATUS   );
               
     }
     else

     /*
      * memory is allocated for "buffer" in as$start_fence only in case of fence
      * or group selections; for individual selection of graphic objects, 
      * "buffer" is assigned to a declared variable.  So we must free "buffer" 
      * only in case of fence selections
      */
          free(buffer);
}


/*************************************************************************
      METHOD : generate_files 
*************************************************************************/

/*+mi
  Private Message generate_files

  Abstract
       Generates the PDS envelope and IGDS files from the geometry of selected
  objects.  If user pressed the Moveon button without selecting any object,
  then the default option is assumed, ie all objects in the design file are
  considered.

  Status/Return Code
      OM_S_SUCCESS  if success;

-mi*/

action generate_files
{
     int                 i;
     int                 nb_vsfeature = 0;
     long                l_msg;
     unsigned long       struct_type;
     IGRint              db_unit_type, cmpnt_tag,
                         num_processed_ids, processed_ids_arrsz;

     IGRlong             msg, IGDS_filedesc;
     IGRdouble           max_abs_overflow, scale_factor,
                         file_ige_range[6];

     VSdspRep            myRep;

     OMuword             osobj;
     GRobjid             *processed_ids;
     struct GRid         foot_id, view_setup;
     struct GRmd_env     MOD_ENV; 
     struct GUcvt_bufs   *cvt_buffers; 
     OM_S_OBJID          iobj;
     OM_S_CHANSELECT     *p_compschan;
     
     OM_S_CLASSLIST          clist;
     struct GRfunction_info  f_info;
     struct list_info        my_info;

     int  err_flg  = 0;

/* get current module environment */

     status = gr$get_module_env( buffer = &MOD_ENV );
     as$status( action = RET_STATUS );

/* 
 * if user selected default option (Moveon without locating any object) then
 * we must use all the elements in the current design file.  So the l_objects
 * instance data must be filled up with valid struct objects.  This is done
 * by invoking the function "VSAdd_to_list" for every struct objects in the
 * design file
 */

     if( !me->nb_objects_list )
     {

     /* set up the my_info structure */

          my_info.p_nb_objects_list    = &me->nb_objects_list;
          my_info.p_nb_free_positions  = &me->nb_free_positions;
          my_info.p_l_objects          = &me->l_objects;
          
     /* 
      * set up the clist structure, to specify all objects subclassed from
      * VSfeature.
      */
          clist.p_classes = (OMuword *)malloc( sizeof( OMuword ));
          status          = om$get_classid( osnum     = OM_Gw_current_OS,
                                            classname = "VSfeature",
                                            p_classid = clist.p_classes );
     
          as$status( action = RET_STATUS );

          clist.w_count = 1;
          clist.w_flags = OM_CLST_subclass;
     
     /* Build the f_info buffer */

          go$build_user_function_buffer( buffer    = &f_info,
                                         your_info = &my_info,
                                         md_env    = &MOD_ENV );

#ifdef DEBUG
     printf("\nOM_Gw_current_OS = %d",OM_Gw_current_OS);
     printf("\nOM_GO_current_OS_objid = %d",OM_GO_current_OS_objid);
#endif

     /* 
      * Send the "pass" message to the current object space, to pass the
      * GRfunction message to all struct objects.  GRfunction in turn invokes
      * VSAdd_to_list function for every struct object
      */

          status = om$send( msg = message OMObjSpace.pass( &clist, 
                                                           OM_e_wrt_object,
                                  message GRgraphics.GRfunction( &msg,
                                                              VSAdd_to_list,
                                                            (char *) &f_info)),
                            senderid = NULL_OBJID,
                            targetid = OM_GO_current_OS_objid,
                            targetos = MOD_ENV.md_id.osnum );

          as$status();
     }

/* Some initializations */

     max_abs_overflow    = 0;
     num_processed_ids   = 0;
     processed_ids_arrsz = 0;
     processed_ids       = NULL;


/* 
 * Depending on the unit type - English or Metric, choose the appropriate
 * seed file
 */
     status = co$unit_database_type( osnum   = MOD_ENV.md_id.osnum, 
                                     db_type = &db_unit_type );
     as$status( action = RET_STATUS );

     if( db_unit_type == GRIO_UNITS_ARE_ENGLISH )

          strcpy(me->seed_file_name, "igds/mdlsdz.dgn");

     else if( db_unit_type == GRIO_UNITS_ARE_METRIC )

          strcpy( me->seed_file_name, "igds/mmdlsdz.dgn" );

/* initialize the envelope and igds files */

     VSEFinit_envelope_and_igds_files(  &msg, me->seed_file_name, 
                                        me->pds_file_name, me->igds_file_name, 
                                        &view_setup, &MOD_ENV, 
                                        &max_abs_overflow, &scale_factor, 
                                        &cvt_buffers, &IGDS_filedesc, 
                                        file_ige_range );

     if( msg == GUNOSEEDFILE )
	{
		ex$message( field   = ERROR_FIELD,
                      msgnumb = VS_E_SdFlNtFnd );
	}

     if( msg != EMS_S_Success )
     {
          printf( "\nError in VSEFinit_envelope_and_igds_files :\
                  \nerror_code = %d\n", msg );
          goto quit;
     }

#ifdef DEBUG
     printf("\nLIST OF OBJECTS :");
     for(i=0; i< me->nb_objects_list; i++)
          printf("\n\t%d,\t%d",me->l_objects[i].osnum,me->l_objects[i].objid);
#endif

/* Allocate memory for p_compschan, and select the channel, for later use */

	p_compschan = (OM_S_CHANSELECT *)om$malloc( structure = OM_S_CHANSELECT );

	if( !p_compschan )
	{
		om$report_error( sts = OM_E_NODYNMEM );
          goto quit;
     }

     status = om$make_chanselect( channame = "GRcmpowner.to_components",
                              p_chanselect = p_compschan );

     as$status();

/* Process each object */

     for( i=0 ; i<me->nb_objects_list ; i++ )
     {

          iobj   = me->l_objects[i].objid;
          osobj  = me->l_objects[i].osnum;


/*  check for 2-D objects      */

          status = om$send( msg  = message ACncpx.ACget_NV_rep( &myRep ),
                                targetid = iobj ,
                                targetos = osobj );

          as$status( action = RET_STATUS );

        if( myRep & AC_2D_REP )
        {
          err_flg=1;

        gr$display_object( object_id = &(me->l_objects[i]), mode = GRhd);

	  #ifdef DEBUG
     	    printf ("\n 2-D object \n objid %d  osnum %d", iobj,osobj);
	  #endif

          continue;
        }
        else
        {
         gr$display_object( object_id = &(me->l_objects[i]), mode = GRhe);

        }

          #ifdef DEBUG
            printf ("\n 3-D object \n objid %d  osnum %d", iobj,osobj);
          #endif

/*  check   complete     */

          status = om$send( msg  = message VSfeature.VSgetResultType( &l_msg, 
                                                     &struct_type),
                        targetos = osobj,
                        targetid = iobj) ;
          as$status( action = RET_STATUS );

#ifdef DEBUG
     printf ("\nstructure type = %x ", struct_type);
#endif

          if( struct_type & VS_m_PLATE )
          {

#ifdef DEBUG
     printf ( "\nplate = %d", iobj);
#endif

          /* setup the envelop header information for this PLATE */

               EFwrite_component_to_envelope_file(&msg, (GRobjid)iobj, 
                                                  MOD_ENV.md_id.osnum,
                                                  &MOD_ENV,
                                                  (IGRuint *)(&cmpnt_tag),
                                                  &scale_factor,
                                                  file_ige_range); 

               status = om$send( msg   = message NDmacro.ACreturn_foot(&msg,
                                                  "plate:base", &foot_id, NULL, 
                                                   NULL),
                              targetos = osobj,
                              targetid = iobj );

               as$status( action = RET_STATUS) ;

               if (!msg) 
                    printf ("\nERROR : Plate objid = %d has no base\n",iobj);
               else 
               {

               /* write envelope info. for all surfaces of the plate's base */

                    status = om$send( msg =  message EMSsurface.
                                             EMcreate_envelope_and_igds_files(
                                             &msg, &MOD_ENV, &scale_factor, 
                                             cvt_buffers, &IGDS_filedesc, 
                                             &max_abs_overflow, &cmpnt_tag, 
                                             (IGRboolean)1,
                                             file_ige_range, &num_processed_ids,
                                             &processed_ids_arrsz, 
                                             &processed_ids),
                                  targetos = osobj,
                                  targetid = foot_id.objid);
                    as$status( action = RET_STATUS );
               }

               status = om$send( msg   = message NDmacro.ACreturn_foot( &msg,
                                                 "plate:offset", &foot_id,
                                                 NULL, NULL ),
                              targetos = osobj,
                              targetid = iobj);

               as$status( action = RET_STATUS) ;
          
               if( !msg )
                    printf ("\nERROR : Plate objid = %d; has no offset\n",iobj);
               else 
               {

               /* write envelope info. for all sufaces of the plate's offset */

                    status = om$send( msg =  message EMSsurface.
                                             EMcreate_envelope_and_igds_files(
                                             &msg, &MOD_ENV, &scale_factor, 
                                             cvt_buffers, &IGDS_filedesc, 
                                             &max_abs_overflow, &cmpnt_tag, 
                                             (IGRboolean)1, file_ige_range, 
                                             &num_processed_ids,
                                             &processed_ids_arrsz, 
                                             &processed_ids ),
                                  targetos = osobj,
                                  targetid = foot_id.objid );

                    as$status( action = RET_STATUS ) ;
               }

          }
          else if( struct_type & VS_m_BEAM )
          {

#ifdef DEBUG
         printf ( "\nbeam = %d", iobj);
#endif

          /* setup the envelop header information for this BEAM */

               EFwrite_component_to_envelope_file(&msg, (GRobjid)iobj, 
                                                  MOD_ENV.md_id.osnum,
                                                  &MOD_ENV,
                                                  (IGRuint *)(&cmpnt_tag),
                                                  &scale_factor,
                                                  file_ige_range); 

               status = om$send( msg   = message NDmacro.ACreturn_foot(&msg,
                                                 "beam:body", &foot_id, NULL, 
                                                 NULL),
                              targetos = osobj,
                              targetid = iobj );

               as$status( action = RET_STATUS) ;

               if (!msg) 
			{
                    printf( "\nBeamobjid = %d has no body : ", iobj );
                    printf( "Using EMSsolid\n");

                    status = om$send( msg  = message EMSsurface.
                                             EMcreate_envelope_and_igds_files(
                                             &msg, &MOD_ENV, &scale_factor, 
                                             cvt_buffers, &IGDS_filedesc, 
                                             &max_abs_overflow, &cmpnt_tag, 
                                             (IGRboolean)1,
                                             file_ige_range, &num_processed_ids,
                                             &processed_ids_arrsz, 
                                             &processed_ids),
                              targetos     = osobj,
                              senderid     = iobj,
                              p_chanselect = p_compschan );

                    as$status( action = RET_STATUS );
               }
               else 
               {

               /* write envelope info. for all surfaces of the beam */

                    status = om$send( msg =  message EMSsurface.
                                             EMcreate_envelope_and_igds_files(
                                             &msg, &MOD_ENV, &scale_factor, 
                                             cvt_buffers, &IGDS_filedesc, 
                                             &max_abs_overflow, &cmpnt_tag, 
                                             (IGRboolean)1,
                                             file_ige_range, &num_processed_ids,
                                             &processed_ids_arrsz, 
                                             &processed_ids),
                                  targetos = osobj,
                                  targetid = foot_id.objid);

                    as$status( action = RET_STATUS );
               }
          }
          else 
               continue;

     nb_vsfeature++;
     }

     VSEFwrite_envelope_and_igds_files( &msg, me->igds_file_name, 
                                        &max_abs_overflow, &cvt_buffers, 
                                        &IGDS_filedesc, 
                                        file_ige_range );

     if( msg != EMS_S_Success )
     {
          printf( "\nError in VSEFwrite_envelope_and_igds_files :\
                  \nerror_code = %d\n", msg );
          goto quit;
     }


#ifdef DEBUG
     if( nb_vsfeature == 0) 
          printf( "\nNo unconsumed %s's were found\n", "VSfeature" );
     else
          printf( "\nNo of VSfeature's found = %d ", nb_vsfeature );
#endif

     status = ex$message( msgnumb = VS_S_FlGenComp );
     as$status();
     if(err_flg)
     {
            FI_msg_box ("IGDS Envelope Processing", FI_BLACK,
                        "Highlighted objects are in symbolic representation! \nChange it to 3-D representation to Process!!",
                        FI_BLACK);
     }


}

/*************************************************************************
     METHOD :  highlight 
*************************************************************************/

/*+mi
  Private Message highlight

  Abstract
       Displays the selected objects in highlight mode

  Status/Return Code
      OM_S_SUCCESS  if success;

-mi*/

action highlight
{
     int         i;
     IGRlong     msg;

for(i=0; i<me->nb_objects_list; i++)
     status = dp$display( msg    = &msg,
                          osnum  = me->l_objects[i].osnum,
                          mode   = me->DisplayMode,
                          oids   = &me->l_objects[i] );
     as$status();
               
}


/*************************************************************************
     METHOD :  wrap_up 
*************************************************************************/

/*+mi
  Private Message wrap_up

  Abstract
       Dehighlights the highlighted objects

  Status/Return Code
      OM_S_SUCCESS  if success;

-mi*/

action wrap_up
{
     IGRlong    msg;
     int        i;

/* dehighlight the selected objects */

     for(i=0; i<me->nb_objects_list; i++)
          status = dp$display( msg    = &msg,
                               osnum  = me->l_objects[i].osnum,
                               mode   = GRbdhe,
                               oids   = &me->l_objects[i] );
     as$status();
               
}

