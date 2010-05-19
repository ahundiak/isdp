
/* $Id: VDCmdUsrAtt.sl,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdattrib / VDCmdUsrAtt.sl
 *
 * Description:
 *      The Command Object provides a form interface for modifying the user
 *      attributes of elements.
 *
 * Dependencies:
 *
 *      VDS_LOCATE
 *
 * Revision History:
 *	$Log: VDCmdUsrAtt.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/04/15  13:22:30  pinnacle
# Replaced: vdattrib/cmd/VDCmdUsrAtt.sl for:  by azuurhou for vds.240
#
# Revision 1.5  1996/04/02  20:18:12  pinnacle
# Replaced: vdattrib/cmd/VDCmdUsrAtt.sl for:  by rmanem for vds.240
#
# Revision 1.4  1996/04/02  16:13:24  pinnacle
# Replaced: vdattrib/cmd/VDCmd*.sl for:  by rmanem for vds.240
#
# Revision 1.3  1996/03/04  21:59:36  pinnacle
# Replaced: ./vdattrib/cmd/VDCmdUsrAtt.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/09/19  02:34:58  pinnacle
# Replaced: vdattrib/cmd/VDCmdUsrAtt.sl for:  by rmanem for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      08/25/94        R. Manem     	Creation
 *      09/18/95        rmn		fixed TR # 179527581 : crash
 *					when string lenths exceed 80 chars.
 *					Use ASend_fence correctly.  
 *      04/02/96        rmn		fixed locate to accept piping.
 *					fixed bug in modifying att value in form
 *
 * -------------------------------------------------------------------------
 */



command_string	VDC_M_VDMdUsrAtt,0,VDMdUsrAtt
command_table	"vds.cmd"
class		VDCmdUsrAtt
super_class     VDS_LOCATE
product_name	"$VDS"
options         "SITC"

form		"VDmodUsrAtt",0,0,"-1","-1"

/*---------------------
 * specification area
 */


specification

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDCmdUsrAtt

  Superclass
      VDS_LOCATE

  Abstract
        The Command Object provides a form interface for modifying the user
        attributes of elements. A collection of elements can be selected 
        using input generators or a single element can be selected for 
        modifying the user attributes.
        The CO also implements the dynamic tracking of the mouse on the form.

  Methods

      process_locate         Public     Processes the elements located by
                                        vds_locate filter

      wrap_up                Public     Wraps up the CO.

      dspAttrs               Public     Displays the user attributes of
                                        the specified element on the form

      delFromList            Public     Deletes an object from the list of
                                        located objects 

      operation              Public     Modifies the attributes of all
                                        located objects

  Overridden Methods

     mouse              Implemented to track the mouse position on the user 
                        attributes form, and display suitable messages in 
                        the message field on the form.
    
     form_notification  Notification routine for the VDmodUsrAtt form

  Forms

     User Attributes    VDmodUsrAtt     User interface for the CO


 -------------------------------------------------------------------------

-cmd*/

#include "VDmsg.h"
#include "VDusrAtt.h"

/*+v
 -------------------------------------------------------------------------
  Abstract

  Notes/Remarks

*/
instance {
      IGRint                    nbLocObjs;       /* No. of located objects */
      IGRint                    curObjIndex;     /* Current object whose
                                                    attributes are displayed */
      variable struct VDusrAtt  usrAttrs[0];     /* Array of user attributes */
      }
/*
 -------------------------------------------------------------------------
-v*/


/*---------------------
 * implementation area
 */



implementation


#include "OMprimitives.h"
#include "OMmacros.h"
#include "string.h"
#include "vdparmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "exproto.h"
#include "VDCmdDef.h"
#include "VDusrAtt.h"
#include "coparamac.h"
#include "coparadef.h"
#include "vdsetmacros.h"
#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"

/*
#define DEBUG
*/

#define MAXROWSIZE         80


/*+fe
 -------------------------------------------------------------------------
  Function MvRowAcrossMcfs

  Abstract
      The function moves a row from one mulicolumn field to another

  Arguments

      char              *pForm    I     pointer to the form
      int               fromMcf   I     Source mcf
      int               rowToMv   I     The row to move
      int               toMcf     I     Destination mcf

 -------------------------------------------------------------------------
-fe*/


static void MvRowAcrossMcfs( char *pForm, int fromMcf, int rowToMv, int toMcf )
{

     int      nrows, col, sel, pos ;
     char     buffer[MAXROWSIZE] ;

     FIfld_get_num_rows( pForm, fromMcf, &nrows ) ;
     if( rowToMv >= nrows ) return ; /* Nothing to move ... */
   
     FIfld_get_num_rows( pForm, toMcf, &nrows ) ;
     FIfld_set_num_rows( pForm, toMcf, nrows + 1 ) ;

     for( col = 0 ; col < 3 ; col++ ) 
     {
          FIfld_get_text( pForm, fromMcf, rowToMv, col, MAXROWSIZE,
    		          (unsigned char*) buffer, &sel, &pos ) ;
          
          /* Don't move row with NULL attribute name */

          if( col == 0 && strlen( buffer ) == 0 )
          {
               FIfld_set_num_rows( pForm, toMcf, nrows ) ;
               return;
          }
          FIfld_set_text( pForm, toMcf, nrows, col, buffer, FALSE ) ;
     }
   
     FIfld_delete_rows( pForm, fromMcf, rowToMv, 1 ) ;
   
} /* MvRowAcrossMcfs */



/*+fe
 -------------------------------------------------------------------------
  Function Mk1stVisRowActive

  Abstract
      The function makes the first visible row active

  Arguments

      char              *pForm    I     pointer to the form
      int               field     I     The multicolumn field

 -------------------------------------------------------------------------
-fe*/

