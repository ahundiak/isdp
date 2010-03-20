/*  ex1.h
 *
 *  This file defines the constants and structure used
 *  in the ex1 application.
 */

/*
 *  #define our BOOLEANS
 */
#define TRUE 1
#define FALSE 0

/*
 *  #define the form labels.
 */
#define WALL_DESIGN_FORM 100
#define ACC_DESIGN_FORM 101

/* 
 *  #define the gadget labels for the WALL_DESIGN form.
 */
#define SUPPLIER_BUTTON 12
#define ACCESS_BUTTON 13
#define MATERIAL_BUTTON 14
#define HEIGHT_SLIDER 35
#define MATERIAL_SUBTITLE 33
#define SUPPLIER_SUBTITLE 32
#define LENGTH_SLIDER 37
#define SUPPLIER_TOGGLE 34
#define NAME_FIELD 31
#define MESSAGE_FIELD 36
#define MATERIAL_FIELD 60
#define SUPPLIER_FIELD 61
#define HEIGHT_TEXT 39
#define LENGTH_TEXT 45

/*
 *  #define the group gadget labels for the wall
 *  design form.
 */
#define ACTION_GROUP 200
#define MATERIAL_GROUP 300
#define SUPPLIER_GROUP 400

/*
 *  #define the gadget labels for the accessories
 *  design form.
 */
#define DESIGN_TOGGLE 12
#define STYLE_FIELD 13
#define DOOR_SUBTITLE 14
#define DOOR_LOCK_SUBTITLE 21
#define DOOR_LOCK_LINE1 20
#define DOOR_LOCK_LINE2 22
#define DOOR_LOCK_LINE3 23
#define DOOR_LOCK_LINE4 24
#define NONE_CHECKBOX 25
#define STANDARD_CHECKBOX 26
#define PADLOCK_CHECKBOX 27
#define DEADBOLT_CHECKBOX 28
#define CHAIN_CHECKBOX 29
#define WINDOW_SUBTITLE 15
#define RIGHT_STYLE_BUTTON 30
#define LEFT_STYLE_BUTTON 31
#define STYLE_SYMBOL 32

/*
 *  #define the group gadget labels for the
 *  accessories design form.
 */
#define LOCK_GROUP 200
#define DOOR_GROUP 300
#define WINDOW_GROUP 400

/*
 *  #define the maximum number of door and
 *  window styles.
 */
#define MAX_DOOR_STYLES 10
#define MAX_WINDOW_STYLES 5

/*
 *  #define the two design mode for the design
 *  accessories form.
 */
#define DESIGN_DOOR 1
#define DESIGN_WINDOW 2

/*
 *  Declare the door and window styles structure
 *  from which two arrays are declared in ex1gvar.h.
 */
struct styles {
  char desc[20];
  int symbol;
};

/*
 *  Declare the wall information structure from
 *  which the global wall structure is declared
 *  in ex1gvar.h.  This structure will hold all
 *  the wall parameters and will be used to write
 *  out the info to the results file before exit.
 */
struct wall_info {
  char name[40];
  double length;
  double height;
  int door_style;
  int lock;
  int window_style;
  int material;
  int num_suppliers;
  char suppliers[5][40];
};
