/*
	I/STRUCT
*/
class implementation VSmodattCmd ;

#include <stdio.h>
#include <string.h>
#ifdef X11
#define	MAXPATHLEN	1024
#else
#include <sys/param.h>
#endif 
#include <FI.h>
#include "growner.h"
#include "parametric.h"
#include "vsglobalmsg.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsdfltvalsfm.h"
#include "vsformproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

#define ROOT_FORM	0
#define CHILD_FORM	1
/*
 * Gadget labels on root (parent) form.
 */
#define VS_K_ORI_ATTR_FLD	12
#define VS_K_DEL_ATTR_FLD	16
#define VS_K_MOD_ATTR_FLD	17
#define VS_K_NEW_ATTR_FLD	18
#define VS_K_MOD_ATTR_BTN	32
#define VS_K_REV_ATTR_BTN	31
#define VS_K_DEL_ATTR_BTN	19
#define VS_K_UND_ATTR_BTN	20
#define VS_K_EDT_ATTR_GRP	30
#define VS_K_ATTR_NAM_FLD	11	/* Belongs to group VS_K_EDT_ATTR_GRP */
#define VS_K_ATTR_VAL_FLD	28	/* Belongs to group VS_K_EDT_ATTR_GRP */

#define VS_K_UATTR_FLD	12
#define VS_K_DFLTS_BTN	15	/* Button calling sub-form		*/

#define MAXROWSIZE	64

extern int   COB_FI_form_notification() ;

%safe
static char	curPATH[MAXPATHLEN	+1]	= ".",
		curNAME[FILENAME_MAX	+1]	= "usrAttrs",
		curRGXP[VS_K_MAX_RGXP]		= "*" ;
%endsafe

