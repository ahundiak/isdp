#ifndef NT
#include <sys/param.h>
#endif

#include <exsysdep.h> 
#include "OMobjectcomm.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

#ifndef NT
#include "exmacros.h"
#endif

#if defined (CLIX) || defined (SUNOS) || defined (IRIX)
#include "dload.h"
#else
#warning Dload is not supported on this OS !!
#endif

extern OM_p_FUNCPTR OM_GA_class_definitions[];

extern int DIadd_name(), DItranslate(), DIrename();
extern int EX_read_product_data();

#if defined (SUNOS54) || defined (SUNOS55)
#include <ieeefp.h>
#elif defined (SUNOS)
#include <sys/ieeefp.h>
#elif defined (IRIX)
#include <sys/fpu.h>
#elif defined (CLIX)
extern double OMfloatcvt();
#else
#warning Floating point conversion is not support on this OS !!
#endif

#define _errchk(str) if(!(1&sts)){printf("*** error in %s\n",str);\
                                  om$report_error(sts=sts);\
                                  printf("Exit? : ");\
                                  scanf("%s",err_ans);\
                                  if (err_ans[0] == 'y') exit(1);\
                                  else return(sts);}

#define _di_errchk(str) if(!(1&sts)){printf("*** DI error in %s\n",str);\
                                     di$report_error(sts=sts);\
                                     printf("Exit? : ");\
                                     scanf("%s",err_ans);\
                                     if (err_ans[0] == 'y') exit(1);\
                                     else return(sts);}

#define MAX_OS      20

/*===========*/
/*  GLOBALS  */
/*===========*/

int          num_os;
int          verbose=0;
char         err_ans[8];
OMuword      os_num[MAX_OS];
OM_S_OBJID   os_oid[MAX_OS];

/*===============*/
/*  Main Driver  */
/*===============*/

main(argc,argv)
int   argc;
char *argv[];
{
   int sts;
   int choice;

   sts = om$runtime_init();
   _errchk("runtime_init");

   for (sts=0; sts<MAX_OS; ++sts) {
      os_num[sts]  = 0;
   }

   num_os = 2;

   while (1) {
      printf("\n");
      printf(" 1) Construct an Object Space\n");
      printf(" 2) Delete an Object Space\n");
      printf(" 3) Write an Object Space\n");
      printf(" 4) Construct an object\n");
      printf(" 5) Delete an object\n");
      printf(" 6) Connect two objects\n");
      printf(" 7) Disconenct operation\n");
      printf(" 8) Send operation\n");
      printf(" 9) Issue an OS msg\n");
      printf("10) Issue a channel operation\n");
      printf("11) Copy chan or move chan\n");
      printf("12) Tag operations\n");
      printf("13) IGRdir operations\n");
      printf("14) Do Set Operation\n");
      printf("15) Dynamic class or change class\n");
      printf("16) PMS\n");
      printf("17) Dynamic load\n");
      printf("18) Memory allocation\n");
      printf("19) Set driver state\n");
      printf("20) Set or disable intercepts\n");
      printf("21) Dictionary operations\n");
      printf("22) Dump the product_data file\n");
      printf("23) Check out utilities\n");
      printf("24) Exit\n");
      printf("\nEnter choice : ");
      scanf("%d",&choice);

      switch (choice) {
         case  1:
                  sts = drv_construct_os();
                  break;

         case  2:
                  sts = drv_delete_os();
                  break;

         case  3:
                  sts = drv_write_os();
                  break;

         case  4:
                  sts = drv_construct_obj();
                  break;

         case  5:
                  sts = drv_delete_obj();
                  break;

         case  6:
                  sts = drv_connect_obj();
                  break;

         case  7:
                  sts = drv_disconnect_obj();
                  break;

         case  8:
                  sts = drv_send();
                  break;

         case  9:
                  sts = drv_os_msg();
                  break;
         case 10:
                  sts = drv_channel_oper();
                  break;

         case 11:
                  sts = drv_copy_move_chan();
                  break;

         case 12: 
                  sts = drv_tag_oper();
                  break;

         case 13:
                  sts = drv_dir_oper();
                  break;

	 case 14:
		  sts = drv_set_oper();
		  break;

         case 15:
                  sts = drv_dynamic_class();
                  break;

         case 16:
                  OM_PMS();
                  break;

         case 17:
                  sts = drv_dynload();
                  break;

         case 18:
                  sts = drv_memalloc();
                  break;

         case 19:
                  sts = drv_set_state();
                  break;

         case 20:
                  sts = drv_intercept();
                  break;

         case 21:
		  sts = drv_dictionary();
                  break;

         case 22:
                  drv_dump_product_data();
                  break;
         case 23:
                  drv_utility_menu();
                  break;
         case 24:
                  exit(0);
                  break;

         default:
                  printf("Invalid choice...try again\n");
#ifndef NT
                  sleep(2);
#endif 
                  break;
      }
   }
}

int drv_dictionary()
{
	int	sts = OM_S_SUCCESS;
#ifdef BIG_ENDIAN
	char	filename[MAXPATHLEN];
	char	answer[256];
	
	printf("Load a dictionary [y/n] : ");
	scanf("%s", answer);
	if ('y' == *answer || 'Y' == *answer)
	{
		printf("Enter dictionary filename : ");
		scanf("%s", filename);

		sts = som_load_dictionary(filename);
		_errchk("dictionary");

#ifdef DEBUG
		printf("Dump dictionary [y/n] : ");
		scanf("%s", answer);
		if ('y' == *answer || 'Y' == *answer)
			(void)som_dump_dictionary(0);
#endif
	}

	printf("Load special conversion functions [y/n] : ");
	scanf("%s", answer);
	if ('y' == *answer || 'Y' == *answer)
	{
		printf("Enter path name : ");
		scanf("%s", filename);

		sts = som_dload_conversion_functions(filename);
		_errchk("conversion functions");

#ifdef DEBUG
		printf("Dump dictionary [y/n] : ");
		scanf("%s", answer);
		if ('y' == *answer || 'Y' == *answer)
			(void)som_dump_dictionary(0);
#endif
	}
#endif	/* BIG_ENDIAN */
	return sts;
}

