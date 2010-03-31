/*
HISTORY:

Long Ago:
05/19/92: NP	Overhauled the function a little bit. Added a function
		called "print_boolean_data" that currently prints the 
		results of timing tests on the boolean code to a file 
		called "bool.time" in /tmp. Interface will be made more
		sophisticated when time permits.
05/25/92: NP	Made changes to obtain accurate timing results for
		functions/methods that call themselves recursively (either 
		directly or through other function/method calls).
*/

#include "EMS.h"
#include "igrtypedef.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include "timerdef.h"

static IGRlong user_time[MAX_NUM_TIMERS], sys_time[MAX_NUM_TIMERS];
static IGRlong real_time[MAX_NUM_TIMERS];
static IGRlong tuser_time[MAX_NUM_TIMERS], tsys_time[MAX_NUM_TIMERS];
static IGRlong treal_time[MAX_NUM_TIMERS];
static struct tms tbf1[MAX_NUM_TIMERS], tbf2[MAX_NUM_TIMERS];

/* Sometimes methods call themselves recursively, which means that a clock
 * which was started at the beginning of the method, is RE_STARTED during
 * the recursive call, thus giving wrong times. The correct thing to do is
 * to start and stop the clock on the outermost call. This is implemented by
 * checking the "recurse_check" array, every time a start or a stop clock is
 * done. Initially, the array is set to 0. During "start_clock", the timer
 * is started ONLY if the value of the array for the index corresponding to
 * the clock number is 0.  Similarly, the clock is stopped during a 
 * "stop_clock" call, ONLY if the value is 1.  The clock is incremented by 1
 * during each call to "start_timer" and decremented by 1 during each call to
 * "stop_timer".
 */
static IGRshort recurse_check[MAX_NUM_TIMERS];



/*
  Inititalization
 */

init_timer(clock_number)
int clock_number;
{
  tuser_time[clock_number] = 0;
  tsys_time[clock_number] = 0;
  treal_time[clock_number] = 0;
  recurse_check[clock_number] = 0;
}



/*
  Start the timer
*/

start_timer(clock_number) 
int clock_number;
{ 
  extern   clock_t times();

  if (recurse_check[clock_number] == 0)
  {
     real_time[clock_number] = times(&(tbf1[clock_number]));
     if ( (real_time[clock_number] == (clock_t) (-1)) )
	fprintf (stderr, "ERROR: could not start timer for clock #%d\n", 
		clock_number);
  }
  recurse_check[clock_number] += 1;
}  



/*
  Stop timer
*/

stop_timer(clock_number, to_print, prtstr)
int clock_number;
short to_print;
char prtstr[];
{
  extern   clock_t times();
  clock_t  current_time;

  if (recurse_check[clock_number] == 1)
  {
     current_time = times(&(tbf2[clock_number]));
     if ( (current_time == (clock_t) (-1)) )
	fprintf (stderr, "ERROR: could not stop timer for clock #%d\n", 
		clock_number);
     real_time[clock_number] = current_time - real_time[clock_number];
     user_time[clock_number] =
                     tbf2[clock_number].tms_utime-tbf1[clock_number].tms_utime;
     sys_time[clock_number]  =
                     tbf2[clock_number].tms_stime-tbf1[clock_number].tms_stime;
     tuser_time[clock_number] += user_time[clock_number];
     tsys_time[clock_number] += sys_time[clock_number];
     treal_time[clock_number] += real_time[clock_number];
     if (to_print)
     {
       fprintf (stderr, "%s\n", prtstr);
       fprintf (stderr, "User time: %d\n", user_time[clock_number]);
       fprintf (stderr, "Sys  time: %d\n", sys_time[clock_number]);
       fprintf (stderr, "Real time: %d\n\n", real_time[clock_number]);
     }
  }

  recurse_check[clock_number] -= 1;
}


/*
  Show totals
*/

total_timer(clock_number, prtstr) 
int clock_number;
IGRchar prtstr[];
{ 
  fprintf (stderr, "%s\n", prtstr);
  fprintf (stderr, "  Total user time: %d\n", tuser_time[clock_number]);
  fprintf (stderr, "  Total sys  time: %d\n", tsys_time[clock_number]);
  fprintf (stderr, "  Total real time: %d\n", treal_time[clock_number]);
  fprintf (stderr, "-------------------------\n\n");
}


