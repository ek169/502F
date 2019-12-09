/***************************************************************************
                             Code Generator
***************************************************************************/
/*-------------------------------------------------------------------------
                             Data Segment
-------------------------------------------------------------------------*/
int data_offset = 0;          /* Initial offset                          */
int data_location()           /* Reserves a data location                */
{
   return data_offset++;
}
/*-------------------------------------------------------------------------
                             Code Segment
-------------------------------------------------------------------------*/
int code_offset = 0;
int gen_label()
{
   return code_offset;
}
int reserve_loc()
{
   return code_offset++;
}
/* Initial offset                          */
/* Returns current offset                  */
/* Reserves a code location                */
                              /* Generates code at current location      */
void gen_code( enum code_ops operation, int arg )
54

{ code[code_offset].op    = operation;
  code[code_offset++].arg = arg;
}
                              /* Generates code at a reserved location   */
void back_patch( int addr,  enum code_ops operation, int arg  )
{
  code[addr].op  = operation;
  code[addr].arg = arg;
}
/*-------------------------------------------------------------------------
                           Print Code to stdio
-------------------------------------------------------------------------*/
void print_code()
{
int i = 0;
   while (i < code_offset) {
      printf("%3ld: %-10s%4ld\n",i,op_name[(int) code[i].op], code[i].arg );
      i++;
} }
/************************** End Code Generator **************************/
A.6 The stack machine: SM.h
/***************************************************************************
                             Stack Machine
***************************************************************************/
/*=========================================================================
                              DECLARATIONS
=========================================================================*/
/* OPERATIONS: Internal Representation */
enum code_ops { HALT, STORE, JMP_FALSE, GOTO,
                DATA, LD_INT, LD_VAR,
                READ_INT, WRITE_INT,
                LT, EQ, GT, ADD, SUB, MULT, DIV, PWR };
/* OPERATIONS: External Representation */
char *op_name[] = {"halt", "store", "jmp_false", "goto",
55

struct instruction
 {
{
do { /*printf( "PC = %3d IR.arg = %8d AR = %3d Top = %3d,%8d\n",
        pc, ir.arg, ar, top, stack[top]); */
/* Fetch
ir = code[pc++];
/* Execute
switch (ir.op) {
"data", "ld_int", "ld_var",
"in_int", "out_int",
"lt", "eq", "gt", "add", "sub", "mult", "div", "pwr" };
  enum code_ops op;
int arg; };
/* CODE Array */
struct instruction code[999];
/* RUN-TIME Stack */
int stack[999];
/*-------------------------------------------------------------------------
                              Registers
-------------------------------------------------------------------------*/
int                 pc   = 0;
struct instruction  ir;
int
int
char
/*=========================================================================
                             Fetch Execute Cycle
=========================================================================*/
void fetch_execute_cycle()
ch;
ar = 0; top =0;
               */
               */
               : printf( "halt\n" );
                 scanf( "%ld", &stack[ar+ir.arg] ); break;
case WRITE_INT : printf( "Output: %d\n", stack[top--] );  break;
case HALT
case READ_INT  : printf( "Input: " );
break;
case STORE     : stack[ir.arg] = stack[top--];
case JMP_FALSE : if ( stack[top--] == 0 )
pc = ir.arg;
        case GOTO      : pc = ir.arg;
        case DATA      : top = top + ir.arg;
56
break;
break;
break;
break;

   case LD_INT
   case LD_VAR
   case LT
case EQ
case GT
case ADD
case SUB
case MULT
case DIV
case PWR
default
} }
   while (ir.op != HALT);
}
: stack[++top] = ir.arg;
: stack[++top] = stack[ar+ir.arg];
: if ( stack[top-1] < stack[top] )
             stack[--top] = 1;
          else stack[--top] = 0;
: if ( stack[top-1] == stack[top] )
             stack[--top] = 1;
          else stack[--top] = 0;
: if ( stack[top-1] > stack[top] )
             stack[--top] = 1;
          else stack[--top] = 0;
break;
break;
: stack[top-1] = stack[top-1] + stack[top];
          top--;
          break;
: stack[top-1] = stack[top-1] - stack[top];
top--;
          break;
: stack[top-1] = stack[top-1] * stack[top];
top--;
          break;
: stack[top-1] = stack[top-1] / stack[top];
top--;
          break;
: stack[top-1] = stack[top-1] * stack[top];
top--;
          break;
: printf( "%sInternal Error: Memory Dump\n" );
break;