int drv_construct_os()
{
   int    sts;
   OMuint loadmode;
   char   class[OM_K_MAXCLASS_LEN];
   char   osname[OM_K_MAXOSNAME_LEN];
/*   char   lm_str[10];
   char   logical[64];*/
   char  *di_logical=0;

/*   printf ("Enter os class : ");
   scanf("%s",class);
   printf ("Enter os name : ");
   scanf("%s",osname);
   printf ("Enter loadmode (ro,rw) : ");
   scanf("%s",lm_str);
   loadmode = 0;
   if (lm_str[1] == 'o') loadmode = OM_e_loados_ro;
   logical[0] = 0;
   printf ("Enter di_logical : ");
   scanf("%s",logical);
   if ( logical[0] ) di_logical = logical;
*/
   strcpy(class, "OMFiledOS");
   printf ("Enter os name : ");
   scanf("%s",osname);
   loadmode = 0;
   di_logical = 0;

   sts = om$construct_os( classname  = class,
                          osname     = osname,
                          p_objid    = &os_oid[num_os],
                          osnum      = &os_num[num_os],
                          loadmode   = loadmode,
                          di_logical = di_logical );
   _errchk("construct_os");

   printf ("OS number constructed is %d\n",os_num[num_os]);
   ++num_os;

   return (sts);
}


int drv_delete_os()
{
   int           sts;
   int           defer;
   char         *classname;
   OMuword       osnum;
   OM_S_MESSAGE  del_os;

   sts = drv_display_os();

   printf ("Enter OS number to delete : ");
   scanf("%hd",&osnum);

   if (OM_GA_OSDs[osnum]->type == OM_OSD_trans) {
      classname = "OMTransOS";
   }
   else {
      classname = "OMFiledOS";
   }
  
   sts = om$make_message ( classname  = classname,
                           methodname = "delete",
                           size       = 4,
                           p_arglist  = &defer,
                           p_msg      = &del_os );
   _errchk ("make_message for delete of os");

   sts = om$send ( msg      = &del_os,
                   senderid = 0,
                   targetid = 0,
                   targetos = osnum );
   _errchk("delete os");

   os_num[osnum] = 0;
   return (sts);
}


int drv_write_os()
{
   int           sts;
   char         *p_name=0;
   char          c1[4], new_name[OM_K_MAXOSNAME_LEN];
   OMuword       osnum;
   OM_S_MESSAGE  write_os;
   

   sts = drv_display_os();

   printf ("Enter OS number to write : ");
   scanf("%hd",&osnum);

   if (OM_GA_OSDs[osnum]->type == OM_OSD_trans) {
      printf ("Cannot write a Transient Object Space\n");
#ifndef NT
      sleep(2);
#endif 

      return (0);
   }

   printf ("New OS name? [y/n] : ");
   scanf("%s",c1);  

   if ( c1[0] == 'y' ) {
      printf ("Enter new OS name : ");
      scanf("%s",new_name);
      p_name = new_name;
   }
   else
      p_name = 0;

   sts = om$make_message ( classname  = "OMFiledOS",
                           methodname = "write",
                           size       = 4,
                           p_arglist  = &p_name,
                           p_msg      = &write_os );
   _errchk ("make_message for write of os");

   sts = om$send ( msg      = &write_os,
                   senderid = 0,
                   targetid = 0,
                   targetos = osnum );
   _errchk("write OS");

   return (sts);
}


int drv_construct_obj()
{
   int         sts, num, i, auto_name;
   char        classname[OM_K_MAXCLASS_LEN];
   char        logical[64];
   OMuword     osnum, osnum2;
   OM_S_OBJID  my_oid;

   sts = drv_display_os();

   printf ("Enter OS number : ");
   scanf("%hd",&osnum);

   printf ("Enter classname : ");
   scanf("%s",classname);

   printf ("Enter number to construct : ");
   scanf("%d",&num);

   printf ("Auto naming (n or di_logical) : ");
   scanf("%s",logical);

   if ( logical[0] == 'n' && logical[1] == 0 ) 
      auto_name = 0;
   else
      auto_name = strlen(logical);

   for (i=0; i<num; ++i) {
      sts = om$construct ( osnum     = osnum,
                           classname = classname,
                           p_objid   = &my_oid );
      _errchk("construct object");

      if (verbose) {
         printf ("%d) Object id is %d\n",i, my_oid);
      }
      else {
         if (i == 0) printf ("First object id is %d\n",my_oid);
         if (i == num-1) printf ("Last object id is %d\n",my_oid);
      }
      
      if (auto_name) {
         sprintf(&logical[auto_name],":%d",my_oid);
         sts = di$add_name ( objname = logical,
                             objid   = my_oid,
                             p_osnum = &osnum2 );
         _di_errchk("add name");
      }
   }

   return (sts);                        
}


int drv_delete_obj()
{
   int           sts;
   int           defer;
   OMuword       osnum;
   OM_S_OBJID    my_oid;
   OM_S_MESSAGE  root_del;

   sts = drv_display_os();

   printf ("Enter OS number : ");
   scanf("%hd",&osnum);

   printf ("Enter oid to delete : ");
   scanf("%d",&my_oid);

   sts = om$make_message ( classname  = "Root",
                           methodname = "delete",
                           size       = 4,
                           p_arglist  = &defer,
                           p_msg      = &root_del );
   _errchk("make message for Root.delete");

   sts = om$send ( msg      = &root_del,
                   senderid = my_oid,
                   targetid = my_oid,
                   targetos = osnum );
   _errchk("send of Root.delete");

   return (sts);
}


int drv_connect_obj()
{
   int           sts;
   char          s1_name[OM_K_MAXCHANNAME_LEN];
   char          s2_name[OM_K_MAXCHANNAME_LEN];
   OMuword       s1_osnum;
   OM_S_OBJID    s1_oid;
   OM_S_MESSAGE  root_con;
   struct sd_conn_args {
      OM_S_CHANSELECT to_sel;
      int             to_idx;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_sel;
      int             fr_idx;
   } conn_args;

   sts = drv_display_os();

   conn_args.to_sel.type = OM_e_name;
   conn_args.fr_sel.type = OM_e_name;   
   conn_args.to_sel.u_sel.name = s1_name;
   conn_args.fr_sel.u_sel.name = s2_name;

   printf ("Side 1 - Enter OS number : ");
   scanf("%hd",&s1_osnum);
   printf ("         Enter oid : ");
   scanf("%d",&s1_oid);
   printf ("         Enter channel name : ");
   scanf("%s",s1_name);
   printf ("         Enter index : ");
   scanf("%d",&conn_args.to_idx);

   printf ("Side 2 - Enter OS number : ");
   scanf("%hd",&conn_args.fr_os);
   printf ("         Enter oid : ");
   scanf("%d",&conn_args.fr_objid);
   printf ("         Enter channel name : ");
   scanf("%s",s2_name);
   printf ("         Enter index : ");
   scanf("%d",&conn_args.fr_idx);

   sts = om$make_message ( classname  = "Root",
                           methodname = "connect",
                           size       = sizeof(struct sd_conn_args),
                           p_arglist  = &conn_args,
                           p_msg      = &root_con );
   _errchk("make message for Root.connect");

   sts = om$send ( msg      = &root_con,
                   senderid = conn_args.fr_objid,
                   targetid = s1_oid,
                   targetos = s1_osnum );
   _errchk("send of Root.connect");

   return (sts);   
}


