local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node


local function in_mathzone()
    local node = vim.treesitter.get_node({ ignore_injections = false })

    while node do
        local type = node:type()
        -- Debug: Print types to see what the injected parser sees
        -- print(type)

        if type == "displayed_equation" or type == "inline_formula" or type == "math_environment" then
            return true
        end

        node = node:parent()
    end
    return false
end

return {
    s({trig = "mb", snippetType="autosnippet"}, fmta(
        [[ \mathbf{<>} ]], {i(0)}
    )),
    -- ==========================================
    -- 0. LOGIC & SYMBOLS
    -- ==========================================
    --
    s({ trig = "-con", snippetType = "autosnippet" }, { t("\\unicode{x21af}") }, { condition = in_mathzone }),
    s({ trig = "*", snippetType = "autosnippet" }, { t("\\cdot") }, { condition = in_mathzone }),
    s({ trig = ". ", snippetType = "autosnippet" }, { t("& ") }, { condition = in_mathzone }),
    s({ trig = ";x", snippetType = "autosnippet" }, { t("\\times") }, { condition = in_mathzone }),
    s({ trig = "exi", snippetType = "autosnippet" }, { t("\\exists ~") }, { condition = in_mathzone }),
    s({ trig = "for", snippetType = "autosnippet" }, { t("\\forall ~") }, { condition = in_mathzone }),
    s({ trig = "!!", snippetType = "autosnippet" }, { t("\\not") }, { condition = in_mathzone }),
    s({ trig = "eset", snippetType = "autosnippet" }, { t("\\emptyset") }, { condition = in_mathzone }),
    s({ trig = "_set", snippetType = "autosnippet" }, { t("\\subset") }, { condition = in_mathzone }),
    s({ trig = "=set", snippetType = "autosnippet" }, { t("\\subseteq") }, { condition = in_mathzone }),

    -- ==========================================
    -- 1. MATH SETS (Auto-Snippets)
    -- ==========================================
    s({ trig = "RR", snippetType = "autosnippet" }, { t("\\mathbb{R}") }, { condition = in_mathzone }),
    s({ trig = "NN", snippetType = "autosnippet" }, { t("\\mathbb{N}") }, { condition = in_mathzone }),
    s({ trig = "ZZ", snippetType = "autosnippet" }, { t("\\mathbb{Z}") }, { condition = in_mathzone }),
    s({ trig = "QQ", snippetType = "autosnippet" }, { t("\\mathbb{Q}") }, { condition = in_mathzone }),
    s({ trig = "CC", snippetType = "autosnippet" }, { t("\\mathbb{C}") }, { condition = in_mathzone }),
    s({ trig = "FF", snippetType = "autosnippet" }, { t("\\mathbb{F}") }, { condition = in_mathzone }),
    s({ trig = "PP", snippetType = "autosnippet" }, { t("\\mathbb{P}") }, { condition = in_mathzone }),

    -- ==========================================
    -- 2. CONDITIONAL LOGIC
    -- ==========================================
    s({ trig = "imp", snippetType = "autosnippet" }, { t("\\implies ") }, { condition = in_mathzone }),
    s({ trig = "-ra", snippetType = "autosnippet" }, { t("\\rightarrow ") }, { condition = in_mathzone }),
    s({ trig = "-la", snippetType = "autosnippet" }, { t("\\leftarrow ") }, { condition = in_mathzone }),
    s({ trig = "<->", snippetType = "autosnippet" }, { t("\\iff ") }, { condition = in_mathzone }),
    s({ trig = "land", snippetType = "autosnippet" }, { t("\\land ") }, { condition = in_mathzone }),
    s({ trig = "lor", snippetType = "autosnippet" }, { t("\\lor ") }, { condition = in_mathzone }),
    s({ trig = ">=", snippetType = "autosnippet" }, { t("\\geq ") }, { condition = in_mathzone }),
    s({ trig = "<=", snippetType = "autosnippet" }, { t("\\leq ") }, { condition = in_mathzone }),
    s({ trig = "==", snippetType = "autosnippet" }, { t("\\equiv ") }, { condition = in_mathzone }),

    -- ==========================================
    -- 3. STRUCTURES INSIDE MATH
    -- ==========================================

    s(
        { trig = "./", snippetType = "autosnippet" },
        fmta(
            [[
            \\
            <>
    ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),
    s(
        { trig = "set", snippetType = "autosnippet" },
        fmta(
            [[
      \{ <> \}
    ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    -- FRACTION
    s(
        { trig = "//", snippetType = "autosnippet" },
        fmta("\\frac{<>}{<>}", { i(1), i(2) }),
        { condition = in_mathzone }
    ),

    -- SUBSCRIPT / SUPERSCRIPT
    s({ trig = "^^", snippetType = "autosnippet" }, fmta("^{<>}", { i(1) }), { condition = in_mathzone }),
    s({ trig = "__", snippetType = "autosnippet" }, fmta("_{<>}", { i(1) }), { condition = in_mathzone }),

    -- ==========================================
    -- 4. GREEK LETTERS (Auto-Snippets)
    -- ==========================================
    s({ trig = ";a", snippetType = "autosnippet" }, { t("\\alpha") }, { condition = in_mathzone }),
    s({ trig = ";u", snippetType = "autosnippet" }, { t("\\upeta") }, { condition = in_mathzone }),
    s({ trig = ";b", snippetType = "autosnippet" }, { t("\\beta") }, { condition = in_mathzone }),
    s({ trig = ";g", snippetType = "autosnippet" }, { t("\\gamma") }, { condition = in_mathzone }),
    s({ trig = ";t", snippetType = "autosnippet" }, { t("\\theta") }, { condition = in_mathzone }),
    s({ trig = ";s", snippetType = "autosnippet" }, { t("\\sigma") }, { condition = in_mathzone }),
    s({ trig = ";d", snippetType = "autosnippet" }, { t("\\delta") }, { condition = in_mathzone }),
    s({ trig = ";p", snippetType = "autosnippet" }, { t("\\phi") }, { condition = in_mathzone }),
    s({ trig = ";O", snippetType = "autosnippet" }, { t("\\Omega") }, { condition = in_mathzone }),
    s({ trig = ";x", snippetType = "autosnippet" }, { t("\\xi") }, { condition = in_mathzone }),
    s({ trig = ";l", snippetType = "autosnippet" }, { t("\\lambda") }, { condition = in_mathzone }),
    s({ trig = ";L", snippetType = "autosnippet" }, { t("\\Lambda") }, { condition = in_mathzone }),
    s({ trig = ";e", snippetType = "autosnippet" }, { t("\\epsilon") }, { condition = in_mathzone }),
    s({ trig = ";ve", snippetType = "autosnippet" }, { t("\\varepsilon") }, { condition = in_mathzone }),
    s({ trig = ";o", snippetType = "autosnippet" }, { t("\\omega") }, { condition = in_mathzone }),
    s({ trig = "_inf", snippetType = "autosnippet" }, { t("\\infty") }, { condition = in_mathzone }),
    s({ trig = "dag", snippetType = "autosnippet" }, { t("\\dagger") }, { condition = in_mathzone }),
    s({ trig = "~=", snippetType = "autosnippet" }, { t("\\approx") }, { condition = in_mathzone }),
    s({ trig = "in", snippetType = "autosnippet" }, { t("\\in") }, { condition = in_mathzone }),

    -- ==========================================
    -- 5. CALCULUS & ANALYSIS
    -- ==========================================
    -- LIMIT
    s(
        { trig = "lim", snippetType = "autosnippet" },
        fmta("\\lim_{<> \\to <>} ", { i(1, "n"), i(2, "\\infty") }),
        { condition = in_mathzone }
    ),

    -- SUMMATION
    s(
        { trig = "sum", snippetType = "autosnippet" },
        fmta("\\sum_{<>}^{<>} ", { i(1, "n=1"), i(2, "\\infty") }),
        { condition = in_mathzone }
    ),

    -- INTEGRAL
    s(
        { trig = "int", snippetType = "autosnippet" },
        fmta("\\int_{<>}^{<>} <> \\, d<>", { i(1, "-\\infty"), i(2, "\\infty"), i(3), i(0) }),
        { condition = in_mathzone }
    ),

    -- PARTIAL DERIVATIVE (fraction style)
    s(
        { trig = "part", snippetType = "autosnippet" },
        fmta("\\frac{\\partial <>}{\\partial <>}", { i(1), i(2) }),
        { condition = in_mathzone }
    ),

    -- ==========================================
    -- 6. FONTS, ACCENTS & TEXT
    -- ==========================================
    -- TEXT inside Math
    s({ trig = "tt", snippetType = "autosnippet" }, fmta("\\text{<>}", { i(1) }), { condition = in_mathzone }),

    -- MATH CALIGRAPHY
    s({ trig = "mcal", snippetType = "autosnippet" }, fmta("\\mathcal{<>}", { i(1) }), { condition = in_mathzone }),

    -- MATH BOLD
    s({ trig = "mbf", snippetType = "autosnippet" }, fmta("\\mathbf{<>}", { i(1) }), { condition = in_mathzone }),

    -- HAT
    s({ trig = "hat", snippetType = "autosnippet" }, fmta("\\hat{<>}", { i(1) }), { condition = in_mathzone }),

    -- VECTOR
    s({ trig = "vec", snippetType = "autosnippet" }, fmta("\\vec{<>}", { i(1) }), { condition = in_mathzone }),

    -- BAR
    s({ trig = "bar", snippetType = "autosnippet" }, fmta("\\overline{<>}", { i(1) }), { condition = in_mathzone }),

    -- ==========================================
    -- 7. DELIMITERS
    -- ==========================================
    -- PARENTHESES ()
    s(
        { trig = "lrp", snippetType = "autosnippet" },
        fmta("\\left( <> \\right)", { i(1) }),
        { condition = in_mathzone }
    ),

    -- SQUARE BRACKETS []
    s(
        { trig = "lrb", snippetType = "autosnippet" },
        fmta("\\left[ <> \\right]", { i(1) }),
        { condition = in_mathzone }
    ),

    -- CURLY BRACES {}
    s(
        { trig = "lrc", snippetType = "autosnippet" },
        fmta("\\left\\{ <> \\right\\}", { i(1) }),
        { condition = in_mathzone }
    ),

    -- ABSOLUTE VALUE | |
    s(
        { trig = "abs", snippetType = "autosnippet" },
        fmta("\\left| <> \\right|", { i(1) }),
        { condition = in_mathzone }
    ),

    -- NORM || ||
    s(
        { trig = "norm", snippetType = "autosnippet" },
        fmta("\\left\\| <> \\right\\|", { i(1) }),
        { condition = in_mathzone }
    ),

    -- ==========================================
    -- 8. FIXED SIZE DELIMITERS (Big variants)
    -- ==========================================
    -- BIG PARENTHESES
    s({ trig = "bgp", snippetType = "autosnippet" }, fmta("\\Big( <> \\Big)", { i(1) }), { condition = in_mathzone }),

    -- BIG SQUARE BRACKETS
    s({ trig = "bgb", snippetType = "autosnippet" }, fmta("\\Big[ <> \\Big]", { i(1) }), { condition = in_mathzone }),

    -- BIG CURLY BRACES
    s(
        { trig = "bgc", snippetType = "autosnippet" },
        fmta("\\Big\\{ <> \\Big\\}", { i(1) }),
        { condition = in_mathzone }
    ),

    -- BIG ABSOLUTE VALUE
    s({ trig = "bga", snippetType = "autosnippet" }, fmta("\\Big| <> \\Big|", { i(1) }), { condition = in_mathzone }),

    -- BIG NORM
    s(
        { trig = "bgn", snippetType = "autosnippet" },
        fmta("\\Big\\| <> \\Big\\|", { i(1) }),
        { condition = in_mathzone }
    ),

    -- ==========================================
    -- 9. MATRICES & ROOTS
    -- ==========================================
    -- GENERIC PARENTHESIS MATRIX (pmatrix)
    s(
        { trig = "pmat", snippetType = "autosnippet" },
        fmta(
            [[
      \begin{pmatrix}
          <>
      \end{pmatrix}
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    -- GENERIC BRACKET MATRIX (bmatrix)
    s(
        { trig = "bmat", snippetType = "autosnippet" },
        fmta(
            [[
      \begin{bmatrix}
          <>
      \end{bmatrix}
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    -- SQUARE ROOT
    s({ trig = "sq", snippetType = "autosnippet" }, fmta("\\sqrt{<>}", { i(1) }), { condition = in_mathzone }),

    --- ARRAYS
    s(
        { trig = "ar", snippetType = "autosnippet" },
        fmta(
            [[
      \begin{array}
          <>
      \end{array}
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    s(
        { trig = "lar", snippetType = "autosnippet" },
        fmta(
            [[
      \left \{ 
      \begin{array}
          <>
      \end{array}
      \right .
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    s(
        { trig = "rar", snippetType = "autosnippet" },
        fmta(
            [[
      \left . 
      \begin{array}
          <>
      \end{array}
      \right \}
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),

    s(
        { trig = "{}ar", snippetType = "autosnippet" },
        fmta(
            [[
      \left \{
      \begin{array}
          <>
      \end{array}
      \right \}
      ]],
            { i(1) }
        ),
        { condition = in_mathzone }
    ),
}
