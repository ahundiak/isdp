/* $Id: VDCmdRvIt_Fn.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdRvIt_Fn.I
 *
 * Description : These are the functions used by "Review Element with
 *		 Item Numbers" command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRvIt_Fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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
# Revision 1.14  1995/09/13  22:24:46  pinnacle
# Replaced: vdannot/cmd/VDCmdRvIt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.13  1995/08/25  21:15:54  pinnacle
# Replaced: vdannot/cmd/VDCmdRvIt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.12  1995/08/24  17:25:44  pinnacle
# Replaced: vdannot/cmd/VDCmdRvIt_Fn.I for:  by tlbriggs for vds.240
#
# Revision 1.11  1995/08/22  21:10:50  pinnacle
# Replaced: vdannot/cmd/VDCmdRvIt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.10  1995/08/16  15:44:34  pinnacle
# Replaced: vdannot/cmd/VDCmdRvIt_Fn.I for:  by yzhu for vds.240
#
# Revision 1.3  1994/12/22  22:51:54  pinnacle
# Replaced:  vdannot/cmd/VDCmdRvIt_Fn.I r#
#
# Revision 1.2  1994/12/20  17:17:12  pinnacle
# Replaced:  vdannot/cmd/VDCmdRvIt* r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#

 *
 * History:
 *
 *	02/15/94	Raju		Creation Date  
 *      03/05/94	Adz		Correction if case no reference file is 
 *					attached. The function GRgetctxsuper() 
 *                              	return no object, when no reference file
 *					is attached.
 *	12/20/94	R. Manem	VDdisplayItemsInOs : to display
 *					parent objects of item numbers
 *					located in reference files.
 *	12/22/94	R. Manem	VDdisplayItemsInOs : check for 
 *					ASsource, ACpretend parent along with
 *					ASsourcein and ACpretendin
 *	06/15/95	tlb		Modify for new VDitem, VDitemMgr
 *	07/18/95	yzhu		Add  VDitem_get_tblID_from_tblName
 *	08/24/95	tlb		Fix type of VDrevItemCmpString
 *
 * -------------------------------------------------------------------*/

class implementation Root ;


#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "refdef.h"
#include "dpmacros.h"
#include "dp.h"
#include "asbox.h"
#include "growner.h"
#include "vdandef.h"
#include "nddef.h"
#include "dimdef.h"
#include "AS_status.h"

#include "v_miscmacros.h"
#include "vdsmacros.h"
#include "VDSannot.h"
#include "v_dbgmacros.h"


/*
#define DEBUG
*/

extern	OM_p_OSD *OM_GA_OSDs;
extern	GRclassid	OPP_VDitem_class_id,
			OPP_DMsrc_class_id,
			OPP_ASsourcein_class_id,
			OPP_ASsource_class_id,
			OPP_ACpretendin_class_id,
			OPP_ACpretend_class_id,
			OPP_VDdrw2d_class_id,
			OPP_ACncpx_class_id;

extern	DPerase_hilite(),
	UI_status();

from  GRcontext  import GRgetinstance;
from  NDnode     import ASreturn_go;
from  VDitem     import VDgetItemInfo;
from  GRgraphics import GRdisplay;
from  ACcpx      import find_macro;
from  ACcpx_defn import ACgive_name;
from  NDnode     import NDget_objects;
from  NDmacro    import ACreturn_foot;
#ifdef FOO

/* ------------------------------------------------------------------------
 *  Function : VDgetItemsInOs
 *
 *  Des : This function gets the item no.s and their object ids in a given os.
 *
 *  Return code :
 *			1  :  success
 *			0  :  failure
 *  History :
 *        Raju       02/15/94   Creation
 *
 * -------------------------------------------------------------------------- */

long  VDgetItemsInOs(
  OMuword	Osnum,		/* I - os name to get items from */
  IGRint	MaxItems,	/* I - size of ItemNbs, ItemIds  */
  IGRint	ItemNbs[],	/* O - Item numbers in the os    */
				/*   = NULL,  list not created   */
  GRobjid       ItemIds[],	/* O - object ids of items in the os */
				/*   = NULL,  list not created   */
  IGRint	*nbItems	/* O - no. of items found in the os  */
)
{

int	sts;
int	i_obj, max_obj, ItemCount;
int	nb, i1, i2;
IGRlong msg;
GRclassid obj_class;
IGRint	tmpNb;
GRobjid tmpObjid;


  max_obj = OM_GA_OSDs[Osnum]->CurSpaceMapSize;

  ItemCount = 0;
  for( i_obj=0; i_obj<max_obj; i_obj=i_obj+1 )
  {

      sts = om$get_classid(objid = i_obj,
                           osnum = Osnum,
                           p_classid = &obj_class);
      if(!(sts&1)) continue;

      sts = om$is_ancestry_valid(subclassid = obj_class,
                                 superclassid = OPP_VDitem_class_id);
      if((sts != OM_S_SUCCESS)) 
	     	continue;

      sts = om$send(msg = message VDitem.VDgetItemInfo( &msg, &nb, 
							 NULL ),
		    targetid = i_obj,
		    targetos = Osnum,
		    senderid = NULL_OBJID);
      if(!(sts&1)) continue;

      if ( ItemNbs != NULL ) ItemNbs[ItemCount] = nb;
      if ( ItemIds != NULL ) ItemIds[ItemCount] = i_obj;
      ItemCount++;
      if ( ItemCount == MaxItems ) break;
  }
  *nbItems = ItemCount;

  /*
   * sort the item no.s  and object ids
   */
  if ( ItemNbs != NULL )
  {  for( i1=0; i1<*nbItems-1; i1++ )
	for ( i2=i1;  i2<*nbItems; i2++ )
	{
	  if( ItemNbs[i1] > ItemNbs[i2] )
	  {
	     tmpNb     = ItemNbs[i1];
	     ItemNbs[i1] = ItemNbs[i2];
	     ItemNbs[i2] = tmpNb;

	     if ( ItemIds != NULL )
	     {  tmpObjid  = ItemIds[i1];
	        ItemIds[i1] = ItemIds[i2];
	        ItemIds[i2] = tmpObjid;
	     }
	  }  /*  if ( ItemNbs[i1] > ItemNbs[i2] ) */
	} /* for loop */
  }  /*  if ( ItemNbs != NULL ) */

  return 1;

} /*  VDgetItemsInOs  */
#endif FOO
 /*-------------------------------------------------------------------------- */