int drv_disconnect_obj()
{
   int              sts;
   char             ans[4];
   char             s1_name[OM_K_MAXCHANNAME_LEN];
   char             s2_name[OM_K_MAXCHANNAME_LEN];
   OMuword          osnum;
   OM_S_OBJID       my_oid;
   OM_S_MESSAGE     wild_dis;
   OM_S_MESSAGE     disconn;
   OM_S_CHANSELECT  csel;
   struct sd_discon_args {
      OM_S_CHANSELECT to_sel;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_sel;
   } discon_args;

   printf ("Wild disconnect? (y/n) : ");
   scanf("%s",ans);
   sts = drv_display_os();
   if ( ans[0] == 'y' ) {
      printf ("Enter OS number : ");
      scanf("%hd",&osnum);
      printf ("Enter oid : ");
      scanf("%d",&my_oid);
      printf ("Enter channel name : ");
      scanf("%s",s1_name);

      sts = om$make_message ( classname  = "Root",
                              methodname = "wild_disconnect",
                              size       = sizeof(OM_S_CHANSELECT),
                              p_arglist  = &csel,
                              p_msg      = &wild_dis );
      _errchk("make message for Root.wild_disconnect");

      csel.type       = OM_e_name;
      csel.u_sel.name = s1_name;

      sts = om$send ( msg      = &wild_dis,
                      senderid = my_oid,
                      targetid = my_oid,
                      targetos = osnum );
      _errchk("send of Root.wild_disconnect");
   }
   else {
      printf ("Side 1 - Enter OS number : ");
      scanf("%hd",&osnum);
      printf ("         Enter oid : ");
      scanf("%d",&my_oid);
      printf ("         Enter channel name : ");
      scanf("%s",s1_name);

      printf ("Side 2 - Enter OS number : ");
      scanf("%hd",&discon_args.fr_os);
      printf ("         Enter oid : ");
      scanf("%d",&discon_args.fr_objid);
      printf ("         Enter channel name : ");
      scanf("%s",s2_name);

      sts = om$make_message ( classname  = "Root",
                              methodname = "disconnect",
                              size       = sizeof(struct sd_discon_args),
                              p_arglist  = &discon_args,
                              p_msg      = &disconn );
      _errchk("make message for Root.disconnect");

      discon_args.to_sel.type = OM_e_name;
      discon_args.fr_sel.type = OM_e_name;
      discon_args.to_sel.u_sel.name = s1_name;
      discon_args.fr_sel.u_sel.name = s2_name;

      sts = om$send ( msg      = &disconn,
                      senderid = discon_args.fr_objid,
                      targetid = my_oid,
                      targetos = osnum );
      _errchk("send of Root.disconnect");
   }

   return (0);
}


int drv_send()
{
   int              sts, choice, to_idx, from_idx, argsz, *p_arg=0;
   char             typ[4];
   char             class[OM_K_MAXCLASS_LEN];
   char             meth[OM_K_MAXMETH_LEN];
   char             channame[OM_K_MAXCHANNAME_LEN];
   OMuword          osnum, save_os;
   OM_S_OBJID       my_oid;
   OM_S_MESSAGE     msg;
   OM_S_CHANSELECT  csel;
   OM_E_INC_FLAG    inc;

   printf ("\n");
   printf (" 1) Send to an object\n");
   printf (" 2) Channel send\n");
   printf (" 3) Sibling send\n");
   printf ("\nEnter choice : ");
   scanf("%d",&choice);

   if (choice < 1 || choice > 3) return (0);

   printf ("Message - Enter classname    : ");
   scanf("%s",class);
   printf ("          Enter methodname   : ");
   scanf("%s",meth);
   printf ("          Enter arglist size : ");
   scanf("%d",&argsz);
   if (argsz) {
      p_arg = (int *) om$malloc (size = argsz);
      printf ("Enter arg type (i-int,c-char,s-string) : ");
      scanf("%s",typ);
      switch ( typ[0] ) {
       case 'i': 
                 printf ("Enter int : ");
                 scanf ("%d",p_arg);
                 break;

       case 'c':
                 printf ("Enter char : ");
                 scanf ("%s",typ);
                 *(char *)p_arg = typ[0];
                 break;

       case 's':
                 printf ("Enter string : ");
                 scanf ("%s",p_arg);
                 break;

       default :
                 break;
      }
   }

   sts = om$make_message ( classname  = class,
                           methodname = meth,
                           size       = argsz,
                           p_arglist  = p_arg,
                           p_msg      = &msg );
   _errchk("make message");

   sts = drv_display_os();
   printf ("Enter OS number : ");
   scanf("%hd",&osnum);
   printf ("Enter oid : ");
   scanf("%d",&my_oid);   

   switch ( choice ) {
     case  1 : 
                sts = om$send ( msg      = &msg,
                                senderid = my_oid,
                                targetid = my_oid,
                                targetos = osnum );
		if (sts == OM_W_UNKNOWN_MSG)
		{
			printf("unknown send for %u.%u\n", osnum, my_oid);
			sts = OM_S_SUCCESS;
		}
                _errchk("send");
                break;

     case  2 : 
                printf ("Enter channel name : ");
                scanf("%s",channame);

                csel.type = OM_e_name;
                csel.u_sel.name = channame;

                printf ("Enter from index : ");
                scanf("%d",&from_idx);
                printf ("Enter to index : ");
                scanf("%d",&to_idx);

                sts = om$send ( msg          = &msg,
                                senderid     = my_oid,
                                p_chanselect = &csel,
                                targetos     = osnum,
                                from         = from_idx,
                                to           = to_idx );
                _errchk("send channel");
                break;

     case  3 : 
                printf ("Enter channel name : ");
                scanf("%s",channame);
                printf ("Inclusive (0 or 1) : ");
                scanf("%d",&inc);
                if (inc) 
                   inc = OM_e_inclusive;
                else
                   inc = OM_e_exclusive;

                csel.type = OM_e_name;
                csel.u_sel.name = channame;


                if ( osnum != OM_Gw_current_OS ) {
                   save_os = OM_Gw_current_OS;
                   om$make_current_os ( osnum = osnum );
                }
                else
                   save_os = OM_Gw_current_OS;

                sts = om$sibling_send ( msg          = &msg,
                                        senderid     = my_oid,
                                        p_chanselect = &csel,
                                        inclusive    = inc );
                
                if ( save_os != OM_Gw_current_OS ) {
                   om$make_current_os ( osnum = save_os );
                }
                _errchk("sibling send");
                break;
   }

   if ( p_arg ) om$dealloc ( ptr = (char *) p_arg );
   return (sts);
}


