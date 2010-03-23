




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/****************************** R E A D E R . C ******************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)  13-Feb-86  mby   

 1)   1-May-86  mby   

 2)  11-Jun-86  jsc  Added -u option to arg list for unconstrained set width

 3)  10-Jul-86  jsc  Added -w and -q options for rotation and obliquing

 4)  16-Sep-86  jsc  Switch added to disable plaid utilization (bogus_mode).

 5)   9-Dec-86  mby  Major rewrite.
                     Added 'subset list', 'import widths', 'clip', 'squeeze',
                       'kerning', 'device', 'revision', 'first four'.

 6)  25-Feb-87  mby  Squeezing implies automatic clipping
                     'kerning <filename>'

 7)  20-May-87  mby  'kerning all', 'kerning table', 'kerning table <pathname>'

 ****************************************************************************/


#include "../hfiles/stdef.h"              /* Bitstream standard macros  */
#include "../hfiles/comp2_3.h"            /* data structures for compr'd font */
#include "../hfiles/mkbm.h"
#include "../hfiles/math.h"




/***** STATIC VARIABLES *****/

static  char    g_name_buffer[1024];    /* filename arguments stored here */
static  fix15   g_name_p[21];           /* pointers to arguments (max = 20) */
static  fix15   g_name_total;           /* number of arguments read */
static  fix15   g_name_count;           /* index of current argument */
static  float   g_lpm[256];             /* stores lines per em arguments */
static  fix15   g_lpm_total;            /* number of arguments read */
static  fix15   g_lpm_count;            /* index of current argument */
static  float   g_psz[256];             /* stores point size arguments */
static  fix15   g_psz_total;            /* number of arguments read */
static  fix15   g_psz_count;            /* index of current argument */
static  bool16  fatal_block_error;      /* don't make font from this parameter block */
static  fix15   job_control_file = 0;   /* 1 = yes, -1 = no, 0 = don't know */
static  bool16  setnames;               /* font name exists in j.c.f. or in command line  */
static  bool16  setres;                 /* set horizontal res flag */
static  bool16  setres_h;               /* set horizontal res flag */
static  bool16  setres_v;               /* set vertical res flag */
static  bool16  setres_a;               /* set aspect ratio flag */

/***** EXTERNAL GLOBAL VARIABLES *****/
extern  fix     cfont_fd;           /* compressed font file descriptor      */
extern  char    cfont_name[100];    /* compressed font file name            */
extern  FILE   *mfile_fp;           /* job control file descriptor          */
extern  char    mfile_name[100];    /* job control file name                */
extern  float   aspect_ratio;       /* aspect ratio (default = 1)           */
extern  char    bmap_name_field[4]; /* bitmap font name name field          */
extern  fix15   bmap_dev_field;     /* bitmap font name device field        */
extern  fix15   bmap_rev_field;     /* bitmap font name revision field      */
extern  bool16  bogus_mode;         /* True: plaid data to be ignored       */
extern  boolean clip_left;          /* Clips min x at left of emsquare if true */
extern  boolean clip_right;         /* Clips max x at right of emsquare if true */
extern  boolean clip_bottom;        /* Clips min y at bottom of emsquare if true */
extern  boolean clip_top;           /* Clips max y at top of emsquare if true */
extern  bool16  import_flag;        /* T if import widths option on         */
extern  char    import_name[100];   /* pathname of font for importing widths */
extern  fix15   kerning_flag;       /* 0: no kerning, 1: all pairs, 2: use kerning table */
extern  char    kerning_name[100];  /* pathname with list of kerning pairs  */
extern  float   lines_per_em;       /* vertical lines per em square         */
extern  float   lines_per_emx;      /* horizontal "lines per em"            */
extern  float   point_size_x;       /* x-point size (72.3 pts per inch)     */
extern  float   point_size_y;       /* y-point size (72.3 pts per inch)     */
extern  float   resh;               /* output device resolution, horizontal */
extern  float   resv;               /* output device resolution, vertical   */
extern  float   rot_angle;          /* rotation angle in degrees            */
extern  float   obl_angle;          /* obliquing angle in degrees           */
extern  bool16  setpoint;           /* user parameter is point size         */
extern  bool16  setlines;           /* user parameter is lines per em       */
extern  boolean squeeze_left;       /* Squeezes min x into left of emsquare if true */
extern  boolean squeeze_right;      /* Squeezes max x into right of emsquare if true */
extern  boolean squeeze_bottom;     /* Squeezes min y into bottom of emsquare if true */
extern  boolean squeeze_top;        /* Squeezes max y into top of emsquare if true */
extern  bool16  subset_flag;        /* True: subset chars from list of IDs  */
extern  char    subset_name[100];   /* subset file name                     */
extern  bool16  sw_fixed;           /* true if set width constrained        */
extern  float   xht_adj;            /* x height adjustment                  */


FUNCTION  bool  get_args (argc, argv)
  fix15     argc;
  char    **argv;