long VDitem_VRCorr_to_VRComp(
  struct GRid   *Obj        /* I/O - model object(3d)  */
)
{
int             VDComp_class = TRUE, loc1_msg, loc2_msg;
GRclassid       classid;
struct GRid     object;
IGRlong         status;

       SetProc( VDitem_VRCorr_to_VRComp );  Begin

           VDComp_class = TRUE;
           status =
           om$get_classid (    classname = "VRComponent",
                               p_classid = &classid );

           if ( ! ( status & 1 ) ) VDComp_class = FALSE;
           loc1_msg = ( VDComp_class && DMancestry_valid (
                             *Obj, classid ) );

           if ( loc1_msg ) {
             int       j;

             for( j = 0 ; j < OM_K_MAXINT ; j++ ) {

                   status = om$get_objid_at_index(
                         objid   = Obj->objid,
                         osnum   = Obj->osnum,
                         index   = j,
                         p_chanselect = &AS_to_owner,
                         objidaddr    = &object.objid,
                         osnumaddr    = &object.osnum);
                   if( !(status & 1) ) {
                       break;
                   }

                   VDComp_class = TRUE;
                   status =
                   om$get_classid (        classname = "VRCorrection",
                                           p_classid = &classid );
                   if ( ! ( status & 1 ) ) VDComp_class = FALSE;

                   loc2_msg = ( VDComp_class && DMancestry_valid (object,
                                                                  classid) );

                   __DBGpr_obj( "object", object );

                   if ( loc2_msg ) {
                     *Obj = object;       // We found the VRCorrection
                     break;
                   }
             } /* for */
        } /* if */

        status = OM_S_SUCCESS;
        End
        return status;
}


/*
 *  This function is used by qsort
 */

static int VDrevItemCmpString ( const void *a, const void *b )
{
   return strcmp( (char *)a, (char *)b );
}

/*
 *  This function removes duplicates from a sorted list
 */

static int VDrevRemoveDuplicates ( int *nbStrings,
				   char stringList[][OM_K_MAXOSNAME_LEN],  
				   int stringSize )
{
   int		ii, tmpNoStrings;
   char		**tmpStringList;

   if (  * nbStrings <= 1 ) return 1;
/*
   tmpStringList = (char **) malloc ( sizeof(char **) * (*nbStrings));
*/
   tmpStringList = _MALLOC((*nbStrings), char *);
   if ( tmpStringList == NULL ) 
   {
	printf( "VDrevRemoveDuplicates : Can not allocate memory\n" );
	return 0;
   }

   tmpNoStrings = 1;
   tmpStringList[0] = stringList[0];
   for ( ii=1; ii<*nbStrings; ii++ )
	if ( strncmp(stringList[ii], stringList[ii-1], stringSize) )
	    tmpStringList[ tmpNoStrings++ ] = stringList[ii];
	
   for ( ii=0; ii<tmpNoStrings; ii++)
	strncpy( stringList[ii], tmpStringList[ii], stringSize );

   *nbStrings = tmpNoStrings;

   _FREE ( tmpStringList );

   return 1;

}

/* --------------------------------------------------------------------------
 *  Function : VDSgetActiveFileList
 *
 *  Des : This function gets the list of all active files and sorts them.
 *
 *  Return code :
 *			1  :  success
 *			0  :  failure
 *  History :
 *        Raju       02/15/94   Creation
 *
 * -------------------------------------------------------------------------- */
long VDSgetActiveFileList( 
  long 		*msg,			/*  O - return code		*/
  int		ListSize,		/*  I - size of ActiveFileList  */
  int		*nbActiveFile,		/*  O - no. of active files	*/
  char 		ActiveFileList[][OM_K_MAXOSNAME_LEN]
					/*  O - active file names	*/
)

