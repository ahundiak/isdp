# ifndef EMmsg_obj_include
# define EMmsg_obj_include 1

/*
 * Enumerated data-types that 
 * indicate different types of 
 * data.
 */

enum EMdatatype 
  {
  EMpoints,     /* Data is an array of type IGRpoint */
  EMcurve,      /* Data is of type struct IGRbsp_curve */
  EMmsg_obj,    /* Data is of type struct EMmsg_obj */
  EMsurface,    /* Data is of type struct IGRbsp_surface */
  EMgendata     /* Data is of type enum EMdatatype */
  };

/*
 * This structure contains the addresses
 * of the fields in the argument-list of
 * the message that is part of the implied 
 * datatype EMmsg_obj. These addresses allow
 * access to the relevant parts of the
 * argument-list. In the case of curves, only
 * a subset of these fields is used.
 */

struct EMcomm_struct
  {            
  IGRint *u_from, *v_from;     /* Addresses of the memory locations into which
                                  the starting indices (of U, i.e., rows and 
                                  V, i.e., columns) of the data
                                  to be transferred are to be placed. */
  IGRint *u_offset, *v_offset; /* Addresses of the memory location into which
                                  the number of units of data (in the U
                                  and the V direction) needed, are to be
                                  placed. */
  IGRchar **buff;              /* Address of the memory location into which
                                  the ADDRESS of the allocated buffer is to
                                  be placed */
  IGRint *buff_size;           /* Address of the memory location into which
                                  the size of the allocated buffer needs to be
                                  placed (size in bytes) */
  IGRboolean *is_reg;          /* Address of the memory location in which
                                  the 'regular-points' flag is returned.
                                  Disregarded in the case of curves.
                                  This flag is TRUE if the number of points
                                  in each of the v_rows is the same. (A
                                  rectangular matrix of points). This flag
                                  is disregarded if only a single row of 
                                  points is being returned. */
  IGRint *num_rows;            /* Address of the memory locations in which
                                  the number of rows (in the v-direction)
                                  that have been returned. (The convention
                                  is the points being placed as
                                  U-major, i.e., row major. */
  IGRint **num_inrow;          /* Address of the address where the array
                                  containing the number of points in each
                                  row are stored. If the 'is_reg' flag is
                                  set or the reference is to a curve,
                                  only the first element in this array
                                  need be looked at. */
  IGRlong *msg;                /* Address of the memory location in which
                                  the return code will be place. */
  };



/* 
 * Data conveyed using this structure
 * is not explicit but implied. This is
 * analogous to a level of indirection.
 */

struct EMmsg_obj
  {
  enum EMdatatype out_datatype;   /* Data type of the data extracted by
                                     the following message send */
  OM_p_MESSAGE msg;               /* Pointer to a message structure,
                                     possibly created by an OM_make_message */
  struct GRid object;             /* Object id and OS-number of the
                                     object containing the data */
  enum OM_e_wrt_flag wrt_flag;    /* The flag that is the first argument in
                                     the OM_send... function */
  struct EMcomm_struct commargs;  /* The structure that enables access to
                                     certain arguments in the msg's 
                                     argument-list */
  };

/*
 * This structure is more an analogue
 * of 'struct IGRpointset', except that
 * it returns a matrix of points (possibly
 * irregular), rather than just a string.
 */

struct EMpointmatrix
  {
  IGRboolean is_reg;             /* TRUE if the matrix is regular */
  IGRlong num_rows;              /* Number of rows in the matrix */
  IGRlong *num_inrow;            /* Array of numbers indicating the number
                                    of elements in each row. If 'is_reg' 
                                    flag is TRUE, only the first element
                                    need be valid */
  IGRdouble *points;             /* The contiguous array of points, placed
                                    row major */
  };


/* Enumerated data type EMSpos for subcurve description in an */
/* extended curve */

enum EMSpos
  {
        EMSpos_NULL,    /* an orphan subcurve */
        EMSpos_FIRST,   /* first subcurve in an extended curve */
        EMSpos_LAST,    /* last subcurve in an extended curve */
        EMSpos_MIDDLE   /* subcurve between two subcurves */
  };

# endif /* if EMmsg_obj_include */