void Mk1stVisRowActive( char *pForm, int field ) 
{

     int    nrows ;

     FIfld_get_num_rows( pForm, field, &nrows ) ;
     if( nrows ) 
     {
          int offset ;

          FIfld_get_row_offset( pForm, field, &offset ) ;
          FIfld_set_active_row( pForm, field, offset, 0 ) ;
          FIfld_set_select( pForm, field, offset, 0, TRUE ) ;  
     }

} /* Mk1stVisRowActive */


/*+fe
 -------------------------------------------------------------------------
  Function MkLstVisRowActive

  Abstract
      The function makes the last visible row active

  Arguments

      char              *pForm    I     pointer to the form
      int               field     I     The multicolumn field

 -------------------------------------------------------------------------
-fe*/


void MkLstVisRowActive( char *pForm, int field ) 
{

     int  nrows = 0 ;

     FIfld_get_num_rows( pForm, field, &nrows ) ;
     if( nrows ) 
     {
          int nvisrows ;
          FIfld_get_num_vis_rows( pForm, field, &nvisrows ) ;
          if( nrows < nvisrows ) 
               nvisrows = nrows ;
          FIfld_set_active_row( pForm, field, nrows-1, nvisrows-1 ) ;
          FIfld_set_select( pForm, field, nvisrows-1, 0, TRUE ) ;  
     }

} /* MkLstVisRowActive */


/*+fe
 -------------------------------------------------------------------------
  Function VDfillUsrAttrForm

  Abstract
      This function fills the user attribute form 

  Arguments

      char              *form     I     pointer to the form
      struct VDusrAtt   usrAtt    I     the list of attributes for the 
                                        various mcfs in the form

 -------------------------------------------------------------------------
-fe*/



void VDfillUsrAttrForm( char               *form,
                        struct VDusrAtt    usrAtt )
{
     IGRint           i, j, 
                      nbAttrs, 
                      mcf[4];
     struct ACrg_coll *att;

     mcf[0] = VD_K_ORI_ATTR_FLD;
     mcf[1] = VD_K_MOD_ATTR_FLD;
     mcf[2] = VD_K_DEL_ATTR_FLD;
     mcf[3] = VD_K_NEW_ATTR_FLD;
 
     /* Reset the mcfs */

     for( i = 0 ; i < 4 ; i++ )
          FIg_reset( form, mcf[i] );

     /* for each mcf, fill up the attributes in the form */

     for( i = 0 ; i < 4 ; i++ )
     {
          nbAttrs = usrAtt.nb[i];
          att = usrAtt.att[i];

          FIfld_set_num_rows( form, mcf[i], nbAttrs );

          if( !nbAttrs )
               continue;

          for( j = 0 ; j < nbAttrs ; j++ )
          {
               FIfld_set_text( form, mcf[i], j, 0, att[j].name, FALSE );
          
               switch( att[j].desc.type )
               {
                    case AC_ATTRIB_TEXT :
     
                    case AC_ATTRIB_TYPE_NOT_DEF :
     
                         FIfld_set_text( form, mcf[i], j, 1, "txt", FALSE );
                         FIfld_set_text( form, mcf[i], j, 2, 
                                         att[j].desc.value.att_txt, FALSE );
                    break;
     
                    case AC_ATTRIB_DOUBLE :
                         FIfld_set_text( form, mcf[i], j, 1, "dbl", FALSE );
                         FIfld_set_value( form, mcf[i], j, 2, 
                                         att[j].desc.value.att_exp, FALSE );
                    break;
     
                    default :
                         printf("\nUnknown type for attribute\n");
                         FIfld_set_text( form, mcf[i], j, 1, "txt", FALSE );
                         FIfld_set_text( form, mcf[i], j, 2, 
                                         att[j].desc.value.att_txt, FALSE );
                    break;
              
               }
          }
     }
}


/*+fe
 -------------------------------------------------------------------------
  Function VDgetUsrAttFromForm

  Abstract
      This function gets the attributes from the form and fills up
      the usrAtt structure

  Arguments

      long              *sts      O     Completion code
      char              *form     I     pointer to the form
      struct VDusrAtt   *usrAtt   O     the list of attributes for the
                                        various mcfs in the form

  Returns

      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     no dynamic memory

 -------------------------------------------------------------------------
-fe*/



long VDgetUsrAttFromForm( long            *sts,
                          char            *form,
                          struct VDusrAtt *usrAtt )
{
     IGRint           i, j, k, 
                      nb,
                      size,
                      sel,
                      pos,
                      mcf[4];
     char             *name = NULL, 
                      *value = NULL, 
                      type[2];
     double           dblval;

     *sts = VD_SUCCESS;

     mcf[0] = VD_K_ORI_ATTR_FLD;
     mcf[1] = VD_K_MOD_ATTR_FLD;
     mcf[2] = VD_K_DEL_ATTR_FLD;
     mcf[3] = VD_K_NEW_ATTR_FLD;
  
     /* Reset the output structure */

     for( i = 0 ; i < 4 ; i++ )
     {
          usrAtt->nb[i] = 0;
          if( usrAtt->att[i] )
              free( usrAtt->att[i] );
          usrAtt->att[i] = NULL;
     }