int drv_os_msg()
{
   int           sts, choice, state;
   char          name[OM_K_MAXOSNAME_LEN];
   OMuword       os;
   OM_S_MESSAGE  msg;
   struct sd_change_args {
      char              *name;
      OM_e_OVRWRT_FLG  overwrt;
   } change_args;

   printf ("\n");
   printf (" 1) Change OS name\n");
   printf (" 2) Set OS state\n");
   printf (" 3) Get OS status\n");
   printf ("\nEnter choice : ");
   scanf("%d",&choice);

   if (choice < 1 || choice > 3) return (0);

   sts = drv_display_os();

   printf ("Enter OS number : ");
   scanf("%hd",&os);

   switch (choice) {

      case  1: 
                printf ("Enter new OS name : ");
                scanf("%s",name);

                sts = om$make_message ( classname  = "OMObjSpace",
                                        methodname = "change_name",
                                         size       = sizeof(struct sd_change_args),
                                         p_arglist  = &change_args,
                                         p_msg      = &msg );
                _errchk("make message for OMObjSpace.change_name");

                change_args.name = name;
                change_args.overwrt = OM_e_no_ovrwrt;

                sts = om$send ( msg      = &msg,
                                senderid = NULL_OBJID,
                                targetid = 0,
                                targetos = os );
                _errchk("send of OMObjSpace.change_name");
                break;

      case  2:

                printf ("Enter OS state (0=nowrite,1=write) : ");
                scanf("%d",&state);

                sts = om$make_message ( classname  = "OMFiledOS",
                                        methodname = "set_state",
                                        size       = 4,
                                        p_arglist  = &state,
                                        p_msg      = &msg );
                _errchk("make message for OMFiledOS.set_state");

                sts = om$send ( msg      = &msg,
                                senderid = NULL_OBJID,
                                targetid = 0,
                                targetos = os );
                _errchk("send of OMFiledOS.set_state");
                break;
         case 3:
         {
            int            ii, count;
            OM_p_SPAMAPENT p_spacemap;
            OM_S_OSSTATUS  os_stat;
            OM_p_OSSTATUS  pstat=&os_stat;

            pstat->stattype = OM_OS_STATUS_MISC;
            sts = om$make_message ( classname  = "OMFiledOS",
                                    methodname = "get_status",
                                    size       = 4,
                                    p_arglist  = &pstat,
                                    p_msg      = &msg );
            _errchk("make message for OMFiledOS.get_status");

            for (count=ii=0; ii<OM_GA_OSDs[os]->CurSpaceMapSize; ii++)
            {
               p_spacemap=&OM_GA_OSDs[2]->Spacemap[ii];
               if (!(OM_OBJ_INVALID(p_spacemap->flags)))
                 count++;
            }
            sts = om$send ( msg      = &msg,
                            senderid = NULL_OBJID,
                            targetid = 0,
                            targetos = os );
            _errchk("send of OMFiledOS.get_status(misc)");

            printf("\n  OS type: %d OM_OSD_", pstat->stat.misc.OStype);
            if (pstat->stat.misc.OStype)
            {
               if (pstat->stat.misc.OStype == 1)
                  printf("trans");
               else
                  printf("filed");
            }
            else printf("MOSDOS");
            printf("   Flags: %d", pstat->stat.misc.OSflags);
            if (pstat->stat.misc.OSflags)
            {
               if (pstat->stat.misc.OSflags & 1)
                  printf(" OM_OSD_inuse");
               if (pstat->stat.misc.OSflags & 2)
                  printf(" OM_OSD_nowrite");
               if (pstat->stat.misc.OSflags & 4)
                  printf(" OM_OSD_compress_on_wrt");
               if (pstat->stat.misc.OSflags & 8)
                  printf(" OM_OSD_modified");
               if (pstat->stat.misc.OSflags & 16)
                  printf(" OM_OSD_ISOmodified");
               if (pstat->stat.misc.OSflags & 32)
                  printf(" OM_e_loados_ro");
               if (pstat->stat.misc.OSflags & 64)
                  printf(" OM_OSD_Rootdel_pending");
            }
            printf("\n  Creation time: %s\n  Last write:    %s\n",
               pstat->stat.misc.CreTimeDate, pstat->stat.misc.TimeDate);
            printf("  Total object count: %d  Current Spacemap size: %d\n",
               count, OM_GA_OSDs[os]->CurSpaceMapSize);
            printf("  Known object count: %d (%d user, %d OM)\n",
               pstat->stat.misc.num_UserObjects +
               pstat->stat.misc.num_OMobjects,
               pstat->stat.misc.num_UserObjects,
               pstat->stat.misc.num_OMobjects);

            pstat->stattype = OM_OS_STATUS_CLUSTERS;
            sts = om$send ( msg      = &msg,
                            senderid = NULL_OBJID,
                            targetid = 0,
                            targetos = os );
            _errchk("send of OMFiledOS.get_status(clusters)");
            printf("  Cluster count: %d (%d faulted)  In-memory chunks: %d\n\n",
               pstat->stat.cluster.total_num,
               pstat->stat.cluster.num_faulted,
               pstat->stat.cluster.num_chunks);
            break;
         }
      }
   return (sts);
}