{

	long 		sts,		/* OM return code		*/
			numberOfBytes,
			BytesReceived ;
	char 		Osname[OM_K_MAXOSNAME_LEN];
	short		flag ;
	int  		count,		/* ... of contexts		*/
			FileCount,	/* Count of  files		*/
    			i ;		/* Loop index			*/
	OMuword		Osnum ;		/* Osnum of a file		*/
	struct GRid	ctxId,		/* the context id 		*/	
			rfmgr ;		/* Id of ref. file mgr		*/
	OM_S_CHANSELECT rfmgrTOctx ;	/* Ref. file mgr -> context	*/
	struct GRmd_env	ctxEnv,		/* Environment from context	*/
			ActiveEnv ;	/* Environment of master file	*/


	FileCount	= 0 ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	if( nbActiveFile ) *nbActiveFile = 0 ;

	numberOfBytes = sizeof ActiveEnv ;
	gr$get_module_env(	msg	= msg,
				sizbuf	= &numberOfBytes,
				buffer	= &ActiveEnv,
				nret	= &BytesReceived ) ;

#ifdef DEBUG
	printf( "Active osnum : [%d]\n", ActiveEnv.md_id.osnum ) ;
#endif

	/*
	 * Get all attached files 
	 */
	sts = om$make_chanselect(
				channame	= "Super_rfmgr.to_context",
				p_chanselect	= &rfmgrTOctx ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Get the context Super.
	 */
	sts = GRgetctxsuper( msg, &rfmgr ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = om$get_channel_count(	osnum		= rfmgr.osnum,
					objid		= rfmgr.objid,
					p_chanselect	= &rfmgrTOctx,
					count		= (OMuint *) &count ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Loop on contexts.
	 */
	for( i = 0 ; i < count ; ++i ) {

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
						msg,
						&ctxEnv.md_env.matrix_type,
						ctxEnv.md_env.matrix,
						&Osnum,
						&flag,
						&ctxId ),
			senderid	= rfmgr.objid,
			targetos	= rfmgr.osnum,
			p_chanselect	= &rfmgrTOctx,
			to		= i,
			from		= i ) ;

		if( !( 1 & sts & *msg ) ) continue ;

		/*
		 * See if this object space is active before
		 * trying to use this context object.
		 */
		 sts = om$os_number_to_name(	osnum	= Osnum,
						osname	= Osname ) ;
		if( !( 1 & sts ) ) {
			/*
			 * Skip this osnum.
			 */
#ifdef	DEBUG
			printf( "No OS name for [%s]\n", Osnum ) ;
#endif
			continue ;
		}

#ifdef DEBUG
		printf( "Osnum  : [%d]\n", Osnum ) ;
		printf( "Osname : [%s]\n", Osname ) ;
#endif

		if( ActiveFileList )
			strcpy( ActiveFileList[FileCount++], Osname );

		/*
		 * check the size of the list
		 */
		if ( FileCount == ListSize ) break;	

	} /* End for */

	if( nbActiveFile ) *nbActiveFile = FileCount ;

        /*
         *   sort the file list 
         */
        if ( *nbActiveFile > 0 )
	{
		qsort ( ActiveFileList, *nbActiveFile, 
			sizeof(char) * OM_K_MAXOSNAME_LEN,
			VDrevItemCmpString);
 	}

        /*
         *  Remove the duplicates from the list
         */
        sts = VDrevRemoveDuplicates (  nbActiveFile, ActiveFileList,
					OM_K_MAXOSNAME_LEN );

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VDSgetActiveFileList */

/* --------------------------------------------------------------------------
 *  Function : VDdisplayItemsInOs
 *
 *  Des : This function displays item objects and their parts in the given os
 *
 *  Return code :
 *			1  :  success
 *			0  :  failure
 *  History :
 *        Raju       02/15/94   Creation
 *
 * -------------------------------------------------------------------------- */
long  VDdisplayItemsInOs (
  long		*msg,		/* O - return code  */
  OMuword	Osnum,		/* I - os in question */
  int		NbItems,	/* I - no. of items to be displayed */
  GRobjid	*ItemIds	/* I - object ids of the items */
)
{
long		sts,
		bytes,
		received,
		loc_msg;
int		i_obj,
		index,
		found = 0,
		suc,
		count,
		i;
struct	GRid	part,
		rfmgr,
		ctxId;
struct	GRmd_env ModEnvItems, ModEnvObj;
enum	GRdpmode dpmode;
GRclassid 	obj_class;
OM_S_CHANSELECT rfmgrTOctx;	/* Ref. file mgr -> context	*/
OMuword		TmpOsnum;
short		flag;

   SetProc( VDdisplayItemsInOs); Begin
   sts  = OM_S_SUCCESS;
   *msg = MSSUCC;

   dpmode = GRhd;
   __DBGpr_int( " Osnum ", Osnum );

   /*
    * get current module environment
    */
   bytes = sizeof( struct GRmd_env );
   sts = gr$get_module_env(   msg     = &suc,
                              sizbuf  = &bytes,
                              buffer  = &ModEnvItems,
                              nret    = &received );

   __DBGpr_int( " ModEnvItems.md_id.osnum", ModEnvItems.md_id.osnum );
   if( ModEnvItems.md_id.osnum !=  Osnum ){

      /*
       * Get module environment of the given OS
       */
      sts = om$make_chanselect(
                             channame        = "Super_rfmgr.to_context",
                             p_chanselect    = &rfmgrTOctx ) ;
      if( !( sts & 1 ) ) goto wrapup ;

      /*
       * Get the context Super.
       */
      sts = GRgetctxsuper( msg, &rfmgr ) ;
      if( !( sts & 1 & *msg ) ) goto wrapup ;

      sts = om$get_channel_count(   osnum           = rfmgr.osnum,
                                    objid           = rfmgr.objid,
                                    p_chanselect    = &rfmgrTOctx,
                                    count           = (OMuint *) &count ) ;
      if( !( sts & 1 ) ) goto wrapup ;

      __DBGpr_int( " count", count );

      /*
       * Loop on contexts.
       */
      for( i = 0 ; i < count ; i++ )
      {
            sts = om$send(
                 msg     = message GRcontext.GRgetinstance(
                                              msg,
                                              &ModEnvItems.md_env.matrix_type,
                                              ModEnvItems.md_env.matrix,
                                              &TmpOsnum,
                                              &flag,
                                              &ctxId ),
                  senderid        = rfmgr.objid,
                  targetos        = rfmgr.osnum,
                  p_chanselect    = &rfmgrTOctx,
                  to              = i,
                  from            = i ) ;

           if( !( 1 & sts & *msg ) ) continue ;
   
	   if ( TmpOsnum == Osnum ) break;

      }

      if ( i >= count )
      {  printf( "Display items in OS : can not find OS [%d] \n", Osnum );
         goto Error;
      }
   }

   __DBGpr_int( " TmpOsnum", TmpOsnum );

   ModEnvItems.md_id.osnum = Osnum;
   ModEnvItems.md_id.objid = NULL_OBJID;

   /*
    *  loop over the items and display them
    */
   for( i_obj=0; i_obj<NbItems; i_obj++)
   {

#ifdef  DEBUG
      printf(" i = [%d], Item object : [%d,%d]\n", i_obj, ItemIds[i_obj],
						   Osnum );
#endif

      sts =
      om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
						&ModEnvItems.md_env.matrix_type,
						ModEnvItems.md_env.matrix,
						&dpmode,
						&ModEnvItems.md_id),
	      targetid = ItemIds[i_obj],
	      targetos = Osnum,
	      senderid = NULL_OBJID );

      __DBGpr_int( " ItemIds", ItemIds[i_obj]);

      found = 0;
      for( index = 0 ; index < OM_K_MAXINT && !found ; index = index+1 ){

	sts = om$get_objid_at_index(objid = ItemIds[i_obj],
                                    osnum = Osnum,
                                    index = index,
                                    p_chanselect = &ND_father,
                                    objidaddr = &part.objid,
                                    osnumaddr = &part.osnum);
	if(!(sts&1)) break;

        __DBGpr_obj( " Part object", part);
        sts = om$get_classid(objid = part.objid,
                             osnum = part.osnum,
                             p_classid = &obj_class);
        if(!(sts&1)) continue;

        ModEnvObj = ModEnvItems;

        sts = om$is_ancestry_valid(subclassid = obj_class,
                                superclassid = OPP_ACncpx_class_id);
        if((sts != OM_S_SUCCESS)) 
        {
             /* check for source object */
        
             __DBGpr_com( " check for source object");

             if( (om$is_ancestry_valid(subclassid = obj_class,
                     superclassid = OPP_ASsourcein_class_id ) == OM_S_SUCCESS)
	       || (om$is_ancestry_valid(subclassid = obj_class,
		     superclassid = OPP_ACpretendin_class_id ) == OM_S_SUCCESS)
	       || (om$is_ancestry_valid(subclassid = obj_class,
		     superclassid = OPP_ACpretend_class_id ) == OM_S_SUCCESS)
	       || (om$is_ancestry_valid(subclassid = obj_class,
		     superclassid = OPP_ASsource_class_id ) == OM_S_SUCCESS))
	     {

                 sts = om$send( msg	= message NDnode.ASreturn_go( &part,
						&ModEnvObj.md_env.matrix_type,
						ModEnvObj.md_env.matrix ),
				targetid= part.objid,
				targetos= part.osnum,
		    		senderid = NULL_OBJID);
                 if( !(sts & 1) )
                     break;

                __DBGpr_obj( " Go = ", part);

		found = 1;
   		ModEnvItems.md_id.osnum = part.osnum;
   		ModEnvItems.md_id.objid = NULL_OBJID;

             }
             else
	 	 continue;
        }
        else
		found = 1;
   
        __DBGpr_int( " found = ", found);

        if( found )
        {
           sts =
	   om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
					&ModEnvObj.md_env.matrix_type,
					ModEnvObj.md_env.matrix,
					&dpmode,
					&ModEnvObj.md_id),
		   targetid = part.objid,
		   targetos = part.osnum,
		   senderid = NULL_OBJID );
        }
      }
   }

