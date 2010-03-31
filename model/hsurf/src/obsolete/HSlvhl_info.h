#define	TRUE	1
#define FALSE	0

struct	HSlvhl_info
	{
	double	scale;
	
	int	xdits, ydits;
	
	int	min_x_dep, min_y_dep;
	int	max_x_dep, max_y_dep;
	
	int	min_x_dep_sv, min_y_dep_sv;
	int	max_x_dep_sv, max_y_dep_sv;
	
	int	win_no, pipe_no;
	
	int	visible_color;
	int	hidden_color;
		
	int	visible_weight;
	int	hidden_weight;
		
	int	visible_style;
	int	hidden_style;
		
	int	visible_layer;
	int	hidden_layer;
		
	int	optimization;
	
	char	display_hidden;
	char	generate_soos;		
	};
