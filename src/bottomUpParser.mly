/*
Copyright (c) 2013, Simon Cruanes
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.  Redistributions in binary
form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with
the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

%{
%}

%token LEFT_PARENTHESIS
%token RIGHT_PARENTHESIS
%token DOT
%token IF
%token NOT
%token COMMA
%token EOI
%token <string> SINGLE_QUOTED
%token <string> LOWER_WORD
%token <string> UPPER_WORD
%token <string> INT

%start parse_literal
%type <BottomUpAst.literal> parse_literal

%start parse_literals
%type <BottomUpAst.literal list> parse_literals

%start parse_clause
%type <BottomUpAst.clause> parse_clause

%start parse_file
%type <BottomUpAst.file> parse_file

%start parse_query
%type <BottomUpAst.query> parse_query

%%

parse_file:
  | clauses EOI { $1 }

parse_literal:
  | literal EOI { $1 }

parse_literals:
  | literals EOI { $1 }

parse_clause:
  | clause EOI { $1 }

parse_query:
  | query EOI { $1 }

clauses:
  | clause { [$1] }
  | clause clauses { $1 :: $2 }

clause:
  | literal DOT { BottomUpAst.Clause ($1, []) }
  | literal IF literals DOT { BottomUpAst.Clause ($1, $3) }

literals:
  | literal { [$1] }
  | literal COMMA literals { $1 :: $3 }

literal:
  | LOWER_WORD { BottomUpAst.Atom ($1, []) }
  | LOWER_WORD LEFT_PARENTHESIS args RIGHT_PARENTHESIS
    { BottomUpAst.Atom ($1, $3) }

query:
  | LEFT_PARENTHESIS args RIGHT_PARENTHESIS IF signed_literals
    {
      let pos_literals, neg_literal = $5 in
      BottomUpAst.Query ($2, pos_literals, neg_literal)
    }

signed_literals:
  | literal COMMA signed_literals
    { let pos, neg = $3 in $1 :: pos, neg }
  | NOT literal COMMA signed_literals
    { let pos, neg = $4 in pos, $2 :: neg }
  | literal { [$1], [] }
  | NOT literal { [], [$2] }

args:
  | term { [$1] }
  | term COMMA args  { $1 :: $3 }

term:
  | INT { BottomUpAst.Const $1 }
  | LOWER_WORD { BottomUpAst.Const $1 }
  | UPPER_WORD { BottomUpAst.Var $1 }
  | SINGLE_QUOTED { BottomUpAst.Quoted $1 }
