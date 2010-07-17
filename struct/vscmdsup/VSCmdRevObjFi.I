/* $Id: VSCmdRevObjFi.I,v 1.5 2001/05/09 16:33:54 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       struct/vscmdsup/VSCmdRevObjFi.I
 *
 * Description: Command Class for "Review Structural Objects" command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSCmdRevObjFi.I,v $
 *      Revision 1.5  2001/05/09 16:33:54  ramarao
 *      Fixed TR# 5184.
 *
 *      Revision 1.4  2001/03/13 14:01:53  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/12 21:11:07  ramarao
 *      Changes to accept ~~orientation1 && ~~orientation2.
 *
 *      Revision 1.2  2001/02/27 18:22:55  ramarao
 *      Modifications to add object id search.
 *
 *      Revision 1.1  2001/02/25 19:21:04  ramarao
 *      Created "Review Structural Objects" command.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/25/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VSCmdRevObjF;

#include "VDobj.h"
#include "VDfrm.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "VSCmdRevFrm.h"
#include "vdAPImacros.h"
#include "vsmiscmacros.h"

%safe
static Form 	VSRevObjform = NULL; /* if NULL, form does not exist */
static int      x_memo = -1,
                y_memo = -1,
                s_memo = -1;
static long	prev_options = ( SEARCH_PLATES | SEARCH_BEAMS );
static IGRint	prev_SearchType=PCMK_SEARCH;
static IGRchar	prev_MainWindowName[100]="";
static IGRchar  prev_ChildWindowName[100]="";
static IGRchar  prev_ChildType[100]="Unwrap";
%endsafe

extern DIint	DIadd_name(), DItranslate();

from ACheader	import	ACfind_model;

VSreviewObj_command_form()
{
  GRobjid objid;

  return om$construct ( classname = "VSCmdRevObjF", p_objid = &objid,
      msg = message VSCmdRevObjF.init_form () );
}

void VSget_revObj_form( Form1 )
Form *Form1;
{
   *Form1 = VSRevObjform;
}

static void VSRevProfRevOper( 	FILE		*fp,
				struct GRid	*macId,
				IGRchar		*selector,
				IGRchar		*operName,
				IGRboolean	show,
				IGRint		*ind )
{
   operName[0] = '\0';
   VSgetOperName( macId, selector, operName );
   if( operName[0] == '\0' )
   {
       *ind = 0;
       if( show )
	 fprintf( fp, "<%s> is not defined in macro definition\n", selector );
   }
   else
   {
       *ind = 1;
       fprintf( fp, "<%s> is defined as <%s> in macro definition\n", 
		selector, operName  );
   }
}

