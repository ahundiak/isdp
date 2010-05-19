/*


Name
  FIdirformi.I

Description
  The routines in this file process the Directory command form
Notes


 */

class implementation FIdirform;

#include "alloca.h"
#include "coimport.h"
#include "OMerrordef.h"
#include "DIprims.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "ODE.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
//#include <tools.h>    // ENVIRONV ONLY
#include "cct.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "DIglob.h"
#include "grmsg.h"
#include "grcmd.h"
#include "madef.h"
#include "drawparam.h"
#include "AS_status.h"
#include "GMmacros.h"

# define max(a,b)              (a<b ? b : a)
# define min(a,b)              (a<b ? a : b)
#define FORM1   1

%safe
static Form        DIform = NULL;
static Form        DIEditForm = NULL;
static char        DIform_find_start [DI_PATH_MAX] = { 0 };
static int         DIform_find_count = 0;
static char        **DIform_find_lines = NULL;
static struct GRid *DIform_find_grids = NULL;
static int         DILocked = 0;
%endsafe

extern GRclassid OPP_IGRdir_class_id;


from cmdserver  import disconnect_from_stack;
from GRgraphics import GRdelete, GRdisplay;
from expression import give_syntax, NDgive_value, put_value, NDchange_node;

/*

Name
 COdelete_dir_form ð
Abstract
 This function is called from the super_object when 
 it gets the sleep message. It deletes the form so that it 
 won't interfere with journaling when doing a save.
Synopsis

Description
 
Return Value

Notes

Index

Keywords
  delete,form,journaling,sleep

History
  02/10/93 : Carlos M. Diaz : created

 */

void COdelete_dir_form()
{

  if (DIform)
  {
    int         sts;
    OM_S_OBJID objid = NULL_OBJID;

    sts = di$translate ( osnum = OM_Gw_TransOSnum_0,
      p_objid = &objid, path = "IGENOD", objname = "DirCmds" );
    if (sts == DIR_S_SUCCESS)
    {
      om$send ( msg = message Root.delete ( 1 ), targetid = objid,
        targetos = OM_Gw_TransOSnum_0, senderid = NULL_OBJID );
    }
    FIf_delete(DIform);
    DIform = NULL;
  }
  if (DIEditForm)
  {
    FIf_delete(DIEditForm);
    DIEditForm = NULL;
  }
}

/* ---------------------------------------------------------------------------*/


/* This macro is used to find the names that match the regular expression.
    If lines is specified (char ***), it is filled out with the results.
   This macro is intended to be used by the directory sub-system only.

        o  deep returns the maximum layer number 
        o  max_level may be used to restrict the deep of the search (-1 means
           no restriction)

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        char *start_dir       : the place to start to find from        		(IN)

        char ***lines         : if specified, the entries are         		(OUT)
                                  listed in this array

        int *ptr              : the number of listed entry;                	(OUT)

        int  max_level        : the maximum level of search                 	(IN)
                                  (< 0 means no limit)

        DIgrid **grids        : the grids of the listed entries			(OUT)

        int  *deep            : the effective deep of the                 	(OUT)
                                search (<= max_level)
 */

#omdef di$form_find ( start_dir = ".",
                      lines = NULL,
                      ptr,
                      grids = NULL, 
                      max_level = 1,
                      deep = NULL )
       DIform_find ( (start_dir), (lines), (ptr), (max_level), (int *)(deep), (DIgrid **)(grids) )
#endomdef


void DIget_dir_form ( p_form )
Form *p_form;
{
   *p_form = DIform;
}



void FIget_form_find_info ( max_level, start_dir )
int *max_level;
char *start_dir;
{
   strncpy( start_dir, DIform_find_start, DI_PATH_MAX );
   *max_level = 1;
}


static my_strcmp ( p_s1, p_s2 )
                   char **p_s1, **p_s2;
/*
   A strcmp with double pointers for qsort.
*/
{
  return strcmp ( *p_s1, *p_s2 );
}


DIget_trailer_with_id2 ( osnum, objid, trailer )
                        DIspacenum osnum;
                        DIobjid    objid;
                        DIchar     *trailer;
/*.DIget_trailer_with_id */
{
  OMuword class_id;
  DIint   i;
  
  om$get_classid ( objid = objid, osnum = osnum, p_classid = &class_id );
  
  for (i = 0; i < DIR_G_trailer_index; i++)
  {
    /*"examining : %d - %d\n", class_id, DIR_G_trailer_ids [i]*/
    if ((om$is_ancestry_valid ( subclassid = class_id,
               superclassid = DIR_G_trailer_ids [i] ) == DIR_S_SUCCESS) || 
        (class_id == DIR_G_trailer_ids [i]))
       break;
  }
  if (i < DIR_G_trailer_index)
     strncpy ( trailer, DIR_G_trailers [i], DI_PATH_MAX ) [DI_PATH_MAX - 1];
  else
     trailer [0] = '\0';
  return(1);
}


DIform_find ( start, lines, ptr, max_level, deep, grids )
              char   *start      /* The start directory                  IN  */,
                     ***lines      /* The buffer to put the names in     OUT */;
              int    *ptr          /* The number of lines                OUT */,
                     max_level     /* The maximum level of the find      IN  */,
                     *deep         /* The effective level of the find    OUT */;
              DIgrid **grids	   /* The list of grids			 OUT */;
/*
   This function calls di$find for the form of the directory sub-system.
 */
{
  int ReturnStatus, state;

  /* set up static variables */
  DIstrcpy ( DIform_find_start, start );

  /*
   * Do we need to sort the list?
   */
  FIg_get_state ( DIform, SORT_TOGGLE, &state );
  if (!state && DIform_find_count)
  {
    char **tmp_lines;
    int  i;
    
    /* call find */
    ReturnStatus = di$find ( start_dir = start, 
                       options = OPT_LEVEL,
                       max_level = max_level,
                       lines = &tmp_lines,
                       ptr = &DIform_find_count,
                       deep = deep );
    if (ReturnStatus & 1)
    {
      if (ptr) *ptr = DIform_find_count;
  
      qsort ( tmp_lines, DIform_find_count, sizeof ( char * ), (int (*)())my_strcmp );
  
      *grids = (DIgrid *)malloc ( DIform_find_count * sizeof ( DIgrid ) );
      *lines = (char **)malloc ( DIform_find_count * sizeof ( char * ) );
      if (lines && grids)
      {
        for (i = 0; i < DIform_find_count; i++)
        {
          OM_S_MESSAGE           msg;
          int                    sts;
          struct { char *name; } argument;
          GRclassid              clid;
          GRspacenum             osnum;
          GRobjid                objid;
          char                   name [DI_PATH_MAX];
  
          strcpy ( name, tmp_lines [i] );
          free ( tmp_lines [i] );
          di$translate ( path = start, objname = name, p_objid = &objid, p_osnum = &osnum );
          
          /* get the output from the class */
          argument.name = name;
          sts = om$get_classid ( osnum = osnum, objid = objid, p_classid = &clid );
          if (sts == OM_S_SUCCESS)
          {
            sts = om$make_message ( classid    = clid,
                methodname = "DIgive_output",
                size       = sizeof ( argument ),
                p_arglist  = &argument,
                p_msg      = &msg );
            if (sts == OM_S_SUCCESS)
              sts = om$send ( msg = &msg, senderid = NULL_OBJID, targetid = objid, targetos = osnum );
          }
  
          if (sts != OM_S_SUCCESS)
          {
            char trailer [DI_PATH_MAX];
  
            /* add the trailer if any */
            DIget_trailer_with_id2 ( osnum, objid, trailer );
            strncat ( name, trailer, DI_PATH_MAX ) [DI_PATH_MAX - 1] = '\0';
          }

          (*grids) [i].osnum = osnum;
          (*grids) [i].objid = objid;
          (*lines) [i] = (char *)malloc ( strlen ( name ) * sizeof ( char ) + 1 );
          if ((*lines) [i])
            strcpy ( (*lines) [i], name );
          else
          {
            ReturnStatus = OM_E_NODYNMEM;
            break;
          }
        }
      }
      else
        ReturnStatus = OM_E_NODYNMEM;

      free ( tmp_lines );
      tmp_lines = NULL;
    }
    else
      if (ptr) *ptr = 0;
  }
  else
  {
    /* call find */
    ReturnStatus = di$find ( start_dir = start, 
                       lines = lines, 
                       options = OPT_TRAILER | OPT_LEVEL,
                       max_level = max_level,
                       grids = grids,
                       ptr = &DIform_find_count,
                       deep = deep );
    if (ptr) *ptr = DIform_find_count;
  }

  return ReturnStatus;
}

