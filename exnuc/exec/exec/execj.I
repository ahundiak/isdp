class implementation exec;
#include "exsysdep.h"

#ifdef SUNOS
#include <stdio.h>
#endif

extern int      Help_active();
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <limits.h>

extern Display *EXdisplay;
extern int      Help_active();

#endif
#ifdef ENV5
#include <tools.h>
#endif

#include <string.h>
#include <ctype.h>
#include <OMminimum.h>
#include <OMprimitives.h>
#include <OMerrordef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <exdef.h>
#include "wl.h"
#include "exwl.h"
#include "exproto.h"
#include <stdlib.h>

from module import GRmd_add_super,mod_info;
from OMObjSpace import get_status;
from IGEgadget import convert_pnt, activate;
#ifdef CLIX
from IGEabsdig import create;
#endif

extern struct EX_global EX_global_var;
extern struct module_params **module_data;
extern OM_S_OBJID EX_exec_id;
extern uword      EX_exec_osnum;
extern struct EX_visible_module *module_table;
extern struct EX_invisible_module *invisible_table;    
extern int EX_driver_exist;

#if defined( CLIX )
extern OM_S_OBJID absdig_id ;
#endif

extern int EX_help_proc_exist;
extern int EX_help_quiet;
extern int EX_disp_quiet;
extern char EX_seedfile[];
extern char EX_filename[];
extern char *EX_firstcmd;
extern int EX_create;
extern int timer_no;
extern int EX_batch_mode;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_findmod ( objid, osnum )
OM_S_OBJID *objid;
uword      *osnum;
{
   if(objid)  *objid = EX_active_module;
   if(osnum)  *osnum = EX_active_OS_num;

  return (1);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int EX_get_exec_id ( objid, osnum )
OM_S_OBJID *objid;
uword      *osnum;
{
   if(objid)  *objid = EX_exec_id;
   if(osnum)  *osnum = EX_exec_osnum;

  return (1);
}


/****************************************************/
/*                                                  */
/*       convert point                              */
/*                                                  */
/****************************************************/

struct conv_pnt
{
   int                  *ret;
   int                  *response;
   struct EX_button     *pnt1;   

};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_conv_pnt (window, pnt1, response)
int window;
struct EX_button *pnt1;
int *response;
{
   int              status = 1;
   int              ret;
   struct conv_pnt  cnv_pnt;
   OM_S_MESSAGE     msg_struct;
   OMuword          os;
   OM_S_OBJID       oid;
   WLuint32         lwin;


   cnv_pnt.ret = &ret;
   cnv_pnt.response = response;
   cnv_pnt.pnt1 = pnt1;

   status = om$make_message (  classname = "IGEgadget", 
                              methodname = "convert_pnt", 
                                    size = sizeof(struct conv_pnt), 
                               p_arglist = &cnv_pnt, 
                                   p_msg = &msg_struct);

   if (! (1 & status))
   {
      printf("Error in EX_conv_pnt \n");
      om$report_error(sts = status);
      goto wrapup;
   }

   status = EX_trans_win (window, &lwin, &os, &oid);
   if (status != WL_SUCCESS)
   {
      status = OM_E_ERROR;
      goto wrapup;
   }

   status = om$send (mode = OM_e_wrt_object,
                     msg = &msg_struct,
                     senderid = NULL_OBJID,
                     targetid = oid, 
                     targetos = os);
                  
   if(!(1&status))
   {
      return(OM_W_ABORT);
   }

wrapup:
   return (status);
}


int EX_get_win_class (hw_win_no, class_name)
int        hw_win_no;
char       *class_name;
{
   int         status;
   WLuint32    lwin;
   OMuword     os;
   OM_S_OBJID  oid;

 
   status = EX_trans_win (hw_win_no, &lwin, &os, &oid );
   if (status != WL_SUCCESS)
   {
      class_name[0] = '\0';
      return (OM_E_ERROR);
   }

   status = om$get_classname ( osnum      = os,
                               objid      = oid,
                               classname  = class_name );

   return (status);
}

/*============================================*/
/*  Translates HARDWARE window number into    */
/*      1)  logical window number             */
/*      2)  window OS number                  */
/*      3)  window OBJID                      */
/*  It will return WL status codes            */
/*============================================*/

#if defined (X11)
int EX_trans_win ( hw_win, lwin, win_os, win_oid )
unsigned int   hw_win;
#elif defined (ENV5)
int EX_trans_win ( hw_win, lwin, win_os, win_oid )
int            hw_win;
#endif
WLuint32      *lwin;
OMuword       *win_os;
OM_S_OBJID    *win_oid;
{
    int       status;
    EXwindata *win_data;

    status = WLget_logical_window ( hw_win, lwin );
    if (status != WL_SUCCESS) return (status);
    
    status = WLget_user_data ( *lwin, (void**)&win_data, NULL );
    if (status != WL_SUCCESS) return (status);

    /*=================================================================*/
    /*  make sure that we only process our graphic windows using this  */
    /*  function - we want to weed out others using WL for windowing   */
    /*=================================================================*/

    if (win_data && ((win_data->id == EX_GRAPHIC_WINDOW) ||
                     (win_data->id == EX_DIGITIZER_WINDOW)))
    {
       *win_oid = win_data->win_oid;
       *win_os  = win_data->win_os;
    }
    else
       return (WL_BAD_HARDWARE_WINDOW);

    return (status);
}

#argsused
int EX_add_win (int hw_win, OM_S_OBJID objid, OMuword osnum)
{
   int              status;
   OM_S_CHANSELECT  chandef1;
   OM_S_CHANSELECT  chandef2;

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "IGEwsys.exec";

   chandef2.type = OM_e_name;
   chandef2.u_sel.name = "exec.hw_win";

   status = om$send  (msg = message Root.connect(chandef2, NULL, 
                                        objid, osnum, 
                                        chandef1, OM_K_MAXINT ), 
                           senderid = objid, 
                           targetid = EX_exec_id, 
                           targetos = EX_exec_osnum);
   if (!(status & 1))
   {
      om$report_error(sts = status);
   }

   return (status);
}


int EX_del_win ( OM_S_OBJID objid, OMuword osnum )
{
   int             status;
   OM_S_CHANSELECT chandef1;
   OM_S_CHANSELECT chandef2;

   chandef2.type = OM_e_name;
   chandef2.u_sel.name = "exec.hw_win";

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "IGEwsys.exec";

   status = om$send  (msg = message Root.disconnect (chandef2, 
                                        objid, osnum, chandef1 ), 
                      senderid = objid, 
                      targetid = EX_exec_id, 
                      targetos = EX_exec_osnum);
   if (!(status & 1))
   {
      om$report_error(sts = status);
   }

   return (status);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#if defined ( CLIX )

int EX_set_abs_dig ( int fm )
{
      int status = 0;
      IGRlong msg;
      
      if( absdig_id == NULL_OBJID )
      {
          status = om$construct(classname = "IGEabsdig",
                            p_objid = &absdig_id,
                            osnum = 1,    
            msg = message IGEabsdig.create(fm));
           if (! (1&status) )
           {
              printf(" construct abs digitizer error\n");
              om$report_error(sts = status);
           }
    
           status = om$send(msg = message IGEgadget.activate(&msg,-1),
                            senderid = NULL_OBJID,
                       targetid = absdig_id,
                           targetos = 1);
           if(!(1&status))
           {
              printf("\n IGEabsdig activate error\n");
              om$report_error(sts = status);
              status = ex$clear_abs_dig();
           }
       }
       else
       {
           printf("Error IGEabsdig already defined\n");
       }
   return (status);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_clear_abs_dig( )

{
      int status = 0;

   if(absdig_id != NULL_OBJID)
   {   
      status = om$send(msg = message IGEabsdig.delete(0),
                     senderid = NULL_OBJID,
                     targetid = absdig_id,
                     targetos = 1);
      if(!(1&status))
      {
          printf("\n can not delete IGEabsdig\n");
      }
      else
      {
          absdig_id = NULL_OBJID;
      }
   }
   else
   {
           printf("Error IGEabsdig not defined\n");
   }
   return (status);
}

#endif

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  EX_wait_for_input */

int EX_wait_for_input (
  int *response,
  char *response_data,
  int mode,
  int *num_bytes)
{
  int status;
 
   status = om$send( mode = OM_e_wrt_object,
                        msg = message exec.wait_for_input(response,
                                 response_data,mode,num_bytes),
                        senderid = EX_exec_id,
                        targetid = EX_exec_id,
                        targetos = EX_exec_osnum     ) ;
/*    ex$message(msgnumb = EX_S_Clear);	  */
/*    this clear is messing up some commands pam may 18*/

    return( status   );
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
int EX_attach_kbd( objid, osnum )
OM_S_OBJID objid;
OMuword    osnum;
{

      int status = 0;

      OM_S_CHANSELECT chandef1;
      OM_S_CHANSELECT chandef2;

        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "IGEkbdproc.to_exec";

        chandef2.type = OM_e_name;
        chandef2.u_sel.name = "exec.to_kbd_processor";

        status = om$send  (msg = message Root.connect(chandef2, 0, 
                                 objid, osnum,  chandef1, 0 ), 
                           senderid = objid, 
                           targetid = EX_exec_id, 
                           targetos = EX_exec_osnum);

        if (!(status & 1))
        {
            om$report_error(sts = status);
            printf("IN EX_attach_kbd send connect error\n");
        }

   return (status);

}
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
int EX_detach_kbd( objid, osnum )
OM_S_OBJID objid;
OMuword    osnum;
{
   int status;
   OM_S_CHANSELECT chandef1;
   OM_S_CHANSELECT chandef2;

    chandef1.type = OM_e_name;
    chandef1.u_sel.name = "exec.to_kbd_processor";
    chandef2.type = OM_e_name;
    chandef2.u_sel.name = "to_exec";
 
        status = om$send( mode = OM_e_wrt_object,
                      msg = message Root.disconnect( chandef2, EX_exec_id,
                            EX_exec_osnum, chandef1),
                           senderid = EX_exec_id,
                           targetid = objid,
                           targetos = osnum);
        if( ! (1&status))
        {
            om$report_error(sts = status);
            printf("In deatch kbd send disconnect error\n");
        }
    return (status);
}
*/




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_attach_listener( 
OM_S_OBJID objid,
OMuword    osnum)
{

      int status = 0;

      OM_S_CHANSELECT chandef1;
      OM_S_CHANSELECT chandef2;

        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "IGEinlisnr.to_exec";

        chandef2.type = OM_e_name;
        chandef2.u_sel.name = "exec.to_listener";

        status = om$send  (msg = message Root.connect(chandef2, 0, 
                                 objid, osnum,  chandef1, 0 ), 
                           senderid = EX_exec_id,
                           targetid = EX_exec_id, 
                           targetos = EX_exec_osnum);

        if (!(status & 1))
        {
            om$report_error(sts = status);
            printf("IN EX_attach_listener send connect error\n");
        }
        else
        {
           ;
/*         printf("IN EX_attach_listener status = %d\n",status);  */
        }
   return (status);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_detach_listener( 
OM_S_OBJID objid,
OMuword    osnum)
{
   int status;
   OM_S_CHANSELECT chandef1;
   OM_S_CHANSELECT chandef2;

    chandef1.type = OM_e_name;
    chandef1.u_sel.name = "exec.to_listener";
    chandef2.type = OM_e_name;
    chandef2.u_sel.name = "IGEinlisnr.to_exec";
 
        status = om$send( mode = OM_e_wrt_object,
                      msg = message Root.disconnect( chandef2, EX_exec_id,
                            EX_exec_osnum, chandef1),
                           senderid = EX_exec_id,
                           targetid = objid,
                           targetos = osnum);
        if( ! (1&status))
        {
            om$report_error(sts = status);
            printf("In deatch listener send disconnect error\n");
        }
        else
        {
             ;
/*            printf("IN EX_deatch_listener status = %d\n",status); */
        }
    return (status);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_attach_generator( 
OM_S_OBJID objid,
OMuword    osnum)
{

      int status = 0;

      OM_S_CHANSELECT chandef1;
      OM_S_CHANSELECT chandef2;

        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "IGEingen.to_exec";

        chandef2.type = OM_e_name;
        chandef2.u_sel.name = "exec.to_generator";

        status = om$send  (msg = message Root.connect(chandef2, NULL, 
                                 objid, osnum,  chandef1, NULL ), 
                           senderid = objid, 
                           targetid = EX_exec_id, 
                           targetos = EX_exec_osnum);

        if (!(status & 1))
        {
            om$report_error(sts = status);
            printf("IN EX_attach_generator send connect error\n");
        }

   return (status);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_detach_generator( 
OM_S_OBJID objid,
OMuword    osnum)
{
   int status;
   OM_S_CHANSELECT chandef1;
   OM_S_CHANSELECT chandef2;

    chandef1.type = OM_e_name;
    chandef1.u_sel.name = "exec.to_generator";
    chandef2.type = OM_e_name;
    chandef2.u_sel.name = "IGEingen.to_exec";
 
        status = om$send( mode = OM_e_wrt_object,
                      msg = message Root.disconnect( chandef2, EX_exec_id,
                            EX_exec_osnum, chandef1),
                           senderid = EX_exec_id,
                           targetid = objid,
                           targetos = osnum);
        if( ! (1&status))
        {
            om$report_error(sts = status);
            printf("In deatch generator send disconnect error\n");
        }
    return (status);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* note:                                              */
/*     OM requires that the name of NOD be unique in  */
/*     the object space, and the name of NOD should   */
/*     be put in itself.                              */
/*                                                    */
/*     If you use this macro the create new NOD, it   */
/*     will put the name of the NOD in the NOD.       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#argsused
int EX_get_NOD( 
char *NODname,
OM_S_OBJID *pobjid,
int create,
OM_S_OBJID modid,
OMuword    mosnum)
{
    OMuword         mod_osnum;
    int status;     
    char pathn[DI_PATH_MAX];

    mod_osnum = mosnum;
    status = OM_S_SUCCESS;
    status = di$give_pathname(osnum = mod_osnum, pathname= pathn);
    if  (! (1&status) ) 
    {
       printf("in EX_get_NOD get di path error osnum =<%d>\n",mod_osnum);
       di$report_error(sts = status);
/*       return(OM_E_ERROR); */
       return(status);
    }

    *pobjid = NULL_OBJID;    

    DIstrcat(pathn,NODname);
    status = di$translate( objname=pathn , p_objid=pobjid);

    if(status == DIR_W_NAME_NOT_FOUND ) 
    {
       if( create == 0)
       {
/*        printf("can not find NOD, and do not want to create new\n"); */
             status = OM_E_ERROR;       /*generic error */
       }
       else /* create new NOD */
       {
          status = di$mkdir( dirname=pathn,p_dirid = pobjid );
          if (!(1&status))
          {
	     printf("EX_get_NOD di$mkdir pathn=<%s>\n",pathn);
             di$report_error(sts = status, comment="Error send di$mkdir");
             /* status = OM_E_ERROR; */
          }
       }
    }
    return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#argsused
int EX_get_oid_nodname( 
char *NODname,
char *objname,
OM_S_OBJID *pobjid,
OM_S_OBJID modid,
OMuword    mosnum,
int        errprint)
{
    OMuword         mod_osnum;
    int status;     
    char pathn[DI_PATH_MAX];   

    mod_osnum = mosnum;

    status = di$give_pathname(osnum = mod_osnum, pathname= pathn);
    if (! (1&status) )
    {
       printf("in EX_get_oid_nodname get di path error osnum =<%d>\n",mod_osnum);
       di$report_error(sts = status);
       /* return(OM_E_ERROR);*/
       return(status);
    }

    *pobjid = NULL_OBJID;
    DIstrcat(pathn,NODname);    
    DIstrcat(pathn,objname);
    status = di$translate(objname = pathn , p_objid=pobjid);
    if (! (1&status) )
    {
      if( errprint == 2 )
      {
        printf("in EX_get_oid_nodname di$translate error objname =<%s> in <%s>\n",objname,pathn);
        di$report_error(sts = status);
      }
      /*  return(OM_E_ERROR); */
    }

    return ( status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_add_name_nodname(
char *NODname,
char *objname,
OM_S_OBJID objid,
OMuword    mosnum)
{
    OMuword         mod_osnum;
    int status;     
    char pathn[DI_PATH_MAX];

    mod_osnum = mosnum;
   
    status = di$give_pathname(osnum = mod_osnum, pathname= pathn);
    if (! (1&status) )
    {
       printf("in EX_add_name_nodname get di path error osnum =<%d>\n",mod_osnum);
       di$report_error(sts = status);
       /* return(OM_E_ABORT); */
       return(status);
    }

    DIstrcat(pathn,NODname);    
    DIstrcat(pathn,objname);
    status = di$add_name(objname = pathn , objid= objid);
    if (! (1&status) )
    {
       printf("in EX_add_name_nodname get di$add_name error pathn =<%s>\n",pathn);
       di$report_error(sts = status);
    }

    return (status);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_remove_name_nodname(
char *NODname,
char *objname,
OMuword    mosnum)
{
    OMuword         mod_osnum;
    int status;     
    char pathn[DI_PATH_MAX];

    mod_osnum = mosnum;
   
    status = di$give_pathname(osnum = mod_osnum, pathname= pathn);
    if (! (1&status) )
    {
       printf("in EX_remove_name_nodname get di path error osnum =<%d>\n",mod_osnum);
       di$report_error(sts = status);
       /* return(OM_E_ERROR); */
       return(status);
    }

    DIstrcat(pathn,NODname);    
    DIstrcat(pathn,objname);
    status = di$rm_name( regexp = pathn );
    if (! (1&status) )
    {
       printf("in EX_remove_name_nodname di$rm_name error pathn =<%s>\n",pathn);
       di$report_error(sts = status);
       /* return(OM_E_ERROR); */
    }

    return (status);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#argsused
int EX_get_oid_nodid(
OM_S_OBJID NODobjid,
char  *objname,
OM_S_OBJID *pobjid,
OM_S_OBJID modid,
OMuword    mosnum)
{
    int status;     
    OMuword    mod_osnum;    
    char   NODname[DI_PATH_MAX]; /* defined in DIdef.h */

    mod_osnum = mosnum;

    status = di$untranslate( objname= NODname, objid = NODobjid, osnum=mod_osnum);
    if( ! (1&status) )
    {
       printf("in EX_get_oid_nodid get NOD name error osnum =<%d> id=<%d>\n",mod_osnum,NODobjid);
       di$report_error(sts = status);
       /*return(OM_E_ERROR); */
       return(status);       
    }
    DIstrcat(NODname,objname);
    status = di$translate(objname = NODname , p_objid=pobjid);
    
    return (status);

}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_add_name_nodid(
OM_S_OBJID NODobjid,
char  *objname,
OM_S_OBJID objid,
OMuword    mosnum)
{
    int status;     
    OMuword    mod_osnum;    
    char   NODname[DI_PATH_MAX]; /* defined in DIdef.h */

    mod_osnum = mosnum;

    status = di$untranslate( objname= NODname, objid = NODobjid, osnum=mod_osnum);
    if( ! (1&status) )
    {
       printf("in EX_add_name_nodid get NOD name error osnum =<%d> id=<%d>\n",mod_osnum,NODobjid);
       di$report_error(sts = status);
       /* return(OM_E_ABORT); */
       return(status);
    }

    DIstrcat(NODname,objname);
    status = di$add_name(objname = NODname , objid= objid);
    if (! (1&status) )
    {
       printf("in EX_add_name_nodid get di$add_name error pathn =<%s>\n",NODname);
       di$report_error(sts = status);
      /*  return(OM_E_ABORT);*/
    }

    return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_remove_name_nodid( 
OM_S_OBJID NODobjid,
char  *objname,
OMuword    mosnum)
{
    int status;
    OMuword    mod_osnum;    
    char   NODname[DI_PATH_MAX]; /* defined in DIdef.h */

    mod_osnum = mosnum;

    status = di$untranslate( objname= NODname, objid = NODobjid, osnum=mod_osnum);
    if( ! (1&status) )
    {
       printf("in EX_remove_name_nodid get NOD name error osnum =<%d> id=<%d>\n",mod_osnum,NODobjid);
       di$report_error(sts = status);
       /*return(OM_E_ABORT);*/
       return(status);
    }
    DIstrcat(NODname,objname);
    status = di$rm_name( regexp = NODname );
    if (! (1&status) )
    {
       printf("in EX_remove_name_nodid di$rm_name error pathn =<%s>\n",NODname);
       di$report_error(sts = status);
      /* return(OM_E_ERROR);*/
    }

    return (status);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_attach_super ( 
IGRchar *super_class,
OM_S_OBJID *super_id,
OM_S_OBJID module_id,
OMuword module_os,
int wakeup_flag)
{
    return ( om$send (msg = message module.GRmd_add_super (super_class,
                                                   super_id,wakeup_flag),
                      senderid = module_id,
                      targetid = module_id,
                      targetos = module_os));
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_get_global (
IGRint  mode,
struct EX_var_list *var,
IGRint *which_error)
{
    *which_error = 0;
    if (mode == EX_INQ)
    {
        EX_inq_global (var, which_error);
    }
    else
    {
        EX_set_global (var, which_error);
    }
    if (*which_error)
    {
        return (0);
    }
    else
    {
        return (1);
    }
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_inq_global (
struct EX_var_list *var,
IGRint  *which_error)
{
    struct EX_var_list *temp;
   
    temp = var;
    while (temp->var != EX_END_PARAM)
    {
        switch (temp->var)
        {
        case EX_CUR_FILENAME:
                if ( *(temp->num_bytes) >= (int)strlen (EX_global_var.filename))
                {
                    strcpy (temp->var_value, EX_global_var.filename);
                    *(temp->num_bytes) =  strlen (EX_global_var.filename);
                }
                else
                {
                    *which_error = EX_CUR_FILENAME;
                    *(temp->num_bytes) =  0;
                }
                break;

        case EX_WORKING_DIR:
                if (*(temp->num_bytes) >= (int)strlen (EX_global_var.working_dir))
                {
                    strcpy (temp->var_value, EX_global_var.working_dir);
                    *(temp->num_bytes) =  strlen (EX_global_var.working_dir);
                }
                else
                {
                    *which_error = EX_WORKING_DIR;
                    *(temp->num_bytes) =  0;
                }
                break;

        case EX_SUPPORT_DIR:
                if (*(temp->num_bytes) >= strlen (EX_global_var.support_dir))
                {
                    strcpy (temp->var_value, EX_global_var.support_dir);
                    *(temp->num_bytes) =  strlen (EX_global_var.support_dir);
                }
                else
                {
                    *which_error = EX_SUPPORT_DIR;
                    *(temp->num_bytes) =  0;
                }
                break;

        default:
                *which_error = temp->var;
                break;

        }
    temp++;
    }
    return(1);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_set_global (
struct EX_var_list *var,
IGRint *which_error)
{
    struct EX_var_list *temp;
   
    temp = var;
    while (temp->var != EX_END_PARAM)
    {
        switch (temp->var)
        {
        case EX_CUR_FILENAME:
                strcpy (EX_global_var.filename, temp->var_value);
                break;

        case EX_WORKING_DIR:
                strcpy (EX_global_var.working_dir, temp->var_value);
                break;

        case EX_SUPPORT_DIR:
                strcpy (EX_global_var.support_dir, temp->var_value);
                break;

        default:
                *which_error = temp->var;
                break;
        }
    temp++;
    }
    return(1);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#argsused
int EX_file_status (
OM_S_OBJID modid,
uword      modos,
int       *mode)
{
    
    IGRlong OMmsg, status;
    OM_S_OSSTATUS status_info;
    OM_S_OBJID  target;

    uword  mod_osnum;


    mod_osnum = modos;
    status = om$osnum_to_oso_objid(osnum=mod_osnum, p_objid= &target);
    if(! (1&status) )
    {
       printf("IN EX_file_status osnum to oso objid error\n");
       printf("osnum = %d \n",mod_osnum);
       om$report_error(sts = status );
       return(0);
    }

    status_info.stattype = OM_OS_STATUS_MISC;

    OMmsg = om$send (msg = message OMObjSpace.get_status (&status_info),
                     senderid = NULL_OBJID,
                     targetid = target,
                     targetos = modos);
    if (! (1 & OMmsg))
    {
       printf("IN EX_file_status get_status error\n");
        om$report_error (sts = OMmsg);
        return (0);
    }
    if (!(status_info.stat.misc.OSflags & OM_OSD_nowrite))
    {
        *mode = EX_WRITE_FILE;
    }
    else
    {
        *mode = EX_NOWRITE_FILE;
    }
    return(1);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int EX_get_invis_info_by_index(
int index,
OMuword  *mod_osnum,
OM_S_OBJID *mod_id,
OM_S_OBJID *filed_id,
int        *flag,
int        *num_open,
int        *mod_type)
{
    if( (index >= EX_MAX_INVIS_MODULES) || (index < 0))
    {
        if ( ! IGEsractive() )
           printf("IN EX_get_invis_info wrong index %d\n",index);
	return(0);
    }
    else if (invisible_table[index].obj_space_num == 0)
    {
        if ( ! IGEsractive() )
           printf("IN EX_get_invis_info wrong index %d (obj_space_num=0)\n",index);
	return(0);
    }
    else
    {
        if(mod_osnum) *mod_osnum = invisible_table[index].obj_space_num;
        if(mod_id)    *mod_id    = invisible_table[index].module_my_id;	
	if(filed_id)  *filed_id  = invisible_table[index].filed_id;
	if(flag)          *flag  = invisible_table[index].permis_flag;
	if(num_open)  *num_open  = invisible_table[index].numof_opens;
        if(mod_type)  *mod_type  = -1;


        return(1);    
    }

}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  given module name check whether it is in visible table or not    */
 
int EX_is_visible( 
char *mod_name)
{
   int i, ret;
   ret = 0;
   for ( i = 0; i< EX_MAX_MODULES ; i++)
   {
       if(  ( module_table[i].obj_space_num != 0) &&
            !strcmp(module_data[module_table[i].obj_space_num]->CS_OS_name, 
             mod_name)   )   /* same name */
       {
          ret = 1;  
	  break;
       }
   }
   return(ret);    
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int EX_is_invis( 
OMuword mod_osnum,
int *index)
{
   int i, ret;
   ret = 0;
   for ( i = 0; i< EX_MAX_INVIS_MODULES; i++)
   {
       if ( ( invisible_table[i].obj_space_num != 0) &&
            ( invisible_table[i].obj_space_num == mod_osnum) )
       { 
          ret = 1;  
	  if( index ) *index = i;
	  break;
       }
   }

   return(ret);    
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* given mod os num, check whether another os has the same type */
/*
int EX_check_mod_type(
OMuword mod_osnum)
{
   int i, ret, current_type;
   ret = 0;

   for ( i = 0; i< EX_MAX_MODULES; i++)
   {
       if ( ( module_table[i].obj_space_num != 0) &&
            ( module_table[i].obj_space_num != mod_osnum) )
       { 
           if( module_data[mod_osnum]->module_type ==
	       module_data[module_table[i].obj_space_num]->module_type )
           {
               ret = 1;  
               break;
           }
       }
   }

   return(ret);    

}
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int EX_is_driver_exist()
{
    return( EX_driver_exist);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void EX_set_mod_no_scn_menu(
OMuword mod_osnum)
{
   int i;

   for ( i = 0; i< EX_MAX_MODULES; i++)
   {
       if ( module_table[i].obj_space_num == mod_osnum) 
       { 
            module_table[i].no_scn_menu = 1; 
       }
    }

}

int EX_is_scn_menu_present()
{
   return(module_table[active_module_num].no_scn_menu ? 0 : 1);
}

void EX_print_module_table()
{
   int i;

   for ( i = 0; i< EX_MAX_MODULES; i++)
   {
      printf("module_table[%d].obj_space_num = <%d>\n",i,module_table[i].obj_space_num); 
      printf("module_table[%d].module_my_id  = <%d>\n",i,module_table[i].module_my_id); 
      printf("module_table[%d].filed_id      = <%d>\n",i,module_table[i].filed_id); 
      printf("module_table[%d].permis_flag   = <%d>\n",i,module_table[i].permis_flag);
      printf("module_table[%di].no_scn_menu  = <%d>\n\n",i,module_table[i].no_scn_menu); 
   }
}




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* given mod os num, return module objid   */
/*  for both visible and invisible modules */

int EX_get_modid_given_osnum(
OMuword mod_osnum,
OM_S_OBJID *mod_id)
{
   int i, ret;
   ret = 0;

   for ( i = 0; i< EX_MAX_MODULES; i++)
   {
       if ( module_table[i].obj_space_num == mod_osnum ) 
       { 
           *mod_id = module_table[i].module_my_id;
           ret = 1;  
           break;
       }
   }
   if ( ret == 0 )
   {
       for ( i = 0; i< EX_MAX_INVIS_MODULES; i++)
       {
	   if ( invisible_table[i].obj_space_num == mod_osnum ) 
	   { 
	       *mod_id = invisible_table[i].module_my_id;
	       ret = 1;  
	       break;
	   }
       }
   }

   return(ret);    
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  find the search path                                        */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  find the super                                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int EX_get_super( 
OM_S_OBJID	mod_id,
OMuword		mod_osnum,   
char		*super_name,	/* name for your super		*/
int		create,   
char		*super_classname, /* classname for your super	*/
OM_S_OBJID 	*super_id,	/* objid, osnum for your super	*/
OMuword         *super_osnum,
int             wakeup_flag)
{
    IGRlong	OMmsg;

    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
				/* Get super from Named Object
				   directory			*/

/*    if( !(strcmp(super_classname, "GRadp") ) )return(0);  */



    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD", objname = super_name,
				  pobjid = super_id,  modid = mod_id,
		 		  mod_osnum = mod_osnum, dummy=1);
    if (! (1 & OMmsg ))   /* Named Object not yet created	*/
    {				/* reset OMmsg			*/
	OMmsg = OM_S_SUCCESS;
		 		/* construct super		*/
       if( create )
       {

	    OMmsg = ex$attach_super(super_class = super_classname,
			    super_id = super_id,
			    modid = mod_id,
			    mod_osnum = mod_osnum,
                            wakeup_flag = wakeup_flag);

	    if (1 & OMmsg)
	    {
                OMmsg = EX_add_name_nodname( "IGENOD", super_name, *super_id , mod_osnum);
   	    }


        }
    }
				/* space number same as module	*/
    if(super_osnum) *super_osnum = mod_osnum;

    

    return( OMmsg );
}


int EX_mod_info(  
OMuword mod_osnum,
int mode,
char *app,
int applen)
{
   int status;
   OM_S_OBJID	mid;

     status = ex$get_modid( mod_osnum=mod_osnum, mod_id= &mid );
     if( ! (1& status) )
     {
         printf("EX_mod_info get_modid error osnum=%d\n",mod_osnum);
     }
     else
     {
        status = om$send (msg = message module.mod_info(mode, NULL, 0, 
                                                   app,applen),
                      senderid = mid,
                      targetid = mid,
                      targetos = mod_osnum );
	if( !(1&status) ) om$report_error(sts = status);
	
     }
     return( (1&status)? 1 : 0 );
}

int EX_is_help_active()
{
    int flag, ret, status;
    flag = 0;
    ret = 0;
    if ( EX_help_proc_exist == 1 )
    {
      status = Help_active( &flag );  
      if( (flag == 1) && (EX_help_quiet == 0 ) ) ret = 1;
    }
    return(ret);
}


int EX_help_flag( 
    int mode,
    int *flag)
{    
    if ( mode == EX_SET ) EX_help_quiet = *flag;
    if ( mode == EX_INQ ) *flag = EX_help_quiet ;    
    return(1);
}

int EX_help_on( 
    int *oldflag)
{    
    *oldflag = EX_help_quiet ;    
    EX_help_quiet = 0;
    return(1);
}

int EX_help_off(
    int *oldflag)
{    
    *oldflag = EX_help_quiet ;    
    EX_help_quiet = 1;
    return(1);
}


int EX_disp_flag( 
    int mode,
    int *flag)
{    
    if ( mode == EX_SET ) EX_disp_quiet = *flag;
    if ( mode == EX_INQ ) *flag = EX_disp_quiet ;    
    return(1);
}

int EX_disp_on( 
    int *oldflag)
{    
    *oldflag = EX_disp_quiet ;    
    EX_disp_quiet = 0;
    return(1);
}

int EX_disp_off( 
    int *oldflag)
{    
    *oldflag = EX_disp_quiet ;    
    EX_disp_quiet = 1;
    return(1);
}


int EX_is_file_open( 
char *filename)
{
   char string[200];
   OMuword os_num;
   int status, ret; 

   strcpy(string, filename);
   module_build_path( string );
   status = om$os_name_to_number(osname = string, p_osnum = &os_num);
   ret = ( 1&status ) ? 1 : 0;
   return(  ret );
}

 int EX_get_file_path( 
char *env,char *string,char *outfile,
int *ftype, int size)
{
  register int i,j;
  int  len, return_val = 1;
  char path_name[256];
  char *envp;

     envp = (char *)getenv(env);     
     if(envp && envp[0] != '\0')
     {
        len = strlen(envp);
        j = ( envp[0] == ':' ) ? 1  : 0;
        while( j < len )
        {
           for( i = 0; j < len; j++,i++)
           {
              if(envp[j] == ':')
              {
                 j++;
                 break;
              }
              path_name[i] = envp[j];
              path_name[i+1] = '\0';
           } 
           strcat(path_name,"/");
           strcat(path_name,string);

           return_val = EX_check_stat(path_name,ftype);
           if(return_val == 1)
	   {
               if( size > (int)strlen(path_name)  )
	       {
                   strcpy(outfile, path_name);
	       }
	       else
	       {
	           return_val = -1;
	       }
               break;
	   }
        } /* while */
     }
     return( return_val); 

 }


#if defined(ENV5)

#define INPUT_EVENTS   (KEYBOARD_EVENT | BUTTON_EVENT | KEYIN_EVENT | \
			MENUBAR_EVENT | PTTY_EVENT | AUX_EVENT | \
			PROCESS_EVENT | REFRESH_EVENT | DELETE_EVENT | \
			COVER_EVENT | COLLAPSE_EVENT | WINDOW_USER_ICON_EVENT | \
			USER_EVENT )

#define	input_avail	(Inq_events(&event_flags),(event_flags & INPUT_EVENTS))

  /* continue until a non-window icon event happens  */

EX_check_input()
{
   int event_flags, resp;

	while (  (!input_avail) &&  !( ex$peek_event_queue(resp = &resp) ) )
	{

 	   event_flags = 0;
           Wait_for_next(INPUT_EVENTS,&event_flags);

	}  /* end of while input avail  */
        return(1);
}  /* end of program  */
#elif defined(X11)
EX_check_input()
{

  XEvent report;
  int resp;
  if (!( ex$peek_event_queue(resp = &resp)))
  {
   /*if there is nothing on the software queue wait*/

  JNL_XMaskEvent(EXdisplay,
             ButtonPressMask | KeyPressMask,
             &report);
  JNL_XPutBackEvent(EXdisplay, &report);
  } 
        return(1);
}  /* end of program  */
#else
#error Windowing system switches must be set!s
#endif

int EX_set_up_file( 
char *filename,
char *seedfile,
char *firstcmd,
int *create)
{
    if ( seedfile != NULL ) strcpy(EX_seedfile,seedfile);
    if ( filename != NULL ) strcpy(EX_filename,filename);
    if ( firstcmd != NULL ) EX_cmdgetptr(firstcmd,&EX_firstcmd);
    if ( create   != NULL ) EX_create = *create;
    return(1);
}
int EX_get_file_default( 
char *filename,
char *seedfile,
char *firstcmd,
int *create)
{
    if ( seedfile != NULL ) strcpy(seedfile,EX_seedfile);
    if ( filename != NULL ) strcpy(filename,EX_filename);
    if ( create   != NULL ) *create = EX_create;
    if ( ( firstcmd != NULL ) & ( EX_firstcmd != NULL )  )
              strcpy( firstcmd, EX_firstcmd);
    return(1);
}

#define MY_CHECK  0
#define MY_KEY    1
#define MY_STRING 2

int EX_call_firstcmd()
{
   int finished, len, put, found, type, first; 
   char *tmp, *tmpstart, *tmpend;
   char *strend;
   
   char field[80];  
   char aa;   
   if( EX_firstcmd != NULL ) 
   {
       tmp = EX_firstcmd;
       strend = EX_firstcmd + strlen(EX_firstcmd);
       finished = 0; 

       first = 1;
       /* get cmd */
       while( !finished )
       {
          put = 0;
          type = MY_CHECK;
          while( *tmp == ' ') tmp++;  /* remove leading blanks */
          if( *(tmp) == '"' )
	  {
             tmpstart = ++tmp;
	     tmpend = strchr( tmpstart, '"');
             if( tmpend == NULL )
	     {
	       printf( "1 mismatch double quote <%s> \n", tmpstart);
	       finished = 1;
	     }
	     else
	     {
               type = MY_STRING;
	       len = tmpend - tmpstart;
	       strncpy(field,tmpstart, len);
	       field[len] = '\0';
               tmp = ++tmpend;
               while( *tmp == ' ') tmp++;
               if (tmp >= strend ) finished = 1;
               put = 1; 
             }
	  }
          else
	  {
             while( *tmp == ' ') tmp++;
	     tmpstart = tmp;
	     tmpend = strchr(tmpstart , ' ');
             found = 1;
	     if( tmpend == NULL )
	     {
	        tmpend = tmpstart + strlen(tmpstart);
                finished = 1;
	     }
             else
	     {
                if (tmpstart == tmpend )
		{
		   found = 0;
		   finished = 1;
		}
	     }
	     if ( found  )
	     {
		len = tmpend - tmpstart;
		strncpy(field,tmpstart, len);
		field[len] = '\0';
		tmp = ++tmpend;
                if ( *tmp == '\0') finished = 1;
		put = 1; 
             }
	  }
	  if ( put == 1 )
	  {
             if ( first )
	     {
	        first = 0;
		if (type != MY_STRING)
		{
		   if( strchr( field ,'=' ) != NULL )
		   {
		      type = MY_STRING;
		   }
		   else
		   {
                      type = MY_KEY;
		   }
                }
	     }
	     else
	     {
                aa = field[0];
	        if( ! isupper(aa) ) type = MY_STRING;
	     }
             EX_firstcmd_putque( field , type);
	  }
          EX_firstcmd = NULL;
       }
 }
 return(1);
}

int EX_firstcmd_putque( 
char *field,
int type)
{
   long num_byte;
   int  status;
   int resp;
   long msg;

    if ( type == MY_KEY )   resp = EX_CMD_KEY ;
    if ( type == MY_STRING )   resp = EX_STRING ;  
    if ( type == MY_CHECK )
    {
        if ( ! strcmp( "RESET", field) )               resp = RESET;
     else if ( ! strcmp( "EX_RJT_MOVEON", field) )     resp = EX_RJT_MOVEON;
     else if ( ! strcmp( "TERMINATE", field) )         resp = TERMINATE;
     else if ( ! strcmp( "STATUS_DISP", field) )       resp = STATUS_DISP;
     else if ( ! strcmp( "CLEAR_STACK", field) )       resp = CLEAR_STACK;
     else if ( ! strcmp( "D_COMMAND", field) )         resp = D_COMMAND;
     else if ( ! strcmp( "EX_BACK_UP", field) )        resp = EX_BACK_UP;
     else if ( ! strcmp( "D_RESET", field) )           resp = D_RESET;
     else if ( ! strcmp( "MOVE_ON", field) )           resp = MOVE_ON;
     else if ( ! strcmp( "FORM_FINISHED", field) )     resp = FORM_FINISHED;
     else if ( ! strcmp( "EX_FORM_FINISHED", field) )  resp = EX_FORM_FINISHED;
     else if ( ! strcmp( "EX_RESTART", field) )        resp = EX_RESTART;
     else resp = EX_STRING;
    }
			
    num_byte = strlen(field) + 1;

    status = ex$putque( msg = &msg,  response=&resp , pos =BACK,
			byte=&num_byte,  buffer=field );        
    if( ! (1&status))
    {
	printf("IN EX_call_firstcmd can not putq  %s\n", field);
        return(0);
    }
    return(1);     
}  


int EX_build_classlist ( 
char           *classnames[],
int             size,
OM_p_CLASSLIST  p_clist)
{
   int i, sts;

   for (i=0; i<size; ++i) {
      sts = om$get_classid ( classname = classnames[i],
                             p_classid = &p_clist->p_classes[i] );
      if (!(1&sts)) return (sts);
   }
   p_clist->w_count = size;
   return (OM_S_SUCCESS);
}


int EX_get_working_dir ( 
char *name,
int  *len)
{
   int    which;
   struct EX_var_list  exvar[2];
 
   exvar[0].var = EX_WORKING_DIR;
   exvar[0].var_value = name;
   exvar[0].num_bytes = len;
   exvar[1].var = 0;

   return (ex$global(mode        = EX_INQ, 
                     var         = exvar,
                     which_error = &which));      
}


int EX_get_support_dir ( 
char *name,
int  *len)
{
   int    which;
   struct EX_var_list  exvar[2];
 
   exvar[0].var = EX_SUPPORT_DIR;
   exvar[0].var_value = name;
   exvar[0].num_bytes = len;
   exvar[1].var = 0;

   return (ex$global(mode        = EX_INQ, 
                     var         = exvar,
                     which_error = &which));      
}


end implementation exec;

