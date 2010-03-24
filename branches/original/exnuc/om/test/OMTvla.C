/*-----------------------------------------------------------------------
   Variable length array test.  Four command line parameters:  

   parameter 1:  Controls printing of major headings.  If TRUE print, else
                 do not print.

   parameter 2:  Controls printing of iteration data.  If TRUE print, else
                 do not print.

   parameter 3:  Specifies the number of iterations taken in the outrigger
                 test.

   parameter 4:  If TRUE, the test will pause after each object space 
                 write.  This allows the examination of the object space
                 with analos at each phase of the test.
--------------------------------------------------------------------------*/


#include <stdio.h>
#include <varargs.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"

#define ARRAY_C 0
#define ARRAY_S 1
#define ARRAY_F 2
#define ARRAY_I 3

#define NUMOBJS 2
#define MAXIT 5000
#define DEFIT 500

extern int OM_Gi_min_free_space;

#omdef write_read_os()
   if (print)
      printf("!!!!! Writing object space %s !!!!!\n",osname);

   sts = om$send(msg = &delete_msg,
                 targetid = os_objid,
                 targetos = osnum,
                 senderid = NULL_OBJID);
   if (!(1&sts))
      error(sts,"deleting object space %s\n",osname);
   
   if (paus)
   {
      printf("<return to continue> ");
      c = getc(stdin);
   }

   if (print) 
      printf("!!!!! Loading object space %s !!!!!\n",osname);

   sts = om$construct_os(classname="OMFiledOS",
                         p_objid=&os_objid,
                         osnum=&osnum,
                         osname=osname);
   if (!(1&sts))
      error(sts,"construct os %s\n",osname);

   if (x_print)
      printf("\to osnum = %d, os_objid = %d\n",osnum,os_objid);

#endomdef

#omdef verify_data()
   if (print)
      printf("!!!!! Verifying data !!!!!\n");

   for (ii=0; ii < NUMOBJS; ++ii)
   {
      sts = om$send(msg = &verify_msg,
                    senderid=NULL_OBJID,
                    targetid = objid[ii],
                    targetos = osnum);
      if (!(1&sts)) 
         error(sts,"send verify_msg objid[%d]\n",ii);
   }
          
#endomdef

/*-----------------------------
        Error handler
-----------------------------*/

static void error(va_alist)
va_dcl
{
   int sts;
   char *format;
   va_list args;

   va_start(args);

   sts = va_arg(args, int);
   format = va_arg(args, char *);

   fprintf(stderr,"error!!!  ");
   vfprintf(stderr,format,args);
   
   if (sts)
      om$report_error(sts=sts);

   exit(1);
}

/*------------------------------
      Guts of the test
-----------------------------*/

