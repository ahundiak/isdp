/***************************************************************************
 * I/VDS
 *
 * File:        vdattrib/VDCmdUsrAtti.I
 *
 * Purpose:     Displays, modifies, deletes and reads user attributes.
 *
 * Notes:       The middle column in the multi-column fields contains the
 *		attribute type (an ACrg_collect holdover). It is automatically
 *		determined by using SMget_double in the module ProcessNew-
 *		Attributes.
 *		Default values, a confusing term, refers to attribute values
 *		input through an ascii file.
 * Dependencies:
 *		Forms:  VDmodUsrAtt (parent), VDdflValues.fm (first subform),
 *			VDKyInFilNm.fm (second subform).
 *              Ascii File (optional): format:
 *				       %attribute name       followed by,
 *				       attribute values
 *				       repeat for each attribute (30 max)
 *
 * History:
 *   MM/DD/YY   AUTHOR  DESCRIPTION
 *   08/25/94   R.Manem Creation
 *   09/18/95   rmn     fixed TR # 179527581 : crash
 *                      when string lenths exceed 80 chars.
 *                      Use ASend_fence correctly.
 *   04/02/96   rmn     fixed locate to accept piping.
 *                      fixed bug in modifying att value in form
 *
 *   06/10/97   EJM     CR#179527294  Add "Read from File" capability
 *
 *			This command now handles user attributes input from
 *			an ascii file. The "Read from file" button
 *			(VD_K_DFLTS_BTN) was activated on the parent form, 
 *			VDmodUsrAtt. When selected, the subform, 
 *			VDdflValues.fm, displays names, values and value 
 *			choices. Another subform, VDKyInFilNm.fm, appears if
 *			the search button is used to find a file.
 *                      Module, VDmodAttrCallBack, was added (from struct).
 *
 *   07/28/97   EJM     CR#179602470  Add "Copy Attributes" capability
 *
 *			Can now copy attributes from one object to another.
 *			New code in method form_notification under "case
 *			VD_K_COPY_ATTRS_BTN".
 *		
 *   04/15/99   EJM     CR#179900526: Increase maximum number of default
 *			values - _CALLOC(MX_ATTR_DFLTS, VDdefaultValues);
 *			also, load ppl file to get path of specific attri-
 *			bute files.
 *	/08/05/02	ylong		TR6614, delete GRgrset/GRsvset
 ***************************************************************************/


class implementation VDCmdUsrAtt;




#include "OMprimitives.h"
#include "OMmacros.h"
#include "string.h"
#include "vdparmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "exproto.h"
#include "VDCmdDef.h"
#include "VDusrAtt.h"	    /* defines gadget labels, under vdinclude */
#include "coparamac.h"
#include "coparadef.h"
#include "vdsetmacros.h"
#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"

#include "vddfltvalsfm.h"   /* VD_K_DFLTS_MCF     */
/*
#define vdsDEBUG
*/
#include "v_dbgmacros.h"    /* CR179602470: added */

#include "VDtypedef.h"		/* for types in VDppl1.h */
#include "VDppl1.h"		/* vdppl macros		 */
#include "VDmem.h"		/* _CALLOC		 */
#include "v_miscmacros.h"	/* vd_$is_ancestry_valid */

extern  GRclassid       OPP_GRgrset_class_id ;

from	GRgrset		import	GSdissolve;

/*
#define DEBUG
*/

#define MAXROWSIZE         80

%safe
static char     curPATH[MAXPATHLEN      +1]     = ".",
                curNAME[FILENAME_MAX    +1]     = "usrAttrs",
                curRGXP[VD_K_MAX_RGXP]          = "*" ;
%endsafe

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


