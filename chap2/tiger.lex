%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;
char* str=NULL;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

void str_init(){
    str=checked_malloc(1000);
    str[0]='\0';
}

void add_str(char c){
    int len = strlen(str);
    str[len++]=c;
    str[len]='\0';
}
void str_cle(){
    str=NULL;
}

%}

%x string  
%x comment
%x ffstr

%%
[ \t]*   {adjust(); continue;}
" "	 {adjust(); continue;}
\n	 {adjust(); EM_newline(); continue;}
\r
","	 {adjust(); return COMMA;}
":"  {adjust(); return COLON;}
";"  {adjust(); return SEMICOLON;}
"("  {adjust(); return LPAREN;}
")"  {adjust(); return RPAREN;}
"["  {adjust(); return LBRACK;}
"]"  {adjust(); return RBRACK;}
"{"  {adjust(); return LBRACE;}
"}"  {adjust(); return RBRACE;}
"."  {adjust(); return DOT;}
"+"  {adjust(); return PLUS;}
"-"  {adjust(); return MINUS;}
"*"  {adjust(); return TIMES;}
"/"  {adjust(); return DIVIDE;}
"="  {adjust(); return EQ;}
"<>" {adjust(); return NEQ;}
"<"  {adjust(); return LT;}
"<=" {adjust(); return LE;}
">"  {adjust(); return GT;}
">=" {adjust(); return GE;}
"&"  {adjust(); return AND;}
"|"  {adjust(); return OR;}
":=" {adjust(); return ASSIGN;}

for  	 {adjust(); return FOR;}
while    {adjust(); return WHILE;};
to       {adjust(); return TO;}
break    {adjust(); return BREAK;}
let      {adjust(); return LET;}
in       {adjust(); return IN;}
end      {adjust(); return END;}
function {adjust(); return FUNCTION;}
var      {adjust(); return VAR;}
type     {adjust(); return TYPE;}
array    {adjust(); return ARRAY;}
if       {adjust(); return IF;}
then     {adjust(); return THEN;}
else     {adjust(); return ELSE;}
do       {adjust(); return DO;}
of       {adjust(); return OF;}
nil      {adjust(); return NIL;}

[0-9]+	 {adjust(); yylval.ival=atoi(yytext); return INT;}
[A-Za-z]+[_A-Za-z0-9]* {adjust(); yylval.sval=String(yytext); return ID;}

"/*"([^\*]|(\*)*[^\*/])*(\*)*"*/" {adjust(); continue;}

\"          {adjust(); str_init(); BEGIN string;}
<string>\\n {adjust(); add_str('\n');};
<string>\\t {adjust(); add_str('\t');};
<string>\\^[a-zA-Z]  {adjust();}
<string>\\[0-9]{3} {adjust(); add_str(atoi(yytext+1));}
<string>\\\" {adjust(); add_str('\"');}
<string>\\\\ {adjust(); add_str('\\');}
<string>\"   {adjust(); yylval.sval=String(str); str_cle(); BEGIN(0); return STRING;}
<string>\\f  {adjust(); BEGIN ffstr;}
<string>\n   {adjust(); EM_newline(); add_str('\n');}
<string>\r
<string>.    {adjust(); add_str(yytext[0]);}

<ffstr>f\\ {adjust(); BEGIN string;}
<ffstr>\n  {adjust(); EM_newline();}
<ffstr>\r
<ffstr>.   {adjust();}

.	 {adjust(); EM_error(EM_tokPos,"illegal token");}