int drv_channel_oper()
{
   int                  choice, size, sts, i;
   OMuint               count, ndx;
   char                 ch_name[OM_K_MAXCHANNAME_LEN];
   OMuword              os1, os2;
   OM_S_OBJID           oid1, oid2;
   OM_S_CHANSELECT      csel;
   OM_p_OBJECT_LINKAGE  oid_list, po;
  
   printf ("\n");
   printf (" 1) get_channel_count\n");
   printf (" 2) get_channel_objects\n");
   printf (" 3) is_objid_on_channel\n");
   printf (" 4) get_index\n");
   printf (" 5) get_objid_at_index\n");
   printf (" 6) channel_preset\n");      
   printf (" 7) channel_unpreset\n");
   printf ("\nEnter Choice : ");
   
   scanf("%d",&choice);

   if ( choice < 1 || choice > 7 ) {
      printf ("Invalid choice . . . \n");

#ifndef NT
      sleep(2);
#endif 

      return(0);
   }

   sts = drv_display_os();

   printf ("Enter OS number : ");
   scanf("%hd",&os1);
   printf ("Enter oid : ");
   scanf("%d",&oid1);
   printf ("Enter channel name : ");
   scanf("%s",ch_name);

   csel.type = OM_e_name;
   csel.u_sel.name = ch_name;

   switch ( choice ) {
     case  1:  
               sts = om$get_channel_count ( osnum        = os1,
                                            objid        = oid1,
                                            p_chanselect = &csel,
                                            count        = &count );
               _errchk("get_channel_count");
               printf ("Channel count : %d\n",count);
               break;

     case  2:
               sts = om$get_channel_count ( osnum        = os1,
                                            objid        = oid1,
                                            p_chanselect = &csel,
                                            count        = &count );
               _errchk("get_channel_count");
               printf ("Channel count : %d\n",count);
               if (!count) return(1);
               oid_list = (OM_p_OBJECT_LINKAGE)
                  om$malloc ( size = sizeof(OM_S_OBJECT_LINKAGE) *
                                             count );
               if (!oid_list) {
                  printf ("Could not allocate oid list\n");
#ifndef NT
                  sleep(2);
#endif 
                  return(0);
               }           
               size = count;
                           
               sts = om$get_channel_objects ( osnum        = os1,
                                              objid        = oid1,
                                              p_chanselect = &csel,
                                              list         = oid_list,
                                              size         = size,
                                              count        = &count );
               _errchk("get_channel_objects");

               for ( i=0; i<count; ++i ) {
                  po = &oid_list[i];
                  printf ("Ndx:%d  OS:%d  Flags:%x(x)  Cnum:(%d,%d) Oid:%d\n",
                     i,po->osnum,po->w_flags,po->channum.classid,
                     po->channum.number,po->S_objid);
               }
               om$dealloc ( ptr = (char *) oid_list );
               break;

     case  3:
               printf ("Objid in question - Enter OS number : ");
               scanf("%hd",&os2);
               printf ("                    Enter oid : ");
               scanf("%d",&oid2);

               sts = om$is_objid_on_channel ( osnum_c      = os1,
                                              objid_c      = oid1,
                                              p_chanselect = &csel,
                                              objid        = oid2,
                                              osnum2       = os2 );
               if (sts == OM_S_SUCCESS)
                  printf ("Yes...objid was on channel\n");
               else if (sts == OM_W_NOTONCHAN)
                  printf ("No...objid was not on channel\n");
               else
                  _errchk("is_objid_on_channel");
               break;

     case  4:
               printf ("Objid in question - Enter OS number : ");
               scanf("%hd",&os2);
               printf ("                    Enter oid : ");
               scanf("%d",&oid2);

               sts = om$get_index ( osnum_c      = os1,
                                    objid_c      = oid1,
                                    p_chanselect = &csel,
                                    objid        = oid2,
                                    osnum2       = os2,
                                    indexaddr    = &ndx );
               if (sts == OM_S_SUCCESS)
                  printf ("Index : %d\n",ndx);
               else
                  _errchk("get_index");
               break;

     case  5:
               printf ("Enter index : ");
               scanf("%d",&ndx);
               sts = om$get_objid_at_index ( osnum        = os1,
                                             objid        = oid1,
                                             p_chanselect = &csel,
                                             index        = ndx,
                                             objidaddr    = &oid2,
                                             osnumaddr    = &os2 );
               if (sts == OM_S_SUCCESS)
                  printf ("OS:%d  Objid:%d\n",os2,oid2);
               else
                  _errchk("get_objid_at_index");
               break;

     case  6:
               printf ("Enter size : ");
               scanf("%d",&size);

               sts = om$channel_preset ( osnum        = os1,
                                         objid        = oid1,
                                         p_chanselect = &csel,
                                         size         = size );
               _errchk("channel_preset");
               break;

     case  7:
               printf ("Enter collapse flags (0 or 1) : ");
               scanf("%d",&ndx);

               sts = om$channel_unpreset ( osnum         = os1,
                                           objid         = oid1,
                                           p_chanselect  = &csel,
                                           collapse_flag = ndx );
               _errchk("channel_unpreset");
               break;
   }
   return(1);
}


int drv_copy_move_chan()
{
   int           sts;
   char          ans[4];
   char          sor_name[OM_K_MAXCHANNAME_LEN];
   char          tar_name[OM_K_MAXCHANNAME_LEN];
   OMuword       tar_osnum;
   OM_S_OBJID    tar_oid;
   OM_S_MESSAGE  msg;
   struct sd_args {
      OM_S_CHANSELECT to_sel;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_sel;
   } args;

   printf ("Copy chan or Move chan (c/m) : ");
   scanf("%s",ans);
   
   sts = drv_display_os();

   printf ("Source - Enter OS number : ");
   scanf("%hd",&args.fr_os);
   printf ("         Enter oid : ");
   scanf("%d",&args.fr_objid);
   printf ("         Enter channel name : ");
   scanf("%s",sor_name);
   printf ("Target - Enter OS number : ");
   scanf("%hd",&tar_osnum);
   printf ("         Enter oid : ");
   scanf("%d",&tar_oid);
   printf ("         Enter channel name : ");
   scanf("%s",tar_name);

   args.fr_sel.type = OM_e_name;
   args.to_sel.type = OM_e_name;
   args.fr_sel.u_sel.name = sor_name;
   args.to_sel.u_sel.name = tar_name;

   if ( ans[0] == 'c' ) {
      sts = om$make_message ( classname  = "Root",
                              methodname = "copy_chan",
                              size       = sizeof(struct sd_args),
                              p_arglist  = &args,
                              p_msg      = &msg );
      _errchk("make message for Root.copy_chan");
   }
   else {
      sts = om$make_message ( classname  = "Root",
                              methodname = "move_chan",
                              size       = sizeof(struct sd_args),
                              p_arglist  = &args,
                              p_msg      = &msg );
      _errchk("make message for Root.move_chan");
   }

   sts = om$send ( msg      = &msg,
                   senderid = args.fr_objid,
                   targetid = tar_oid,
                   targetos = tar_osnum );
   _errchk("send of copy_chan or move_chan");
   return(sts);
}