wrapup:
   return 1;

Error:
   return 0;
}  /*  VDdisplayItemsInOs  */
/* --------------------------------------------------------------------------
 *  Function : VDdisplayItemsNoBln
 *
 *  Des : This function displays objects with items but  without ballons 
 *
 * Status/Return Code
 *     status == OM_S_SUCCESS      for succesful
 *     status == OM_E_ABORT        for unsuccesful
 *  History :
 *        Y.Zhu         07/15/94   Creation
 *
 * -------------------------------------------------------------------------- */
long  VDdisplayItemsNoBln(
  long          *msg,           /* O - return code  */
  OMuword       *Osnum,         /* I - os of items  */
  int           NbItems,        /* I - no. of objecs to be displayed */
  GRobjid       *ItemIds        /* I - object ids of the items without ballon */
)
{
long            status,
                bytes,
                received,
                loc_msg;
int             j,
                suc,
                count,
                i, i0;
struct  GRid    rfmgr,
                ctxId;
struct  GRmd_env ModEnvItems, ModEnvObj;
enum    GRdpmode dpmode;
OM_S_CHANSELECT rfmgrTOctx;     /* Ref. file mgr -> context     */
OMuword         TmpOsnum;
short           flag;
struct GRid     ModelId;
IGRint          NbPrtnd, NbDrw2d;
OM_S_CHANSELECT to_child;
struct GRid     *Prtnd = NULL,
                *Drw2d = NULL;

   SetProc( VDdisplayItemsNoBln); Begin
   status  = OM_S_SUCCESS;
   *msg = MSSUCC;
   dpmode = GRhd;

   for( j = 0; j < NbItems; j++) {
   
     __DBGpr_int( " Osnum ", Osnum[j] );

     /*
      * get current module environment
      */
   
     bytes = sizeof( struct GRmd_env );

     status = gr$get_module_env(   msg     = &suc,
                              sizbuf  = &bytes,
                              buffer  = &ModEnvItems,
                              nret    = &received );

     __DBGpr_int( " ModEnvItems.md_id.osnum ", ModEnvItems.md_id.osnum);
  
   
     if( ModEnvItems.md_id.osnum !=  Osnum[j] ){

      /*
       * Get module environment of the given OS
       */
      status = om$make_chanselect(
                             channame        = "Super_rfmgr.to_context",
                             p_chanselect    = &rfmgrTOctx ) ;
      if( !( status & 1 ) ) goto wrapup ;

      /*
       * Get the context Super.
       */
      status = GRgetctxsuper( msg, &rfmgr ) ;
      if( !( status & 1 & *msg ) ) {
          status = OM_E_ABORT;
          goto wrapup ;
      }

      status = om$get_channel_count(osnum           = rfmgr.osnum,
                                    objid           = rfmgr.objid,
                                    p_chanselect    = &rfmgrTOctx,
                                    count           = (OMuint *) &count ) ;

      if( !( status & 1 ) ) goto wrapup ;
      __DBGpr_int( " count ", count );


      /*
       * Loop on contexts.
       */
      for( i = 0 ; i < count ; i++ ) {
           status = om$send(
                 msg     = message GRcontext.GRgetinstance(
                                              msg,
                                              &ModEnvItems.md_env.matrix_type,
                                              ModEnvItems.md_env.matrix,
                                              &TmpOsnum,
                                              &flag,
                                              &ctxId ),
                  senderid        = rfmgr.objid,
                  targetos        = rfmgr.osnum,
                  p_chanselect    = &rfmgrTOctx,
                  to              = i,
                  from            = i ) ;

           if( !( 1 & status & *msg ) ) continue ;

           if ( TmpOsnum == Osnum[j] ) break;

       } /* for i */
       __DBGpr_int( " TmpOsnum ", TmpOsnum );

       if ( i >= count ) {  
         printf( "Display items in OS : can not find OS [%d] \n", Osnum );
         status = OM_E_ABORT;
         goto wrapup;
       }
     }


     ModEnvItems.md_id.osnum = Osnum[j];
     ModEnvItems.md_id.objid = NULL_OBJID;

     ModEnvObj = ModEnvItems;

     status =
     om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                                &ModEnvItems.md_env.matrix_type,
                                                ModEnvItems.md_env.matrix,
                                                &dpmode,
                                                &ModEnvItems.md_id),
              targetid = ItemIds[j],
              targetos = Osnum[j],
              senderid = NULL_OBJID );
      
     as$status();

     __DBGpr_int( " ItemIds ", ItemIds[j] );
     __DBGpr_int( " Osnum ", Osnum[j] );

     /* get VDdrw2d object if exist */
     ModelId.osnum = Osnum[j];
     ModelId.objid = ItemIds[j];


     status = om$make_chanselect(channame      = "NDchildren.children",
                                 p_chanselect  = &to_child);

     status = VDitem_VRCorr_to_VRComp (&ModelId); 

     /*
      * Get the ACpretendin's / ASsourcein's on the notification channel
      * Both are subclassed from NDnodein
      */

     NbPrtnd = 0;

     status = VDGetGridsFromChan_of_Class ( msg, ModelId,
                                             &AS_notification,
                                             -OPP_NDnodein_class_id
                                               /*OPP_ACpretendin_class_id*/,
                                             &NbPrtnd, &Prtnd );

     if( !(status & *msg & 1)) continue;
 
     __DBGpr_int( " NbPrtnd ", NbPrtnd );

     for ( i = 0; i < NbPrtnd; i++ ) {
     
        NbDrw2d = 0;

        status = VDGetGridsFromChan_of_Class ( msg, Prtnd[i],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d, &Drw2d);
        if( !(status & *msg & 1)) continue;
 
        __DBGpr_int( " NbDrw2d ", NbDrw2d);
        
        /* get env of Drw2d */
        for ( i0 = 0; i0 < NbDrw2d; i0++ ) { 
          status =
          _VD_SEND_OBJN(   Drw2d[i0],
                           NDmacro.ACreturn_foot(
                                                msg,
                                                "",
                                                &Drw2d[i0],
                                                &ModEnvObj.md_env.matrix_type,
                                                ModEnvObj.md_env.matrix ));
          if( !(status&*msg&1) ) continue ;
          __DBGpr_mat(" matrix", ModEnvObj.md_env.matrix);

          ModEnvObj.md_id.osnum = Drw2d[i0].osnum;
          ModEnvObj.md_id.objid = NULL_OBJID;

          status =
          om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                           &ModEnvObj.md_env.matrix_type,
                                            ModEnvObj.md_env.matrix,
                                           &dpmode,
                                           &ModEnvObj.md_id),
              targetid = Drw2d[i0].objid,
              targetos = Drw2d[i0].osnum,
              senderid = NULL_OBJID );
      
          as$status();
        }  /* for i0 */
       
           _FREE( Drw2d );
           Drw2d = NULL;
      }  /* for i */
           _FREE( Prtnd );
           Prtnd = NULL;
   } /* for j*/

