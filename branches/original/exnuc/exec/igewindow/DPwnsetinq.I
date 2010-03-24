class implementation IGEwindow;

#define TRUE 1
#define FALSE 0

#include "OMmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "wl.h"


int DPsetinqwindow ( msg, inq0_set1, which_error, var_list, osnum, 
                     window_objid )
IGRlong     *msg;                   /* return message status */
IGRchar     inq0_set1;              /* 1 = set a value in view's inst data
                                       0 = inquire about a value */
IGRlong     *which_error;           /* pointer to an erroneous variable */
struct      win_var_list *var_list; /* list of variables to get */
GRspacenum  osnum;
GRobjid     window_objid;

{
   IGRlong      status;
   GRobjid      mod_objid;
   GRspacenum   mod_osnum;        

   *msg = MSSUCC;

   if (osnum == 0xFFFF)
      ex$get_cur_mod( id = &mod_objid, osnum = &mod_osnum);
   else
      mod_osnum = osnum;

   if ( !inq0_set1 )
   {
      status = om$send (mode = OM_e_wrt_object,
                        msg = message IGEwindow.DPinquire ( msg, 
                                                      which_error, var_list ),
                               senderid = NULL_OBJID,
                               targetid = window_objid,
                               targetos = mod_osnum);
      if ( !(status & 1))
      {
         printf("\nin DPsetinq  DPinquire failed\n");
         om$report_error(sts = status);
      }
   }
   else 
   {
      status = om$send (mode = OM_e_wrt_object,
                        msg = message IGEwindow.DPset ( msg, which_error,
                                                        var_list ),
                        senderid = NULL_OBJID,
                        targetid = window_objid,
                        targetos = mod_osnum);
      if ( !(status & 1))
      {
         printf("\nin DPsetinq  DPset failed\n");
         om$report_error(sts = status);
      }
   }
   return (status);
}         


method DPinquire (IGRlong *msg;IGRlong *which_error; 
		  struct win_var_list *var_list )
{
   IGRboolean           storage;
   IGRdouble            *temper;
   IGRint               *temp_int;
   IGRchar	        path_name[DI_PATH_MAX];
   IGRchar              name[DI_PATH_MAX];
   IGRlong              status;		

   for ( storage = TRUE;
         (var_list->var != END_PARAM) && (storage == TRUE); var_list++)
   {
      switch (var_list->var)
      {
         case HW_WIN_NO :
            storage = (var_list->num_bytes >= sizeof(ME.IGEgadget->win_no));
            if (storage)
            {
               *( (IGRint *)var_list->var_ptr) = ME.IGEgadget->win_no;
               *var_list->bytes_returned = sizeof (ME.IGEgadget->win_no);
            }
            break;

         case WINDOW_NAME :
            strcpy(name, " ");
            status = di$untranslate (objname = path_name,
                                     objid = my_id,
				     osnum = OM_Gw_current_OS);
            if ((!(status & 1)) && (status != DIR_W_NAME_NOT_FOUND))
            {
#ifdef DEBUG
               di$report_error(sts = status, comment = "untranslate failed in window DPinquire");
#endif
               goto wrapup;
            }

            if (status != DIR_W_NAME_NOT_FOUND)
            {
               status = di$split(pathname=path_name,
                                 name=name);

               if (!(status &1))
               {
#ifdef DEBUG
                  di$report_error(sts = status, comment = "split failed in window DPinquire");
#endif
                  goto wrapup;
               }
            }

            *(var_list->bytes_returned) = strlen(name) + 1;
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE(name, var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         case WINDOW_DEP :  
            *(var_list->bytes_returned) = (sizeof (IGRint) * 4);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               temp_int = (IGRint *) var_list->var_ptr;
               *temp_int++ = ME.IGEgadget->min_x_dep;
               *temp_int++ = ME.IGEgadget->min_y_dep;
               *temp_int++ = ME.IGEgadget->max_x_dep;
               *temp_int = ME.IGEgadget->max_y_dep;
            }  
            break;

         case WINDOW_INDEP :   
            *(var_list->bytes_returned) = (sizeof (IGRdouble) * 4);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               temper = (IGRdouble *) var_list->var_ptr;
               *temper++ = ME.IGEgadget->min_x_indep;
               *temper++ = ME.IGEgadget->min_y_indep;
               *temper++ = ME.IGEgadget->max_x_indep;
               *temper = ME.IGEgadget->max_y_indep;
            }                         
            break;

         case WINDOW_FLAGS :
            *(var_list->bytes_returned) = sizeof (ME.IGEwindow->flags);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->flags,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case SCREEN_NO :
            *(var_list->bytes_returned) = sizeof (int );
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->screen_no,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case WS_TYPE :
            *(var_list->bytes_returned) = sizeof (int);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->ws_type,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case WIN_TYPE :
            *(var_list->bytes_returned) = sizeof (int);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->win_type,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case WIN_LEVEL :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->level,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case RIGHT_SPACE :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->right_space, 
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case LEFT_SPACE :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->left_space,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case TOP_SPACE :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->top_space,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case BOTTOM_SPACE :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->bottom_space,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case DRAW_BORDER :
            *(var_list->bytes_returned) = sizeof (IGRboolean);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->draw_border,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case ICON_FLAGS :
            *(var_list->bytes_returned) = sizeof (IGRint);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->icon_flags,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case SYMBOL_NUMBER :
            *(var_list->bytes_returned) = sizeof (IGRshort);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE( (char *)&ME.IGEwindow->symbol_number,
                              var_list->var_ptr,
                              *var_list->bytes_returned);
            }  
            break;

