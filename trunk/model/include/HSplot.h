
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSplot_include
#define HSplot_include 1

#define WTP_NO  0
#define WTP_YES  1
#define WTP_ERROR 2

struct HSplot_info
   {
   IGRdouble plotter_max[2];
   IGRdouble plotter_resolution;
   IGRdouble size_x, size_y, scale;
   IGRdouble line_width_const, t_line_width_const;
   IGRdouble range[12];
   IGRdouble fence_range[12];
   IGRdouble eye_pt[3];
   IGRdouble rotation[16];

   Form submit_form;
   Form create_form;
   Form status_form;
   Form option_form;
   Form displayed_form;

   unsigned int dpb_flags;
   unsigned int con_flags;
   unsigned int opt_flags;

   IGRint max_line_width, t_max_line_width;
   IGRint raster_type, t_raster_type;

   IGRint displayed_form_no;

   IGRint switch1;
   IGRint copies;
   IGRint units;
   IGRint units_label;

   struct IGRcv_prism *prism;
   struct GRid window;
   struct GRid fence_window;
   struct GRid fence;
   struct GRmd_env module;
   struct GRsymbology *symbology;

   IGRlong file_id;

   IGRshort num_colors;
   IGRshort num_shades;
   IGRshort properties;

   IGRchar queue[32];
   IGRchar date[32];
   IGRchar nodename[32];
   IGRchar last_job_queue[32];
   IGRchar last_job_id[32];
   IGRchar last_job_name[32];
   IGRchar job_to_can[32];

   IGRchar plotfile[132];
   IGRchar textfile[132];
   IGRchar last_checked_plotfile[132];
   IGRchar last_checked_textfile[132];
   IGRchar unique_textfile[132];
   IGRchar rasterfile[132];
   IGRchar seedfile[132];

   IGRchar window_name[GRNAME_SIZE];
   IGRchar command[80];
   };

/*

where
   plotter_max: 
      is the max dimensions of the currently selected plotting device

   plotter_resolution
      the resolution of the currently selected plotting device

   size_x, size_y: 
      the current plot size displayed on the Submit form

   scale: 
      the current plot scale, displayed on the Submit form

   line_width_const: 
      the current line width constant displayed on the Submit Options form.

   t_line_width_const: 
      the line width constant saved just before entering the Submit 
      Options form
   
   range: 
      the range of the selected window:  [0-2] is the range in world 
      coordinates and [3-5] if the range in view coordinates
   
   fence_range: 
      the range of the fence:  [0-2] is the range in world coordinates 
      and [3-5] if the range in view coordinates

   eye_pt: 
      the perspective eye point, collected from the window gragad 
      information
  
   rotation: 
      the window rotation matrix.

   submit_form: 
      pointer to the submit form

   create_form: 
      pointer to the create form

   status_form: 
      pointer to the queue status form

   option_form: 
      pointer to the submit option form

   displayed_form: 
      pointer to the currently displayed form

   dpb_flags: 
      Flags written into the files dpb.  There tell how to 
      initialize the session.

   con_flags: 
      control flags: These control the action during a given session

   opt_flags: 
      option flags: There control the action on the submit options form.

   max_line_width: 
      the current status of the max line width field on the submit 
      options form

   t_max_line_width: 
      the status of the max line width just before the submit options 
      form was activated

   raster_type: 
      the status of the raster type field on the the submit options form

   t_raster_type: 
      the status of the raster type field just before the submit 
      options form was activated.

   displayed_form_no: 
      the four forms in the CSPF command are numbered 0-3.  This is 
      the number of the one currently active.

   switch1: 
      used to report back to the top level of the command what action 
      was take from the check/cancel/execute buttons

   copies: 
      the current status of the number of copies field

   units: 
      flag that tells which measuring uints are being used

   units_label: 
      string that represents the current measuring uints.

   prism: 
      prism corresponding to the fence

   window: 
      GRid of the selected window

   fence_window: 
      GRid of the window in which the fence is defined

   fence: 
      GRid of the fence

   module: 
      the current module environment

   symbology: 
      the symbology of the object currently being processed.
 
   file_id: 
      file id of the currently open, and being written to, 
      shaded plot file.

   num_colors: 
      number of colors in the current colortable

   num_shades: 
      number of shades per color in the current colortable

   properties:  
      the properties flags of the object currently being processed

   queue: 
      the name of the active device/pipe queue displayed on the 
      submit form

   date: 
      the current date values displayed on the submit form

   nodename: 
      used in the queue status form, the nodename of the node on 
      which the device que exist

   last_job_queue
   last_job_id
   last_job_name
      stuff that is filled in after a qpr request has been made, but
      it is never referenced

   plotfile
      the name of the plotfile displayed on the submit and create form

   textfile
      the name of the textfile displayed on the submit and create form

   last_checked_plotfile
   last_checked_textfile
      on the create form, this was the last good plotfile and textfile
      named displayed on the form.  If the user types in new names and
      for some reason they turn out to be bad, the user can go back
      to the old names

   unique_textfile
      if the input textfile name already exist, and the user wants to
      use a unique name instead, this is were it comes from

   rasterfile
      the name of the rasterfile displayed on the submit and create form

   seedfile.
      when submitting a shaded plot to the igds metafile interpreter
      you have to have an igds file in which to put the raster reference
      file attachment.  If the user does not supply an igds file, then
      this is the name of a default file.

   window_name
      the name of the selected shading window

   command
      when forcing action like 'elements in view' on to the event stack,
      this buffer is used to build the commands before sending them.
*/


#endif