wrapup:

           _FREE( Drw2d );
           _FREE( Prtnd );
   End
   return status;
}  /*  VDdisplayItemsNoBln  */

/* --------------------------------------------------------------------------
 *  Function : VDdisplayItemsBln
 *
 *  Des : This function displays objects and their item objects  with ballons
 *
 * Status/Return Code
 *     status == OM_S_SUCCESS      for succesful
 *     status == OM_E_ABORT        for unsuccesful
 *  History :
 *        Y.Zhu         08/15/94   Creation
 *
 * -------------------------------------------------------------------------- */
long  VDdisplayItemsBln(
  long          *msg,           /* O - return code  */
  OMuword       *Osnum,         /* I - os of items  */
  int           NbItems,        /* I - no. of objecs to be displayed */
  GRobjid       *ItemIds        /* I - object ids of the items without ballon */
)
{
long            	status,i0,
                	bytes,
                	received,
                	loc_msg;
int             	j, suc, count, i, index, found;
GRclassid       	obj_class;
struct  GRid    	rfmgr, ctxId, part, part1;
struct  GRmd_env 	ModEnvItems, ModEnvObj;
enum    GRdpmode 	dpmode;
OM_S_CHANSELECT 	rfmgrTOctx;     /* Ref. file mgr -> context     */
OMuword         	TmpOsnum;
short           	flag;
IGRint          	NbPrtnd, NbDrw2d;
OM_S_CHANSELECT 	to_child;
struct GRid     	*Prtnd = NULL,
                	*Drw2d = NULL;

   SetProc( VDdisplayItemsBln); Begin
   status  = OM_S_SUCCESS;
   *msg = MSSUCC;
   dpmode = GRhd;


   status =om$make_chanselect(channame  = "NDchildren.children",
                                 p_chanselect  = &to_child);


   for( j = 0; j < NbItems; j++) {

     __DBGpr_int( " Osnum ", Osnum[j] );

     /*
      * get current module environment
      */

     bytes = sizeof( struct GRmd_env );

     status = gr$get_module_env(   msg     = &suc,
                              sizbuf  = &bytes,
                              buffer  = &ModEnvItems,
                              nret    = &received );

     __DBGpr_int( " ModEnvItems.md_id.osnum ", ModEnvItems.md_id.osnum);


     if( ModEnvItems.md_id.osnum !=  Osnum[j] ){

      /*
       * Get module environment of the given OS
       */
      status = om$make_chanselect(
                             channame        = "Super_rfmgr.to_context",
                             p_chanselect    = &rfmgrTOctx ) ;
      if( !( status & 1 ) ) goto wrapup ;

      /*
       * Get the context Super.
       */
      status = GRgetctxsuper( msg, &rfmgr ) ;
      if( !( status & 1 & *msg ) ) {
          status = OM_E_ABORT;
          goto wrapup ;
      }

      status = om$get_channel_count(osnum           = rfmgr.osnum,
                                    objid           = rfmgr.objid,
                                    p_chanselect    = &rfmgrTOctx,
                                    count           = (OMuint *) &count ) ;

      if( !( status & 1 ) ) goto wrapup ;
      __DBGpr_int( " count ", count );


      /*
       * Loop on contexts.
       */
      for( i = 0 ; i < count ; i++ ) {
           status = om$send(
                 msg     = message GRcontext.GRgetinstance(
                                              msg,
                                              &ModEnvItems.md_env.matrix_type,
                                              ModEnvItems.md_env.matrix,
                                              &TmpOsnum,
                                              &flag,
                                              &ctxId ),
                  senderid        = rfmgr.objid,
                  targetos        = rfmgr.osnum,
                  p_chanselect    = &rfmgrTOctx,
                  to              = i,
                  from            = i ) ;

           if( !( 1 & status & *msg ) ) continue ;

           if ( TmpOsnum == Osnum[j] ) break;

       } /* for i */
       __DBGpr_int( " TmpOsnum ", TmpOsnum );

       if ( i >= count ) {
         printf( "Display items in OS : can not find OS [%d] \n", Osnum );
         status = OM_E_ABORT;
         goto wrapup;
       }
     }

     ModEnvItems.md_id.osnum = Osnum[j];
     ModEnvItems.md_id.objid = NULL_OBJID;


     status =
     om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                                &ModEnvItems.md_env.matrix_type,
                                                ModEnvItems.md_env.matrix,
                                                &dpmode,
                                                &ModEnvItems.md_id),
              targetid = ItemIds[j],
              targetos = Osnum[j],
              senderid = NULL_OBJID );

     as$status();

     __DBGpr_int( " ItemIds ", ItemIds[j] );
     __DBGpr_int( " Osnum ", Osnum[j] );

      found = 0;
      for( index = 0 ; index < OM_K_MAXINT && !found ; index = index+1 ){

        status = om$get_objid_at_index(objid = ItemIds[j],
                                    osnum = Osnum[j],
                                    index = index,
                                    p_chanselect = &ND_father,
                                    objidaddr = &part.objid,
                                    osnumaddr = &part.osnum);

        __DBGpr_obj( " Part object", part);

        status = om$get_classid(objid = part.objid,
                             osnum = part.osnum,
                             p_classid = &obj_class);
        if(!(status&1)) continue;

        ModEnvObj = ModEnvItems;

        status = om$is_ancestry_valid(subclassid = obj_class,
                                superclassid = OPP_ACncpx_class_id);

        if((status != OM_S_SUCCESS)) {
             /* check for source object */

             __DBGpr_com( " check for source object");

             if( (om$is_ancestry_valid(subclassid = obj_class,
                     superclassid = OPP_ASsourcein_class_id ) == OM_S_SUCCESS)
               || (om$is_ancestry_valid(subclassid = obj_class,
                     superclassid = OPP_ACpretendin_class_id ) == OM_S_SUCCESS)
               || (om$is_ancestry_valid(subclassid = obj_class,
                     superclassid = OPP_ACpretend_class_id ) == OM_S_SUCCESS)
               || (om$is_ancestry_valid(subclassid = obj_class,
                     superclassid = OPP_ASsource_class_id ) == OM_S_SUCCESS))
             {

                 status = om$send( msg     = message NDnode.ASreturn_go( &part1,
                                                &ModEnvObj.md_env.matrix_type,
                                                ModEnvObj.md_env.matrix ),
                                targetid= part.objid,
                                targetos= part.osnum,
                                senderid = NULL_OBJID);
                if( !(status & 1) )
                     break;
                __DBGpr_obj( " part in source ", part1);

                found = 1;
                ModEnvObj.md_id.osnum = part1.osnum;
                ModEnvObj.md_id.objid = NULL_OBJID;
  
                status =
                om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                        &ModEnvObj.md_env.matrix_type,
                                        ModEnvObj.md_env.matrix,
                                        &dpmode,
                                        &ModEnvObj.md_id),
                   targetid = part1.objid,
                   targetos = part1.osnum,
                   senderid = NULL_OBJID );
           
                as$status();
 		status = VDitem_VRCorr_to_VRComp ( & part1 );
                /*
      		 * Get the ACpretendin's / ASsourcein's on the notification 
                 * channel  Both are subclassed from NDnodein
      		 */

     		NbPrtnd = 0;

     		status = VDGetGridsFromChan_of_Class ( msg, part1,
                                             &AS_notification,
                                             -OPP_NDnodein_class_id
                                               /*OPP_ACpretendin_class_id*/,
                                             &NbPrtnd, &Prtnd );

     		if( !(status & *msg & 1)) continue;

     		__DBGpr_int( " NbPrtnd ", NbPrtnd );

                /* find VDdrw2d project */
                /*
                 * get all ACpretendin objects from the notification channel
                 */

                for ( i = 0; i < NbPrtnd; i++ ) {
                	__DBGpr_obj( " NbPrtnd ", Prtnd[i] );
                } 
                for ( i = 0; i < NbPrtnd; i++ ) {

                    NbDrw2d = 0;

                    status = VDGetGridsFromChan_of_Class ( msg, Prtnd[i],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d, &Drw2d);
        
                    if( !(status & *msg & 1)) continue;

                    __DBGpr_int( " NbDrw2d ", NbDrw2d);

                    /* get env of Drw2d */

                    for ( i0 = 0; i0 < NbDrw2d; i0++ ) {
       
                      status =
                      _VD_SEND_OBJN(   Drw2d[i0],
                          NDmacro.ACreturn_foot(
                                                msg,
                                                "",
                                                &Drw2d[i0],
                                                &ModEnvObj.md_env.matrix_type,
                                                ModEnvObj.md_env.matrix ));

                      if( !(status&*msg&1) ) continue ;
       
                      __DBGpr_mat(" matrix", ModEnvObj.md_env.matrix);
                      __DBGpr_int(" matrix type", ModEnvObj.md_env.matrix_type);

                      ModEnvObj.md_id.osnum = Drw2d[i0].osnum;
     
                      ModEnvObj.md_id.objid = NULL_OBJID;

                      status =
                      om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                           &ModEnvObj.md_env.matrix_type,
                                           ModEnvObj.md_env.matrix,
                                           &dpmode,
                                           &ModEnvObj.md_id),
                      targetid = Drw2d[i0].objid,
                      targetos = Drw2d[i0].osnum,
                      senderid = NULL_OBJID );

                      as$status();
                    }  /* for i0 */

                    _FREE( Drw2d );
                     Drw2d = NULL;
                  }  /* for i */
           
               	  _FREE( Prtnd );
           	  Prtnd = NULL;
   	       } /* if*/
               else 
                    continue;
          }
          else {
             found = 1;

             __DBGpr_int( " found = ", found);

             status =
             om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                        &ModEnvObj.md_env.matrix_type,
                                        ModEnvObj.md_env.matrix,
                                        &dpmode,
                                        &ModEnvObj.md_id),
                   targetid = part.objid,
                   targetos = part.osnum,
                   senderid = NULL_OBJID );
             as$status();
          }
      } /* for index */
   } /* for j*/

   status = OM_S_SUCCESS;