#argsused
int DIdirform_process_form ( form_label, gadget_label, value, form )
int form_label;
int  gadget_label;
double value;
Form form;
{
  int        stat_func, stat_OM;
  long       msg_loc;
  GRobjid    cmdobj;
  GRspacenum cmdos;

  /*
   * We ignore everything when a subform is up
   */
  if (DILocked)
    return OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (DIform, &cmdobj, &cmdos);
  if (stat_func)
    return OM_E_ABORT;
  stat_OM = om$send (msg = message FIdirform.do_form ( &msg_loc, form_label, 
                     gadget_label, value), 
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if (!(stat_OM & 1))
    return OM_E_ABORT;

  return stat_OM;
}


/*

Name
  DIDeleteEditForm

Abstract
  Deletes the Edit form.

Synopsis
  void DIDeleteEditForm ();

Description
  Fairly trivial.
  
Return Value
  none.
  
Notes

Index

Keywords
  delete,directory,equation,form

History
  06/16/93 : Henry G. Bequet : created

 */
void DIDeleteEditForm ()
{
  long ReturnStatus;
  int  GadgetIndex;

  FIf_delete ( DIEditForm );
  DIEditForm = NULL;
  DILocked--;

  dp$erase_hilite ( msg = &ReturnStatus );
  DIclear_hilited ();
  for (GadgetIndex = 100; GadgetIndex < 114; GadgetIndex++)
    FIg_set_state ( DIform, GadgetIndex, 0 );
}


%safe
static char        DIEditedString [DI_PATH_MAX] = { '\0' }, DILastEditedString [DI_PATH_MAX];
static struct GRid DIEditedGrid;
%endsafe

#argsused
void DIModifNotify ( FormLabel, GadgetLabel, Value, NotUsed )
int    FormLabel;
int    GadgetLabel;
double Value;
Form   NotUsed;
{
  int  AutoAccept = 0;
  char alpha [DI_PATH_MAX];
  void DIActivateEditField (), DIobject_added ( char * ), DIInsertName ();

  switch (GadgetLabel)
  {
    case 13: /* list of expressions */
      {
        char CurrentSyntax [DI_PATH_MAX];
        int x, y, f_x, f_y;    
          
        FIf_get_location ( DIEditForm, &f_x, &f_y );         

#ifdef CLIX
        x = 0;
#else
        x = -5;
#endif

        y = 80;
    
        FIg_set_state_off ( DIEditForm, GadgetLabel );
        DILocked++;
        FIg_get_text ( DIEditForm, EDIT_FIELD, CurrentSyntax );
        if (EXPPickExpression ( f_x + x, f_y + y, CurrentSyntax ) == OM_S_SUCCESS)
        {
          /*
           * We replace the syntax
           */
          DILocked--;
          if (DIEditForm)
          {
            FIg_set_text ( DIEditForm, EDIT_FIELD, CurrentSyntax );
            AutoAccept = 1;
          }
        }
        else
          DILocked--;
      }
      
      /*
       * We simulate an accept button selection
       */
      if (AutoAccept)
        GadgetLabel = 1;
      else
        break;

    case 1: /* edited string */
      FIg_set_state_off ( DIEditForm, GadgetLabel );
      if (*DIEditedString == '\0')
      {
        char        exp_name [DI_PATH_MAX], exp_syntax [DI_PATH_MAX], syntax [DI_PATH_MAX];
        GRobjid     expid;
        OMuword     osnum;
        
        /*
         * We are adding something
         */
        FIg_get_text ( DIEditForm, EDIT_FIELD, syntax );
        if (*syntax)
          if (strchr ( syntax, '=' ) || strchr ( syntax, '"' ))
          {
            char *s;
            EXP_extract_lhs_rhs ( syntax, exp_name, exp_syntax );
            
            s = exp_syntax;
            if( s != 0 && *s != '\0' )
              while( *s && *s == ' ' ) s++ ;
    
            if (*exp_name && (*s == '"'))
            {
              /* text expression creation */
              di$pwd ( p_osnum = &osnum );
              if (EXP_text_exp_build ( exp_name, exp_syntax, osnum, &expid ) == EXP_S_SUCCESS)
              {
                ex$message ( msgnumb = AS_S_TxtCre );
                DIupdate_form ();
                DIInsertName ( exp_name );
                DIobject_added ( exp_name );
              }
              else
              {
                ex$message ( msgnumb = AS_S_SynErr );
                DIActivateEditField ();
              }
            }
            else
            {
              if (exp$create ( exp_name = exp_name, exp_syntax = syntax,
                    p_exp_id = &expid )== EXP_S_SUCCESS)
              {
                long msg;
                
                ex$message ( msgnumb = AS_S_EqnCrea, type = "%s", var = `syntax` );                
                dp$erase_hilite ( msg = &msg );
                DIclear_hilited ();
                DIInsertName ( exp_name );
                nd$exec_batch ();
                DIobject_added ( exp_name );

              }
              else
                DIActivateEditField ();
            }
          }
          else
          {
            int ReturnStatus;
            
            /*
             * We create a directory
             */
            ReturnStatus = di$mkdir ( dirname = syntax );
            if (ReturnStatus & 1)
            {
              ex$message ( msgnumb = GR_S_Mkdir, type = "%s", var = `syntax` );
            }
            else
              if (ReturnStatus == DIR_E_DIR_DUP)
              {
                ex$message ( msgnumb = GR_E_DIR_DUP );
              }
              else
                if (ReturnStatus == DIR_W_NAME_NOT_FOUND)
                {
                  ex$message ( msgnumb = GR_E_INVARG );
                }
                else
                  if (ReturnStatus == DIR_E_PERMISSION)
                  {
                    ex$message ( msgnumb = GR_E_PERM );
                  }
                  else
                  {
                    ex$message ( msgnumb = GR_E_Mkdir );
                  }
          }
        break;
      }
      else
      {
        int CountBefore, CountAfter;

        /*
         * Get a count of the number of objects
         */
        di$ls ( ptr= &CountBefore );
        
        strcpy ( DILastEditedString, DIEditedString );
        if (!(DIput_edited () & 1))
        {
          /*
           * An error occured, put the user back in the edit field
           */
          DIActivateEditField ();
          break;
        }
        else
        {
          int  ReturnStatus;
          char ObjectName [DI_PATH_MAX];
          long msg;

          ex$message(msgnumb = AS_S_ExpMod);          
          ReturnStatus = di$untranslate ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid,
            objname = ObjectName );
          if (ReturnStatus & 1)
          {
            di$split ( pathname = ObjectName, name = ObjectName );
            DIInsertName ( ObjectName );
          }
          dp$erase_hilite ( msg = &msg );
          DIclear_hilited ();
        }
      
        /*
         * We want to update the form
         */
        {
          GRobjid    cmdobj;
          GRspacenum cmdos;
          int        ReturnStatus;
          
          ReturnStatus = FIf_get_cmd_oid_os ( DIform, &cmdobj, &cmdos );
          if (ReturnStatus)
            return;
          ReturnStatus = om$send ( msg = message FIdirform.update (),
            senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos );
          if (!(ReturnStatus & 1))
            return;
        }

        /*
         * We may have added an new expression. For instance, the user edits
         * a=10 into a+b=10 and b didn't exist before. In this case, we want 
         * to scroll the window to that new expression and leave the edit form
         * up.
         */
        di$ls ( ptr = &CountAfter );
        if (CountAfter != CountBefore)
        {
          char **Names = NULL;
          int  ReturnStatus;
          
          ReturnStatus = di$ls ( ptr = &CountAfter, lines = &Names );
          if (ReturnStatus & 1)
          {
            DIobject_added ( Names [CountAfter - 1] );
            di$free ( count = CountAfter, lines = Names );
            Names = NULL;
            
            /*
             * We don't want to delete the edit form.
             */
            break;
          }
        }
      }
            
    case 4: /* Delete the edit form */
      DIDeleteEditForm ();
      break;
            
    case 15: /* Set Initial values */
      {
        struct GRid *cyc_grid = (struct GRid *)alloca(sizeof(struct GRid) * MAX_NUM_EQN_VAR);
        int cyc_count, i, stat;
        IGRlong ReturnStatus;
        IGRchar full_name[DI_PATH_MAX], rel_dir_name[DI_PATH_MAX], name[DI_PATH_MAX];    
        FIg_set_state_off ( DIEditForm, GadgetLabel );
        
        if (om$is_objid_valid ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid ) 
                    == OM_S_SUCCESS)
        {
          if (di$untranslate ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid, 
                           objname = name ) & 1)
          {
    
            ReturnStatus = EQfind_loop_elmts ( DIEditedGrid, cyc_grid, &cyc_count );
            if ( ( ! ( ReturnStatus & 0x00000001 ) ) ) 
            { 
              printf ( "\nError at line %d of the file %s :\n" , __LINE__, __FILE__ ); 
              som_report_error ( ( ( ReturnStatus ) ) ); 
              return; 
            }
    
          }
          else
            cyc_count = 0;
        }
        else
          cyc_count = 0;

        if (cyc_count >= MAX_NUM_EQN_VAR)
          Error_Text( EXP_MEM_FAIL, (int *) "to find cycle" ) ;
      
        if (cyc_count > 0)
        {
          char *var_name[MAX_NUM_EQN_VAR];
          double *var_init_value = (double *)alloca(cyc_count * sizeof(double));
          double *original_value = (double *)alloca(cyc_count * sizeof(double));          
          IGRboolean recalc_cycle;

          recalc_cycle = FALSE;
                        
          for (i = 0; i < cyc_count; i++)
          {
            om$send(msg=message expression.NDgive_value(&var_init_value[i]),
                               senderid = NULL_OBJID,
                      	   targetos = cyc_grid[i].osnum, 
                      	   targetid = cyc_grid[i].objid);

            original_value[i] =  var_init_value[i];
            stat = EXP_rec_untranslate( cyc_grid[i].objid , cyc_grid[i].osnum, full_name);
            if((stat!=DIR_S_SUCCESS)&&(stat!=DIR_W_NAME_NOT_FOUND))
              di$report_error(sts = stat);
            
            if(full_name[0] != '\0') 
            {
              di$split(pathname = full_name, name = name, dirname = rel_dir_name);
            }
            var_name[i] = (char *)alloca(strlen(name) + 1);
            strcpy(var_name[i], name);
          }
          
          if (EXPGiveInitialValues (var_name, cyc_count, var_init_value) == OM_S_SUCCESS)
          {
            for (i = 0; i < cyc_count; i++)
            {
              om$send(msg=message expression.put_value(var_init_value[i]),
                             senderid = NULL_OBJID,
                        	   targetos = cyc_grid[i].osnum, 
                        	   targetid = cyc_grid[i].objid);
  
              if (fabs(original_value[i] - var_init_value[i]) > 1.e-10)
                 recalc_cycle = TRUE;
            }


            if (recalc_cycle)
            {
               ReturnStatus = om$send(msg = message expression.NDchange_node( NULL ),
                                senderid = NULL_OBJID,
                   	        targetos = cyc_grid[0].osnum, 
                   	        targetid = cyc_grid[0].objid);
               if ( ( ! ( ReturnStatus & 0x00000001 ) ) ) 
               { 
                 printf ( "\nError at line %d of the file %s :\n" , __LINE__, __FILE__ ); 
                 som_report_error ( ( ( ReturnStatus ) ) ); 
                 return; 
               }
              /*
               * We want to update the form
               */
              {
                GRobjid    cmdobj;
                GRspacenum cmdos;
                int        ReturnStatus;
                
                ReturnStatus = FIf_get_cmd_oid_os ( DIform, &cmdobj, &cmdos );
                if (ReturnStatus)
                  return;
                ReturnStatus = om$send ( msg = message FIdirform.update (),
                  senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos );
                if (!(ReturnStatus & 1))
                  return;
              }
      
            }

          }
        }
      }
      break;

  case 12: /* event/push on queue button */
    *alpha = '\0';
    FIg_get_text ( DIEditForm, 14, alpha );
    if (*alpha)
    {
      long size, msg;
      int  resp;

      size = strlen ( alpha ) + 1;
      resp = EX_STRING;
      ex$putque ( msg = &msg,
        response = &resp, pos = FRONT, byte = &size, buffer = alpha );
      
      /*
       * We are done with the form
       */
      DIDeleteEditForm ();
    }
    break;
  }
}