static void VSRevValidProfcard( struct GRobj_env	*stiffObj,
				struct GRid		macId,
				IGRchar			*txt )
{
IGRlong		sts, msg;
IGRint		i, retFlag = FALSE, row_no, pos, sel, ind1, ind2, ind3,
		nbSteps=0;
IGRchar		operName[50];
struct GRid	footId, *stepInfo=NULL;
FILE		*fp=NULL;

   if( txt == NULL || txt[0] == '\0' ) fp=stdout;
   else fp = fopen( txt, "a" );
   if( fp == NULL ) return;

   fprintf( fp, "Validating --- " );
   vdobj$Print( objID = &macId, file = fp );

   if( !vs$is_ancestry_valid( object  = &macId,
                              classid = OPP_ACncpx_class_id ) )
   {
	fprintf( fp, "Object is not a macro ( ACncpx class )\n" );
	goto wrapup;
   }

   ind1 = ind2 = ind3 = 0;
   VSRevProfRevOper( fp, &macId, "~~operand", operName, TRUE, &ind1 ); 
   VSRevProfRevOper( fp, &macId, "~~operand0", operName, TRUE, &ind2 );
   if( !ind1 && !ind2 )
   {
      fprintf( fp, "Either ~~operand or ~~operand0 should be defined\n" );
      goto wrapup;
   }

   ind1 = ind2 = ind3 = 0;
   VSRevProfRevOper( fp, &macId, "~~operator", operName, TRUE, &ind1 );
   VSRevProfRevOper( fp, &macId, "~~operator0", operName, TRUE, &ind2 );
   VSRevProfRevOper( fp, &macId, "~~operator0~0", operName, TRUE, &ind3 );
   if( !ind1 && !ind2 && !ind3 )
   {
      fprintf( fp, "Either ~~operator or ~~operator0 or ~~operator0~0 should be defined\n" );
      goto wrapup;
   }

   if( stiffObj )
   {
      struct GRid	parentId;

      parentId.objid = NULL_OBJID;

      VSRevGetStepInfo( stiffObj, &nbSteps, &stepInfo );
      vdobj$GetParent( objID = &macId, idx = 0, parentID = &parentId );
      if( parentId.objid != NULL_OBJID )
      {
	for( i=0; i<nbSteps; ++i )
	{
	   if( parentId.objid == stepInfo[i].objid &&
	       parentId.osnum == stepInfo[i].osnum     )
	   {
	       fprintf( fp, "First Parent of this macro is one of the stiffeners in the dependency graph\n" );
	       break; 
	   }
	}
	if( i == nbSteps )
	{
	  fprintf( fp, "First Parent of this Stiffener -- " );
	  vdobj$Print( objID = &parentId, file = fp );
	  fprintf( fp, "First Parent of this macro is NOT one of the stiffeners in the dependency graph\n" );
	  goto wrapup;
	}
      }
   }

   ind1 = 0;
   VSRevProfRevOper( fp, &macId, "~~orientation", operName, TRUE, &ind1 );
   if( !ind1 )
	VSRevProfRevOper( fp, &macId, "~~orientation1", operName, FALSE, &ind1 );
   if( !ind1 )
        VSRevProfRevOper( fp, &macId, "~~orientation2", operName, FALSE, &ind1 );
   if( !ind1 )
   {
      IGRchar		selector[40];

      for( i=0; i<20; ++i )
      {
	if( i<10 )	sprintf( selector, "~~marking%d",  i );
        else	        sprintf( selector, "~~marking0%d", i-10 );

	ind1 = 0;
        VSRevProfRevOper( fp, &macId, selector, operName, FALSE, &ind1 );
        if( ind1 == 0 )  continue;
	
	fprintf( fp, "<%s> is defined as <%s> in macro definition\n",
				selector, operName );
	footId.objid = NULL_OBJID;
	sts = vd_$return_foot( msg = &msg, name = operName, 	
			       objId = &macId, footId = &footId );
	if( !(sts&1&msg) || footId.objid == NULL_OBJID )
	{
	   ind1 = 0;
	   fprintf( fp, "<%s> foot is missing\n", operName );
	   continue;
	}
	else
	{
	   ind2 = 0;
	   VSRevProfRevOper( fp, &macId, "~~cmd", operName, FALSE, &ind2 );
	   if( ind2 )
	   {
	      if( !strcmp( operName, "et" ) )
	      {
		fprintf( fp, "Input macro is an End Treatment. So, This is NOT valid marking.\n" );
		ind1 = 0;
	        continue;
	      }
	      fprintf( fp, "<~~cmd> is defined as <%s> in macro definition\n",
			operName );	
	   }
	   fprintf( fp, "Found Valid Marking -- " );
	   vdobj$Print( objID = &footId, file = fp );
	}
      }
      if( ind1 == 0 )
      {
         fprintf( fp, "Either ~~orientation or ~~marking* should be defined\n" );
      }
      goto wrapup;
   }
   else
   {
      footId.objid = NULL_OBJID;
      sts = vd_$return_foot( msg = &msg, name = operName, 
			     objId = &macId, footId = &footId );
      if( !(sts&1&msg ) || footId.objid == NULL_OBJID )
      {
         fprintf( fp, "<%s> foot is missing\n", operName );
         goto wrapup;
      }
      else
      {
	 fprintf( fp, "<%s> foot found -- ", operName );
	 vdobj$Print( objID = &footId, file = fp );
      }
   }

   ind1 = 0;
   VSRevProfRevOper( fp, &macId, "~~cmd", operName, FALSE, &ind1 );
   if( ind1 )
   {
     if( !strcmp( operName, "et" ) )
	fprintf( fp, "This macro is an End Treatment\n" );
   }
   retFlag = TRUE;

wrapup:
   if( retFlag == FALSE ) fprintf( fp, "Macro is NOT valid for profile card\n\n" );
   else fprintf( fp, "Macro IS valid for profile card\n\n" );
   fflush( fp );
   if( fp != stdout ) fclose( fp );
   _FREE( stepInfo );
   return;
}