int drv_tag_oper()
{
   int      sts;
   OMuint   tag;
   int      my_oid;
   char     ans[4];
   OMuword  osnum;
   OMuword  prev_osnum;

   printf ("Enable tagging? (y/n) : ");
   scanf("%s",ans);
   if (ans[0] == 'y') {
      om$enable_tag_connects(flag = 1);
      om$enable_tagging(flag = 1);
   }
   else {
      om$enable_tag_connects(flag = 0);
      om$enable_tagging(flag = 0);
   }
   
   sts = drv_display_os();

   printf ("Enter tag OS (0 if not) : ");
   scanf("%hd",&osnum);
   if (osnum) {
      sts = om$set_tag_os ( osnum        = osnum,
                            p_prev_osnum = &prev_osnum );
      _errchk("set tag OS");
   }

   while (1) {
      printf ("Enter objid to tag (0 to quit) : ");
      scanf("%d",&my_oid);
  
      if (!my_oid) break;
      sts = om$add_tag ( osnum = osnum,
                         objid = my_oid,
                         p_tag = &tag );
      _errchk("add tag");
   }
   return (sts);
}


int drv_dir_oper()
{
   int         sts = 1;
   int         dir_choice;
   char        name[64];
   OMuword     osnum;
   OM_S_OBJID  my_oid;

   printf ("1) Add name\n");
   printf ("2) Translate name\n");
   printf ("3) Remove name\n");
   printf ("\nEnter choice : ");
   scanf("%d",&dir_choice);

   switch ( dir_choice ) {
      case  1:
                printf ("Enter os   : ");
                scanf("%hd",&osnum);
                printf ("Enter oid  : ");
                scanf("%d",&my_oid);
                printf ("Enter name : ");
                scanf("%s",name);
                sts = di$add_name ( objname = name,
                                    objid   = my_oid,
                                    p_osnum = &osnum );
                _di_errchk("add name");
                printf ("OSnum returned : %d\n",osnum);
                break;
      case  2:
                printf ("Enter name : ");
                scanf("%s",name);
                sts = di$translate ( objname = name,
                                     p_objid = &my_oid,
                                     p_osnum = &osnum );
                _di_errchk("translate");
                printf ("OSnum,objid returned : (%d,%d)\n",osnum,my_oid);
                break;
      case  3:  
                printf ("Enter name : ");
                scanf("%s",name);
                sts = di$rm_name ( regexp = name );    
                _di_errchk("remove name");
                break;
/*      case  4:  
                debug_on();
                debug_class("*");
                debug_method("*");
                break; */
      default:
                printf ("Invalid choice...try again\n");
#ifndef NT
                sleep(2);
#endif 
                break;
   }  
   return(sts);
}

#define MAX_PARENTS 20

int drv_dynamic_class()
{
   int sts, choice;
   char *parents[MAX_PARENTS], dyn_class[32];
   OMuword num_parents, minver, majver, os;
   OM_S_OBJID oid;
   OMuword i;
 
   printf ("1) Dynamic class\n");  
   printf ("2) Change class\n");  
   printf ("3) Exit\n");  
   printf ("Enter choice : ");
   scanf ("%d",&choice);

   switch ( choice ) {
   case 1:
      printf ("Enter number of parents : ");
      scanf("%hd",&num_parents);
   
      if ( num_parents > MAX_PARENTS ) {
         printf ("Sorry,  currently limited to %d parents\n",MAX_PARENTS);
         return (0);
      }
 
      for ( i=0; i<num_parents; ++i ) {
         printf ("Enter parent[%d] name : ",i);
         parents[i] = om$malloc(size = 32);
         scanf("%s",parents[i]);
      }

      printf ("Enter major version : ");
      scanf("%hd",&majver);
      printf ("Enter minor version : ");
      scanf("%hd",&minver);

      printf ("Enter dynamic class name : ");
      scanf("%s",dyn_class);
  
      sts = om$dynamic_class ( p_parent_class  = parents,
                               num_parents     = num_parents,
                               maj_version     = majver,
                               min_version     = minver,
                               p_dynamic_class = dyn_class );
      _errchk("dynamic class");

      for ( i=0; i<num_parents; ++i ) {
         om$dealloc ( ptr = (char *) parents[i] );
      }

      break;

   case 2:
      sts = drv_display_os();
      printf ("Enter osnum : ");
      scanf("%hd",&os);
      printf ("Enter oid   : ");
      scanf("%d",&oid);
      printf ("Enter new classname : ");
      scanf("%s",dyn_class);

      sts = om$change_class ( osnum     = os,
                              objid     = oid,
                              classname = dyn_class );
      _errchk("change_class");
      break;

   default:
      return (1);

   }
   return (sts);
}


int drv_dynload()
{
#if defined (CLIX) || defined (SUNOS) || defined (IRIX)
   int                    choice, sts, options, numsyms, ii, count;
   int                    (*save_class_init)();
   char                   spec[64], impl[64];
   void                   *p_dl;
   struct symdef          *symbuf;
   OM_p_CREATECLASS_ARGS  p_cc_args;

   options = TEXTREF | DATAREF | TEXTREDEF;
   printf("1) Dynamic load of class\n");
   printf("2) Dynamic load of function\n");
   printf("Enter choice : ");
   scanf("%d",&choice);
   
   switch ( choice ) {
     case 1 : 
       printf("Enter class specification object : ");
       scanf("%s",spec);
       printf("Enter class implementation object : ");
       scanf("%s",impl);

       p_dl = dload ( "dynload.o", options );
       p_dl = dload ( impl, options );
       p_dl = dload ( spec, options );
       if (numsyms = dload_symbol_lookup(p_dl, (char *) 0, &symbuf))
       {
          for (ii=0; ii<numsyms; ii++)
          {
             if (symbuf[ii].flags & DL_TEXT)
             {
                save_class_init = (OM_p_FUNCPTR) (int) symbuf[ii].value;
                p_cc_args = ((OM_p_CREATECLASS_ARGS (*)()) (int)
                   symbuf[ii].value) ();
                sts = som_create_class ( p_cc_args, p_cc_args->p_class_id );
                _errchk("som_create_class");
                printf(" New classid : %hd\n",*p_cc_args->p_class_id);
                break;
             }
          }
          if (ii == numsyms)
             printf("No text symbols found by dload\n");
       }
       else
          printf(" No symbols found by dload\n");

       printf("Press return to continue\n");
       scanf("%s",spec);
       break;

     case 2 :
       printf("Enter object filename : ");
       scanf("%s",spec);
       p_dl = dload ( spec, options );
       numsyms = dload_symbol_lookup(p_dl, (char *) 0, &symbuf);
       printf(" Number of unresolved : %d\n", numsyms);
       for (ii=count=0; ii<numsyms; ii++)
       {
          if (symbuf[ii].flags & DL_TEXT)
            count++;
       }
       printf(" Number of functions  : %d\n", count);
       printf("Press return to continue\n");
       scanf("%s",spec);
       break;

     default :
       return (0);
   }
#else
#warning Dload not supported on this OS !!
#endif

   return (1);
}