/* Return times. Time types-
   0 - user time
   1 - sys time
   2 - real time
*/
return_time(clock_number, time_type, time)
int clock_number, time_type, *time;
{
 if(time_type == 0)
   *time = user_time[clock_number];
 else if(time_type == 1)
   *time = sys_time[clock_number];
 else if(time_type == 2)
   *time = real_time[clock_number];
}



/* Return total times. Time types-
   0 - user time
   1 - sys time
   2 - real time
*/
return_total_time(clock_number, time_type, time)
int clock_number, time_type, *time;
{
 if(time_type == 0)
   *time = tuser_time[clock_number];
 else if(time_type == 1)
   *time = tsys_time[clock_number];
 else if(time_type == 2)
   *time = treal_time[clock_number];
}


/* This function prints the results of timing tests in the boolean code to
 * a file called "bool.time" in /tmp.  This function can be extended by 
 * adding more and more fprintf statements to it, when new timers are added
 * to the system.
 */

print_boolean_data()
{
 FILE *out;

 out = fopen ("/tmp/bool.time", "w");
 
 if (!out)
 {
   fprintf (stderr, "ERROR - Could not create file bool.time in /tmp\n");
   return;
 }

 fprintf (out,"TIMING RESULTS FOR BOOLEAN                          USR   SYS   REAL\n");
 fprintf (out,"--------------------------                          ---   ---   ---\n");

/***************************************************** 
 * EMjoiningBoolean
 *****************************************************/

 fprintf (out,"\nTime for EMjoiningBoolean:                          %-5d %-5d %-5d\n", 
   tuser_time[T_EMJOININGBOOLEAN],
   tsys_time[T_EMJOININGBOOLEAN],
   treal_time[T_EMJOININGBOOLEAN]);

if (tuser_time[T_EMJOININGBOOLEAN] != 0)
{
 fprintf (out,"%% time used by intersect surfaces                   %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T_EMINTERSECT_SURFACES]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
   (double)tsys_time[T_EMINTERSECT_SURFACES]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
   (double)treal_time[T_EMINTERSECT_SURFACES]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% time used by boolean surfaces with int.           %-5.1f %-5.1f %-5.1f\n", 
(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);
}

/***************************************************** 
 * EMintersect_surfaces
 *****************************************************/

 fprintf (out,"\nTime for EMintersect_surfaces:                      %-5d %-5d %-5d\n",
   tuser_time[T_EMINTERSECT_SURFACES],
   tsys_time[T_EMINTERSECT_SURFACES],
   treal_time[T_EMINTERSECT_SURFACES]);

if ( tuser_time[T_EMINTERSECT_SURFACES] != 0)
{
 fprintf (out,"%% time used by sfsfint                              %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T1_SFSFINT]/(double)tuser_time[T_EMINTERSECT_SURFACES]*100.0, 
   (double)tsys_time[T1_SFSFINT]/(double)tsys_time[T_EMINTERSECT_SURFACES]*100.0, 
   (double)treal_time[T1_SFSFINT]/(double)treal_time[T_EMINTERSECT_SURFACES]*100.0);
 fprintf (out,"%% time used by fixsfintouts                         %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T1_FIXSFINTOUTS]/(double)tuser_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)tsys_time[T1_FIXSFINTOUTS]/(double)tsys_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)treal_time[T1_FIXSFINTOUTS]/(double)treal_time[T_EMINTERSECT_SURFACES]*100.0);
 fprintf (out,"%% time used by trace                                %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T1_TRACE]/(double)tuser_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)tsys_time[T1_TRACE]/(double)tsys_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)treal_time[T1_TRACE]/(double)treal_time[T_EMINTERSECT_SURFACES]*100.0);
 fprintf (out,"%% time used by refine                               %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T1_REFINE]/(double)tuser_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)tsys_time[T1_REFINE]/(double)tsys_time[T_EMINTERSECT_SURFACES]*100.0,
   (double)treal_time[T1_REFINE]/(double)treal_time[T_EMINTERSECT_SURFACES]*100.0);
}

/***************************************************** 
 * EMsfsfint
 *****************************************************/

 fprintf (out,"\nTime for EMsfsfint:                                 %-5d %-5d %-5d\n", 
   tuser_time[T_EMSFSFINT],
   tsys_time[T_EMSFSFINT],
   treal_time[T_EMSFSFINT]);

if (tuser_time[T_EMSFSFINT] != 0)
{
 fprintf (out,"%% time used by get_int_data (regular intr.)         %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T12_GET_INT_DATA]/(double)tuser_time[T_EMSFSFINT]*100.0, 
   (double)tsys_time[T12_GET_INT_DATA]/(double)tsys_time[T_EMSFSFINT]*100.0, 
   (double)treal_time[T12_GET_INT_DATA]/(double)treal_time[T_EMSFSFINT]*100.0);

 fprintf (out,"%% time used by bdryint (overlapping plane intr.)    %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T12_BDRYINT]/(double)tuser_time[T_EMSFSFINT]*100.0, 
   (double)tsys_time[T12_BDRYINT]/(double)tsys_time[T_EMSFSFINT]*100.0, 
   (double)treal_time[T12_BDRYINT]/(double)treal_time[T_EMSFSFINT]*100.0);

 fprintf (out,"%% time used by fulltrim                             %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T12_FULLTRIM]/(double)tuser_time[T_EMSFSFINT]*100.0, 
   (double)tsys_time[T12_FULLTRIM]/(double)tsys_time[T_EMSFSFINT]*100.0, 
   (double)treal_time[T12_FULLTRIM]/(double)treal_time[T_EMSFSFINT]*100.0);

 fprintf (out,"%% time used by orient and mkintdata                 %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T12_ORIENT_AND_MKINTDATA]/(double)tuser_time[T_EMSFSFINT]*100.0, 
   (double)tsys_time[T12_ORIENT_AND_MKINTDATA]/(double)tsys_time[T_EMSFSFINT]*100.0, 
   (double)treal_time[T12_ORIENT_AND_MKINTDATA]/(double)treal_time[T_EMSFSFINT]*100.0);
}

/***************************************************** 
 * EMlsfulltrim
 *****************************************************/

 fprintf (out,"\nTime for EMlsfulltrim:                              %-5d %-5d %-5d\n",
   tuser_time[T_EMLSFULLTRIM],
   tsys_time[T_EMLSFULLTRIM],
   treal_time[T_EMLSFULLTRIM]);

if (tuser_time[T_EMLSFULLTRIM] != 0)
{
 fprintf (out,"%% time used by trimming against my/other bdry:      %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T27_PARTTRIM]/(double)tuser_time[T_EMLSFULLTRIM]*100.0, 
   (double)tsys_time[T27_PARTTRIM]/(double)tsys_time[T_EMLSFULLTRIM]*100.0, 
   (double)treal_time[T27_PARTTRIM]/(double)treal_time[T_EMLSFULLTRIM]*100.0);

 fprintf (out,"%% time used by map bdry from one surf to other:     %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T27_MAP_BOUNDARY]/(double)tuser_time[T_EMLSFULLTRIM]*100.0, 
   (double)tsys_time[T27_MAP_BOUNDARY]/(double)tsys_time[T_EMLSFULLTRIM]*100.0, 
   (double)treal_time[T27_MAP_BOUNDARY]/(double)treal_time[T_EMLSFULLTRIM]*100.0);
}

/***************************************************** 
 * EMlsparttrim
 *****************************************************/

 fprintf (out,"\nTime for EMlsparttrim:                              %-5d %-5d %-5d\n",
   tuser_time[T_EMLSPARTTRIM],
   tsys_time[T_EMLSPARTTRIM],
   treal_time[T_EMLSPARTTRIM]);

if (tuser_time[T_EMLSPARTTRIM] != 0)
{
 fprintf (out,"%% time used by trim against my bdry:                %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T30_TRIM_AGAINST_BOUNDARY]/(double)tuser_time[T_EMLSPARTTRIM]*100.0, 
   (double)tsys_time[T30_TRIM_AGAINST_BOUNDARY]/(double)tsys_time[T_EMLSPARTTRIM]*100.0, 
   (double)treal_time[T30_TRIM_AGAINST_BOUNDARY]/(double)treal_time[T_EMLSPARTTRIM]*100.0);

 fprintf (out,"%% time used by pt location:                         %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T30_PT_LOCATION]/(double)tuser_time[T_EMLSPARTTRIM]*100.0, 
   (double)tsys_time[T30_PT_LOCATION]/(double)tsys_time[T_EMLSPARTTRIM]*100.0, 
   (double)treal_time[T30_PT_LOCATION]/(double)treal_time[T_EMLSPARTTRIM]*100.0);

 fprintf (out,"%% time used by mkpybdrysl:                          %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T30_MKPYBDRYSL]/(double)tuser_time[T_EMLSPARTTRIM]*100.0, 
   (double)tsys_time[T30_MKPYBDRYSL]/(double)tsys_time[T_EMLSPARTTRIM]*100.0, 
   (double)treal_time[T30_MKPYBDRYSL]/(double)treal_time[T_EMLSPARTTRIM]*100.0);
}

/***************************************************** 
 * EMmkpybdrysl
 *****************************************************/

 fprintf (out,"\nTime for EMmkpybdrysl:                              %-5d %-5d %-5d\n",
   tuser_time[T_EMMKPYBDRYSL],
   tsys_time[T_EMMKPYBDRYSL],
   treal_time[T_EMMKPYBDRYSL]);

if (tuser_time[T_EMMKPYBDRYSL] != 0)
{
 fprintf (out,"%% time used by pt location:                         %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T34_PT_LOCATION]/(double)tuser_time[T_EMMKPYBDRYSL]*100.0, 
   (double)tsys_time[T34_PT_LOCATION]/(double)tsys_time[T_EMMKPYBDRYSL]*100.0, 
   (double)treal_time[T34_PT_LOCATION]/(double)treal_time[T_EMMKPYBDRYSL]*100.0);

 fprintf (out,"%% time used by pt nesting:                          %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T34_POINT_NESTING]/(double)tuser_time[T_EMMKPYBDRYSL]*100.0, 
   (double)tsys_time[T34_POINT_NESTING]/(double)tsys_time[T_EMMKPYBDRYSL]*100.0, 
   (double)treal_time[T34_POINT_NESTING]/(double)treal_time[T_EMMKPYBDRYSL]*100.0);
}

/***************************************************** 
 * EMptnesting
 *****************************************************/

 fprintf (out,"\nTime for EMptnesting:                               %-5d %-5d %-5d\n",
   tuser_time[T_EMPTNESTING],
   tsys_time[T_EMPTNESTING],
   treal_time[T_EMPTNESTING]);

if ( tuser_time[T_EMPTNESTING] != 0)
{
 fprintf (out,"%% time used by pt location:                         %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T37_PT_LOCATION]/(double)tuser_time[T_EMPTNESTING]*100.0, 
   (double)tsys_time[T37_PT_LOCATION]/(double)tsys_time[T_EMPTNESTING]*100.0, 
   (double)treal_time[T37_PT_LOCATION]/(double)treal_time[T_EMPTNESTING]*100.0);
}

/***************************************************** 
 * EMget_int_data
 *****************************************************/

 fprintf (out,"\nTime for EMget_int_data:                            %-5d %-5d %-5d\n",
   tuser_time[T_EMGETINTDATA],
   tsys_time[T_EMGETINTDATA],
   treal_time[T_EMGETINTDATA]);

if ( tuser_time[T_EMGETINTDATA] != 0)
{
 fprintf (out,"%% time used by bssfsfint                            %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T17_BSSFSFINT]/(double)tuser_time[T_EMGETINTDATA]*100.0, 
   (double)tsys_time[T17_BSSFSFINT]/(double)tsys_time[T_EMGETINTDATA]*100.0, 
   (double)treal_time[T17_BSSFSFINT]/(double)treal_time[T_EMGETINTDATA]*100.0);

 fprintf (out,"%% time used by fix_the_int and addintpts            %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T17_FIX_INTERSECTIONS]/(double)tuser_time[T_EMGETINTDATA]*100.0, 
   (double)tsys_time[T17_FIX_INTERSECTIONS]/(double)tsys_time[T_EMGETINTDATA]*100.0, 
   (double)treal_time[T17_FIX_INTERSECTIONS]/(double)treal_time[T_EMGETINTDATA]*100.0);
}

/***************************************************** 
 * EMboolean_surfaces_w_intersection
 *****************************************************/

 fprintf (out,"\nTime for EMboolean_surfaces_w_intersection:         %-5d %-5d %-5d\n", 
   tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION],
   tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION],
   treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]);

if (tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION] != 0)
{
 fprintf (out,"%% time used by topology validate                    %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_TOPOLOGY_VALIDATE]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_TOPOLOGY_VALIDATE]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_TOPOLOGY_VALIDATE]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);

 fprintf (out,"%% time used by split edges                          %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_SPLIT_EDGES]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_SPLIT_EDGES]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_SPLIT_EDGES]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);

 fprintf (out,"%% time used by close loops                          %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_CLOSE_LOOPS]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_CLOSE_LOOPS]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_CLOSE_LOOPS]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);

 fprintf (out,"%% time used by unsplit edges                        %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_UNSPLIT_EDGES]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_UNSPLIT_EDGES]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_UNSPLIT_EDGES]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);

 fprintf (out,"%% time used by cleanup                              %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_CLEANUP]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_CLEANUP]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_CLEANUP]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);

 fprintf (out,"%% time used by save state and boolinit              %-5.1f %-5.1f %-5.1f\n", 
   (double)tuser_time[T2_SAVE_STATE_AND_BOOLINIT]/(double)tuser_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)tsys_time[T2_SAVE_STATE_AND_BOOLINIT]/(double)tsys_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0,
   (double)treal_time[T2_SAVE_STATE_AND_BOOLINIT]/(double)treal_time[T_EMBOOLEAN_SURFACES_W_INTERSECTION]*100.0);
}

/***************************************************** 
 * EMcloseyourself
 *****************************************************/

 fprintf (out,"\nTime for EMcloseyourself:                           %-5d %-5d %-5d\n", 
   tuser_time[T_EMCLOSEYOURSELF],
   tsys_time[T_EMCLOSEYOURSELF],
   treal_time[T_EMCLOSEYOURSELF]);

if (tuser_time[T_EMCLOSEYOURSELF] != 0)
{
 fprintf (out,"%% time used by create loop                          %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T21_CREATE_LOOP]/(double)tuser_time[T_EMCLOSEYOURSELF]*100.0,
 (double)tsys_time[T21_CREATE_LOOP]/(double)tsys_time[T_EMCLOSEYOURSELF]*100.0,
 (double)treal_time[T21_CREATE_LOOP]/(double)treal_time[T_EMCLOSEYOURSELF]*100.0);

 fprintf (out,"%% time used by nest loop                            %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T21_NEST_LOOP]/(double)tuser_time[T_EMCLOSEYOURSELF]*100.0,
 (double)tsys_time[T21_NEST_LOOP]/(double)tsys_time[T_EMCLOSEYOURSELF]*100.0,
 (double)treal_time[T21_NEST_LOOP]/(double)treal_time[T_EMCLOSEYOURSELF]*100.0);
}

/***************************************************** 
 * EMnesting
 *****************************************************/

 fprintf (out,"\nTime for EMnesting:                                 %-5d %-5d %-5d\n", 
   tuser_time[T_EMNESTING],
   tsys_time[T_EMNESTING],
   treal_time[T_EMNESTING]);

if ( tuser_time[T_EMNESTING] != 0)
{
 fprintf (out,"%% time used by point location                       %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T24_PT_LOCATION]/(double)tuser_time[T_EMNESTING]*100.0,
 (double)tsys_time[T24_PT_LOCATION]/(double)tsys_time[T_EMNESTING]*100.0,
 (double)treal_time[T24_PT_LOCATION]/(double)treal_time[T_EMNESTING]*100.0);
}

/***************************************************** 
 * EMmake_comp
 *****************************************************/

 fprintf (out,"\nTime for EMmake_comp:                               %-5d %-5d %-5d\n",
   tuser_time[T_EMMAKE_COMP],
   tsys_time[T_EMMAKE_COMP],
   treal_time[T_EMMAKE_COMP]);

 
/***************************************************** 
 * Some interesting output
 *****************************************************/
 fprintf (out,"\n\n\n");

if (tuser_time[T_EMJOININGBOOLEAN] != 0)
{
 fprintf (out,"%% of total time used by bssfsfint:                  %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T17_BSSFSFINT]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T17_BSSFSFINT]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T17_BSSFSFINT]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% of total time used by pt location:                %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T_EMPT_LOCATION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T_EMPT_LOCATION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T_EMPT_LOCATION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% of total time used by pt loc in EMlsparttrim      %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T30_PT_LOCATION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T30_PT_LOCATION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T30_PT_LOCATION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% of total time used by pt loc in EMmkpybdrysl      %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T34_PT_LOCATION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T34_PT_LOCATION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T34_PT_LOCATION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% of total time used by pt loc in EMptnesting       %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T37_PT_LOCATION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T37_PT_LOCATION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T37_PT_LOCATION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);

 fprintf (out,"%% of total time used by pt loc in EMnesting:        %-5.1f %-5.1f %-5.1f\n", 
 (double)tuser_time[T24_PT_LOCATION]/(double)tuser_time[T_EMJOININGBOOLEAN]*100.0,
 (double)tsys_time[T24_PT_LOCATION]/(double)tsys_time[T_EMJOININGBOOLEAN]*100.0,
 (double)treal_time[T24_PT_LOCATION]/(double)treal_time[T_EMJOININGBOOLEAN]*100.0);
}

fclose (out);
}