/*  GET_ARGS -- reads a set of parameters from either the command line or
 *              a job control file. Assures consistency of lines per em &
 *              point size - resolution
 *  Input arguments:
 *    argc -- argument count
 *    argv -- list of pointers to command line arguments
 *  Returns:
 *    true if able to return a valid set of parameters to main.c
 *  Called from:
 *    main.c
 */

    DECLARE
    char    aa[100];

    bool    command_line_args ();
    bool    params_get();
    fix     getln();
    void    printhelp();

    BEGIN
    if (job_control_file == 0)      /* decide if we have a job control file or not */
        {
        if (argc < 2)           /* if no 2nd argument, quit */
            {
            printhelp();
            exit(0);
            }
        strcpy (cfont_name, *(argv+1));     /* 2nd argument presumably a file name */
        if ((cfont_fd = open (cfont_name, READ)) < 0)   /* try to open the file */
            {
            printf("\n*** Cannot open file %s\n\n", cfont_name);
            exit(0);
            }
        read (cfont_fd, aa, (fix) 4);   /* read the first 4 bytes of this file */
        close (cfont_fd);               /* then close it */
        if (strncmp (aa, "$BFG", 4) == 0)   /* if first 4 bytes are "$BFG", */
            {                              /* then it is a job control file */
            job_control_file = 1;
            strcpy (mfile_name, cfont_name);      /* open for reading as an */
            if ((mfile_fp = fopen (mfile_name, "r")) == NULL) /* ASCII file */
                {
                printf("\n*** Cannot open file %s\n\n", mfile_name);
                exit(0);
                }
            getln (mfile_fp, aa, (fix15)100);   /* flush 1st line = "$BFG"  */
            }
        else                            /* Assume file is a compressed font. */
            {                           /*  All make_bmap parameters will be */
            job_control_file = -1;      /*  read from the command line. */
            if (!command_line_args (argc, argv))
                return (FALSE);
            }
        }

    while (TRUE)
        {
        if (!params_get())          /* read a new set of job control parameters */
            return (FALSE);         /* if no more, then return FALSE */

       /*  Calculate missing parameters here  */
        if (setpoint)               /* calculate lines per em from pointsize */
            lines_per_em = point_size_y * resv / PTPERINCH;
        else                        /* calculate pointsize from lines per em */
            point_size_y = lines_per_em * PTPERINCH / resv;
        point_size_x = point_size_y;
        if (lines_per_em < 5.501)
            {
            printf("point size:  %.2f\n", point_size_y);
            printf("resolution:  %.2f x %.2f\n", resh, resv);
            printf("lines per em:  %.2f \n", lines_per_em);
            printf("*** Not enough scan lines!\n\n");
            close (cfont_fd);
            continue;
            }
        lines_per_emx = point_size_x * resh / PTPERINCH;
                /* Note: lpmx = lpm * aspect_ratio, when psize_x = psize_y  */
        break;
        }

    return(TRUE);       /* returns bitmap font parameters to main module */
    END


FUNCTION  bool  command_line_args (argc, argv)
  fix15     argc;
  char    **argv;

/*  COMMAND_LINE_ARGS -- reads a set of parameters from the command line
 *                       arguments
 *  Input arguments:
 *    argc -- argument count
 *    argv -- list of pointers to command line arguments
 *  Returns:
 *    true if able to return a set of parameters
 *    false if parameters are incomplete
 *  Called from:
 *    get_args
 */

    DECLARE
    char    aa[100];
    char    line1[256];
    char    line2[256];
    char   *line1p;
    fix31   gt;
    fix15   ii;
    fix31   lcount;
    fix31   tleng;
    double  tvalue;
    fix31   ttype;

    bool    block_check();
    void    get_other_args();
    fix31   get_token();
    void    init_params();
    void    mbyte();
    void    printhelp();
    bool    process_option();
    fix31   read_cl_option();

    BEGIN
    if (argc < 3)
        {
        printhelp();
        exit(0);
        }
    argv++;                     /* skip second argument */
    for (ii=3,lcount=0; ii<=argc; ii++)     /* copy all arguments into string 'line1' */
        {
        strcpy (aa, *(++argv));
        tleng = strlen(aa);
        if ((lcount + tleng + 1) > 255)  break;
        mbyte (aa, line1+lcount, tleng);
        lcount += tleng;
        line1[lcount++] = ' ';
        }
    line1[lcount] = 0;

    init_params();
    g_name_total = 1;                       /* 1 font name */
    strcpy (g_name_buffer, cfont_name);     /* load name into name buffer */
    setnames = TRUE;

    /* Do all command line arguments */
    line1p = line1;
    while ((gt = get_token (&line1p, (fix31)100, aa, &tleng, &tvalue)) != 0)
        {
        /* Do all arguments having to do with one option. Stop when reach
           the next option */
        if (gt == 2  &&  (ttype = read_cl_option(aa)) > 0)
            {
            get_other_args (&line1p, line2);
            process_option (ttype, line2);
            }
        else
            printf("\n*** Do not understand argument \"%s\"\n\n", aa);
        }

    if (!block_check())         /* check for proper data in command line */
        return (FALSE);
    return(TRUE);
    END


FUNCTION  static  void  init_params ()

/*  INIT_PARAMS -- initializes and sets defaults
 *    Called from:
 *      command_line_args, read_block
 */
    DECLARE
    fix15   ii;
    char   *q = BMAPDEF;

    BEGIN
    g_name_p[0] = 0;
    g_name_total = 0;
    g_name_count = 0;
    g_lpm_total = 0;
    g_lpm_count = 0;
    g_psz_total = 0;
    g_psz_count = 0;
    fatal_block_error = FALSE;
    setnames = FALSE;
    setres = FALSE;
    setres_h = FALSE;
    setres_v = FALSE;
    setres_a = FALSE;
    aspect_ratio = 1.;
    for (ii=0; ii<4; ii++)
        bmap_name_field[ii] = q[ii];
    bmap_dev_field = 0;
    bmap_rev_field = 1;
    bogus_mode = FALSE;
    clip_left = FALSE;
    clip_right = FALSE;
    clip_bottom = FALSE;
    clip_top = FALSE;
    import_flag = FALSE;
    kerning_flag = 0;
    *kerning_name = '\0';
    lines_per_em = -1.;
    point_size_x = -1.;
    point_size_y = -1.;
    resv = (float)GENERIC;
    resh = (float)GENERIC;
    rot_angle = 0.0;
    obl_angle = 0.0;
    setpoint = FALSE;
    setlines = FALSE;
    squeeze_left = FALSE;
    squeeze_right = FALSE;
    squeeze_bottom = FALSE;
    squeeze_top = FALSE;
    subset_flag = FALSE;
    sw_fixed = TRUE;
    xht_adj = 1.0;
    END


FUNCTION  static  fix31  read_cl_option (token)
  char     *token;

/*  READ_CL_OPTION -- checks to see if command line token is a valid option,
 *                    e.g., "-r", "-p", "-l", etc. The option chosen is
 *                    identified by the return value
 *  Input argument:
 *    token -- a string, such as "-r", etc.
 *  Returns:
 *    long integer -- this identifies the option
 *    -1 if unidentifiable
 *  Called from:
 *    command_line_args, get_other_args
 */
    DECLARE
    BEGIN
    if (strcmp(token,"-l") == 0)
        return (2L);
    else if (strcmp(token,"-p") == 0)
        return (3L);
    else if (strcmp(token,"-r") == 0)
        return (4L);
    else if (strcmp(token,"-h") == 0)
        return (5L);
    else if (strcmp(token,"-v") == 0)
        return (6L);
    else if (strcmp(token,"-a") == 0)
        return (7L);
    else if (strcmp(token,"-d") == 0)
        return (8L);
    else if (strcmp(token,"-w") == 0)
        return (9L);
    else if (strcmp(token,"-q") == 0)
        return (10L);
    else if (strcmp(token,"-b") == 0)
        return (21L);
    else if (strcmp(token,"-u") == 0)
        return (22L);
    else if (strcmp(token,"-i") == 0)
        return (13L);
    else if (strcmp(token,"-c") == 0)
        return (14L);
    else if (strcmp(token,"-z") == 0)
        return (15L);
    else if (strcmp(token,"-s") == 0)
        return (16L);
    else if (strcmp(token,"-kt") == 0)
        return (17L);
    else if (strcmp(token,"-ka") == 0)
        return (24L);
    else if (strcmp(token,"-e") == 0)
        return (18L);
    else if (strcmp(token,"-f") == 0)
        return (23L);
    else
        return (-1L);
    END


