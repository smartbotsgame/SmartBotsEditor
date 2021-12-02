unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TParameters = class(TForm)
    Button1: TButton;
    Button2: TButton;
    fBotModel: TListBox;
    fBotName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Parameters: TParameters;
  BotName, BotModel : string;
implementation
uses Unit1;
{$R *.DFM}

procedure TParameters.Button2Click(Sender: TObject);
begin
close;
end;

procedure TParameters.Button1Click(Sender: TObject);
begin
BotName:=fBotName.Text;
if fBotModel.ItemIndex>=0 then
        BotModel := fBotModel.Items[fBotModel.itemIndex]
else    BotModel:='';
MainForm.SetTitle;
close;
end;

procedure TParameters.FormCreate(Sender: TObject);
var sr:TSearchRec;
begin
if FindFirst('bots\*.b3d', 0, sr)=0 then begin
        fBotModel.Items.Add(copy(sr.name, 1, length(sr.name)-4));
        fBotModel.ItemIndex:=0;
        while FindNext(sr)=0 do begin
                fBotModel.Items.Add(copy(sr.name, 1, length(sr.name)-4));
                end;
        FindClose(sr);
        end;
end;

procedure TParameters.FormShow(Sender: TObject);
var k:byte;
begin
fBotNAme.Text:=BotName;
with fBotModel do
for k:=0 to Items.Count-1 do
        if lowercase(Items[k])=lowercase(BotModel) then begin ItemIndex:=k; exit; end;
fBotModel.ItemIndex:=0;
end;

procedure TParameters.FormKeyPress(Sender: TObject; var Key: Char);
begin
if key=#27 then close;
end;

end.
