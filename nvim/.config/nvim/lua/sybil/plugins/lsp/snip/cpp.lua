local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return {
	-- ==========================================
	-- 1. HEADERS & BOILERPLATE
	-- ==========================================

	-- MAIN function
	-- Fix: Escape <iostream> to <<iostream>>
	s(
		{ trig = "main", snippetType = "autosnippet" },
		fmta(
			[[
        #include <<iostream>>

        int main(int argc, char *argv[]) {
            <>

            return 0;
        }
        ]],
			{ i(0) }
		)
	),

	-- INCLUDE (standard) -> #include <...>
	-- Fix: Use << to start literal <, then <> for node, then >> for literal >
	s({ trig = "inc", snippetType = "autosnippet" }, fmta("#include <<<> >>", { i(1) })),

	-- INCLUDE (local) -> #include "..."
	s({ trig = "Inc", snippetType = "autosnippet" }, fmta('#include "<>"', { i(1) })),

	-- COMPETITIVE PROGRAMMING TEMPLATE
	-- Fix: Escape bits/stdc++.h and stream operators
	s(
		{ trig = "cp", snippetType = "autosnippet" },
		fmta(
			[[
        #include <<bits/stdc++.h>>
        using namespace std;

        void solve() {
            <>
        }

        int main() {
            ios_base::sync_with_stdio(0); cin.tie(0);
            int t; cin >>>> t;
            while(t--) {
                solve();
            }
            return 0;
        }
        ]],
			{ i(0) }
		)
	),

	-- ==========================================
	-- 2. I/O (Printing & Reading)
	-- ==========================================

	-- COUT (std::cout)
	-- Fix: Escape << operators to <<<<
	s({ trig = "cout", snippetType = "autosnippet" }, fmta("std::cout <<<< <> <<<< std::endl;", { i(1) })),

	-- COUT (using namespace std style)
	s({ trig = "pout", snippetType = "autosnippet" }, fmta("cout <<<< <> <<<< endl;", { i(1) })),

	-- CIN
	-- Fix: Escape >> operators to >>>>
	s({ trig = "cin", snippetType = "autosnippet" }, fmta("std::cin >>>> <>;", { i(1) })),

	-- ==========================================
	-- 3. CONTROL FLOW
	-- ==========================================

	-- FOR LOOP (Standard Index)
	-- Fix: Escape comparison operator < to <<
	s(
		{ trig = "fori", snippetType = "autosnippet" },
		fmta(
			[[
        for (int <> = 0; <> << <>; ++<>) {
            <>
        }
        ]],
			{ i(1, "i"), rep(1), i(2, "n"), rep(1), i(0) }
		)
	),

	-- FOR LOOP (Range Based)
	s(
		{ trig = "forr", snippetType = "autosnippet" },
		fmta(
			[[
        for (auto& <> : <>) {
            <>
        }
        ]],
			{ i(1, "x"), i(2, "container"), i(0) }
		)
	),

	-- IF STATEMENT
	s(
		{ trig = "if", snippetType = "autosnippet" },
		fmta(
			[[
        if (<>) {
            <>
        }
        ]],
			{ i(1), i(0) }
		)
	),

	-- ELSE IF
	s(
		{ trig = "elif", snippetType = "autosnippet" },
		fmta(
			[[
        else if (<>) {
            <>
        }
        ]],
			{ i(1), i(0) }
		)
	),

	-- WHILE LOOP
	s(
		{ trig = "wh", snippetType = "autosnippet" },
		fmta(
			[[
        while (<>) {
            <>
        }
        ]],
			{ i(1), i(0) }
		)
	),

	-- ==========================================
	-- 4. DATA STRUCTURES & CLASS
	-- ==========================================

	-- CLASS declaration
	s(
		{ trig = "cl", snippetType = "autosnippet" },
		fmta(
			[[
        class <> {
        public:
            <>(<>);
            ~rep(1)();

        private:
            <>
        };
        ]],
			{ i(1, "ClassName"), rep(1), i(2), i(0) }
		)
	),

	-- STRUCT
	s(
		{ trig = "st", snippetType = "autosnippet" },
		fmta(
			[[
        struct <> {
            <>
        };
        ]],
			{ i(1, "StructName"), i(0) }
		)
	),

	-- STD::VECTOR
	-- Fix: Escape template brackets << >>
	s({ trig = "vec", snippetType = "autosnippet" }, fmta("std::vector<<<> >> <>", { i(1, "int"), i(2, "v") })),

	-- STD::MAP
	s(
		{ trig = "map", snippetType = "autosnippet" },
		fmta("std::map<< <>, <> >> <>", { i(1, "key"), i(2, "value"), i(3, "m") })
	),

	-- ==========================================
	-- 5. MODERN C++ / MISC
	-- ==========================================

	-- LAMBDA FUNCTION
	s({ trig = "ld", snippetType = "autosnippet" }, fmta("[<>] (<>) { <> };", { i(1, "&"), i(2), i(0) })),

	-- TEMPLATE
	s({ trig = "tpl", snippetType = "autosnippet" }, fmta("template <<typename <> >>", { i(1, "T") })),

	-- CAST (static_cast)
	s(
		{ trig = "cast", snippetType = "autosnippet" },
		fmta("static_cast<<<> >>(<>)<>", { i(1, "type"), i(2, "var"), i(0) })
	),
}
