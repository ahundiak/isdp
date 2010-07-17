struct emu_data
{
  double	cyl_len_cone[2];
  double	cyl_len_ellips[2];
  short		no_cyl_90_degree[2];
};


typedef struct system_flags
  {
  unsigned short process_idt:1 ;	/* checker will process idt file */
  unsigned short remote_project:1 ;	/* project is remote to to checker */
  unsigned short remote_enva:1 ;	/* envelope file A is remote to checker */
  unsigned short remote_envb:1 ; 	/* envelope file B is remote to checker */
  unsigned short reserved:12 ;		/* future use */
  } System_Flags;


struct system_data
{
  union
  {
    double	size_d;
    short	size[4];
  }su;
  double	version;
  double	cyl_len_cone;
  double	slicing_dist;
  double	delta_radius;
  double	cyl_len_ellips;
  short		no_design_files;
/*  short		no_divisions;  */
  System_Flags	sys_flags;  
  short		no_cyl_90_degree;
  short		internal_lun;		/* log switch, 0=log off , >0=log on */
  short		reserved[10];
  char		id_option;
  char		id_mode;
  char		report_file[64];
  char		insulation_thickness;
  char		same_line;
  char		internal_file[64];
  char		env_a_file[64];
  char		env_b_file[64];
  char		marker_file[64];
  char		wake_up_time[23];
};


struct startup_data
{ 
  struct	system_data		rxw_system;
  struct	emu_data		rxw_emu;
};


union
{
  char		buffer_rxw[2000];
  struct	startup_data  		startup;
}startup_union;
