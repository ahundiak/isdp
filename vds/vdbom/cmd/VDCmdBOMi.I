/* $Id: VDCmdBOMi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDCmdBOMi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdBOMi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
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
# Revision 1.5  1995/01/23  19:10:48  pinnacle
# Replaced:  vdbom/cmd/VD* r#
#
# Revision 1.4  1994/12/30  22:40:48  pinnacle
# Replaced:  vdbom/cmd/VDCmdBOMi.I tr# 179424276
#
# Revision 1.3  1994/12/12  20:47:42  pinnacle
# Replaced:  vdbom/cmd/*.[IS] r#
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *                      R. Manem        Creation date
 *      12/07/94        R. Manem        OPE enhancements :
 *                                      - ProcessColDesc adapted to new form
 *                                      - my_init, initialization of additional
 *                                        instance data
 *	12/12/94	R. Manem	- leader line support
 *					- init_from_bom : non-assoc case 
 *	12/30/94	R. Manem	- init_from_bom : compute mod env
 *					  correctly from the object's contextid
 *	01/23/95	R. Manem	Validate format for %OBJ_NAME and
 *					%OBJ_TYPE in ProcessColDesc
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdBOM;

#include "OMprimitives.h"
#include "OMmacros.h"
#include "string.h"
#include "nddef.h"
#include "gr.h"
#include "grmacros.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "exproto.h"
#include "VDCmdDef.h"
#include "VDbom.h"
#include "dim.h"
#include "dimdef.h"
#include "dimmacros.h"
#include "coparamac.h"
#include "coparadef.h"
#include "vdparmacros.h"
#include "vdsetmacros.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"
#include "VDmsg.h"

/*
#define DEBUG
*/

from NDnode          import NDget_objects;
from ACcpx           import find_macro;
from ACcpx           import ACfind_exp_temp_obj;
from ASnode          import ASreturn_go;

from GRvg	import GRgetrang;
from GRcontext	import GRgetmodule_env;

extern int VDdet_get_def_units();

/*+fe
 -------------------------------------------------------------------------
  Function VDfillAttrForm

  Abstract
      This function fills the attributes form 

  Arguments

      char              *form     I     pointer to the form
      struct GRobj_env  obj       I     Object whose attributes are to be
                                        filled in the form

 -------------------------------------------------------------------------
-fe*/



long VDfillAttrForm( long               *sts,
                     char               *form,
                     struct GRobj_env   obj )
{
     IGRint           i, j,
                      nbAttrs; 
     IGRlong          status;
     struct ACrg_coll *att = NULL;

     *sts = MSSUCC;

     /* Reset the mcf */

     FIg_reset( form, VD_LST_ATTR_FLD );

     /* Get the number of attribtues for the object */

     status = vd$get_parameters( sts       = sts,
                                 object    = &obj.obj_id,
                                 md_env    = &obj.mod_env,
                                 count     = &nbAttrs );

     as$status();

#ifdef DEBUG
     printf("\n No of attributes = %d\n", nbAttrs );
#endif

     /* allocate space for the attributes */

     att = (struct ACrg_coll *)malloc( sizeof( struct ACrg_coll) * nbAttrs );
    
     if( att == NULL )
     {
               *sts = VD_ERROR;
               printf("\nError : Dynamic allocation\n");
               status = OM_E_NODYNMEM;
               goto wrapup;
     }
     
     /* get the list of attributes for the object */

     status = vd$get_parameters( sts       = sts,
                                 object    = &obj.obj_id,
                                 md_env    = &obj.mod_env,
                                 plist     = att,
                                 size      = nbAttrs,
                                 count     = &nbAttrs );

     as$status();

     FIfld_set_num_rows( form, VD_LST_ATTR_FLD, nbAttrs );

