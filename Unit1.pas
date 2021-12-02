unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
//    File1: TMenuItem;
//    Edit1: TMenuItem;
//    Search1: TMenuItem;
//    Run1: TMenuItem;
//    Help1: TMenuItem;
    Help: TMemo;
    MenuNew: TMenuItem;
//    N2: TMenuItem;
    MenuOpen: TMenuItem;
//    N4: TMenuItem;
    MenuSave: TMenuItem;
    MenuSaveAs: TMenuItem;
//    N5: TMenuItem;
    MenuExit: TMenuItem;
    MenuCut: TMenuItem;
    MenuCopy: TMenuItem;
    MenuPaste: TMenuItem;
    MenuDelete: TMenuItem;
    SelectAll: TMenuItem;
    MenuFind: TMenuItem;
    MenuReplace: TMenuItem;
    MenuRun: TMenuItem;
    MenuCompile: TMenuItem;
    MenuCleverBotshelp: TMenuItem;
//    N6: TMenuItem;
    MenuAbout: TMenuItem;
    MenuParameters: TMenuItem;
    StatusBar: TStatusBar;
    Splitter1: TSplitter;
    MenuUndo: TMenuItem;
//    N7: TMenuItem;
    PopupMenu: TPopupMenu;
//    Undo2: TMenuItem;
//    N8: TMenuItem;
//    Cut1: TMenuItem;
//    Copy1: TMenuItem;
//    Paste1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    FindDialog: TFindDialog;
    Editor: TRichEdit;
    ReplaceDialog: TReplaceDialog;