void DIActivateEditField ()
/*
 * This routine acivates the edit field of the form
 */
{
  int x, y, ReturnStatus;
  char buffer[70];

  if (!DIEditForm)
  {
    int x, y;
    FIf_get_location ( DIform, &x, &y );    
    ReturnStatus = FIf_new ( 0, "GRModifExp", DIModifNotify, &DIEditForm );
    if (ReturnStatus)
      return;
#ifdef CLIX    
    FIf_set_location(DIEditForm, x, y+85);      
#else
   {
#include "wl.h"
      WLuint32 lwin_no;
      int      x1, y1, in_window, key_buttons;

      
      WLmouse_win_position ( &lwin_no, &x1, &y1, &in_window ); 
      FIf_set_location(DIEditForm, x + 510, y1 );
    }
#endif
   /*
    * Can the user set initial values?
    */
   if (*DIEditedString != '\0')
   {
      struct GRid    *cyc_grid = (struct GRid *)alloca(sizeof(struct GRid) * MAX_NUM_EQN_VAR);
      int            cyc_count;
      char       name [DI_PATH_MAX];      
      long ReturnStatus;
      int in_master_file = 0;
      DIspacenum curr_osnum;
      DIobjid    curr_objid;
      

        if (om$is_objid_valid ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid ) 
                    == OM_S_SUCCESS)
        {
          if (di$untranslate ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid, 
                           objname = name ) & 1)
          {
    
            ReturnStatus = EQfind_loop_elmts ( DIEditedGrid, cyc_grid, &cyc_count );
            if ( ( ! ( ReturnStatus & 0x00000001 ) ) ) 
            { 
              printf ( "\nError at line %d of the file %s :\n" , __LINE__, __FILE__ ); 
              som_report_error ( ( ( ReturnStatus ) ) ); 
              return; 
            }

            ex$get_cur_mod ( id = &curr_objid, osnum = &curr_osnum );
            if (curr_osnum == DIEditedGrid.osnum)
              in_master_file = 1;
    
          }
          else
            cyc_count = 0;
        }
        else
          cyc_count = 0;

      if (cyc_count)
        FIg_enable ( DIEditForm, 15 );
      else
        FIg_disable ( DIEditForm, 15 );

      FIg_enable ( DIEditForm, 12 );
      
      ex$message ( msgnumb = AS_P_EqnEdit, buff = buffer );        
      FIg_set_text ( DIEditForm, 11, buffer );
   }
   else
   {
     FIg_disable ( DIEditForm, 15 );
     FIg_disable ( DIEditForm, 12 );       
     ex$message ( msgnumb = AS_P_EqnAdd, buff = buffer );        
     FIg_set_text ( DIEditForm, 11, buffer );
   }

        
    FIg_set_text ( DIEditForm, EDIT_FIELD, DIEditedString );
    FIf_display ( DIEditForm );
    DILocked++;
  }

  if (DIEditForm)
  {
    FIg_get_location ( DIEditForm, EDIT_FIELD, &x, &y );
    FIf_process_point ( DIEditForm, x + 12, y + 1, MIDDLE_BUTTON, SINGLE_CLICK, 0 );
  }
}


void DIInsertName ( Name )
char *Name	/* The name of the entry to insert			IN  */;
/*
 * This entry point inserts the name passed in at the position specified by the user
 * through the arrow buttons (if any)
 */
{
  int    GadgetIndex, State, Flag, RelativePosition, NameIndex, NameIndex2, 
         NameIndexOrigin, ReturnStatus;
  char   Line [DI_PATH_MAX], **OpenNames = NULL;
  DIgrid *OpenGrids = NULL;
  int    OpenCount = 0;

  /*
   * Do we have to make sure the object is inserted in a certain place?
   */
  for (GadgetIndex = 100, State = 0; GadgetIndex < 114; GadgetIndex++)
  {
    FIg_get_state ( DIform, GadgetIndex, &State );
    if (State)
      break;
  }
   
  if (State)
  {
    ReturnStatus = di$dump ( lines = &OpenNames, options = NULL, grids = &OpenGrids,
      ptr = &OpenCount );

    if (ReturnStatus & 1)
    {
      for (NameIndex = 0, Line [0] = '\0'; NameIndex < DIform_find_count; NameIndex++)
      {
        FIfld_get_text ( DIform, INNER_WINDOW, NameIndex, 0, DI_PATH_MAX, Line, 
          &Flag, &RelativePosition );
        if (RelativePosition == GadgetIndex - 100)
          break;
      }
      
      /*
       * We remove everybody after the position
       */
      for (NameIndexOrigin = NameIndex2 = ++NameIndex; NameIndex2 < OpenCount; NameIndex2++)
      {
        GRclassid ClassId;
        
        om$get_classid ( objid = OpenGrids [NameIndex2].objid, 
          osnum = OpenGrids [NameIndex2].osnum, p_classid = &ClassId );
        if (om$is_ancestry_valid ( subclassid = ClassId,
              superclassid = OPP_IGRdir_class_id ) == OM_S_SUCCESS)
        {
          OpenGrids [NameIndex2].objid = NULL_OBJID;
          NameIndex++;
        }
        else
          di$rm_index ( index = NameIndex );
      }
      
      /*
       * We remove and then add the entry we are supposed to insert.
       */
      for (NameIndex2 = 0; NameIndex2 < OpenCount; NameIndex2++)
      {
        di$split ( pathname = OpenNames [NameIndex2], name = OpenNames [NameIndex2] );
        if (!strcmp ( Name, OpenNames [NameIndex2] ))
        {
          if (NameIndex2 < NameIndexOrigin)
            di$rm_index ( index = NameIndex2 );

          di$add_name ( objname = OpenNames [NameIndex2],
            objid = OpenGrids [NameIndex2].objid );
	  OpenGrids [NameIndex2].objid = NULL_OBJID;
        }
      }

      /*
       * We put everybody back in the directory
       */
      for (NameIndex = NameIndexOrigin; NameIndex < OpenCount; NameIndex++)
        if (OpenGrids [NameIndex].objid != NULL_OBJID)
          di$add_name ( objname = OpenNames [NameIndex],
            objid = OpenGrids [NameIndex].objid );

      di$free ( lines = OpenNames, count = OpenCount );
      free ( OpenGrids );
      OpenNames = NULL;
      OpenGrids = NULL;
    }
  } 
}


void DIobject_added ( name )
char *name /* The name of the object that was added			IN  */;
/*
 * This routine scrolls the INNER window (named elements) to the end and activates
 * the edit/add field.
 */
{
  int         i, ReturnStatus, dir_count, non_dir_count, flag, rel_pos;
  struct GRid grid;
  GRclassid   classid;
  char        tmp [DI_PATH_MAX];
    
  ReturnStatus = di$translate ( objname = name, p_osnum = &grid.osnum, p_objid = &grid.objid );
  if (ReturnStatus & 1)
  {
    for (i = 0, dir_count = 0, non_dir_count = 0; i < DIform_find_count; i++)
    {
      om$get_classid ( osnum = DIform_find_grids [i].osnum, objid = DIform_find_grids [i].objid,
          p_classid = &classid );
      if (om$is_ancestry_valid ( subclassid = classid, 
              superclassid = OPP_IGRdir_class_id ) == OM_S_SUCCESS)
        dir_count++;
      else 
        non_dir_count++;

      if (grid.osnum == DIform_find_grids [i].osnum &&
          grid.objid == DIform_find_grids [i].objid)
      {
        FIfld_get_text ( DIform, INNER_WINDOW, non_dir_count - 1, 0, DI_PATH_MAX, 
            tmp, &flag, &rel_pos );
        if (rel_pos == -1)
          FIfld_set_active_row ( DIform, INNER_WINDOW, non_dir_count - 1, 1 );
        break;
      }
    }
  }

  if (DIEditForm)
    FIg_set_text ( DIEditForm, EDIT_FIELD, "" );

  DIActivateEditField ();
}