FUNCTION  static  void  get_other_args (command_line, arg_line)
  char    **command_line;
  char     *arg_line;

/*  GET_OTHER_ARGS -- This function reads all the arguments that follow a
 *          command line option and saves them in arg_line. For example if the
 *          command line has "-p 6:8, 10, 12", this function reads the
 *          arguments "6:8, 10, 12". Processing stops when the next option
 *          is found
 *  Input argument:
 *    command_line -- whatever remains in the command line
 *  Output arguments:
 *    command_line -- pointer is updated
 *    arg_line -- the arguments are copied into this string
 *  Called from:
 *    command_line_args
 */
    DECLARE
    char    aa[100];        /* tokens are read into here */
    char   *clstart;
    char   *clsave;
    fix31   gt;
    fix31   tleng;
    double  tvalue;

    fix31   get_token();
    fix31   read_cl_option();
    void    mbyte();

    BEGIN
    clstart = *command_line;
    while (TRUE)            /* Stay in loop until command line is finished */
        {                   /*  or until read a new option */
        clsave = *command_line;
        if ((gt = get_token (command_line, (fix31)100, aa, &tleng, &tvalue)) == 0)
            break;
        if (gt == 2)        /* read a string */
            {
            if (read_cl_option(aa) > 0)     /* is it this name of a new option? */
                {
                *command_line = clsave;     /* restore the token */
                break;                      /* exit loop */
                }
            }
        }
    mbyte (clstart, arg_line, (fix31)(clsave - clstart));
    arg_line[(fix31)(clsave - clstart)] = 0;    /* terminate string */
    END


FUNCTION  static  bool  process_option (option_type, arg_line)
  fix31     option_type;
  char     *arg_line;

/*  PROCESS_OPTION -- parses an argument list
 *    Input arguments:
 *      option_type -- identifies option as point size, aspect ratio, etc.
 *      arg_line -- list of 0 or more arguments
 *    Returns:
 *      true unless end-of-block token ( "$" ) is found
 *    Called from:
 *      command_line_args, read_block
 */
    DECLARE
    char    line[512];          /* buffer */
    fix15   ii, jj;
    bool16  zz;
    bool    arg_fontnames();
    bool    arg_lpm();
    bool    arg_pointsz();
    bool    arg_rezo();
    bool    arg_devrev();
    bool    arg_rotobl();
    bool    arg_isk4();
    bool    arg_squeeze_clip();

    BEGIN
    zz = TRUE;
    for (ii=0, jj=0; ; ii++)        /* make it easy to read */
        {
        if (arg_line[ii] == ',')        /* treat comma as a space */
            line[jj++] = ' ';
        else if (arg_line[ii] == ':')   /* make sure colon is separated   */
            {                           /* from other arguments by spaces */
            line[jj++] = ' ';
            line[jj++] = ':';
            line[jj++] = ' ';
            }
        else
            line[jj++] = arg_line[ii];
        if (arg_line[ii] == 0)          /* end of string terminates */
            break;
        }

    switch ((fix)option_type)    {

    case 1:                     /* name(s) of font(s) */
        if (arg_fontnames (line))
            setnames = TRUE;
        break;

    case 2:                     /* lines per em(s) */
        if (arg_lpm (line))
            setlines = TRUE;
        break;

    case 3:                     /* point size(s) */
        if (arg_pointsz (line))
            setpoint = TRUE;
        break;

    case 4:                     /* resolution (x & y) */
        arg_rezo (line, option_type, "resolution");
        break;

    case 5:                     /* resolution, x */
        arg_rezo (line, option_type, "horizontal resolution");
        break;

    case 6:                     /* resolution, y */
        arg_rezo (line, option_type, "vertical resolution");
        break;

    case 7:                     /* aspect ratio (x / y) */
        arg_rezo (line, option_type, "aspect ratio");
        break;

    case 8:                     /* device number */
        arg_devrev (line, option_type, "device");
        break;

    case 9:                     /* rotation angle */
        arg_rotobl (line, option_type, "rotate");
        break;

    case 10:                    /* obliquing angle */
        arg_rotobl (line, option_type, "oblique");
        break;

    case 11:                    /* plaid mode */
        bogus_mode = FALSE;
        break;

    case 12:                    /* set width constrained */
        sw_fixed = TRUE;
        break;

    case 13:                    /* import widths */
        if (arg_isk4 (line, option_type))
            import_flag = TRUE;
        break;

    case 14:                    /* clip */
        arg_squeeze_clip (line, option_type, "clip");
        break;

    case 15:                    /* squeeze */
        arg_squeeze_clip (line, option_type, "squeeze");
        break;

    case 16:                    /* subset list */
        if (arg_isk4 (line, option_type))
            subset_flag = TRUE;
        break;

    case 17:                    /* kerning table <pathname> - kerning pairs & */
        if (arg_isk4 (line, option_type))   /*  tracks in font */
            kerning_flag = 2;
        break;

    case 18:                    /* revision */
        arg_devrev (line, option_type, "revision");
        break;

    case 19:                    /* end of block ( $ )  */
        zz = FALSE;
        break;

    case 20:                    /* logical end of line (end or comment)  */
        break;

    case 21:                    /* no plaid mode */
        bogus_mode = TRUE;
        break;

    case 22:                    /* set width unconstrained */
        sw_fixed = FALSE;
        break;

    case 23:                    /* first four characters */
        arg_isk4 (line, option_type);
        break;

    case 24:                    /* kerning all - kerning pairs & tracks in font */
        kerning_flag = 1;
        break;

    default:
        break;
        }                   /* end of CASE statement */

    return (zz);

    END


