/** 
 * 
 * Define a grammar for parsing FX option broker quotes * 
 * 
 * (c) Simon Keen 2015 
 * 
 * provided under the MIT license
 *  
 * Here are some examples of the natural language quote strings that this combined grammar can process 
 * 
 * audusd 1m .9 .97 double no touch in 100m aud 
 * audusd 1m .90 one touch 
 * 40m aud usdjpy 1y 99 100 1x2 call ratio 
 * usdjpy 1y 99 100 cr 1:2 50m aud per strike 
 * 1y 0.98 strip audjpy 5m atm call on jpy in 50b jpy 
 * jpy 1y 98 99 100 101 cd ref 100.1 in 100M jpy 
 * jpy 1y 25d rr in 40m usd ref 110 
 * xauusd 1m 1.1 1.2 call spread 
 * audusd 8m usd 1y 2y 1.2 call calendar
 * audcad 8y 1 2 3 put fly 50m aud ref 1.4 
 * EURUSD 1aug2012 atm sd 
 * EURUSD 6d 0.9 1.0 1.1 call fly 
 * eurjpy 1y 1.42 ko= 1.44 c ref 1.40 
 * usdjpy 1m tk cut atm euro c ko=24d with 50m usd rebate in 50m eur ref 1.1 
 * gbpusd on tk 1.43 c ko 1.45 spot ref 1.44 in 80m gbp 
 * usdjpy 1y 101 102 down and in put 
 * eurjpy 1y 1.42 ko= 1.44 uoc ref 1.40 
 * eurjpy 1y 1.42 uoc ko at 1.44 ref 1.40 
 * EURJPY 1y 25d RR usdmyr 1/jan/1242 atm c ref 1.421 
 * usdmyr 1/1/2015 1042 c 
 * usdjpy 10y 20y atm call calendar 
 * audcad ON 1.1 1.2 1.3 cf in 50m aud ref 1.42 
 * audcad 1-jan-2015 1.1 1.2 1.3 pf in 50m aud ref 1.42 
 * audjpy 1y atm call 
 * audjpy 1y atm c 
 * audjpy 1y 1.21 put 
 * audjpy 1y 1.21 P 
 * usdjpy 1m 101 110 call spread 
 * usdjpy 1m 2m 101 cc 
 * gbpusd ON atm sd 
 * gbpusd ON 1.4 1.5 str 
 * gbpusd ON 1.4 1.6 strangle 
 * gbpusd 3m 25d risk reversal 
 * gbpusd 15feb atm call on usd
 */ 
grammar Quotes;

quote_list : (quote )*;

quote 
	: counterparty? 
		( ccypair 
			( strategy notional? price_ref?
			| strategy price_ref? notional?
			| notional strategy price_ref?
			)
		| notional? ccypair strategy price_ref?
		| notional strategy price_ref?
	) quote_tail? ;

quote_tail : .*? NL;

price_ref 
	: spot_ref
	| fwd_ref
	| ref
	;
	
fwd_ref : (VS | V)? (F | FWD | FORWARD) number;

spot_ref : (VS | V)? SPOT REF? number ;

ref : (VS | V | REF) number;

per_strike : PER STRIKE;

strategy 
	: strat_double_strike 	
	| strat_single_barrier
	| strat_single_strike 
	| strat_triple_strike
	| strat_quadruple_strike 	
	| strat_calendar 	
	| strat_diagonal
	| strat_single_barrier 	
	| strat_double_barrier 	
	| strat_single_touch 	
	| strat_double_touch 
	;
	
strat_single_strike 
	: maturity strike exercise_style? single_strike_product 
	;

strat_double_strike : maturity strike strike exercise_style? double_strike_product ;

strat_triple_strike : maturity strike strike strike exercise_style? triple_strike_product ;

strat_quadruple_strike : maturity strike strike strike strike exercise_style? quadruple_strike_product ;

strat_calendar : maturity_spread strike calendar_product ;

strat_diagonal : maturity_spread strike strike (call | put);

// note: the parser will recognize barrier products when they are specified without 
// explicit barrier details : usdjpy 1m 99 101 up and out call 
// application code needs to determine which strike is the barrier 

strat_single_barrier 
	: maturity barrier strike exercise_style? single_barrier_product 	
	| maturity strike exercise_style? single_barrier_product barrier 	
	| maturity strike barrier exercise_style? (single_strike_product | single_barrier_product) 	
	| maturity strike exercise_style? single_strike_product barrier 	
	| maturity strike strike exercise_style? single_barrier_product
	;