         case SYMBOL_NAME :
            *(var_list->bytes_returned) = om$dimension_of(varray = me^^IGEwindow.symbol_name);
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE(me^^IGEwindow.symbol_name, var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         case COLLAPSE_POS:
            *(var_list->bytes_returned) = sizeof(IGRdouble) * 2;
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage)
            {
               OM_BLOCK_MOVE((char *)me^^IGEwindow.collapse_pos,
                             var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         case CURSOR_ENABLE_PATTERN :
            if (om$dimension_of(varray = me^^IGEwindow.cursor_def) < 66)
            {
               *(var_list->bytes_returned) = 0;
            }
            else
            {
               *(var_list->bytes_returned) = 32 * sizeof(IGRlong);
            }
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage && *var_list->bytes_returned)
            {
               OM_BLOCK_MOVE((char *)me^^IGEwindow.cursor_def,
                             var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         case CURSOR_DATA_PATTERN  :
            if (om$dimension_of(varray = me^^IGEwindow.cursor_def) < 66)
            {
               *(var_list->bytes_returned) = 0;
            }
            else
            {
               *(var_list->bytes_returned) = 32 * sizeof(IGRlong);
            }
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage && *var_list->bytes_returned)
            {
               OM_BLOCK_MOVE((char *)&me^^IGEwindow.cursor_def[32],
                             var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         case CURSOR_HOT_SPOT  :
            if (om$dimension_of(varray = me^^IGEwindow.cursor_def) < 66)
            {
               *(var_list->bytes_returned) = 0;
            }
            else
            {
               *(var_list->bytes_returned) = 2 * sizeof(IGRlong);
            }
            storage = (var_list->num_bytes >= *var_list->bytes_returned);
            if (storage && *var_list->bytes_returned)
            {
               OM_BLOCK_MOVE((char *)&me^^IGEwindow.cursor_def[64],
                             var_list->var_ptr,
                             *var_list->bytes_returned);
            }
            break;

         default :
            storage = FALSE;
            break;
      }  /* close for switch */
      if (storage == FALSE)
      {
         *which_error = var_list->var;
      }
   }    /* close for "for"  */

wrapup:

   *msg = (storage) ? MSSUCC : MSFAIL;
   status = (storage) ? OM_S_SUCCESS : OM_E_ABORT;
   return (status);
 }   /* close for inquire */




method DPset (IGRlong *msg;IGRlong *which_error; 
	      struct win_var_list *var_list )
{

        IGRboolean storage;
        IGRint *temp_int;
	IGRchar	path_name[DI_PATH_MAX];
	IGRchar	dir_name[DI_PATH_MAX];
	IGRchar	name[DI_PATH_MAX];
	IGRchar old_cur_dir[DI_PATH_MAX];
	IGRint temp_flag;
	IGRlong status;	
	
        for ( storage = TRUE;
              (var_list->var != END_PARAM) && (storage == TRUE); var_list++)
         {
            switch (var_list->var)
            {

            case WINDOW_NAME :

                storage = TRUE;
                status = di$untranslate ( objname = path_name,
                                          objid   = my_id,
                                          osnum   = OM_Gw_current_OS);
                if ((!(status & 1)) && (status != DIR_W_NAME_NOT_FOUND))
                {
#ifdef DEBUG
                   di$report_error(sts = status,
                             comment = "untranslate failed in window DPset");
#endif
                   goto wrapup;
                }

                if (status != DIR_W_NAME_NOT_FOUND)
                {
                   status = di$split (pathname = path_name,
                                      dirname  = dir_name,
                                      name     = name);
                   if (!(status &1))
                   {
#ifdef DEBUG
                      di$report_error(sts = status,
                                     comment = "split failed in window DPset");
#endif
                      goto wrapup;
                   }

                   DIstrcat(dir_name,var_list->var_ptr);
                   di$rename (oldname = path_name, newname = dir_name);
                   strcpy(name,var_list->var_ptr);
                }
                else
                {
                   strcpy(name,var_list->var_ptr);
                   di$pwd(dirname = old_cur_dir);
                   status = di$give_pathname ( osnum    = OM_Gw_current_OS,
                                               pathname = path_name);
                   if (!(1 & status))
                   {
#ifdef DEBUG
                      di$report_error ( sts = status, 
                                   comment = "in window DPset, give_pathname");
#endif
                      goto wrapup;
                   }

                   di$cd (dirname = path_name);
                   DIstrcat(path_name,"windows");
                   status = di$mkdir (dirname = path_name);
                   if ((!(1& status)) && (status != DIR_E_DIR_DUP))
                   {
#ifdef DEBUG
                      di$report_error( sts = status, 
                                  comment = "in window DPset, mkdir error");
#endif
                      di$cd(dirname = old_cur_dir);
                      goto wrapup;
                   }

                   DIstrcat(path_name,name);
                   status = di$add_name (objname = path_name,
                                         objid   = my_id);
                   if ((!(1& status)) && (status != DIR_E_NAME_DUP))
                   {
#ifdef DEBUG
                      di$report_error ( sts = status, 
                                comment = "in window DPset, add_name error");
#endif
                      di$cd(dirname = old_cur_dir);
                      goto wrapup;
                   }
                   di$cd(dirname = old_cur_dir);
                }
	 
                if ((ME.IGEwindow->flags & WIN_IS_ACTIVE) &&
                    (ME.IGEwindow->win_type == BORDER))
                {
                   WLset_window_name ( ME.IGEgadget->win_no, name );
                   status = OM_S_SUCCESS;
                }
                break;

            case WINDOW_FLAGS :   
                *(var_list->bytes_returned) = sizeof (IGRint) * 2;
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
        	   temp_int = (IGRint *) var_list->var_ptr;		    
        	   temp_flag = ME.IGEwindow->flags & ~ *temp_int++;
                   ME.IGEwindow->flags = temp_flag | *temp_int;
                }                         
                break;
            case ICON_FLAGS :   
                *(var_list->bytes_returned) = sizeof (IGRint) * 2;
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   temp_int = (IGRint *) var_list->var_ptr;		    
                   temp_flag = ME.IGEwindow->icon_flags & ~ *temp_int++;
                   ME.IGEwindow->icon_flags = temp_flag | *temp_int;
                }                         
                break;

            case SCREEN_NO :
                *(var_list->bytes_returned) = sizeof (int);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->screen_no = *(int *) var_list->var_ptr;
                }  
                break;

            case WIN_TYPE:   
                *(var_list->bytes_returned) = sizeof (int);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->win_type = *(int *) var_list->var_ptr;
                }                         
                break;

