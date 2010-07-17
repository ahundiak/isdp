/***************************************************************************
 * INGR - PPL
 *
 * File:        PC2d.h
 *
 * Description:	PPL include files defining common constants
 *              for profile card programs.
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/17/00        mjablko         creation date
 *
 ***************************************************************************/

/* ============================ */
/*          MAIN TYPES          */
/* ============================ */

/* stiffener types */
#define TEE     0
#define ANGLE   1
#define ITEE    2
#define CHAN    3
#define BULB    4
#define FLAT    5
#define PIPE    6
#define BTEE    7

/* End Cut Type */
#define STRAIGHT  0
#define SNIPE     1
#define BEAMLIM   2
#define BEAMLIMR  3
#define JOG       4
#define TRANSDN   5
#define TRANSUP   6
#define WEBASFLG  7
#define TEMPLATE1 8            // Requires one profile size
#define TEMPLATE2 9            // Requires size fo two profiles


/* end feature types */
#define NONE  0
#define SNIPE 1
#define COPE  2

#define NONE  0
#define EQUAL 1
#define EXT   2
#define SNP   3

/* Flange/Web type */
#define HIDDEN  0
#define VISIBLE 1
#define CENTRAL 2
#define SIDE    3

/* General position */
#define BOTTOM   0
#define TOP      1
#define LEFT     2
#define RIGHT    3

/* ============================ */
/*     DIMENSION POSITIONING    */
/* ============================ */

/* Dimension directions */
#define DIM_ABOVE  0
#define DIM_BELOW  1
#define DIM_RIGHT  2
#define DIM_LEFT   3

/* Dimension text direction */
#define DIM_TXT_LEFT   0
#define DIM_TXT_INSIDE 1
#define DIM_TXT_RIGHT  2

/* txt scale factors */
#define LABEL   2.5
#define DIM     4
#define ANG_FAC 0.15
#define DIM_OVL 1.5
#define DIM_LEN 15

/* ========================= */
/*     FEATURE  SIZING       */
/* ========================= */

/* Web & Flange view constants */
/* =========================== */
#define        WEBTHK     0.1
#define        FLGTHK     0.05
#define        BULBWEBTHK 0.15

#define        WEBANGLE   0.3
#define        FLGCUT     0.2
#define        FLGSNIPE   0.3
#define        FLSMSNIPE  0.3
#define        FLBIGSNIPE 0.35


#define        BMCUTLEN   0.3
#define        BMCUTHGT   0.05



/* feature sizing */
#define WEBSNIPE    0.1
#define WEBBIGSNIPE 0.15
#define WEBSCALLOP  0.15
#define WEBEXTSCALL 0.3


#define DISTTOSN  0.35         //Distance from top of profile to the flange snipe
#define DISTTOWEB 0.473        //Distance from top of profile to the web
#define WEBENDCUT 0.975        //Multiply this by FrameWidth to get the angle at end of web snipe
#define FLGANGLE    0.3
#define WEBRATIO    0.4
//#define WEBTHK    0.1          //Multiply by FrameHeight to get thickness of the web.  Should be 1.0 - DISTTOWEB*2


// FROM WEB
/* feature sizing */
#define FEATSIZE 0.1
#define SCALLOPLEN 4.0
#define FIL_RAD 0.1
#define STOCK 0.05


// FROM FLANGE
/* txt scale factors */
//#define LABEL   1.5
//#define DIM     4
//#define ANG_FAC 0.15
//#define DIM_OVL 1.5
//#define DIM_LEN 15

/* feature sizing */
#define FLGANGLE  0.3
#define WEBRATIO  0.4
#define SMSNIPE   0.3
#define BIGSNIPE  0.35
#define DISTTOSN  0.35         //Distance from top of profile to the flange snipe
#define DISTTOWEB 0.473        //Distance from top of profile to the web
#define WEBENDCUT 0.975        //Multiply this by FrameWidth to get the angle at end of web snipe
#define WEBTHK    0.1          //Multiply by FrameHeight to get thickness of the web.  Should be 1.0 - DISTTOWEB*2


/* ========================= */
/*      OTHER CONSTANTS      */
/* ========================= */

/*
#define PI             3.141592654
#define HALF_PI        1.570796
*/