strat_double_barrier 
	: strat_single_strike barrier barrier 	
	| maturity strike strike strike double_barrier_product;
	
strat_double_touch : maturity strike strike double_touch_product pay_in?;

strat_single_touch : maturity strike single_touch_product pay_in?;

pay_in : PAY IN? CCY;

single_strike_product 
	: call 	
	| put 	
	| risk_reversal 	
	| straddle 	
	| strip 	
	| strap 
	;

double_strike_product 
	: call_spread 	
	| put_spread 	
	| risk_reversal 	
	| strangle 	
	| guts 	
	| call_ratio 	
	| put_ratio 
	;

triple_strike_product 
	: butterfly 
	| seagull
	| call_ladder 	
	| put_ladder 
	;
	
quadruple_strike_product 
	: condor 	
	| iron_condor
	;
	
calendar_product 
	: call_calendar
	| put_calendar ;

single_barrier_product 
	: uoc 	
	| uic 	
	| doc 	
	| dic 	
	| uop 	
	| uip 	
	| dop 	
	| dip 
	;
	
single_touch_product 
	: one_touch
	| no_touch 
	;
	
double_touch_product 
	: double_one_touch 	
	| double_no_touch 
	;
	
double_barrier_product : double_barrier_type (put|call);
// product identification rules 

call 
	: call_on put_on?
	;

call_on
	: call_token ON ccy
	| ccy call_token
	| call_token
	;

call_token
	: C
	| CALL
	;

put 
	: put_on call_on?
	;

put_on 
	: put_token ON ccy
	| ccy? put_token
	;

put_token
	: P
	| PUT
	;
	
call_spread 
	: CS
	| CALL SPREAD 
	;
	
put_spread 
	: PS
	| PUT SPREAD 
	;
	
call_ratio 
	: ( CR | CALL RATIO ) ratio? 	
	| ratio ( CR | CALL RATIO ) 
	;
	
put_ratio 
	: ( PR | PUT RATIO ) ratio?
	| ratio ( PR | PUT RATIO )
	;
	
ratio 
	: number ( ':' | X ) number 
	;
	
butterfly 
	: call_fly 	
	| put_fly 
	| iron_fly	// uses otm put and otm call // 
	;

call_fly 
	: CALL (BF | FLY | BUTTERFLY) 	
	|CF 
	;
	
put_fly 
	: PUT (BF | FLY	| BUTTERFLY)
	| PF 
	;
	
iron_fly 
	: IF
	| IBF
	| IFLY
	| IRON (FLY	| BUTTERFLY) 
	;
	
seagull 
	: SG
	| SEAGULL
	;
	
straddle 
	: SD
	| STRADDLE
	;
	
strip : STRIP ;

strap : STRAP ;

strangle 
	: ST 
	| STR
	| STRANGLE
	;
	
guts : G | GUTS ;

call_calendar : CC | CALL CALENDAR ;

put_calendar : PC | PUT CALENDAR ;

diagonal_spread : (D | DIAGONAL) (call | put) SPREAD;

risk_reversal : RR | RISK REVERSAL ;

one_touch : (OT | ONE TOUCH) (UP | DOWN)?;

no_touch : (NT | NO TOUCH) (UP | DOWN)? ;

double_one_touch : DOT | DOUBLE ONE TOUCH ;

double_no_touch : DNT | DOUBLE NO TOUCH ;

put_ladder : PL | put LADDER;

call_ladder : CL | call LADDER;

condor 
	: call_condor
	| put_condor 
	| iron_condor
	;

call_condor : CCD | call CONDOR ;

put_condor : PCD | put CONDOR ;

iron_condor : CD | ICD | IRON CONDOR ;	// made from otm puts and otm calls 

uoc 
	: UO call
	| UOC (ON CCY)?
	| UP AND? OUT call
	;
	
uop 
	: UO put
	| UOP (ON CCY)?
	| UP AND? OUT put
	;
	
uic : UI call | UIC (ON CCY)? | UP AND? IN call;
uip : UI put | UIP (ON CCY)? | UP AND? IN put;
doc : DO call | DOC (ON CCY)? | DOWN AND? OUT call;
dop : DO put | DOP (ON CCY)? | DOWN AND? OUT put;
dic : DI call | DIC (ON CCY)? | DOWN AND? IN call;
dip : DI put | DIP (ON CCY)? | DOWN AND? IN put;

uodoc : uodo call;
uodop : uodo put;
uodic : uodi call;
uodip : uodi put;
uidoc : uido call;
uidop : uido put;
uidic : uidi call;
uidip : uidi put;

