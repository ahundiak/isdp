class implementation IGEdigwin;

#include <stdio.h>
#include <exdef.h>
#include <exmacros.h>
#include <ex.h>
#include <expriv.h>
#include <execmsg.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>
#include <exwl.h>
#include <OMerrordef.h>

#define BUFSIZE   512
extern struct EX_pmenu_entry EX_paper_menu[];
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <limits.h>

extern Display *EXdisplay;
extern int      Help_active();

#define MAX_WINDOW    40
#define MAX_REGION    20
#define MAX_TOTAL     60
#endif

#if defined( ENV5 )

method activate(IGRlong *msg; IGRint win_no )
{
   IGRint status;
   int    digix,digiy,digi0x,digi0y;
   int   rno;
   int   mask;

    digi0x = ME.IGEdigwin->org_x;
    digi0y = ME.IGEdigwin->org_y;
    digix  = ME.IGEdigwin->org_x + ME.IGEdigwin->ext_x;
    digiy  = ME.IGEdigwin->org_y + ME.IGEdigwin->ext_y;

    status = Create_dig_region(ME.IGEdigwin->fm,digi0x,digi0y,digix,digiy,&rno);
    if( status != 0 )
    {
        printf("\n IGEdigwin activate create digi region error");
    }                                    
    else
    {
        WLuint32              lwin;
        WLuint32              ctx_num;
        WLuint16              lscreen;
        int                   lscreen_type;
        EXwindata            *p_windata;
        struct WLnative_info  native_info;

        /*
         * Store the 'rno' returned by the above call in the instance.
         * This value is needed by the delete call.
         * Added this code for a problem faced by Mike Heatherly. - Srikanth.
         */

        ME.IGEdigwin->rno = rno;

        /*=======================*/
        /*  get the WL defaults  */
        /*=======================*/

        status = WLget_active_screen ( &lscreen, &lscreen_type );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        status = CMget_active_context ( lscreen, &ctx_num );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        /*====================================================*/
        /*  register the digitizer window with the WL system  */
        /*====================================================*/

        native_info.base_win = rno;

        status = WLadd_hardware_window ( rno, ctx_num, &native_info, &lwin );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        /*========================================================*/
        /*  now store the osnum and objid in WL user data fields  */
        /*========================================================*/

        p_windata = (EXwindata*)malloc (sizeof (EXwindata));
        if (!p_windata) return (OM_E_NODYNMEM);

        p_windata->id      = EX_DIGITIZER_WINDOW;
        p_windata->win_os  = OM_Gw_current_OS;
        p_windata->win_oid = my_id;

        status = WLset_user_data ( lwin, (void**)&p_windata, NULL );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        /*========================================================*/
        /*  store the logical window number in the instance data  */
        /*========================================================*/

        ME.IGEgadget->win_no = lwin;

        mask = 7;  /* 0111  button 0 1 2 */

        status = Set_dig_btn(rno,mask);
        if (status != 0)
        {
           printf ("\n IGEdigwin set btn error\n");
        }
        else
        {
             status = ex$add_win_to_exec(win_num = rno, objid = my_id,
                                         osnum = 1);
             if(! (1 &status) )
             {
                 printf("IGEdigwin add win to exec error\n");
             }
        }
    }

    return (status);
 }                  