int drv_memalloc()
{
   int  choice, siz, num, tot=0, i;
   char *ptr;

   printf ("1) malloc\n");
   printf ("2) calloc\n");
   printf ("3) realloc\n");
   printf ("4) sm_malloc\n");
   printf ("5) sm_calloc\n");
   printf ("6) sm_realloc\n");
   printf ("Enter choice : ");
   scanf ("%d",&choice);

   if ( choice > 6 ) return (0);

   if ( choice != 3 && choice != 6 ) {   
      printf ("Enter number of chunks : ");
      scanf("%d",&num);
      printf ("Enter size of chunks   : ");
      scanf("%d",&siz);
   }
   else {  /* realloc cases */
      num = 1;
      printf ("Enter ptr (hex)  : ");
      scanf("%x",&ptr);
      printf ("Enter size       : ");
      scanf("%d",&siz);
   }

   for ( i=0; i<num; ++i ) {
      switch (choice) {
        case 1:
                ptr = om$malloc ( size = siz );
                break;

        case 2:
                ptr = om$calloc ( num = 1, size = siz );
                break;

        case 3:
                ptr = om$realloc ( ptr = (char *) ptr, size = siz );
                break;

        case 4:
                ptr = om$sm_malloc ( size = siz );
                break;

        case 5:
                ptr = om$sm_calloc ( num = 1, size = siz );
                break;

        case 6:
                ptr = om$sm_realloc ( ptr = (char *) ptr, size = siz );
                break;
      }
      if (ptr) { 
         tot += siz;
         printf ("%d) Ptr::0x%x   Size::%d   Total Size::%d\n",i,ptr,siz,tot);
      }
      else {
         printf ("****** Zero ptr returned *****  Size::%d   Total Size::%d\n",
                          siz, tot);
         return (0);               
      }
   }
   return (1);
}


int drv_display_os()
{
   int i;

   printf ("\n");
   for ( i=1; i<num_os; ++i ) {
      if (OM_GA_OSDs[i])
         printf ("%d - %s\n",i,OM_GA_OSDs[i]->name);
   }
   printf ("\n");
   return (1);
}

int drv_set_oper()
{
   OMuint	sts;
   OM_S_OBJID	my_oid;
   OMuword	my_os;
   OM_S_MESSAGE	msg;
   char		mychan_name[128], op2_name[128], op3_name[128];
   struct sd_args {
      OM_S_CHANSELECT to_sel;
      OM_S_OBJID      op2_objid;
      OMuword         op2_os;
      OM_S_CHANSELECT op2_sel;
      OM_S_OBJID      op3_objid;
      OMuword         op3_os;
      OM_S_CHANSELECT op3_sel;
      char	      operation;
      OMuword	      preserve;
   } args;

   args.to_sel.type = OM_e_name;
   args.op2_sel.type = OM_e_name;
   args.op3_sel.type = OM_e_name;
   args.to_sel.u_sel.name = &(mychan_name[0]);
   args.op2_sel.u_sel.name = &(op2_name[0]);
   args.op3_sel.u_sel.name = &(op3_name[0]);
   printf ("\n");
   printf ("Receiving Operand - Enter oid : ");
   scanf("%d",&my_oid);
   printf ("                  - Enter osnum : ");
   scanf("%hd",&my_os);
   printf ("                  - Enter channel name : ");
   scanf("%s",mychan_name);
   printf ("Enter operation type(u or i or d) : ");
   scanf("%1s",&(args.operation));
   printf ("Enter preserve flag(1 or 0) : ");
   scanf("%hd",&(args.preserve));
   printf ("Operand2 - Enter OS number : ");
   scanf("%hd",&(args.op2_os));
   printf ("           Enter oid : ");
   scanf("%d",&(args.op2_objid));
   printf ("         Enter channel name : ");
   scanf("%s",op2_name);
   printf ("Operand3 - Enter OS number : ");
   scanf("%hd",&(args.op3_os));
   printf ("           Enter oid : ");
   scanf("%d",&(args.op3_objid));
   printf ("           Enter channel name : ");
   scanf("%s",op3_name);


   sts = om$make_message ( classname  = "Root",
                              methodname = "set_operation",
                              size       = sizeof(struct sd_args),
                              p_arglist  = &args,
                              p_msg      = &msg );
   _errchk("make message for Root.set_operation");

   sts = om$send ( msg      = &msg,
                   targetid = my_oid,
		   senderid = NULL_OBJID,
                   targetos = my_os );
   _errchk("set operation");
   printf ("\n");
   return(1);
}


int drv_set_state ()
{
   int num;

   printf (" 1) Verbose is %s \n",(verbose?"ON":"OFF"));
   printf ("Enter choice to toggle : ");

   scanf("%d",&num);

   switch (num)
   {
      case 1: verbose = !verbose;
              break;

      default:
              break;
   }

   return (1);
}


int drv_intercept()
{
   int         choice, sts;
   OMuword     os, tos;
   OM_S_OBJID  oid, toid;

   printf (" 1) Set intercept\n");
   printf (" 2) Disable intercept\n");
   printf (" 3) Cancel intercept\n");
   printf (" 4) Get intercept\n");
   printf ("Enter choice : ");
   scanf ("%d",&choice);

   sts = drv_display_os();

   printf ("Enter osnum : ");
   scanf("%hd",&os);
   printf ("Enter oid   : ");
   scanf("%d",&oid);

   switch (choice) {
     case 1:
             printf ("Enter target osnum : ");
             scanf("%hd",&tos);
             printf ("Enter target oid   : ");
             scanf("%d",&toid);

             sts = om$set_intercept ( osnum        = os,
                                      objid        = oid,
                                      target_osnum = tos,
                                      target_objid = toid );
             _errchk("set_intercept");
             break;

     case 2:
             sts = om$disable_intercept ( osnum = os,
                                          objid = oid );
             _errchk("disable_intercept");
             break;

     case 3:
             sts = om$cancel_intercept ( osnum = os,
                                         objid = oid );
             _errchk("cancel_intercept");
             break;

     case 4:
             sts = om$get_intercept ( osnum          = os,
                                      objid          = oid,
                                      p_target_osnum = &tos,
                                      p_target_objid = &toid );
             _errchk("get_intercept");
             printf ("Target osnum : %hd\n",tos);
             printf ("Target objid : %d\n",toid);
             break;

     default:
             break;
   }
   return (1);
}