     for( i = 0 ; i < nbAttrs ; i++ )
     {
          for( j = strlen( att[i].name ) - 1; j >= 0 ; j-- )
               if( att[i].name[j] == ':' )
                    break;
          j++;

          FIfld_set_text( form, VD_LST_ATTR_FLD, i, 0, &att[i].name[j], FALSE );
     
          switch( att[i].desc.type )
          {
               case AC_ATTRIB_TEXT :

               case AC_ATTRIB_TYPE_NOT_DEF :

                    FIfld_set_text( form, VD_LST_ATTR_FLD, i, 1, "txt", FALSE );
                    FIfld_set_text( form, VD_LST_ATTR_FLD, i, 2, 
                                    att[i].desc.value.att_txt, FALSE );
               break;

               case AC_ATTRIB_DOUBLE :
                    FIfld_set_text( form, VD_LST_ATTR_FLD, i, 1, "dbl", FALSE );
                    FIfld_set_value( form, VD_LST_ATTR_FLD, i, 2, 
                                    att[i].desc.value.att_exp, FALSE );
               break;

               default :
                    printf("\nUnknown type for attribute\n");
                    FIfld_set_text( form, VD_LST_ATTR_FLD, i, 1, "txt", FALSE );
                    FIfld_set_text( form, VD_LST_ATTR_FLD, i, 2, 
                                    att[i].desc.value.att_txt, FALSE );
               break;
         
          }
     }

wrapup :
     if( att )
          free( att );
     return status;
}

static void RemoveBlanks( char *str )
{
     int i, j, len;
     char newstr[80];

     j = 0;
     len = strlen( str );
     for( i = 0 ; i < len ; i++ )
          if( str[i] != ' ' )
               newstr[j++] = str[i];
     newstr[j] = '\0';
     strcpy( str, newstr );
}

     
long ProcessColDesc( char *form )
{
     int         i, 
                 j,
                 len,
                 index,
                 sel,
                 pos,
                 colWidth,
                 nrows;
     char        name[MAXROWSIZE],
                 sortOrder[4],
                 sortIndex[4],
                 title[MAXROWSIZE],
                 Width[MAXROWSIZE],
                 format[MAXROWSIZE],
                 buf[MAXROWSIZE],
                 just[5];
                 
     long        sts = VD_SUCCESS;


     FIfld_get_num_rows( form, VD_COL_DESC_FLD, &nrows ) ;
     i = 0;
     while( i < nrows )
     {
          /* get attribute name */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 0, MAXROWSIZE,
                          (unsigned char *)name, &sel, &pos );

          /* delete row if name is NULL */

          if( !strlen( name ) )
          {
               FIfld_delete_rows( form, VD_COL_DESC_FLD, i, 1 );
               nrows--;
               continue;
          }

          /* Print message for duplicate column names */

          for( j = 0 ; j < i ; j++ )
          {
               FIfld_get_text( form, VD_COL_DESC_FLD, j, 0, MAXROWSIZE,
                               (unsigned char *)buf, &sel, &pos );
               if( !strcmp( name, buf ) )
               {
                    char info[MAXROWSIZE];

                    sprintf( info, "<%s> duplicated", name );

                    FIfld_set_text( form, FI_MSG_FIELD, 0, 0, info, FALSE );
                    UI_status( info );

                    sts = VD_RESTART_CMD;
                    goto quit;
                }
          }

          /* validate sort order */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 1, 4,
                          (unsigned char *)sortOrder, &sel, &pos );

          len = strlen(sortOrder);

#ifdef DEBUG
     printf("\nProcessColDesc : sortOrder = %s, len = %d\n", sortOrder, len );
#endif
          sortIndex[0] = '\0';
          if( len > 0 )
          {
               strncpy( sortIndex, sortOrder, len-1 );
               sortIndex[len-1] = '\0';

#ifdef DEBUG
     printf("\nsortIndex = %s", sortIndex );
#endif

               index = atoi( sortIndex );

#ifdef DEBUG
     printf("\nindex = %d", index );
#endif
               if( len > (SORT_LEVEL + 1) || (index < 1) || 
                                             (index > SORT_LEVEL) ||
                                             (sortOrder[len-1] != '<' &&
                                              sortOrder[len-1] != '>') )
                   FIfld_set_text( form, VD_COL_DESC_FLD, i, 1, "", FALSE );
          }

          /* if title is NULL then set it to attribute name */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 2, MAXROWSIZE,
                          (unsigned char *)title, &sel, &pos );

          if( !(len = strlen( title )) )
          {
               if( name[0] == '%' )
                    strcpy( title, &name[1] );
               else
                    strcpy( title, name );
               
               /* convert to uppercase */

               for( i = 0 ; i < len ; i++ )
                    title[i] = (char) toupper( (int) (title[i]) );

               FIfld_set_text( form, VD_COL_DESC_FLD, i, 2, title, FALSE );
          }

          /* validate column width */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 3, MAXROWSIZE,
                          (unsigned char *)Width, &sel, &pos );
          colWidth = atoi( Width );

