local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin

-- ----------------------------------------------------------------------------
-- HELPER FUNCTIONS (TREESITTER VERSION)
-- ----------------------------------------------------------------------------

local function in_mathzone()
    -- Get the current node at the cursor
    local node = vim.treesitter.get_node()

    -- Iterate up the tree to see if we are inside a math node
    while node do
        if node:type() == 'math_environment' or node:type() == 'inline_formula' or node:type() == 'displayed_equation' then
            return true
        end
        node = node:parent()
    end
    return false
end

-- ----------------------------------------------------------------------------
-- SNIPPETS
-- ----------------------------------------------------------------------------

return {

    s({trig = "in", snippetType="autosnippet"}, { t("\\in ") }, { condition = in_mathzone }),

    -- ==========================================
    -- 4. MATH SETS (Auto-Snippets)
    -- ==========================================
    s({trig = "RR", snippetType="autosnippet"}, { t("\\mathbb{R}") }, { condition = in_mathzone }),
    s({trig = "NN", snippetType="autosnippet"}, { t("\\mathbb{N}") }, { condition = in_mathzone }),
    s({trig = "ZZ", snippetType="autosnippet"}, { t("\\mathbb{Z}") }, { condition = in_mathzone }),
    s({trig = "QQ", snippetType="autosnippet"}, { t("\\mathbb{Q}") }, { condition = in_mathzone }),
    s({trig = "CC", snippetType="autosnippet"}, { t("\\mathbb{C}") }, { condition = in_mathzone }),
    s({trig = "FF", snippetType="autosnippet"}, { t("\\mathbb{F}") }, { condition = in_mathzone }),
    s({trig = "PP", snippetType="autosnippet"}, { t("\\mathbb{P}") }, { condition = in_mathzone }),
    -- ==========================================
    -- 4. CONDITIONAL LOGIC
    -- ==========================================
    s({trig = "imp", snippetType="autosnippet"}, { t("\\implies ") }, { condition = in_mathzone }),
    s({trig = "->", snippetType="autosnippet"}, { t("\\rightarrow ") }, { condition = in_mathzone }),
    s({trig = "<-", snippetType="autosnippet"}, { t("\\leftarrow ") }, { condition = in_mathzone }),
    s({trig = "<->", snippetType="autosnippet"}, { t("\\iff ") }, { condition = in_mathzone }),
    s({trig = "land", snippetType="autosnippet"}, { t("\\land ") }, { condition = in_mathzone }),
    s({trig = "lor", snippetType="autosnippet"}, { t("\\lor ") }, { condition = in_mathzone }),
    -- ==========================================
    -- 1. GENERAL ENVIRONMENTS (Regular Triggers)
    -- ==========================================
    s({trig = "beg", snippetType="autosnippet"}, fmta(
        [[
      \begin{<>}
          <>
      \end{<>}
    ]],
        {
            i(1),
            i(0),
            rep(1),
        }
    )),

    s({trig = "set", snippetType="autosnippet"}, fmta(
        [[
      \{ <> \}
    ]],
        {
            i(1),
        }
    ), {condition = in_mathzone}),

    -- SECTION
    s({trig = "sec", snippetType="autosnippet"}, fmta(
        [[
      \section{<>}
      \label{sec:<>}

      <>
    ]],
        { i(1), rep(1), i(0) }
    )),

    -- ITEMIZE LIST
    s({trig = "item", snippetType="autosnippet"}, fmta(
        [[
      \begin{itemize}
          \item <>
      \end{itemize}
    ]],
        { i(0) }
    )),

    s({trig = "*item", snippetType="autosnippet"}, fmta(
        [[
      \begin{itemize*}
          \item <>
      \end{itemize*}
    ]],
        { i(0) }
    )),

    ---ALIGN
    s({trig = "*align", snippetType="autosnippet"}, fmta(
        [[
      \begin{align*}
          <>
      \end{align*}
    ]],
        { i(0) }
    )),

    -- FIGURE
    s({trig = "fig", snippetType="autosnippet"}, fmta(
        [[
      \begin{figure}[htpb]
          \centering
          \includegraphics[width=0.8\linewidth]{<>}
          \caption{<>}
          \label{fig:<>}
      \end{figure}
    ]],
        { i(1), i(2), i(3) }
    )),

    -- ==========================================
    -- 2. MATH AUTOMATION (Auto-Snippets)
    -- ==========================================

    -- INLINE MATH ($...$)
    s({trig = "il", snippetType="autosnippet"}, fmta(
        "$<>$<>",
        { i(1), i(0) }
    )),

    -- DISPLAY MATH (\[ ... \])
    s({trig = "dm", snippetType="autosnippet"}, fmta(
        [[
      \[
          <>
      \] <>
    ]],
        { i(1), i(0) }
    )),

    -- FRACTION
    s({trig = "//", snippetType="autosnippet"}, fmta(
        "\\frac{<>}{<>}",
        { i(1), i(2) }
    ), { condition = in_mathzone }),

    -- SUBSCRIPT / SUPERSCRIPT
    s({trig = "td", snippetType="autosnippet"}, fmta("^{<>}", { i(1) }), { condition = in_mathzone }), 
    s({trig = "__", snippetType="autosnippet"}, fmta("_{<>}", { i(1) }), { condition = in_mathzone }), 

    -- ==========================================
    -- 3. GREEK LETTERS (Auto-Snippets)
    -- ==========================================
    s({trig = ";a", snippetType="autosnippet"}, { t("\\alpha") }, { condition = in_mathzone }),
    s({trig = ";b", snippetType="autosnippet"}, { t("\\beta") },  { condition = in_mathzone }),
    s({trig = ";g", snippetType="autosnippet"}, { t("\\gamma") }, { condition = in_mathzone }),
    s({trig = ";t", snippetType="autosnippet"}, { t("\\theta") }, { condition = in_mathzone }),
    s({trig = ";s", snippetType="autosnippet"}, { t("\\sigma") }, { condition = in_mathzone }),
    s({trig = ";d", snippetType="autosnippet"}, { t("\\delta") }, { condition = in_mathzone }),
    s({trig = ";p", snippetType="autosnippet"}, { t("\\phi") },   { condition = in_mathzone }),
    s({trig = ";O", snippetType="autosnippet"}, { t("\\Omega") }, { condition = in_mathzone }),
}
