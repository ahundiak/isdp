/*
HISTORY:

05/19/92 : NP	Finally, I get to create a file !!!.

*/

/* This file defines constants to be used as timer clock indices for the 
 * purposes of timing functions/methods.  Every time a new clock is added to
 * the system (symbolically speaking) or in other words, we want to time yet
 * another function, the "MAX_TIMERS" #define should be updated. THIS IS 
 * IMPORTANT.
 *
 *              INSTRUCTION ON ADDING A NEW #DEFINE TO THIS FILE
 *              ------------------------------------------------
 *       To make it easy to identify the #define for a particular function,
 *       the following convention has been followed here. The rules are quite
 *       stringent in the hope that it will ease possible automation later on.
 *
 *       A) ALL CASES
 *          ---------
 *       o Add a comment above the defined constant with the EXACT name
 *         of the function/method in which the timer is defined. This is so
 *         that if at some point of time, the names of some functions/methods
 *         are changed, then the developer should be able to change the name 
 *         of the timer accordingly. By "grep"ing for the function/method name
 *         the developer can change the #define according to the rules below.
 *       o Update the "MAX_TIMERS" #define at the bottom of this file to 
 *         indicate the total number of timers defined in this file.
 *       o Note that although there are two lists below, the number sequence is
 *         common for the two. i.e. Use the next higher number from the highest
 *         number in the two lists below. The highest number is always 
 *         (MAX_TIMERS - 1).
 *       o Update the "timer_strings" array in the "ECtimeri.I" file 
 *         to add a print string for the newly added timer. DO NOT
 *          FORGET TO INCLUDE A COMMA AT THE END OF THE PREVIOUS ENTRY.
 *
 *       B) FOR A TIMER ENCOMPASSING A WHOLE METHOD/FUNCTION
 *          ------------------------------------------------
 *       o The constant ALWAYS begins with a "T_"
 *       o Add to that the name of the method/function EXACTLY as it is,
 *         EXCEPT that all the characters are upper case 
 *       o If constant is longer that allowed, then trucnate from right.
 *
 *       C) FOR A TIMER THAT TIMES ONLY PART OF THE CODE OF A METHOD/FUNCTION
 *          -----------------------------------------------------------------
 *       o The constant begins with "T{NUM}_", where {NUM} is the number of the
 *         timer clock (defined above this define) for the function/method 
 *         within which this timer is to be used.
 *       o The rest of the name may be anything that makes sense to the user
 *
 *       EXAMPLES:
 *       --------
 *       o Timer name for a timer that starts at the beginning of and stops at
 *         the end of method "EMsfsfint" will be "T_EMSFSFINT"
 *       o If the above timer is defined as
 *              #define T_EMSFSFINT	16
 *         then, a timer within EMsfsfint method that only checks for the time
 *         spent in method "EMget_int_data" can be possibly defined as:
 *              #define T16_TIME_IN_EMGET_INT_DATA     33
 *
 *
 */
 
#ifndef _timerdef_include
#define _timerdef_include

/* MAIN TIMERS
 * -----------
 * These are timers that are started at the top of a function/method and end 
 * at the bottom. The numbers between this list and the one below should be
 * in increasing order and there should be no common number between them.
 */

/* Timer for the "EMjoiningBoolean" method */
#define T_EMJOININGBOOLEAN                                                  0

/* Timer for the "EMintersect_surfaces" function */
#define T_EMINTERSECT_SURFACES                                              1

/* Timer for the "EMboolean_surfaces_w_intersection" function */
#define T_EMBOOLEAN_SURFACES_W_INTERSECTION                                 2

/* Timer for the "EMsfsfint" method */
#define T_EMSFSFINT                                                        12

/* Timer for the "EMsfsfint" method */
#define T_EMGETINTDATA                                                     17

/* Timer for the "EMcloseyourself" method */
#define T_EMCLOSEYOURSELF                                                  21

/* Timer for the "EMnesting" method */
#define T_EMNESTING                                                        24

/* Timer for the "EMpt_location" method */
#define T_EMPT_LOCATION                                                    26

/* Timer for the "EMlsfulltrim" method */
#define T_EMLSFULLTRIM                                                     27