double_barrier_type 
	: uodo
	| uodi
	| uido 
	| uidi
	;
	
uodo 
	: UODO
	| UP AND OUT AND? DOWN AND OUT 	
	| DOWN AND OUT AND? UP AND OUT
	;
	
uodi 
	: UODI
	| UP AND OUT AND? DOWN AND IN 	
	| DOWN AND IN AND? UP AND OUT
	;
	
uido
	: UIDO
	| UP AND IN AND? DOWN AND OUT 	
	| DOWN AND OUT AND? UP AND IN
	;
	
uidi 
	: UIDI
	| UP AND IN AND? DOWN AND IN 	
	| DOWN AND IN AND? UP AND IN
	;
	
strike 
	: atm_strike 
	| delta_strike 
	| number
	;
	
delta_strike : number D ;

atm_strike
	: ATM
	| ATMF
	| ATMS
	| DN 
	;
	
barrier 
	: knock_style (AT | '=' | '@') strike rebate? 	
	| strike knock_style rebate? 
	| knock_style strike rebate?
	;
	
knock_style 
	: knock_in 	
	| knock_out 
	| reverse_knock_out 
	| reverse_knock_in
	;
	
rebate 
	: WITH? REBATE OF? notional
	| WITH? notional REBATE
	| percentage REBATE
	;
	
knock_out 
	: american_knock_out 
	| european_knock_out 
	;
	
american_knock_out
	: AKO
	| AMERICAN KO
	;
	
european_knock_out
	: EKO 
	| EUROPEAN KO
	| KO
	| KNOCK SEPARATOR? OUT // assume euro
	;
	
knock_in 
	: american_knock_in
	| european_knock_in
	;

american_knock_in
	: AKI
	| AMERICAN KI
	;

european_knock_in
	: EKI
	| EUROPEAN KI
	| KNOCK SEPARATOR? IN
	;

reverse_knock_out : RKO | REVERSE KNOCK OUT;
reverse_knock_in : RKI | REVERSE KNOCK IN;

// could add Asian out style, Bermudean too
exercise_style 
	: american_exercise 	
	| european_exercise 
	;
	
european_exercise 
	: EURO 	
	| EUROPEAN
	| E 
	;

american_exercise 
	: AMER 	
	| AMERICAN
	| A 
	;
	
notional : IN? (number ccy 	|
number notional_scale?) ccy per_strike?;
notional_scale 
	: T
	| B	
	| M	
	| K
	;
	
maturity 
	: tenor expiry_cut? 
	| date expiry_cut? 
	;

maturity_spread 
	: number X (number | tenor)
	| maturity maturity
	;

tenor 
	: number (D | W | M | Y) 	
	| overnight 
	;
	
date 
	: INT month
	| INT SEPARATOR? month SEPARATOR? INT 	
	| INT SEPARATOR? month SEPARATOR? INT4 	
	| INT SEPARATOR INT SEPARATOR INT4
	;

month 
	: JAN | FEB | MAR 
	| APR | MAY | JUN 
	| JUL | AUG | SEP 
	| OCT | NOV	| DEC 
	;

// expiry tokens should be provided from static	
expiry_cut : (TK | TOK | NY) CUT? ;

overnight 
	: ON 	
	| OVERNIGHT
	;
	
percentage : number '%';
number 
	: FLOAT
	| INT
	| INT4
	;
	
// lexer rules // general vocabulary 
OT : [Oo][Tt];
NT : [Nn][Tt];
DNT : [Dd][Nn][Tt];
DOT : [Dd][Oo][Tt];
NO : [Nn][Oo];
TOUCH : [Tt][Oo][Uu][Cc][Hh];
ONE : [Oo][Nn][Ee];
DOUBLE : [Dd][Oo][Uu][Bb][Ll][Ee];
KI : [Kk][Ii];
EKI : [Ee][Kk][Ii];
AKI : [Aa][Kk][Ii];
KO : [Kk][Oo];
EKO : [Ee][Kk][Oo];
AKO : [Aa][Kk][Oo];
RKO : [Rr][Kk][Oo];
RKI : [Rr][Kk][Oo];
IN : [Ii][Nn];
OUT : [Oo][Uu][Tt];
PAY : [Pp][Aa][Yy];
KNOCK : [Kk][Nn][Oo][Cc][Kk];
DOWN : [Dd][Oo][Ww][Nn];
UP : [Uu][Pp];
AND : [Aa][Nn][Dd];
REVERSE : [Rr][Ee][Vv][Ee][Rr][Ss][Ee];
REBATE : [Rr][Ee][Bb][Aa][Tt][Ee];
WITH : [Ww][Ii][Tt][Hh];
OF : [Oo][Ff];
AT : [Aa][Tt];
CUT : [Cc][Uu][Tt];
IRON : [Ii][Rr][Oo][Nn];
RATIO : [Rr][Aa][Tt][Ii][Oo];