wrapup:
   _FREE(Drw2d);
   _FREE(Prtnd);
   End
   return status;
}  /*  VDdisplayItemsBln */


/* --------------------------------------------------------------------------
 *  Function : VDitem_get_tblID_from_tblName
 *
 *  Des : This function get table id from table name
 *
 *  Return code :
 *                      1  :  success
 *                      0  :  failure
 *  History :
 *        YZhu       07/18/95   Creation
 *
 * -------------------------------------------------------------------------- */
long  VDitem_get_tblID_from_tblName(
  long          *msg,           /* O - return code  */
  char          *tblName,       /* I - table name*/
  struct GRid   *tblId)         /* O - table Id  */
{
IGRlong                status = OM_S_SUCCESS;
IGRint                 count, i;
IGRchar                dirname[80];
IGRchar                superClassName[80];
IGRint                 ref_file;
struct VD_id_name     *IdName = NULL;
IGRchar                tablename[80];  

  SetProc(VDitem_get_tblID_from_tblNam); Begin
  /*
   * Get all table names from :designfile:usr:drw_tables
   */

  *msg = MSSUCC;
  strcpy( dirname, "drw_tables");
  strcpy( superClassName, "VDdrwTbl");

  ref_file = 1; 
  count    = 0;

  status =
  VD_get_tableName ( msg, dirname, superClassName, &count, ref_file, &IdName);