     for( i = 0 ; i < 4 ; i++ )
     {
          FIfld_get_num_rows( form, mcf[i], &nb ) ;

#ifdef DEBUG
     printf("\n\nNo of attributes in gadget %d : %d", i, nb );
#endif

          if( !nb ) 
               continue;

          usrAtt->att[i] = (struct ACrg_coll *) om$malloc( size = 
                                                sizeof(struct ACrg_coll) * nb );

          if( !usrAtt->att[i] )
          {
               *sts = VD_ERROR;
               printf("\nError : dynamic allocation\n");
               return OM_E_NODYNMEM;
          }
 
          /* k = number of attributes stored (no blank lines included) */

          k = 0;
          for( j = 0 ; j < nb ; j++ )
          {
               /* 
                * get the attribute name 
                */

               FIfld_get_text_length( form, mcf[i], j, 0, &size );
               name = (char *)om$malloc( size = size+1 );

               if( !name )
               {
                    *sts = VD_ERROR;
                    printf("\nError : Dynamic allocation\n");
                    goto wrapup;
               }

               FIfld_get_text( form, mcf[i], j, 0, size, 
                               (unsigned char *)name, &sel, &pos );
               name[size] = '\0';

#ifdef DEBUG
     printf("\nVDgetUsrAttFromForm : gadget %d : name = %s", i, name );
     printf("\nString Length = %d", strlen( name ) );
#endif

               if( strlen( name )  == 0 )
                    continue;

               strncpy( usrAtt->att[i][k].name, name, ATTR_TXT );
	       usrAtt->att[i][k].name[ ATTR_NAME-1 ] = '\0';
	       

#ifdef DEBUG
     printf("\nAttribute name = %s\n", name );
#endif
               /* 
                * get the attribute value, as a string 
                */

               FIfld_get_text_length( form, mcf[i], j, 2, &size );
               value = (char *)om$malloc( size = size+1 );

               if( !value )
               {
                    *sts = VD_ERROR;
                    printf("\nError : Dynamic allocation\n");
                    goto wrapup;
               }

               FIfld_get_text( form, mcf[i], j, 2, size, 
                               (unsigned char *)value, &sel, &pos );
               value[size] = '\0';

#ifdef DEBUG
     printf("\nAttribute value = %s\n", value );
#endif

               /* 
                * get the type of the attribute 
                */

               FIfld_get_text( form, mcf[i], j, 1, 2, 
                               (unsigned char *)type, &sel, &pos );

               /*
                * store the type and appropriate value in the ACrg_coll 
                * structure
                */

               if( type[0] == 't' )
               {
                    usrAtt->att[i][k].desc.type = AC_ATTRIB_TEXT;
                    strncpy( usrAtt->att[i][k].desc.value.att_txt, value,
						ATTR_TXT );
		    usrAtt->att[i][k].desc.value.att_txt[ ATTR_TXT-1 ] = '\0';

#ifdef DEBUG
     printf("\nAttribute type = %s", "TEXT" );
     printf("   String = %s\n", value );
#endif

               }
               else if( type[0] == 'd' )
               {
                    usrAtt->att[i][k].desc.type = AC_ATTRIB_DOUBLE;
                    SMget_double( form, mcf[i], j, 2, &dblval );
                    usrAtt->att[i][k].desc.value.att_exp = dblval;

#ifdef DEBUG
     printf("\nAttribute type = %s", "DOUBLE" );
     printf("   Double = %g\n", dblval );
#endif

               }
               k++;
          }
          usrAtt->nb[i] = k;
     }

wrapup :

     if( name )
          free( name );
     if( value )
          free( value );

     return OM_S_SUCCESS;
}


/*+fe
 -------------------------------------------------------------------------
  Function ProcessNewAttributes

  Abstract
      This function processes the new attributes entered, removing
      blank lines and printing messages for duplicate attributes

  Arguments

      char              *form     I     pointer to the form

  Returns
      VD_SUCCESS        if success
      VD_RESTART_CMD    if attribute is duplicated

 -------------------------------------------------------------------------
-fe*/


static long ProcessNewAttributes( char *pForm )
{

     int    nrowsNEW = 0 ;
     int    i, j, k ;
     int    sel, pos;
     long   status, msg, sts;
     double dbl;
     char   buffer[MAXROWSIZE], type[4];
     struct VDusrAtt   usratt;

     sts = VD_SUCCESS;

     FIfld_get_num_rows( pForm, VD_K_NEW_ATTR_FLD, &nrowsNEW ) ;

     /* delete empty rows and set the types properly */

     i = 0;
     while( i < nrowsNEW )
     {
          /* get attribute name */

          FIfld_get_text( pForm, VD_K_NEW_ATTR_FLD, i, 0, MAXROWSIZE,
                          (unsigned char*) buffer, &sel, &pos ) ;

          /* delete row if name is NULL */

          if( !strlen( buffer ) )
          {
               FIfld_delete_rows( pForm, VD_K_NEW_ATTR_FLD, i, 1 );
               nrowsNEW--;
          }
          else
          {
               /* get type and value */

               FIfld_get_text( pForm, VD_K_NEW_ATTR_FLD, i, 1, 2,
                               (unsigned char*) type, &sel, &pos ) ;
               FIfld_get_text( pForm, VD_K_NEW_ATTR_FLD, i, 2, MAXROWSIZE,
                               (unsigned char*) buffer, &sel, &pos ) ;

               /* 
                * if first char is 'd' , set type to "dbl", otherwise
                * if anything else is entered, set type to "txt"
                * Note: if blank, it is left blank
                */

               if( type[0] == 'd' )
                    FIfld_set_text( pForm, VD_K_NEW_ATTR_FLD, i, 1, 
                                    "dbl", FALSE );
               else if( strlen( type ) )
                    FIfld_set_text( pForm, VD_K_NEW_ATTR_FLD, i, 1, 
                                    "txt", FALSE );

               /*
                * If type is "txt", nothing done
                * if type is "dbl", get the double value, if it is not a
                *                   double, then force type to "txt"
                * If nothing is entered for type,
                *                   set it to "dbl" or "txt", depending on
                *                   the value entered
                */

               if( strlen( buffer) )
               {
                    if( SMget_double( pForm, VD_K_NEW_ATTR_FLD, i, 2, &dbl ) )
                    {
                         if( !strlen( type ) )
                              FIfld_set_text( pForm, VD_K_NEW_ATTR_FLD, i, 1, 
                                              "dbl", FALSE );
                    }
                    else 
                         FIfld_set_text( pForm, VD_K_NEW_ATTR_FLD, i, 1, 
                                         "txt", FALSE );
               }
               i++;
          }
     }
     if( !nrowsNEW )
          goto quit;

     for( i = 0 ; i < 4 ; i++ )
     {
          usratt.att[i] = NULL;
          usratt.nb[i]  = 0;
     }

     status = VDgetUsrAttFromForm( &msg, 
                                   pForm,
                                   &usratt );
     /*
      * If a new attribute is already in the list of existing, deleted or
      * modified attribute then print error message and return.
      */

     for( i = 0 ; i < nrowsNEW ; i++  ) 
     {
          FIfld_get_text( pForm, VD_K_NEW_ATTR_FLD, i, 0, MAXROWSIZE,
                          (unsigned char*) buffer, &sel, &pos ) ;
          if( !strlen( buffer ) )
               continue;

          for( j = 0 ; j < 3 ; j++ )
          {
               for( k = 0 ; k < usratt.nb[j]; k++ )
               {
                    /* 
                     * if attribute is duplicate, print message, 
                     * and return error
                     */

                    if( !strcmp( buffer, usratt.att[j][k].name ) )
                    {
                         char   info[80];

                         sprintf( info, "<%s> duplicated", buffer ); 

                         FIfld_set_text( pForm, FI_MSG_FIELD, 0, 0, 
                                         info, FALSE ) ;
                         UI_status( info );
                         sts = VD_RESTART_CMD;
                         goto quit;
                    }
               }
          }
      }

quit :
      return sts;
} /* ProcessNewAttributes */