FUNCTION  static  bool  arg_fontnames (line_buffer)
  char     *line_buffer;

/*  ARG_FONTNAMES -- gets a list of file names (strings) from line_buffer
 *  Input argument:
 *    line_buffer -- source string containing list of file names
 *  Returns:
 *    true if at >= 1 argument was found (no verification here)
 *    writes static  g_name_buffer, g_name_p, g_name_total
 *  Called from:
 *    process_option
 */
    DECLARE
    fix31   mm;
    fix15   old_total;      /* previous argument total */
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    tok[100];       /* token goes here */
    fix31   get_token();
    
    BEGIN
    old_total = g_name_total;
    while (TRUE)
        {
        tkn = get_token (&line_buffer, (fix31)100, tok, &tknsize, &tknvalue);
        if (tkn == 0  ||  tkn == 4)     /* break at end of line or semicolon */
            break;
        mm = g_name_p[g_name_total];
        if ((mm + tknsize + 1) > 1024)      /* max of 1024 */
            {                                       /* bytes for storing names */
            printf("\n*** Out of room to store pathnames\n");
            printf("\n*** %ld pathnames read\n\n", g_name_total);
            break;
            }
        strcpy (g_name_buffer + mm, tok);   /* copy string argument */
        g_name_total++;
        g_name_p[g_name_total] = mm + tknsize + 1;  /* set pointer to next */
        if (g_name_total >= 20)
            {
            printf("\n*** Job Control File has a limit of 20 pathnames per block\n\n");
            break;
            }
        }
    if (g_name_total > old_total)   /* have we read any new arguments? */
        return(TRUE);               /* if yes, return true */
    else
        return(FALSE);
    END


FUNCTION  static  bool  arg_lpm (line_buffer)
  char     *line_buffer;

/*  ARG_LPM -- gets a list of lines per em arguments
 *  Input argument:
 *    line_buffer -- source string containing list of numbers
 *  Returns:
 *    true if at >= 1 argument was found
 *    writes static  g_lpm, g_lpm_total
 *  Called from:
 *    process_option
 */
    DECLARE
    fix15   ii;
    fix15   num_args;       /* number of arguments read this time */
    fix15   old_total;      /* previous argument total */
    void    get_numbers();  /* parses and stores a list of numbers */

    BEGIN
    old_total = g_lpm_total;
    /*  Put list of numbers into g_lpm array */
    get_numbers (line_buffer, g_lpm, &g_lpm_total, "lines per em");
    num_args = g_lpm_total - old_total;
    for (ii=old_total; ii<g_lpm_total; ii++)  /* verify that all arguments */
        {                             /* are integer and >= 6 lines per em */
        if (g_lpm[ii] != floor(g_lpm[ii])  ||  g_lpm[ii] < 6.)
            {
            printf ("\n  ** lines per em  %s\n", line_buffer);
            printf ("  ** Illegal value: \"%.2f\"\n\n", g_lpm[ii]);
            g_lpm[ii] = 0.;
            num_args--;
            }
        }

    if (num_args > 0)
        return(TRUE);
    else
        return(FALSE);
    END


FUNCTION  static  bool  arg_pointsz (line_buffer)
  char     *line_buffer;

/*  ARG_POINTSZ -- gets a list of point size arguments
 *  Input argument:
 *    line_buffer -- source string containing list of numbers
 *  Returns:
 *    true if at >= 1 argument was found
 *    writes static  g_psz, g_psz_total
 *  Called from:
 *    process_option
 */
    DECLARE
    fix15   ii;
    fix15   num_args;       /* number of arguments read this time */
    fix15   old_total;      /* previous argument total */
    void    get_numbers();  /* parses and stores a list of numbers */

    BEGIN
    old_total = g_psz_total;
    /*  Put list of numbers into g_psz array */
    get_numbers (line_buffer, g_psz, &g_psz_total, "point size");
    num_args = g_psz_total - old_total;
    for (ii=old_total; ii<g_psz_total; ii++)  /* verify that point size >= 2.0 */
        {
        if (g_psz[ii] < 2.)
            {
            printf ("\n  ** point size  %s\n", line_buffer);
            printf ("  ** Illegal value: \"%.2f\"\n\n", g_psz[ii]);
            g_psz[ii] = 0.;
            num_args--;
            }
        }

    if (num_args > 0)
        return(TRUE);
    else
        return(FALSE);
    END


FUNCTION  static  bool  arg_rezo (line_buffer, option_type, error_msg)
  char     *line_buffer;
  fix31     option_type;
  char     *error_msg;

/*  ARG_REZO -- gets 1 argument for either horizontal/vertical resolution,
 *              aspect ratio. 'aspect_ratio', 'resh', and 'resv' are always
 *              maintained consistent (i.e., a = rh / rv)
 *  Input arguments:
 *    line_buffer -- source string
 *    option_type -- resolution, hres, vres, or aspect ratio
 *    error_msg -- printed if bad argument found
 *  Returns:
 *    true if an argument is found
 *    writes static  setres_h, setres_v, setres_a
 *    writes globals  resh, resv, aspect_ratio
 *  Called from:
 *    process_option
 */
    DECLARE
    fix15   ii;
    char   *orig_buff;
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    token[100];     /* token goes here */
    fix31   get_token();

    BEGIN
    orig_buff = line_buffer;
    tkn = get_token (&line_buffer, (fix31)100, token, &tknsize, &tknvalue);

    if (tkn == 1  &&  tknvalue > 0.)
        {
        if (option_type == 4)           /* resolution */
            {
            if ((setres_h && setres_v) || (setres_a && (setres_h || setres_v)))
                {
                printf ("\n  ** resolution  %.2f\n", tknvalue);
                printf ("  ** Redundant. This parameter will be ignored.\n\n");
                }
            else
                {
                setres = TRUE;
                if (!setres_h)
                    resh = tknvalue;
                    if (setres_a)
                        resh = tknvalue * aspect_ratio;
                if (!setres_v)
                    resv = tknvalue;
                aspect_ratio = resh / resv;
                }
            }
        else if (option_type == 5)      /* horizontal resolution */
            {
            if (setres_h || (setres_v && setres_a) || setres)
                {
                printf ("\n  ** horizontal resolution  %.2f\n", tknvalue);
                printf ("  ** Redundant. Overrides existing parameter.\n\n");
                }
            resh = tknvalue;
            setres_h = TRUE;
            if (setres_a  &&  !setres_v)
                resv = resh / aspect_ratio;
            else
                aspect_ratio = resh / resv;
            }
        else if (option_type == 6)      /* vertical resolution */
            {
            if (setres_v || (setres_h && setres_a) || setres)
                {
                printf ("\n  ** vertical resolution  %.2f\n", tknvalue);
                printf ("  ** Redundant. Overrides existing parameter.\n\n");
                }
            resv = tknvalue;
            setres_v = TRUE;
            if (setres_a && !setres_h)
                resh = aspect_ratio * resv;
            else
                aspect_ratio = resh / resv;
            }
        else if (option_type == 7)      /* aspect ratio */
            {
            if ((setres_h && setres_v)  ||  setres_a  ||  setres)
                printf ("\n  ** aspect ratio  %.2f\n  ** Redundant. ", tknvalue);

            if (setres_h && setres_v)
                printf ("This parameter will be ignored.\n\n");
            else
                {
                if (setres_a || setres)
                    printf ("Overrides existing parameter.\n\n");
                aspect_ratio = tknvalue;
                if (setres_h)
                    resv = resh / aspect_ratio;
                else
                    resh = aspect_ratio * resv;
                setres_a = TRUE;
                }
            }
        }

    else
        {
        printf ("\n  ** %s   %s\n", error_msg, orig_buff);
        printf ("  ** Bad argument: \"%s\"\n\n", token);
        fatal_block_error = TRUE;
        return(FALSE);
        }

    END