void DIintercept_routine ( form, xpos, ypos, button, trans, t_tag )
Form form;
int  xpos, ypos, button, trans, t_tag;
{
  int        row = -1, col = -1, flag, rel_pos, update = 0, sts, num_rows;
  char       current_dir [DI_PATH_MAX];
  static int last_tag = -1, last_xpos = -1, last_ypos = -1;

  /*
   * We ignore everything when a subform is up
   */
  if (DILocked)
    return;

  if (trans == DOUBLE_CLICK)
    button = LEFT_BUTTON;
  else
    if ((t_tag - last_tag < 30) && (trans == SINGLE_CLICK) && 
        (button == MIDDLE_BUTTON) && 
        abs ( xpos - last_xpos ) <= 2 && 
        abs ( ypos - last_ypos ) <= 2)
      /* we have a double click, same as LEFT_BUTTON */
      button = LEFT_BUTTON;
  last_tag = t_tag;
  last_xpos = xpos;
  last_ypos = ypos;

  if (button == LEFT_BUTTON)
  {
    char *p_left_bracket;
    
    /* That's a cd for directories and edit for others */
    FIfld_find_row_and_column ( form, INNER_WINDOW, xpos, ypos, &row, &col );
    FIfld_get_num_rows ( form, INNER_WINDOW, &num_rows ); 
    if (row == -1 && col == -1 && row < num_rows)
    {
      FIfld_find_row_and_column ( form, DIR_WINDOW, xpos, ypos, &row, &col );
      FIfld_get_num_rows ( form, DIR_WINDOW, &num_rows ); 
      if (row != -1 && col != -1 && row < num_rows)
      {
        *current_dir = '\0';
        FIfld_get_text ( form, DIR_WINDOW, row, col, DI_PATH_MAX, 
            current_dir, &flag, &rel_pos );
        if (*current_dir)
        {
          sts = di$cd ( dirname = current_dir );
          if (sts == DIR_W_DIR_NOT_FOUND)
          {
            p_left_bracket = strchr(current_dir, '(');
            if (p_left_bracket)
            {
              if (!strcmp(p_left_bracket, "()"))
                 *p_left_bracket = '\0';

               sts = di$cd ( dirname = current_dir );
               if (sts == DIR_W_DIR_NOT_FOUND)
                 ex$message ( field = ERROR_FIELD, msgnumb = GR_E_DIR_NOT_FOUND );
            }
/* ADDED FOR VDS OBJECTS */
            else{
		char *p_left_info_begin,
                     *p_left_info_end ;

                p_left_info_begin = strchr( current_dir, '[' ) ;

                if( p_left_info_begin ) {
                        p_left_info_end = strchr( p_left_info_begin, ']' ) ;

                        if( p_left_info_end )
                                *p_left_info_begin = '\0' ;

                       sts = di$cd( dirname = current_dir ) ;
                       if( sts == DIR_W_DIR_NOT_FOUND )
                               ex$message( field = ERROR_FIELD,
                                           msgnumb = GR_E_DIR_NOT_FOUND ) ;
               }
               else
                 ex$message ( field = ERROR_FIELD, msgnumb = GR_E_DIR_NOT_FOUND
);
            }
/* ADDED FOR VDS OBJECTS */
/***
            else
              ex$message ( field = ERROR_FIELD, msgnumb = GR_E_DIR_NOT_FOUND );            
 ***/
          }

          di$pwd ( dirname = current_dir );
          if (!*current_dir)
          {
            DIstrcpy ( current_dir, DIR_G_str_dir );
            FIg_set_text ( form, CURRENT_DIR_FIELD, current_dir );
          }
          update = TRUE;
        }
      }
      else
        FIf_process_point ( form, xpos, ypos, button, trans, t_tag );
    }
    else
    {
      *DIEditedString = '\0';
      *current_dir = '\0';
      FIfld_get_text ( form, INNER_WINDOW, row, col, DI_PATH_MAX, 
        current_dir, &flag, &rel_pos );
      if (*current_dir)
      {
        DIget_edited ( current_dir );
        if (*DIEditedString)
        {
          /*
           * Make the edit field active
           */
          DIActivateEditField ();
          update = 1;
        }
        else
          FIf_process_point ( form, xpos, ypos, button, trans, t_tag );
      }
    }
  }
  else
  {
    FIfld_find_row_and_column ( form, INNER_WINDOW, xpos, ypos, &row, &col );
    FIfld_get_num_rows ( form, INNER_WINDOW, &num_rows ); 
    if (row != -1 && col != -1 && row < num_rows)
    {
      char szText [DI_PATH_MAX];
      int  nIndex, nFlag, nPosition;
      long msg;
      
      /*
       * We hilite that row
       */
      DIclear_hilited ();
      dp$erase_hilite ( msg = &msg );
      FIfld_get_text ( form, INNER_WINDOW, row, col, DI_PATH_MAX, 
        szText, &nFlag, &nPosition );
      for (nIndex = 0; nIndex < DIform_find_count; nIndex++)
        if (!strcmp ( szText, DIform_find_lines [nIndex] ))
        {
          DIhilite_line ( &DIform_find_grids [nIndex] );
          dp$display ( msg = &msg, mode = GRhd, oids = &DIform_find_grids [nIndex] );
        }
    }
    else
      FIf_process_point ( form, xpos, ypos, button, trans, t_tag );
  }

  if (update)
  {
    GRobjid    cmdobj;
    GRspacenum cmdos;
    
    sts = FIf_get_cmd_oid_os ( form, &cmdobj, &cmdos );
    if (sts)
      return;
    sts = om$send ( msg = message FIdirform.update (),
      senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos );
    if (!(sts & 1))
      return;
  }
}


DIrectory_command_form ()
{
  GRobjid objid;
  
  return om$construct ( classname = "FIdirform", p_objid = &objid,
      msg = message FIdirform.init_form () );
}


method init_form ()
{
  int ret, ReturnStatus;

  if (!DIform)
  {
    ret = FIf_new (DIform, "GRDirCmds", DIdirform_process_form, &DIform);
    if (ret)
      return OM_E_ABORT;
    ret = FIf_set_cmd_oid_os ( DIform, my_id, OM_Gw_current_OS );
    if (ret)
      return OM_E_ABORT;
    ReturnStatus = om$send ( msg = message FIdirform.set_gadgets (), targetid = my_id );
    if (!(ReturnStatus & 1))
      return OM_E_ABORT;
  
    /*
     * Set the interception routine
     */
    FIf_set_button_intercept_routine ( DIform, DIintercept_routine );
    
    /* add my name to the IGENOD directory */
    di$add_name ( osnum = OM_Gw_current_OS,
                  objid = my_id,
                  path = "IGENOD",
                  objname = "DirCmds" );
    
    /*
     * Clear edited string
     */
    *DIEditedString = '\0';
    ReturnStatus = om$send ( msg = message FIdirform.update (), targetid = my_id );
    if (!(ReturnStatus & 1))
      return OM_E_ABORT;
  
    ret = FIf_display ( DIform );
    if (ret)
      return OM_E_ABORT;
    DILocked = 0;
  }

  return OM_S_SUCCESS;
}


%safe
static int  first = 1;
%endsafe



