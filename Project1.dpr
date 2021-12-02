program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  vars in 'vars.pas',
  Unit2 in 'Unit2.pas' {Parameters};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'AI Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TParameters, Parameters);
  Application.Run;
end.
