/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

File:		comm.h

Purpose: 	This header file defines all server commands
	and structures used to carry on communication between
	the client and the image manipulation side of the server.

Author:	Jeff Silvaggi

Date:	06-29-89

Change History:
	01-15-91  jms	Added rotate flag to pc_select_plot structure
**********************************************************************/
#include "dbcomm.h"	/* Include server database commands */

/* DISPLAY Server commands */
#define INITIALIZE 	1	/* Initialize server tables */
#define SET_MODE 	2	/* Change default client screen characteristics */
#define OVERVIEW 	3	/* Generate overview image */
#define SEND_TEXT	4	/* Send a screen full of text data */
#define OPEN_DETAIL 	5	/* Open detail files for specified item */
#define WINDOW 		6	/* Generate an image based on passed coordinates */
#define CLOSE 		7	/* Close detail files for specified item */
#define PLOT 		8	/* Plot a window area */
#define EXIT 		9	/* Terminate current session */
#define ACCEPTED	10	/* Returned to client if command was accepted */
#define ERROR 		11	/* Returned to client if an error was encountered */
#define OVERVIEW_DATA	12	/* Send the specified portion of the overview */
#define WINDOW_DATA	13	/* Send the specified portion of the window area data */
#define REDLINE_OPEN	14	/* Open an existing redline layer for read */
#define REDLINE_CLOSE	15	/* Close an open redline layer */
#define REDLINE_CREATE	16	/* Open a new redline file for write */
#define REDLINE_READ	17	/* Read a portion of a redline file */
#define REDLINE_WRITE	18	/* Write a portion of a redline file */
#define PLOT_LIST	19	/* Send a list of available plot queues */
#define SELECT_PLOT	20	/* Select a plot queue for next PLOT command */
#define REFERENCE_INFO	21	/* Get information about current redline layers */
#define VALIDATE_PASSWD	22	/* Validate redline layer password if present */
#define ACTIVATE_LAYER	24	/* Activate an existing redline layer */
#define NOT_AVAILABLE	25	/* Optical disk file currently not in cache */
#define NO_PERMISSION	26	/* User does not have permission to do requested operation */
#define SEND_VLT	27	/* Send a VLT for specified file */
#define USE_DEFAULT_VLT	28	/* Returned to client if the default VLT should be used */
#define ERROR_MSG	29	/* Returned to client if error with message */

#define ADD_FILE	33	/* Add a detail file to the server tables */
#define READ_INTERFACE	34	/* Read a DMANDS interface file */
#define REDLINE_ADD	35	/* Add a redline file to the server tables */
#define REDLINE_CHECKIN	36	/* Checkin the specified redline layer */
#define FILE_INIT_XFR	39	/* Initialize a file transfer between client/server */
#define FILE_XFER	40	/* Transfer a file between client/server */
#define	ODCONFIG_FILE	41	/* Optical disk configuration command */
#define	ODRECONFIG	42	/* Optical disk configuration command */
#define	ODALTERCONFIG	43	/* Optical disk configuration command */
#define ACTIVATE_BLANK	44	/* Activate a blank redline layer */
#define GET_PAGES	45	/* Get number of pages in file */
#define GET_COPIES	46	/* Get number of copies for plotting */

/* Server timer commands for analyzing performance */
#define TIMER_START	30	/* Start timer to time an event */
#define TIMER_SEND	31	/* Send junk data for testing network speed */
#define TIMER_STOP	32	/* Stop timer and print results to errlog */
#define CTIMER_ON	37	/* Start client timer */
#define CTIMER_OFF	38	/* Stop client timer and print information */
/***********************************************************/

/* WS-PC values definition */
#define IS_WS	701
#define IS_PC	702

/* Redline access switches */
#define REFERENCE_FILE_WRITE_ACCESS	(1 << 0)	/* User can write */
#define REFERENCE_FILE_EXISTS		(1 << 1)	/* File exists */
#define REFERENCE_FILE_READ_PASSWORD	(1 << 2)	/* Password required */
#define REFERENCE_FILE_WRITE_PASSWORD	(1 << 3)	/* Password required */

#define MAX_PC_LIST_SIZE 8

/********************************************************
   SET_LENGTH Command modifiers
	bit
         0	0 = Display client  1 = Sponsor client
         1	0 = Workstation     1 = PC
*********************************************************/
#define     WS_DISPLAY		0
#define     WS_SPONSOR		1
#define     PC_DISPLAY		2
#define     PC_SPONSOR		3

