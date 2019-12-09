%{/*************************************************************************
                   Compiler for the Simple language
***************************************************************************/
/*=========================================================================
       C Libraries, Symbol Table, Code Generator & other C code
=========================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ST.h"
#include "SM.h"
#include "CG.h"
#define  YYDEBUG 1
int  errors;
/*-------------------------------------------------------------------------
/* For I/O                                     */
/* For malloc here and in symbol table         */
/* For strcmp in symbol table                  */
/* Symbol Table                                */
/* Stack Machine                               */
/* Code Generator                              */
/* For Debugging                               */
/* Error Count                                 */
               The following support backpatching
-------------------------------------------------------------------------*/
 struct  lbs              /* Labels for data, if and while               */
 {
int for_goto;
int for_jmp_false;
47
  };
struct lbs * newlblrec()  /* Allocate space for the labels               */
{
  return  (struct lbs *) malloc(sizeof(struct lbs));
}
/*-------------------------------------------------------------------------
               Install identifier & check if previously defined.
-------------------------------------------------------------------------*/
install ( char *sym_name )
{
   symrec *s;
   s = getsym (sym_name);
   if (s == 0)
        s = putsym (sym_name);
   else { errors++;
          printf( "%s is already defined\n", sym_name );
} }
/*-------------------------------------------------------------------------
                 If identifier is defined, generate code
-------------------------------------------------------------------------*/
context_check( enum code_ops operation, char *sym_name )
{ symrec *identifier;
  identifier = getsym( sym_name );
  if ( identifier == 0 )
       { errors++;
         printf( "%s", sym_name );
         printf( "%s\n", " is an undeclared identifier"  );
       }
  else gen_code( operation, identifier->offset );
}
/*=========================================================================
                          SEMANTIC RECORDS
=========================================================================*/
%}
%union semrec
{
 int     intval;
 char    *id;
 struct lbs *lbls;
/* The Semantic Records                        */
/* Integer values                              */
/* Identifiers                                 */
/* For backpatching                            */
}
/*=========================================================================
                               TOKENS
=========================================================================*/
%start program
%token <intval>  NUMBER          /* Simple integer                       */
48

%token <id>      IDENTIFIER      /* Simple identifier                    */
%token <lbls>    IF WHILE        /* For backpatching labels              */
%token SKIP THEN ELSE FI DO END
%token INTEGER READ WRITE LET IN
%token ASSGNOP
/*=========================================================================
                          OPERATOR PRECEDENCE
=========================================================================*/
%left ’-’ ’+’
%left ’*’ ’/’
%right ’^’
/*=========================================================================
                   GRAMMAR RULES for the Simple language
=========================================================================*/
%%
program : LET
             declarations
          IN           { gen_code( DATA, data_location() - 1 );          }
             commands
          END          { gen_code( HALT, 0 ); YYACCEPT;                  }
;
declarations : /* empty */
   | INTEGER id_seq IDENTIFIER ’.’ { install( $3 );                      }
;
id_seq : /* empty */
   | id_seq IDENTIFIER ’,’  { install( $2 );                             }
;
commands : /* empty */
   | commands command ’;’
;
command : SKIP
   | READ IDENTIFIER   { context_check( READ_INT, $2 );                  }
   | WRITE exp         { gen_code( WRITE_INT, 0 );                       }
   | IDENTIFIER ASSGNOP exp { context_check( STORE, $1 );                }
| IF exp
  THEN commands
  ELSE
commands
FI
| WHILE
{ $1 = (struct lbs *) newlblrec();
  $1->for_jmp_false = reserve_loc();              }
{ $1->for_goto = reserve_loc();                   }
{ back_patch( $1->for_jmp_false,
             JMP_FALSE,
             gen_label() );                       }
{ back_patch( $1->for_goto, GOTO, gen_label() );  }
{ $1 = (struct lbs *) newlblrec();
  $1->for_goto = gen_label();                     }
49

exp
DO
commands
END
;
exp : NUMBER
   | IDENTIFIER
   | exp ’<’ exp
   | exp ’=’ exp
   | exp ’>’ exp
   | exp ’+’ exp
   | exp ’-’ exp
   | exp ’*’ exp
   | exp ’/’ exp
   | exp ’^’ exp
   | ’(’ exp ’)’
{ $1->for_jmp_false = reserve_loc();              }
{ gen_code( GOTO, $1->for_goto );
  back_patch( $1->for_jmp_false,
             JMP_FALSE,
             gen_label() );                       }
{ gen_code( LD_INT, $1 );                         }
{ context_check( LD_VAR,  $1 );                   }
{ gen_code( LT,
{ gen_code( EQ,
{ gen_code( GT,
{ gen_code( ADD,
{ gen_code( SUB,
{ gen_code( MULT,
{ gen_code( DIV,
{ gen_code( PWR,
0); } 0); } 0); } 0); } 0); } 0); } 0); } 0); }
;
%%
/*=========================================================================
                                  MAIN
=========================================================================*/
main( int argc, char *argv[] )
{ extern FILE *yyin;
  ++argv; --argc;
  yyin = fopen( argv[0], "r" );
  /*yydebug = 1;*/
  errors = 0;
  yyparse ();
  printf ( "Parse Completed\n" );
  if ( errors == 0 )
  { print_code ();
    fetch_execute_cycle();
  }
}
/*=========================================================================
                                 YYERROR
=========================================================================*/
yyerror ( char *s )  /* Called by yyparse on error */
{
errors++;
  printf ("%s\n", s);
}
/**************************** End Grammar File ***************************/

/*
A.2 Directions
Directions:  this file contains a sample terminal session.
> bison -d Simple.y
   or
> bison -dv Simple.y
Simple.y contains 39 shift/reduce conflicts.
> gcc -c Simple.tab.c
> flex Simple.lex
> gcc -c lex.yy.c
> gcc -o Simple Simple.tab.o lex.yy.o -lm
> Simple test_simple
Parse Completed
  0: data         1
  1: in_int       0
  2: ld_var       0
  3: ld_int      10
  4: lt           0
  5: jmp_false    9
  6: ld_int       1
  7: store        1
  8: goto         9
  9: ld_var       0
 10: ld_int      10
 11: lt           0
 12: jmp_false   22
 13: ld_int       5
 14: ld_var       1
 15: mult         0
 16: store        1
 17: ld_var       0
 18: ld_int       1
 19: add          0
 20: store        0
 21: goto         9
 22: ld_var       0
 23: out_int      0
 24: ld_var       1
 25: out_int      0
 26: halt         0
Input: 6
Output: 10
Output: 625
51
*/