method do_form ( long *msg; int form_label; int gadget_label; double value)
{

  int    sts, 
         field,   /* Field of instance data needing modify    */
         pop,     /* Does the button need to be popped up     */
         update;   /* Update the display field with a FIND     */
  long   msg, size;
  char   auto_cd [DI_PATH_MAX], buf [DI_PATH_MAX], cmd [DI_PATH_MAX];
  char   alpha [DI_PATH_MAX];
  int    ret, ReturnStatus1, resp;

  sts = OM_S_SUCCESS;
  pop = FALSE;
  update = FALSE;
  strcpy ( cmd, "" );
  strcpy ( auto_cd, "" );
  if (gadget_label != DELETE_BUTTON)
    *DILastEditedString = '\0';

  /*
   * Do not erase the hilite because in this case we amke a decision based
   * upon it.
   */
  if (gadget_label != 18)
  {
    dp$erase_hilite ( msg = &ReturnStatus1 );
    DIclear_hilited ();
  }
  
  switch (gadget_label)
  {
  case ADD_BUTTON:
    *DIEditedString = '\0';
    DIActivateEditField ();
    break;

  case EXIT_BUTTON:
    FIg_set_state_off ( DIform, gadget_label );
    FIf_delete ( DIform );
    DIform = NULL; /* indicates form no longer exists */
    om$send ( msg = message Root.delete ( 1 ), targetid = my_id );
    break;

  case WINDOW_BUTTON:
    break;
  
  case HELP_BUTTON:
    pop   = TRUE;
    field = HELP_BUTTON;
    break;

  case CD_BUTTON:
    if ( DIstrcmp ( me->info.command, "off" ) )
    {
      DIstrcpy ( me->info.command, "off" );
      field = CD_BUTTON;
      {
         /* Put the button back to FALSE position */
         ret = FIg_set_state_off (DIform, CD_BUTTON);
      }
    }
    else
    {
      pop = TRUE;
      DIstrcpy ( me->info.command, "on" );
    }

    break;

  case DASH_BUTTON:
    pop   = TRUE;
    field = DASH_BUTTON;
    DIstrcpy ( auto_cd, "-" );

    break;

  case RMDIR_BUTTON:
    pop = TRUE;
    DIdelete_name ( NULL, 1 );
    update = TRUE;
    break;

  case MKDIR_BUTTON:
    pop = TRUE;
    DImake_directory ();
    update = TRUE;
    break;

  case SORT_TOGGLE:
    update = TRUE;
    break;

  case CURRENT_DIR_FIELD:
    ret = FIg_get_text(DIform, CURRENT_DIR_FIELD, alpha);
    DIConvertToLongPath ( alpha );
    DIstrcpy ( auto_cd, alpha );
    break;

  case START_DIR_FIELD:
    ret = FIg_get_text(DIform, START_DIR_FIELD, alpha);
    if (DIstrcmp ( alpha, "" ))
      DIstrcpy ( me->info.title, alpha );
    else
      DIstrcpy ( me->info.title, "." );

    update = TRUE;

    break;

  case BOTTOM_LINE_FIELD:
    break;

  case REPORT_BUTTON:
    pop = TRUE;
    DIprint_report ();
    break;

  case CURRENT_DIR_TITLE:
    FIg_erase ( DIform, CURRENT_DIR_TITLE );
    FIg_erase ( DIform, CURRENT_DIR_FIELD );
    FIg_display ( DIform, START_DIR_TITLE );
    FIg_display ( DIform, START_DIR_FIELD );
    break;

  case START_DIR_TITLE:
    FIg_erase ( DIform, START_DIR_TITLE );
    FIg_erase ( DIform, START_DIR_FIELD );
    if (!me->info.title [0] || (me->info.title [0] == '.' && !me->info.title [1]))
      FIg_set_color ( DIform, CURRENT_DIR_TITLE, FI_BLACK );
    else
      FIg_set_color ( DIform, CURRENT_DIR_TITLE, FI_BLUE );
    FIg_display ( DIform, CURRENT_DIR_TITLE );
    FIg_display ( DIform, CURRENT_DIR_FIELD );
    break;

  case 18:
    /*
     * Push event on queue. First we see if we can find a row that is
     * hilited
     */
    {
      int  nIndex, nMaxIndex, nFlag, nPosition, nResponse, nIndex2, nColor;
      char szText [DI_PATH_MAX], szName [DI_PATH_MAX];
      long lMessage, lSize, status;
      
      FIfld_get_num_rows ( DIform, INNER_WINDOW, &nMaxIndex );
      for (nIndex = 0; nIndex < nMaxIndex; nIndex++)
      {
        FIfld_get_line_color ( DIform, INNER_WINDOW, nIndex, 0, &nColor );
        if (nColor == FI_OFF_WHITE)
        {
          /*
           * We put the name of the guy on the queue.
           */
          FIfld_get_text ( DIform, INNER_WINDOW, nIndex, 0, DI_PATH_MAX, 
            szText, &nFlag, &nPosition );
          for (nIndex2 = 0; nIndex2 < DIform_find_count; nIndex2++)
            if (!strcmp ( szText, DIform_find_lines [nIndex2] ))
            {
              status = di$untranslate ( osnum = DIform_find_grids [nIndex2].osnum, 
                objid = DIform_find_grids [nIndex2].objid, 
                objname = szName );
              if (status & 1)
              {
                 lSize = strlen ( szName ) + 1;
              }
              else
              {
                status = Extract_from_expr (szText, szName, &lSize);
              }
              nResponse = EX_STRING;
              ex$putque ( msg = &lMessage, response = &nResponse,
                pos = FRONT, byte = &lSize, buffer = szName );
              break;
            }
        
          break;
        }
      }
    }
    dp$erase_hilite ( msg = &ReturnStatus1 );
    DIclear_hilited ();
    break;
    
  default:
    break;
  }

  if ( pop )
  {
    /* we don't want to pop up the selected gadget and the automatic
       cd mode gadget must stay down as long as we are in automatic
       cd mode */
    if ((me->last_icon != -1) && (me->last_icon != gadget_label) &&
        (me->last_icon != CD_BUTTON))
    {
      /* Put the button back to FALSE position */
      ret = FIg_set_state_off(DIform, me->last_icon);
    }
    me->last_icon = gadget_label;
  }

  if ( *cmd )
  {
    size = strlen ( cmd ) + 1;
    resp = EX_CMD_KEY;

    sts = ex$putque ( msg      = &msg,
                      response = &resp,
                      pos      = FRONT,
                      byte     = &size,
                      buffer   = cmd );

/*  Commented out following code because user is not going to keyin 
    'report directory' command -- msm
*/
/*    if (!DIstrcmp ( cmd, "GRRpDr" ))
    {
      DIstrcpy ( cmd, alpha );
      size = strlen ( cmd ) + 1;
      resp = EX_STRING;

      sts = ex$putque ( msg      = &msg,
          response = &resp,
          pos      = BACK,
          byte     = &size,
          buffer   = cmd );
    }*/
  }

  if (*auto_cd)
  {
    sts = di$cd ( dirname = auto_cd  );
    if (sts == DIR_W_DIR_NOT_FOUND)
      ex$message ( field = ERROR_FIELD, msgnumb = GR_E_DIR_NOT_FOUND );

    di$pwd ( dirname = buf );

    if (!*buf)
    {
      DIstrcpy ( buf, DIR_G_str_dir );
      ret = FIg_set_text(DIform, CURRENT_DIR_FIELD, buf);
    }
    update = TRUE;
  }

  if (update)
    om$send ( msg = message FIdirform.update (), targetid = my_id );

  return OM_S_SUCCESS;
}


void DIInitShortFileList ( PForm, GadgetLabel, DisplayStar )
Form *PForm	/* The form to work with				IN  */;
int  GadgetLabel/* The gadget to work with				IN  */;
int  DisplayStar/* Start the lsit with a '*'?				IN  */;
/*
 * Initialize the list of choices for gadget GadgetLabel in form PForm
 * with the possible short cuts for file names.
 */
{
  int        Count, FileIndex, RowIndex;
  char       **FileNames = NULL, FileName [DI_PATH_MAX], RegularExpression [DI_PATH_MAX];
  GRspacenum Osnum;

  if (DisplayStar)  
  {
    FIg_set_text ( *PForm, GadgetLabel, "*" );
    FIfld_set_list_text ( *PForm, GadgetLabel, 0, 0, "*", 0 );
    RowIndex = 1;
  }
  else
    RowIndex = 0;
    
  ex$get_cur_mod ( osnum = &Osnum );
  DIstmocpy ( RegularExpression, "ref", "*", NULL, Osnum );
  di$ls ( regexp = RegularExpression, ptr = &Count, lines = &FileNames, options = NULL );
  for (FileIndex = 0; FileIndex < Count; FileIndex++)
  {
    di$split ( pathname = FileNames [FileIndex], name = FileNames [FileIndex] );
    if (strcmp ( FileNames [FileIndex], "refnames" ))
    {
      strcat ( strcpy ( FileName, "$" ), FileNames [FileIndex] );
      FIfld_set_list_text ( *PForm, GadgetLabel, RowIndex++, 0, 
          FileName, 0 );
    }
    else
    {
      DIstmocpy ( FileName, "usr", NULL, Osnum );
      FIfld_set_list_text ( *PForm, GadgetLabel, RowIndex++, 0, FileName, 0 );
    }
  }

  di$free ( lines = FileNames, count = Count );
}