FUNCTION  static  bool  arg_devrev (line_buffer, option_type, error_msg)
  char     *line_buffer;
  fix31     option_type;
  char     *error_msg;

/*  ARG_DEVREV -- gets 1 integer argument from line_buffer
 *  Input argument:
 *    line_buffer -- source string
 *    option_type -- device number, or revision number
 *    error_msg -- printed if bad argument found
 *  Returns:
 *    true if an argument is found
 *    writes globals  bmap_dev_field, bmap_rev_field
 *  Called from:
 *    process_option
 */
    DECLARE
    char   *orig_buff;
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    token[100];     /* token goes here */
    fix31   get_token();

    BEGIN
    orig_buff = line_buffer;
    tkn = get_token (&line_buffer, 100L, token, &tknsize, &tknvalue);
    if (tkn != 1  ||  tknvalue < 0.  ||  tknvalue != floor(tknvalue))
        {
        printf ("\n  ** %s   %s\n", error_msg, orig_buff);
        printf ("  ** Bad argument: \"%s\"\n\n", token);
        fatal_block_error = TRUE;
        return (FALSE);
        }
    if (option_type == 8)
        bmap_dev_field = tknvalue;
    else
        bmap_rev_field = tknvalue;
    return (TRUE);
    END


FUNCTION  static  bool  arg_rotobl (line_buffer, option_type, error_msg)
  char     *line_buffer;
  fix31     option_type;
  char     *error_msg;

/*  ARG_ROTOBL -- gets 1 numeric argument for rotation or obliquing angle
 *  Input arguments:
 *    line_buffer -- source string
 *    option_type -- rotation or obliquing angle
 *    error_msg -- printed if bad argument found
 *  Returns:
 *    true if an argument is found
 *    writes globals  rot_angle, obl_angle
 *  Called from:
 *    process_option
 */
    DECLARE
    char   *orig_buff;
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    token[100];     /* token goes here */
    fix31   get_token();

    BEGIN
    orig_buff = line_buffer;
    tkn = get_token (&line_buffer, 100L, token, &tknsize, &tknvalue);
    if (tkn != 1  ||  (option_type == 10  &&  ABS(tknvalue) >= 90.))
        {
        printf ("\n  ** %s   %s\n", error_msg, orig_buff);
        printf ("  ** Bad argument: \"%s\"\n\n", token);
        fatal_block_error = TRUE;
        return (FALSE);
        }
    if (option_type == 9)
        rot_angle = tknvalue;
    else
        obl_angle = tknvalue;
    return (TRUE);
    END


FUNCTION  static  bool  arg_isk4 (line_buffer, option_type)
  char     *line_buffer;
  fix31     option_type;

/*  ARG_ISK4 -- gets a file name or string from line_buffer
 *  Input arguments:
 *    line_buffer -- source string
 *    option_type -- import width, subset list, kerning-pair-list file,
 *                   or bitmap font name field
 *  Returns:
 *    true if an argument is found
 *    writes globals  import_name, subset_name, kerning_name, bmap_name_field
 *  Called from:
 *    process_option
 */
    DECLARE
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    tok[100];       /* token goes here */
    fix31   get_token();
    void    mbyte();

    BEGIN
    tkn = get_token (&line_buffer, 100L, tok, &tknsize, &tknvalue);
    if (option_type == 17  &&  tkn == 0)
        {
        mbyte (KERNDEF, kerning_name, (fix31)22);
        return (TRUE);
        }
    if (tkn == 0  ||  tkn == 4)
        return (FALSE);
    if (option_type == 16)
        strcpy (subset_name, tok);
    else if (option_type == 17)
        strcpy (kerning_name, tok);
    else if (option_type == 13)
        strcpy (import_name, tok);
    else if (option_type == 23)
        mbyte (tok, bmap_name_field, (fix31)4);
    return (TRUE);
    END


FUNCTION  static  bool  arg_squeeze_clip (line_buffer, option_type, error_msg)
  char     *line_buffer;
  fix31     option_type;
  char     *error_msg;