/*---------------------
 * state table area
 */


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"

state start
     prompt_key              VD_P_IdStEls
     accept_key              VD_P_AccRej
     locate_class            "+ACncpx"
     locate_properties       "LC_DP_ONLY | LC_LC_ONLY "
     locate_owner            "LC_RIGID_OWNER | LC_FLEX_COMP | 
                              LC_RIGID_COMP  | LC_FLEX_OWNER "

     /*
      * Accept locate by name.
      */
     mask                    "GRm_DATA | GRm_STRING | GRm_OBJID"

     filter                  vds_locate

     on EX_DATA or EX_OBJID

          do process_locate

               on RETURN_CODE = VD_RESTART_CMD         state .

               on RETURN_CODE = VD_ERROR  
                    do wrap_up                         state terminate

          state getAttr

     on EX_RJT_MOVEON or EX_RESET
          do wrap_up                                   state terminate


state getAttr
     execute                 dspAttrs( 0 )
     display_form            0
     prompt_key	             VD_P_KyInAttr
     mask                    "GRm_BACK_UP | GRm_RESTART"
     execute                 set_dynamics_in_form( &me->ret, 
                                                   me->forms[0].form_ptr )
     filter                  vds_get_event_with_dynamics

     on GR_UNKNOWN_TYPE.VD_FORM_EXECUTE
	  state .

     on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
          /*
           * Form has been checked off.
           */
          do operation
               /*
               * Bad user input in form.
               */
               on RETURN_CODE = VD_RESTART_CMD
                    state .
               on RETURN_CODE = VD_ERROR
                    do wrap_up                            state terminate

          do erase_form 0
          do wrap_up

          state start

     on GR_UNKNOWN_TYPE.VD_FORM_CANCEL or EX_BACK_UP or EX_RESTART or 
                                                        EX_RJT_MOVEON  
          do erase_form 0

          do wrap_up

     state start

at init		do message_key	VD_M_MdUsrAtt
/*
at delete	do cleanUp()
*/



/*---------------------
 * message area
 */

/*+me
 -------------------------------------------------------------------------
  Public Message process_locate

  Abstract
        Processes the located elements

  Arguments
        long    *sts           O       Completion code

  Status 
      status    OM_S_SUCCESS    if success
                OM_E_NODYNMEM   no dynamic memory
                OW_W_ABORT      some other error

  Return Code 
      sts       VD_SUCCESS      if success
                VD_RESTART_CMD  if command has to be restarted
                VD_ERROR        if error 

 -------------------------------------------------------------------------
-me*/

action process_locate
{

int               i, j, nbObjs; 
struct GRobj_env  *lObjs = NULL;
IGRlong		  msg = 1;

struct GRid	  setId;
struct GRmd_env	  setEnv;

     *sts = VD_SUCCESS;


     /* Make graphic set, if necessary */

     VD_MakeGRsetOfObject( 	&msg,
				&me->ModuleInfo,
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				&setId,
				&setEnv,
				0 );

     /* eliminate dangles, table header/rows, etc */

     status =
     vd$filter_objects(	msg	= &msg,
			setId	= &setId );


     /* get the list of located objects */

     status = as$start_fence( 	set 		= &setId,
				set_env		= &setEnv,
				nb_obj           = &nbObjs,
				p_obj_env        = &lObjs,
				response         = me->response,
				response_data    = me->response_data);

     as$status();

     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          return status;
     }

#ifdef DEBUG
     printf("\nNo of objects returned = %d\n", nbObjs);