  if ( ! count || ! ( status & *msg & 1 ) )
  {
    UI_status ( "No BOM Table Defined; Terminating Command" );

    status = OM_W_ABORT;
    goto wrapup;
  }

  status = OM_W_ABORT;
  /* check matching table name */
  for(i = 0; i < count; i ++ ) {
    tablename[0] = '\0';
    strcat( tablename, IdName[i].tbl_name);
    strcat( tablename, "[");
    strcat( tablename, IdName[i].deg_file.fname);
    strcat( tablename, "]");

    if ( !strcmp( tblName, tablename)) {
        *tblId = IdName[i].tbl_id;
        status = OM_S_SUCCESS;
        break;
    } 
  } 

wrapup:
  _FREE(IdName);
  End
  return status;
}
/* --------------------------------------------------------------------------
 *  Function : VDitem_get_objId_from_itemId
 *
 *  Des : This function get assoicated object id from item id
 *
 *  Return status/code :
 *           status = OM_S_SUCCESS: success
 *           status = OM_E_ABORT:  failure
 *  History :
 *        YZhu       07/18/95   Creation
 *
 * -------------------------------------------------------------------------- */
long  VDitem_get_objId_from_itemId(
  long          *msg,           /* O - return code  */
  struct GRid   itemId,         /* I - item id  */
  struct GRid   *objId)         /* O - object id  */
{
IGRlong             status = OM_S_SUCCESS;
struct GRid         objSrc, obj, obj1, obj2, macro;
IGRint              count,index,found = 0;
struct GRmd_env     objEnv;
struct GRobj_env    parent;
IGRchar             *c;

