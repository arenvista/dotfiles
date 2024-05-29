set background=dark
if exists('g:colors_name')
hi clear
if exists('syntax_on')
syntax reset
endif
endif
let g:colors_name = 'lushwal'
highlight Normal guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight! link User Normal
highlight Bold guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=bold
highlight Boolean guifg=#A46751 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Character guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight ColorColumn guifg=#AFA09D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Comment guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight Conceal guifg=#988D8B guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight! link Whitespace Conceal
highlight Conditional guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Constant guifg=#A46751 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Cursor guifg=#0A0A0A guibg=#DACBC8 guisp=NONE blend=NONE gui=NONE
highlight CursorColumn guifg=#AFA09D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight CursorLine guifg=#988D8B guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight CursorLineNr guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Debug guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Define guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Delimiter guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticError guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticHint guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticInfo guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticUnderlineError guifg=#8E4C33 guibg=NONE guisp=#8E4C33 blend=NONE gui=underline
highlight DiagnosticUnderlineHint guifg=#B0A3A0 guibg=NONE guisp=#B0A3A0 blend=NONE gui=underline
highlight DiagnosticUnderlineInfo guifg=#6C8A93 guibg=NONE guisp=#6C8A93 blend=NONE gui=underline
highlight DiagnosticUnderlineWarn guifg=#A98579 guibg=NONE guisp=#A98579 blend=NONE gui=underline
highlight DiagnosticWarn guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiffAdd guifg=#946E61 guibg=#988D8B guisp=NONE blend=NONE gui=bold
highlight! link DiffAdded DiffAdd
highlight DiffChange guifg=#C4B3B0 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight DiffDelete guifg=#8E4C33 guibg=#988D8B guisp=NONE blend=NONE gui=bold
highlight! link DiffRemoved DiffDelete
highlight! link diffRemoved DiffDelete
highlight DiffFile guifg=#8E4C33 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight DiffLine guifg=#6C8A93 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight DiffNewFile guifg=#946E61 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight DiffText guifg=#6C8A93 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight Directory guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight EndOfBuffer guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Error guifg=#8E4C33 guibg=#DACBC8 guisp=NONE blend=NONE gui=NONE
highlight ErrorMsg guifg=#8E4C33 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Exception guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Float guifg=#A46751 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight FoldColumn guifg=#6C8A93 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Folded guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=italic
highlight Function guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Identifier guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight IncSearch guifg=#988D8B guibg=#A46751 guisp=NONE blend=NONE gui=NONE
highlight Include guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Italic guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=italic
highlight Keyword guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Label guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight LineNr guifg=#C4B3B0 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Macro guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MatchParen guifg=#DACBC8 guibg=#C4B3B0 guisp=NONE blend=NONE gui=NONE
highlight MiniCompletionActiveParameter guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniCursorword guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=underline
highlight! link MiniCursorwordCurrent MiniCursorword
highlight MiniIndentscopePrefix guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=nocombine
highlight MiniIndentscopeSymbol guifg=#988D8B guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight MiniJump guifg=#6C8A93 guibg=NONE guisp=#C4B3B0 blend=NONE gui=underline
highlight MiniJump2dSpot guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=undercurl
highlight MiniStarterCurrent guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterFooter guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniStarterHeader guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniStarterInactive guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight MiniStarterItem guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight MiniStarterItemBullet guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterItemPrefix guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterQuery guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterSection guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineDevinfo guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineFileinfo guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineFilename guifg=#A98579 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineInactive guifg=#AFA09D guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeCommand guifg=#0A0A0A guibg=#B0A3A0 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeInsert guifg=#0A0A0A guibg=#6C8A93 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeNormal guifg=#0A0A0A guibg=#946E61 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeOther guifg=#0A0A0A guibg=#B6B0C4 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeReplace guifg=#0A0A0A guibg=#8E4C33 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeVisual guifg=#0A0A0A guibg=#A46751 guisp=NONE blend=NONE gui=NONE
highlight MiniSurround guifg=#988D8B guibg=#A46751 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineCurrent guifg=#C4B3B0 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineFill guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniTablineHidden guifg=#946E61 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedCurrent guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedHidden guifg=#AFA09D guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedVisible guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineVisible guifg=#C4B3B0 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight MiniTestEmphasis guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTestFail guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTestPass guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTrailspace guifg=#8E4C33 guibg=#DACBC8 guisp=NONE blend=NONE gui=NONE
highlight ModeMsg guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MoreMsg guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight NonText guifg=#C4B3B0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Number guifg=#A46751 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Operator guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PMenu guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight PMenuSel guifg=#DACBC8 guibg=#6C8A93 guisp=NONE blend=NONE gui=NONE
highlight PmenuSbar guifg=#AFA09D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PmenuThumb guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PreProc guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Question guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Repeat guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Search guifg=#C4B3B0 guibg=#A98579 guisp=NONE blend=NONE gui=NONE
highlight! link MiniTablineTabpagesection Search
highlight SignColumn guifg=#AFA09D guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight Special guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpecialChar guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpecialKey guifg=#C4B3B0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpellBad guifg=#8E4C33 guibg=NONE guisp=#8E4C33 blend=NONE gui=underline
highlight SpellCap guifg=#A98579 guibg=NONE guisp=#A98579 blend=NONE gui=underline
highlight SpellLocal guifg=#B0A3A0 guibg=NONE guisp=#B0A3A0 blend=NONE gui=underline
highlight SpellRare guifg=#B6B0C4 guibg=NONE guisp=#B6B0C4 blend=NONE gui=underline
highlight Statement guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight StatusLine guifg=#DACBC8 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight StatusLineNC guifg=#AFA09D guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight StatusLineTerm guifg=#946E61 guibg=#946E61 guisp=NONE blend=NONE gui=NONE
highlight StatusLineTermNC guifg=#A98579 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight StorageClass guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight String guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Structure guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight TabLine guifg=#C4B3B0 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight TabLineFill guifg=#C4B3B0 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight TabLineSel guifg=#946E61 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight Tag guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Title guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight Todo guifg=#A98579 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight TooLong guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Type guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Typedef guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Underlined guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight VertSplit guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight! link WinSeparator VertSplit
highlight Visual guifg=#0A0A0A guibg=#AFA09D guisp=NONE blend=NONE gui=NONE
highlight VisualNOS guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight WarningMsg guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight WildMenu guifg=#DACBC8 guibg=#6C8A93 guisp=NONE blend=NONE gui=NONE
highlight WinBar guifg=#DACBC8 guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight WinBarNC guifg=#AFA09D guibg=#0A0A0A guisp=NONE blend=NONE gui=NONE
highlight gitCommitOverflow guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight gitCommitSummary guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight helpCommand guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight helpExample guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @attribute guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @boolean guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @character guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @character.special guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @comment guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight @conditional guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant.builtin guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant.macro guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constructor guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @debug guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @define guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @exception guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @field guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @float guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function.builtin guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function.macro guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @include guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword.function guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword.operator guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @label guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @method guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @namespace guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @none guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @number guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @operator guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @parameter guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @preproc guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @property guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.bracket guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.delimiter guifg=#DACBC8 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.special guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @repeat guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @storageclass guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.escape guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.regex guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.special guifg=#99563D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @symbol guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag.attribute guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag.delimiter guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.bold guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @text.danger guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.diff.add guifg=#946E61 guibg=#988D8B guisp=NONE blend=NONE gui=bold
highlight @text.diff.delete guifg=#8E4C33 guibg=#988D8B guisp=NONE blend=NONE gui=bold
highlight @text.emphasis guifg=#B6B0C4 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight @text.environment guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.environment.name guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.literal guifg=#946E61 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.math guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.note guifg=#B0A3A0 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.reference guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.strike guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=strikethrough
highlight @text.title guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @text.todo guifg=#A98579 guibg=#988D8B guisp=NONE blend=NONE gui=NONE
highlight @text.underline guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=underline
highlight @text.uri guifg=NONE guibg=#988D8B guisp=NONE blend=NONE gui=underline
highlight @type guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @type.builtin guifg=#6C8A93 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @type.definition guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @variable guifg=#A98579 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @variable.builtin guifg=#8E4C33 guibg=NONE guisp=NONE blend=NONE gui=NONE