method convert_pnt( IGRlong *msg; int *response; struct EX_button *pnt1)
{
    register int i,tmpx , tmpy;
    register struct EX_paper_cmd *cmd_entry;
    IGRlong    status = OM_S_SUCCESS;
    IGRlong num_byte;
    IGRlong mmsg;
    IGRint found;
    IGRint resp;
    char  r_d[8];
    status = OM_S_SUCCESS;
    found = 0;
    
    
    for( i = 0; i< ME.IGEdigwin->num_of_cmds; i++ )    
    {
	tmpx = (int)(pnt1->x);
	tmpy = (int)(pnt1->y);
	cmd_entry = ME.IGEdigwin->p_cmd + i;
	if( (tmpx > cmd_entry -> x1) &&
	    (tmpx < cmd_entry -> x2) &&
	    (tmpy > cmd_entry -> y1) &&
	    (tmpy < cmd_entry -> y2) )
	{
	   /* found entry */
	    num_byte = strlen(cmd_entry->input_string) + 1;
	    resp = cmd_entry->resp | EX_HARDWARE_GENERATED;
	    status = ex$putque( msg = &mmsg,
				pos=BACK,
       				response=&resp ,
				byte=&num_byte,
				buffer=cmd_entry->input_string ); 
	   found = 1;
           break; 
	}
    }
    if( found == 0 ) 
    {
	    resp = EX_POCKET;
	    r_d[0] = '\0';
	    num_byte = 1;
	    status = ex$putque( msg = &mmsg,
				pos=BACK,
       				response=&resp ,
				byte=&num_byte,
				buffer=r_d ); 
    }
    return(status);
}

method delete( int flag )
{
     IGRlong status;
     int entry_found;
     register int i;
    /* find out if anybody else is using the memory */
     entry_found = FALSE;

     for (i=EX_PMENU_NUM - 1; i> -1; i--)
     {
         if (( EX_paper_menu[i].win_id != NULL_OBJID) &&
	     ( EX_paper_menu[i].win_id != my_id) )
	 {
	    if(EX_paper_menu[i].p_cmd == ME.IGEdigwin->p_cmd)
   	    {
		entry_found = TRUE;
		    break;
	    }
	 }
     }
     if( !entry_found )
     {
        if(ME.IGEdigwin->p_cmd) free( ME.IGEdigwin->p_cmd );
     }

/*     Delete_dig_region(ME.IGEgadget->win_no); - Mike Heatherly's problem */
     Delete_dig_region(ME.IGEdigwin->rno);

     status =  om$send ( mode = OM_e_wrt_message,
                         msg = message Root.delete(0),
                         senderid = my_id,
                         targetid = my_id);
     if(! (1&status) )
     {
          printf("IGEdigwin delete self error \n");
     }
     return(status);
}



