%{
enum TokenCode {
    IDENTIFIER = 1,
    LEFT_BRACE,
    RIGHT_BRACE,
    IO_IN,
    IO_OUT,
    IO_ERR,
    ASSIGNMENT,
    IF,
    ELSE,
    ELIF,
    WHILE,
    EXIT,
    SEMICOLON,
    PLUS,
    MINUS,
    MULTIPLY,
    DIVIDE,
    REMAINDER,
    AND,
    OR,
    LT,
    GT,
    EQ,
    LTE,
    GTE,
    NEQ,
    INT_T,
    INT_V,
    STRING_T,
    STRING_V,
    BOOL_T,
    BOOL_V,
};

#include <stdio.h>
int line_number = 1;
%}

escaped (\\n|\\t|\\\\|\\\")
ascii [ !@#$%\^&*()\-_=+\[\]{}|;:'",<.>/?]

%%

if      return IF;
else    return ELSE;
elif    return ELIF;
while   return WHILE;

\{      return LEFT_BRACE;
\}      return RIGHT_BRACE;

\$in    return IO_IN;
\$out   return IO_OUT;
\$err   return IO_ERR;

exit    return EXIT;

;       return SEMICOLON;
\+      return PLUS;
\-      return MINUS;
\*      return MULTIPLY;
\/      return DIVIDE;
%       return REMAINDER;

&&      return AND;
\|\|    return OR;

\<      return LT;
\>      return GT;
==      return EQ;
\<=     return LTE;
\>=     return GTE;
!=      return NEQ;

=       return ASSIGNMENT;

int     return INT_T;
0|[1-9][0-9]* return INT_V;

string  return STRING_T;
\"([A-Za-z0-9]|{escaped}|{ascii})+\" return STRING_V;

boolean return BOOL_T;
true|false return BOOL_V;

[A-Za-z][A-Za-z0-9_]* return IDENTIFIER;

\n line_number++;
[ \t]+

.   fprintf(stderr, "invalid character at line %d: %s\n", line_number, yytext);

%%
#include <unordered_map>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main(int argc, char**argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
    } else {
        std::cerr << "No input file give\n";
        return 1;
    }
    
    ofstream pif("pif.txt");
    ofstream st("st.txt");
    
    unordered_map<string, int> symbol_indices;
    int available_index = 1;
    
    int current_code;
    while (current_code = yylex()) {
        switch (current_code) {
            case IDENTIFIER:
            case INT_V:
            case STRING_V:
            case BOOL_V:
                if (symbol_indices.insert({yytext, available_index}).second) {
                    st << yytext << '\n';
                    available_index++;
                }
                pif << current_code << "\t\t" << symbol_indices.at(yytext) << '\n';
                break;
            default: pif << current_code << "\t\t" << 0 << '\n';
        }
    }
}

#ifndef yywrap
    int yywrap() { return 1; }
#endif