drv_utility_menu()
{
   int   choice;

   while (1)
   {
      printf("\n   Utilities Most Affected by Porting\n\n");
      printf("   1) OMfloatcvt: Test both rounding directions for pos and neg values\n");
      printf("   2) som_get_mem_info: Request all 6 memory values\n");
      printf("   3) Test 'em all\n");
      printf("   4) Return to Main Driver Menu\n");
      printf("   5) Exit\n\n");

      printf ("Enter choice : ");
      scanf ("%d",&choice);

      switch(choice)
      {
         case 1:
            drv_float_test();
            break;
         case 2:
            drv_mem_info_test();
            break;
         case 3:
            drv_float_test();
            drv_mem_info_test();
            break;
         case 4:
            return;
         case 5:
            exit(0);
         default:
            break;
      }
   }
}


drv_float_test()
{
   double a, c;
   float  b;

#ifdef SUNOS
   char  *save, *in, *out;
#endif

#ifdef IRIX
   int   saveMode, temp;
#endif

   a = 149634.686343;
   c = -3476.324618;

#if defined (CLIX)
   printf("\n\n%f rounded down: ", a);
   b = (float) OMfloatcvt(a, 0);
   printf("%f\n", b);
   printf("%f rounded up:   ", a);
   b = (float) OMfloatcvt(a, 1);
   printf("%f\n", b);
   printf("%f rounded down: ", c);
   b = (float) OMfloatcvt(c, 0);
   printf("%f\n", b);
   printf("%f rounded up:   ", c);
   b = (float) OMfloatcvt(c, 1);
   printf("%f\n\n", b);

#elif defined (SUNOS54) || defined (SUNOS55)

   fpsetround( FP_RN );

   printf("\n\n%f rounded down: ", a);
   b = (float) a;
   printf("%f\n", b);

   fpsetround ( FP_RP );

   printf("%f rounded up: ", a);
   b = (float) a;
   printf("%f\n", b);

   fpsetround ( FP_RN );

   printf("%f rounded down: ", c);
   b = (float) c;
   printf("%f\n", b);

   fpsetround( FP_RP );

   printf("%f rounded up: ", c);
   b = (float) c;
   printf("%f\n", b);


#elif defined (SUNOS)
   ieee_flags("get", "direction", in, &save);
   ieee_flags("set", "direction", "negative", &out);

   printf("\n\n%f rounded down: ", a);
   b = (float) a;
   printf("%f\n", b);

   ieee_flags("set", "direction", "positive", &out);

   printf("%f rounded up: ", a);
   b = (float) a;
   printf("%f\n", b);

   ieee_flags("set", "direction", "negative", &out);

   printf("%f rounded down: ", c);
   b = (float) c;
   printf("%f\n", b);

   ieee_flags("set", "direction", "positive", &out);

   printf("%f rounded up: ", c);
   b = (float) c;
   printf("%f\n", b);

   ieee_flags("get", "direction", save, &out);

#elif defined (IRIX)
   saveMode = swapRM(ROUND_TO_MINUS_INFINITY);
   printf("\n\n%f rounded down: ", a);
   b = (float) a;
   printf("%f\n", b);

   temp = swapRM(ROUND_TO_PLUS_INFINITY);
   printf("%f rounded up: ", a);
   b = (float) a;
   printf("%f\n", b);

   temp = swapRM(ROUND_TO_MINUS_INFINITY);
   printf("%f rounded down: ", c);
   b = (float) c;
   printf("%f\n", b);

   temp = swapRM(ROUND_TO_PLUS_INFINITY);
   printf("%f rounded up: ", c);
   b = (float) c;
   printf("%f\n", b);

   temp = swapRM(saveMode);
#else
#warning Floating point conversion not supported on this OS !!
#endif

   return(1);
}


drv_mem_info_test()
{
   int   avail_swap, total_swap, phys_mem,
         avail_om, total_om, total_free;

   if (!som_get_mem_info(&avail_swap, NULL, NULL, NULL, NULL, NULL))
   {
      printf("Avail_swap call failed\n");
   }
   if (!som_get_mem_info(NULL, &total_swap, NULL, NULL, NULL, NULL))
   {
      printf("Total_swap call failed\n");
   }
   printf("\n\nAvailable Swap  %10d     Total Swap      %10d\n",
      avail_swap, total_swap);
   if (!som_get_mem_info(NULL, NULL, NULL, &avail_om, NULL, NULL))
   {
      printf("Avail OM call failed\n");
      return(0);
   }
   if (!som_get_mem_info(NULL, NULL, NULL, NULL, &total_om, NULL))
   {
      printf("Total OM call failed\n");
      return(0);
   }
   printf("Available OM    %10d     Total OM        %10d\n",
      avail_om, total_om);
   if (!som_get_mem_info(&avail_swap, NULL, NULL, &avail_om, NULL, &total_free))
   {
      printf("Total free call failed\n");
      return(0);
   }
   if (!som_get_mem_info(NULL, NULL, &phys_mem, NULL, NULL, NULL))
   {
      printf("Phys_mem call failed\n");
      return(0);
   }
   printf("Total Free      %10d     Physical Memory %10d\n\n",
      total_free, phys_mem);
   return(1);
}


int drv_dump_product_data()
{
   int   ii;
   char  *p, *p1, *p2, *p3, *p4, *p5;

#ifndef NT
   if (!EX_read_product_data())
   {
      printf("EX_read_product_data failed.  Cannot continue.\n");
      return(0);
   }
   ii = 1;
   while (ex$get_product_data(index = ii, out_runname = &p,
      config_path = &p1, out_logo = &p2, module = &p3, dependency = &p4,
      product_path = &p5))
   {
      printf("\nRun_name      %s\n", p);
      printf("Logo          %s\n", p2);
      printf("Module        %s\n", p3);
      printf("Dependency    %s\n", p4);
      printf("Config_path   %s\n", p1);
      printf("Product_path  %s\n", p5);
      ii++;
   }
#endif
   return(1);
}

EX_error_box(vs, msg, title)
int   vs;
char  *msg, *title;
{
   if (!vs || !msg || !title)
   {
      printf("\n\nPoor Man's EX_error_box:\n");
      printf("\n+-------------------+\n");
      printf("|                   |\n");
      printf("|       x  x        |\n");
      printf("|         >         |\n");
      printf("|       ____        |\n");
      printf("|        U          |\n");
      printf("|                   |\n");
      printf("+-------------------+\n\n");
   }
   return(1);
}