method update ()
{
  int    i, sts, dir_count, non_dir_count, dir_field_count, 
         non_dir_field_count, sel_flag, position;
  char   tmp [DI_PATH_MAX], alpha [DI_PATH_MAX];

  /*
   * We get the list of valid file names
   */
  DIInitShortFileList ( &DIform, CURRENT_DIR_FIELD, 0 );

  FIfld_get_num_rows ( DIform, DIR_WINDOW, &dir_field_count );
  FIfld_get_num_rows ( DIform, INNER_WINDOW, &non_dir_field_count );
  
  if (DIform_find_lines)
  {
    di$free ( lines = DIform_find_lines, count = DIform_find_count );
    DIform_find_lines = NULL;
  }
  
  if (DIform_find_grids)
  {
    free ( DIform_find_grids );
    DIform_find_grids = NULL;
  }
  
  sts = di$form_find ( start_dir = me->info.title, 
      lines = &DIform_find_lines, grids = &DIform_find_grids, ptr = &DIform_find_count );

  /*
   * We always have .. in the list of directories
   */
  if (!dir_field_count)
  {
    char      tmp [DI_PATH_MAX];
    int	      sf, pos;
    FIfld_get_text ( DIform, DIR_WINDOW, 0, 0, DI_PATH_MAX, tmp, &sf, &pos );
    if( strcmp( tmp, ".." ) )
    {
    	FIfld_set_text ( DIform, DIR_WINDOW, 0, 0, "..", 0 );      
    }
    
  }

  
  /* Fill out the display field with the results of find */
  for (i = 0, dir_count = 1, non_dir_count = 0; i < DIform_find_count; i++)
  {
    GRclassid classid;
    int       dir; 
    char      tmp [DI_PATH_MAX];
    
    if (om$get_classid ( osnum = DIform_find_grids [i].osnum, objid = DIform_find_grids [i].objid,
          p_classid = &classid ) == OM_S_SUCCESS)
      dir = om$is_ancestry_valid ( subclassid = classid, 
        superclassid = OPP_IGRdir_class_id ) == OM_S_SUCCESS;
    else
      dir = 0;
      
    if (dir)
    {
      if (dir_count / 4 < dir_field_count)
        FIfld_get_text ( DIform, DIR_WINDOW, dir_count / 4, dir_count % 4, 
          DI_PATH_MAX, tmp, &sel_flag, &position );
      else
      {
        *tmp = '\0';
        sel_flag = 0;
      }
      if (strcmp ( tmp, DIform_find_lines [i] ))
      {
        FIfld_set_text ( DIform, DIR_WINDOW, dir_count / 4, dir_count % 4, 
            DIform_find_lines [i], sel_flag );
      }
      dir_count++;
    }
    else
    {
      if (non_dir_count < non_dir_field_count)
        FIfld_get_text ( DIform, INNER_WINDOW, non_dir_count, 0, DI_PATH_MAX, 
            tmp, &sel_flag, &position );
      else
      {
        *tmp = '\0';
        sel_flag = 0;
      }
      if (strcmp ( tmp, DIform_find_lines [i] ))
        FIfld_set_text ( DIform, INNER_WINDOW, non_dir_count, 0, DIform_find_lines [i], sel_flag );
      non_dir_count++;
    }
  }

  /*
   * See if we need to erase the old lines
   */

  if (dir_count / 4 < dir_field_count)
  {
    char      tmp [DI_PATH_MAX];
    int	      sf, pos;

    for (i = 0; i < 4 * 4; i++)
    {
          FIfld_get_text ( DIform, DIR_WINDOW, (i + dir_count) / 4, (i + dir_count) % 4, DI_PATH_MAX, tmp, &sf, &pos );
	  if( strcmp( tmp, "" ) )
	  {
           FIfld_set_text ( DIform, DIR_WINDOW, (i + dir_count) / 4, (i + dir_count) % 4, "", 0 );             
          }

    }
/*
 * ‚    FIfld_set_num_rows ( DIform, DIR_WINDOW, dir_count );
 */

  }
  
  if (non_dir_count < non_dir_field_count)
    FIfld_set_num_rows ( DIform, INNER_WINDOW, non_dir_count );

  FIg_get_text ( DIform, CURRENT_DIR_FIELD, alpha );
  DIterminator ( alpha );

  di$pwd ( dirname = tmp );

  DIterminator ( tmp );
  if (DIstrcmp ( alpha, tmp ))
  {
    if ( !*tmp )
      DIstrcpy ( tmp, DIR_G_str_dir );
    
    DIConvertToShortPath ( tmp );
    FIg_set_text ( DIform, CURRENT_DIR_FIELD, tmp );
  }
  /*
   * Are the arrow buttons available?
   */
  {
    int State, GadgetIndex;
    
    FIg_get_state ( DIform, SORT_TOGGLE, &State );
    if (State && !strcmp ( DIform_find_start, "." ))
      for (GadgetIndex = 100; GadgetIndex < 114; GadgetIndex++)
        FIg_display ( DIform, GadgetIndex );
    else
      for (GadgetIndex = 100; GadgetIndex < 114; GadgetIndex++)
        FIg_erase ( DIform, GadgetIndex );
  }

  return OM_S_SUCCESS;
}


method set_gadgets ()
{
  char dir [DI_PATH_MAX];
  
  first = 1;
  di$pwd ( dirname = dir );
  if (!DIstrcmp ( dir, "" ))
    DIstrcpy ( dir, DIR_G_str_dir );

  /* The title field will be used for the regular expression */
  DIstrcpy ( me->info.title, "." );

  /* The command field will be used for the auto_cd mode */
  DIstrcpy ( me->info.command, "off" );

  /* last icon doesn't exist yet */
  me->last_icon = -1;

  om$send ( msg = message FIdirform.update (), targetid = my_id );

  return OM_S_SUCCESS;
}


DIget_edited ( name )
char *name 	  /* The name selected by the end user			IN  */;
/*
 * This routine initializes DIEditedString and DIEditedGrid based on the
 * selected entry in the form.
 */
{
  int sts, i;

  for (i = 0, sts = OM_W_ABORT; i < DIform_find_count; i++)
    if (!strcmp ( name, DIform_find_lines [i] ))
    {
      OM_S_MESSAGE             msg;
      struct { char *string; } argument;
      OMuword                  clid;
      
      /*
       * We found the guy -> hilite it and format the edit string
       */
      {
        long msg;
        
        DIhilite_line ( &DIform_find_grids [i] );
        dp$display ( msg = &msg, mode = GRhd, oids = &DIform_find_grids [i] );
      }

      argument.string = &DIEditedString [0];
      sts = om$get_classid ( osnum = DIform_find_grids [i].osnum, objid = DIform_find_grids [i].objid, 
        p_classid = &clid );
      if (sts == OM_S_SUCCESS)
      {
        sts = om$make_message ( classid    = clid,
                                methodname = "DIget_edit_string",
                                size       = sizeof ( argument ),
                                p_arglist  = &argument,
                                p_msg      = &msg );
        if (sts == OM_S_SUCCESS)

          sts = om$send ( msg = &msg, senderid = NULL_OBJID,
              targetid = DIform_find_grids [i].objid, 
              targetos = DIform_find_grids [i].osnum );
      }
      
      DIEditedGrid.osnum = DIform_find_grids [i].osnum;
      DIEditedGrid.objid = DIform_find_grids [i].objid;
      break;
    }
    
  if (sts != OM_S_SUCCESS)
  {
    for (i = 0; i < DIform_find_count; i++)
      if ((DIform_find_grids [i].osnum == DIEditedGrid.osnum) && 
          (DIform_find_grids [i].objid == DIEditedGrid.objid))
      {
        di$untranslate ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid, 
            objname = DIEditedString );
        di$split ( pathname = DIEditedString, name = DIEditedString );
        break;
      }
  }
    
  return OM_S_SUCCESS;
}


DIput_edited ()
/*
 * This procedure puts the edited value back into the system. If the object doesn't
 * understand the message, then a simple change name is performed (including for
 * directories). If the new name is empty, that's a remove name.
 */
{
  OM_S_MESSAGE             msg;
  struct { char *string; } argument;
  OMuword                  clid;
  int                      sts, ReturnStatus = OM_E_ABORT;
  char                     new_string [DI_PATH_MAX];

  /*
   * Send the DIput_edit_string to the object
   */
  *new_string = '\0';
  FIg_get_text ( DIEditForm, EDIT_FIELD, new_string );
  if (!*new_string || (!strcmp ( new_string, DIEditedString )))
  {
    *DIEditedString = '\0';
    return OM_S_SUCCESS;
  }

  sts = om$get_classid ( osnum = DIEditedGrid.osnum, objid = DIEditedGrid.objid, 
    p_classid = &clid );
  argument.string = new_string;
  if (sts == OM_S_SUCCESS)
  {
    sts = om$make_message ( classid    = clid,
      methodname = "DIput_edit_string",
      size       = sizeof ( argument ),
      p_arglist  = &argument,
      p_msg      = &msg );
    if (sts == OM_S_SUCCESS)
    {
      ReturnStatus = om$send ( msg = &msg, senderid = NULL_OBJID,
        targetid = DIEditedGrid.objid, targetos = DIEditedGrid.osnum );

  
      if (ReturnStatus & 1)
      {
        long msg;
        dp$display ( msg = &msg, oids = &DIEditedGrid);
      }  
    }
  }

  if (sts != OM_S_SUCCESS)
  {
    /*
     * The object doesn't understand the DIput_edit_string message,
     * this becomes a DI rename.
     */
    ReturnStatus = di$rename ( oldname = DIEditedString, newname = new_string );
    if (ReturnStatus == DIR_E_NAME_DUP)
    {
      ex$message ( field = ERROR_FIELD, msgnumb = GR_E_DupNme );
    }
    else
    {
      ex$message ( field = ERROR_FIELD, msgnumb = GR_E_InvNme );
    }
  }

  if (ReturnStatus & 1)
  {
    nd$exec_batch ();
    *DIEditedString = '\0';
  }

  return ReturnStatus;
}


%safe
static Form report_form = NULL;
%endsafe

#argsused
void DIprocess_dir_report ( form_label, gadget_label, value )
int form_label;
int  gadget_label;
double value;
{
  char file_name [DI_PATH_MAX], tmp_name[5];
  int  i;
  FILE *fet;

  if (report_form && (gadget_label == 1 || gadget_label == 4))
  {
    *file_name = '\0';
    FIg_get_text ( report_form, 20, file_name );

    if (gadget_label == 1)
    {
      strncpy (tmp_name, file_name, 4);
      tmp_name[4] = '\0';

      /* Find out whether file name is UNIX window or not. If UNIX window
         e.g /dev/console, no need to check whether file exists or not and
         just print the contents.
      */

      if (strcmp (tmp_name, "/dev")) {
      /*
         Make sure we prompt before overwriting an existing file
      */

         fet = fopen ( file_name, "r" );
         if (fet)
         {
           char buffer [DI_PATH_MAX];

           fclose ( fet );
           ex$message ( msgnumb = GR_P_FlExOv, buff = buffer );
           if (GRconfirm_box ( buffer ) != TRUE) {
             FIf_delete ( report_form );
             report_form = NULL;
             DILocked--;
             return;
           }
         }
      }

      /* open the file */
      fet = fopen ( file_name, "w" );
      if (fet)
      {
        for (i = 0; i < DIform_find_count; i++)
          fprintf ( fet, "%3d: %s - (%d, %d)\n", i, DIform_find_lines [i], 
              DIform_find_grids [i].osnum, DIform_find_grids [i].objid );
    
        /* close the file */
        fclose ( fet );
      }
    }

    FIf_delete ( report_form );
    report_form = NULL;
    DILocked--;
  }

  return;
}


