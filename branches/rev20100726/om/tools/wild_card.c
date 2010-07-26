#include <string.h>
#include <stdio.h>
#ifdef NT
#include <malloc.h>
#endif

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();
extern void som_dealloc();

extern int  extract_token(),
            string_verifies();

extern void display_state();

#define MAXCLASSNAME_LEN 64
struct state_node{

int	final_flag;		/* true if this is the final state */
char	position_hold;		/* true if the buffer pointer cannot be 
				 * advanced while searching for the item*/

char	transition;		/* type of transition needed to go to next 
				 * state */
char	string_of_chars[MAXCLASSNAME_LEN];	/* string which must be found to go to next 
				 * state */
#define NONE		0	/* no transition, this is the final state*/

#define ANY_CHAR	1	/* any single character will get to the next
				 * state */
#define ANY_CHAR_OF_SET 2	/* any one of a set of chars will get to next
				 * state */
#define STRING	3	        /* a string match is needed to get to next 
				 * state */
#define ROVING_STRING   4       /* a string is needed but not from the starting
				 * point */
#define ANY_SET_OF_CHARS 5	/* any set of chars can get to next state */


};

#ifdef MAIN
/* this is a main routine used to test and debug this facility */

main()
{
int i,j,k,num_matches;
char *string_list[10],*return_list[10],buffer[20];

string_list[0] = "abcdefgh11";
string_list[1] = "bcdeafgh22";
string_list[2] = "abcdfgh33e";
string_list[3] = "acdefgbh44";
string_list[4] = "bcadefhgii";
string_list[5] = "acdfebhigi";
string_list[6] = "abgggfghii";
string_list[7] = "aberefghii";
string_list[8] = "aqwwlfghii";
string_list[9] = "abommfghii";
#define STRT 0
	while(1)
	{
		printf("Enter string>");
		scanf("%s",buffer);
		printf("finding wildcard match for string \"%s\"\n",buffer);
		wild_card(&string_list[STRT],10-STRT,buffer,return_list,&num_matches);
		printf("Returned matches : %d \n",num_matches);
		for(i=STRT; i<10; i++)
	 	  printf("string_list[%d] = \"%s\"\n",i,string_list[i]);
		printf("\n\n");
		for(i=0; i<num_matches; i++)
	 	  printf("return_list[%d] = \"%s\"\n",i,return_list[i]);
	}
}	
#endif
void wild_card(string_list,num_to_search,user_search_string,return_list,num_matches)

/* this routine extracts, from the array of strings pointed to by string_list,
 * a subset of those strings as dictated by user_search_string and places them
 * into the return_list array of strings. user_search_string may contain the
 * metacharacters '*' and '?'. This routine will allocate the second dimension
 * of return_list as necessary. 
 */
