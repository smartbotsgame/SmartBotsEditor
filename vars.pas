unit vars;

interface

type Tkeys=set of ' '..'~';

const TALPHABETIC : TKeys=['a'..'z', '_', '#', '%'];
      TALPHABETICSHORT : TKeys=['a'..'z', '_', 'A'..'Z'];
      TFIGURES    : TKeys=['0'..'9'];
      TNUMERIC    : TKeys=['0'..'9', '.'];

function IsVar ( s:string ):integer;
function IsVarFloat(s:string):boolean;
function IsNumber ( const s : string ):boolean;
function IsName ( s:string ):boolean;
function IsFunc ( s : string ):boolean;
procedure InitVarsUnit;
procedure VarLock;
function CountVars:integer;
procedure VarsWrite(const f:integer);
procedure StripString(s:string; var p1, p2, p3, p4, p5, p6:string);
function FindFunc(const s:string):integer;
function GetFuncID(const s:string):integer;
procedure WriteLine(const f:integer; const s:string);

const VAR_NO_ERROR=0;
const VAR_INCORRECT_TYPE=1;
const VAR_INCORRECT_NAME=2;
const VAR_TOO_MANY=3;

var VarError:byte;

type TFunc = record
     name : string;
     code : integer;
     i, o : byte;
     format : string;
     float : boolean;
     end;

var funcs : array[1..100] of TFunc;
    fcount : byte;

implementation

uses SysUtils, Classes;

type Tvar = record
     name : string;
     float : boolean;
     end;

var count, countM : integer; //количество переменных
    content:array[1..100] of TVar;


procedure WriteLine(const f:integer; const s:string);
var k, b:byte;
begin
for k:=1 to length(s) do begin
        b:=ord(s[k]);
        FileWrite(f, b, 1);
        end;
b:=13;
FileWrite(f, b, 1);
b:=10;
FileWrite(f, b, 1);
end;

procedure VarsWrite(const f:integer);
var k:integer; str:string;
begin
FileWrite(f, count, 4);
for k:=1 to count do begin
        str:=content[k].name;
        WriteLine(f, str);
        end;
end;

function CountVars:integer;
begin
CountVars:=count;
end;
procedure StripString(s:string; var p1, p2, p3, p4, p5, p6:string);
var k, p:byte;
begin
p1:='';p2:='';p3:='';p4:='';p5:='';p6:='';
k:=1;
p:=length(s);
// 1
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p1:=p1+s[k];inc(k); end;
// 2
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p2:=p2+s[k];inc(k); end;
// 3
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p3:=p3+s[k];inc(k); end;
// 4
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p4:=p4+s[k];inc(k); end;
// 5
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p5:=p5+s[k];inc(k); end;
// 6
while (k<=p) and (s[k]=' ') do inc(k);
while (k<=p) and (s[k]<>' ') do begin p6:=p6+s[k];inc(k); end;
end;

function FindFunc(const s:string):integer;
var k:byte;
begin
FindFunc:=0;
for k:=1 to fcount do if funcs[k].name=s then FindFunc:=k;
end;

function GetFuncID(const s:string):integer;
var k:byte;
begin
GetFuncID:=0;
for k:=1 to fcount do if funcs[k].name=s then GetFuncID:=funcs[k].code;
end;

procedure InitVarsUnit;
begin
count:=countM;
end;

function IsFunc ( s : string ):boolean;
var k:byte;
begin
s:=lowercase(s);
k:=length(s);
if (s[k]='#') or (s[k]='%') then delete(s, k, 1);
IsFunc:=IsName(s);
for k := 1 to fcount do if funcs[k].name=s then exit;
IsFunc:=false;
end;

function IsNumber ( const s : string ):boolean;
var k, start:byte;p:boolean;
begin
start:=1+byte((s[1]='-') or (s[1]='+'));
p:=false;
IsNumber:=true;
for k:= start to length(s) do begin
        if s[k]='.' then
                if p then IsNumber:=false else p:=true
        else
                if not (s[k] in TNUMERIC) then IsNumber:=false;
        end;
end;

function IsName ( s:string ):boolean;
var k:byte;
begin
s:=lowerCase(s);
if s='' then begin IsName:=true; exit; end;
IsName:=false;
if (s[1]<'a') or (s[1]>'z') then exit;
for k:=2 to length(s) do
        if not ((s[k] in TALPHABETICSHORT) or (s[k] in TFIGURES)) then exit;
IsName:=true;
end;

procedure VarLock;
begin
countM:=count;
end;

function IsVarFloat(s:string):boolean;
var k, l:integer;
begin
l:=length(s);
if s[l]='#' then begin IsVarFloat:=true; exit; end;
if s[l]='%' then begin IsVarFloat:=false; exit; end;
for k:=1 to count do
        if content[k].name=s then IsVarFloat:=content[k].float;
end;

function IsVar ( s:string ):integer;
var float, t : boolean; len, k:byte;
begin
if count>90 then begin VarError:=VAR_TOO_MANY; exit; end;
VarError:=VAR_NO_ERROR;
len:=length(s);
IsVar:=0;
if len=0 then exit;
float:=true; // это число
t:=false; // задан тип?
if s[len]='%' then begin float:=false; t:=true; end // если это указатель...
else if s[len]='#' then t:=true; // если это число
if t then dec(len); // если тип задан, убираем постфикс
s:=copy(s, 1, len);
if not IsName(s) then begin VarError:=VAR_INCORRECT_NAME; exit; end;
s:=lowercase(s);
for k:=1 to count do begin
        if content[k].name=s then begin //если имена совпадают
                if t and (float<>content[k].float) then // если тип задан и не совпадает
                        begin VarError:=VAR_INCORRECT_TYPE; exit; end;
                IsVar:=k;
                exit;
                end;
        end;
inc(count);
content[count].name:=s;
content[count].float:=float;
IsVar:=count;
end;

end.