#endif

     /* allocate memory for located objects  and store the objects */

     if( !nbObjs )
     {
          *sts = VD_RESTART_CMD;
          goto quit;
     }

     status = om$vla_set_dimension( varray = me->locObjs,
                                    size   = nbObjs );
     if( !(status & 1) )
     {
          printf("\nError : dynamic allocation\n");
          *sts = VD_ERROR;
          return OM_E_NODYNMEM;
     }
          
     for( i = 0 ; i < nbObjs ; i++ )
          me->locObjs[i] = lObjs[i];

     me->nbLocObjs = nbObjs;
     me->curObjIndex = 0;

     ASend_fence();

     /*
      * Allocate the list of pointers for user attributes 
      */

     status = om$vla_set_dimension( varray = me->usrAttrs,
                                    size   = nbObjs );
     if( !(status & 1) )
     {
          printf("\nError : dynamic allocation\n");
          *sts = VD_ERROR;
          return OM_E_NODYNMEM;
     }
   
     /* Initialize the list */

     for( i = 0 ; i < nbObjs ; i++ )
          for( j = 0 ; j < 4 ; j++ )
          {
               me->usrAttrs[i].nb[j]  = 0;
               me->usrAttrs[i].att[j] = NULL;
          }

     /* 
      * Get the user attributes for each located object,  if the
      * object does not support the user attribute methods, then
      * it is an invalid object; print warning message and remove it
      * from the list
      */

     i = 0;
     while( i < me->nbLocObjs )
     {
          status = vd$getUsrAttributes( sts     = sts,
                                        object  = me->locObjs[i].obj_id,
                                        md_env  = &me->locObjs[i].mod_env,
                                        nbAttrs = &me->usrAttrs[i].nb[ORG],
                                        att     = &me->usrAttrs[i].att[ORG]
                                      );
          if( status == OM_W_UNKNOWN_MSG || 
              status == OM_W_REJECTED_METHOD )
          {
#ifdef	vdsDEBUG
               printf("\n\nWARNING : Invalid object [%d, %d] located.\n",
					me->locObjs[i].obj_id.osnum,
					me->locObjs[i].obj_id.objid );
               printf("\tDeselecting object\n");
#endif
               UI_status( "Invalid object located - deselecting it" );

               status = om$send( msg = message VDCmdUsrAtt.delFromList( 
                                                        sts , i ),
                                 targetid = my_id );
               as$status();
          }
          else
               i++;
     }
     if( !me->nbLocObjs )
     {
          *sts = VD_RESTART_CMD;
          goto quit;
     }
               
     goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message wrap_up

  Abstract
        Frees pointers
        Unhighlights the highlighted element
        Resets the instance data
        Resets the form

  Arguments
        long    *sts           O       Completion code

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/


action wrap_up
{
     int i, j;

     for( i = 0 ; i < me->nbLocObjs ; i++ )
          for( j = 0 ; j < 4 ; j++ )
               if( me->usrAttrs[i].att[j] )
                    free( me->usrAttrs[i].att[j] );

     /* Unhighlight the current element */

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex(sts,
                                                                me->curObjIndex,
                                                                GRbdhe ),
                       targetid = my_id );
     as$status();


     /* Remove all objects from the list */

     om$vla_set_dimension( varray = me->usrAttrs,
                           size   = 0 );

     status = om$send( msg = message VDS_LOCATE.removeLastLocatedObjects(
                                                                         sts, 
                                                                         0 ),
                       targetid = my_id );
     me->nbLocObjs = 0;
     me->curObjIndex = 0;
  
     /* reset the form */

     FIf_reset( me->forms[0].form_ptr );
     goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message dspAttrs

  Abstract
        Displays the attributes of an element in the form

  Arguments
        int     elmNo           I     Index of element, whose attributes
                                      are to be displayed

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/


action dspAttrs( int elmNo )
{
     int              oldInd;
     long             msg ;
     char             *pForm = me->forms[0].form_ptr ;
     struct GRobj_env elm;

     /* get the old object index and dehighlight it */

     oldInd = me->curObjIndex;

     /* 
      * dehighlight only if new element is different  from the previous one 
      * The first time dspAttrs is called, the old index will be equal to
      * the new one, because me->curObjIndex is set to 0 in process_locate
      */

     if( oldInd != elmNo )
     {
          status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( &msg,
                                                                      oldInd,
                                                                      GRbdhe ),
                            targetid = my_id );
          as$status();
     }

     /* Get the current element and highlight it */
           
     status = om$send( msg = message VDS_LOCATE.getLocObjAtIndex( &msg, 
                                                                  elmNo, 
                                                                  &elm ),
                       targetid = my_id ) ;
     as$status();

     me->curObjIndex = elmNo;

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( &msg,
                                                                 elmNo,
                                                                 GRbdhd ),
                       targetid = my_id );
     as$status();

     /* fill up the user attributes form */

     VDfillUsrAttrForm( pForm, me->usrAttrs[elmNo] ) ;

     /* 
      * if more than one object is located, then display the roll through
      * group gadgets, else erase it
      */

     if( me->nbLocObjs == 1 )
          FIg_erase( pForm, VD_K_ROL_THRU_GRP );
     else
     {
          FIfld_set_value( pForm, VD_K_ROL_THRU_FLD, 0, 0, 
                           (double)(elmNo+1), FALSE );
          FIg_display( pForm, VD_K_ROL_THRU_GRP );
     }

     /* 
      * erase the "Read from file" gadget.To be taken care of in later 
      * versions
      */

     FIg_erase( pForm, VD_K_DFLTS_BTN );
     FIg_erase( pForm, VD_K_UATT_GRP );

     goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message delFromList

  Abstract
        Deletes the specified object from the list of located objects

  Arguments
        long    *sts            O     Completion Code
        int     elmNo           I     Index of element to delete

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/