// cuts 
TK : [Tt][Kk];
TOK : [Tt][Oo][Kk];
NY : [Nn][Yy];

UOC : [Uu][Oo][Cc];
DOC : [Dd][Oo][Cc];
UIC : [Uu][Ii][Cc];
DIC : [Dd][Ii][Cc];
UOP : [Uu][Oo][Pp];
DOP : [Dd][Oo][Pp];
UIP : [Uu][Ii][Pp];
DIP : [Dd][Ii][Pp];
UODO : UO DO | DO UO;
UODI : UO DI | DI UO;
UIDO : UI DO | DO UI;
UIDI : UI DI | DI UI;
UO : [Uu][Oo];
UI : [Uu][Ii];
DO : [Dd][Oo];
DI : [Dd][Ii];
BUTTERFLY : [Bb][Uu][Tt][Tt][Ee][Rr][Ff][Ll][Yy] ;
BF : [Bb][Ff] ;
FLY : [Ff][Ll][Yy] ;
IF :[Ii][Ff];
IBF : [Ii]BF ;
IFLY : [Ii]FLY ;
CF : [Cc][Bb]?[Ff] ;
PF : [Pp][Bb]?[Ff] ;
PL : [Pp][Ll] ;
CL : [Cc][Ll] ;
LADDER : [Ll][Aa][Dd][Dd][Ee][Rr] ;
CS : [Cc][Ss] ;
PS : [Pp][Ss] ;
CR : [Cc][Rr] ;
PR : [Pp][Rr] ;
CALL : [Cc][Aa][Ll][Ll] ;
C : [Cc] ;
PUT : [Pp][Uu][Tt] ;
P : [Pp] ;
SPREAD : [Ss][Pp][Rr][Ee][Aa][Dd] ;
STRANGLE : [Ss][Tt][Rr][Aa][Nn][Gg][Ll][Ee] ;
STR : [Ss][Tt][Rr] ;
ST : [Ss][Tt] ;
GUTS : [Gg][Uu][Tt][Ss] ;
SEAGULL : [Ss][Ee][Aa][Gg][Uu][Ll][Ll];
SG : [Ss][Gg];
STRADDLE : ST | [Ss][Tt][Rr][Aa][Dd][Dd][Ll][Ee] ;
SD : [Ss][Dd];
STRIP : [Ss][Tt][Rr][Ii][Pp] ;
STRAP : [Ss][Tt][Rr][Aa][Pp];
RISK : [Rr][Ii][Ss][Kk] ;
REVERSAL : [Rr][Ee][Vv][Ee][Rr][Ss][Aa][Ll] ;
RR : [Rr][Rr];
CALENDAR : [Cc][Aa][Ll][Ee][Nn][Dd][Aa][Rr] ;
CC : [Cc][Cc] ;
PC : [Pp][Cc] ;
DIAGONAL : [Dd][Ii][Aa][Gg][Oo][Nn][Aa][Ll];
CONDOR : [Cc][Oo][Nn][Dd][Oo][Rr];
CCD : [Cc][Cc][Dd];
PCD : [Pp][Cc][Dd];
CD : [Cc][Dd] ;
ICD : [Ii][Cc][Dd];
ATM : [Aa][Tt][Mm] ;
ATMF : [Aa][Tt][Mm][Ff];
ATMS : [Aa][Tt][Mm][Ss];
DN : [Dd][Nn];
REF : [Rr][Ee][Ff];
VS : [Vv][Ss];
V : [Vv];
SPOT : [Ss][Pp][Oo][Tt];
FWD : [Ff][Ww][Dd];
FORWARD : [Ff][Oo][Rr][Ww][Aa][Rr][Dd];
F : [Ff];
PER : [Pp][Ee][Rr];
STRIKE : [Ss][Tt][Rr][Ii][Kk][Ee];
D : [Dd];
W : [Ww];
M : [Mm];
Y : [Yy];
ON : [Oo][Nn];
OVERNIGHT : [Oo][Vv][Ee][Rr][Nn][Ii][Gg][Hh][Tt];
B : [Bb];
T : [Tt];
K : [Kk];
A : [Aa];
E : [Ee];
G : [Gg];
X : [Xx];
JAN : [Jj][Aa][Nn] ;
FEB : [Ff][Ee][Bb] ;
MAR : [Mm][Aa][Rr] ;
APR : [Aa][Pp][Rr] ;
MAY : [Mm][Aa][Yy] ;
JUN : [Jj][Uu][Nn] ;
JUL : [Jj][Uu][Ll] ;
AUG : [Aa][Uu][Gg] ;
SEP : [Ss][Ee][Pp] ;
OCT : [Oo][Cc][Tt] ;
NOV : [Nn][Oo][Vv] ;
DEC : [Dd][Ee][Cc] ;