method create( IGRint fm; IGRint org_x; IGRint org_y; IGRchar *path;
                          IGRint *cmdnum;  struct EX_paper_cmd **addr_cmdptr )
{
  FILE *fp;  
  int x_ext,y_ext;/* size of paper menu */
  int digix,digiy; /* abs digitizer area */
  register int    cmd_count, i, line_num;
  register struct EX_paper_cmd *cmd1;
  int x1, y1, x2, y2;
  int num_read;
  int response;
  int status; 
  struct EX_paper_cmd *cmd;
  char  *outstr;
  char   s[BUFSIZE];               
  char   key_str[BUFSIZE];
  char   ch;

   ME.IGEdigwin->fm = fm;
   ME.IGEdigwin->org_x = org_x;
   ME.IGEdigwin->org_y = org_y;
   i = 0;

   if(! (fp = (FILE *) fopen( path, "r") ) )
   {
       ex$message(msgnumb = EX_F_CanNotLMenu);
       return(OM_E_ERROR);
   }
   else
   {
       status = Inq_dig(&digix,&digiy);
       status = TRUE;
       if(fscanf(fp,"%d%c%d",&x_ext,&ch,&y_ext) != 3)
       {
          fclose(fp);
          return(OM_E_ERROR);
       }
       else
       {
           if ( x_ext > digix || y_ext > digiy
                || x_ext <= 0 || y_ext <= 0 )
           {
              ex$message(msgnumb = EX_F_WrongDigSize);
	      fclose(fp);
	      return(OM_E_ERROR);
           }
           else
	   {
	       ME.IGEdigwin->ext_x = x_ext;
	       ME.IGEdigwin->ext_y = y_ext;

               if( *addr_cmdptr != NULL )
	       {
	          ME.IGEdigwin->p_cmd = *addr_cmdptr;
	          ME.IGEdigwin->num_of_cmds = *cmdnum;
	       }
	       else
	       {
		   cmd_count = 0;
		   while ( fgets(s, BUFSIZE, fp) != NULL )
		   { 
		      if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
 			 continue;
		      ++cmd_count;
		   }
		   fclose(fp);
		   if( cmd_count )
		   {
		       if ( ! ( cmd = ( struct EX_paper_cmd *) 
			  malloc ( cmd_count * sizeof ( struct EX_paper_cmd ) ))) 
  		       {
			     printf("no memory for cmd\n");
		       }
		       else
		       {
			    if(! (fp = (FILE *) fopen( path, "r") ) )
			    {
				ex$message(msgnumb = EX_F_CanNotLMenu);
				return(OM_E_ERROR);
			    }
			    else
			    {
			       fscanf(fp,"%d%c%d",&x_ext,&ch,&y_ext);
			       line_num = 0;
                               i = 0;
			       while( fgets(s, BUFSIZE, fp) != NULL )
			       {
				   line_num++;
				   if((s[0] == '#') || (s[0] == ' ') || 
				      (s[0] == '\t') || (s[0] == '\n'))
         				      continue;
				   if((num_read = sscanf(s,"%d,%d,%d,%d,%d,%[^\n]\n",
				       &x1,&y1,&x2,&y2,&response,key_str )) >= 5 )  
				   {
                                       cmd1 = cmd + i;   
				       cmd1->x1 = (x1 < x2) ? x1 : x2;
				       cmd1->y1 = (y1 < y2) ? y1 : y2;
				       cmd1->x2 = (x1 < x2) ? x2 : x1;
				       cmd1->y2 = (y1 < y2) ? y2 : y1;
				       cmd1->resp = response;
				       if( num_read == 6 )
				       {
					  EX_cmdgetptr(key_str, &outstr);
					  cmd1->input_string = outstr;
				       }
				       else
				       {
					  cmd1->input_string = NULL;
				       }
				       i++;
				   }
				   else
				   {
				       printf("\nwrong entry in paper menu <%s>\n",path);
				       printf("possible error in entry %d, field %d\n",line_num,num_read+1);
				   }
			       }
  			       fclose(fp);   
			       ME.IGEdigwin->num_of_cmds = cmd_count;
			       ME.IGEdigwin->p_cmd = cmd;
			       *cmdnum = cmd_count;
			       *addr_cmdptr = cmd;
			    }
		       }
		   } /* there is cmd */
               }
	   } /* ext is correct */
       } /* file opened */
   }
   return(OM_S_SUCCESS);
}


#endif



#if defined( CLIX ) && defined( X11 )

#include <X11/extensions/XDigitizer.h>

method activate(IGRlong *msg; IGRint win_no )
{
   IGRint status;
   long           digi0x,digi0y;
   unsigned long  digix,digiy;
   DigRegion   rno;
   unsigned long   mask;
   WLuint32    lwin;
   OMuword     lwin_os;
   OM_S_OBJID  lwin_oid;
   int  surface;

   status = 1;

    digi0x = ME.IGEdigwin->org_x;
    digi0y = ME.IGEdigwin->org_y;
    digix  = ME.IGEdigwin->ext_x;
    digiy  = ME.IGEdigwin->ext_y;

    surface = ( ME.IGEdigwin->fm == 1 ) ? FloatingMenuSurface : DigitizerSurface;

    rno = XCreateDigitizerRegion( EXdisplay, surface, digi0x,digi0y, digix,digiy);
    if( (rno != NoDigitizer) && (rno != NoFloatingMenu) && 
        (rno != BadValue )  && (rno != BadAlloc ) )
    {
        ME.IGEgadget->win_no = rno;
        mask = DigitizerButton1Mask | DigitizerButton2Mask | DigitizerButton3Mask ;
        /* mask = 7;  0X0111  button 0 1 2 */

        XSetDigitizerButton(EXdisplay,rno,mask);

        XSetDigitizerButtonEvent( EXdisplay, rno, DigButtonPressMask |
	                   DigButtonReleaseMask | DigButtonTimeoutMask );

        status = ex$add_win_to_exec(win_num = rno, objid = my_id, osnum = 1);
        if(! (1 &status) )
        {
            printf("IGEdigwin add win to exec error\n");
        }
        EX_trans_win(rno, &lwin, &lwin_os, &lwin_oid);
        /*  EX_scr[slot] = -1;        /* dig win  screen set to -1 */
        ME.IGEgadget->win_no = lwin;

    }
    else
    {
        printf("\n IGEdigwin activate create digi region error");
    }                                    


    return (status);
 }                  

