#define EX_MAX_DIACRITIC 4

struct diacritic
{
unsigned char diacritic;
char nbytes;
char lower_char[EX_MAX_DIACRITIC];
};