action delFromList( long *sts; int elmNo )
{
     int i;


     /* dehighlight the object before deleting it */

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( sts,
                                                                 elmNo,
                                                                 GRbdhe ),
                       targetid = my_id );
     as$status();

     /* free the attribute lists for the object to be deleted */

     for( i = 0 ; i < 4 ; i++ )
          if( me->usrAttrs[elmNo].att[i] )
          {
               free( me->usrAttrs[elmNo].att[i] );
               me->usrAttrs[elmNo].att[i] = NULL;
          }

     /* move the remaining objects one position up in the list */

     for( i = elmNo ; i < me->nbLocObjs - 1 ; i++ )
     {
          me->locObjs[i] = me->locObjs[i+1];
          me->usrAttrs[i] = me->usrAttrs[i+1];
     }

     me->nbLocObjs--;
     om$vla_set_dimension( varray = me->locObjs,
                           size   = me->nbLocObjs );

     om$vla_set_dimension( varray = me->usrAttrs,
                           size   = me->nbLocObjs );

     if( me->curObjIndex >= me->nbLocObjs && me->curObjIndex )
          me->curObjIndex--;

     goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message operation

  Abstract
        Modifies the user attributes of all the located objects, based on
        the current values on the form.

  Arguments
        int     *response       O
        char    *response_data  O

  Status/Return Code
      status == OM_S_SUCCESS    always;

  Note 
         The values of the user attributes in the Modified, Deleted and
         New attribute columns only are read, and these values are
         modified for all the located objects.  It is important to have
         this list active, when the form is checked off.
         This implies that the original user attributes of the objects will
         not be changed, unless it is in the modified or new attribute list

 -------------------------------------------------------------------------
-me*/