method convert_pnt( IGRlong *msg; int *response; struct EX_button *pnt1)
{
    register int i,tmpx , tmpy;
    register struct EX_paper_cmd *cmd_entry;
    IGRlong    status = OM_S_SUCCESS;
    IGRlong num_byte;
    IGRlong mmsg;
    IGRint found;
    IGRint resp;
    char  r_d[8];
    status = OM_S_SUCCESS;
    found = 0;
    
    
    for( i = 0; i< ME.IGEdigwin->num_of_cmds; i++ )    
    {
	tmpx = (int)(pnt1->x);
	tmpy = (int)(pnt1->y);
	cmd_entry = ME.IGEdigwin->p_cmd + i;
	if( (tmpx > cmd_entry -> x1) &&
	    (tmpx < cmd_entry -> x2) &&
	    (tmpy > cmd_entry -> y1) &&
	    (tmpy < cmd_entry -> y2) )
	{
	   /* found entry */
	    num_byte = strlen(cmd_entry->input_string) + 1;
	    resp = cmd_entry->resp | EX_HARDWARE_GENERATED;
	    status = ex$putque( msg = &mmsg,
				pos=BACK,
       				response=&resp ,
				byte=&num_byte,
				buffer=cmd_entry->input_string ); 
	   found = 1;
           break; 
	}
    }
    if( found == 0 ) 
    {
	    resp = EX_POCKET;
	    r_d[0] = '\0';
	    num_byte = 1;
	    status = ex$putque( msg = &mmsg,
				pos=BACK,
       				response=&resp ,
				byte=&num_byte,
				buffer=r_d ); 
    }
    return(status);
}

method delete( int flag )
{
     int         status;
     int         entry_found;
     register int i;
     WLuint16   lscreen;
     int        lscreen_type;
     WLuint32   lwin;
     WLuint32   ctx_num;
     struct WLnative_info  native_info;

     /* find out if anybody else is using the memory */

     entry_found = FALSE;

     for (i=EX_PMENU_NUM - 1; i> -1; i--)
     {
         if (( EX_paper_menu[i].win_id != NULL_OBJID) &&
	     ( EX_paper_menu[i].win_id != my_id) )
	 {
	    if(EX_paper_menu[i].p_cmd == ME.IGEdigwin->p_cmd)
   	    {
		entry_found = TRUE;
		    break;
	    }
	 }
     }
     if( !entry_found )
     {
        if(ME.IGEdigwin->p_cmd) free( ME.IGEdigwin->p_cmd );
     }


     lwin = ME.IGEgadget->win_no;

     status = WLget_active_screen ( &lscreen, &lscreen_type );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     status = CMget_active_context ( lscreen, &ctx_num );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     status = WLget_native_info ( lwin, ctx_num, &native_info );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     XDestroyDigitizerRegion( EXdisplay, native_info.base_win);

     status =  om$send ( mode = OM_e_wrt_message,
                         msg = message Root.delete(0),
                         senderid = my_id,
                         targetid = my_id);
     if(! (1&status) )
     {
          printf("IGEdigwin delete self error \n");
     }
     return(status);
}