static void VDmodAttrCallBack(	char *defltValsForm,
				char *pAttrForm,
				int  controlType ) {
  /*
   * This is a call-back after the 'Default Values' form, VDdflValues.fm,
   * has been accepted or canceled.
   * (`parentForm' is the 'Modify User Attribute' form.)
   */

SetProc( VDmodAttrCallBack ); Begin

  switch( controlType ) {

    case FI_ACCEPT: {
     VDdfltValsInfo	*info ;
     int		nbRows ;
     VDdefaultValues	*dflts ;
     int		i, row ;

     /*
      * Feed all selected names & values to master forms 'New attributes' field.
      */
     FIfld_get_num_rows( defltValsForm, VD_K_DFLTS_MCF, &nbRows ) ;
     FIfld_get_num_rows( pAttrForm, VD_K_NEW_ATTR_FLD, &row );

     FIf_get_user_pointer( defltValsForm, (char **) &info ) ;
     dflts = info->defaultValues ;
     for( i = 0 ; i < nbRows ; i++ ) {

        if( dflts[i].curVal > 0 ) {
	  /*
	   * Selected.
	   */
	  int pos = dflts[i].curVal - 1 ;

	  FIfld_set_text( pAttrForm, VD_K_NEW_ATTR_FLD, row,
			  0, dflts[i].attrName, FALSE ) ;
	  FIfld_set_text( pAttrForm, VD_K_NEW_ATTR_FLD, row,
			  2, dflts[i].attrValues[pos], FALSE ) ;
	  row++ ;
	}
      }

      FIg_enable( pAttrForm, VD_K_DFLTS_BTN );
      FIg_enable( pAttrForm, VD_K_COPY_ATTRS_BTN );

      /*
       * Checks for dups, etc.
       */
      ProcessNewAttributes( pAttrForm ) ;
   }
   /* No break intentionally */

   case FI_CANCEL	: {
      unsigned int cmdId ; unsigned short cmdOs ; long msg ;

      FIg_enable( pAttrForm, VD_K_DFLTS_BTN );
      FIg_enable( pAttrForm, VD_K_COPY_ATTRS_BTN );

      FIf_get_cmd_oid_os( pAttrForm, &cmdId, &cmdOs ) ;

      om$send( msg      = message VDS_LOCATE.stop_dynamics_in_form(
		   			                  &msg, defltValsForm ),
   	       targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
      om$send( msg      = message VDS_LOCATE.set_dynamics_in_form(
   				                            &msg, pAttrForm ),
   	       targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
      /*
       * Tell the command that the form has been dismissed so it can
       * zero out its form pointer. To avoid implementing a message just
       * for this we use CEO.form_notification with the arguments form label,
       * gadget label and form set to -1, -1 and NULL respectively.
       */
       om$send( msg      = message CEO.form_notification( -1, -1, 0., NULL ),
                targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
    }
    break ;
  }

End

} /* VDmodAttrCallBack */


/*---------------------
 * state table area
 * 
*/

/*
#define _start 0
#define _getAttr 1
*/

method process_locate ( long * sts )
{
  int		  status = OM_S_SUCCESS;


int               i, j, nbObjs=0; 
struct GRobj_env  *lObjs = NULL;
IGRlong		  msg = 1;

struct GRid	  setId;
struct GRmd_env	  setEnv;

SetProc( process_locate ); Begin

     *sts = VD_SUCCESS;

     /* Initialize pointers to secondary form */
     me->modAttrForm = NULL;
     me->cpAttrForm = NULL;

     /* Initialize pointer to attributes' structure (no init override) */
     me->dfltInfo.defaultValues = NULL;

     /* Added ancestry check to avoid "Accept fence contents/Reject" prompt */
     if( vd_$is_ancestry_valid(
                        object  = &me->event1.located_object[0].located_obj,
                        classid = OPP_GRgrset_class_id ))
     {	
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
       vd$filter_objects(msg	= &msg,
			setId	= &setId );


       /* get the list of located objects */

       status = as$start_fence( set 		 = &setId,
  				set_env		 = &setEnv,
				nb_obj           = &nbObjs,
				p_obj_env        = &lObjs,
				response         = me->response,
				response_data    = me->response_data);

       as$status();

       if( setId.objid != NULL_OBJID ) /* TR6614 */
       {
          om$send (     msg      = message GRgrset.GSdissolve(&msg),
                        targetid = setId.objid,
                        targetos = setId.osnum);
       }

       if( !(status & 1) )
       {
          *sts = VD_ERROR;
          return status;
       }
     } /* if ancestry a set */
     else 
     {
       nbObjs = 1;
       lObjs = _CALLOC( 1, struct GRobj_env );
       if( !(lObjs) )
       {
          *sts = VD_ERROR;
          printf("\nError : dynamic allocation at process_locate\n");
          return OM_E_NODYNMEM;
       }
       lObjs->obj_id  = me->event1.located_object[0].located_obj;
       lObjs->mod_env = me->event1.located_object[0].module_info;
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
quit:

  End

  return OM_S_SUCCESS;
}

/*
 -------------------------------------------------------------------------------
  Method get_attributes

  Copies attributes from a selected object to the multicolumn field on the Copy
  User Attributes subform. Please note that attributes collected by the method,
  "process_locate", in the structure, usrAttrs, are copied into the structure,
  defaultValues, which is the data structure used by the subform's form_notifi-
  cation code. If this were not done, another form_notification routine would
  need to be written and another subform created. Currently, the same subform
  used for "Read User Attributes" is used for copying attributes. 
 -------------------------------------------------------------------------------
*/

method get_attributes( long *sts )
{
     int	      status = OM_S_SUCCESS;
     IGRint           j, 
                      nbAttrs;
     char             *sForm = me->cpAttrForm;
     struct VDusrAtt  usrAtt[256];
     struct ACrg_coll *att;

     VDdefaultValues  *dflts = NULL;



SetProc( get_attributes ); Begin


   /* Note: me->locObjs[0].obj_id.objid has the object id of initial object */
   /*       selected, i.e., the object to receive new attributes;           */
   /*       me->event1.located_object[0].located_obj.objid is the object id */
   /*       of the second object selected, i.e., the object whose attri-    */
   /*       butes will be copied.                                           */
   /*       Using me->event1 with vd$getUsrAttributes here, allows          */
   /*       vd$modUsrAttributes to write new attributes to the first object.*/


#ifdef	vdsDEBUG
printf("\n\n [%d, %d]: object to copy attributes from\n",
                  me->event1.located_object[0].located_obj.objid,
                  me->event1.located_object[0].located_obj.osnum);
#endif

     status = vd$getUsrAttributes( 
                        sts     = sts,
                        object  = me->event1.located_object[0].located_obj, 
                        md_env  = &me->event1.located_object[0].module_info,
                        nbAttrs = &usrAtt[0].nb[0],
                        att     = &usrAtt[0].att[0]);

     if( status == OM_W_UNKNOWN_MSG || 
         status == OM_W_REJECTED_METHOD )
     {
#ifdef	vdsDEBUG
               printf("\n\nWARNING : Invalid object [%d, %d] located.\n",
                  me->event1.located_object[0].located_obj.objid,
                  me->event1.located_object[0].located_obj.osnum);
               printf("\tDeselecting object\n");
#endif
               UI_status( "Invalid object located - deselecting it" );

               status = om$send( msg = message VDCmdUsrAtt.delFromList( 
                                                        sts , 0 ),
                                 targetid = my_id );
               as$status();
     }


     *sts = VD_SUCCESS;
     
/*   dflts = me->defaultValues;  previous code */

     if( me->dfltInfo.defaultValues == NULL )
     {
	me->dfltInfo.defaultValues = 
  			_CALLOC(MX_ATTR_DFLTS, VDdefaultValues);
        if( !(me->dfltInfo.defaultValues) )
        {
          *sts = VD_ERROR;
          printf("\nError : dynamic allocation at get_attributes\n");
          return OM_E_NODYNMEM;
        }
     }

     dflts = me->dfltInfo.defaultValues;

     nbAttrs = usrAtt[0].nb[0];
     att = usrAtt[0].att[0];

     FIfld_set_num_rows( sForm, VD_K_DFLTS_MCF, nbAttrs );

     if( !nbAttrs )
          printf("\n   nbAttrs = 0 \n");

     for( j = 0 ; j < nbAttrs ; j++ )
     {
          FIfld_set_text( sForm, VD_K_DFLTS_MCF, j, 0, att[j].name, FALSE );
     
	  strcpy( dflts[j].attrName, att[j].name );
          dflts[j].count = 0;
	  dflts[j].curVal = -1;

          switch( att[j].desc.type )
          {
               case AC_ATTRIB_TEXT :

               case AC_ATTRIB_TYPE_NOT_DEF :

	  	    strcpy( dflts[j].attrValues[0], att[j].desc.value.att_txt );
                    FIfld_set_text( sForm, VD_K_DFLTS_MCF, j, 1, 
                                    att[j].desc.value.att_txt, FALSE );
                    FIfld_set_text( sForm, VD_K_DFLVL_FLD, j, 0, 
                                    att[j].desc.value.att_txt, FALSE );
               break;

               case AC_ATTRIB_DOUBLE :

		    sprintf(dflts[j].attrValues[0],"%g", att[j].desc.value.att_exp );
                    FIfld_set_value( sForm, VD_K_DFLTS_MCF, j, 1, 
                                    att[j].desc.value.att_exp, FALSE );
                    FIfld_set_value( sForm, VD_K_DFLVL_FLD, j, 0, 
                                    att[j].desc.value.att_exp, FALSE );
               break;

               default :

                    printf("\nUnknown type for attribute\n");
	  	    strcpy( dflts[j].attrValues[0], att[j].desc.value.att_txt );
                    FIfld_set_text( sForm, VD_K_DFLTS_MCF, j, 1, 
                                    att[j].desc.value.att_txt, FALSE );
                    FIfld_set_text( sForm, VD_K_DFLVL_FLD, j, 0, 
                                    att[j].desc.value.att_txt, FALSE );
               break;
         
          } /* switch */
     } /* for */

     VDfi_msgkey( sForm, VD_I_SelObjsToBeCopied );

End
     return OM_S_SUCCESS;
}


method wrap_up ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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

     if( me->modAttrForm ) {
	VIf_delete( me->modAttrForm );
	me->modAttrForm=NULL;  
     }
     if( me->cpAttrForm ) {
       VIf_delete( me->cpAttrForm );
       me->cpAttrForm=NULL;
     }

     /* reset the main form */
     FIf_reset( me->forms[0].form_ptr );
     goto quit;

quit:
  return OM_S_SUCCESS;
}

method dspAttrs ( int elmNo )
{
  int		  status = OM_S_SUCCESS;

     int              oldInd;
     long             msg ;
     char             *pForm = me->forms[0].form_ptr ;
     struct GRobj_env elm;


SetProc( dspAttrs ); Begin


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


     goto quit;
quit:

  End

  return OM_S_SUCCESS;
}

method delFromList ( long *sts; int elmNo )
{
  int		  status = OM_S_SUCCESS;

     int i;


SetProc( delFromList ); Begin


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

quit:

  End

  return OM_S_SUCCESS;
}

method operation ( long * sts )
{
  int		  status = OM_S_SUCCESS;

     char             *form = me->forms[0].form_ptr ;
     int              i, j, k,
                      nb[4],
                      elmNo,
                      total = 0 ;
     long             msg;
     struct ACrg_coll *att = NULL;
     struct GRobj_env  locObj;


SetProc( operation ); Begin


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
quit:

  End

  return OM_S_SUCCESS;
}

method mouse ( long     *msg;
              char     *form;
              int      x; 
              int      y )
{
  int		  status = OM_S_SUCCESS;

     int   label ;


     /* just to remove compiler warning */

     status = OM_S_SUCCESS;

     /* case statements below only for parent form, not a subform */
     if( form != me->forms[0].form_ptr )   goto quit; 

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

                         case VD_K_COPY_ATTRS_BTN  : 
                              m = VD_I_CpAttrToObj   ; break ;

                         case VD_K_DFLTS_BTN    : 
                              m = VD_I_LdAttrFrFile  ; break ;

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

quit:

  return OM_S_SUCCESS;
}

method form_notification ( int      form_label; 
                          int      gadget_label; 
                          double   value;
                          char     *form_ptr )
{
  int		  status = OM_S_SUCCESS;

     int   resp,
           i, j,
           sel,
           pos,
           row,
           dest;
     long  msg;
     char  buffer[MAXROWSIZE];

     struct GRid	pplID;


     SetProc( VDCmdUsrAtti.form_notification ); Begin
     __DBGpr_int("form_label", form_label);
     __DBGpr_int("form_ptr", form_ptr);
     __DBGpr_int("gadget_label", gadget_label);
     __DBGpr_dbl("value", value);

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
	       /* Changed resp from VD_FORM_CANCEL to TERMINATE; */
	       /* to eliminate possible memory faults, besides,  */
	       /* cancel should mean no more processing.         */

               resp = TERMINATE;
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
               // tr179800344
               // FIg_erase( form_ptr, VD_K_UATT_GRP );
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

               __DBGpr_str("Text string to be moved to original list", buffer);

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

	  case VD_K_COPY_ATTRS_BTN: {

               /* Display subform */
               int x, y ;
               FIf_get_location( form_ptr, &x, &y ) ; x += 200 ; y += 200 ;
               me->dfltInfo.numDefaultsWanted= -1 ; /* No limit */
               me->dfltInfo.parentForm       = form_ptr ;
               me->dfltInfo.maxNumDefaults   = MX_ATTR_DFLTS ;
	       if( me->dfltInfo.defaultValues == NULL )
	       {
		me->dfltInfo.defaultValues = 
			_CALLOC(MX_ATTR_DFLTS, VDdefaultValues);
		if( !(me->dfltInfo.defaultValues) )
		{
		  printf("\nError : dynamic allocation under COPY_ATTRS_BTN\n");
		  me->ret = VD_ERROR;
                  me->state = _terminate;
		}
	       }
/*             me->dfltInfo.defaultValues    = me->defaultValues ; */
               me->dfltInfo.currentDefault   = 0 ;
               me->dfltInfo.callBack         = VDmodAttrCallBack ;
               me->dfltInfo.fileForm         = NULL ;
               me->dfltInfo.fileInfo.curPATH = curPATH ;
               me->dfltInfo.fileInfo.curNAME = curNAME ;
               me->dfltInfo.fileInfo.curRGXP = curRGXP ;
               me->cpAttrForm                = VDcreateDefaultValuesForm(
                                         x, y, &me->dfltInfo, gadget_label ) ;
               if( me->cpAttrForm ) {
                 long msg ;

                 FIf_set_cmd_oid_os( me->cpAttrForm, my_id, OM_Gw_current_OS ) ;

                 FIg_disable( form_ptr, gadget_label ) ;

                 om$send( msg = message VDS_LOCATE.stop_dynamics_in_form(
                                                                         &msg, form_ptr),
                          targetid = my_id ) ;
                 om$send( msg = message VDS_LOCATE.set_dynamics_in_form(
                                                             &msg, me->cpAttrForm ),
                          targetid = my_id ) ;
                }


		/* Go to "on GR_UNKNOWN_TYPE.VD_K_COPY_ATTRS_BTN"      */
                /* under state, getAttr, which invokes state, copyAttr */

	        _put_response(resp = VD_K_COPY_ATTRS_BTN);
              }

              break ;

          case VD_K_DFLTS_BTN : {
	       IGRint	ret;
	       IGRlong  sts;
	       IGRchar	attrFile[128];
	       IGRchar	filePath[128];

               int x, y ;
               FIf_get_location( form_ptr, &x, &y ) ; x += 200 ; y += 200 ;

		// Get specific attribute filename ONLY if one object located,
		//   NOT a fence set.

	       if( me->nbLocObjs == 1 ){
		// Send located objid to GetAdditionalAttributesFileName and 
		// get appropriate filename back.

		pplID.objid = NULL_OBJID;
		vdppl$Load(name = "VDgetFileNm.u", pplID = &pplID);
		if (pplID.objid == NULL_OBJID) {
		  printf("Could not load PPL file, VDgetFileNm.u\n");
		  goto quit;
		}

		// Set global for located object
		sts = vdppl$SetData(pplID = &pplID,
		    name  = "OBJ_OE",
		    size  = sizeof(struct GRobj_env),
		    data  = (IGRchar*)&me->locObjs[0]);
		__CheckRC( sts, 1, "vdppl$SetData", quit );
		
		// Run PPL function to retrieve filename for located object
		sts = vdppl$Run(pplID = &pplID, 
		    name  = "GetAdditionalAttributesFileName",
		    ret   = &ret);
		/* ret = return sts from GetAdditionalAttributesFileName */
		__CheckRC( sts, ret, "vdppl$Run", quit );

		// Get the filename
		sts=vdppl$GetData(pplID = &pplID,
		  name  = "OBJ_FILENAME",
		  size  = 128,
		  data  = attrFile);
		__CheckRC( sts, 1, "vdppl$GetData", quit );

		if( attrFile == NULL ){
		  UI_status( "No attribute filename for this type object" );
		  strcpy( curPATH, "." ) ;
		  strcpy( curNAME, "usrAttr" ) ;
		}
		else{
		  // Get the filename
		  sts=vdppl$GetData(pplID = &pplID,
		    name  = "OBJ_PATH",
		    size  = 128,
		    data  = filePath);
		  __DBGpr_str("filePath", filePath);
		  __DBGpr_str("attrFile", attrFile);
		  strcpy( curPATH, filePath ) ;
		  strcpy( curNAME, attrFile ) ;
		}
	       }
	       else{
		// More than one object selected, display a default filename
		strcpy( curPATH, "." ) ;
		strcpy( curNAME, "usrAttr" ) ;
	       }

               if( !*curPATH ) strcpy( curPATH, "." ) ;
               if( !*curNAME ) strcpy( curNAME, "usrAttr" ) ;
               me->dfltInfo.numDefaultsWanted= -1 ; /* No limit */
               me->dfltInfo.parentForm       = form_ptr ;
               me->dfltInfo.maxNumDefaults   = MX_ATTR_DFLTS ;
	       if( me->dfltInfo.defaultValues == NULL )
	       {
		me->dfltInfo.defaultValues = 
			_CALLOC(MX_ATTR_DFLTS, VDdefaultValues);
		if( !(me->dfltInfo.defaultValues) )
		{
		  printf("\nError : dynamic allocation under DFLTS_BTN\n");
		  me->ret = VD_ERROR;
                  me->state = _terminate;
		}
	       }
/*             me->dfltInfo.defaultValues    = me->defaultValues ;  */
               me->dfltInfo.currentDefault   = 0 ;
               me->dfltInfo.callBack         = VDmodAttrCallBack ;
               me->dfltInfo.fileForm         = NULL ;
               me->dfltInfo.fileInfo.curPATH = curPATH ;
               me->dfltInfo.fileInfo.curNAME = curNAME ;
               me->dfltInfo.fileInfo.curRGXP = curRGXP ;
               me->modAttrForm               = VDcreateDefaultValuesForm(
                                           x, y, &me->dfltInfo, gadget_label ) ;
             if( me->modAttrForm ) {
               long msg ;
               FIf_set_cmd_oid_os( me->modAttrForm, my_id, OM_Gw_current_OS ) ;

               FIg_disable( form_ptr, gadget_label ) ;

               om$send( msg = message VDS_LOCATE.stop_dynamics_in_form(
                                                                       &msg, form_ptr),
                        targetid = my_id ) ;
               om$send( msg = message VDS_LOCATE.set_dynamics_in_form(
                                                           &msg, me->modAttrForm ),
                        targetid = my_id ) ;
              }
            }
            break ;
      } /* end switch */

      goto quit;

quit:

  if (pplID.objid != NULL_OBJID) vdppl$Delete(pplID = &pplID);
  End
  return OM_S_SUCCESS;
}

end implementation VDCmdUsrAtt;