//    N1: TMenuItem;
    PopHelp: TMenuItem;
    PopUndo: TMenuItem;
    PopCut: TMenuItem;
    PopCopy: TMenuItem;
    PopPaste: TMenuItem;
    MenuFile: TMenuItem;
    MenuEdit: TMenuItem;
    MenuSearch: TMenuItem;
    MenuRuns: TMenuItem;
    MenuHelp: TMenuItem;
    function CheckStr ( s:string ):integer;
    procedure obr(const i:byte);
    function Compile:boolean;
    procedure MenuRunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Viewfunctions1Click(Sender: TObject);
    procedure MenuCleverBotshelpClick(Sender: TObject);
    procedure MenuDeleteClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure CompileOps;
    procedure MenuCutClick(Sender: TObject);
    procedure MenuCopyClick(Sender: TObject);
    procedure MenuPasteClick(Sender: TObject);
    procedure MenuUndoClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuSaveAsClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MenuFindClick(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure MenuReplaceClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuCompileClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuParametersClick(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure EditorSelectionChange(Sender: TObject);
    procedure PopHelpClick(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: Char); // компилировать из стека ops[]
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveSources;
    procedure ColorStrings(i1, i2:integer);
    procedure SetTitle;
  end;

var
  MainForm: TMainForm;

implementation

uses Vars, ShellApi, Unit2;

const clLightBlue=170 + 255 shl 8 + 255 shl 16;

//---- константы для проверки синтаксиса ----
const UNDEFINED=0;
const NUMBER=1; //все числа
const BRACKET_OPEN=2; //открывающая скобка (
const BRACKET_CLOSE=4; //закрывающая скобка )
const VARIABLE=8; //переменная
const SIGNS1=16; // унарные/бинарные операции : +, -
const SIGNS2=32; // бинарные операции : *, /
const POINT=64; // запятая ,
const EQ1=128; // <
const EQ2=256; // =
const EQ3=512; //>
const LOGIC1=1024; // Not
const LOGIC2=2048; //And, Or
const FUNC0=4096; // функции, ничего не возвращающие
const FUNC1=8192; // функции, возвращающие результат
const IF_=16384; // if
const ELSE_=32768; // else
const ENDIF2_=65536; // end if,  endif
const END_=131072; // end

const SIGNS = SIGNS1 or SIGNS2; // +, -, *, /
const EQS = EQ1 or EQ2 or EQ3; // < = >
const ANY = NUMBER or VARIABLE; // число или переменная
const FUNC=FUNC1 or FUNC0; // функции
const ENDIF_=ENDIF2_ or END_;

//---- ошибки ----
var ErrorMsg : array[1..100] of string;
    ErrorPos, ErrorLen : integer;
    ErrorTag : string;

//---- глобальные переменные для проверки синтаксиса ----
var must, can : integer;

// ---- стек операторов ----
var ops, stack       : array[0..100] of string;
    ifs              : array[0..30]of integer; // >0 - IF , <0 - ELSE
    opstop, stacktop, ifstop : byte;
    CompileIf        : boolean;

var FileName, FormCaption :string;

type TDesc = record
        name, s, l : string;
        end;
var desc:array[1..100] of TDesc;
    DescList : TStringList;
    desctop : byte;

var HelpCommand, ScriptVersion : string;
    CodeList : TStringList;
//=============================================================================
{$R *.DFM}
//=============================================================================
function GetStringID ( s:string ):integer;
begin
GetStringID:=UNDEFINED;
s:=lowercase(s);
if s='(' then begin GetStringID:=BRACKET_OPEN; exit; end;
if s=')' then begin GetStringID:=BRACKET_CLOSE; exit; end;
if (s='+') or (s='-') then begin GetStringID:=SIGNS1; exit; end;
if (s='*') or (s='/') then begin GetStringID:=SIGNS2; exit; end;
if s=',' then begin GetStringID:=POINT; exit; end;
if s='<' then begin GetStringID:=EQ1; exit; end;
if s='=' then begin GetStringID:=EQ2; exit; end;
if s='>' then begin GetStringID:=EQ3; exit; end;
if s='not' then begin GetStringID:=LOGIC1; exit; end;
if (s='and') or (s='or') then begin GetStringID:=LOGIC2; exit; end;
if s='if' then begin GetStringID:=IF_; exit; end;
if s='else' then begin GetStringID:=ELSE_; exit; end;
if s='endif' then begin GetStringID:=ENDIF2_; exit; end;
if s='end' then begin GetStringID:=END_; exit; end;
if IsNumber(s) then begin GetStringID:=NUMBER; exit; end;
if IsFunc(s) then begin
        if funcs[FindFunc(s)].o=0 then GetStringID:=FUNC0 else GetStringID:=FUNC1;
        exit;
        end;
if IsVar(s)>0 then begin GetStringID:=VARIABLE; exit; end;
end;

function NextPos ( s:string; start:integer):integer;
var k:integer;
begin
s:=s+' ';
if not ((s[start] in TNUMERIC) or (s[start] in TALPHABETIC)) then
        begin NextPos:=start+1; exit; end;
for k := start+1 to length(s) do if not ( (s[k]in TNUMERIC) or (s[k] in TALPHABETIC) ) then break;
NextPos:=k;
end;

function Convert(const must:integer ):string;
var res:string;
begin
res:='';
if must and VARIABLE > 0 then res:=res+', переменная';
if must and NUMBER > 0 then res:=res+', число';
if (must and FUNC1 > 0) and (must and FUNC0 > 0) then res:=res+', любая функция' else begin
        if must and FUNC0 > 0 then res:=res+', функция(ничего не возвращающая)';
        if must and FUNC1 > 0 then res:=res+', функция(возвращающая результат)';
        end;
if (must and SIGNS1 > 0) and (must and SIGNS2 > 0) then res:=res+', арифметические операции(+, -, *, /)' else begin
        if must and SIGNS1 > 0 then res:=res+', - или +';
        if must and SIGNS2 > 0 then res:=res+', * или /';
        end;
if (must and EQ1 > 0) and (must and EQ2 > 0) and (must and EQ3 > 0) then res:=res+', знаки неравенств(<, =, >)' else begin
        if must and EQ1 > 0 then res:=res+', <';
        if must and EQ2 > 0 then res:=res+', =';
        if must and EQ3 > 0 then res:=res+', >';
        end;
if must and LOGIC1 > 0 then res:=res+', Not';
if must and LOGIC2 > 0 then res:=res+', логические операции(And, Or)';
if must and BRACKET_OPEN > 0 then res:=res+', открывающая скобка';
if must and BRACKET_CLOSE > 0 then res:=res+', закрывающая скобка';
if must and POINT > 0 then res:=res+', запятая';
Convert:=copy(res, 2, length(res)-1);
end;

function Prio(s:string):byte;
begin
Prio:=14;
if s='(' then Prio:=0; // открывающая скобка
if s=',' then Prio:=2; // запятая
if (s='-') or (s='+') then Prio:=4;
if (s='/') or (s='*') then Prio:=6;
if (s='=') or (s='<=') or (s='>=') or (s='<>') or (s='<') or (s='>') then Prio:=8;
if (s='or') or (s='and') then Prio:=10;
if (s='not') or (s='~') then Prio:=12;
end;

procedure TMainForm.obr(const i:byte);
var p:byte;
begin
p:=Prio(ops[i]);
while (stackTop>0) and (Prio(stack[StackTop])>=p) do begin
        CodeList.Add(inttostr(GetFuncID(stack[stackTop])));
        dec(stackTop);
        end;
end;

procedure AddS(const i:byte);
begin
inc(stacktop);
stack[stacktop]:=ops[i];
end;

procedure TMainForm.CompileOps;
var k, s : integer;
begin
if opstop=0 then exit; // если пусто, уходим
StackTop:=0;
s:=1;
if (not CompileIf) and (GetStringID(ops[1])=VARIABLE) then s:=3; // если это присваивание
for k := s to opstop do begin
        case GetStringID(ops[k]) of
        BRACKET_OPEN : AddS(k);
        POINT : obr(k);
        BRACKET_CLOSE : begin
                while stack[stackTop]<>'(' do begin
                        CodeList.Add(inttostr(GetFuncID(stack[stackTop])));
                        dec(stacktop);
                        end;
                dec(stacktop);
                end;
        VARIABLE : begin
                CodeList.Add(inttostr(GetFuncID('push_var')));
                CodeList.Add(inttostr(IsVar(ops[k])));
                end;
        NUMBER : begin
                CodeList.Add(inttostr(GetFuncID('push_num')));
                CodeList.Add('#'+ops[k]);
                end;
        else begin obr(k); adds(k); end; // '>', '<', '=', '<=', '>=', '<>', *, /, +, -, ~
        end; // case
        end;
while stacktop>0 do begin
        CodeList.Add(inttostr(GetFuncID(stack[stacktop])));
        dec(stacktop);
        end;
if s=3 then begin
        CodeList.Add(inttostr(GetFuncID('pop_')));
        CodeList.Add(inttostr(IsVar(ops[1])));
        end;
opstop:=0;
if CompileIf then begin
        CodeList.Add(inttostr(GetFuncID('if')));
        CodeList.Add('');
        inc(ifstop);
        ifs[ifstop]:=CodeList.count-1;
        CompileIf:=false;
        end;
end;

function TMainForm.CheckStr ( s:string ):integer;
var curr, next, t, brackets, old:integer; sub, oldsub:string;
var params:array[0..100] of string; // какие должны быть типы параметров?
    points:array[0..100] of byte; // сколько осталось запятых?
    float :array[0..100] of boolean;
    buf:byte;
    err : boolean;
function TopFloat:boolean;
begin
TopFloat:=params[brackets][points[brackets]]='#'
end;
function TopUndef:boolean;
begin
TopUndef:=params[brackets][points[brackets]]='?'
end;
begin
curr:=1;
if trim(s)='' then begin CheckStr:=0; exit; end; // если пусто, уходим
must:=FUNC0 or VARIABLE or IF_; // сначала должно быть...
can:=0;
if ifs[ifstop]>0 then must:=must or ELSE_ or ENDIF_; // если в вершине if
if ifs[ifstop]<0 then must:=must or ENDIF_; // если в вершине else
brackets:=0; // количество скобок
t:=0; // тип лексемы
opstop:=0;
CompileIf:=false;
CheckStr:=1;
while curr<=length(s) do begin
        next:=NextPos(s, curr);
        if trim(sub)<>'' then oldsub:=sub;
        sub:=copy(s, curr, next-curr);
        if trim(sub)<>'' then begin
                old := t;
                t := GetStringID ( sub );
                if VarError=VAR_INCORRECT_TYPE then begin
                        ErrorTag:='Неверно задан тип переменной!';
                        ErrorPos:=curr-1;
                        ErrorLen:=next-curr;
                        exit;
                        end;
                if t=UNDEFINED then begin
                        ErrorTag:='Неизвестный символ!';
                        ErrorPos:=curr-1;
                        ErrorLen:=next-curr;
                        exit;
                        end;
                if (t and must=0) and (t and can=0) then begin // не подходит - ошибка
                        sub := Convert(must or can);
                        ErrorTag:='Должно быть :'+sub;
                        if sub='' then ErrorTag:='Лишний символ!';
                        ErrorPos:=curr-1;
                        ErrorLen:=next-curr;
                        exit;
                        end;
                if t and ANY>0 then begin // число или переменная
                        if ((old = VARIABLE) or (old = NUMBER) or (old = BRACKET_CLOSE) or (old= 0 ) or (old=ELSE_) or (old=ENDIF2_)) and (brackets=0) and (t=VARIABLE) then
                                begin
                                CompileOps;
                                must:=EQ2;
                                can:=0;
                                points[0]:=1;
                                if IsVarFloat(sub) then params[0]:='#' else params[0]:='%';
                                end
                        else begin
                                if t = NUMBER then begin
                                  if (not TopFloat) and (not TopUndef) and (sub<>'0') then begin
                                    ErrorTag:='Несовместимость типов!';
                                    ErrorPos:=curr-1;
                                    ErrorLen:=next-curr;
                                    exit;
                                    end;
                                  end
                                else begin
                                  err:=IsVarFloat(sub);
                                  if (err<>TopFloat) and (not TopUndef) then begin
                                    ErrorTag:='Несовместимость типов!';
                                    ErrorPos:=curr-1;
                                    ErrorLen:=next-curr;
                                    exit;
                                    end;
                                  end;
                                must := 0;
                                can := EQS or SIGNS or LOGIC2 or BRACKET_CLOSE;
                                if points[brackets]>1 then must:=must or POINT;
                                if brackets=0 then can:=can or VARIABLE or FUNC0 or IF_;
                                if ifs[ifstop]>0 then can:=can or ELSE_ or ENDIF_; // если в вершине if
                                if ifs[ifstop]<0 then can:=can or ENDIF_; // если в вершине else
                                if brackets>0 then must:=must or BRACKET_CLOSE;
                                end;
                        end;
                if t and FUNC > 0 then begin
                        buf:=FindFunc(sub);
                        if (t=FUNC1) and (funcs[buf].float<>TopFloat) and (not TopUndef) then begin
                          ErrorTag:='Несовместимость типов!';
                          ErrorPos:=curr-1;
                          ErrorLen:=next-curr;
                          exit;
                          end;
                        if t = FUNC0 then CompileOps;
                        must:=BRACKET_OPEN;
                        buf:=length(sub);
                        if (sub[buf]='#') or (sub[buf]='%') then begin
                                ErrorTag:='После имени функции нельзя ставить постфикс '+sub[buf]+'.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        can:=0;
                        end;
                if t and POINT >0 then begin
                        err:=(brackets=0);
                        if not err then begin err:=(points[brackets]<=1); dec(points[brackets]); end;
                        if err then begin
                                ErrorTag:='Лишняя запятая.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        must:=ANY or BRACKET_OPEN or SIGNS1 or FUNC1 or LOGIC1;
                        can:=0;
                        end;
                if t and ENDIF_ > 0 then begin
                        must:=0;
                        can:=VARIABLE or FUNC0 or IF_;
                        if brackets<>0 then begin
                                ErrorTag:='Не хватает '+inttostr(brackets)+' закрывающих скобок.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        if ifstop=0 then begin
                                ErrorTag:='Конструкции EndIf должна предшествовать конструкция If..[Else]..';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        CompileOps;
                        CodeList[abs(ifs[ifstop])]:=inttostr(CodeList.Count);
                        sub:='';
                        dec(ifstop);
                        if t=END_ then begin must:=IF_; can:=0; end;
                        end;
                if (t = IF_) then begin
                    if old<>END_ then begin
                        if brackets<>0 then begin
                                ErrorTag:='Не хватает '+inttostr(brackets)+' закрывающих скобок.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        must:=BRACKET_OPEN or ANY or FUNC1;
                        points[0]:=1;
                        params[0]:='?';
                        can:=0;
                        CompileOps;
                        CompileIf:=true;
                        end
                    else begin
                         t:=ENDIF2_;
                         must:=0;
                         can:=VARIABLE or FUNC0 or IF_;
                         end;
                    sub:='';
                    end;
                if t = ELSE_ then begin
                        must:=0;
                        can:=VARIABLE or FUNC0;
                        if ifs[ifstop]<=0 then begin
                                ErrorTag:='Конструкции Else должна предшествовать конструкция If.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        if brackets<>0 then begin
                                ErrorTag:='Не хватает '+inttostr(brackets)+' закрывающих скобок.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        CompileOps;
                        CodeList.Add(inttostr(GetFuncID('goto_')));
                        CodeList.Add('');
                        sub:='';
                        CodeList[ifs[ifstop]]:=inttostr(CodeList.Count);
                        ifs[ifstop]:=-(CodeList.Count-1);
                        end;
                if t and BRACKET_OPEN > 0 then begin // открывающая скобка (
                        inc(brackets);
                        must := ANY or SIGNS1 or FUNC1 or LOGIC1 or BRACKET_OPEN;
                        can := 0;
                        if old and FUNC>0 then begin
                                buf:=FindFunc(oldsub);
                                params[brackets]:=funcs[buf].format;
                                end
                        else params[brackets]:='?';
                        points[brackets]:=length(params[brackets]);
                        if points[brackets]=0 then must:=must or BRACKET_CLOSE;
                        end;
                if t and BRACKET_CLOSE > 0 then begin // закрывающая скобка )
                        if brackets<1 then begin
                                ErrorTag:='Лишняя скобка.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        if points[brackets]>1 then begin
                                ErrorTag:='Не хватает параметров в функции. Еще должно быть '+inttostr(points[brackets]-1)+'.';
                                ErrorPos:=curr-1;
                                ErrorLen:=next-curr;
                                exit;
                                end;
                        dec(brackets);
                        must:=0;
                        can := SIGNS or EQS or LOGIC2;
                        if brackets=0 then can:=can or VARIABLE or FUNC0 or IF_;
                        if ifs[ifstop]>0 then can:=can or ELSE_ or ENDIF_; // если в вершине if
                        if ifs[ifstop]<0 then can:=can or ENDIF_; // если в вершине else
                        if brackets>0 then begin
                                must := must or BRACKET_CLOSE;
                                if points[brackets]>1 then can:=can or POINT;
                                end;
                        end;
                if t and (SIGNS or LOGIC2 or LOGIC1) > 0 then begin // + - / * and or not
                        if (old=BRACKET_OPEN) or (old and EQS>0) or (old and POINT>0) then begin
                                if sub='+' then sub:=''; // унарный плюс
                                if sub='-' then sub:='~'; // унарный минус
                                end;
                        must:=ANY or FUNC1 or BRACKET_OPEN;
                        can:=0;
                        end;
                if t and EQ1 > 0 then begin // <
                        must:=ANY or FUNC1 or BRACKET_OPEN or EQ2 or EQ3 or SIGNS1;
                        can:=0;
                        end;
                if t and EQ2 > 0 then begin // =
                        must:=ANY or FUNC1 or BRACKET_OPEN or SIGNS1;
                        can:=0;
                        end;
                if t and EQ3 > 0 then begin // >
                        must:=ANY or FUNC1 or BRACKET_OPEN or SIGNS1;
                        if old<>EQ1 then must:=must or EQ2;
                        can:=0;
                        end;
                if sub<>'' then begin
                        if (t and EQS>0) and (old and EQS>0) then ops[opstop]:=ops[opstop]+sub
                        else begin
                                inc(opstop);
                                ops[opstop]:=sub;
                                end;
                        end;
                end;
        curr:=next;
        end;
CompileOps;
if brackets>0 then begin
        ErrorTag:='Не хватает '+inttostr(brackets)+' закрывающих скобок!';
        ErrorPos:=curr-1;
        ErrorLen:=0;
        exit;
        end;
if must<>0 then begin
        sub := Convert(must);
        ErrorTag:='Должно быть :'+sub;
        if sub='' then ErrorTag:='Лишний символ!';
        ErrorPos:=curr-1;
        ErrorLen:=0;
        exit;
        end;
CheckStr:=0;
end;

function TMainForm.Compile:boolean;
var k : integer;
    str, sub, fname : string;
    p, start, glStart, f, size : integer;
    ps : byte;
    num : single;
begin
Compile:=false;
InitVarsUnit;
CodeList.Clear;
Help.Lines.Clear;
must:=0;
can:=0;
glStart:=0;
ifstop:=0; // глобальная вершина if'ов
ifs[0]:=0;
for k := 0 to Editor.Lines.Count-1 do begin
        str := Editor.Lines[k];
        ps:=pos(';', str);
        if ps>0 then str:=copy(str, 1, ps-1);
        str:=str+':';
        start:=0;
        p:=pos(':', str);
        repeat
                sub:=lowercase(copy(str, 1, p-1));
                delete(str, 1, p);
                if CheckStr(sub)<>0 then begin
                        Editor.SelStart:=glStart+start+ErrorPos;
                        Editor.SelLength:=ErrorLen;
                        Help.Lines.Add('Ошибка! '+ErrorTag);
                        exit;
                        end;
                p:=pos(':', str);
                if p=0 then break;
                start:=start+p;
        until false;
        inc(glStart, length(Editor.Lines[k])+2);
        end;
if ifstop<>0 then begin
        Help.Lines.Add('Ошибка! Не хватает '+inttostr(ifstop)+' конструкций EndIf!');
        exit;
        end;
if VarError=VAR_TOO_MANY then begin
        Help.Lines.Add('Ошибка! Вы используете слишком много переменных! Максимальное количество - 90.');
        exit;
        end;
if FileName='' then begin ShowMessage('Файл не сохранен! Компиляция не возможна.'); exit; end;
fname:=ExtractFileName(FileName);
fname:=copy(fname, 1, length(fname)-3)+'ai';
f:=FileCreate('scripts\'+fname);
WriteLine(f, ScriptVersion);
VarsWrite(f);
if BotModel='' then begin
        ShowMessage('Задайте модель бота.');
        Parameters.Show;
        exit;
        end;
WriteLine(f, BotModel);
WriteLine(f, BotName);
size:=CodeList.Count*4;
FileWrite(f, size, 4);
CodeList.SaveToFile('CodeList.txt');
DecimalSeparator:='.';
for p:=0 to CodeList.Count-1 do begin
        str:=CodeList[p];
        if str='' then begin ShowMessage('Еб твою мать, опять ошибка в редакторе!'+chr(13)+'Скажи разработчику, чтобы зашил дыры!'); exit; end;
        if str[1]='#' then begin
                delete(str, 1, 1);
                if str[1]='.' then str:='0'+str;
                num:=strtofloat(str);
                FileWrite(f, num, 4);
                end
        else begin
                start:=strtoint(str);
                FileWrite(f, start, 4);
                end;
        end;
FileClose(f);
help.lines.add('Компиляция прошла успешно.');
help.Lines.Add('Файл вашего ИИ сохранен в "scripts\'+fname+'"');
help.Lines.Add('Имя : '+BotName);
help.Lines.Add('Модель : '+BotModel);
help.Lines.Add('Чтобы изменить имя и модель нажмите F7.');
Compile:=true;
end;

procedure TMainForm.MenuRunClick(Sender: TObject);
begin
if Compile then
        ShellExecute(Handle,NIL,PChar('SmartBots.exe'), PChar('/nomenu'),nil,SW_SHOWNORMAL);
end;

function StrToInt(const s:string):integer;
var code, value:integer;
begin
val(s, value, code);
StrToInt:=value;
end;

procedure OpenBot;
var f:TextFile; s:string;
begin
s:=copy(FileName, 1, length(FileName)-3)+'cfg';
if FileExists(s) then begin
        AssignFile(f, s);
        Reset(f);
        readln(f, BotName);
        readln(f, BotModel);
        CloseFile(f);
        end
else begin
        BotName:='';
        BotModel:='';
        end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var f:TextFile;s, name, code, i, o, form, t:string;p:byte; x:integer;
  List: TStringList;
  Wnd : hWnd;
  buff: array [0..127] of Char;
begin
  List := TStringList.Create;
  Wnd := GetWindow(Handle, gw_HWndFirst);
  while Wnd <> 0 do begin
    if (Wnd <> Application.Handle) and
    (GetWindow(Wnd, gw_Owner) = 0) and
    (GetWindowText(Wnd, buff, sizeof(buff)) <> 0)
    then begin
      GetWindowText(Wnd, buff, sizeof(buff));
      List.Add(StrPas(buff));
    end;
    Wnd := GetWindow(Wnd, gw_hWndNext);
  end;
  for x := 0 to List.Count - 1 do
    if List.Strings[x] = Application.Title then Application.Terminate;
fcount:=0;
FileName:='';
FormCaption:=MainForm.Caption;
DescList:=TStringList.Create;
DescList.Clear;
if FileExists('cfg/EditorStart.cfg') then begin
  AssignFile(f, 'cfg/EditorStart.cfg');
  reset(f);
  readln(f, x);
  for p:=1 to x do begin
    readln(f, s);
    Help.Lines.Add(s);
    end;
  for p:=0 to MainMenu.Items.Count-1 do begin
    readln(f, s);
    if s<>'' then MainMenu.Items[p].Caption:=s;
    for x:=0 to MainMenu.Items[p].Count-1 do
      if MainMenu.Items[p].Items[x].Caption<>'-' then begin
        readln(f, s);
        if s<>'' then MainMenu.Items[p].Items[x].Caption:=s;
        end;
    end;
  CloseFile(f);
  end else ShowMessage('Не найден файл конфигурации EditorStart.cfg!');
if FileExists('cfg/description.cfg') then begin
        AssignFile(f, 'cfg/description.cfg');
        reset(f);
        desctop:=0;
        while not seekeof(f) do begin
                inc(desctop);
                readln(f, s);
                if trim(s)<>'' then begin
                        desc[desctop].name:=lowercase(s);
                        DescList.Add(desc[desctop].name);
                        readln(f, desc[desctop].s);
                        readln(f, desc[desctop].l);
                        end;
                end;
        closeFile(f);
        DescList.Sort;
        end else ShowMessage('Не найден файл конфигурации description.cfg!');
if FileExists('cfg/editor.cfg') then begin
        AssignFile(f, 'cfg/editor.cfg');
        reset(f);
        readln(f, FileName);
        FileName:='scripts\sources\'+FileName;
        if FileExists(FileName) then begin
            Editor.Lines.LoadFromFile(FileName);
            ColorStrings(0, length(Editor.Text));
            OpenBot;
            end else FileName:='';
        Editor.Modified:=false;
        SetTitle;
        readln(f, x);
        MainForm.Top:=x;
        readln(f, x);
        MainForm.Left:=x;
        readln(f, x);
        MainForm.Height:=x;
        readln(f, x);
        MainForm.Width:=x;
        closeFile(f);
        end;
if FileExists('cfg/cfg.cfg') then begin
        AssignFile(f, 'cfg/cfg.cfg');
        reset(f);
        readln(f, ScriptVersion);
        while not eof(f) do begin
                readln(f, s);
                if s<>'' then
                if s[1]<>';' then begin // если это не комментарий
                        StripString(s, name, code, i, o, form, t);
                        inc(fcount);
                        funcs[fcount].name:=lowercase(name);
                        funcs[fcount].code:=strtoint(code);
                        funcs[fcount].i:=strtoint(i);
                        funcs[fcount].o:=strtoint(o);
                        funcs[fcount].format:=form;
                        funcs[fcount].float:=(t='#');
                        end;
                end;
        closeFile(f);
        end else ShowMessage('Не найден файл конфигурации cfg.cfg! Правильная работа редактора не гарантирована!');
if FileExists('cfg/import.cfg') then begin
        AssignFile(f, 'cfg/import.cfg');
        reset(f);
        while not eof(f) do begin
                readln(f, s);
                p:=pos(';', s);
                if p>0 then delete(s, p, length(s)-p+1);
                s:=trim(s);
                if s<>'' then IsVar(s);
                end;
        VarLock;
        closeFile(f);
        end else ShowMessage('Не найден файл конфигурации import.cfg! Правильная работа редактора не гарантирована!');
CodeList:=TStringList.Create;
end;

procedure TMainForm.Viewfunctions1Click(Sender: TObject);
var k:byte;
begin
Help.Lines.Clear;
for k:=1 to fcount do Help.Lines.Add(funcs[k].name);
end;

procedure TMainForm.MenuCleverBotshelpClick(Sender: TObject);
var str:string;
begin
str:=GetCurrentDir()+'\main.html';
if FileExists(str) then ShellExecute(Handle, nil, PChar(str),nil,nil, SW_SHOWNORMAL)
end;

procedure TMainForm.MenuDeleteClick(Sender: TObject);
begin
Editor.ClearUndo;
Editor.ClearSelection;
end;

procedure TMainForm.SelectAllClick(Sender: TObject);
begin
Editor.SelStart:=0;
Editor.SelLength:=length(Editor.Text);
end;

procedure TMainForm.MenuAboutClick(Sender: TObject);
begin
ShowMessage('Редактор ИИ для игры SmartBots.');
end;

procedure TMainForm.MenuCutClick(Sender: TObject);
begin
Editor.ClearUndo;
Editor.CutToClipboard;
end;

procedure TMainForm.MenuCopyClick(Sender: TObject);
begin
Editor.ClearUndo;
Editor.CopyToClipboard;
end;

procedure TMainForm.MenuPasteClick(Sender: TObject);
var p:integer;
begin
Editor.ClearUndo;
p:=Editor.SelStart;
Editor.PasteFromClipboard;
ColorStrings(p, Editor.SelStart);
end;

procedure TMainForm.MenuUndoClick(Sender: TObject);
begin
Editor.Undo;
end;

procedure TMainForm.MenuOpenClick(Sender: TObject);
begin
if Editor.Modified then
        if MessageDlg('Текущий файл был изменен. Все равно продолжить?', mtConfirmation, [mbYes, mbNo], 0)=idNo then exit;
if OpenDialog.Execute then begin
        FileName:=OpenDialog.FileName;
        Editor.Lines.Clear;
        Editor.Lines.LoadFromFile(OpenDialog.FileName);
        ColorStrings(0, length(Editor.text));
        OpenBot;
        SetTitle;
        Editor.Modified:=false;
        end;
end;

procedure SaveBot;
var f:TextFile; s:string;
begin
s:=copy(FileName, 1, length(FileName)-3)+'cfg';
AssignFile(f, s);
Rewrite(f);
writeln(f, BotName);
writeln(f, BotModel);
CloseFile(f);
end;

procedure TMainForm.MenuSaveAsClick(Sender: TObject);
begin
if SaveDialog.Execute then begin
        FileName:=SaveDialog.FileName;
        SaveSources;
        SaveBot;
        Editor.Modified:=false;
        SetTitle;
        end;
end;

procedure TMainForm.MenuSaveClick(Sender: TObject);
begin
if FileName='' then begin
        if SaveDialog.Execute then begin
                FileName:=SaveDialog.FileName;
                SaveSources;
                SaveBot;
                Editor.Modified:=false;
                SetTitle;
                end;
        end
else begin
        SaveSources;
        SaveBot;
        Editor.Modified:=false;
        end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var f:TextFile;
begin
if Editor.Modified then
        if MessageDlg('Текущий файл был изменен. Все равно выйти?', mtConfirmation, [mbYes, mbNo], 0)=idNo then Action:=caNone;
AssignFile(f, 'cfg/editor.cfg');
rewrite(f);
writeln(f, ExtractFileName(FileName));
writeln(f, MainForm.Top);
writeln(f, MainForm.Left);
writeln(f, MainForm.Height);
writeln(f, MainForm.Width);
closeFile(f);
end;

procedure TMainForm.MenuFindClick(Sender: TObject);
begin
FindDialog.Execute;
end;

procedure TMainForm.FindDialogFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, ToEnd: Integer;
  i1, i2 : integer;
begin
  with Editor do
  begin
    if SelLength <> 0 then StartPos := SelStart + SelLength
    else StartPos := 0;
    i1:=SendMessage(Handle, em_LineFromChar, StartPos, 0);
    ToEnd := Length(Text) - StartPos;
    FoundAt := FindText(FindDialog.FindText, StartPos, ToEnd, []);
    if FoundAt <> -1 then
    begin
      i2:=SendMessage(Handle, em_LineFromChar, FoundAt, 0);
      SendMessage(Handle, em_LineScroll, 0, i2-i1);
      SelStart := FoundAt;
      SelLength := Length(FindDialog.FindText);
    end;
  end;
end;

procedure TMainForm.ReplaceDialogFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, ToEnd: Integer;
  i1, i2 : integer;
begin
  with Editor do
  begin
    if SelLength <> 0 then StartPos := SelStart + SelLength
    else StartPos := 0;
    i1:=SendMessage(Handle, em_LineFromChar, StartPos, 0);
    ToEnd := Length(Text) - StartPos;
    FoundAt := FindText(ReplaceDialog.FindText, StartPos, ToEnd, []);
    if FoundAt <> -1 then
    begin
      i2:=SendMessage(Handle, em_LineFromChar, FoundAt, 0);
      SendMessage(Handle, em_LineScroll, 0, i2-i1);
      SelStart := FoundAt;
      SelLength := Length(ReplaceDialog.FindText);
    end
    else SelLength:=0;
  end;
end;

procedure TMainForm.MenuReplaceClick(Sender: TObject);
begin
ReplaceDialog.Execute;
end;

procedure TMainForm.MenuNewClick(Sender: TObject);
begin
if Editor.Modified then
        if MessageDlg('Текущий файл был изменен. Все равно продолжить?', mtConfirmation, [mbYes, mbNo], 0)=idNo then exit;
FileName:='';
BotName:='Unnamed';
BotModel:=Parameters.fBotModel.Items[0];
Editor.Lines.Clear;
Editor.Modified:=false;
SetTitle;
end;

procedure TMainForm.MenuCompileClick(Sender: TObject);
begin
Compile;
end;

procedure TMainForm.MenuExitClick(Sender: TObject);
begin
close;
end;

procedure TMainForm.MenuParametersClick(Sender: TObject);
begin
Parameters.Show;
end;

procedure TMainForm.ReplaceDialogReplace(Sender: TObject);
begin
if frReplaceAll in ReplaceDialog.Options then begin
        Editor.SelLength:=0;
        repeat
                ReplaceDialogFind(Sender);
                if Editor.SelLength>0 then begin
                        Editor.SelText:=ReplaceDialog.ReplaceText;
                        Editor.SelLength:=Length(ReplaceDialog.ReplaceText);
                        end;
        until Editor.SelLength=0;
        end
else    begin
        if lowercase(Editor.SelText)=lowercase(ReplaceDialog.ReplaceText) then begin
                Editor.SelText:=ReplaceDialog.ReplaceText;
                Editor.SelLength:=Length(ReplaceDialog.ReplaceText);
                end;
        ReplaceDialogFind(Sender);
        end;
end;

procedure TMainForm.EditorSelectionChange(Sender: TObject);
var i1, i2, len:integer; c : char; s:string;
begin
i1:=Editor.SelStart;
if i1>0 then dec(i1);
i2:=Editor.SelStart;
len:=length(Editor.text);
if len>0 then begin
        while true do begin
                c:=Editor.Text[i1+1];
                if i1<0 then break;
                if not ((c in TALPHABETICSHORT) or (c in TFIGURES)) then break;
                dec(i1);
                end;
        inc(i1);
        while true do begin
                c:=Editor.Text[i2+1];
                if not ((c in TALPHABETICSHORT) or (c in TFIGURES)) then break;
                if i2>len then break;
                inc(i2);
                end;
        s:=lowercase(copy(Editor.Text, i1+1, i2-i1));
        for i1:=1 to desctop do if s=desc[i1].name then begin
                StatusBar.Panels[0].Text:=desc[i1].s;
                HelpCommand:=desc[i1].name;
                end;
        end;
end;

procedure TMainForm.PopHelpClick(Sender: TObject);
var k, ps:byte; s:string;
begin
for k:=1 to desctop do
        if HelpCommand=desc[k].name then begin
                s:=desc[k].l;
                ps:=pos('|', s);
                Help.Lines.Clear;
                while ps>0 do begin
                        Help.Lines.Add(copy(s, 1, ps-1));
                        delete(s, 1, ps);
                        ps:=pos('|', s);
                        end;
                Help.Lines.Add(s);
                end;
end;

procedure TMainForm.SaveSources;
var k:integer;
begin
CodeList.Clear;
CodeList.AddStrings(Editor.Lines);
CodeList.SaveToFile(FileName);
end;

procedure TMainForm.ColorStrings(i1, i2: integer);
var k, os, ol, p, l, n, i, start:integer; s:string;
begin
LockWindowUpdate(Editor.Handle);
i1:=SendMessage(Editor.Handle, em_LineFromChar, i1, 0);
i2:=SendMessage(Editor.Handle, em_LineFromChar, i2, 0);
os:=Editor.SelStart;
ol:=Editor.SelLength;
for k:=i1 to i2 do begin
  start:=SendMessage(Editor.Handle, em_LineIndex, k, 0);
  s:=lowercase(Editor.Lines[k]);
  p:=1;
  l:=length(s);
  Editor.SelStart:=start;
  Editor.SelLength:=l;
  Editor.SelAttributes.Color:=clWhite;
  while p<=l do begin
    if s[p]=';' then begin
        Editor.SelStart:=start+p-1;
        Editor.SelLength:=l-p+1;
        Editor.SelAttributes.Color:=clYellow;
        break;
        end;
    n:=NextPos(s, p);
    if DescList.Find(copy(s, p, n-p), i) then begin
        Editor.SelStart:=start+p-1;
        Editor.SelLength:=n-p;
        Editor.SelAttributes.Color:=clLightBlue;
        end;
    p:=n;
    end;
  end;
Editor.SelStart:=os;
Editor.SelLength:=ol;
LockWindowUpdate(0);
end;

procedure TMainForm.EditorKeyPress(Sender: TObject; var Key: Char);
begin
if ord(key)>31 then begin
  Editor.SelText:=key;
  key:=#0;
  end;
ColorStrings(Editor.SelStart, Editor.SelStart+Editor.SelLength);
end;

procedure TMainForm.SetTitle;
begin
if FileName='' then MainForm.Caption:=FormCaption else
MainForm.Caption:=FormCaption+ ' - '+ExtractFileName(FileName)+'  ['+BotName+']  ['+BotModel+']';
end;

end.