method create( IGRint fm; IGRint org_x; IGRint org_y; IGRchar *path;
                          IGRint *cmdnum;  struct EX_paper_cmd **addr_cmdptr )
{
  FILE *fp;  
  int x_ext,y_ext;/* size of paper menu */
  int digix,digiy; /* abs digitizer area */
  register int    cmd_count, i, line_num;
  register struct EX_paper_cmd *cmd1;
  int x1, y1, x2, y2;
  int num_read;
  int response;
  int status; 
  struct EX_paper_cmd *cmd;
  DigConfig  dig;
  char  *outstr;
  char   s[BUFSIZE];               
  char   key_str[BUFSIZE];
  char   ch;




   ME.IGEdigwin->fm = fm;
   ME.IGEdigwin->org_x = org_x;
   ME.IGEdigwin->org_y = org_y;
   i = 0;

   if(! (fp = (FILE *) fopen( path, "r") ) )
   {
       ex$message(msgnumb = EX_F_CanNotLMenu);
       return(OM_E_ERROR);
   }
   else
   {

       XQueryDigitizerConfiguration( EXdisplay, &dig);
       if( dig.DigitizerAttached )
       {
           digix = dig.DigitizerWidth;
           digiy = dig.DigitizerHeight;
       }
       else
       {
           return(OM_E_ERROR);
       }
       status = TRUE;
       if(fscanf(fp,"%d%c%d",&x_ext,&ch,&y_ext) != 3)
       {
          fclose(fp);
          return(OM_E_ERROR);
       }
       else
       {
           if ( x_ext > digix || y_ext > digiy
                || x_ext <= 0 || y_ext <= 0 )
           {
              ex$message(msgnumb = EX_F_WrongDigSize);
	      fclose(fp);
	      return(OM_E_ERROR);
           }
           else
	   {
	       ME.IGEdigwin->ext_x = x_ext;
	       ME.IGEdigwin->ext_y = y_ext;

               if( *addr_cmdptr != NULL )
	       {
	          ME.IGEdigwin->p_cmd = *addr_cmdptr;
	          ME.IGEdigwin->num_of_cmds = *cmdnum;
	       }
	       else
	       {
		   cmd_count = 0;
		   while ( fgets(s, BUFSIZE, fp) != NULL )
		   { 
		      if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
 			 continue;
		      ++cmd_count;
		   }
		   fclose(fp);
		   if( cmd_count )
		   {
		       if ( ! ( cmd = ( struct EX_paper_cmd *) 
			  malloc ( cmd_count * sizeof ( struct EX_paper_cmd ) ))) 
  		       {
			     printf("no memory for cmd\n");
		       }
		       else
		       {
			    if(! (fp = (FILE *) fopen( path, "r") ) )
			    {
				ex$message(msgnumb = EX_F_CanNotLMenu);
				return(OM_E_ERROR);
			    }
			    else
			    {
			       fscanf(fp,"%d%c%d",&x_ext,&ch,&y_ext);
			       line_num = 0;
                               i = 0;
			       while( fgets(s, BUFSIZE, fp) != NULL )
			       {
				   line_num++;
				   if((s[0] == '#') || (s[0] == ' ') || 
				      (s[0] == '\t') || (s[0] == '\n'))
         				      continue;
				   if((num_read = sscanf(s,"%d,%d,%d,%d,%d,%[^\n]\n",
				       &x1,&y1,&x2,&y2,&response,key_str )) >= 5 )  
				   {
                                       cmd1 = cmd + i;   
				       cmd1->x1 = (x1 < x2) ? x1 : x2;
				       cmd1->y1 = (y1 < y2) ? y1 : y2;
				       cmd1->x2 = (x1 < x2) ? x2 : x1;
				       cmd1->y2 = (y1 < y2) ? y2 : y1;
				       cmd1->resp = response;
				       if( num_read == 6 )
				       {
					  EX_cmdgetptr(key_str, &outstr);
					  cmd1->input_string = outstr;
				       }
				       else
				       {
					  cmd1->input_string = NULL;
				       }
				       i++;
				   }
				   else
				   {
				       printf("\nwrong entry in paper menu <%s>\n",path);
				       printf("possible error in entry %d, field %d\n",line_num,num_read+1);
				   }
			       }
  			       fclose(fp);   
			       ME.IGEdigwin->num_of_cmds = cmd_count;
			       ME.IGEdigwin->p_cmd = cmd;
			       *cmdnum = cmd_count;
			       *addr_cmdptr = cmd;
			    }
		       }
		   } /* there is cmd */
               }
	   } /* ext is correct */
       } /* file opened */
   }
   return(OM_S_SUCCESS);
}

#endif

end implementation IGEdigwin;