int VSRevObj_process_form ( form_label, gadget_label, value )
int form_label;
int  gadget_label;
double value;
{
  int        stat_func, stat_OM;
  long       msg_loc;
  GRobjid    cmdobj;
  GRspacenum cmdos;

  stat_OM = OM_S_SUCCESS;
  stat_func = FIf_get_cmd_oid_os (VSRevObjform, (unsigned int *) &cmdobj,  &cmdos);
  if (stat_func)
    return (OM_E_ABORT);
  stat_OM =
  om$send(msg = message VSCmdRevObjF.do_form (&msg_loc,  form_label,
                     gadget_label,  value),
          senderid = NULL_OBJID,
          targetid = cmdobj,
          targetos = cmdos);
  if (!(stat_OM & 1))
    return (OM_E_ABORT);

  return (stat_OM);
}

#define MAX_WINDOW      40

method init_form()
{
  long		msg;
  int 		i, ind, status, ret, num_ggid=0;
  char		objName[DI_PATH_MAX], dirName[DI_PATH_MAX], baseName[50], 
		txt[100];
  struct GRid   ggid[MAX_WINDOW];

  if( VSRevObjform ) goto quit; /* form already exists */

  ret = FIf_new( 1, "VSRevObj.frm",  VSRevObj_process_form,  &VSRevObjform );
  if (ret)
    return (OM_E_ABORT);
  ret = FIf_set_cmd_oid_os(VSRevObjform,  my_id,  OM_Gw_current_OS);
  if (ret)
    return (OM_E_ABORT);

  /* add my name to the IGENOD directory */
  di$add_name ( osnum = OM_Gw_current_OS,
                objid = my_id,
                path = "IGENOD",
                objname = "VSRevObjForm" );

  if( x_memo != -1 )
  {
     FIf_set_location(VSRevObjform,x_memo,y_memo);
     FIf_set_screen(VSRevObjform,s_memo);
  }

  // Initialization
  me->options = prev_options ;
  if( me->options & SEARCH_PLATES ) 
	FIg_set_state_on(  VSRevObjform, G_PLATES );
  else  FIg_set_state_off( VSRevObjform, G_PLATES );

  if( me->options & SEARCH_BEAMS ) 
        FIg_set_state_on(  VSRevObjform, G_BEAMS );
  else  FIg_set_state_off( VSRevObjform, G_BEAMS );

  if( me->options & STRUCT_AUTO_FIT )
	FIg_set_state_on(  VSRevObjform, G_STRUCT_AUTO );
  else  FIg_set_state_off( VSRevObjform, G_STRUCT_AUTO );

  if( me->options & CHILD_AUTO_FIT )
        FIg_set_state_on(  VSRevObjform, G_CHILD_AUTO );
  else  FIg_set_state_off( VSRevObjform, G_CHILD_AUTO );

  me->CurrentIndex = -1;
  me->TotalObjectCount = 0;
  me->FoundObjectCount = 0;
  me->ChildObjectCount = 0;
  me->ChildFoundObjectCount = 0;

  om$vla_set_dimension( varray = me->TotalObjects, size = 0 );
  om$vla_set_dimension( varray = me->FoundObjects, size = 0 );
  om$vla_set_dimension( varray = me->ChildObjects, size = 0 );
  om$vla_set_dimension( varray = me->ChildFoundObjects, size = 0 );

  me->MainWindow.objid = me->ChildWindow.objid = NULL_OBJID;

  dp$get_gragad_id(  msg         = &msg,
                     name        = "*",
                     array_size  = MAX_WINDOW,
                     numberofids = &num_ggid,
                     found_GRids = ggid,
                     type_gragad = ALL_GG_CLASSES | GG_WIN_ON );

  FIfld_set_list_num_rows( VSRevObjform, G_STRUCT_WINDOW, 0, 0 );
  FIfld_set_list_num_rows( VSRevObjform, G_CHILD_WINDOW, 0, 0 );

  ind = 0;
  for( i=0; i<num_ggid; ++i )
  {
     di$untranslate( objid   = ggid[i].objid,
		     osnum   = ggid[i].osnum,
		     objname = objName      );
     if( objName[0] == '\0' ) continue;

     di$split( pathname  = objName, dirname= dirName, name = baseName );

     FIfld_set_list_text( VSRevObjform, G_STRUCT_WINDOW, 
			  ind, 0, (unsigned char * )baseName, FALSE );
     if( !strcmp( prev_MainWindowName, baseName ) )
     {
	FIg_set_text( VSRevObjform, G_STRUCT_WINDOW, baseName );
	me->MainWindow = ggid[i] ;
     }
   
     FIfld_set_list_text( VSRevObjform, G_CHILD_WINDOW, 
			  ind, 0, (unsigned char * )baseName, FALSE );
     if( !strcmp( prev_ChildWindowName, baseName ) )
     {      
        FIg_set_text( VSRevObjform, G_CHILD_WINDOW, baseName );
        me->ChildWindow = ggid[i] ;
     }
     ind++;
  }

  me->SearchType = prev_SearchType;
  FIfld_set_active_row( VSRevObjform, G_SEARCH_TYPE, me->SearchType, 0 );

  FIg_set_text( VSRevObjform, G_CHILD_TYPE, prev_ChildType );
  FIg_set_text( VSRevObjform, FI_MSG_FIELD, "Start Search" );

  om$send ( msg = message VSCmdRevObjF.CollectObjects(), targetid = my_id );

  ret = FIf_display ( VSRevObjform );
  if (ret)
    return OM_E_ABORT;

quit:
  return 1;
}

