/*
  DESCRIPTION

  This file includes the definitions of functions that are used for performing
  timing tests throughout the system. The philosophy is simply this:
  There are a number of independent clocks avaialable which can record
  the real-time, user-time and system-time spent. Real-time is the perceived
  time (and should be equivalent to someone physicaly holding a stop-watch
  and counting). The user-time is the amount of time spent by the process
  in the actual application code and system time is the time spent by the
  process while servicing system calls (virtual memory page-swapping, 
  I/O, etc). Note that mallocs are accounted for in user-time.

  At system start-up, all the MAX_CLOCKS are initialized (in EMdpb.wake_up()).
  At any time during the session, one can initialize a given clock (identified
  by it's number), indicating that you want to use that particular clock.
  And then at any time thereafter 'start' and 'stop' the clock just like 
  you would a stopwatch. When you 'print' a particular clock into a FILE 
  (a NULL pointer prints to stderr), the total accumulated between the starts
  and stops is printed. A print does NOT initialize the clock.

  Look at the prototype file PWapi/clock.h for the list of functions in this
  file.


  NOTES

  If a print is issued before a stop is done, a cautionary statement is also
  printed indicating this condition. The times printed in this case will
  include the current time spent since the last start.

  The numbers indicate a 15% accuracy. The units are jiffies (or 60ths of a
  second).
*/
#include <stdio.h>
#ifndef NT
#include <sys/times.h>
#endif
#include "PWminimum.h"

#include "PWapi/clock.h"
#ifndef NT
static PWboolean clock_inuse[MAX_CLOCKS];
static int real_time[MAX_CLOCKS], user_time[MAX_CLOCKS], sys_time[MAX_CLOCKS];
static struct tms tbf1[MAX_CLOCKS], tbf2[MAX_CLOCKS];
static clock_t start_real_time[MAX_CLOCKS];
#endif
void pwInitClocks
(
)
{
  int i;
#ifdef NT
printf("Stubbing pwInitClocks\n");
#else 
  for (i=0; i<MAX_CLOCKS; i++)
  {
    clock_inuse[i] = FALSE;
    real_time[i] = user_time[i] = sys_time[i] = 0;
    tbf1[i].tms_utime = tbf1[i].tms_stime = 0;
    tbf2[i].tms_utime = tbf2[i].tms_stime = 0;
    start_real_time[i] = 0;
  }
 #endif
  return;
}

void pwInitClock
(
  int clock_number
)
{
#ifdef NT
printf("Stubbing pwInitClock\n");
#else 
 
  real_time[clock_number] = 0;
  user_time[clock_number] = 0;
  sys_time[clock_number] = 0;

  clock_inuse[clock_number] = FALSE;
 #endif
  return;
}

void pwStartClock
(
  int clock_number
)
{

#ifdef NT
printf("Stubbing pwStartClock\n");
#else 


  extern clock_t times();

  start_real_time[clock_number] = times (&tbf1[clock_number]);

  clock_inuse[clock_number] = TRUE;

#endif
  return;
}

void pwStopClock
(
  int clock_number
)
{
#ifdef NT
printf("Stubbing pwStopClock\n");
#else 

  extern clock_t times();

  real_time[clock_number] += 
   (int) (times (&tbf2[clock_number]) - start_real_time[clock_number]);
  user_time[clock_number] += 
   tbf2[clock_number].tms_utime - tbf1[clock_number].tms_utime;
  sys_time[clock_number] += 
   tbf2[clock_number].tms_stime - tbf1[clock_number].tms_stime;

  clock_inuse[clock_number] = FALSE;
#endif
  return;
}

void pwPrintClock
(
  FILE *file,
  int clock_number
)
{
#ifdef NT
printf("Stubbing pwPrintClock\n");
#else 

  int rtime, utime, stime;
  struct tms tmp_tbf;

  if (!file)
    file = stderr;

  fprintf (file, "Clock - %d", clock_number);
  if (clock_inuse[clock_number])
  {
    fprintf (file, ", CAUTION: CLOCK STILL RUNNING\n");

    rtime = real_time[clock_number] +
     (int) (times (&tmp_tbf) - start_real_time[clock_number]);
    utime = user_time[clock_number] + 
     tmp_tbf.tms_utime - tbf1[clock_number].tms_utime;
    stime = sys_time[clock_number] +
     tmp_tbf.tms_stime - tbf1[clock_number].tms_stime;
  }
  else
  {
    fprintf (file, "\n");

    rtime = real_time[clock_number];
    utime = user_time[clock_number];
    stime = sys_time[clock_number];
  }

  fprintf (file, "Real Time _: %d (%7.12lf secs.)\n", rtime, rtime/60.0);
  fprintf (file, "User Time _: %d (%7.12lf secs.)\n", utime, utime/60.0);
  fprintf (file, "System Time _: %d (%7.12lf secs.)\n", stime, stime/60.0);
#endif 
  return;
}

int pwGetRealTime
(
  int clock_number
)
{

int rtime;
#ifdef NT
printf("Stubbing pwGetRealTime\n");
#else 

  struct tms tmp_tbf;

  if (clock_inuse[clock_number])
  {
    rtime = real_time[clock_number] +
     (int) (times (&tmp_tbf) - start_real_time[clock_number]);
  }
  else
  {
    rtime = real_time[clock_number];
  }
#endif 
  return (rtime);
}


int pwGetUserTime
(
  int clock_number
)
{

int utime;
#ifdef NT
printf("Stubbing pwInitClock\n");
#else 
  struct tms tmp_tbf;

  if (clock_inuse[clock_number])
  {
    times (&tmp_tbf);
    utime = user_time[clock_number] + 
     tmp_tbf.tms_utime - tbf1[clock_number].tms_utime;
  }
  else
  {
    utime = user_time[clock_number];
  }
#endif 
  return (utime);
}


int pwGetSysTime
(
  int clock_number
)
{
#ifdef NT
printf("Stubbing pwGetSysTime \n");
return(0);
#else 

  int stime;
  struct tms tmp_tbf;

  if (clock_inuse[clock_number])
  {
    times (&tmp_tbf);
    stime = sys_time[clock_number] +
     tmp_tbf.tms_stime - tbf1[clock_number].tms_stime;
  }
  else
  {
    stime = sys_time[clock_number];
  }
#endif 

}