#ifdef DEBUG
     printf("\nAttr %d : column width = %d\n", i,  colWidth );
#endif
          if( colWidth <= 0 || colWidth > MAX_COL_WIDTH )
          {
               sprintf( Width, "%d", MAX_COL_WIDTH );
               FIfld_set_text( form, VD_COL_DESC_FLD, i, 3, 
                               Width, FALSE );
               colWidth = MAX_COL_WIDTH;
          }

          /* validate justification */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 4, 5,
                          (unsigned char *)just, &sel, &pos );
          if( just[0] == 'C' || just[0] == 'c' ||
              just[0] == 'L' || just[0] == 'l' ||
              just[0] == 'R' || just[0] == 'R' )
          {
               just[1] = '\0';
               FIfld_set_text( form, VD_COL_DESC_FLD, i, 4, 
                               (unsigned char *)just, FALSE );
          }
          else
          {
               strcpy( just, "L" );
               FIfld_set_text( form, VD_COL_DESC_FLD, i, 4, 
                               (unsigned char *)just, FALSE );
          }

          /* validate format string */

          FIfld_get_text( form, VD_COL_DESC_FLD, i, 5, MAXROWSIZE,
                          (unsigned char *)format, &sel, &pos );

          RemoveBlanks( format );

          len = strlen( format );
          if( ( !strcmp( "%OBJ_NAME", name ) || !strcmp( "%OBJ_TYPE", name ) )
						&& format[len-1] != 's' )
               strcpy( format, "%s" );

          FIfld_set_text( form, VD_COL_DESC_FLD, i, 5, 
                           (unsigned char *)format, &sel, &pos );
          i++;
     }

quit :
     return sts;
}


/*---------------------
 * state table area
 */



#define _start 0
#define _getFormat 1
#define _getCoordSys 2

method my_init ( long * sts )
{
     int	  status = OM_S_SUCCESS;
     int          i;

     struct DMsenv_param	par_senv;

     *sts = VD_SUCCESS;

#ifdef DEBUG
     printf("\nIn my_init : \n");
#endif

     me->nbLocObjs = 0;
     me->curObjIndex = 0;
     me->csGrid.obj_id.objid = NULL_OBJID;
     me->leaderFlag = 1;
     me->ldrLine.segs = NULL;

     /* initialize current os */

     status = ex$get_cur_mod( osnum = &me->curOS );
     as$status();

     for( i = 0 ; i < SORT_LEVEL ; i++ )
          strcpy( me->sortAttrLst[i], "" );

     /* 
      * initialize the balloon parameters - used for Create BOM command 
      * for Modify BOM command - init_from_bom  will overwrite these values 
      */

     status = dm$get_dim_param( type    = DM_SENV_PARAM,
                                p_data  = (char *)&par_senv );
     as$status();

     me->blnType = par_senv.bln_type;
     me->blnSize = par_senv.bln_size;
     me->blnSides = par_senv.num_sides;
     
#ifdef DEBUG
     printf("\nblnType = %d, size = %g, sides = %d\n",  me->blnType,
							me->blnSize,
							me->blnSides );
#endif

     goto quit;

quit:
  return OM_S_SUCCESS;
}

method wrap_up ( long * sts )
{
  int		  status = OM_S_SUCCESS;

     /* Unhighlight the current element */

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex(sts,
                                                                me->curObjIndex,
                                                                GRbdhe ),
                       targetid = my_id );
     as$status();

     /* Unhighlight the coordinate system */

     status = gr$display_object( object_id      = &me->csGrid.obj_id,
                                 md_env         = &me->csGrid.mod_env,
                                 mode           = GRbdhe );

     /* Remove all objects from the list */

     status = om$send( msg = message VDS_LOCATE.removeLastLocatedObjects(
                                                                         sts, 
                                                                         0 ),
                       targetid = my_id );
     me->nbLocObjs = 0;
     me->curObjIndex = 0;
  
     /* free the pointer */
 
     if( me->ldrLine.segs )
          free( me->ldrLine.segs );
     
     /* reset the form */

     FIf_reset( me->forms[0].form_ptr );
     goto quit;