/*  ARG_SQUEEZE_CLIP -- gets squeezing and clipping arguments (left, right,
 *                      bottom, top). Squeezing implies clipping, even if
 *                      clipping is not explicitly declared.
 *  Input arguments:
 *    line_buffer -- source string
 *    option_type -- clip, squeeze
 *    error_msg -- printed if bad argument found
 *  Writes globals  {clip, squeeze} {_left, _right, _top, _bottom}
 *  Called from:
 *    process_option
 */
    DECLARE
    char   *orig_buff;
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    char    token[100];     /* token goes here */
    fix31   get_token();

    BEGIN
    orig_buff = line_buffer;
    while ((tkn = get_token (&line_buffer, 100L, token, &tknsize, &tknvalue)) != 0  &&  tkn != 4)
        {
        if (strcmp (token, "left") == 0)
            {
            clip_left = TRUE;
            if (option_type == 15)
                squeeze_left = TRUE;
            }
        else if (strcmp (token, "right") == 0)
            {
            clip_right = TRUE;
            if (option_type == 15)
                squeeze_right = TRUE;
            }
        else if (strcmp (token, "bottom") == 0)
            {
            clip_bottom = TRUE;
            if (option_type == 15)
                squeeze_bottom = TRUE;
            }
        else if (strcmp (token, "top") == 0)
            {
            clip_top = TRUE;
            if (option_type == 15)
                squeeze_top = TRUE;
            }
        else
            {
            printf ("\n  ** %s   %s\n", error_msg, orig_buff);
            printf ("  ** Bad argument: \"%s\"\n\n", token);
            fatal_block_error = TRUE;
            }
        }
    return (TRUE);
    END


FUNCTION  static  void  get_numbers (line_buffer, num_buffer, num_count,
                                     error_msg)
/*  GET_NUMBERS -- parses a list of numeric arguments. The list can
 *          include runs of the form 6 : 10, or 6 : 7 : .1
 *          The first number is the initial value, the second number
 *          is the final value, and the last number is the step size.
 *    Input arguments:
 *      line_buffer -- source string containing list of numbers
 *      error_msg -- printed if bad argument found
 *    Output arguments:
 *      num_buffer -- numeric arguments are put here
 *      num_count -- number of numeric arguments
 *    Returns:
 *      true if at >= 1 argument was found
 *    Called from:
 *      arg_lpm, arg_pointsz
 */
  char     *line_buffer;
  float    *num_buffer;
  fix15    *num_count;
  char     *error_msg;

    DECLARE
    double  argvalue;
    bool    load_break;     /* stores numbers on break */
    bool    load_number;    /* stores numbers when token type 1 found */
    bool    loop_flag;
    char   *orig_buff;
    bool    rstart;         /* start argument flag */
    bool    rcolon;         /* argument range accept */
    bool    rend;           /* end argument flag */
    fix31   tkn;            /* returned by get_token */
    fix31   tknsize;        /* size of token string */
    double  tknvalue;       /* value of token, if number */
    double  tok_start;      /* first value in argument run */
    double  tok_end;        /* final value in argument run */
    double  tok_step;       /* step size in argument run */
    char    token[100];     /* token goes here */
    fix31   get_token();
    
    BEGIN
    orig_buff = line_buffer;  /* save original line_buffer */
    rcolon = FALSE;
    rstart = TRUE;
    load_number = FALSE;
    load_break = FALSE;
    loop_flag = TRUE;
    while (loop_flag)
        {
        tkn = get_token (&line_buffer, (fix31)100, token, &tknsize, &tknvalue);
        if (tkn == 4  ||  tkn == 0)     /* quit at end of line, or semicolon */
            loop_flag = FALSE;
        if ((tkn == 1 && load_number)  ||  (!loop_flag && load_break))
            {
            for (argvalue = tok_start; argvalue <= tok_end; argvalue += tok_step)
                {
                if (*num_count >= 256)
                    {
                    printf ("%s  %s\n", error_msg, orig_buff);
                    printf ("*** More than 256 arguments\n\n");
                    return;
                    }
                num_buffer[*num_count] = argvalue;
                (*num_count)++;
                }
            load_break = FALSE;
            load_number = FALSE;
            rcolon = FALSE;
            rstart = TRUE;
            }
        if (tkn == 1)           /* token is a number */
            {
            if (rstart)
                {
                tok_start = tknvalue;   /* start argument */
                tok_end = tknvalue;     /* default: end = start */
                tok_step = 1.;          /* default: step = 1 */
                rcolon = TRUE;
                rend = FALSE;
                }
            else if (rend)
                {
                tok_end = tknvalue;     /* end argument */
                if (tok_end < tok_start)    /* must be greater than start arg */
                    tok_end = tok_start;
                rcolon = TRUE;
                }
            else
                {
                tok_step = tknvalue;    /* step value */
                if (tok_step <= 0.)         /* must be greater than 0 */
                    (tok_step = 1000000.);
                }
            load_number = TRUE;
            load_break = TRUE;
            }
        else if (tkn == 3  &&  rcolon)  /* accept ":" if rcolon TRUE */
            {
            rcolon = FALSE;
            if (rend)
                rend = FALSE;
            else if (rstart)
                {
                rend = TRUE;
                rstart = FALSE;
                }
            load_number = FALSE;
            continue;
            }
        else if (loop_flag)
            {
            printf ("\n  ** %s   %s\n", error_msg, orig_buff);
            printf ("  ** Bad argument: \"%s\"\n\n", token);
            load_number = TRUE;
            }
        }
    return;
    END


FUNCTION  static  void  printhelp()
/*
Usage:

    make_bmap  <compressed_font> [options]     OR

    make_bmap  <job_control_file>


    Options:   -l  -p  -r  -h  -v  -a  -w  -q  -b  -u
               -i  -c  -z  -s  -kt  -ka  -f  -d  -e

    Job Control File Format:
        $BFG
        keyword1    <arguments>
        keyword2    <arguments>
        ...
        keywordN    <arguments>
        $           <block terminator>
        etc.

    Keywords:   compressed font    lines per em    point size    resolution
        horizontal resolution    vertical resolution    aspect ratio
        rotate    oblique    plaid mode    no plaid mode
        set width unconstrained    set width constrained    import    clip
        squeeze    subset list    kerning all    kerning table    first four
        device    revision


    Use <HELP> make_bmap  for complete information on the options and format
    of the job control file.
*/
    DECLARE
    BEGIN
    printf("\nUsage:\n\n    make_bmap  <compressed_font> [options]     OR\n\n");
    printf("    make_bmap  <job_control_file>\n\n\n");
    printf("    Options:   -l  -p  -r  -h  -v  -a  -w  -q  -b  -u\n");
    printf("               -i  -c  -z  -s  -kt  -ka  -f  -d  -e\n\n");
    printf("    Job Control File Format:\n");
    printf("        $BFG\n");
    printf("        keyword1    <arguments>\n");
    printf("        keyword2    <arguments>\n");
    printf("        ...\n");
    printf("        keywordN    <arguments>\n");
    printf("        $           <block terminator>\n");
    printf("        etc.\n\n");
    printf("    Keywords:   compressed font    lines per em    point size    resolution\n");
    printf("        horizontal resolution    vertical resolution    aspect ratio\n");
    printf("        rotate    oblique    plaid mode    no plaid mode\n");
    printf("        set width unconstrained    set width constrained    import    clip\n");
    printf("        squeeze    subset list    kerning all    kerning table    first four\n");
    printf("        device    revision\n\n\n");
    printf("    Use <HELP> make_bmap  for complete information on the options and format\n");
    printf("    of the job control file.\n\n\n");
    END