DIprint_report ()
/*
 * This routine takes a file name from the user and writes the list of
 * names and grid's to the specified file.
 */
{
  int x, y, f_x, f_y, ReturnStatus;


  FIf_get_location ( DIform, &f_x, &f_y );    
  FIg_get_location ( DIform,  MKDIR_BUTTON, &x, &y );  
  
  ReturnStatus = FIf_new ( 1, "GRDirReport", DIprocess_dir_report, &report_form );
  if (!ReturnStatus)
  {
    FIf_set_location(report_form, f_x + x, f_y + y);    
    FIf_display ( report_form );
    FIg_get_location ( report_form, NAME_FIELD, &x, &y );
    FIf_process_point ( report_form, x + 2, y + 2, MIDDLE_BUTTON, SINGLE_CLICK, 0 );
    DILocked++;
  }

  return OM_S_SUCCESS;  
}


%safe
static Form mkdir_form = NULL;
%endsafe

#argsused
void DIprocess_mkdir ( form_label, gadget_label, value )
int form_label;
int  gadget_label;
double value;
{
  char dir_name [DI_PATH_MAX];
  int  ReturnStatus;

  if (mkdir_form && (gadget_label == 1 || gadget_label == 4))
  {
    *dir_name = '\0';
    FIg_get_text ( mkdir_form, 20, dir_name );
    FIf_delete ( mkdir_form );
    mkdir_form = NULL;
    DILocked--;

    if (gadget_label != 4)
    {
      ReturnStatus = di$mkdir ( dirname = dir_name );
      if (ReturnStatus & 1)
      {
        ex$message ( msgnumb = GR_S_Mkdir, type = "%s", var = `dir_name` );
        DIupdate_form ();
      }
      else
        if (ReturnStatus == DIR_E_DIR_DUP)
        {
          ex$message ( msgnumb = GR_E_DIR_DUP );
        }
        else
          if (ReturnStatus == DIR_W_NAME_NOT_FOUND)
          {
            ex$message ( msgnumb = GR_E_INVARG );
          }
          else
            if (ReturnStatus == DIR_E_PERMISSION)
            {
              ex$message ( msgnumb = GR_E_PERM );
            }
            else
            {
              ex$message ( msgnumb = GR_E_Mkdir );
            }
    }
  }

  return;
}


DImake_directory ()
/*
 * This routine takes a directory name from the user and attempts to create it.
 */
{
  int  x, y, f_x, f_y, ReturnStatus;
  char buffer [DI_PATH_MAX];

  FIf_get_location ( DIform, &f_x, &f_y );    
  FIg_get_location ( DIform,  MKDIR_BUTTON, &x, &y );  
  ReturnStatus = FIf_new ( 1, "GRDirReport", DIprocess_mkdir, &mkdir_form );
  if (!ReturnStatus)
  {
    FIf_set_location(mkdir_form, f_x + x, f_y + y);    
    DILocked++;
    ex$message ( msgnumb = GRC_M_CreateDir, buff = buffer );
    FIg_set_text ( mkdir_form, TITLE, buffer );
    FIf_display ( mkdir_form );
    FIg_get_location ( mkdir_form, NAME_FIELD, &x, &y );
    FIf_process_point ( mkdir_form, x + 2, y + 2, MIDDLE_BUTTON, SINGLE_CLICK, 0 );
  }

  return OM_S_SUCCESS;  
}


%safe
static Form rmdir_form = NULL;
%endsafe

#argsused
void DIprocess_rmdir ( form_label, gadget_label, value )
int form_label;
int  gadget_label;
double value;
{
  char            dir_name [DI_PATH_MAX];
  int             i, dir, ReturnStatus;
  GRspacenum      osnum;
  GRobjid         objid;
  GRclassid       class_id;
  long            msg;
  struct GRmd_env md_env;
  struct GRid     grid;

  if (rmdir_form && (gadget_label == 1 || gadget_label == 4))
  {
    *dir_name = '\0';
    FIg_get_text ( rmdir_form, 20, dir_name );
    FIf_delete ( rmdir_form );
    rmdir_form = NULL;
    DILocked--;
    
    if (DIEditForm)
    {
      FIf_delete ( DIEditForm );
      DIEditForm = NULL;
      DILocked--;
    }

    if (gadget_label != 4)
    {
      ReturnStatus = di$translate ( objname = dir_name, p_objid = &objid, p_osnum = &osnum );
      if (ReturnStatus & 1)
      {
        om$get_classid ( objid = objid, osnum = osnum, p_classid = &class_id );
        dir = om$is_ancestry_valid ( subclassid = class_id,
            superclassid = OPP_IGRdir_class_id ) == DIR_S_SUCCESS;
      }
      else
        dir = 1;
      
      if (dir)
      {      
        ReturnStatus = di$rmdir ( dirname = dir_name );
        if (ReturnStatus & 1)
        {
          ex$message ( msgnumb = GR_S_Rmdir, type = "%s", var = `dir_name` );
          DIupdate_form ();
        }
        else
          if (ReturnStatus == DIR_W_NAME_NOT_FOUND)
          {
            ex$message ( msgnumb = GR_E_INVARG );
          }
          else
            if (ReturnStatus == DIR_E_PERMISSION)
            {
              ex$message ( msgnumb = GR_E_PERM );
            }
            else
            {
              ex$message ( msgnumb = GR_E_Rmdir );
            }
      }
      else
      {
        /*
         * We can only delete in the module object space
         */
        ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
        if (md_env.md_id.osnum == osnum)
        {
          md_env.md_env.matrix_type = MAIDMX;
          for (i = 1; i < 15; i++)
            md_env.md_env.matrix [i] = 0.0;
          for (i = 0; i < 16; i += 5)
            md_env.md_env.matrix [i] = 1.0;
          grid.osnum = osnum;
          grid.objid = objid;
          dp$display ( msg = &msg, mode = GRbehe, oids = &grid );
          om$send ( msg = message GRgraphics.GRdelete ( &msg, &md_env ),
            senderid = NULL_OBJID, targetos = osnum, targetid = objid );
          if (!(msg & 1))
          {
            ex$message ( msgnumb = GR_E_Del );
          }
          else
          {
            nd$exec_batch ();
          }
        }
        else
        {
          ex$message ( msgnumb = GR_E_NoDel );
        }
      }
    }
  }

  return;
}


DIdelete_name ( name, dir )
char *name	/* The name of the object (might be NULL)		IN  */;
int  dir	/* Is it a directory?					IN  */;
/*
 * This routine takes a directory/element name from the user and attempts to delete it.
 */
{
  int  x, y, f_x, f_y, ReturnStatus;
  char buffer [DI_PATH_MAX];

  if (rmdir_form)
    return OM_S_SUCCESS;

  FIf_get_location ( DIform, &f_x, &f_y );    
  FIg_get_location ( DIform,  MKDIR_BUTTON, &x, &y );  

  ReturnStatus = FIf_new ( 1, "GRDirReport", DIprocess_rmdir, &rmdir_form );
  if (!ReturnStatus)
  {
    FIf_set_location(rmdir_form, f_x + x, f_y + y);        
    if (name)
    {
      FIg_set_text ( rmdir_form, NAME_FIELD, name );
      ex$message ( msgnumb = dir ? GRC_M_DelDir : GRC_M_Del, buff = buffer );
      FIg_set_text ( rmdir_form, TITLE, buffer );
      ex$message ( msgnumb = dir ? GR_P_Cd : GR_P_EnterName, buff = buffer );
      FIg_set_text ( rmdir_form, PROMPT, buffer );
    }
    else
    {
      ex$message ( msgnumb = GRC_M_DelDir, buff = buffer );
      FIg_set_text ( rmdir_form, TITLE, buffer );
    }

    DILocked++;
    FIf_display ( rmdir_form );
    FIg_get_location ( rmdir_form, NAME_FIELD, &x, &y );
  }

  return OM_S_SUCCESS;  
}


DIunhilite_line ( p_grid )
struct GRid *p_grid	/* The grid of the line to be unhilited		IN  */;
/*
 * This routine unhilites the specified line.
 */
{
  int  i, line_count = 0;
  long msg;

  if (DIform)
  {  
    /*
     * Find the grid and if it is there then unhilite it
     */
    for (i = 0; i < DIform_find_count; i++)
      if ((DIform_find_grids [i].osnum == p_grid->osnum) &&
          (DIform_find_grids [i].objid == p_grid->objid))
      {
        FIfld_set_line_color ( DIform, INNER_WINDOW, line_count, 0, FI_BLACK );
        dp$erase_hilite ( msg = &msg );
        break;
      }
      else
      {
        GRclassid classid;
    
        om$get_classid ( osnum = DIform_find_grids [i].osnum, objid = DIform_find_grids [i].objid,
            p_classid = &classid );
        if (om$is_ancestry_valid ( subclassid = classid, 
                superclassid = OPP_IGRdir_class_id ) != OM_S_SUCCESS)
          line_count++;
      }
  }

  return OM_S_SUCCESS;
}


