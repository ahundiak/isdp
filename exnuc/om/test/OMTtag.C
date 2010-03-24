#include <stdio.h>
#include <varargs.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMtags.h"

#define NUMOS 7
#define MAXNUMOBJS 2000

#define SEND_DEBUG_TAGCON() \
   { \
      for ( ii=1; ii<NUMOS; ii++ ) \
      { \
         if ((OM_GA_p_tagcon) && (OM_GA_p_tagcon[osnum[ii]])) \
         { \
            p_tc_link = OM_GA_p_tagcon[osnum[ii]]; \
            while ( p_tc_link ) \
            { \
               printf("\nSending debug msg to TagCon oid %d in OS %d\n", \
                       p_tc_link->objid, osnum[ii]); \
               sts = om$send ( msg = &TCdbg, \
                               senderid = p_tc_link->objid, \
                               targetid = p_tc_link->objid, \
                               targetos = osnum[ii] ); \
               if (!(1&sts)) \
                  error(sts,"error in TagCon.debug msg\n"); \
               p_tc_link = p_tc_link->next; \
            } \
         } \
         else \
         { \
            printf ("OM_GA_p_tagcon value is invalid for OS %d\n",ii); \
         } \
      } \
   }

/*-----------------------------------------------------------------------
   Tagged object test.  Three command line parameters:  

   parameter 1:  Controls printing of major headings.  If TRUE print, else
                 do not print.

   parameter 2:  Controls printing of iteration data.  If TRUE print, else
                 do not print.

   parameter 3:  Specifies the half the number of objects to constructed in 
                 each object space.  Half of the objects are tagged, the
                 other half are not.  (150 <= x <= 2000)
--------------------------------------------------------------------------*/

static void error(sts, format, args)
int sts;
char *format;
int args;
{
   fprintf(stderr,"error!!!  ");
   vfprintf(stderr,format,&args);
   
   if (sts)
      om$report_error(sts=sts);

   exit(1);
}