char *string_list[],*return_list[],*user_search_string;
int num_to_search,*num_matches;
{

/* first establish the number of states. This will be easy. The number 
 * of states is equal to the number of occurrences of '?' + '*' +
 * the number of strings (of length one or more) in between these + 1
 * for the final state.*/

struct state_node *states;
int i,j,k,kk,num_states,str_len,char_last_seen,aster_last_seen;
char token[MAXCLASSNAME_LEN],search_string[MAXCLASSNAME_LEN],
	compare_string_list[MAXCLASSNAME_LEN];

        for(i=0; i<MAXCLASSNAME_LEN; i++)  search_string[i] = '\0';

	str_len = strlen(user_search_string);
	if((user_search_string[str_len-1] != '*') &&
	   (user_search_string[str_len-1] != '?'))
	{
	   strncpy(search_string,user_search_string,str_len);
	   search_string[str_len] = '@';
	   str_len++;
	}
	else
	{
	   strncpy(search_string,user_search_string,str_len);
	   search_string[str_len] = '\0';
	}
#ifdef DEBUG
printf("Search string %s has total length %d \n",search_string,str_len);
#endif

	if(!str_len) return;

	for(i=0,char_last_seen = 0,num_states=1; i<str_len; i++)
	{
	   if(search_string[i] == '*'){ num_states++; char_last_seen = 0;}
	   else if(search_string[i] == '?'){num_states++;char_last_seen = 0;}
	   else if(!char_last_seen) {char_last_seen = 1; num_states++;}
	}

#ifdef DEBUG
printf("%d states, including final, were found \n",num_states);
#endif

	/* set up the list of states */

	states = (struct state_node *) 
		 som_malloc(sizeof(struct state_node)*num_states);

	for(i=aster_last_seen=j=0; i<num_states-1; i++)
	{
		j += extract_token(&search_string[j],token);

#ifdef DEBUG
printf("token \"%s\" from \"%s\"",token,&search_string[j]);
#endif
		if(!strcmp(token,"*"))
		{
		  states[i].final_flag = 0;
		  states[i].transition = ANY_SET_OF_CHARS;
		  aster_last_seen = 1;
		}
		else if(!strcmp(token,"?"))
		{
		  states[i].final_flag = 0;
		  states[i].transition = ANY_CHAR;
		}
		else 
		{
		/* this is a string. */
		  states[i].final_flag = 0;
		  states[i].transition = STRING;
		  k = strlen(token) + 1;
		  strcpy(states[i].string_of_chars,token);
		  if(aster_last_seen) states[i].position_hold = 0;
		   else 
		   {
			states[i].position_hold = 1;
			aster_last_seen = 0;
		   }
		}
#ifdef DEBUG
printf("\nJust created state: \n");
display_state(&states[i]);
#endif
	
	}

	/* indicate the final state */
	states[num_states-1].transition = NONE;
	states[num_states-1].final_flag = 1;

#ifdef DEBUG
printf("\nJust created state: \n");
display_state(&states[num_states-1]);
#endif

	/* now that the state list is built, test the search string 
	 * against the list to be searched */

	for(i=0,*num_matches = 0; i<num_to_search; i++)
	{
	    for(j=0; j<MAXCLASSNAME_LEN; j++)  compare_string_list[j] = '\0';

	    kk = strlen(string_list[i]);
	    strncpy(compare_string_list,string_list[i],kk);
	    if(search_string[str_len-1] == '@')
	       compare_string_list[kk] = '@';

#ifdef DEBUG
printf("Comparing %s to %s \n",compare_string_list,search_string);
#endif
	    if(string_verifies(compare_string_list,states))
	    {

	        k= strlen(string_list[i]);

	    	return_list[*num_matches] = (char *) malloc(k+1);

	        strncpy(return_list[*num_matches],string_list[i],k);
		return_list[*num_matches][k] = '\0';

		(*num_matches)++;

	    }
	}

	som_dealloc(states);
	return;
}

int string_verifies(suspect_string,states)
/* this routine churns through the state machine pointed to by states
 * to see if suspect_string achieves final state 
 */
char	*suspect_string;
struct state_node *states;

{
int k,kk,curr_state,buff_pos,str_len,match_found;

	str_len = strlen(suspect_string);
	if(!str_len) return(0);