/* Timer for the "EMlsparttrim" method */
#define T_EMLSPARTTRIM                                                     30

/* Timer for the "EMmkpybdrysl" function */
#define T_EMMKPYBDRYSL                                                     34

/* Timer for the "EMptnesting" function */
#define T_EMPTNESTING                                                      37

/* Timer for the "EMmake_comp" method at EMSsfstitch class */
#define T_EMMAKE_COMP                                                      39

/* Timer for the "EMround" method at EMSsfrndbool class */
#define T_EMROUND                                                          41

/* SUB TIMERS
 * ----------
 * These are timers that measure the time taken for calls to other functions/
 * methods from within a parent function/method.  The parent function/method
 * is the #define under the "MAIN TIMERS" which has the same value as the 
 * number following the first "T" of the #defines below. Note that the #defines
 * are in increasing order between the two lists and there should be no common
 * number between the two lists.
 */

/* Sub-timer WITHIN the "EMintersect_surfaces" method */
#define T1_SFSFINT                                                          3

/* Sub-timer WITHIN the "EMintersect_surfaces" method */
#define T1_FIXSFINTOUTS                                                     4

/* Sub-timer WITHIN the "EMintersect_surfaces" method */
#define T1_TRACE                                                            5

/* Sub-timer WITHIN the "EMintersect_surfaces" method */
#define T1_REFINE                                                           6

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_TOPOLOGY_VALIDATE                                                7

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_SPLIT_EDGES                                                      8

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_CLOSE_LOOPS                                                      9

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_UNSPLIT_EDGES                                                   20

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_CLEANUP                                                         10

/* Sub-timer WITHIN the "EMboolean_surfaces_w_intersection" function */
#define T2_SAVE_STATE_AND_BOOLINIT                                         11

/* Sub-timer WITHIN the "EMsfsfint" method */
#define T12_GET_INT_DATA                                                   13

/* Sub-timer WITHIN the "EMsfsfint" method */
#define T12_FULLTRIM                                                       14

/* Sub-timer WITHIN the "EMsfsfint" method */
#define T12_ORIENT_AND_MKINTDATA                                           15

/* Sub-timer WITHIN the "EMsfsfint" method */
#define T12_BDRYINT                                                        16

/* Sub-timer WITHIN the "EMsfsfint" method */
#define T12_GETRANGE                                                       40

/* Sub-timer WITHIN the "EMget_int_data" method */
#define T17_BSSFSFINT                                                      18

/* Sub-timer WITHIN the "EMget_int_data" method */
#define T17_FIX_INTERSECTIONS                                              19

/* Sub-timer WITHIN the "EMcloseyourself" method */
#define T21_CREATE_LOOP                                                    22

/* Sub-timer WITHIN the "EMcloseyourself" method */
#define T21_NEST_LOOP                                                      23

/* Sub-timer WITHIN the "EMnesting" method */
#define T24_PT_LOCATION                                                    25

/* Sub-timer WITHIN the "EMlsfulltrim" method */
#define T27_PARTTRIM                                                       28

/* Sub-timer WITHIN the "EMlsfulltrim" method */
#define T27_MAP_BOUNDARY                                                   29

/* Sub-timer WITHIN the "EMlsparttrim" method */
#define T30_TRIM_AGAINST_BOUNDARY                                          31

/* Sub-timer WITHIN the "EMlsparttrim" method */
#define T30_PT_LOCATION                                                    32

/* Sub-timer WITHIN the "EMlsparttrim" method */
#define T30_MKPYBDRYSL                                                     33

/* Sub-timer WITHIN the "EMmkpybdrysl" method */
#define T34_PT_LOCATION                                                    35

/* Sub-timer WITHIN the "EMmkpybdrysl" method */
#define T34_POINT_NESTING                                                  36

/* Sub-timer WITHIN the "EMptnesting" method */
#define T37_PT_LOCATION                                                    38


#define MAX_TIMERS          42   /* Total number of timers defined */
#define MAX_NUM_TIMERS      100  /* Maximum number of timers allowed */
#define TIMER_STRING_MAX    80   /* Maximum length of timer output string */

extern IGRboolean _use_timers;

#endif