quit:
  return OM_S_SUCCESS;
}

method init_from_bom( long *sts )
{
     IGRint            	i,
                       	size,
                       	ret,
                       	intmsg,
                       	nbTempObjs;
     IGRlong           	msg;
     struct GRid       	macro_def,
			setGrid, 
			ctxId, 
			mac,
     			*objList = NULL;
     struct GRmd_env   	MOD_ENV, env;
     GRclassid         	class_id;
     OMuword		os;

     long status = OM_S_SUCCESS;

     *sts = VD_SUCCESS;

     me->nbLocObjs = 0;

     /* get the macro definition */

     status = om$send( msg      = message ACcpx.find_macro( &macro_def ),
                       targetid = me->bomGrid.obj_id.objid,
                       targetos = me->bomGrid.obj_id.osnum );
     as$status();

     mac.objid = me->bomGrid.obj_id.objid;
     mac.osnum = me->bomGrid.obj_id.osnum;

     if( !(status & 1) )
     {
          *sts = VD_RESTART_CMD;
          goto wrapup;
     }

     /* get the number of templates */

     status = om$send( msg     = message NDnode.NDget_objects( ND_ROOT, NULL,
                                                               0, NULL, 0,
                                                               OM_K_MAXINT, 
                                                               &nbTempObjs ),
                       targetid = mac.objid,
                       targetos = mac.osnum );
     as$status();
     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nNo of templates = %d\n", nbTempObjs );
#endif

     /* get the rg collector */

     status = om$send( msg      = message ACcpx.ACfind_exp_temp_obj(&intmsg,
                                                                    0,
                                                                    &me->coll ),
                       targetid = mac.objid,
                       targetos = mac.osnum );
     as$status();

     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }
#ifdef DEBUG
   printf("\nCollector objid = <%d, %d>\n", me->coll.objid, me->coll.osnum );
#endif

     /* get the current module environment */

     size = sizeof( struct GRmd_env );
     status = gr$get_module_env( msg    = &msg,
                                 sizbuf = &size,
                                 buffer = &MOD_ENV,
                                 nret   = &ret );
     as$status();

     /* get the coordinate system ASsource object */
     
     status = om$send( msg     = message ACcpx.ACfind_exp_temp_obj( &intmsg,
                                                                    1,
                                                     &me->csGrid.obj_id),
                      targetid = mac.objid,
                      targetos = mac.osnum );
     as$status();

     if( !(status & 1  ) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }

     me->csGrid.mod_env = MOD_ENV;
     me->csGrid.mod_env.md_id.osnum = me->csGrid.obj_id.osnum;

     /* get the coordinate system GRid */

     status = om$send( msg      = message ASnode.ASreturn_go(&me->csGrid.obj_id, 
                                                              NULL, NULL),
                       targetid = me->csGrid.obj_id.objid,
                       targetos = me->csGrid.obj_id.osnum );
     as$status();
     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nCoord sys objid = <%d, %d>\n", me->csGrid.obj_id.objid,
                                              me->csGrid.obj_id.osnum );
