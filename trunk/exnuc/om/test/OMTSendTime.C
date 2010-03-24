#include <sys/types.h>
#include "OMobjectcomm.h"
#include "OMintprims.h"

#define MAXSEND 100000

EX_error_box(bogus)
int	bogus;
{
return 1;
}

main(argc,argv)
int argc;
char *argv[];
{
   int             sts, i, maxSend, defer=0, a, b, c, g, h, ii, j;
   short           d, e, f;
   u_int           clock(), bef, aft;
   long            diff0, diff5, diff10, diff_loop;
   OMuword         osnum;
   OM_S_OBJID      os_oid, st2_oid, st_oid;
   OM_S_MESSAGE    msg;

   struct sd_d5 {
     int a,b,c; 
     short d;
     int e;
   } d5;
   
   struct sd_d10 {
     int a,b,c; 
     short d,e,f;
     int g,h,ii,j;
   } d10;

   
   if ( argc > 1 ) maxSend = atoi(argv[1]);
   else            maxSend = MAXSEND;

   sts = om$runtime_init();
   if (!(1&sts)) {
      printf("error in runtime_init\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$construct_os ( classname = "OMFiledOS",
                           osname    = "SendTime.os",
                           p_objid   = &os_oid,
                           osnum     = &osnum );
   if (!(1&sts)) {
      printf ("Error from construct OS\n");
      om$report_error(sts=sts);
      exit();
   }

   om$make_current_os ( osnum = osnum );

   sts = om$construct ( classname = "SendTime2",
                        osnum     = osnum,
                        p_objid   = &st2_oid );
   if (!(1&sts)) {
      printf ("Error constructing SendTime2\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$construct ( classname = "SendTime",
                        osnum     = osnum,
                        p_objid   = &st_oid );
   if (!(1&sts)) {
      printf ("Error constructing SendTime (%d)\n",i);
      om$report_error(sts=sts);
      exit();
   }

   /*====================================================*/
   /*  First time the loop so we only report send times  */
   /*====================================================*/

   bef = clock();

   for (i=0; i<maxSend; ++i) {
      sts = i;
   }

   aft = clock();
   diff_loop = aft - bef;

   /*=============================*/
   /*  Start the timer -  0 args  */
   /*=============================*/

   printf ("Sending %d iterations with 0 args...\n",maxSend);

   sts = om$make_message ( classname = "SendTime",
                           methodname = "dummy",
                           p_msg = &msg );
   bef = clock();

   for (i=0; i<maxSend; ++i) {
      sts = om$send ( msg      = &msg,
                      senderid = st2_oid,
                      targetid = st_oid,
                      targetos = osnum );
      if (!(1&sts)) {
         printf ("Error from om$send (iter:%d)\n",i);
         om$report_error(sts=sts);
         exit();
      }
   }

   aft = clock();
   diff0 = aft - bef - diff_loop;

   /*=============================*/
   /*  Start the timer -  5 args  */
   /*=============================*/

   printf ("Sending %d iterations with 5 args...\n",maxSend);

   sts = om$make_message ( classname = "SendTime",
                           methodname = "dummy5",
                           p_arglist = &d5,
                           size = sizeof(struct sd_d5),
                           p_msg = &msg );

   bef = clock();

   for (i=0; i<maxSend; ++i) {
      sts = om$send ( msg      = &msg,
                      senderid = st2_oid,
                      targetid = st_oid,
                      targetos = osnum );
      if (!(1&sts)) {
         printf ("Error from om$send (iter:%d)\n",i);
         om$report_error(sts=sts);
         exit();
      }
   }

   aft = clock();
   diff5 = aft - bef - diff_loop;

   /*=============================*/
   /*  Start the timer - 10 args  */
   /*=============================*/

   printf ("Sending %d iterations with 10 args...\n",maxSend);

   sts = om$make_message ( classname = "SendTime",
                           methodname = "dummy10",
                           p_arglist = &d10,
                           size = sizeof(struct sd_d10),
                           p_msg = &msg );

   bef = clock();

   for (i=0; i<maxSend; ++i) {
      sts = om$send ( msg      = &msg,
                      senderid = st2_oid,
                      targetid = st_oid,
                      targetos = osnum );
      if (!(1&sts)) {
         printf ("Error from om$send (iter:%d)\n",i);
         om$report_error(sts=sts);
         exit();
      }
   }

   aft = clock();
   diff10 = aft - bef - diff_loop;

   /*====================*/
   /*  Report the times  */
   /*====================*/

   printf ("------------------------------------------------------\n");
   printf (" Args  (0)   total %-10ld      per/send %-10.3f\n",
          diff0,(double)diff0/maxSend);
   printf (" Args  (5)   total %-10ld      per/send %-10.3f\n",
          diff5,(double)diff5/maxSend);
   printf (" Args (10)   total %-10ld      per/send %-10.3f\n",
          diff10,(double)diff10/maxSend);
   printf (" All times in microseconds\n");
   printf ("------------------------------------------------------\n");
}