	for(curr_state=0,buff_pos=0; (!states[curr_state].final_flag)
			            && (buff_pos < str_len);)
	{


		if(states[curr_state].transition == ANY_SET_OF_CHARS)
		{
#ifdef DEBUG
printf("in '*' state. advancing the current state \n");
#endif
			curr_state ++;
			/* if the just advanced state is the final state,
			 * advance the buffer pointer to the end, since 
			 * all the rest of the characters will match the
			 * asterisk
			*/
		        if(states[curr_state].transition == NONE)
			{
#ifdef DEBUG
printf("Next state is final, so moving buffer pointer to the end \n");
#endif
			     buff_pos = str_len;
			}

		}
		else if(states[curr_state].transition == ANY_CHAR)
	        {
#ifdef DEBUG
printf("In any char state. advancing the buffer and current state. \n");
#endif
			buff_pos ++;
			curr_state++;

		}	
		else if(states[curr_state].transition == STRING)
		{
		 /* there are two cases looking for a string. 
		  * either we must start with the current buffer char
		  * or we can look ahead for the string */
#ifdef DEBUG
printf("In string state \n");
#endif
		k = strlen(states[curr_state].string_of_chars);

		if(states[curr_state].position_hold)
		 {
#ifdef DEBUG
printf("Fixed string state \n");
printf("comparing state string %s and search string %s for length %d \n",
states[curr_state].string_of_chars,&suspect_string[buff_pos],k);
#endif

			if(!strncmp(states[curr_state].string_of_chars,
			     &suspect_string[buff_pos],k))
			{
#ifdef DEBUG
printf("Fixed string state- -- MATCH FOUND\n");
#endif
	 		buff_pos+=k;
			curr_state++;

			}
			else buff_pos = str_len;
		 }	
		 else  /* we are in roving string state */
		 {
#ifdef DEBUG
printf("In roving string state. looking for a match \n");
#endif
		 for(kk=buff_pos,match_found=0; kk < (str_len - k+1); kk++)
		 {
		         if(!strncmp
		                (states[curr_state].string_of_chars,
				&suspect_string[kk],k))
			 {
				match_found = 1;
				curr_state++;
			        buff_pos += (kk-buff_pos+k);
				break;
			 }  /* end of if we have a string match */
		 } /* end of looking through the string */
		 /* if there was not a match, set the buffer pointer
		  * to the end to quit the search through the string.
		  * the overall test will fail sonce the state is not final
		  */
		 if(!match_found) buff_pos = str_len;

		 } /* end of else position_hold flag is not set */
	        }	/* end of else this is a string state */
		else /* this is an unknown state */
		{
		   /* if the previous state was an asterisk state, advance
		    * the buffer pointer so that it is at the end of the 
		    * buffer */
		}		
	}	/* end of do until we hit final state or end of string */

	/* at this point, if the string is at its end and  the state is final
	 * then the string was a match */

	if((states[curr_state].final_flag) && (buff_pos == str_len))
	return(1);

	else return(0);
}

/******************************************************************/
int extract_token(search_string,token)
char  *search_string, *token;
{
   int i, j, seen_letter;

   j = strlen(search_string);
   if (!j)
   {
      token[0] = 0;
      return(0);
   }
   for (i=seen_letter=0; i<j; i++)
   {
      token[i] = search_string[i];
      if((token[i] == '*') && !seen_letter) 
      {
         token[i+1] = '\0';
         return(1);	
      }
      else if((token[i] == '?') && !seen_letter)
      {
         token[i+1] = '\0';
         return(1);	
      }
      else if((token[i] == '*') &&  seen_letter) 
      {
         token[i] = '\0';
         return(i);	
      }
      else if((token[i] == '?') &&  seen_letter)
      {
         token[i] = '\0';
         return(i);	
      }
      else seen_letter = 1;
   }
	
   /* if here, we didnt see any '*' or '?' */
   token[i] = '\0';
   return(i);
}

/**********************************************************/
void display_state(state)
struct state_node *state;
{
   printf("Final:%d  | position_hold: %d\n",
      state->final_flag,state->position_hold);
   printf("@ of state = %X | Transition: ",state);
   switch (state->transition)
   {
      case (ANY_CHAR):
         printf("ANY_CHAR\n"); break;
      case (STRING): 
         printf("STRING (@ %X) \"%s\" \n",
            state->string_of_chars,state->string_of_chars);
         break;
      case (ANY_SET_OF_CHARS):
         printf("ANY_SET_OF_CHARS \n");break;
      case (NONE):
         printf("NONE (Final state) \n"); break;
      default:
         printf("??Unknown state %d \n",state->transition); break;
   }
}