/* PC ADD_FILE argument structure */
typedef struct pc_add_file
{
	char	catalog[40];	/* Catalog name of base file */
	char	item_name[40];	/* Item name of base file */
	char	item_rev[40];	/* Item revision of base file */
	char	item_acl[8];	/* Item ACL of base file */
	long	file_number;	/* Multiple file number from NFM */
	char	ci_location[20];/* Checkin location of base file */
	char	node[16];	/* Node where base file resides */
	char	fname[80];	/* Path to file */
	short	type;		/* Data type:		0=B&W image 1=text 3=color */
	short	archived;	/* Archived flag:	1=archived 0=not archived */
	long	pages;		/* Number of pages in document */
	long	file_size;	/* Size of detail file in bytes */
	char	r_node[16];	/* Node where reduced resolution file resides */
	char	r_name[80];	/* Path to file */
	short	r_archived;	/* RR Archived flag:	1=archived 0=not archived */
	short	dummy;		/* Pad field for clipper alignment */
} pc_add_file;

/* PC INITIALIZE & SET_MODE argument structure */
typedef struct pc_init
{
	short	x_pix;		/* # of pixels in X direction */
	short	y_pix;		/* # of pixels in Y direction */
	short	c_txt;		/* # of text chars per line */
	short	l_txt;		/* # of text lines */
	float   aspect; 	/* aspect ratio (height/width) */
	short	display_typ;	/* Display type   : 0=bitmap 1=RLE 2=G4 */
	short	term_type;	/* Terminal type:	*/
				/*	0 	EGA	*/
				/*	1	VGA	*/
				/*	2	ROP(2)	2 virtual screens */
				/*	3	IFB	*/
				/*	4	ROP(1)	1 virtual screen */
				/* 2=4 bitplane WS, 3=8 bitplane WS */
	short	text_wrap;	/* Text wrap      : 1=enable 0=disable */
	short	invert_pix;	/* Invert pixels  : 1=enable 0=disable */
	char	dec_type;	/* Y direction or : 1=enable 0=disable */
	char	zoom_ret;	/* Zoom retention : 1=enable 0=disable */
	char	page_factor;	/* Partial page factor: 1=1 2=1/2 3=1/3 4=1/4 */
	char	delayed_cache;	/* Delayed cache  : 1=enable 0=disable */
	char	node[16];	/* Client Node name */
	char	alt_path[80];	/* Aternate cache directory from DMDS.alt */
} pc_init;

/* PC OVERVIEW, OPEN_DETAIL & CLOSE argument structure */
typedef struct pc_overview
{
	short	list_no;	/* File list number */
	short	dummy;
	long	page;		/* Page number in document */
} pc_overview;

/* UNIX OVERVIEW structure */
typedef struct u_overview
{
	long bytes;
	long protection;	/* Bit 0 : 1 = printable */
} u_overview;

/* PC_OVERVIEW_DATA structure */
typedef struct pc_overview_data
{
	long offset;
	long bytes;
} pc_overview_data;

/* PC SEND_TEXT argument structure */
typedef struct pc_text
{
	short	list_no;	/* File list number */
	short	lines;		/* Number of lines */
	long	st_line;	/* Starting line number */
} pc_text;

/* UNIX OPEN_DETAIL argument structure */
typedef struct u_detail
{
	long	x_pix;		/* Detail pixels in X direction */
	long	y_pix;		/* Detail pixels in Y direction */
        double  tran[16];       /* transformation matrix */
        long    dpi;            /* resolution */
	char	scan_orient;	/* Scanline orientation code (from raster header) */
	char	dummy[3];
	long	ul_x;		/* Upper left X coordinate */
	long	ul_y;		/* Upper left Y coordinate */
	long	lr_x;		/* Lower right X coordinate */
	long	lr_y;		/* Lower right Y coordinate */
	long	protection;	/* Bit 0 : 1 = printable */
} u_detail;

/* PC WINDOW & PLOT argument structure */
typedef struct pc_window	
{
	long	ul_x;		/* Upper left X coordinate */
	long	ul_y;		/* Upper left Y coordinate */
	long	lr_x;		/* Lower right X coordinate */
	long	lr_y;		/* Lower right Y coordinate */
        short   list_no;        /* Server file list number */
	short	reference_mask; /* Mask of which redlines to plot */
	long	page;		/* Page number in document */
} pc_window;

/* Unix WINDOW structure */
typedef struct  u_window	       
{
	long	ul_x;		/* Upper left X coordinate */
	long	ul_y;		/* Upper left Y coordinate */
	long	lr_x;		/* Lower right X coordinate */
	long	lr_y;		/* Lower right Y coordinate */
        long    bytes;          /* number of bytes */
} u_window;