action operation
{
     char             *form = me->forms[0].form_ptr ;
     int              i, j, k,
                      nb[4],
                      elmNo,
                      total = 0 ;
     long             msg;
     struct ACrg_coll *att = NULL;
     struct GRobj_env  locObj;

     elmNo = me->curObjIndex;

     /* get the current list of attributes from the form */

     status = VDgetUsrAttFromForm( sts, 
                                   form,
                                   &me->usrAttrs[elmNo] );
                                   
     if( !(status & *sts & 1) )
          goto quit;

     /* compute total number of attributes */

     for( i = 0 ; i < 4 ; i++ )
          nb[i] = me->usrAttrs[elmNo].nb[i];

     total = nb[1] + nb[2] + nb[3];

     if( !total ) 
     { 
          *sts = VD_SUCCESS; 
          return OM_S_SUCCESS; 
     }

     /* allocate memory */

     att = (struct ACrg_coll *) om$malloc( size = sizeof( struct ACrg_coll ) *
                                                total );

     if( !att )
     {
          *sts = VD_ERROR;
          printf("\nError : dynamic allocation\n");
          return OM_E_NODYNMEM;
     }

     /* assign the attributes in the list */

     k = 0;
     for( i = 1 ; i < 4 ; i++ )
          for( j = 0 ; j < nb[i] ; j++ )
          {
              att[k] = me->usrAttrs[elmNo].att[i][j];
              if( i == 2 )
                   att[k].desc.type = VD_ATTRIB_DELETE;
              k++;
          }

     /* modify attributes for each located object */

     for( i = 0 ; i < me->nbLocObjs ; i++ )
     {
          status = om$send( msg = message VDS_LOCATE.getLocObjAtIndex(&msg,
                                                                      i,
                                                                      &locObj),
                            targetid = my_id );
          as$status( action = GOTO_VALUE,
                     value  = wrapup );

#ifdef DEBUG
     printf("\nObject <%d, %d> : Modifying attributes\n", 
                                 locObj.obj_id.objid, 
                                 locObj.obj_id.osnum );
#endif

          status = vd$modUsrAttributes( sts     = &msg,
                                        object  = locObj.obj_id,
                                        md_env  = &locObj.mod_env,
                                        nbAttrs = k,
                                        att     = att );
          as$status();

          if( status == OM_W_UNKNOWN_MSG )
          {
               printf("\nInvalid object : <%d, %d>\n", 
                                          locObj.obj_id.objid,
                                          locObj.obj_id.osnum );
               UI_status( "Invalid object" );
          }
     }

     goto quit;

wrapup :

     if( att )
          free( att );
     return status;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        mouse from VDS_LOCATE

  Abstract
        Based on the mouse position on the user attributes form 
        this method displays a suitable message in the message field

  Arguments
      long              *msg      O     Completion code
      char              *form     I     pointer to the form
      int               x         I     x coordinate of the mouse position
      int               y         I     y coordinate of the mouse position


 -------------------------------------------------------------------------
-mo*/


action mouse( long     *msg;
              char     *form;
              int      x; 
              int      y )
{
     int   label ;

     /* just to remove compiler warning */

     status = OM_S_SUCCESS;

     if( FIf_find_gadget( form, FI_FORM_GROUP, x, y, &label ) == FI_SUCCESS ) 
     {
          static int  prevLabel  = -1 ;
          static char *prevForm  = NULL ;

          if( prevForm != form || prevLabel != label ) 
          {
               long m ;
               char buffer[80];

               if( form == me->forms[0].form_ptr ) 
               {
                    switch( label ) 
                    {
                         case VD_K_ORI_ATTR_FLD : 
                              m = VD_I_OriginalAttrs ; break ;

                         case VD_K_DEL_ATTR_FLD : 
                              m = VD_I_AttrsToBeDel  ; break ;

                         case VD_K_MOD_ATTR_FLD : 
                              m = VD_I_AttrsToBeMod  ; break ;

                         case VD_K_NEW_ATTR_FLD : 
                              m = VD_I_AttrsToBeCre  ; break ;

                         case VD_K_MOD_ATTR_BTN : 
                              m = VD_I_MvOriToMod    ; break ;

                         case VD_K_REV_ATTR_BTN : 
                              m = VD_I_UndoMod       ; break ;

                         case VD_K_DEL_ATTR_BTN : 
                              m = VD_I_DelAttr       ; break ;

                         case VD_K_UND_ATTR_BTN : 
                              m = VD_I_UndelAttr     ; break ;

                         case VD_K_ROL_PLUS_BTN : 
                              m = VD_I_DpAttNxOb     ; break ;

                         case VD_K_ROL_MNUS_BTN : 
                              m = VD_I_DpAttPrOb     ; break ;

                         case VD_K_ROL_THRU_FLD : 
                              m = VD_I_PosCurObj     ; break ;

                         case VD_K_DEL_LIST_BTN : 
                              m = VD_I_DelObFrSt     ; break ;

/*
                         case VS_K_DFLTS_BTN    : 
                              m = VD_I_LdAttrFrFile  ; break ;
*/

                         default                : 
                              m = VD_I_EmptyMessage  ; break ;
                    }
                    ex$message( msgnumb = m,
                                buff    = buffer );

                    FIfld_set_text( form, FI_MSG_FIELD, 0, 0, 
                                    buffer, FALSE ) ;
               }
               prevForm = form ; prevLabel = label ;
          }
     }

     *msg = MSSUCC ;
     goto quit;

} /* method mouse */


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input



 -------------------------------------------------------------------------
-mo*/


action form_notification( int      form_label; 
                          int      gadget_label; 
                          double   value;
                          char     *form_ptr )
{
     int   resp,
           i, j,
           sel,
           pos,
           row,
           dest;
     long  msg;
     char  buffer[MAXROWSIZE];


     switch( gadget_label )
     {
          case FI_ACCEPT :
          {
               long sts;

               sts = ProcessNewAttributes( form_ptr );
               if( sts == VD_RESTART_CMD )
                    break;

               resp = VD_FORM_ACCEPT;
               ex$putque( msg      = &msg, 
                          response = &resp );
               break;
          }

          case FI_EXECUTE :
          {
               long sts;

               sts = ProcessNewAttributes( form_ptr );
               if( sts == VD_RESTART_CMD )
                    break;

               /* update attributes for all object */

               status = om$send( msg = message VDCmdUsrAtt.operation(&me->ret),
                                 targetid = my_id );

               if( me->ret == VD_ERROR )
                    me->state = _terminate;

               /* free up existing structures */

               for( i = 0 ; i < me->nbLocObjs ; i++ )
                    for( j = 0 ; j < 4 ; j++ )
                         if( me->usrAttrs[i].att[j] )
                         {
                              free( me->usrAttrs[i].att[j] );
                              me->usrAttrs[i].att[j] = NULL;
                              me->usrAttrs[i].nb[j] = 0;
                         }

               FIf_reset( me->forms[0].form_ptr );

               FIfld_set_num_rows( form_ptr, VD_K_ORI_ATTR_FLD, 0 );
               FIfld_set_num_rows( form_ptr, VD_K_MOD_ATTR_FLD, 0 );
               FIfld_set_num_rows( form_ptr, VD_K_DEL_ATTR_FLD, 0 );
               FIfld_set_num_rows( form_ptr, VD_K_NEW_ATTR_FLD, 0 );

               /* 
                * reinitialize data.  Not checking for status, because
                * it should work.  (Worked at initialization, the first time
                */

               for( i = 0 ; i < me->nbLocObjs; i++ )
                    status = vd$getUsrAttributes( sts     = &sts,
                                        object  = me->locObjs[i].obj_id,
                                        md_env  = &me->locObjs[i].mod_env,
                                        nbAttrs = &me->usrAttrs[i].nb[ORG],
                                        att     = &me->usrAttrs[i].att[ORG]
                                      );

               /* reset current object index, so that form gets updated */

               me->curObjIndex = -1;

               resp = VD_FORM_EXECUTE;
               ex$putque( msg      = &msg, 
                          response = &resp );
               break;
          }

          case FI_CANCEL :
               resp = VD_FORM_CANCEL;
               ex$putque( msg      = &msg, 
                          response = &resp );
               break;

          case VD_K_ORI_ATTR_FLD :
               break;

          case VD_K_MOD_ATTR_FLD :
               row = (int) value;
               FIfld_get_text( form_ptr, gadget_label, row, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               if( !strlen( buffer ) )
                    break;

               FIfld_set_text( form_ptr, VD_K_UATT_NAM_FLD, 0, 0, 
                               buffer, FALSE );
               FIfld_get_text( form_ptr, gadget_label, row, 1, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               FIfld_set_text( form_ptr, VD_K_UATT_TYP_FLD, 0, 0, 
                               buffer, FALSE );
               FIfld_get_text( form_ptr, gadget_label, row, 2, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               FIfld_set_text( form_ptr, VD_K_UATT_VAL_FLD, 0, 0, 
                               buffer, FALSE );
               FIg_display( form_ptr, VD_K_UATT_GRP );
               FIfld_pos_cursor( form_ptr, VD_K_UATT_TYP_FLD, 0, 0, 0, 0, 
                                 0, 0 );
               break;

          case VD_K_UATT_TYP_FLD :
               FIfld_get_text( form_ptr, gadget_label, 0, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               if( buffer[0] == 'd' )
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, "dbl", FALSE);
               else
                    FIfld_set_text( form_ptr, gadget_label, 0, 0, "txt", FALSE);
               FIfld_pos_cursor( form_ptr, VD_K_UATT_VAL_FLD, 0, 0, 0, 0, 
                                 0, 0 );
               break;
               
          case VD_K_UATT_VAL_FLD :
               FIfld_get_active_row( form_ptr, VD_K_MOD_ATTR_FLD,
                                     &row, &pos );
               FIfld_get_text( form_ptr, gadget_label, 0, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               if( strlen( buffer ) )
               {
                    char typ[4];
                    double dbl;

                    FIfld_get_text( form_ptr, VD_K_UATT_TYP_FLD, 0, 0, 
                                    4, (unsigned char *)typ, 
                                    &sel, &pos );
                    if( !SMget_double(form_ptr, gadget_label, 0, 0, &dbl ))
                         strcpy( typ, "txt" );
                              
                    FIfld_set_text( form_ptr, VD_K_MOD_ATTR_FLD, row, 1, 
                                    typ, FALSE);
                    FIfld_set_text( form_ptr, VD_K_MOD_ATTR_FLD, row, 2, 
                                    buffer, FALSE);
               }
               FIg_erase( form_ptr, VD_K_UATT_GRP );
               break;

          case VD_K_DEL_ATTR_BTN :
               dest = VD_K_DEL_ATTR_FLD; 
               goto MV_FROM_ORI ;

          case VD_K_MOD_ATTR_BTN :
               dest = VD_K_MOD_ATTR_FLD ;

MV_FROM_ORI:
               FIfld_get_active_row( form_ptr, VD_K_ORI_ATTR_FLD, &row, &pos ) ;
               MvRowAcrossMcfs( form_ptr, VD_K_ORI_ATTR_FLD, row, dest ) ;
               Mk1stVisRowActive( form_ptr, VD_K_ORI_ATTR_FLD ) ; 
               MkLstVisRowActive( form_ptr, dest ) ; 
               break ;

          case VD_K_UND_ATTR_BTN :
               FIfld_get_active_row( form_ptr, VD_K_DEL_ATTR_FLD, &row, &pos ) ;
               MvRowAcrossMcfs(form_ptr, VD_K_DEL_ATTR_FLD, row, VD_K_ORI_ATTR_FLD);
               Mk1stVisRowActive( form_ptr, VD_K_DEL_ATTR_FLD ) ; 
               MkLstVisRowActive( form_ptr, VD_K_ORI_ATTR_FLD ) ; 
               break ;

          case VD_K_REV_ATTR_BTN : 
          {
               int                cur, nb;
               long		  msg ;
    	       struct GRobj_env   elm ;
               struct ACrg_coll   *att;
    	
               cur = me->curObjIndex;

               FIfld_get_active_row( form_ptr, VD_K_MOD_ATTR_FLD, &row, &pos ) ;
               FIfld_get_text( form_ptr, VD_K_MOD_ATTR_FLD, row, 0, MAXROWSIZE,
	                        (unsigned char*) buffer, &sel, &pos ) ;
#ifdef DEBUG
    printf("\nText string to be moved to original list  = %s\n", buffer );
#endif
               if( buffer[0] == ' ')
                    break;

	       status = om$send( msg     = message VDS_LOCATE.getLocObjAtIndex(
                                                                         &msg, 
                                                                         cur, 
                                                                         &elm ),
	                         targetid = my_id ) ;

               as$status();
   
               status = vd$getUsrAttributes( sts     = &msg,
                                             object  = elm.obj_id,
                                             md_env  = &elm.mod_env,
                                             nbAttrs = &nb,
                                             att     = &att );
               as$status();
               if( !(status & msg & 1) )
                    break;

               for( i = 0 ; i < nb ; i++ )
               {
                    if( !strcmp( att[i].name, buffer ) )
                    {
                         char *p, t[4];
                         
                         switch( att[i].desc.type )
                         {
                              case AC_ATTRIB_DOUBLE :
                                   p = buffer;
                                   sprintf( p, "%g", att[i].desc.value.att_exp);
                                   strcpy( t, "dbl" );
                                   break;

                              default :
                                   p = att[i].desc.value.att_txt;
                                   strcpy( t, "txt" );
                                   break;
                         } 
                    
	                 FIfld_set_text( form_ptr, VD_K_MOD_ATTR_FLD, 
                                         row, 1, t, FALSE ) ;
	                 FIfld_set_text( form_ptr, VD_K_MOD_ATTR_FLD, 
                                         row, 2, p, FALSE ) ;
	                 MvRowAcrossMcfs( form_ptr, VD_K_MOD_ATTR_FLD, 
                                          row, VD_K_ORI_ATTR_FLD);
	                 Mk1stVisRowActive( form_ptr, VD_K_MOD_ATTR_FLD ) ; 
	                 MkLstVisRowActive( form_ptr, VD_K_ORI_ATTR_FLD ) ; 
                    }
               }
               break;
	  }

          case VD_K_ROL_PLUS_BTN :
          {
               int curInd, totNo;
               long sts;
            
               curInd = me->curObjIndex;
               totNo  = me->nbLocObjs;
       
               if( curInd + 1 >= totNo )
                    break;

               VDgetUsrAttFromForm( &sts, 
                                    form_ptr,
                                    &me->usrAttrs[curInd] );
               if( sts != VD_SUCCESS )
                    break;

               status = om$send( msg = message VDCmdUsrAtt.dspAttrs(curInd + 1),
                                 targetid = my_id );

               as$status();
               break;
          }

          case VD_K_ROL_MNUS_BTN :
          {
               int curInd, totNo;
               long sts;
            
               curInd = me->curObjIndex;
               totNo  = me->nbLocObjs;
       
               if( curInd == 0 )
                    break;

               VDgetUsrAttFromForm( &sts, 
                                    form_ptr,
                                    &me->usrAttrs[curInd] );
               if( sts != VD_SUCCESS )
                    break;

               status = om$send( msg = message VDCmdUsrAtt.dspAttrs(curInd - 1),
                                 targetid = my_id );

               as$status();
               break;
          }
               
          case VD_K_DEL_LIST_BTN :
          {
               status = om$send( msg = message VDCmdUsrAtt.delFromList( &msg,
                                                             me->curObjIndex ),
                                 targetid = my_id );
               as$status();

               status = om$send( msg = message VDCmdUsrAtt.dspAttrs(
                                                             me->curObjIndex ),
                                 targetid = my_id );

               as$status();
               break;
          }

          case VD_K_NEW_ATTR_FLD :
               ProcessNewAttributes( form_ptr ) ;
               break ;

          case VD_K_DFLTS_BTN : 
               break ;
      } /* end switch */

      goto quit;

} /* method form_notification */