main(argc,argv)
int argc;
char **argv;
{
   int               sts;             
   int               x_print, print, paus, c;
   OM_S_OBJID        objid[NUMOBJS];
   OM_S_OBJID        os_objid;
   OMuword           osnum;
   static char       *osname = "/usr/tmp/osvar0";
   static char       array[] = { 'c', 's', 'f', 'i' };
   int               ii,jj,kk;
   int               iterations;
   OM_S_MESSAGE      delete_msg,init_msg, verify_msg, set_msg;

   struct OM_sd_delete_args
   {
      int flag;
   } delete_args;

   struct OM_sd_set_args
   {
      int array;
      int dim;
   } set_args;

   /*---------------------------------------------------*/  
   /*  Get the command line arguments and/or defaults.  */
   /*---------------------------------------------------*/

   print = argc > 1?atoi(argv[1]):0;
   x_print = argc > 2?atoi(argv[2]):0;

   iterations = (iterations=(iterations=argc>3?atoi(argv[3]):DEFIT)>MAXIT?DEFIT:iterations)<0?DEFIT:iterations;

   paus = argc > 4?atoi(argv[4]):0;

   /*-------------------------------------*/
   /*  Initialize OM and begin the test.  */
   /*-------------------------------------*/

   if (print) 
      printf("\nVariable length array test:\n");
   if (x_print)
      printf("\to iterations = %d\n",iterations);
   if (print) 
      printf("!!!!! Runtime initialization !!!!!\n");
   sts = om$runtime_init();
   if (!(1&sts)) 
      error(sts,"runtime init\n");

   sts = om$make_message(classname = "Root",
                         methodname = "delete",
                         p_arglist = &delete_args,
                         size = sizeof(struct OM_sd_delete_args),
                         p_msg = &delete_msg);
   if (!(1&sts))
      error(sts,"make message for delete \n");

   delete_args.flag = TRUE;

   /*---------------------------------------------------------------*/
   /*  Remove any object space generated from a previous execution  */
   /*  of this test.                                                */
   /*---------------------------------------------------------------*/

   unlink(osname);
   

   if (print) 
      printf("!!!!! Constructing object space %s !!!!!\n",osname);
   sts = om$construct_os(classname="OMFiledOS",
                         p_objid=&os_objid,
                         osnum=&osnum,
                         osname=osname);
   if (!(1&sts))
      error(sts,"construct os");
   if (x_print)
      printf("\to osnum = %d, os_objid = %d\n",osnum,os_objid);


   if (print) 
      printf("!!!!! Constructing objects !!!!!\n");
   for (ii=0; ii < NUMOBJS; ++ii)
   {
      sts = om$construct(classname="vla",
                         p_objid=&objid[ii],
                         osnum=osnum);
      if (!(1&sts)) 
         error(sts,"construct objid[%d]\n",ii);
      if (x_print)
         printf("\to objid[%d]=%d\n",ii,objid[ii]);
   }

   if (print)
      printf("!!!!! Initial set up !!!!!\n");
   sts = om$make_message(classname="vla",
                         methodname="init",
                         p_msg=&init_msg);
   if (!(1&sts))
      error(sts,"make message init\n");
   for (ii=0; ii < NUMOBJS; ++ii)
   {
      sts = om$send(msg = &init_msg,
                    senderid=NULL_OBJID,
                    targetid = objid[ii],
                    targetos = osnum);
      if (!(1&sts)) 
         error(sts,"send init_msg objid[%d]\n",ii);
   }


   sts = om$make_message(classname="vla",
                         methodname="verify",
                         p_msg=&verify_msg);
   if (!(1&sts))
      error(sts,"make message verify\n");

   verify_data();

   sts = om$make_message(classname="vla",
                         methodname="set",
                         p_arglist=&set_args,
                         size=sizeof(struct OM_sd_set_args),
                         p_msg=&set_msg);
   if (!(1&sts))
      error(sts,"make message set\n");


   if (print)
      printf("!!!!! Inrigger test 1 !!!!!\n");

   if (x_print)
      printf("\to array at end of object\n");

   set_args.dim = 4;
   set_args.array = ARRAY_I;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting smaller at end\n");

   verify_data();
   write_read_os();
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 2 !!!!!\n");
   set_args.dim = 0;
   set_args.array = ARRAY_I;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array set to zero at end\n");

   verify_data();
   write_read_os();
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 3 !!!!!\n");
   set_args.dim = 6;
   set_args.array = ARRAY_S;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting smaller not at end\n");

   set_args.dim = 7;
   set_args.array = ARRAY_F;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting larger at end with free space\n");

   verify_data();
   write_read_os();
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 4 !!!!!\n");
   set_args.dim = 4;
   set_args.array = ARRAY_S;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting smaller second time not at end\n");

   set_args.dim = 12;
   set_args.array = ARRAY_F;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting larger at end without enough free space\n");

   verify_data();
   write_read_os();
   verify_data();

   if (print)
      printf("!!!!! Deleting object !!!!!\n");
   if (x_print)
      printf("\to old objid[%d]=%d\n",0,objid[0]);

   sts = om$send(msg=&delete_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"deleting objid[%d]=%d\n",0,objid[0]);

   
   if (print) 
      printf("!!!!! Constructing object !!!!!\n");

   sts = om$construct(classname="vla",
                      p_objid=&objid[0],
                      msg=&init_msg,
                      osnum=osnum);
   if (!(1&sts)) 
      error(sts,"construct objid[%d]\n",0);
   if (x_print)
      printf("\to objid[%d]=%d\n",0,objid[0]);

   verify_data();
   write_read_os();
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 5 !!!!!\n");
   if (x_print)
      printf("\to array not at end of object\n");
   set_args.dim = 14;
   set_args.array = ARRAY_S;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting larger with no free space\n");

   
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 6 !!!!!\n");
   set_args.dim = 25;
   set_args.array = ARRAY_C;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting larger with free space behind\n");

   
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 7 !!!!!\n");
   set_args.dim = 7;
   set_args.array = ARRAY_F;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting larger with free space in front\n");

   
   verify_data();

   if (print)
      printf("!!!!! Inrigger test 8 !!!!!\n");
   set_args.dim = 10;
   set_args.array = ARRAY_C;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting smaller without compression\n");

   verify_data();

   if (print)
      printf("!!!!! Inrigger test 9 !!!!!\n");

   OM_Gi_min_free_space = 10;

   set_args.dim = 5;
   set_args.array = ARRAY_C;

   sts = om$send(msg=&set_msg,
                 targetid=objid[0],
                 targetos=osnum,
                 senderid=NULL_OBJID);
   if (!(1&sts))
      error(sts,"array getting smaller with compression\n");

   verify_data();

   OM_Gi_min_free_space = 64;
   write_read_os();
   verify_data();

   
   if (print)
      printf("!!!!! Outrigger test !!!!!\n");

   if (x_print)
      printf("\to setting dimension to zero ...\n");

   set_args.dim = 0;
   
   for (ii=0; ii < NUMOBJS; ++ii)
   {
      set_args.array = ARRAY_C;
      sts = om$send(msg=&set_msg,
                    senderid=NULL_OBJID,
                    targetid=objid[ii],
                    targetos=osnum);
      if (!(1&sts))
         error(sts,"send set_msg objid[%d], array c\n",ii);

      set_args.array = ARRAY_S;
      sts = om$send(msg=&set_msg,
                    senderid=NULL_OBJID,
                    targetid=objid[ii],
                    targetos=osnum);
      if (!(1&sts))
         error(sts,"send set_msg objid[%d], array s\n",ii);


      set_args.array = ARRAY_F;
      sts = om$send(msg=&set_msg,
                    senderid=NULL_OBJID,
                    targetid=objid[ii],
                    targetos=osnum);
      if (!(1&sts))
         error(sts,"send set_msg objid[%d], array f\n",ii);

      set_args.array = ARRAY_I;
      sts = om$send(msg=&set_msg,
                    senderid=NULL_OBJID,
                    targetid=objid[ii],
                    targetos=osnum);
      if (!(1&sts))
         error(sts,"send set_msg objid[%d], array i\n");
   }

   if (x_print)
   {
      printf("\to forward dimensioning ...\n\n");
      printf("\t\tobjid\tarray\tdimension\n");
      printf("\t\t-------------------------\n");
   }
   
   for (set_args.array=0,ii=0; ii < iterations; ++ii, ++set_args.array)
   {
      set_args.dim = ((ii%5)?ii:0);
      set_args.array = ((set_args.array==4)?0:set_args.array);

      for (jj=0; jj < NUMOBJS; ++jj)
      {
         sts = om$send(msg = &set_msg,
                       senderid = NULL_OBJID,
                       targetid = objid[jj],
                       targetos = osnum);
         if (!(1&sts)) 
            error(sts,"forward loop:send objid[%d], array %d, dim=%d, ii=%d\n",
                      jj,set_args.array,set_args.dim,ii);
         if (x_print)
            printf("\t\t  %d\t  %c\t  %d\n",
                    objid[jj],array[set_args.array],set_args.dim);
      }

      for (jj=0; jj < NUMOBJS; ++jj)
      {
         sts = om$send(msg = &verify_msg,
                       senderid = NULL_OBJID,
                       targetid = objid[jj],
                       targetos = osnum);
         if (!(1&sts)) 
            error(sts,"forward loop:verifying objid[%d], array %d, ii=%d\n",
                      jj,set_args.array,ii);
      }

   }


   if (x_print)
   {
      printf("\n\to backward dimensioning ...\n\n");
      printf("\t\tobjid\tarray\tdimension\n");
      printf("\t\t-------------------------\n");
   }

   for (set_args.array=0,ii=iterations; ii >= 0; --ii, ++set_args.array)
   {
      set_args.dim = ((ii%5)?ii:0);
      set_args.array = ((set_args.array==4)?0:set_args.array);

      for (jj=0; jj < NUMOBJS; ++jj)
      {
         sts = om$send(msg = &set_msg,
                       senderid = NULL_OBJID,
                       targetid = objid[jj],
                       targetos = osnum);
         if (!(1&sts)) 
            error(sts,"forward loop:send objid[%d], array %d, dim=%d, ii=%d\n",
                      jj,set_args.array,set_args.dim,ii);
         if (x_print)
            printf("\t\t  %d\t  %c\t  %d\n",
                    objid[jj],array[set_args.array],set_args.dim);
      }

      for (jj=0; jj < NUMOBJS; ++jj)
      {
         sts = om$send(msg = &verify_msg,
                       senderid = NULL_OBJID,
                       targetid = objid[jj],
                       targetos = osnum);
         if (!(1&sts)) 
            error(sts,"forward loop:verifying objid[%d], array %d, ii=%d\n",
                      jj,set_args.array,ii);
      }

   }

   write_read_os();
   verify_data();

   if (print)
      printf("Test completed.\n\n");

}