FUNCTION  static  bool  params_get ()

/*  PARAMS_GET -- Find a valid set of parameters
 *  Returns:
 *    true if able to find a valid set of parameters
 *  Called from:
 *    get_args
 */

    DECLARE
    fix31   r;
    bool    params_next();
    fix31   read_block();   /* reads a specification block from a job control file */

    BEGIN
    while (TRUE)
        {           /* check if any more parameters in current data block */
        if (params_next())      /* find new parameters */
            break;
        while ((r = read_block()) == 0);    /* bad block, read next one */
        if (r == -1)                        /* EOF, exit program */
            return(FALSE);
        }

    return (TRUE);
    END


FUNCTION  static  bool  params_next ()

/*  PARAMS_NEXT -- Tries to find more parameters in current data block
 *  Returns:
 *    true if able to find valid, unused parameters
 *    writes globals  point_size_y, lines_per_em, cfont_name,
 *      cfont_fd
 *  Called from:
 *    params_get
 */

    DECLARE
    BEGIN
    while (TRUE)
        {
        if (setpoint)               /* get pointsize */
            {
            if (g_psz_count >= g_psz_total)
                {
                g_name_count++;
                g_psz_count = 0;
                }
            if ((point_size_y = g_psz[g_psz_count++]) == 0.)
                continue;
            }

        else if (setlines)          /* get lines per em */
            {
            if (g_lpm_count >= g_lpm_total)
                {
                g_name_count++;
                g_lpm_count = 0;
                }
            if ((lines_per_em = g_lpm[g_lpm_count++]) == 0.)
                continue;
            }

        else
            return (FALSE); 

        if (g_name_count >= g_name_total)
            return (FALSE);
        strcpy(cfont_name, g_name_buffer + g_name_p[g_name_count]);  /* file name */

        if ((cfont_fd = open (cfont_name, READ)) < 0)
            {
            printf("\n*** Cannot open file %s\n\n", cfont_name);
            g_name_count++;
            g_psz_count = 0;
            g_lpm_count = 0;
            }
        else
            return (TRUE);
        }
    END


FUNCTION  static  fix31  read_block()

/*  READ_BLOCK -- Reads a block containing parameters for font-name,
 *                lines-per-em, point-size, device-resolution, etc.
 *  Returns:
 *     1 = OK
 *     0 = bad block, insufficient or inconsistent parameters
 *    -1 = end of file. Also if there is no job control file
 *  Called from:
 *    params_get
 */
    DECLARE
    char    line[256];
    char   *line1;
    fix31   spec_type;
    bool    new_block;

    bool    block_check();
    fix     getln();
    void    init_params();
    bool    process_options();
    char   *read_spec();


    BEGIN
    if (job_control_file == -1)   /* if no job control file, it's all over */
        return ((fix31) -1);

    init_params();
    new_block = TRUE;
    while (TRUE)
        {
        if (getln (mfile_fp, line, 256) == -1)    /* read 1 line from job control file */
            {
            if (new_block)
                return ((fix31) -1);
            break;                                /* break on EOF */
            }
        new_block = FALSE;
        printf("%s\n", line);
        line1 = read_spec (line, &spec_type);     /* find out what keyword */
        if (!process_option (spec_type, line1))   /* break when "$" found */
            break;
        }

    if (!block_check())         /* check for proper data in block */
        return ((fix31) 0);
    return((fix31) 1);
    END


FUNCTION  static  char  *read_spec (linebuffer, spec_type)
  char     *linebuffer;         /* 1 line of the job control file */
  fix31    *spec_type;          /* specifier type */