DIhilite_line ( p_grid )
struct GRid *p_grid	/* The grid of the line to be hilited		IN  */;
/*
 * This routine hilites the specified line.
 */
{
  int  i, line_count = 0;

  if (DIform)
  {  
    /*
     * Find the grid and if it is there then hilite it
     */
    for (i = 0; i < DIform_find_count; i++)
      if ((DIform_find_grids [i].osnum == p_grid->osnum) &&
          (DIform_find_grids [i].objid == p_grid->objid))
      {
        FIfld_set_line_color ( DIform, INNER_WINDOW, line_count, 0, FI_OFF_WHITE );
        break;
      }
      else
      {
        GRclassid classid;
    
        om$get_classid ( osnum = DIform_find_grids [i].osnum, objid = DIform_find_grids [i].objid,
            p_classid = &classid );
        if (om$is_ancestry_valid ( subclassid = classid, 
                superclassid = OPP_IGRdir_class_id ) != OM_S_SUCCESS)
          line_count++;
      }
  }
  
  return OM_S_SUCCESS;
}


DIhilite_lines ( grids, count )
struct GRid *grids	/* The grids of the lines to be hilited		IN  */;
int count   	        /* The number of grids				IN  */;
/*
 * This routine hilites the specified lines.
 */
{
  int  i;
  long msg;
  
  if (DIform)
    for (i = 0; i < count; i++)
    {
      dp$display ( msg = &msg, mode = GRhd, oids = &grids [i] );
      DIhilite_line ( &grids [i] );
    }
      
  return OM_S_SUCCESS;
}


DIclear_hilited ()
/*
 * This routine clears the hilited lines, if any.
 */
{
  if (DIform)
  {
    int  i, row, length, sel, pos;
    char *text;
      
    for (i = 0; i < DIform_find_count; i++)
      FIfld_set_line_color ( DIform, INNER_WINDOW, i, 0, FI_BLACK );
  
    FIfld_get_active_row ( DIform, INNER_WINDOW, &row, &pos );
    if (row > -1)
    {
      FIfld_get_text_length ( DIform, INNER_WINDOW, row, 0, &length );
      if (length)
      {
        text = (char *)alloca ( length + 1 );
        FIfld_get_text ( DIform, INNER_WINDOW, row, 0, length + 1, text, &sel, &pos );
        if (sel)
          FIfld_set_text ( DIform, INNER_WINDOW, row, 0, text, 0, 0 );
      }
    }

    FIfld_get_active_row ( DIform, DIR_WINDOW, &row, &pos );
    if (row > -1)
      for (i = 0; i < 4; i++)
      {
        FIfld_get_text_length ( DIform, DIR_WINDOW, row, i, &length );
        if (length)
        {
          text = (char *)alloca ( length + 1 );
          FIfld_get_text ( DIform, DIR_WINDOW, row, i, length + 1, text, &sel, &pos );
          if (sel)
            FIfld_set_text ( DIform, DIR_WINDOW, row, i, text, 0, 0 );
        }
      }
  }

  return OM_S_SUCCESS;
}


DIprint_lines ( )
/*
 * This routine prints the equation lines
 */
{
  int  i;
  char exp_syntax[EXP_MAX_LEN];
  long ReturnStatus;
  
  if (DIform)
  {  
    /*
     * Print each equation line 
     */
    for (i = 1; i < DIform_find_count; i++)
    {
      ReturnStatus = om$send(msg = message expression.give_syntax (exp_syntax),
          	   targetid = DIform_find_grids [i].objid,
          	   targetos = DIform_find_grids [i].osnum,
          	   senderid = NULL_OBJID);

      printf("objid = %d, syntax = %s",DIform_find_grids [i].objid, exp_syntax);
      printf("\n");
      
    }
  }
  return(1);
}


/*
 *  This routine expands "$ref_filename" into the full pathname.
 */

int DIConvertToLongPath(path)
char path[];
{
  char    *cl_ptr, *cl2_ptr;
  OMuword osnum;
  char    FileName[DI_PATH_MAX], FullPath[DI_PATH_MAX], 
          CurrentFileName [DI_PATH_MAX], CurrentFilePath [DI_PATH_MAX];

  if((path [0] == '$'))
  {
    strcpy ( FileName, path );
    if (cl2_ptr = strchr(FileName, ':'))
      *cl2_ptr = '\0';
    ex$get_cur_mod ( osnum = &osnum );
    if (strlen ( FileName ) > 1)
    {
      di$give_pathname ( osnum = osnum, pathname = CurrentFilePath );
      di$split ( pathname = CurrentFilePath, name = CurrentFileName );
      if (!strncmp ( CurrentFileName, &FileName [1], strlen ( CurrentFileName ) ))
        DIstmcpy ( FullPath, CurrentFilePath, "usr", 0 );
      else
        DIstmocpy ( FullPath, "ref", &FileName [1], "usr", 0, osnum );

      EXPsubstitute ( FileName, FullPath, path );
    }
    else
    {
      DIstmocpy ( FullPath, "usr", 0, osnum );
      if (cl_ptr = strchr ( path, ':' ))
        strcat ( FullPath, ++cl_ptr );
      strcpy ( path, FullPath );
    }
  }
    
  return OM_S_SUCCESS;
}


/*
 *  This routine converts a full pathname into "$ref_filename".
 */

int DIConvertToShortPath ( path )
char path[];
{
  char       FileName [DI_PATH_MAX], var_name [DI_PATH_MAX], CurrentDirectory [DI_PATH_MAX],
             CurrentFileName [DI_PATH_MAX], CurrentFilePath [DI_PATH_MAX];
  char       *prev_pos, *curr_pos;
  int        found, Length;
  GRspacenum osnum;

  prev_pos = path;
  found = FALSE;

  if (curr_pos = (char *)EXPlocate ( ":ref:", prev_pos ))
  {
    while (curr_pos)
    {
      found = TRUE;
      prev_pos = curr_pos;
      curr_pos = (char *)EXPlocate(":ref:", (prev_pos + strlen(":ref:")));    
    }
    
    if (found)
    {
      strcpy (FileName, (prev_pos + strlen(":ref:")));
      if (!(prev_pos = (char *)EXPlocate(":usr:", FileName)))
        prev_pos = (char *)EXPlocate(":usr", FileName);
      if (prev_pos)
      {
        if (curr_pos = strchr ( ++prev_pos, ':' ))
          strcpy ( var_name, ++curr_pos );
        else
          *var_name = '\0';
        *prev_pos = '\0';
        if (Length = strlen ( FileName ))
        {
          strcpy ( path, "$" );
          strcat ( path, FileName );
          if (*var_name)
            strcat ( path, var_name );
          else
            if (path [Length] == ':')
              path [Length] = '\0';
        }
      }
    }
  }
  else
  {
    int Done = 0;
    
    /*
     * We check if the name is in the current directory
     */
    di$pwd ( dirname = CurrentDirectory );
    Length = strlen ( CurrentDirectory );
    if (!strncmp ( path, CurrentDirectory, Length ))
      if (!strchr ( &path [Length + 1], ':' ))
      {
        memcpy ( path, &path [Length + 1], strlen ( path ) - Length );
        Done = 1;
      }

    if (!Done)
    { 
      ex$get_cur_mod ( osnum = &osnum );
      di$give_pathname ( osnum = osnum, pathname = CurrentFilePath );
      di$split ( pathname = CurrentFilePath, name = CurrentFileName );
      strcat ( CurrentFilePath, ":usr:" );
      Length = strlen ( CurrentFilePath );
      if (!strncmp ( CurrentFilePath, path, Length ))
      {
        char *pString1, *pString2;

        strcpy ( path, "$" );
        strcat ( path, CurrentFileName );
        for (pString1 = &path [strlen ( path )], pString2 = &path [Length - 1];;)
        {
          *pString1++ = *pString2++;
          if (!*pString2)
          {
            *pString1 = '\0';
            break;
          }
        }
      }
    }
  }

  return OM_S_SUCCESS;
}

int Extract_from_expr (szText, szName, plSize)
char *szText; 
char *szName;
long *plSize;
{
  char *pbracket = NULL;
  char *pcomma = NULL;
  
  pbracket = strchr(szText, '[');
  if (pbracket == NULL)
    find_var_name(szText, szName);
  else
  {
     pcomma = strchr(szText, ',');
     if (pcomma)
       find_var_name(pbracket, szName);
     else 
       find_var_name(szText, szName);  
  }  

  *plSize = strlen ( szName ) + 1;
  return(1);
}


int find_var_name(pstr, szName)
char *pstr; 
char *szName;
{
  char *pch;

  pch = pstr;

  while ((*pch) && (!is_first_letter(*pch)))
    pch++;
  if (*pch)
  {
    *szName = *pch;
    szName++;
    pch++;
    while ((*pch) && (is_valid_letter(*pch)))
    {
       *szName = *pch;
       szName++;
       pch++;
    }
  }
  *szName = '\0';
  return(1);
}

int is_first_letter(ch)
char ch;
{
  if ((ch >= 'a') && (ch <= 'z') ||
      (ch >= 'A') && (ch <= 'Z') ||
      (ch == '_') ||
      (ch == '.'))
      return (TRUE);
  else
      return (FALSE);
}

int is_valid_letter(ch)
char ch;
{
  if ((ch >= 'a') && (ch <= 'z') ||
      (ch >= 'A') && (ch <= 'Z') ||
      (ch == '_') ||
      (ch == '\''))
      return (TRUE);
  else
      return (FALSE);
}

end implementation FIdirform;
