class specification A (1:0) of Root;

instance A
{
     int     anum;
     channel {(rel_ordered,many_to_many)B;}acb;
     channel {(rel_ordered,many_to_many)C;}acs;
     channel {C,B;}acbc;
     channel {}acany;
     channel {}anyca;
     variable double	db[2];
     variable long	lg[1];
     variable short	sh[3];
     variable char	ch[0];
     variable struct complex
	{
		int	num;
		char  	cplxch[5];
	} cplx[5];
};

taggable;

message assign_a ( int num );

message inc_a();

message show_a();

message var_assign_dbl(int newsize);

message var_assign_long(int newsize);

message var_assign_short(int newsize);

message var_assign_char(int newsize);

message var_assign_struct(int newsize);

message var_show_dbl();

message var_show_long();

message var_show_short();

message var_show_char();

message var_show_struct();

message answer();
end specification A;
