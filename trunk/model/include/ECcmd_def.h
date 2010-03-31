#ifndef ECcmd_def_include
#define ECcmd_def_include 1

/* ***********************************************************************
     value for mytype
 ********************************************************************** */
#define CURVE   0
#define SURFACE 1
#define CONTROL 0
#define NO_CONTROL 1

/* ***********************************************************************
	case values for EMstorepoint
 *********************************************************************** */
#define reg_input 1
#define brln_input 2
#define ptprj_input 3
#define unique 1
#define distptpt 2
#define distptli 3

/* **********************************************************************
	case values for EMstorevalue
 ********************************************************************** */
#define less_than 1
#define less_than_equal 2
#define greater_than 3
#define greater_than_equal 4
#define in_range 5
#define outside_range 6

/* ***********************************************************************
     values for dynamics
 ************************************************************************/
#define off  0
#define line 1
#define dynmod 2

#endif