method do_form ( long *msg; int form_label; int gadget_label; double value)
{
IGRint			state, row_no, pos, sel, num_ggid;
IGRchar			txt[200];
struct GRobj_env 	objOE;

  switch (gadget_label)
  {
    case FI_ACCEPT:
      dp$erase_hilite( msg = msg );

      prev_options = me->options;
      prev_SearchType = me->SearchType;

      FIg_get_text( VSRevObjform, G_STRUCT_WINDOW, txt ) ;
      strcpy( prev_MainWindowName, txt ) ;

      FIg_get_text( VSRevObjform, G_CHILD_WINDOW, txt ) ;
      strcpy( prev_ChildWindowName, txt ) ;

      FIg_get_text( VSRevObjform, G_CHILD_TYPE, txt ) ;
      strcpy( prev_ChildType, txt ) ;

      FIf_get_location(VSRevObjform,&x_memo,&y_memo);
      FIf_get_screen  (VSRevObjform,&s_memo);

      FIg_set_state_off ( VSRevObjform, gadget_label );
      FIf_delete ( VSRevObjform );
      VSRevObjform = NULL; /* indicates form no longer exists */
      om$send ( msg = message Root.delete ( 1 ), targetid = my_id );
      break;

    case G_EVENT:
       FIg_set_state_off ( VSRevObjform, gadget_label );
       if( me->CurrentIndex != -1 )
       {
           ASputobj( msg, me->FoundObjects[me->CurrentIndex].obj_id.objid,
		     me->FoundObjects[me->CurrentIndex].obj_id.osnum,
                     &me->FoundObjects[me->CurrentIndex].mod_env);
       }
       else if( me->ChildFoundObjectCount > 0 )
       {
	   FIfld_get_active_row( VSRevObjform, G_CHILD_LIST, &row_no, &pos );
	   FIfld_get_select( VSRevObjform,G_CHILD_LIST, row_no, 0, &sel );
           if( sel )
           {
	       	VDahGetObjectEnv( &me->ChildFoundObjects[row_no],
				  &objOE );
		ASputobj( msg, objOE.obj_id.objid, objOE.obj_id.osnum,
			  &objOE.mod_env );
	   }
       }
       break;

    case G_PLATES:
	FIg_get_state( VSRevObjform, G_PLATES, &state );
	if( state )  	me->options |= SEARCH_PLATES;
	else		me->options &= ~SEARCH_PLATES;
	
    case G_BEAMS:
        FIg_get_state( VSRevObjform, G_BEAMS, &state );
        if( state )     me->options |= SEARCH_BEAMS;
        else            me->options &= ~SEARCH_BEAMS;

    case G_SEARCH_TYPE:
	FIg_get_text( VSRevObjform, G_SEARCH_TYPE, txt ) ;
	if( !strcmp( txt, "PCMK" ) )	  me->SearchType = PCMK_SEARCH;
	else if( !strcmp( txt, "NAME" ) ) me->SearchType = NAME_SEARCH;
	else if( !strcmp( txt, "ID" ) )   me->SearchType = OBJID_SEARCH;

    case G_SEARCH_PCMK:
      dp$erase_hilite( msg = msg );
      FIg_get_text( VSRevObjform, G_SEARCH_PCMK, txt ) ;
      om$send ( msg = message VSCmdRevObjF.FillFoundObjectsInForm( txt ),
		targetid = my_id );
      break;

    case G_STRUCT_AUTO:
      FIg_get_state( VSRevObjform, gadget_label, &state );
      if( state )     me->options |= STRUCT_AUTO_FIT;
      else            me->options &= ~STRUCT_AUTO_FIT; 
      break;

    case G_CHILD_AUTO:
      FIg_get_state( VSRevObjform, gadget_label, &state );
      if( state )     me->options |= CHILD_AUTO_FIT;
      else            me->options &= ~CHILD_AUTO_FIT; 
      break;

    case G_PREVIOUS:
    case G_NEXT:
      FIg_set_state_off ( VSRevObjform, gadget_label );
      if( me->FoundObjectCount == 0 ) break;

      if( gadget_label == G_PREVIOUS &&
	  me->CurrentIndex != -1     &&
	  me->CurrentIndex != 0          ) (me->CurrentIndex)--;
      else if( gadget_label == G_NEXT &&
	  me->CurrentIndex != -1 &&
	  me->CurrentIndex != (me->FoundObjectCount-1) ) (me->CurrentIndex)++;
      else break;		

      FIfld_set_active_row( VSRevObjform, G_STRUCT_LIST, me->CurrentIndex, 7 );
      FImcf_set_select( VSRevObjform, G_STRUCT_LIST, me->CurrentIndex, TRUE );	

    case G_STRUCT_LIST:
      if( me->FoundObjectCount == 0 ) break;
      FIfld_get_active_row( VSRevObjform, G_STRUCT_LIST, &row_no, &pos );
      FIfld_get_text( VSRevObjform, G_STRUCT_LIST, row_no, 2, 
                      200, (unsigned char *)txt, &sel, &pos );
      FIfld_get_select( VSRevObjform,G_STRUCT_LIST, row_no, 0, &sel );
      if( sel )
      {
	  dp$erase_hilite( msg = msg );
	  VSbulkDisplayByGRobj_envs( GRhd, 1, &me->FoundObjects[row_no] );
	  me->CurrentIndex = row_no;
	  om$send ( msg = message VSCmdRevObjF.CollectChildObjects(), 
		    targetid = my_id );
          om$send ( msg = message VSCmdRevObjF.FillChildObjectsInForm(),
                    targetid = my_id );
	  FIg_set_text( VSRevObjform, FI_MSG_FIELD, txt );
      }
      else 
      {
	  VSbulkDisplayByGRobj_envs( GRhe, 1, &me->FoundObjects[row_no] );
	  FIg_set_text( VSRevObjform, FI_MSG_FIELD, "" );
	  me->CurrentIndex = -1;
      }

      if( me->options & STRUCT_AUTO_FIT && me->MainWindow.objid != NULL_OBJID &&
          me->CurrentIndex != -1 )
      {
          dp$erase_hilite( msg = msg );
          VDvw_fit_many_objects( 1, &me->FoundObjects[me->CurrentIndex], NULL,
                                 1.0, NULL, &me->MainWindow, 1 );
          VSbulkDisplayByGRobj_envs( GRhd, 1,
                                &me->FoundObjects[me->CurrentIndex] );
      }

      if( me->options & CHILD_AUTO_FIT && me->ChildFoundObjectCount > 0 &&
          me->ChildWindow.objid != NULL_OBJID )
      {
	 FIg_get_text( VSRevObjform, G_CHILD_TYPE, txt ) ;
	 if( strcmp( txt, "User Defined" ) )
	 {
	    IGRdouble 	ratio;

	    if( !strcmp( txt, "Profile Card" ) )  ratio = 1.25;
	    else				  ratio = 1.0;
            VDahGetObjectEnv( &me->ChildFoundObjects[0], &objOE );
            VDvw_fit_many_objects( 1, &objOE, NULL, ratio, NULL, 
				   &me->ChildWindow, 1 );
            VSbulkDisplayByGRobj_envs( GRhd, 1, &objOE );
	 }
      }
      break;

    case G_CHILD_LIST:
      if( me->ChildFoundObjectCount == 0 ) break;
      FIfld_get_active_row( VSRevObjform, G_CHILD_LIST, &row_no, &pos );
      FIfld_get_select( VSRevObjform,G_CHILD_LIST, row_no, 0, &sel );
      VDahGetObjectEnv( &me->ChildFoundObjects[row_no], &objOE );
      FIg_get_text( VSRevObjform, G_CHILD_TYPE, txt ) ;
      if( sel )
      {
	if( !strcmp( txt, "User Defined" ) ) 
		FIg_display( VSRevObjform, G_VALIDATE );
        else    FIg_erase( VSRevObjform, G_VALIDATE );

	dp$erase_hilite( msg = msg );
	VSbulkDisplayByGRobj_envs( GRhd, 1, &objOE );
	FIfld_get_text( VSRevObjform, G_CHILD_LIST, row_no, 0,
			200, (unsigned char *)txt, &sel, &pos );
	FIg_set_text( VSRevObjform, FI_MSG_FIELD, txt );
      }
      else
      {
	FIg_erase( VSRevObjform, G_VALIDATE );
	VSbulkDisplayByGRobj_envs( GRhe, 1, &objOE );
      }
      break;

    case G_STRUCT_WINDOW:
      FIg_get_text( VSRevObjform, gadget_label, txt ) ;
      dp$get_gragad_id( msg         = &msg,
                        name        = txt,
                        array_size  = 1,
                        numberofids = &num_ggid,
                        found_GRids = &me->MainWindow,
                        type_gragad = ALL_GG_CLASSES | GG_WIN_ON );
      break;

    case G_CHILD_WINDOW:
      FIg_get_text( VSRevObjform, gadget_label, txt ) ;
      dp$get_gragad_id( msg         = &msg,
                        name        = txt,
                        array_size  = 1,
                        numberofids = &num_ggid,
                        found_GRids = &me->ChildWindow,
                        type_gragad = ALL_GG_CLASSES | GG_WIN_ON );
      break;

    case G_STRUCT_FIT:
      FIg_set_state_off ( VSRevObjform, gadget_label ); 
      if( me->MainWindow.objid == NULL_OBJID || me->CurrentIndex == -1 ) break;
      dp$erase_hilite( msg = msg );
      VDvw_fit_many_objects( 1, &me->FoundObjects[me->CurrentIndex], NULL,
			     1.0, NULL, &me->MainWindow, 1 );
      VSbulkDisplayByGRobj_envs( GRhd, 1, &me->FoundObjects[me->CurrentIndex] ); 
      break;

    case G_CHILD_FIT:
      FIg_set_state_off ( VSRevObjform, gadget_label );
      if( me->ChildWindow.objid == NULL_OBJID || me->ChildFoundObjectCount ==0 ) 
	 break;

      FIfld_get_active_row( VSRevObjform, G_CHILD_LIST, &row_no, &pos );
      FIfld_get_select( VSRevObjform,G_CHILD_LIST, row_no, 0, &sel );
      if( sel )
      {
          VDahGetObjectEnv( &me->ChildFoundObjects[row_no], &objOE );
          dp$erase_hilite( msg = msg );
          VDvw_fit_many_objects( 1, &objOE, NULL,
                                 1.0, NULL, &me->ChildWindow, 1 );
          VSbulkDisplayByGRobj_envs( GRhd, 1, &objOE );
      }
      break;

    case G_MACRO_SEARCH:
      FIg_is_displayed( VSRevObjform, G_VALIDATE, &state );
      if( state )
      {
         FIg_get_state( VSRevObjform, G_VALIDATE, &state );
         if( state ) 
         {
	   FIg_get_text( VSRevObjform, gadget_label, txt ) ;
           FIfld_get_active_row( VSRevObjform, G_CHILD_LIST, &row_no, &pos );
	   if( me->CurrentIndex == -1 ) 
		VSRevValidProfcard( NULL, me->ChildFoundObjects[row_no], txt );
	   else	 
		VSRevValidProfcard( &me->FoundObjects[me->CurrentIndex], 
				me->ChildFoundObjects[row_no], txt );

	   FIg_set_state_off ( VSRevObjform, G_VALIDATE );
	   FIg_set_text( VSRevObjform, gadget_label, "" );
	   FIg_set_text( VSRevObjform, FI_MSG_FIELD, "" );
	   break;
         }
      }
      om$send ( msg = message VSCmdRevObjF.FillChildObjectsInForm(),
                    targetid = my_id );
      break;

    case G_CHILD_TYPE:
      FIg_get_text( VSRevObjform, gadget_label, txt ) ;

      if( !strcmp( txt, "User Defined" ) )  
		FIg_display( VSRevObjform, G_MACRO_SEARCH );
      else      
      {
	  FIg_erase( VSRevObjform, G_VALIDATE );
	  FIg_erase( VSRevObjform, G_MACRO_SEARCH );
      }

      om$send ( msg = message VSCmdRevObjF.FillChildObjectsInForm(),
                    targetid = my_id );
      break;

     case G_VALIDATE:
      FIg_set_text( VSRevObjform, FI_MSG_FIELD, 
		    "Key-in File Name OR Press Enter" );
      FIg_set_text( VSRevObjform, G_MACRO_SEARCH, "" );
      FIfld_pos_cursor( VSRevObjform, G_MACRO_SEARCH, 0, 0, 0, 0, 0, 0 );
      break;
  }

  return (OM_S_SUCCESS);
}

void VSdelete_RevObj_form()
{
  if (VSRevObjform)
  {
    int         sts;
    OM_S_OBJID objid = NULL_OBJID;

    sts = di$translate ( osnum = OM_Gw_TransOSnum_0,
      p_objid = &objid, path = "IGENOD", objname = "VSRevObjForm" );
    if (sts == DIR_S_SUCCESS)
    {
      om$send ( msg = message Root.delete ( 1 ), targetid = objid,
        targetos = OM_Gw_TransOSnum_0, senderid = NULL_OBJID );
    }

    FIf_delete(VSRevObjform);
    VSRevObjform = NULL;
  }
}

end implementation VSCmdRevObjF;