            case WIN_LEVEL :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->level = *(IGRshort *) var_list->var_ptr;
                }  
                break;

            case RIGHT_SPACE :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->right_space = *(IGRshort *) var_list->var_ptr;
                }  
                break;

            case LEFT_SPACE :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->left_space = *(IGRshort *) var_list->var_ptr;
                }  
                break;

            case TOP_SPACE :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                   ME.IGEwindow->top_space = *(IGRshort *) var_list->var_ptr;
                }  
                break;

            case BOTTOM_SPACE :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                  ME.IGEwindow->bottom_space = *(IGRshort *) var_list->var_ptr;
                }  
                break;


            case DRAW_BORDER :
                *(var_list->bytes_returned) = sizeof (IGRboolean);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                 ME.IGEwindow->draw_border = *(IGRboolean *) var_list->var_ptr;
                }  
                break;

            case SYMBOL_NUMBER :
                *(var_list->bytes_returned) = sizeof (IGRshort);
                storage = (var_list->num_bytes == *var_list->bytes_returned);
                if (storage)
                {
                  ME.IGEwindow->symbol_number = *(IGRshort *)var_list->var_ptr;
                }  
                break;

	    case SYMBOL_NAME  :

                 storage = TRUE;
                 *(var_list->bytes_returned) = strlen(var_list->var_ptr)+1;
		 om$vla_set_dimension (varray = me^^IGEwindow.symbol_name, 
					size = *(var_list->bytes_returned));
                  OM_BLOCK_MOVE( var_list->var_ptr,
                                 me^^IGEwindow.symbol_name, 
                                 *(var_list->bytes_returned) );
                 break;
	
            default :
                storage = FALSE;
                break;
            }  /* close for switch */
        if (storage == FALSE)
        {
           *which_error = var_list->var;
        }
     }    /* close for "for"  */

wrapup:

     *msg = (storage) ? MSSUCC : MSFAIL;
     status = (storage) ? OM_S_SUCCESS : OM_E_ABORT;
     return (status);

 }   /* close for set */


end implementation IGEwindow;