#endif

     /* get the 3rd template, probably a source of VDgrset */

     status = om$send( msg	= message ACcpx.ACfind_exp_temp_obj( &intmsg,
								2,
								&setGrid ),
                      targetid = mac.objid,
                      targetos = mac.osnum );
     as$status();
     if( !(status & 1  ) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nSource set objid = <%d, %d>", setGrid.objid, setGrid.osnum );
#endif

     /* get the set object */

     status = om$send( msg      = message ASnode.ASreturn_go( &setGrid, 
                                                              NULL, NULL),
                      targetid = setGrid.objid,
                      targetos = setGrid.osnum );
     as$status();
     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nActual set objid = <%d, %d>\n", setGrid.objid, setGrid.osnum );
#endif

     status = om$get_classid(   osnum	= setGrid.osnum,
				objid	= setGrid.objid,
				p_classid = &class_id );
     as$status();

     if( om$is_ancestry_valid( subclassid	= class_id,
			       superclassname	= "VDgrset" ) == OM_S_SUCCESS )
     {
          me->assocOption = FALSE;

          status = vd$give_setobjs(	set_grid	= &setGrid,
					set_name	= NULL,
					numcomps	= &me->nbLocObjs );
          as$status();

          if( !me->nbLocObjs )
          {
               *sts = VD_ERROR;
               goto wrapup;
          }

          status = om$vla_set_dimension( varray = me->locObjs,
                                         size   = me->nbLocObjs );
          as$status();
          if( !(status & 1) )
          {
               *sts = VD_ERROR;
               goto wrapup;
          }

          objList = (struct GRid *)malloc( sizeof(struct GRid) *
								me->nbLocObjs );
          if( !objList )
          {
               *sts = VD_ERROR;
               goto wrapup;
          }

          status = vd$give_setobjs(	set_grid	= &setGrid,
					set_name	= NULL,
					numcomps	= &me->nbLocObjs,
					set_objs	= objList );
          as$status();
          if( !(status & 1) )
          {
               *sts = VD_ERROR;
               goto wrapup;
          }

          for( i = 0 ; i < me->nbLocObjs ; i++ )
               me->locObjs[i].obj_id = objList[i];
     }
     else
     {
          me->assocOption = TRUE;

          /* allocate space for the template objects */

          me->nbLocObjs = nbTempObjs - 2;

#ifdef DEBUG
     printf("\n nbLocObjs = %d\n", me->nbLocObjs );
#endif

          status = om$vla_set_dimension( varray = me->locObjs,
                                         size   = me->nbLocObjs );
          as$status();
          if( !(status & 1) )
          {
               *sts = VD_ERROR;
               goto wrapup;
          }

          /* copy each template object to the instance data */

          for( i = 2 ; i < nbTempObjs ; i++ )
          {
               status = om$send( msg = message ACcpx.ACfind_exp_temp_obj( 
						&intmsg, i,
                                                &me->locObjs[i-2].obj_id ),
                                 targetid = mac.objid,
                                 targetos = mac.osnum );

               as$status();

               if( !(status & 1) )
               {
                    *sts = VD_ERROR;
                    goto wrapup;
               }
          
               /* if the object is not a subclass of VDSroot, then return_go */

               status = om$get_classid( 
				osnum        = me->locObjs[i-2].obj_id.osnum,
				objid        = me->locObjs[i-2].obj_id.objid,
				p_classid    = &class_id );

               as$status();

               if( om$is_ancestry_valid( subclassid    = class_id,
                                         superclassname = "VDSroot" ) 
                                                        != OM_S_SUCCESS )
               {
                    status = om$send( msg = message ASnode.ASreturn_go( 
                                                     &me->locObjs[i-2].obj_id,
                                                     NULL, NULL ),
                                      targetid = me->locObjs[i-2].obj_id.objid,
                                      targetos = me->locObjs[i-2].obj_id.osnum);
                    as$status();

                    if( !(status & 1) )
                    {
                         *sts = VD_ERROR;
                         goto wrapup;
                    }
               }
          }
     }

     /* compute the module environment */

     status = ex$get_cur_mod( osnum	= &os );

     for( i = 0 ; i < me->nbLocObjs ; i++ )
     {
          if( me->locObjs[i].obj_id.osnum == os )
               ctxId.objid = NULL_OBJID;
          else
          {
               status = GRfindcontext( 	&msg, NULL, NULL, 
					&me->locObjs[i].obj_id.osnum, &ctxId );
               if( status & 1 )
               {
#ifdef DEBUG
     printf("\ni = %d, ctxId = %d, %d", ctxId.objid, ctxId.osnum );
#endif
                    status = om$send( msg     = message GRcontext.
                                                  GRgetmodule_env( &msg, &env ),
                                      targetid  = ctxId.objid,
                                      targetos  = ctxId.osnum );
                    if( status & 1 )
                         me->locObjs[i].mod_env = env;
                    else
                         ctxId.objid = NULL_OBJID;
               }
               else
                    ctxId.objid = NULL_OBJID;
          }
          if( ctxId.objid == NULL_OBJID )
               me->locObjs[i].mod_env = MOD_ENV;
     }

wrapup :

     return OM_S_SUCCESS;
}

end implementation VDCmdBOM;