from VSfeature	import	VSmodUsrAttributes ;
from NDmacro  	import	ACgive_structure ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int IsValidIdentifier( char *text, int type ) {
	int	rc ;
	if( VSmatchRE( "[a-zA-Z][a-zA-Z_0-9]*", text ) ) {
		rc = 0 ;
	} else {
		ex$message( msgnumb = VS_gE_SyntaxError,
			    type    = "%s",
			    var     = `text` ) ;
		rc = 1 ;
	}
	return rc ;

} /* IsValidIdentifier */
/*----------------------------------------------------------------------------*/
method dspAttrs( int elmNo ) {

	long			sts,
				msg ;
	struct GRobj_env	elm ;
	char			*pForm = me->forms[0].form_ptr ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
							&msg, elmNo, &elm ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;

	VSfillUsrAttrForm( pForm, VS_K_ORI_ATTR_FLD,
			   &elm._grid ) ;

	FIfld_set_num_rows( pForm, VS_K_DEL_ATTR_FLD, 0 ) ;
	FIfld_set_num_rows( pForm, VS_K_MOD_ATTR_FLD, 0 ) ;
	FIfld_set_num_rows( pForm, VS_K_NEW_ATTR_FLD, 0 ) ;
	FIg_erase( pForm, VS_K_EDT_ATTR_GRP ) ;
	FIfld_set_verify_routine( pForm, VS_K_NEW_ATTR_FLD, NAMES_COLUMN,
	                          IsValidIdentifier ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method dspAttrs */
/*----------------------------------------------------------------------------*/
static void MvRowAcrossMcfs( char *pForm, int fromMcf, int rowToMv, int toMcf ){

  int      nrows, col, sel, pos ;
  char     buffer[MAXROWSIZE] ;

  FIfld_get_num_rows( pForm, fromMcf, &nrows ) ;
  if( rowToMv >= nrows ) return ; /* Nothing to move ... */

  FIfld_get_num_rows( pForm, toMcf, &nrows ) ;
  FIfld_set_num_rows( pForm, toMcf, nrows + 1 ) ;
  for( col = 0 ; col < 2 ; col++ ) {
    FIfld_get_text( pForm, fromMcf, rowToMv, col, MAXROWSIZE,
    		    (unsigned char*) buffer, &sel, &pos ) ;
    FIfld_set_text( pForm, toMcf, nrows, col, buffer, FALSE ) ;
  }

  FIfld_delete_rows( pForm, fromMcf, rowToMv, 1 ) ;

} /* MvRowAcrossMcfs */
/*----------------------------------------------------------------------------*/
static void Mk1stVisRowActive( char *pForm, int field ) {

	int	nrows ;

	FIfld_get_num_rows( pForm, field, &nrows ) ;
	if( nrows ) {
	  int offset ;

	  FIfld_get_row_offset( pForm, field, &offset ) ;
	  FIfld_set_active_row( pForm, field, offset, 0 ) ;
	  FIfld_set_select( pForm, field, offset, 0, TRUE ) ;  
	}

} /* Mk1stVisRowActive */
/*----------------------------------------------------------------------------*/
static void MkLstVisRowActive( char *pForm, int field ) {

	int	nrows = 0 ;

	FIfld_get_num_rows( pForm, field, &nrows ) ;
	if( nrows ) {
	  int nvisrows ;
	  FIfld_get_num_vis_rows( pForm, field, &nvisrows ) ;
	  if( nrows < nvisrows ) nvisrows = nrows ;
	  FIfld_set_active_row( pForm, field, nrows-1, nvisrows-1 ) ;
	  FIfld_set_select( pForm, field, nvisrows-1, 0, TRUE ) ;  
	}

} /* MkLstVisRowActive */
/*----------------------------------------------------------------------------*/
static void ProcessNewAttributes( char *pForm ) {

  int	 nrowsNEW = 0 ;
  int	 i, j, k ;
  int	 oneRowDeleted ;
  char   bufferNEW[MAXROWSIZE] ;
  char   buffer   [MAXROWSIZE] ;
  int    mcf[3] ;

  VSfld_del_empty_rows( pForm, VS_K_NEW_ATTR_FLD, 0 ) ;

  /*
   * If a new attribute is already in the list of existing, deleted or
   * modified attribute the refuse it.
   */
  mcf[0] = VS_K_ORI_ATTR_FLD ;
  mcf[1] = VS_K_DEL_ATTR_FLD ;
  mcf[2] = VS_K_MOD_ATTR_FLD ;

  FIfld_get_num_rows( pForm, VS_K_NEW_ATTR_FLD, &nrowsNEW ) ;
  for( i = 0 ; i < nrowsNEW ; ) {
    int sel, pos, nrows ;

    FIfld_get_text( pForm, VS_K_NEW_ATTR_FLD, i, 0, MAXROWSIZE,
    		    (unsigned char*) bufferNEW, &sel, &pos ) ;

    oneRowDeleted = FALSE ;
    for( j = 0 ; j < 3 ; j++ ) {
      FIfld_get_num_rows( pForm, mcf[j], &nrows ) ;
      for( k = 0 ; k < nrows ; k++ ) {
        FIfld_get_text( pForm, mcf[j], k, 0, MAXROWSIZE,
    	               (unsigned char*) buffer, &sel, &pos ) ;
        if( !strcmp( bufferNEW, buffer ) ) {
          char	info[MS_MAX_MSG_LENGTH+1] ;

          FIfld_delete_rows( pForm, VS_K_NEW_ATTR_FLD, i, 1 ) ;
	  ex$message( msgnumb = VS_gI_AttrDuplicated,
		      type    = "%s",
		      var     = `bufferNEW`,
		      buff    = info ) ;
          VSfi_msg( pForm, info ) ;
          VS_Wait_timer( 100 ) ;
          oneRowDeleted = TRUE ;
          goto nextNEWrow ;
        }
      }
    }
    nextNEWrow : if( oneRowDeleted ) nrowsNEW-- ; else i++ ;
  }

} /* ProcessNewAttributes */
/*----------------------------------------------------------------------------*/
method mouse( long *msg ; char *pForm ; int x, y ) {

  int	label ;

  if( FIf_find_gadget( pForm, FI_FORM_GROUP, x, y, &label ) == FI_SUCCESS ) {
    static int  prevLabel  = -1 ;
    static char *prevForm  = NULL ;
    if( prevForm != pForm || prevLabel != label ) {
      long m ;
      if( pForm == me->forms[0].form_ptr ) {
        switch( label ) {
          case VS_K_ORI_ATTR_FLD : m = VS_gI_OriginalAttrs ; break ;
          case VS_K_DEL_ATTR_FLD : m = VS_gI_AttrsToBeDel  ; break ;
          case VS_K_MOD_ATTR_FLD : m = VS_gI_AttrsToBeMod  ; break ;
          case VS_K_NEW_ATTR_FLD : m = VS_gI_AttrsToBeCre  ; break ;
          case VS_K_MOD_ATTR_BTN : m = VS_gI_MvOriToMod    ; break ;
          case VS_K_REV_ATTR_BTN : m = VS_gI_UndoMod       ; break ;
          case VS_K_DEL_ATTR_BTN : m = VS_gI_DelAttr       ; break ;
          case VS_K_UND_ATTR_BTN : m = VS_gI_UndelAttr     ; break ;
          case VS_K_DFLTS_BTN    : m = VS_gI_LdAttrFrFile  ; break ;
          default		 : m = VS_gI_EmptyMessage  ; break ;
        }
        VSfi_msgkey( pForm, m ) ;
      } else if( pForm == me->modAttrForm ) {
      	VSexplainDefaultValuesForm( pForm, label ) ;
      }
      prevForm = pForm ; prevLabel = label ;
    }
  }

  *msg = MSSUCC ;
  return OM_S_SUCCESS ;

} /* method mouse */
/*----------------------------------------------------------------------------*/
static void VSmodAttrCallBack(	char *defltValsForm,
				char *modAttrForm,
				int  controlType ) {
  /*
   * This is a call-back after the 'Default Values' form has been accepted or
   * canceled.
   * (`parentForm' is the 'Modify Attribute' form.)
   */
  switch( controlType ) {

    case FI_ACCEPT : {
     VSdfltValsInfo	*info ;
     int		nbRows ;
     VSdefaultValues	*dflts ;
     int		i, row ;
     /*
      * Feed all selected names & values to master forms 'New attributes' field.
      */
     FIfld_get_num_rows( defltValsForm, VS_K_DFLTS_MCF, &nbRows ) ;
     FIfld_get_num_rows( modAttrForm, VS_K_NEW_ATTR_FLD, &row );

     FIf_get_user_pointer( defltValsForm, (char **) &info ) ;
     dflts = info->defaultValues ;
     for( i = 0 ; i < nbRows ; i++ ) {

        if( dflts[i].curVal > 0 ) {
	  /*
	   * Selected.
	   */
	  int pos = dflts[i].curVal - 1 ;

	  FIfld_set_text( modAttrForm, VS_K_NEW_ATTR_FLD, row,
			  0, dflts[i].attrName, FALSE ) ;
	  FIfld_set_text( modAttrForm, VS_K_NEW_ATTR_FLD, row,
			  1, dflts[i].attrValues[pos], FALSE ) ;
	  row++ ;
	}
      }
      /*
       * Checks for dups, etc.
       */
      ProcessNewAttributes( modAttrForm ) ;
   }
   /* No break intentionally */

   case FI_CANCEL	: {
      unsigned int cmdId ; unsigned short cmdOs ; long msg ;

      FIf_get_cmd_oid_os( modAttrForm, &cmdId, &cmdOs ) ;
      FIg_enable( modAttrForm, VS_K_DFLTS_BTN ) ;
      om$send( msg      = message VSlocateCmd.stop_dynamics_in_form(
		   			                  &msg, defltValsForm ),
   	       targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
      om$send( msg      = message VSlocateCmd.set_dynamics_in_form(
   				                            &msg, modAttrForm ),
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

} /* VSmodAttrCallBack */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form ) {


  if( -1 == form_label ) {
    /*
     * Message sent from the file form's call-back which tells us
     * that the form has been dismissed.
     */
    me->modAttrForm = NULL ;

  } else if( ROOT_FORM == form_label ) {

    long	rc ;
    int		resp,
		sel,
		pos,
		row,
		dest ;
    char	buffer[MAXROWSIZE] ;

    FIg_erase( form, VS_K_EDT_ATTR_GRP ) ;

    switch( gadget_label ) {
      case FI_ACCEPT 		:
        resp = VS_K_END_STATE ;
        ex$putque( msg = &rc, response = &resp ) ;
        break ;

      case FI_CANCEL		:
        if( me->modAttrForm ) {
          VSdeleteDftlValsForm( me->modAttrForm ) ; me->modAttrForm = NULL ;
	}
	resp = TERMINATE ;
	ex$putque( msg = &rc, response = &resp ) ;
	break ;

      case VS_K_ORI_ATTR_FLD :
        break ;

      case VS_K_MOD_ATTR_FLD :
        /*
         * Enable edit fields and copy selected attribute (name and
         * value) to it.
         */
        row = (int) value ;
        FIfld_get_text( form, gadget_label, row, 0, MAXROWSIZE,
                        (unsigned char*) buffer, &sel, &pos ) ;
        FIfld_set_text( form, VS_K_ATTR_NAM_FLD, 0, 0, buffer, FALSE ) ;
        FIfld_get_text( form, gadget_label, row, 1, MAXROWSIZE,
                        (unsigned char*) buffer, &sel, &pos ) ;
        FIfld_set_text( form, VS_K_ATTR_VAL_FLD, 0, 0, buffer, FALSE ) ;
        FIg_display( form, VS_K_EDT_ATTR_GRP ) ;
        FIfld_pos_cursor( form, VS_K_ATTR_VAL_FLD, 0, 0, 0, 0, 0 , 0 ) ;
        break ;

      case VS_K_ATTR_VAL_FLD : {
          /*
           * A new value for an attribute has been entered: if non-empty,
           * remove it from the list of 'Existing attributes' and add it
           * to the list of 'Modified attributes'.
           */
          char prevVal[MAXROWSIZE] ;

          FIfld_get_text( form, gadget_label, 0, 0, MAXROWSIZE,
      	                  (unsigned char*) buffer, &sel, &pos ) ;
          FIfld_get_active_row( form, VS_K_MOD_ATTR_FLD, &row, &pos ) ;
          FIfld_get_text( form, VS_K_MOD_ATTR_FLD, row, 1, MAXROWSIZE,
        		  (unsigned char*) prevVal, &sel, &pos ) ;
          if( strcmp( buffer, prevVal ) ) {
            FIfld_set_text( form, VS_K_MOD_ATTR_FLD, row, 1, buffer, FALSE ) ;
            FIg_erase( form, VS_K_EDT_ATTR_GRP ) ;
           }
        }
        break ;

      case VS_K_DEL_ATTR_BTN :
        dest = VS_K_DEL_ATTR_FLD ; goto MV_FROM_ORI ;

      case VS_K_MOD_ATTR_BTN :
        dest = VS_K_MOD_ATTR_FLD ;
      MV_FROM_ORI:
        FIfld_get_active_row( form, VS_K_ORI_ATTR_FLD, &row, &pos ) ;
        /*
         * CAUTION: system attributes cannot be modified: their names
         * begin with "__".
         */
        FIfld_get_text( form, VS_K_ORI_ATTR_FLD, row, 0, MAXROWSIZE,
	      		      (unsigned char*) buffer, &sel, &pos ) ;
        if( '_' == buffer[0] && '_' == buffer[1] ) {
          VSfi_msgkey( form, VS_gI_CantModSysAttr ) ;
	  break ;
        }
        MvRowAcrossMcfs( form, VS_K_ORI_ATTR_FLD, row, dest ) ;
        Mk1stVisRowActive( form, VS_K_ORI_ATTR_FLD ) ; 
        MkLstVisRowActive( form, dest ) ; 
        break ;

      case VS_K_UND_ATTR_BTN :
        FIfld_get_active_row( form, VS_K_DEL_ATTR_FLD, &row, &pos ) ;
        MvRowAcrossMcfs( form, VS_K_DEL_ATTR_FLD, row, VS_K_ORI_ATTR_FLD);
        Mk1stVisRowActive( form, VS_K_DEL_ATTR_FLD ) ; 
        MkLstVisRowActive( form, VS_K_ORI_ATTR_FLD ) ; 
        break ;

      case VS_K_REV_ATTR_BTN : {
          long		  sts, msg ;
    	  struct GRobj_env  elm ;
          struct ret_struct rs ;
    	  char		  *p ;
    	
          FIfld_get_active_row( form, VS_K_MOD_ATTR_FLD, &row, &pos ) ;
          FIfld_get_text( form, VS_K_MOD_ATTR_FLD, row, 0, MAXROWSIZE,
	                        (unsigned char*) buffer, &sel, &pos ) ;
	  sts = om$send( msg     = message VSlocateCmd.getLocObjAtIndex(
							        &msg, 0, &elm ),
	                 targetid= my_id ) ;
	  __CheckRC( sts, msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;

	  sts = om$send( msg     = message NDmacro.ACgive_structure(
	  	     			&sel, NULL, buffer, &rs, &elm.mod_env ),
	                 targetid= elm._objid,
	                 targetos= elm._osnum ) ;
	  __CheckRC( sts, sel, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;
	  if( double_type == rs.type ) {
	     p = buffer ;
	     sprintf( buffer, "%g", rs.var.root_pm_st.value ) ;
	  } else {
	     p = rs.var.text_st.text_string ;
	  }
	  FIfld_set_text( form, VS_K_MOD_ATTR_FLD, row, 1, p, FALSE ) ;
	  MvRowAcrossMcfs( form, VS_K_MOD_ATTR_FLD, row, VS_K_ORI_ATTR_FLD);
	  Mk1stVisRowActive( form, VS_K_MOD_ATTR_FLD ) ; 
	  MkLstVisRowActive( form, VS_K_ORI_ATTR_FLD ) ; 
	}
	wrapup :
	break ;

      case VS_K_NEW_ATTR_FLD :
        ProcessNewAttributes( form ) ;
        break ;

      case VS_K_DFLTS_BTN : {
          int x, y ;
          FIf_get_location( form, &x, &y ) ; x += 200 ; y += 200 ;
          if( !*curPATH ) strcpy( curPATH, "." ) ;
          if( !*curNAME ) strcpy( curNAME, "usrAttr" ) ;
          me->dfltInfo.numDefaultsWanted= -1 ; /* No limit */
          me->dfltInfo.parentForm	= form ;
          me->dfltInfo.maxNumDefaults	= MX_ATTR_DFLTS ;
          me->dfltInfo.defaultValues	= me->defaultValues ;
          me->dfltInfo.currentDefault	= 0 ;
          me->dfltInfo.callBack		= VSmodAttrCallBack ;
          me->dfltInfo.fileForm		= NULL ;
          me->dfltInfo.fileInfo.curPATH	= curPATH ;
          me->dfltInfo.fileInfo.curNAME	= curNAME ;
          me->dfltInfo.fileInfo.curRGXP = curRGXP ;
          me->modAttrForm		= VScreateDefaultValuesForm(
							x, y, &me->dfltInfo ) ;
	  if( me->modAttrForm ) {
	    long msg ;
	    FIf_set_cmd_oid_os( me->modAttrForm, my_id, OM_Gw_current_OS ) ;

	    FIg_disable( form, gadget_label ) ;
	    om$send( msg = message VSlocateCmd.stop_dynamics_in_form(
	                                                            &msg, form),
   	             targetid = my_id ) ;
	    om$send( msg = message VSlocateCmd.set_dynamics_in_form(
		   				        &msg, me->modAttrForm ),
                     targetid = my_id ) ;
	   }
         }
         break ;
      } /* end switch */

    }

    return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

  long		 sts ;		                 /* OM return code    */
  char		 *form = me->forms[0].form_ptr ;
  int		 nNew,				 /* # of new attr.    */
  		 nMod,                           /* # of attr. to mod.*/
		 nDel,	                         /* # of attr. to del.*/
		 total = 0 ;
  char           **attrNames = NULL ;
  char		 **attrValues= NULL ;


  FIfld_get_num_rows( form, VS_K_NEW_ATTR_FLD, &nNew ) ;
  FIfld_get_num_rows( form, VS_K_MOD_ATTR_FLD, &nMod ) ;
  FIfld_get_num_rows( form, VS_K_DEL_ATTR_FLD, &nDel ) ;

  total = nNew + nMod + nDel ;

  if( !total ) { me->ret = VS_K_ACT_SUCCESS ; return OM_S_SUCCESS ; }

  attrNames = _CALLOC( total, char * ) ;
  attrValues= _CALLOC( total, char * ) ;

  if( attrNames && attrValues ) {
    int              i,
                     j,
                     k,
                     mcf[3],
                     max[3] ;
    int              io,
    		     nattr ;
    struct GRobj_env locObj ;
    mcf[0] = VS_K_NEW_ATTR_FLD ; max[0] = nNew ;
    mcf[1] = VS_K_MOD_ATTR_FLD ; max[1] = nMod ;
    mcf[2] = VS_K_DEL_ATTR_FLD ; max[2] = nDel ;

    k = 0 ;
    for( i = 0 ; i < 3 ; i++ ) {
      for( j = 0 ; j < max[i] ; j++ ) {
        int size ;
        char *n,
             *v ;
        int  sel,
             pos ;
        FIfld_get_text_length( form, mcf[i], j, NAMES_COLUMN, &size ) ;
        if( VS_K_DEL_ATTR_FLD == mcf[i] ) size ++ ; /* for '!' */
        n = _CALLOC( size, char ) ;
        if( n ) {
          if( VS_K_DEL_ATTR_FLD == mcf[i] ) {
             *n = '!' ; n++ ;
          }
          FIfld_get_text( form, mcf[i], j, NAMES_COLUMN, size,
                          (unsigned char*) n, &sel, &pos ) ;
           
          if( VS_K_DEL_ATTR_FLD != mcf[i] ) {
            FIfld_get_text_length( form, mcf[i], j, VALUES_COLUMN, &size ) ;
            v = _CALLOC( size, char ) ;
            if( v ) {
              FIfld_get_text( form, mcf[i], j, VALUES_COLUMN, size,
                              (unsigned char*) v, &sel, &pos ) ;
              attrNames[k]  = n ;
              attrValues[k] = v ;
              k++ ;
            } else {
              _FREE( n ) ;
            }
          } else { attrNames[k]  = n - 1 ; attrValues[k] = NULL ; k++ ; }
        } /* if( n ... */
      } /* for( j ... */
    } /* for( i ... */

    nattr = k ;

    if( nattr ) {
      for( io = 0 ; io < me->oprndCount ; io++ ) {
        sts = om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
						            msg, io, &locObj ),
	               targetid = my_id ) ;
        __CheckRC( sts, *msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;

        om$send( msg	= message VSfeature.VSmodUsrAttributes(
					    msg, nattr, attrNames, attrValues ),
	         targetid = locObj._objid,
	         targetos = locObj._osnum ) ;
      }
    }
  } /* if( attrNames ... */

  wrapup :
		VSfreeList( total, attrNames ) ;
		VSfreeList( total, attrValues  ) ;
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/
method cleanUp() {

	if( me->modAttrForm ) {
		VSdeleteDftlValsForm( me->modAttrForm ) ;
		 me->modAttrForm = NULL ;
	}
	return OM_S_SUCCESS ;

} /* method cleanUp */
/*----------------------------------------------------------------------------*/

end implementation VSmodattCmd ;