// the alternative to listing support ccys is to create 2 simple lexer rules: // 
// CCYPAIR : ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA;
// CCY : ALPHA ALPHA ALPHA ;
// TODO: move this up to the parser grammar section 
ccypair 
	: CCY CCY
	| CCY 
	;

ccy : CCY;

// for counterparty, we should list all tokens
// this might need to be programmatic using static
// plus some predefined strings
counterparty : ~CCY+;

CCY 
	: AUD | USD | GBP | NZD | NOK | SEK | CHF
	| JPY | CAD	| EUR | CZK	| ILS | RUB	| RON 
	| HUF | ZAR | PLN | TRY | CNY | CNH | IDR 
	| INR | PHP | MYR | KRW | SGD | THB | TWD
	| VND | ARS | BRL | CLP | COP | MXN | PEN 
	| AED | SAR | XAG | XAU | XPT | YEN | EURO; 

// trader currency codes 
YEN : [Yy][Ee][Nn];
// iso currency codes could add auto added using static
USD : [Uu][Ss][Dd] ;
GBP : [Gg][Bb][Pp] ;
AUD : [Aa][Uu][Dd] ;
NZD : [Nn][Zz][Dd] ;
NOK : [Nn][Oo][Kk] ;
SEK : [Ss][Ee][Kk] ;
CHF : [Cc][Hh][Ff] ;
JPY : [Jj][Pp][Yy] ;
CAD : [Cc][Aa][Dd] ;
EUR : [Ee][Uu][Rr] ;
CZK : [Cc][Zz][Kk] ;
HUF : [Hh][Uu][Ff] ;
ILS : [Ii][Ll][Ss] ;
PLN : [Pp][Ll][Nn] ;
RON : [Rr][Oo][Nn] ;
RUB : [Rr][Uu][Bb] ;
TRY : [Tt][Rr][Yy] ;
ZAR : [Zz][Aa][Rr] ;
CNH : [Cc][Nn][Hh] ;
CNY : [Cc][Nn][Yy] ;
IDR : [Ii][Dd][Rr] ;
INR : [Ii][Nn][Rr] ;
KRW : [Kk][Rr][Ww] ;
MYR : [Mm][Yy][Rr] ;
PHP : [Pp][Hh][Pp] ;
SGD : [Ss][Gg][Dd] ;
THB : [Tt][Hh][Bb] ;
TWD : [Tt][Ww][Nn] ;
VND : [Vv][Nn][Dd] ;
ARS : [Aa][Rr][Ss] ;
BRL : [Bb][Rr][Ll] ;
CLP : [Cc][Ll][Pp] ;
COP : [Cc][Oo][Pp] ;
MXN : [Mm][Xx][Nn] ;
PEN : [Pp][Ee][Nn] ;
AED : [Aa][Ee][Dd] ;
SAR : [Ss][Aa][Rr] ;
XAG : [Xx][Aa][Gg] ;
XAU : [Xx][Aa][Uu] ;
XPT : [Xx][Pp][Tt] ;
EUROPEAN : [Ee][Uu][Rr][Oo][Pp][Ee][Aa][Nn];
AMERICAN : [Aa][Mm][Ee][Rr][Ii][Cc][Aa][Nn];
EURO : [Ee][Uu][Rr][Oo];
AMER : [Aa][Mm][Ee][Rr];

FLOAT : DIGIT+ '.' DIGIT+ ;
INT4 : DIGIT DIGIT DIGIT DIGIT;
INT : DIGIT+;
ALPHA : [a-zA-Z];

SEPARATOR : [/\\\-] ;

fragment DIGIT : [0-9];
NL : [\r]?[\n];
WS : [ \t]+ -> skip ; // skip spaces, tabs, but not newlines //