/* READ_SPEC -- Searches the beginning of 1 line of the job control file for
 *      keywords ("compressed font", "lines per em", etc.)
 *  Input argument:
 *    linebuffer -- pointer to line of the job control file
 *  Output argument:
 *    spec_type -- integer keyword identifier
 *    linebuffer -- has been updated to point beyond the keyword
 *  Returns:
 *    string pointer to arguments immediately following the keywords
 *  Called from:
 *    read_block
 */
    DECLARE
    char    cc;

    BEGIN
    while ((cc = *linebuffer++) <= ' '  && cc != '\0');   /* remove blank chars */
    linebuffer--;

    if (strncmp (linebuffer, "compressed fonts ", 17) == 0)
        {
        *spec_type = 1;
        return (linebuffer + 17);
        }
    else if (strncmp (linebuffer, "compressed font ", 16) == 0)
        {
        *spec_type = 1;
        return (linebuffer + 16);
        }
    else if (strncmp (linebuffer, "lines per em ", 13) == 0)
        {
        *spec_type = 2;
        return (linebuffer + 13);
        }
    else if (strncmp (linebuffer, "point size ", 11) == 0)
        {
        *spec_type = 3;
        return (linebuffer + 11);
        }
    else if (strncmp (linebuffer, "resolution ", 11) == 0)
        {
        *spec_type = 4;
        return (linebuffer + 11);
        }
    else if (strncmp (linebuffer, "horizontal resolution ", 22) == 0)
        {
        *spec_type = 5;
        return (linebuffer + 22);
        }
    else if (strncmp (linebuffer, "vertical resolution ", 20) == 0)
        {
        *spec_type = 6;
        return (linebuffer + 20);
        }
    else if (strncmp (linebuffer, "aspect ratio ", 13) == 0)
        {
        *spec_type = 7;
        return (linebuffer + 13);
        }
    else if (strncmp (linebuffer, "device ", 7) == 0)
        {
        *spec_type = 8;
        return (linebuffer + 7);
        }
    else if (strncmp (linebuffer, "rotate ", 7) == 0)
        {
        *spec_type = 9;
        return (linebuffer + 7);
        }
    else if (strncmp (linebuffer, "oblique ", 8) == 0)
        {
        *spec_type = 10;
        return (linebuffer + 8);
        }
    else if (strncmp (linebuffer, "plaid mode", 10) == 0)
        {
        *spec_type = 11;
        return (linebuffer + 10);
        }
    else if (strncmp (linebuffer, "no plaid mode", 13) == 0)
        {
        *spec_type = 21;
        return (linebuffer + 13);
        }
    else if (strncmp (linebuffer, "set width constrained", 21) == 0)
        {
        *spec_type = 12;
        return (linebuffer + 21);
        }
    else if (strncmp (linebuffer, "set width unconstrained", 23) == 0)
        {
        *spec_type = 22;
        return (linebuffer + 23);
        }
    else if (strncmp (linebuffer, "import widths ", 14) == 0)
        {
        *spec_type = 13;
        return (linebuffer + 14);
        }
    else if (strncmp (linebuffer, "clip ", 5) == 0)
        {
        *spec_type = 14;
        return (linebuffer + 5);
        }
    else if (strncmp (linebuffer, "squeeze ", 8) == 0)
        {
        *spec_type = 15;
        return (linebuffer + 8);
        }
    else if (strncmp (linebuffer, "subset list ", 12) == 0)
        {
        *spec_type = 16;
        return (linebuffer + 12);
        }
    else if (strncmp (linebuffer, "kerning table", 13) == 0)
        {
        *spec_type = 17;
        return (linebuffer + 13);
        }
    else if (strncmp (linebuffer, "revision ", 9) == 0)
        {
        *spec_type = 18;
        return (linebuffer + 9);
        }
    else if (*linebuffer == '$')
        {
        *spec_type = 19;
        return (linebuffer);
        }
    else if (*linebuffer == '\0'  ||  *linebuffer == ';')
        {
        *spec_type = 20;
        return (linebuffer);
        }
    else if (strncmp (linebuffer, "first four ", 11) == 0)
        {
        *spec_type = 23;
        return (linebuffer + 11);
        }
    else if (strncmp (linebuffer, "kerning all", 11) == 0)
        {
        *spec_type = 24;
        return (linebuffer + 11);
        }
    else
        {
        printf("\n*** Do not understand line \"%s\"\n\n", linebuffer);
        *spec_type = -1;
        return (linebuffer);
        }
    END


FUNCTION  static  bool  block_check ()

/*  BLOCK_CHECK -- verify that a font file has been selected as well as a
 *          point size or line per em (but not both)
 *  Returns:
 *    true if meets the above condition
 *  Called from:
 *    command_line_args, read_block
 */

    DECLARE
    BEGIN
    if (!setnames)
        {
        printf ("\n*** No font file name has been selected\n\n");
        return (FALSE);
        }
    if ((!setpoint  &&  !setlines)  ||  (setpoint  &&  setlines))
        {
        printf ("\n*** You must choose either lines per em or point size, but not both\n\n");
        return (FALSE);
        }
    if (fatal_block_error)
        return (FALSE);

    return(TRUE);
    END


FUNCTION  static  fix31  get_token (linebuff, maxs, tkbuff, tksize, tkvalue)
  char    **linebuff;
  fix31     maxs;
  char     *tkbuff;
  fix31    *tksize;
  double   *tkvalue;

/* GET_TOKEN -- takes a pointer to a string and extracts a token. The pointer
 *              to the original string is updated so that it points past the
 *              end of the token that was read. Information about the token is
 *              returned.
 * Input arguments:
 *   linebuff -- string containing tokens to be parsed
 *   maxs -- maximum token size
 * Output arguments:
 *   tkbuff -- string containing a token
 *   tksize -- size of token string in bytes (without null)
 *   tkvalue -- real number (ignore if token not of type 1)
 *   linebuff -- new string, beyond the current token
 * Returns:
 *   token type: 0 = null (the end)          1 = number
 *               2 = string (not a number)   3 = colon
 *               4 = semicolon
 * Called from:
 *   command_line_args,
 */

    DECLARE
    char    c;
    fix31   count;
    double  ff;
    fix31   n;
    bool16  neg;                /* true if number is negative */
    bool16  nmm;                /* true if string is really a number */
    char   *newbuff;
    char   *tkbuff1;

    BEGIN
    count = 0;
    newbuff = *linebuff;
    tkbuff1 = tkbuff;
    c = *newbuff;

    while ((c = *newbuff++) <= ' '  &&  c != '\0')    /* remove initial spaces */
        (*linebuff)++;                                /*  & control characters */

    if (c == '\0'  ||  maxs <= 1)   /* null token or no room for it */
        {
        *tksize = 0;
        *tkbuff = '\0';
        return (0L);
        }

    if (c == ':'  ||  c == ';')     /* colon, semicolon */
        {
        *tkbuff++ = c;
        *tkbuff = '\0';
        *tksize = 1;
        (*linebuff)++;
        if (c == ':')  return (3L);
        if (c == ';')  return (4L);
        }

    else                            /* string, and possibly a number */
        {                           /* first, capture entire string */
        newbuff = *linebuff;
        while ((c = *newbuff++) > ' '  &&  c != ';' )
            {
            *tkbuff++ = c;
            count++;
            if (count == maxs - 1)  break;
            }
        *tkbuff = '\0';
        *tksize = count;
        (*linebuff) += count;

        neg = FALSE;                /* now check to see if it's a number */
        nmm = FALSE;
        *tkvalue = 0.;
        if (*tkbuff1 == '-')
            {
            neg = TRUE;
            tkbuff1++;
            }
        while ((n = ((fix15)(*tkbuff1 - '0'))) >= 0  &&  n <= 9)
            {
            nmm = TRUE;
            *tkvalue = *tkvalue * 10. + n;
            tkbuff1++;
            }
        if (*tkbuff1 == '.')
            {
            tkbuff1++;
            ff = 10.;
            while ((n = ((fix15)*tkbuff1 - 48)) >= 0  &&  n <= 9)
                {
                nmm = TRUE;
                *tkvalue = *tkvalue + (n / ff);
                ff *= 10.;
                tkbuff1++;
                }
            if (*tkbuff1 != '\0')
                return (2L);
            }
        else if (*tkbuff1 != '\0')
            return (2L);
        if (!nmm)
            return (2L);
        if (neg)  *tkvalue = -*tkvalue;
        return (1L);
        }

    END