main(argc,argv)
int argc;
char **argv;
{
   int               sts;             
   int               x_print_flag, print_flag;
   OM_S_OBJID        Aobjid[NUMOS][MAXNUMOBJS];
   OM_S_OBJID        Bobjid[NUMOS][MAXNUMOBJS];
   OMuint            Atag[NUMOS][MAXNUMOBJS];
   OMuword           version[NUMOS][MAXNUMOBJS];
   OM_S_OBJID        os_objid[NUMOS];
   OMuword           osnum[NUMOS];
   static char       *osname[NUMOS] = { "/usr/tmp/os0",
                                        "/usr/tmp/os1",
                                        "/usr/tmp/os2",
                                        "/usr/tmp/os3",
                                        "/usr/tmp/os4",
                                        "/usr/tmp/os5",
                                        "/usr/tmp/os6" };
   int               ii,jj,kk,numobjs;
   OMuint            test_tag;
   OM_S_OBJID        test_objid;
   OM_S_CHANSELECT   csel0,csel1,csel2;
   OM_S_MESSAGE      delete_msg;
   OMuword           test_osnum;
   OM_S_CHANSELECT   a_csel,b_csel,b_csel2;
   OM_S_MESSAGE      root_conn, Bcnt, TCdbg, OSdel, root_dis, root_move,
                     root_copy;
   OM_p_TAGCON_LINK  p_tc_link;
   OMuint            my_cnt, *p_my_cnt=&my_cnt;
   OMuword           tag_version, tagcon_version;
   
   struct OM_sd_con_args 
   {
      OM_S_CHANSELECT to_csel;
      int             to_idx;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_csel;
      int             fr_idx;
   } con_args;

   struct OM_sd_dis_args
   {
      OM_S_CHANSELECT to_csel;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_csel;
   } dis_args;

   struct OM_sd_move_args
   {
      OM_S_CHANSELECT to_csel;
      OM_S_OBJID      fr_objid;
      OMuword         fr_os;
      OM_S_CHANSELECT fr_csel;
   } move_args;

   struct OM_sd_delete_args
   {
      int flag;
   } delete_args;


   /*---------------------------------------------------*/  
   /*  Get the command line arguments and/or defaults.  */
   /*---------------------------------------------------*/

   print_flag = argc > 1?atoi(argv[1]):0;
   x_print_flag = argc > 2?atoi(argv[2]):0;

   numobjs = 
      (numobjs=argc>3?atoi(argv[3]):150)<= MAXNUMOBJS?numobjs:MAXNUMOBJS;


   /*-------------------------------------*/
   /*  Initialize OM and begin the test.  */
   /*-------------------------------------*/

   if (print_flag) printf("\nTagged object test:\n");
   if (print_flag) printf("runtime initialization ...\n");
   sts = om$runtime_init();
   if (!(1&sts)) error(sts,"runtime init\n");
   if (print_flag) printf(" complete.\n");

   /*----------------------------------------------------------------*/
   /*  Remove any object spaces generated from a previous execution  */
   /*  of this test.                                                 */
   /*----------------------------------------------------------------*/

   for (ii=0; ii < NUMOS; ++ii)
      unlink(osname[ii]);

   /*------------------*/
   /*  Enable tagging  */
   /*------------------*/

   om$enable_tagging ( flag = 1 );
   
   /*---------------------------------------------*/
   /*  Construct object spaces and test objects.  */
   /*---------------------------------------------*/

   if (print_flag) 
      printf("!!!!! Before constructing (%d) object spaces !!!!!\n",NUMOS);

   for (ii=0; ii < NUMOS; ++ii)
   {
      sts = om$construct_os(classname="OMFiledOS",
                            p_objid=&os_objid[ii],
                            osnum=&osnum[ii],
                            osname=osname[ii]);
      if (!(1&sts))
         error(sts,"construct os, ii=%d\n",ii);

      if (x_print_flag)
         printf("\tosnum = %d, os_objid = %d\n",osnum[ii],os_objid[ii]);
   }

   if (print_flag) 
      printf("!!!!! Before constructing (%d) objects in each os !!!!!\n",
              numobjs*2);

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$construct(classname="A",
                            p_objid=&Aobjid[ii][jj],
                            osnum=osnum[ii],
                            p_tag=&Atag[ii][jj]);
         if (!(1&sts))
            error(sts,"construct object class A, ii=%d, jj=%d\n",ii,jj);

         if (x_print_flag)
            printf("\tclass A in osnum %d, objid=%d, tag=%d\n",
                    osnum[ii],Aobjid[ii][jj],Atag[ii][jj]);  

         sts = om$tag_to_objid(osnum=osnum[ii],
                               tag=Atag[ii][jj],
                               p_objid=&test_objid);
         if (!(1&sts))
            error(sts,"tag to objid,ii=%d,jj=%d, tag=%d\n",ii,jj,Atag[ii][jj]);

         if (! IF_EQ_OBJID(test_objid, Aobjid[ii][jj]))
            error(0,"objid mismatch,test_objid=%d, Aobjid[%d][%d]=%d\n",
                    test_objid,ii,jj,Aobjid[ii][jj]);

         sts = om$construct(classname="B",
                            p_objid=&Bobjid[ii][jj],
                            osnum=osnum[ii]);
         if (!(1&sts))
            error(sts,"construct object class B, ii=%d, jj=%d\n",ii,jj);

         if (x_print_flag)
            printf("\tclass B in osnum %d, objid=%d\n",
               osnum[ii],Bobjid[ii][jj]);  
      }
 
   if (print_flag) 
      printf("!!!!! Before comparing objid to tag !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_tag=&test_tag);
         if (!(1&sts))
            error(sts,"objid to tag:os=%d, objid=%d\n",
               osnum[ii],Aobjid[ii][jj]);
       
         if (test_tag != Atag[ii][jj])
            error(0,"tag mismatch:ii=%d,jj=%d, test_tag=%d, Atag[%d][%d]=%d\n",
                   ii,jj,test_tag,ii,jj,Atag[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before move tags !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs/2; ++jj)
      {
         sts = om$remove_tag(osnum=osnum[ii],
                             objid=Aobjid[ii][jj]);

         if (!(1&sts))
            error(sts,"remove tag, ii=%d, jj=%d\n",ii,jj);
      }

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=numobjs/2; jj < ((numobjs/2)*2)-1; ++jj)
      {
         sts = om$move_tag(osnum=osnum[ii],
                           old_objid=Aobjid[ii][jj],
                           new_objid=Aobjid[ii][jj-(numobjs/2)]);

         if (!(1&sts))
            error:(sts,"move tag, ii=%d, jj=%d\n",ii,jj);

         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_tag=&test_tag);

         if (sts != OM_W_NOTTAGGED)
            error(sts,"objid to tag :os=%d, objid=%d\n",osnum[ii],
                   Aobjid[ii][jj]);
       
         Atag[ii][jj-(numobjs/2)] = Atag[ii][jj];

      }

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=(numobjs/2)-1; jj < ((numobjs/2)*2)-1; ++jj)
      {
         sts = om$add_tag(osnum=osnum[ii],
                          objid=Aobjid[ii][jj],
                          p_tag=&Atag[ii][jj]);

         if (!(1&sts))
            error(sts,"adding tags, ii=%d, jj=%d\n",ii,jj);
      }

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_tag=&test_tag);

         if (!(1&sts))
            error(sts,"after adding tags, ii=%d, jj=%d, os=%d, objid=%d\n",
                   ii,jj,osnum[ii],Aobjid[ii][jj]);

         if (test_tag != Atag[ii][jj])
            error(0,"tag mismatch:ii=%d,jj=%d, test_tag=%d, Atag[%d][%d]=%d\n",
                   ii,jj,test_tag,ii,jj,Atag[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before remove tags !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$remove_tag(osnum=osnum[ii],
                             objid=Aobjid[ii][jj]);

         if (!(1&sts))
            error(sts,"remove tag 1, ii=%d, jj=%d\n",ii,jj);

         if (x_print_flag)
            printf("\tremoved tag in osnum %d, objid %d\n",
                   osnum[ii],Aobjid[ii][jj]);

         sts = om$objid_to_tag(osnum=osnum[ii],
                               p_tag=&test_tag, 
                               objid=Aobjid[ii][jj]);

         if (sts != OM_W_NOTTAGGED)
            error(sts,"after remove tag 1, ii=%d, jj=%d\n",ii,jj);
      }

   if (print_flag) 
      printf("!!!!! Before adding tags !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$add_tag(osnum=osnum[ii],
                          objid=Aobjid[ii][jj],
                          p_tag=&Atag[ii][jj]);
         if (!(1&sts))
            error(sts,"adding tags, ii=%d, jj=%d\n",ii,jj);
      }
          
   if (print_flag) 
      printf("!!!!! Before comparing objid to tag !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_tag=&test_tag);

         if (!(1&sts))
            error(sts,"after adding tags, ii=%d, jj=%d, os=%d, objid=%d\n",
                   ii,jj,osnum[ii],Aobjid[ii][jj]);

         if (test_tag != Atag[ii][jj])
            error(0,"tag mismatch:ii=%d,jj=%d, test_tag=%d, Atag[%d][%d]=%d\n",
                   ii,jj,test_tag,ii,jj,Atag[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before remove tags 2 !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs/2; ++jj)
      {
         sts = om$remove_tag(osnum=osnum[ii],
                             objid=Aobjid[ii][jj]);

         if (!(1&sts))
            error(sts,"remove tag 2, ii=%d, jj=%d\n",ii,jj);

         if (x_print_flag)
            printf("\tremoved tag in osnum %d, objid %d\n",
                   osnum[ii],Aobjid[ii][jj]);

         sts = om$objid_to_tag(osnum=osnum[ii],
                               p_tag=&test_tag, 
                               objid=Aobjid[ii][jj]);

         if (sts != OM_W_NOTTAGGED)
            error(sts,"after remove tag 2, ii=%d, jj=%d\n",ii,jj);
      }

   if (print_flag) 
      printf("!!!!! Before converting tag to objid !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$tag_to_objid(osnum=osnum[ii],
                               tag=Atag[ii][jj],
                               p_objid=&test_objid);
         if (!(1&sts))
         {
            if (jj < numobjs/2)
            {
               if (sts != OM_E_NOSUCHTAG)
                  error(sts,"tag to objid, should be no tag ii=%d, jj=%d\n"
                         ,ii,jj);
            }
            else
            {
               error(sts,"tag to objid,ii=%d, jj=%d, tag=%d\n",ii,jj,
                     Atag[ii][jj]);
            }
         }
         else
         {
            if (! IF_EQ_OBJID(test_objid, Aobjid[ii][jj]))
               error(0,"objid mismatch,test_objid=%d, Aobjid[%d][%d]=%d\n",
                       test_objid,ii,jj,Aobjid[ii][jj]);
         }
      }

   if (print_flag) 
      printf("!!!!! Before adding tags 2 !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs/2; ++jj)
      {
         sts = om$add_tag(osnum=osnum[ii],
                          objid=Aobjid[ii][jj],
                          p_tag=&Atag[ii][jj]);

         if (!(1&sts))
            error(sts,"adding tags 2, ii=%d, jj=%d\n",ii,jj);
      }
          
   if (print_flag) 
      printf("!!!!! Before comparing objid to tag !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_version=&version[ii][jj],
                               p_tag=&test_tag);

         if (!(1&sts))
            error(sts,"after adding tags 2:ii=%d, jj=%d, os=%d, objid=%d\n"
                   ,ii,jj,osnum[ii],Aobjid[ii][jj]);

         if (test_tag != Atag[ii][jj])
            error(0,"tag mismatch:ii=%d,jj=%d, test_tag=%d, Atag[%d][%d]=%d\n",
                   ii,jj,test_tag,ii,jj,Atag[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before changing tag versions !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         OMuword test_version;

         sts = om$change_tag_version(osnum=osnum[ii],
                                     objid=Aobjid[ii][jj]);
         if (!(1&sts))
            error(sts,"after changing version:ii=%d, jj=%d, os=%d, objid=%d\n"
                   ,ii,jj,osnum[ii],Aobjid[ii][jj]);

         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_version=&test_version,
                               p_tag=NULL);

         if (!(1&sts))
            error(sts,"after objid to tag:ii=%d, jj=%d, os=%d, objid=%d\n"
                   ,ii,jj,osnum[ii],Aobjid[ii][jj]);

         if (test_version != version[ii][jj]+1)
            error(0,"version mismatch: ii=%d, jj=%d, test_version=%d, version[%d][%d]=%d\n",ii,jj,test_version,ii,jj,version[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before converting tag to objid 2 !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$tag_to_objid(osnum=osnum[ii],
                               tag=Atag[ii][jj],
                               p_objid=&test_objid);
         if (!(1&sts))
            error(sts,"tag to objid,ii=%d, jj=%d, tag=%d\n",
                   ii,jj,Atag[ii][jj]);

         if (! IF_EQ_OBJID(test_objid, Aobjid[ii][jj]))
            error(0,"objid mismatch,test_objid=%d, Aobjid[%d][%d]=%d\n",
                    test_objid,ii,jj,Aobjid[ii][jj]);
      }

   if (print_flag)
      printf("!!!!! Before deleting (writing) all object spaces !!!!!\n");

   sts = om$make_message(classname = "Root",
                         methodname = "delete",
                         p_arglist = &delete_args,
                         size = sizeof(struct OM_sd_delete_args),
                         p_msg = &delete_msg);
   if (!(1&sts))
      error(sts,"make message for delete os\n");

   delete_args.flag = TRUE;

   for (ii=0; ii < NUMOS; ++ii)
   {
      sts = om$send(msg = &delete_msg,
                    targetid = os_objid[ii],
                    targetos = osnum[ii],
                    senderid = NULL_OBJID);

      if (!(1&sts))
         error(sts,"deleting object spaces, ii=%d, osnum=%d, oid=%d\n",ii,
               osnum[ii],os_objid[ii]);
   }
   
   if (print_flag) 
      printf("!!!!! Before constructing (loading) all object spaces !!!!!\n",
              NUMOS);

   for (ii=0; ii < NUMOS; ++ii)
   {
      sts = om$construct_os(classname="OMFiledOS",
                            p_objid=&os_objid[ii],
                            osnum=&osnum[ii],
                            osname=osname[ii]);
      if (!(1&sts))
         error(sts,"construct os, ii=%d\n",ii);

      if (x_print_flag)
         printf("\tosnum = %d, os_objid = %d\n",osnum[ii],os_objid[ii]);
   }

   if (print_flag)
      printf("!!!!! Before converting tag to objid !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$tag_to_objid(osnum=osnum[ii],
                               tag=Atag[ii][jj],
                               p_objid=&test_objid);
         if (!(1&sts))
            error(sts,"tag to objid,ii=%d,jj=%d, tag=%d\n",ii,jj,Atag[ii][jj]);

         if (! IF_EQ_OBJID(test_objid, Aobjid[ii][jj]))
            error(0,"objid mismatch,test_objid=%d, Aobjid[%d][%d]=%d\n",
                    test_objid,ii,jj,Aobjid[ii][jj]);
      }

   if (print_flag) 
      printf("!!!!! Before remove tags 3 !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs/2; ++jj)
      {
         sts = om$remove_tag(osnum=osnum[ii],
                             objid=Aobjid[ii][jj]);

         if (!(1&sts))
            error(sts,"remove tag 3, ii=%d, jj=%d\n",ii,jj);

         if (x_print_flag)
            printf("\tremoved tag in osnum %d, objid %d\n",
                   osnum[ii],Aobjid[ii][jj]);

         sts = om$objid_to_tag(osnum=osnum[ii],
                               p_tag=&test_tag, 
                               objid=Aobjid[ii][jj]);

         if (sts != OM_W_NOTTAGGED)
            error(sts,"after remove tag 3, ii=%d, jj=%d\n",ii,jj);
      }

   if (print_flag) 
      printf("!!!!! Before converting tag to objid !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$tag_to_objid(osnum=osnum[ii],
                               tag=Atag[ii][jj],
                               p_objid=&test_objid);
         if (!(1&sts))
         {
            if (jj < numobjs/2)
            {
               if (sts != OM_E_NOSUCHTAG)
                  error(sts,"tag to objid, should be no tag ii=%d, jj=%d\n"
                         ,ii,jj);
            }
            else
            {
               error(sts,"tag to objid,ii=%d, jj=%d, tag=%d\n",ii,jj,
                     Atag[ii][jj]);
            }
         }
         else
         {
            if (! IF_EQ_OBJID(test_objid, Aobjid[ii][jj]))
               error(0,"objid mismatch,test_objid=%d, Aobjid[%d][%d]=%d\n",
                       test_objid,ii,jj,Aobjid[ii][jj]);
         }
      }

   if (print_flag) 
      printf("!!!!! Before adding tags 3 !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs/2; ++jj)
      {
         sts = om$add_tag(osnum=osnum[ii],
                          objid=Aobjid[ii][jj],
                          p_tag=&Atag[ii][jj]);

         if (!(1&sts))
            error(sts,"adding tags 3, ii=%d, jj=%d\n",ii,jj);
      }
          
   if (print_flag) 
      printf("!!!!! Before comparing objid to tag !!!!!\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < numobjs; ++jj)
      {
         sts = om$objid_to_tag(osnum=osnum[ii],
                               objid=Aobjid[ii][jj],
                               p_version=&version[ii][jj],
                               p_tag=&test_tag);

         if (!(1&sts))
            error(sts,"after adding tags 3:ii=%d, jj=%d, os=%d, objid=%d\n"
                   ,ii,jj,osnum[ii],Aobjid[ii][jj]);

         if (test_tag != Atag[ii][jj])
            error(0,"tag mismatch:ii=%d,jj=%d, test_tag=%d, Atag[%d][%d]=%d\n",
                   ii,jj,test_tag,ii,jj,Atag[ii][jj]);
      }

   /*===========================*/
   /*===========================*/
   /*  START OF TagCon TESTING  */
   /*===========================*/
   /*===========================*/

   OM_Gw_tagcon_inc = 10;

   if (print_flag)
      printf("!!!!! Before connecting A[0]'s with B's in other OS's !!!!!\n");

   if (print_flag)
      printf("!!!!! OM_Gw_tagcon_inc value is %d !!!!!\n",OM_Gw_tagcon_inc);

   om$enable_tag_connects ( flag = 1 );

   sts = om$set_tag_os ( p_prev_osnum = &test_osnum,
                         osnum = osnum[0] );
   if (!(1&sts))
      error(sts,"set_tag_os failure for OS[0]\n");

   a_csel.type = OM_e_num;
   om$get_channel_number ( channame = "A.acb",
                           p_channum = &a_csel.u_sel.number);

   b_csel.type = OM_e_num;
   om$get_channel_number ( channame = "B.bca", 
                           p_channum = &b_csel.u_sel.number);

   b_csel2.type = OM_e_num;
   om$get_channel_number ( channame = "B.bcca", 
                           p_channum = &b_csel2.u_sel.number);

   sts = om$make_message ( classname = "Root",
                           methodname = "connect",
                           size = sizeof(struct OM_sd_con_args),
                           p_arglist = &con_args,
                           p_msg = &root_conn );
   if (!(1&sts))
      error(sts,"make message for Root.connect failed\n");

   con_args.fr_os   = osnum[0];
   con_args.fr_idx  = OM_K_MAXINT;
   con_args.fr_csel = a_csel;
   con_args.to_csel = b_csel;
   con_args.to_idx  = OM_K_MAXINT;
   
   /*==========================================================*/
   /*  Connect loop to connect A[0]'s to B[1]'s thru B[NUMOS]  */
   /*==========================================================*/

   for (ii=1; ii<NUMOS; ii++)
   {
      for (jj=0; jj<numobjs; jj++)
      {
         if (x_print_flag)
            printf("   connecting A[0][%d] to B[%d][%d]\n",jj,ii,jj);

         con_args.fr_objid = Aobjid[0][jj];

         sts = om$send ( msg = &root_conn,
                         senderid = Aobjid[0][jj],
                         targetid = Bobjid[ii][jj],
                         targetos = osnum[ii] );
         if (!(1&sts))
            error(sts,"failed to connect A[0][%d] to B[%d][%d]\n",jj,ii,jj);
      }
   }


   sts = om$make_message ( classname = "OMTagCon",
                           methodname = "debug",
                           p_msg = &TCdbg );
   if (!(1&sts))
      error(sts,"error from make message of TC.dbg\n");


   if (x_print_flag) 
   {
      SEND_DEBUG_TAGCON();
   }

   sts = om$make_message ( classname = "B",
                           methodname = "cnt",
                           size = 4,
                           p_arglist = &p_my_cnt,
                           p_msg = &Bcnt );
   if (!(1&sts))
      error(sts,"error from make message for B.cnt\n");

   if (print_flag)
      printf ("!!!!! Validate count of objects connected to A's !!!!!\n");

   my_cnt = 0;
   for (ii=0; ii<numobjs; ii++)
   {
      sts = om$send ( msg = &Bcnt,
                      senderid = Aobjid[0][ii],
                      p_chanselect = &a_csel,
                      targetos = osnum[0] );
      if (!(1&sts))
         error(sts,"error from channel send of B.cnt from A[0][%d]\n",ii);
   }

   if ( my_cnt != (NUMOS-1)*numobjs )
      error(sts,"****** count invalid, got %d expected %d\n",my_cnt,
             (NUMOS-1)*numobjs);

   if (print_flag) 
      printf("!!!!! Testing for broken or mismatched connects !!!!!\n");

   for (ii=1; ii<NUMOS; ii++)
   {
      sts = om$broken_connects ( osnum = osnum[ii],
                                 tagged_osnum = osnum[0],
                                 p_count = &my_cnt );
      if (!(1&sts))
         error(sts,"error in om$broken_connects for count\n");

      if ( my_cnt )
      {
         printf ("*** count of broken connects invlaid: got %d expected 0\n",
                 my_cnt);
      }

      sts = om$mismatched_connections ( osnum = osnum[ii],
                                 tagged_osnum = osnum[0],
                                 p_count = &my_cnt );
      if (!(1&sts))
         error(sts,"error in om$mismatched_connections for count\n");

      if ( my_cnt )
      {
         printf ("*** invalid mismatched connect count: got %d expected 0\n",
                 my_cnt);
      }

      for (jj=0; jj<numobjs; jj++)
      {
         sts = om$test_connection ( osnum = osnum[ii],
                                    objid = Bobjid[ii][jj],
                                    p_chanselect = &b_csel,
                                    tag_osnum = osnum[0],
                                    tag_objid = Aobjid[0][jj],
                                    p_tag_chanselect = &a_csel,
                                    p_tag_version = &tag_version,
                                    p_tag_connect_version = &tagcon_version,
                                    force_flag = 0 );
         if (!(1&sts)) 
            error(sts,"error in om$test_connection for B[%d][%d]\n",ii,jj);

         if ( tag_version != tagcon_version )
            printf ("**** version mismatch om$test_connection for B[%d][%d]\n",
            ii,jj);
      }
   }

   if (print_flag)
      printf ("!!!!! Deleting OS2 !!!!!\n");

   sts = om$make_message ( classname = "OMFiledOS",
                           methodname = "delete",
                           p_msg = &OSdel );
   if (!(1&sts))
      error(sts,"error from make message for OMFiledOS.delete\n");

   sts = om$send ( msg = &OSdel,
                   senderid = os_objid[2],
                   targetid = os_objid[2],
                   targetos = osnum[2] );
   if (!(1&sts))
      error(sts,"could not delete OS2\n");

   if (print_flag)
      printf ("!!!!! Validate count of objects connected to A's !!!!!\n");

   my_cnt = 0;
   for (ii=0; ii<numobjs; ii++)
   {
      sts = om$send ( msg = &Bcnt,
                      senderid = Aobjid[0][ii],
                      p_chanselect = &a_csel,
                      targetos = osnum[0] );
      if (!(1&sts) && (sts != OM_W_OSNOTACTIVE))
         error(sts,"error from channel send of B.cnt from A[0][%d]\n",ii);
   }

   if ( my_cnt != numobjs*(NUMOS-2) )
      error(sts,"****** count invalid, got %d expected %d\n",my_cnt,
               numobjs*(NUMOS-2));

   if (print_flag)
      printf ("!!!!! Reconstructing OS2 to test TagCon reconnect !!!!!\n");

   sts = om$construct_os(classname="OMFiledOS",
                         p_objid=&os_objid[2],
                         osnum=&osnum[2],
                         osname=osname[2]);
   if (!(1&sts))
      error(sts,"construct os failed for OS2\n");

   if (print_flag)
      printf ("!!!!! Validate count of objects connected to A's !!!!!\n");

   my_cnt = 0;
   for (ii=0; ii<numobjs; ii++)
   {
      sts = om$send ( msg = &Bcnt,
                      senderid = Aobjid[0][ii],
                      p_chanselect = &a_csel,
                      targetos = osnum[0] );
      if (!(1&sts))
         error(sts,"error from channel send of B.cnt from A[0][%d]\n",ii);
   }

   if ( my_cnt != (NUMOS-1)*numobjs )
      error(sts,"****** count invalid, got %d expected %d\n",my_cnt,
           (NUMOS-1)*numobjs);

   if (print_flag)
      printf ("!!!!! Deleting OS0 !!!!!\n");

   sts = om$send ( msg = &OSdel,
                   senderid = os_objid[0],
                   targetid = os_objid[0],
                   targetos = osnum[0] );
   if (!(1&sts))
      error(sts,"could not delete OS0\n");

   if (print_flag)
      printf ("!!!!! Reconstructing OS0 to test Tag side reconnect !!!!!\n");

   sts = om$construct_os(classname="OMFiledOS",
                         p_objid=&os_objid[0],
                         osnum=&osnum[0],
                         osname=osname[0]);
   if (!(1&sts))
      error(sts,"construct os failed for OS0\n");

   if (print_flag)
      printf ("!!!!! Validate count of objects connected to A's !!!!!\n");

   my_cnt = 0;
   for (ii=0; ii<numobjs; ii++)
   {
      sts = om$send ( msg = &Bcnt,
                      senderid = Aobjid[0][ii],
                      p_chanselect = &a_csel,
                      targetos = osnum[0] );
      if (!(1&sts))
         error(sts,"error from channel send of B.cnt from A[0][%d]\n",ii);
   }

   if ( my_cnt != (NUMOS-1)*numobjs )
      error(sts,"****** count invalid, got %d expected %d\n",my_cnt,
            (NUMOS-1)*numobjs);

   if (print_flag)
      printf("!!!!! Disconnecting every 5th object in TagCon OS's !!!!!\n");

   sts = om$make_message ( classname = "Root",
                           methodname = "disconnect",
                           size = sizeof (struct OM_sd_dis_args),
                           p_arglist = &dis_args,
                           p_msg = &root_dis );
   if (!(1&sts))
      error(sts,"make msg fail for Root.disconnect\n");

   dis_args.to_csel = b_csel;
   dis_args.fr_csel = a_csel;
   dis_args.fr_os   = osnum[0];

   for ( ii=1; ii<NUMOS; ii++ )
   {
      for (jj=4; jj<numobjs; jj+=5 )
      {
         dis_args.fr_objid = Aobjid[0][jj];

         if (x_print_flag)
            printf("   disconnecting A[0][%d] to B[%d][%d]\n",jj,ii,jj);

         sts = om$send ( msg = &root_dis,
                         senderid = Aobjid[0][jj],
                         targetid = Bobjid[ii][jj],
                         targetos = osnum[ii] );
         if (!(1&sts))
            error(sts,"disconnect of A[0][%d] and B[%d][%d] fail\n",jj,ii,jj);
      }
   }

   if (x_print_flag)
   {
      SEND_DEBUG_TAGCON();
   }

   if (print_flag)
      printf("!!!!! Reconnecting every 5th pair of objects !!!!!\n");

   con_args.fr_os   = osnum[0];
   con_args.fr_idx  = OM_K_MAXINT;
   con_args.fr_csel = a_csel;
   con_args.to_csel = b_csel;
   con_args.to_idx  = OM_K_MAXINT;
   
   /*=======================================================*/
   /*  Connect loop to connect A[0]'s to B[1]'s and B[2]'s  */
   /*=======================================================*/

   for (ii=1; ii<NUMOS; ii++)
   {
      for (jj=4; jj<numobjs; jj+=5)
      {
         if (x_print_flag)
            printf("   connecting A[0][%d] to B[%d][%d]\n",jj,ii,jj);

         con_args.fr_objid = Aobjid[0][jj];

         sts = om$send ( msg = &root_conn,
                         senderid = Aobjid[0][jj],
                         targetid = Bobjid[ii][jj],
                         targetos = osnum[ii] );
         if (!(1&sts))
            error(sts,"failed to connect A[0][%d] to B[%d][%d]\n",jj,ii,jj);
      }
   }

   if (x_print_flag)
   {
      SEND_DEBUG_TAGCON();
   }

   sts = om$make_message ( classname = "Root",
                           methodname = "move_chan",
                           size = sizeof(struct OM_sd_move_args),
                           p_arglist = &move_args,
                           p_msg = &root_move );
   if (!(1&sts))
      error(sts,"make msg fail for Root.move_chan\n");

   if (print_flag)
      printf("!!!!! Testing move chan for B[1][7] to B[1][8] !!!!!\n");

   move_args.to_csel = b_csel2;
   move_args.fr_objid = Bobjid[1][7];
   move_args.fr_os = osnum[1];
   move_args.fr_csel = b_csel;

   sts = om$send ( msg = &root_move,
                   senderid = Bobjid[1][7],
                   targetid = Bobjid[1][8],
                   targetos = osnum[1] );
   if (!(1&sts))
      error(sts,"move chan fail for B[1][7] to B[1][8](bcca)\n");

   if (x_print_flag)
   {
      SEND_DEBUG_TAGCON();
   }

   if (print_flag)
      printf("!!!!! Testing copy chan for B[2][2] to B[2][3] !!!!!\n");

   sts = om$make_message ( classname = "Root",
                           methodname = "copy_chan",
                           size = sizeof(struct OM_sd_move_args),
                           p_arglist = &move_args,
                           p_msg = &root_copy );
   if (!(1&sts))
      error(sts,"make msg fail for Root.copy_chan\n");

   move_args.to_csel = b_csel2;
   move_args.fr_objid = Bobjid[2][2];
   move_args.fr_os = osnum[2];
   move_args.fr_csel = b_csel;

   sts = om$send ( msg = &root_copy,
                   senderid = Bobjid[2][2],
                   targetid = Bobjid[2][3],
                   targetos = osnum[2] );
   if (!(1&sts))
      error(sts,"copy chan fail for B[2][2] to B[2][3](bcca)\n");

   if (print_flag)
      printf("!!!!! Validate copy chan results !!!!!\n");

   my_cnt = 0;
   for (ii=0; ii<numobjs; ii++)
   {
      sts = om$send ( msg = &Bcnt,
                      senderid = Aobjid[0][ii],
                      p_chanselect = &a_csel,
                      targetos = osnum[0] );
      if (!(1&sts))
         error(sts,"error from channel send of B.cnt from A[0][%d]\n",ii);
   }

   if ( my_cnt != (NUMOS-1)*numobjs+1 )
      error(sts,"**** count invalid, got %d expected %d\n",my_cnt,
             (NUMOS-1)*numobjs+1);

   if (x_print_flag)
   {
      SEND_DEBUG_TAGCON();
   }

   if (print_flag) 
      printf("Test completed.\n\n");   
}