     SetProc( VDitem_get_objId_from_itemId); Begin

     *msg = MSSUCC;
     objSrc.objid = NULL_OBJID ;

     status =
     _VD_SEND_OBJN(  itemId,
                    NDnode.NDget_objects(   ND_ROOT,
                                            &objSrc,
                                            1, NULL,
                                            DIM_ROOT_LOC,
                                            DIM_ROOT_LOC,
                                            &count));
     if( ( !(status&1) ) || ( objSrc.objid == NULL_OBJID )){
                status = OM_E_ABORT;         
		goto wrapup ;
     }

     __DBGpr_obj(" Root of itemId(objSrc) ", objSrc);

     /*
      * Check if the parent is the source objects.
      */
     if( vd_$is_ancestry_valid(object = &objSrc,
                               classid = OPP_DMsrc_class_id )){
         /*
          * get ACpretend
          */
         found = 0 ;
         for( index=0; index<10 && !found ; index++){

               status =
               om$get_objid_at_index(  objid = objSrc.objid,
                                       osnum = objSrc.osnum,
                                       index = index,
                                       p_chanselect = &ND_father,
                                       objidaddr = &obj.objid,
                                       osnumaddr = &obj.osnum);

               if(!(status&1)) break;  /* nothing left */

	       __DBGpr_obj(" father of objSrc(obj)", obj);

               status =
               _VD_SEND_OBJN(   obj,
                                NDmacro.ACreturn_foot(
                                                msg,
                                                "",
                                                &obj1,
                                                &objEnv.md_env.matrix_type,
                                                objEnv.md_env.matrix ));
               if( !(status&*msg&1) ) continue ;

               __DBGpr_obj(" foot of obj(obj1)", obj1);

               ASget_as_owner( &obj1, &obj );
               __DBGpr_obj(" owner of obj1(obj)", obj);

               status =
               _VD_SEND_OBJN(   obj,
                                NDmacro.ACreturn_foot(
                                                msg,
                                                "",
                                                &obj1,
                                                &objEnv.md_env.matrix_type,
                                                objEnv.md_env.matrix ));
               if( !(status&*msg&1) ) continue ;

               parent.obj_id   = obj1 ;
               parent.mod_env  = objEnv ;


               /*
         	* test on objects for macro src_obj.
                */

                macro.objid = NULL_OBJID ;
                status =
                om$send(msg = message ACcpx.find_macro(&macro),
                                senderid = NULL_OBJID,
                                targetid = obj1.objid,
                                targetos = obj1.osnum );
                as$status();

                if( macro.objid == NULL_OBJID ) continue ;

                        status =
                        om$send(msg = message ACcpx_defn.ACgive_name( &c ),
                                 senderid = NULL_OBJID,
                                 targetid = macro.objid,
                                 targetos = macro.osnum);
                        as$status();

                        if( strcmp( c, "src_obj" ) == 0 ){

                                /*
                                 * Get the parent object. (index=0 );
                                 */
                                status =
                               _VD_SEND_OBJN( obj1,
                                        NDnode.NDget_objects(   ND_ROOT,
                                                                &obj2,
                                                                1, NULL,
                                                                0,0,&count ));
                                status =
                                _VD_SEND_OBJN(   obj2,
                                        NDmacro.ACreturn_foot(
                                                msg,
                                                "",
                                                &obj1,
                                                &objEnv.md_env.matrix_type,
                                                objEnv.md_env.matrix ));
                                 if( !(status &*msg& 1) ) continue ;

                                parent.obj_id   = obj1 ;
                                parent.mod_env  = objEnv ;
                        
                                found = 1;
                        } /* if src_obj */
             } /* for index ... */
      } /* DMsrc */
      else {
                status = OM_E_ABORT;
                goto wrapup ;
      }

      /* set object id */
          *objId = parent.obj_id;
 
wrapup:
  End
  return status;
} /* VDitem_get_objId_from_itemId */

end implementation Root;