/* PC REDLINE_ADD argument structure */
typedef struct pc_redline_add
{
	char	item_name[40];	/* Item name */
	char	item_rev[40];	/* Item revision */
	char	node[16];	/* Node where file resides */
	char	fname[80];	/* Path to file */
	short	archived;	/* Archived flag:	1=archived 0=not archived */
	short	list_no;	/* List number this redline belongs to */
	short	page;		/* Page number this redline belongs to */
	short	ref_no;		/* Layer number */
} pc_redline_add;

/* PC REDLINE OPEN */
typedef struct pc_redline_open
{
	short	list_no;	/* Server file list number */
	short	ref_no;		/* Reference file number */
	long	page;		/* Page number of document */
} pc_redline_open;

/* PC REDLINE CREATE */
typedef struct pc_redline_create
{
	short	list_no;	/* Server file list number */
	short	ref_no;		/* Reference file number */
	long	page;		/* Page number of document */
	long	color;		/* Color to be stored in database */
	char	desc[80];	/* Redline layer description */
} pc_redline_create;

/* PC REDLINE CLOSE */
typedef struct pc_redline_close
{
	short	list_no;	/* Server file list number */
	short	ref_no;		/* Reference file number */
	long	page;		/* Page number of document */
} pc_redline_close;

/* PC REDLINE CHECKIN */
typedef struct pc_redline_checkin
{
	short	list_no;	/* Server file list number */
	short	ref_no;		/* Reference file number */
	long	page;		/* Page number of document */
} pc_redline_checkin;

/* PC REDLINE_READ */
typedef struct pc_redline_read
{
	short	list_no;	/* Server file list number */
	short	ref_no;		/* Reference file number */
	long	start;		/* Starting byte offset in file */
	long	nbytes;		/* Number of bytes to read */
	long	page;		/* Page number of document */
} pc_redline_read;

#define BROWSE_NAME_LENGTH 16

/* PC list format */
typedef struct pc_list
{
        short   list_no;        /* Server file list number */
	char	name[BROWSE_NAME_LENGTH];	/* Overview name */
	short	type;		/* Data type 0=image 1=text */
	short	dummy;		/* Dummy variable for clipper alignment */
	long	pages;		/* Number of pages in document */
} pc_list;

/* PC SELECT_PLOT argument structure */
typedef struct pc_select_plot
{
	char	queue[19];	/* Plot queue name */
	char	type;		/* Queue type: 0=Black & White 1=Color 2=Fax */
	float	scale;		/* Scale factor for plot */
	char	red_colors[14];	/* Redline colors */
	short	copies;		/* Number of copies */
	char	rotate;		/* Rotate flag: 1=enable  0=disable */

	/* Fax specific fields */
	char	phone[30];	/* Fax phone number */
	char	to[40];		/* To: (for cover page) */
	char	from[40];	/* From: (for cover page) */
	char	date[40];	/* Date: (for cover page ) */
	char	descr[4][40];	/* Description: (for cover page) */
} pc_select_plot;

/* PC validate password for reference file format */
typedef struct pc_validate_passwd
{
	short	list_no;	/* Browse list index */
	short	ref_no;		/* Reference file index */
	short	read_write;	/* 0 = read passwd; 1 = write passwd */
	char	passwd[80];	/* Null terminated string */
	long	page;		/* Page number of document */
} pc_validate_passwd;

/* PC reference info structure */
typedef struct pc_reference_info
{
	short	list_no;	/* File list number */
	short	dummy;		/* Dummy for clipper alignment */
	char	passwd[80];	/* Password */
	long	page;		/* Page number of document */
} pc_reference_info;

/* UNIX reference file layer structure */
typedef struct u_reference_file_struct
{
	short	status;		/* Exists & write status bits */
	char	name[40];	/* Reference description field */
} u_reference_file_struct;

/* PC activate layer */ 
typedef struct pc_activate_layer
{
	short	list_no;
	short	ref_no;
	long	page;		/* Page number of document */
} pc_activate_layer;

/* PC SEND_VLT argument structure */
typedef struct pc_sendvlt
{
	short   list_no;
	short	dummy;
	long	page;
} pc_sendvlt;

/* UNIX SEND_VLT structure */
typedef struct u_sendvlt
{
	long	vlt_entries;	/* normally 16 */
	struct vlt_data {
		unsigned char index;
		unsigned char red;
		unsigned char green;
		unsigned char blue;
	} vlt_data[256];
} u_sendvlt;

/* CLIENT FILE TRANSFER argument structure */
typedef struct pc_file_xfer
{
	char	fname[132];		/* File name on the server */
	long	file_size;		/* Total file size in bytes */
	char	xfer_flag;		/* Transfer flag: 1=send 0=receive */
} pc_file_xfer;
