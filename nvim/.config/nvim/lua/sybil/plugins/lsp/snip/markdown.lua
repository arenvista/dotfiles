print("loaded md snips")
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
-- HELPER FUNCTIONS (TREESITTER VERSION - UPDATED)
-- ----------------------------------------------------------------------------

local function in_mathzone()
    -- Get the node at the cursor
    local node = vim.treesitter.get_node()
    while node do
        if node:type() == 'inline' then
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
    s({trig = ">=", snippetType="autosnippet"}, { t("\\geq ") }, { condition = in_mathzone }),
    s({trig = "<=", snippetType="autosnippet"}, { t("\\leq ") }, { condition = in_mathzone }),
    s({trig = "==", snippetType="autosnippet"}, { t("\\equiv ") }, { condition = in_mathzone }),
    -- ==========================================
    -- 1. GENERAL ENVIRONMENTS (Regular Triggers)
    -- ==========================================
    s({trig = "beg", snippetType="autosnippet"}, fmta(
        [[
      \begin{<>}
          <>
      \end{<>}
    ]],
        { i(1), i(0), rep(1), }
    )),

    s({trig = "nl", snippetType="autosnippet"}, { t("\\\\") } ),

    s({trig = "set", snippetType="autosnippet"}, fmta(
        [[
      \{ <> \}
    ]],
        { i(1), }
    ), {condition = in_mathzone}),

    -- SECTION
    s({trig = "sec", snippetType="autosnippet"}, fmta(
        [[
      \section{<>}

      <>
    ]],
        { i(1), i(0) }
    )),

    s({trig = "ssec", snippetType="autosnippet"}, fmta(
        [[
      \subsection{<>}

      <>
    ]],
        { i(1), i(0) }
    )),

    -- SEC*
    s({trig = "*sec", snippetType="autosnippet"}, fmta(
        [[
      \section*{<>}

      <>
    ]],
        { i(1), i(0) }
    )),

    s({trig = "*ssec", snippetType="autosnippet"}, fmta(
        [[
      \subsection*{<>}

      <>
    ]],
        { i(1), i(0) }
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
    s({trig = "^^", snippetType="autosnippet"}, fmta("^{<>}", { i(1) }), { condition = in_mathzone }),
    s({trig = "__", snippetType="autosnippet"}, fmta("_{<>}", { i(1) }), { condition = in_mathzone }),

    -- ==========================================
    -- 3. GREEK LETTERS (Auto-Snippets)
    -- ==========================================
    s({trig = ";a", snippetType="autosnippet"}, { t("\\alpha") }, { condition = in_mathzone }),
    s({trig = ";u", snippetType="autosnippet"}, { t("\\upeta") }, { condition = in_mathzone }),
    s({trig = ";b", snippetType="autosnippet"}, { t("\\beta") },  { condition = in_mathzone }),
    s({trig = ";g", snippetType="autosnippet"}, { t("\\gamma") }, { condition = in_mathzone }),
    s({trig = ";t", snippetType="autosnippet"}, { t("\\theta") }, { condition = in_mathzone }),
    s({trig = ";s", snippetType="autosnippet"}, { t("\\sigma") }, { condition = in_mathzone }),
    s({trig = ";d", snippetType="autosnippet"}, { t("\\delta") }, { condition = in_mathzone }),
    s({trig = ";p", snippetType="autosnippet"}, { t("\\phi") },   { condition = in_mathzone }),
    s({trig = ";O", snippetType="autosnippet"}, { t("\\Omega") }, { condition = in_mathzone }),
    s({trig = ";x", snippetType="autosnippet"}, { t("\\xi") }, { condition = in_mathzone }),
    s({trig = ";l", snippetType="autosnippet"}, { t("\\lambda") }, { condition = in_mathzone }),
    s({trig = ";L", snippetType="autosnippet"}, { t("\\Lambda") }, { condition = in_mathzone }),
    s({trig = ";e", snippetType="autosnippet"}, { t("\\epsilon") }, { condition = in_mathzone }),
    s({trig = ";ve", snippetType="autosnippet"}, { t("\\varepsilon") }, { condition = in_mathzone }),
    s({trig = ";o", snippetType="autosnippet"}, { t("\\omega") }, { condition = in_mathzone }),
    s({trig = "inf", snippetType="autosnippet"}, { t("\\infty") }, { condition = in_mathzone }),
    s({trig = "dag", snippetType="autosnippet"}, { t("\\dagger") }, { condition = in_mathzone }),
    s({trig = "~=", snippetType="autosnippet"}, { t("\\approx") }, { condition = in_mathzone }),
    -- ==========================================
    -- Calculus & Analysis (High Usage)
    -- ==========================================
    -- LIMIT
    s({trig = "lim", snippetType="autosnippet"}, fmta(
        "\\lim_{<> \\to <>} ",
        { i(1, "n"), i(2, "\\infty") }
    ), { condition = in_mathzone }),

    -- SUMMATION
    s({trig = "sum", snippetType="autosnippet"}, fmta(
        "\\sum_{<>}^{<>} ",
        { i(1, "n=1"), i(2, "\\infty") }
    ), { condition = in_mathzone }),

    -- INTEGRAL
    s({trig = "int", snippetType="autosnippet"}, fmta(
        "\\int_{<>}^{<>} <> \\, d<>",
        { i(1, "-\\infty"), i(2, "\\infty"), i(3), i(0) }
    ), { condition = in_mathzone }),

    -- PARTIAL DERIVATIVE (fraction style)
    s({trig = "part", snippetType="autosnippet"}, fmta(
        "\\frac{\\partial <>}{\\partial <>}",
        { i(1), i(2) }
    ), { condition = in_mathzone }),
    -- ==========================================
    -- FONTS, ACCENTS & TEXT
    -- ==========================================
    -- TEXT inside Math (e.g., " if " or " otherwise ")
    s({trig = "tt", snippetType="autosnippet"}, fmta(
        "\\text{<>}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- MATH CALIGRAPHY (e.g., \mathcal{F})
    s({trig = "mcal", snippetType="autosnippet"}, fmta(
        "\\mathcal{<>}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- MATH BOLD (e.g., \mathbf{x})
    s({trig = "mbf", snippetType="autosnippet"}, fmta(
        "\\mathbf{<>}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- HAT (e.g., \hat{x})
    s({trig = "hat", snippetType="autosnippet"}, fmta(
        "\\hat{<>}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- VECTOR (e.g., \vec{x})
    s({trig = "vec", snippetType="autosnippet"}, fmta(
        "\\vec{<>}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- BAR (e.g., \bar{x})
    s({trig = "bar", snippetType="autosnippet"}, fmta(
        "\\overline{<>}",
        { i(1) }
    ), { condition = in_mathzone }),
    -- ==========================================
    --- DELIM
    -- ==========================================
    -- PARENTHESES ()
    s({trig = "lrp", snippetType="autosnippet"}, fmta(
        "\\left( <> \\right)",
        { i(1) }
    ), { condition = in_mathzone }),

    -- SQUARE BRACKETS []
    s({trig = "lrb", snippetType="autosnippet"}, fmta(
        "\\left[ <> \\right]",
        { i(1) }
    ), { condition = in_mathzone }),

    -- CURLY BRACES {}
    s({trig = "lrc", snippetType="autosnippet"}, fmta(
        "\\left\\{ <> \\right\\}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- ABSOLUTE VALUE | |
    s({trig = "abs", snippetType="autosnippet"}, fmta(
        "\\left| <> \\right|",
        { i(1) }
    ), { condition = in_mathzone }),

    -- NORM || ||
    s({trig = "norm", snippetType="autosnippet"}, fmta(
        "\\left\\| <> \\right\\|",
        { i(1) }
    ), { condition = in_mathzone }),
    -- ==========================================
    -- FIXED SIZE DELIMITERS (Big variants)
    -- ==========================================
    -- BIG PARENTHESES \Big( \Big)
    s({trig = "bgp", snippetType="autosnippet"}, fmta(
        "\\Big( <> \\Big)",
        { i(1) }
    ), { condition = in_mathzone }),

    -- BIG SQUARE BRACKETS \Big[ \Big]
    s({trig = "bgb", snippetType="autosnippet"}, fmta(
        "\\Big[ <> \\Big]",
        { i(1) }
    ), { condition = in_mathzone }),

    -- BIG CURLY BRACES \Big\{ \Big\}
    s({trig = "bgc", snippetType="autosnippet"}, fmta(
        "\\Big\\{ <> \\Big\\}",
        { i(1) }
    ), { condition = in_mathzone }),

    -- BIG ABSOLUTE VALUE \Big| \Big|
    s({trig = "bga", snippetType="autosnippet"}, fmta(
        "\\Big| <> \\Big|",
        { i(1) }
    ), { condition = in_mathzone }),

    -- BIG NORM \Big\| \Big\|
    s({trig = "bgn", snippetType="autosnippet"}, fmta(
        "\\Big\\| <> \\Big\\|",
        { i(1) }
    ), { condition = in_mathzone }),
    -- ==========================================
    -- MATRIX
    -- ==========================================
    -- GENERIC PARENTHESIS MATRIX (pmatrix)
    s({trig = "pmat", snippetType="autosnippet"}, fmta(
        [[
      \begin{pmatrix}
          <>
      \end{pmatrix}
      ]],
        { i(1) }
    ), { condition = in_mathzone }),

    -- GENERIC BRACKET MATRIX (bmatrix)
    s({trig = "bmat", snippetType="autosnippet"}, fmta(
        [[
      \begin{bmatrix}
          <>
      \end{bmatrix}
      ]],
        { i(1) }
    ), { condition = in_mathzone }),
    -- ==========================================
    -- SQUARE ROOT
    -- ==========================================
    s({trig = "sq", snippetType="autosnippet"}, fmta(
        "\\sqrt{<>}",
        { i(1) }
    ), { condition = in_mathzone }),
}

