object MainForm: TMainForm
  Left = 204
  Top = 141
  Width = 792
  Height = 560
  Caption = 'AI Editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 361
    Width = 784
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object Help: TMemo
    Left = 0
    Top = 364
    Width = 784
    Height = 123
    Align = alBottom
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 487
    Width = 784
    Height = 19
    Panels = <
      item
        Text = #1047#1076#1077#1089#1100' '#1073#1091#1076#1077#1090' '#1086#1087#1080#1089#1072#1085' '#1089#1080#1085#1090#1072#1082#1089#1080#1089' '#1090#1077#1082#1091#1097#1077#1081' '#1092#1091#1085#1082#1094#1080#1080
        Width = 400
      end>
  end
  object Editor: TRichEdit
    Left = 0
    Top = 0
    Width = 784
    Height = 361
    Align = alClient
    Color = 8934690
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    PopupMenu = PopupMenu
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    WordWrap = False
    OnKeyPress = EditorKeyPress
    OnSelectionChange = EditorSelectionChange
  end
  object MainMenu: TMainMenu
    Left = 632
    Top = 65528
    object MenuFile: TMenuItem
      Caption = 'File'
      object MenuNew: TMenuItem
        Caption = 'New'
        ShortCut = 16462
        OnClick = MenuNewClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MenuOpen: TMenuItem
        Caption = 'Open...'
        ShortCut = 16463
        OnClick = MenuOpenClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object MenuSave: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
        OnClick = MenuSaveClick
      end
      object MenuSaveAs: TMenuItem
        Caption = 'Save As...'
        OnClick = MenuSaveAsClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object MenuExit: TMenuItem
        Caption = 'Exit'
        OnClick = MenuExitClick
      end
    end
    object MenuEdit: TMenuItem
      Caption = 'Edit'
      object MenuUndo: TMenuItem
        Caption = 'Undo'
        ShortCut = 16474
        OnClick = MenuUndoClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object MenuCut: TMenuItem
        Caption = 'Cut'
        ShortCut = 16472
        OnClick = MenuCutClick
      end
      object MenuCopy: TMenuItem
        Caption = 'Copy'
        ShortCut = 16451
        OnClick = MenuCopyClick
      end
      object MenuPaste: TMenuItem
        Caption = 'Paste'
        ShortCut = 16470
        OnClick = MenuPasteClick
      end
      object MenuDelete: TMenuItem
        Caption = 'Delete'
        ShortCut = 16430
        OnClick = MenuDeleteClick
      end
      object SelectAll: TMenuItem
        Caption = 'Select All'
        ShortCut = 16449
        OnClick = SelectAllClick
      end
    end
    object MenuSearch: TMenuItem
      Caption = 'Search'
      object MenuFind: TMenuItem
        Caption = 'Find...'
        ShortCut = 16454
        OnClick = MenuFindClick
      end
      object MenuReplace: TMenuItem
        Caption = 'Replace...'
        ShortCut = 16466
        OnClick = MenuReplaceClick
      end
    end
    object MenuRuns: TMenuItem
      Caption = 'Run'
      object MenuRun: TMenuItem
        Caption = 'Run'
        ShortCut = 116
        OnClick = MenuRunClick
      end
      object MenuCompile: TMenuItem
        Caption = 'Compile'
        ShortCut = 117
        OnClick = MenuCompileClick
      end
      object MenuParameters: TMenuItem
        Caption = 'Parameters...'
        ShortCut = 118
        OnClick = MenuParametersClick
      end
    end
    object MenuHelp: TMenuItem
      Caption = 'Help'
      object MenuCleverBotshelp: TMenuItem
        Caption = 'SmartBots help'
        ShortCut = 16496
        OnClick = MenuCleverBotshelpClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object MenuAbout: TMenuItem
        Caption = 'About...'
        OnClick = MenuAboutClick
      end
    end
  end
  object PopupMenu: TPopupMenu
    Left = 368
    Top = 240
    object PopUndo: TMenuItem
      Caption = 'Undo'
      ShortCut = 16474
      OnClick = MenuUndoClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object PopCut: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = MenuCutClick
    end
    object PopCopy: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
      OnClick = MenuCopyClick
    end
    object PopPaste: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
      OnClick = MenuPasteClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PopHelp: TMenuItem
      Caption = 'Help'
      ShortCut = 112
      OnClick = PopHelpClick
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'txt'
    Filter = '*.txt|*.txt'
    InitialDir = 'scripts\sources'
    Options = [ofHideReadOnly, ofNoChangeDir, ofFileMustExist, ofEnableSizing]
    Left = 152
    Top = 72
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'txt'
    Filter = '*.txt|*.txt'
    InitialDir = 'scripts\sources'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofExtensionDifferent, ofEnableSizing]
    Left = 216
    Top = 80
  end
  object FindDialog: TFindDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = FindDialogFind
    Left = 320
    Top = 112
  end
  object ReplaceDialog: TReplaceDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = ReplaceDialogFind
    OnReplace = ReplaceDialogReplace
    Left = 408
    Top = 152
  end
end
